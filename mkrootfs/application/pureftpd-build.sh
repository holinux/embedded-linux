#!/bin/bash

appldir="pure-ftpd-1.0.29"
applurl="http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.29.tar.bz2"

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
    --with-sysquotas \
    --with-altlog \
    --with-puredb \
    --with-extauth \
    --with-ftpwho \
    --with-welcomemsg \
    --with-uploadscript \
    || exit 1
make && make install || exit 1
cd -






