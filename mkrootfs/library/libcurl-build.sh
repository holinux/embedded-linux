#!/bin/bash

appldir="curl-7.21.1"
applurl="http://curl.haxx.se/download/curl-7.21.1.tar.gz"

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
    --host=${TARGET_HOST} \
    --with-random=/dev/random \
    --with-libssh2 \
    || exit 1

make && make DESTDIR=${ROOTFS_PATH} install || exit 1
cd -

