#!/bin/bash

# compile and install python
cd /
wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tar.xz
tar xvf Python-3.9.5.tar.xz
cd Python-3.9.5

export FLAGS="-march=armv5te -mtune=arm926ej-s -mfloat-abi=soft -I/dst/usr/local/include -I/dst/usr/include -L/dst/usr/local/lib -L/dst/usr/lib -I/usr/local/arm-linux-musleabi/include -L/usr/local/arm-linux-musleabi/lib -fno-semantic-interposition"

cat <<EOF > Modules/Setup.local
*shared*
zlib zlibmodule.c -lz
pyexpat expat/xmlparse.c expat/xmlrole.c expat/xmltok.c pyexpat.c -I$(srcdir)/Modules/expat -DHAVE_EXPAT_CONFIG_H -DXML_POOR_ENTROPY -DUSE_PYEXPAT_CAPI -lexpat

*disabled*
_sqlite3
_tkinter
_curses
_codecs_jp
_codecs_kr
_codecs_tw
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
