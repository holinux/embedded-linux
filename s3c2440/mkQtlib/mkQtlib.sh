#!/bin/bash
#
# Author: Hongwang <hoakee@gmai.com>
# One Linux fans from University of Sci-Tech of China
# Script to build linux kernel image for embedded ARM board 
# 2009-05-16 first version, 
#

WORKROOT=${PWD}

# ===========================================================================
QT="qt-everywhere-opensource-src-4.6.0"
QT_URL="ftp://ftp.denx.de/qt-everywhere-opensource-src-4.6.0.tar.bz2"

#for pkg_url in ${QT_URL}
#do
#    pkg_name=`basename ${pkg_url}`
#    if [ ! -f ${pkg_name} ]; then
#        wget --tries=10 --wait=5 --continue ${pkg_url}
#    fi
#    echo -n "Extracting ${pkg_name} .... "
#    tar -xf ${pkg_name} -C ${WORKROOT} 
#    echo "Done."
#done
# ===========================================================================

sed -i 's/arm-linux/arm-hwlee-linux-gnueabi/' \
${WORKROOT}/${QT}/mkspecs/qws/linux-arm-g++/qmake.conf


cd ${WORKROOT}/${QT}
./configure -release -embedded arm -v -little-endian -prefix /home/hongwang/Qtlibroot -xplatform qws/linux-arm-g++ -no-qt3support -no-nis -no-cups -no-iconv -no-qdbus -no-freetype -depths 4,8,16,32 -qt-mouse-linuxtp -qvfb


make && make install || exit 1


# ===========================================================================


