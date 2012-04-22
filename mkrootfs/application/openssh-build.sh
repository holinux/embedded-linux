#!/bin/bash

appldir="openssh-5.6p1"
applurl="http://mirror.rit.edu/pub/OpenBSD/OpenSSH/portable/openssh-5.6p1.tar.gz"

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
    --prefix=${ROOTFS_PATH} \
    --disable-strip \
    || exit 1
make && make install-nokeys || exit 1
cd -






