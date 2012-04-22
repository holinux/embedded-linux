#!/bin/bash

PACKAGE_PATH="/home/holi/Packages"
SOURCES_PATH="/home/holi/Source"
ROOTFS_PATH="/tmp/holi/nfsroot"
TARGET_HOST="mipsel-linux-gnu"
SCRIPTS_LIST="appls.list"

mkdir -pv ${ROOTFS_PATH}
cp template/* ${ROOTFS_PATH}/ -Rf
if [ $? -ne 0 ]; then exit 1; fi
sudo mknod ${ROOTFS_PATH}/dev/console c 5 1
sudo mknod ${ROOTFS_PATH}/dev/null c 1 3

cd application
cat ${SCRIPTS_LIST} | while read EACHLINE
do
    EACHLINE=$(echo ${EACHLINE} | sed -e '/ *\#/d') 
    if [ ${EACHLINE}XX != XX ]; then
        echo "Calling ${EACHLINE} ..."
        source ${EACHLINE}
    fi
done

exit 0

#===========================================================================
echo "====================================================================="
echo "========= Step 3: Copy and Strip Library Files ======================"
echo "====================================================================="
echo "Copy files to nfsroot/lib directory..."
LIBSRCDIR=/usr/local/arm/4.4.0/arm-hwlee-linux-gnueabi/lib
for LIBS in ld- libdl libc libfreetype libjpeg libpng libpthread \
        librt libutil libstdc++ libz libgcc_s libm- libm. libnsl \
        libresolv libssp
do
    cp -rf ${LIBSRCDIR}/${LIBS}*so* ${ROOTFS_PATH}/lib
done
#===========================================================================

#===========================================================================
echo "====================================================================="
echo "========= Step 6: Remove and Strip Libs  ============================"
echo "====================================================================="
#===========================================================================
cd ${ROOTFS_PATH}/usr
#####################################################
echo "Remove noused files..."
find -name man      | xargs rm -rf
find -name \*config | xargs rm -rf
find -name aclocal  | xargs rm -rf
find -name include  | xargs rm -rf

STRIP=arm-hwlee-linux-gnueabi-strip
cd ${ROOTFS_PATH}/lib
for EXT in a h la
do 
	find -name \*.${EXT} | xargs rm -rf
done
cd ${ROOTFS_PATH}/usr/lib
for EXT in a h la
do 
	find -name \*.${EXT} | xargs rm -rf
done


######################################################
echo "Strip($STRIP)..."
for f in ${ROOTFS_PATH}"/lib/"*.so.* \
    ${ROOTFS_PATH}"/usr/bin/"* \
    ${ROOTFS_PATH}"/bin/"* \
    ${ROOTFS_PATH}"/sbin/"*
  #  ${ROOTFS_PATH}"/usr/lib/"*.so.* \
do
	$STRIP $f
done
