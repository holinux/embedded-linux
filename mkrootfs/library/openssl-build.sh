#!/bin/bash

appldir="openssl-1.0.0a"
applurl="http://www.openssl.org/source/openssl-1.0.0a.tar.gz"

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
./Configure linux-armv4:arm-hwlee-linux-gnueabi-gcc no-asm --prefix=${PREFIX_PATH} || exit 1
make && make install || exit 1
cd -






