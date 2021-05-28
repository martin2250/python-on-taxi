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
apt install -y wget python3.8
wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz
tar xvzf Python-3.8.0.tgz
cd Python-3.8.0

export CC=arm-linux-musleabi-gcc
export LD=arm-linux-musleabi-ld
export CPP=arm-linux-musleabi-cpp

export FLAGS="-static -marm -mthumb-interwork -march=armv5te+nofp -mtune=arm926ej-s -mfloat-abi=soft"

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    RANLIB=arm-linux-musleabi-ranlib \
    ./configure --host=arm-linux-musleabi --target=arm-linux-musleabi \
    --build=x86_64-linux-gnu --prefix=$HOME/rapsberry/depsBuild/python \
    --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
    ac_cv_have_long_long_format=yes --disable-shared --enable-optimizations CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXFLAGS="$FLAGS"

make -j 6 HOSTPYTHON=/usr/bin/python3 \
    BLDSHARED="arm-linux-musleabi-gcc -shared" CROSS-COMPILE=arm-linux-musleabi- \
    CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-musleabi-gcc CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXFLAGS="$FLAGS" LINKFORSHARED=" "

mkdir /dst
make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install

cd /dst
cp -rl root/rapsberry/depsBuild/python/* usr/ # yes, "rapsberry" is not a typo
rm -r root
ln -s python3 usr/bin/python

echo '#!/bin/bash' > uninstall_python.sh
echo "cd /" >> uninstall_python.sh
echo -n "rm " >> uninstall_python.sh
find usr -type f | tr '\n' ' ' >> uninstall_python.sh
echo "" >> uninstall_python.sh
echo -n "rmdir " >> uninstall_python.sh
find usr -type d | tr '\n' ' ' >> uninstall_python.sh
chmod +x uninstall_python.sh

tar cvzf python3.8-static-root.tar.gz usr uninstall_python.sh
```

Exit the docker container and copy the final file to your system / to TAXI:
```bash
docker cp python-on-taxi:/dst/python3.8-static-root.tar.gz .
scp python3.8-static-root.tar.gz taxi105:/home/root
```

## Installation
Install python on the TAXI:
```bash
tar xvzf python3.8-static-root.tar.gz -C /
```

Before installing a new version of python, remove the old one:
```bash
cd /
./uninstall_python.sh
```
