#!/bin/bash

FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft"
SOURCEFILE=R_2_4_1

# compile readline
cd /
wget https://github.com/libexpat/libexpat/archive/refs/tags/$SOURCEFILE.tar.gz
tar xvf $SOURCEFILE.tar.gz
cd libexpat-$SOURCEFILE/expat

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    cmake \
    -DCMAKE_INSTALL_PREFIX=/usr

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    make -j 6

make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install
