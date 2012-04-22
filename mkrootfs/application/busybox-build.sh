#!/bin/bash

appldir="busybox-1.18.4"
applurl="http://busybox.net/downloads/busybox-1.18.4.tar.bz2"

pkg_name=`basename ${applurl}`
pkg_full=${PACKAGE_PATH}/${pkg_name}
src_full=${SOURCES_PATH}/${appldir}

if [ ! -f ${pkg_full} ]; then
    wget --tries=10 --wait=5 --continue ${applurl} -P ${PACKAGE_PATH}
fi
echo -n "Extracting ${pkg_name} .... "
tar -xf ${pkg_full} -C ${SOURCES_PATH}
if [ $? -ne 0 ]; then exit 1; fi
echo "Done."

cd ${src_full}
sed -i 's/\(text.*=.*PS1=.*\)w /\1w/' shell/ash.c
sed -i 's/\(text.*=.*PS1=\)/\1Novatek:/' shell/ash.c
make defconfig
echo CONFIG_STATIC=y >> .config
echo CONFIG_FEATURE_EDITING_FANCY_PROMPT=y >> .config
#make ARCH=arm CROSS_COMPILE=arm-hwlee-linux-gnueabi- menuconfig
make ARCH=mips CROSS_COMPILE=mipsel-linux-gnu- || exit 1
make ARCH=mips CROSS_COMPILE=mipsel-linux-gnu- CONFIG_PREFIX=${ROOTFS_PATH} install || exit 1
cd -






