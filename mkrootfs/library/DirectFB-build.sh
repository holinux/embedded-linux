#!/bin/bash

appldir="DirectFB-1.4.5"
applurl="http://www.directfb.org/downloads/Core/DirectFB-1.4/DirectFB-1.4.5.tar.gz"

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


