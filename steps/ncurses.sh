#!/bin/bash

FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft"
SOURCEFILE=ncurses-6.1

export TIC_PATH=/usr/bin/tic

# compile readline
cd /
wget https://ftp.gnu.org/pub/gnu/ncurses/$SOURCEFILE.tar.gz
tar xvf $SOURCEFILE.tar.gz
cd $SOURCEFILE

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    ./configure \
    --prefix=/usr \
    --with-shared \
    --with-normal \
    --without-debug \
    --without-ada \
    --host=arm-linux-musleabi --target=arm-linux-musleabi --build=x86_64-linux-gnu --disable-stripping
    # --with-cxx-binding \
    # --with-cxx-shared \

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    make -j 6


mkdir -p /dst/usr/share/terminfo/x/
make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install
