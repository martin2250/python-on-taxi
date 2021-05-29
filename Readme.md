# Python on TAXI
How to compile python to run on TAXI.

You can also use the precompiled binaries from the GitHub releases, just skip to `Installation`.

## Toolchain Setup
We're using a docker image to compile everything, this makes it much easier to set up the toolchain.

Start the docker container:
```bash
docker run --name python-on-taxi -it rustembedded/cross:armv5te-unknown-linux-musleabi /bin/bash
```

## Building Python
Run these commands inside the docker container:
```bash
apt update
apt install -y software-properties-common
add-apt-repository ppa:deadsnakes/ppa
apt update
apt install -y wget python3.9

wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tar.xz
tar xvf Python-3.9.5.tar.xz
cd Python-3.9.5

export FLAGS="-static -marm -mthumb-interwork -march=armv5te+nofp -mtune=arm926ej-s -mfloat-abi=soft"

./configure --host=arm-linux-musleabi --target=arm-linux-musleabi \
    --build=x86_64-linux-gnu --prefix=/usr --with-system-ffi \
    --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
    ac_cv_have_long_long_format=yes --disable-shared --enable-optimizations CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS"

make -j 6 HOSTPYTHON=/usr/bin/python3.9 \
    BLDSHARED="arm-linux-musleabi-gcc -shared" CROSS-COMPILE=arm-linux-musleabi- \
    CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-musleabi-gcc CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXFLAGS="$FLAGS" LINKFORSHARED=" "

mkdir /dst
# EDIT /usr/bin/lsb_release to use python3.9!!
make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install

cd /dst
ln -s python3 usr/bin/python

echo '#!/bin/sh' > uninstall_python.sh
echo "cd /" >> uninstall_python.sh
echo -n "rm " >> uninstall_python.sh
find usr -type f -exec echo '"{}" ' \; | sort -r | tr '\n' ' ' >> uninstall_python.sh
echo "" >> uninstall_python.sh
echo -n "rmdir " >> uninstall_python.sh
find usr -type d -exec echo '"{}" ' \; | sort -r | tr '\n' ' ' >> uninstall_python.sh
chmod +x uninstall_python.sh

tar cvzf python3.9.5-static-root.tar.gz usr uninstall_python.sh
```

Exit the docker container and copy the final file to your system / to TAXI:
```bash
docker cp python-on-taxi:/dst/python3.9.5-static-root.tar.gz .
scp python3.9.5-static-root.tar.gz taxi105:/home/root
```

## Installation
Install python on the TAXI:
```bash
tar xvzf python3.9.5-static-root.tar.gz -C /
```

Before installing a new version of python, remove the old one:
```bash
cd /
./uninstall_python.sh
```
