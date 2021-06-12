#!/bin/bash

FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft"
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
