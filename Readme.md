# Python on TAXI
How to compile python to run on TAXI.

You can also use the precompiled binaries from the GitHub releases, just skip to `Installation`.

## Current Issues
### libffi
ctypes does not work unless libffi is added to LD_PRELOAD:
```bash
LD_PRELOAD=/usr/lib/libffi.so.6 python
```

## Toolchain Setup
We're using a docker image to compile everything, this makes it much easier to set up the toolchain.

Start the docker container:
```bash
docker run --name python-on-taxi-musleabi -it rustembedded/cross:armv5te-unknown-linux-musleabi /bin/bash
# or to resume
docker exec -it python-on-taxi-musleabi bash
```

## Building Python
Run these commands inside the docker container:
```bash
# install host dependencies
apt update
apt install -y software-properties-common
add-apt-repository ppa:deadsnakes/ppa
apt update
apt install -y wget python3.9 # 8, 7

# create final build directory
rm -rf /dst #remove old build
mkdir /dst

# compile and install libffi
cd /
wget https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz
tar xvf libffi-3.3.tar.gz
cd libffi-3.3

export FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft"

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    ./configure --host=arm-linux-musleabi --target=arm-linux-musleabi --disable-static --prefix=/usr

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    make -j 6

make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install

# compile zlib
cd /
wget https://zlib.net/zlib-1.2.11.tar.gz
tar xvf zlib-1.2.11.tar.gz
cd zlib-1.2.11

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    ./configure --prefix=/usr

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    make -j 6

make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install

# compile and install python
cd /
wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tar.xz
tar xvf Python-3.9.5.tar.xz
cd Python-3.9.5

export FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft -I/dst/usr/local/include -I/dst/usr/include -L/dst/usr/local/lib -L/dst/usr/lib -I/usr/local/arm-linux-musleabi/include -L/usr/local/arm-linux-musleabi/lib"

cat <<EOF > Modules/Setup.local
*shared*
zlib zlibmodule.c -lz

*disabled*
_sqlite3
_tkinter
_curses
pyexpat
_codecs_jp
_codecs_kr
_codecs_tw
unicodedata
EOF

CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" CPPFLAGS="$FLAGS" PKG_CONFIG_PATH="/dst/usr/lib/pkgconfig/" \
    ./configure \
    --host=arm-linux-musleabi --target=arm-linux-musleabi --build=x86_64-linux-gnu \
    --prefix=/usr \
    --with-system-ffi \
    --disable-ipv6 \
    --enable-optimizations \
    --disable-test-modules \
    --without-static-libpython \
    --with-computed-gotos \
    --with-lto \
    ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes

# disable-test-modules will work starting with Python 3.10

CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" CPPFLAGS="$FLAGS" PKG_CONFIG_PATH="/dst/usr/lib/pkgconfig/" \
    make -j 6 HOSTPYTHON=/usr/bin/python3.9 \
    CROSS-COMPILE=arm-linux-musleabi- \
    CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-musleabi-gcc

sed -i '1s/.*/#!\/usr\/bin\/python3.9 -Es/' $(which lsb_release)

make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install

ln -s python3 /dst/usr/bin/python

# copy musl libc to dst
mkdir -p /dst/lib
cp /usr/local/arm-linux-musleabi/lib/libc.so /dst/lib/ld-musl-arm.so.1

# create uninstaller
cd /dst
echo '#!/bin/sh' > uninstall_python.sh
echo "cd /" >> uninstall_python.sh
echo -n "rm " >> uninstall_python.sh
find usr -type f -exec echo '"{}" ' \; | tr '\n' ' ' >> uninstall_python.sh
echo "" >> uninstall_python.sh
echo -n "rmdir " >> uninstall_python.sh
find usr -type d -exec echo '"{}" ' \; | sort -r | tr '\n' ' ' >> uninstall_python.sh # sort directories so e.g. /usr/bin is deleted before /usr
chmod +x uninstall_python.sh

# create tar package
tar cvzf python3.9.5-musleabi-root.tar.gz uninstall_python.sh usr
```

## Building python modules
in the docker container:
```bash
apt install -y python3-pip python3.9-distutils python3.9-distutils python3.9-venv
python3.9 -m pip install crossenv

cd /
python3.9 -m crossenv /dst/usr/bin/python3 venv

. venv/bin/activate

# build-pip install cffi cython

pip install cobs
# installed to venv/cross/lib/python3.9/site-packages

mkdir -p /dst_python/usr/lib/python3.9/site-packages
cp -r /venv/cross/lib/python3.9/site-packages/cobs /dst_python/usr/lib/python3.9/site-packages

# create uninstaller
cd /dst_python
UNINSTALLER="uninstall_python_modules.sh"
echo '#!/bin/sh' > $UNINSTALLER
echo "cd /" >> $UNINSTALLER
echo -n "rm " >> $UNINSTALLER
find usr -type f -exec echo '"{}" ' \; | tr '\n' ' ' >> $UNINSTALLER
echo "" >> $UNINSTALLER
echo -n "rmdir " >> $UNINSTALLER
find usr -type d -exec echo '"{}" ' \; | sort -r | tr '\n' ' ' >> $UNINSTALLER # sort directories so e.g. /usr/bin is deleted before /usr
chmod +x $UNINSTALLER

# create tar package
tar cvzf python3.9-modules-musleabi.tar.gz $UNINSTALLER usr lib
```

Exit the docker container and copy the final file to your system / to TAXI:
```bash
docker cp python-on-taxi:/dst/python3.9.5-musleabi-root.tar.gz .
docker cp python-on-taxi:/dst_python/python3.9-modules-musleabi.tar.gz .
scp python3.9.5-musleabi-root.tar.gz taxi105:/home/root
scp python3.9-modules-musleabi.tar.gz taxi105:/home/root
```

## Installation
Install python on the TAXI:
```bash
tar xvzf python3.9.5-musleabi-root.tar.gz -C /
```

Before installing a new version of python, remove the old one:
```bash
cd /
./uninstall_python.sh
```
