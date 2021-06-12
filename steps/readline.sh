#!/bin/bash

FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft"
SOURCEFILE=readline-8.1

# compile readline
cd /
wget https://ftp.gnu.org/gnu/readline/$SOURCEFILE.tar.gz
tar xvf $SOURCEFILE.tar.gz
cd $SOURCEFILE

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    ./configure \
    --prefix=/usr \
    --host=arm-linux-musleabi --target=arm-linux-musleabi --build=x86_64-linux-gnu

sed -i 's/SHLIB_LIBS = @SHLIB_LIBS@/SHLIB_LIBS = @SHLIB_LIBS@ -lncurses/' shlib/Makefile.in

CC=arm-linux-musleabi-gcc CXX=arm-linux-musleabi-g++ AR=arm-linux-musleabi-ar CPP=arm-linux-musleabi-cpp \
    CFLAGS="$FLAGS" LDFLAGS="$FLAGS" CXXFLAGS="$FLAGS" \
    make -j 6 SHLIB_LIBS=-lncurses

make DESTDIR="/dst/" EXTRA_CFLAGS="$FLAGS" install
