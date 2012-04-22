#!/bin/bash

appldir="sysvinit-2.86"
applurl="ftp://ftp.cistron.nl/pub/people/miquels/software/sysvinit-2.86.tar.gz"

pkg_name=`basename ${applurl}`
pkg_full=${PACKAGE_PATH}/${pkg_name}
src_full=${SOURCES_PATH}/${appldir}

if [ ! -f ${pkg_full} ]; then
    wget --tries=10 --wait=5 --continue ${applurl} -P ${PACKAGE_PATH}
fi
echo -n "Extracting ${pkg_name} .... "
tar -xf ${pkg_full} -C ${SOURCES_PATH}
echo "Done."

cd ${src_full}/src
sed -i '0,/RE/s/gcc/mipsel-linux-gnu-gcc/' Makefile
make && make ROOT=${ROOTFS_PATH} install || exit 1
cd -






