#!/bin/sh

PACKAGE=${PWD}/package
SOURCES=${PWD}/sources
#INSTALL_PATH=${PWD}/rootfs
export PREFIX=${PWD}/rootfs/usr
export LDFLAGS=-L${PREFIX}/lib
export CFLAGS="-g -I${PREFIX}/include"
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
export CC=arm-hwlee-linux-gnueabi-gcc
export CXX=arm-hwlee-linux-gnueabi-c++

# 0.下载并解压必要的软件包
# tslib-1.4, glib-2.12.13, atk-1.20.0, jpegsrc.v6b, zlib-1.2.3
# libpng-1.2.24, expat-2.0.1, freetype-2.3.5, libxml2-2.6.30, fontconfig-2.5.0
# tiff-3.7.4, DirectFB-1.1.1, cairo-1.4.12, pango-1.16.4, gtk+-2.10.14
TSLIB="tslib-1.4"
TSLIB_URL="http://blogimg.chinaunix.net/blog/upfile2/090115225055.gz"
GLIB="glib-2.21.5"
GLIB_URL="http://ftp.gnome.org/pub/gnome/sources/glib/2.21/glib-2.21.5.tar.bz2"
ATK="atk-1.27.90"
ATK_URL="http://ftp.acc.umu.se/pub/GNOME/sources/atk/1.27/atk-1.27.90.tar.bz2"
JPEGSRC="jpeg-7"
JPEGSRC_URL="http://www.ijg.org/files/jpegsrc.v7.tar.gz"
ZLIB="zlib-1.2.3"
ZLIB_URL="http://www.zlib.net/zlib-1.2.3.tar.gz"
LIBPNG="libpng-1.2.39"
LIBPNG_URL="ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.39.tar.gz"
EXPAT="expat-2.0.1"
EXPAT_URL="http://downloads.sourceforge.net/project/expat/expat/2.0.1/expat-2.0.1.tar.gz"
FREETYPE="freetype-2.3.9"
FREETYPE_URL="http://ftp.cc.uoc.gr/mirrors/nongnu.org/freetype/freetype-2.3.9.tar.bz2"
LIBXML2="libxml2-2.7.3"
LIBXML2_URL="ftp://xmlsoft.org/libxml2/libxml2-2.7.3.tar.gz"
FONTCONFIG="fontconfig-2.7.1"
FONTCONFIG_URL="http://cgit.freedesktop.org/fontconfig/snapshot/fontconfig-2.7.1.tar.bz2"
TIFF="tiff-3.8.2"
TIFF_URL="http://dl.maptools.org/dl/libtiff/tiff-3.8.2.tar.gz"
DIRECTFB="DirectFB-1.4.2"
DIRECTFB_URL="http://www.directfb.org/downloads/Core/DirectFB-1.4/DirectFB-1.4.2.tar.gz"
PIXMAN="pixman-0.16.0"
PIXMAN_URL="http://cairographics.org/releases/pixman-0.16.0.tar.gz"
CAIRO="cairo-1.9.2"
CAIRO_URL="http://cairographics.org/snapshots/cairo-1.9.2.tar.gz"
PANGO="pango-1.25.5"
PANGO_URL="http://ftp.gnome.org/pub/gnome/sources/pango/1.25/pango-1.25.5.tar.bz2"
GTK="gtk+-2.10.14"
GTK_URL="http://ftp.gnome.org/pub/gnome/sources/gtk+/2.16/gtk+-2.10.14.tar.bz2"

cd ${PACKAGE}
for pkg_url in ${TSLIB_URL} ${GLIB_URL} ${ATK_URL} ${JPEGSRC_URL} ${ZLIB_URL} ${LIBPNG_URL} \
            ${EXPAT_URL} ${FREETYPE_URL} ${LIBXML2_URL} ${FONTCONFIG_URL} ${TIFF_URL} \
            ${DIRECTFB_URL} ${PIXMAN_URL} ${CAIRO_URL} ${PANGO_URL} ${GTK_URL}
do
    pkg_name=`basename ${pkg_url}`
    if [ ! -f ${pkg_name} ]; then
        wget --tries=10 --wait=5 --continue ${pkg_url}
    fi
    echo -n "Extracting ${pkg_name} .... "
    tar -xf ${pkg_name} -C ${SOURCES}
    echo "Done."
done

# 1.交叉编译tslib， 依赖的库： 无
echo "=========开始交叉编译tslib========="
cd ${SOURCES}/tslib
./autogen.sh
echo "ac_cv_func_malloc_0_nonnull=yes" > arm-linux.cache
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --cache-file=arm-linux.cache --enable-inputapi=no
make && make install || exit 1


