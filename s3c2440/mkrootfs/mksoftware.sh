#!/bin/bash
#
# Author: Hongwang <hoakee@gmai.com>
# One Linux fans from University of Sci-Tech of China
# Script to make rootfs images for embedded ARM-Linux board 
# 2009-05-10 first version, with mdev support
#

echo ${ROOTFS}
echo ${PACKAGE}
echo ${SOURCES}

ROOTFS=${PWD}/rootfs
PACKAGE=${PWD}/package
SOURCES=${PWD}/sources
#rm -Rf ${ROOTFS} ${SOURCES}
#mkdir -pv ${ROOTFS} ${PACKAGE} ${SOURCES}


YAFFS2="yaffs2"
YAFFS2_URL="http://www.aleph1.co.uk/cgi-bin/viewcvs.cgi/yaffs2.tar.gz"
ZLIB="zlib-1.2.3"
ZLIB_URL="http://www.zlib.net/zlib-1.2.3.tar.gz"
LZO="lzo-2.03"
LZO_URL="http://www.oberhumer.com/opensource/lzo/download/lzo-2.03.tar.gz"
MTDUTILS="mtd-utils-1.2.0"
MTDUTILS_URL="ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-1.2.0.tar.bz2"
LIBID3TAG="libid3tag-0.15.1b"
LIBID3TAG_URL="http://ncu.dl.sourceforge.net/sourceforge/mad/libid3tag-0.15.1b.tar.gz"
LIBMAD="libmad-0.15.1b"
LIBMAD_URL="http://ncu.dl.sourceforge.net/sourceforge/mad/libmad-0.15.1b.tar.gz"
MADPLAY="madplay-0.15.2b"
MADPLAY_URL="http://ncu.dl.sourceforge.net/sourceforge/mad/madplay-0.15.2b.tar.gz"
MPLAYER="MPlayer-1.0rc2"
MPLAYER_URL="http://www.mplayerhq.hu/MPlayer/releases/MPlayer-1.0rc2.tar.bz2"


cd ${PACKAGE}
for pkg_url in ${ZLIB_URL} ${LZO_URL} ${MTDUTILS_URL} \
    ${LIBID3TAG_URL} ${LIBMAD_URL} ${MADPLAY_URL}
do
    pkg_name=`basename ${pkg_url}`
    if [ ! -f ${pkg_name} ]; then
        wget --tries=10 --wait=5 --continue ${pkg_url}
    fi
    echo -n "Extracting ${pkg_name} .... "
    tar -xf ${pkg_name} -C ${SOURCES} 
    echo "Done."
done

cd ${SOURCES}/${ZLIB}
CC=arm-hwlee-linux-gnueabi-gcc \
./configure     \
    --shared    \
    --prefix=/usr/local/arm/4.4.0/arm-hwlee-linux-gnueabi
make && make install || exit 1

cd ${SOURCES}/${LZO}
CC=arm-hwlee-linux-gnueabi-gcc \
./configure     \
    --host=arm-hwlee-linux-gnueabi \
    --prefix=/usr/local/arm/4.4.0/arm-hwlee-linux-gnueabi
make && make install || exit 1

cd ${SOURCES}/${MTDUTILS}
sed -i 's/$(BUILDDIR)\/ubi-utils/ubi-utils/' Makefile
sed -i 's/<limits.h>/<linux\/limits.h>/' ubi-utils/src/libpfiflash.c
sed -i 's/<limits.h>/<linux\/limits.h>/' ubi-utils/src/libubimirror.c
sed -i 's/<limits.h>/<linux\/limits.h>/' ubi-utils/src/pddcustomize.c
sed -i 's/<limits.h>/<linux\/limits.h>/' ubi-utils/src/unubi.c
sed -i 's/<limits.h>/<linux\/limits.h>/' ubi-utils/src/unubi_analyze.c
make CROSS=arm-hwlee-linux-gnueabi- WITHOUT_XATTR=1 || exit 1
make CROSS=arm-hwlee-linux-gnueabi- WITHOUT_XATTR=1 DESTDIR=${ROOTFS} install

cd ${SOURCES}/${LIBID3TAG}
CC=arm-hwlee-linux-gnueabi-gcc \
./configure \
    --prefix=/usr/local/arm/4.4.0/arm-hwlee-linux-gnueabi \
    --host=arm-hwlee-linux-gnueabi \
    --disable-debugging \
    --disable-shared    \
    --enable-static
make && make install || exit 1
    
cd ${SOURCES}/${LIBMAD}
CC=arm-hwlee-linux-gnueabi-gcc \
./configure \
    --prefix=/usr/local/arm/4.4.0/arm-hwlee-linux-gnueabi \
    --host=arm-hwlee-linux-gnueabi \
    --disable-debugging \
    --disable-shared    \
    --enable-static
sed -i 's/-fforce-mem//g' Makefile
make && make install || exit 1

cd ${SOURCES}/${MADPLAY}
CC=arm-hwlee-linux-gnueabi-gcc \
./configure             \
    --host=arm-hwlee-linux-gnueabi    \
    --disable-debugging \
    --disable-shared    \
    --enable-static
make && make DESTDIR=${ROOTFS} install || exit 1
    
#cd ${SOURCES}/${MPLAYER}
#./configure \
#    --host-cc=gcc \
#    --cc=arm-hwlee-linux-gnueabi-gcc \
#    --target=arm-hwlee-linux-gnueabi \
#    --enable-static \
#    --prefix={ROOTFS} \
#    --disable-win32dll \
#    --disable-dvdread \
#    --disable-libdvdcss-internal \
#    --disable-mencoder \
#    --disable-live \
#    --disable-mp3lib \
#    --disable-armv5te \
#    --disable-armv6 \
#    --disable-ivtv \
#    --enable-fbdev \
#    --enable-mad \
#    --enable-libavcodec_a || exit 1
#make && make install || exit 1


echo "============================================================="
echo "=============== All Done. Congratulations! =================="
echo "============================================================="
