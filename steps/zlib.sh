#!/bin/bash

FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft"
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
