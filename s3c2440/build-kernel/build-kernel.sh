#!/bin/bash
#
# Author: Hongwang <hoakee@gmai.com>
# One Linux fans from University of Sci-Tech of China
# Script to build linux kernel image for embedded ARM board 
# 2009-05-10 first version, 
#

WORKROOT=${PWD}
TFTPROOT="/home/hongwang/tftproot"
SOURCEDIR="/home/hongwang/source"
BUILDDIR="/home/hongwang/build"
PACKAGEDIR="/home/hongwang/package"
mkdir -pv ${PACKAGEDIR}

# ==========================================================================
# ====================== Download and Extract packages =====================
KERNEL="linux-2.6.32"
KERNEL_URL="http://mirror.rootguide.org/kernel.org/linux/kernel/v2.6/linux-2.6.32.tar.bz2"

cd ${PACKAGEDIR}
for pkg_url in ${KERNEL_URL}
do
    pkg_name=`basename ${pkg_url}`
    if [ ! -f ${pkg_name} ]; then
        wget --tries=10 --wait=5 --continue ${pkg_url}
    fi
    if [ ! -d ${SOURCEDIR}/${KERNEL} ]; then
        echo -n "Extracting ${pkg_name} .... "
        tar -xf ${pkg_name} -C ${SOURCEDIR} 
        echo "Done."
    fi
done
# ================================ END =====================================

#cp -v ../dm9000.c drivers/net/
# ================================ DONE ====================================

# ==========================================================================
# =========================== Finally, Compile =============================
# ==========================================================================

sed -i '/S3C_DEV_USB_HOST/ a \
    default y                \
' ${SOURCEDIR}/${KERNEL}/arch/arm/plat-s3c/Kconfig

cd ${SOURCEDIR}/${KERNEL}
make clean
make distclean
MAKEOPTION="ARCH=arm CROSS_COMPILE=arm-hwlee-linux-gnueabi-"
make ${MAKEOPTION} mini2440_defconfig

make ${MAKEOPTION} menuconfig

#make ${MAKEOPTION} uImage
make ${MAKEOPTION} zImage
#cp -v arch/arm/boot/uImage ${WORKROOT}
#cp -v arch/arm/boot/zImage ${WORKROOT}
cp -v arch/arm/boot/zImage ${TFTPROOT}
# ================================ DONE ====================================

echo "======================================================================"
echo "=================== All Done. Congratulations! ======================="
echo "======================================================================"

