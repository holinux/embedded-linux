#!/bin/bash

appldir="glib-2.27.0"
applurl="http://ftp.acc.umu.se/pub/gnome/sources/glib/2.27/glib-2.27.0.tar.bz2"

pkg_name=`basename ${applurl}`
pkg_full=${PACKAGE_PATH}/${pkg_name}
src_full=${SOURCES_PATH}/${appldir}

if [ ! -f ${pkg_full} ]; then
    wget --tries=10 --wait=5 --continue ${applurl} -P ${PACKAGE_PATH}
fi
echo -n "Extracting ${pkg_name} .... "
tar -xf ${pkg_full} -C ${SOURCES_PATH}
echo "Done."

cd ${src_full}
./configure --host=arm-hwlee-linux-gnueabi --prefix=$PREFIX --with-gfxdrivers=none --with-inputdrivers=all --enable-png --enable-jpeg --enable-tiff --enable-zlib --enable-sdl=no --enable-gif=no --disable-x11 \
    || exit 1
make && make install || exit 1
cd -


