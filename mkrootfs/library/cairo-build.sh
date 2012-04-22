#!/bin/bash

appldir="cairo-1.10.0"
applurl="http://cairographics.org/releases/cairo-1.10.0.tar.gz"

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
./configure \
./configure --host=${TARGET_HOST} --prefix=${PREFIX_PATH} --enable-xlib=no --enable-xlib-xcb=no --enable-qt=no --enable-quartz=no --enable-win32=no --enable-skia=no --enable-os2=no --enable-beos=no --enable-drm=no --enable-gallium=no --enable-glx=no --enable-wgl=no --enable-directfb=yes \
    || exit 1
make && make install || exit 1
cd -