# 2.交叉编译glib， 依赖的库： 无
echo "=========开始交叉编译glib========="
cd ${SOURCES}/${GLIB}
sed -i 's/SSIZE_MAX/32767/g' glib/giounix.c
echo "ac_cv_type_long_long=yes" > arm-linux.cache
echo "glib_cv_stack_grows=no" >> arm-linux.cache
echo "glib_cv_uscore=no" >> arm-linux.cache
echo "ac_cv_func_posix_getpwuid_r=yes" >> arm-linux.cache
echo "ac_cv_func_posix_getgrgid_r=yes" >> arm-linux.cache
./configure --host=arm-hwlee-linux-gnueabi --build=i686-pc-linux --prefix=$PREFIX --cache-file=arm-linux.cache
make && make install || exit 1


# 3.交叉编译atk， 依赖的库： glib
echo "=========开始交叉编译atk========="
cd ${SOURCES}/${ATK}
./configure --host=arm-hwlee-linux-gnueabi --prefix=${PREFIX}
make && make install || exit 1


# 4.交叉编译jpeg， 依赖的库： 无
echo "=========开始交叉编译jpeg========="
cd ${SOURCES}/${JPEGSRC}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --enable-shared --enable-static
mkdir $PREFIX/man
mkdir $PREFIX/man/man1
make && make install || exit 1


# 5.交叉编译zlib， 依赖的库： 无
echo "=========开始交叉编译zlib========="
cd ${SOURCES}/${ZLIB}
CC=arm-hwlee-linux-gnueabi-gcc \
./configure --prefix=$PREFIX --shared
make && make install || exit 1


# 6.交叉编译libpng， 依赖的库： 无
echo "=========开始交叉编译libpng========="
cd ${SOURCES}/${LIBPNG}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX
make && make install || exit 1


# 7.交叉编译expat， 依赖的库： 无
echo "=========开始交叉编译expat========="
cd ${SOURCES}/${EXPAT}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX
make && make install || exit 1


# 8.交叉编译freetype， 依赖的库： 无
echo "=========开始交叉编译freetype========="
cd ${SOURCES}/${FREETYPE}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX
make && make install || exit 1


# 9.交叉编译libxml， 依赖的库： 无
echo "=========开始交叉编译libxml========="
cd ${SOURCES}/${LIBXML2}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX
make && make install || exit 1


# 10.交叉编译fontconfig， 依赖的库： freetype, libxml2
echo "=========开始交叉编译fontconfig========="
cd ${SOURCES}/${FONTCONFIG}
export LIBXML2_CFLAGS=-I$PREFIX/include/libxml2
export LIBXML2_LIBS="-L$PREFIX/lib -lxml2"
./autogen.sh --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --with-freetype-config=$PREFIX/bin/freetype-config --with-arch=arm
make && make install || exit 1


# 11.交叉编译tiff， 依赖的库： jpeg, zlib
echo "=========开始交叉编译tiff========="
cd ${SOURCES}/${TIFF}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --enable-shared
make && make install || exit 1


# 12.交叉编译DirectFB， 依赖的库： 无
echo "=========开始交叉编译DirectFB========="
cd ${SOURCES}/${DIRECTFB}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --with-gfxdrivers=none --with-inputdrivers=all --enable-png --enable-jpeg --enable-tiff --enable-zlib --enable-sdl=no --enable-gif=no --disable-x11
make && make install || exit 1


# 13.交叉编译pixman， 依赖的库：
echo "=========开始交叉编译pixman========="
cd ${SOURCES}/${PIXMAN}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX
make && make install || exit 1


# 14.交叉编译cairo， 依赖的库： pixman, freetype，zlib
echo "=========开始交叉编译cairo========="
cd ${SOURCES}/${CAIRO}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --without-x --disable-xlib --disable-xlib-xrender --enable-directfb --disable-win32 --enable-pdf --enable-ps --disable-svg --enable-png
make && make install || exit 1


# 15.交叉编译pango， 依赖的库： glib, freetype, xml
echo "=========开始交叉编译pango========="
cd ${SOURCES}/${PANGO}
sed -i -e 's/have_cairo=false/have_cairo=true/g' configure
sed -i -e 's/have_cairo_png=false/have_cairo_png=true/g' configure
sed -i -e 's/have_cairo_ps=false/have_cairo_ps=true/g' configure
sed -i -e 's/have_cairo_pdf=false/have_cairo_pdf=true/g' configure
sed -i -e 's/have_cairo_freetype=false/have_cairo_freetype=true/g' configure
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --enable-static --without-x
make && make install || exit 1


# 16.交叉编译gtk， 依赖的库： glib, pango, atk, cairo, DirectFB
echo "=========开始交叉编译gtk========="
cd ${SOURCES}/${GTK}
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CPPFLAGS="-I$PREFIX/include"
cat > config.cache << EOF
gio_can_sniff=yes
EOF
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --with-gdktarget=directfb --without-x --without-libtiff --without-libjasper --cache-file=config.cache
make && make install || exit 1


echo "=========交叉编译全部结束========="

