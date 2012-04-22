#!/bin/sh
#
# Author: Hongwang Li <hoakee@gmail.com>    
# From:   University of Sci-Tech of China
# History: 
# 2009-05-12 Change RESULT_DIR to /usr/local/arm/4.4.0/. 
#            Add log.txt to record time cost.
# 2009-05-09 Binutils-2.19==>2.19.1. Apply many patches.
# 2009-05-02 First version, works well on my computer
# 

if [ ${USER} = root ]; then
	echo "DO NOT run as root!"
	exit 1
fi

#==============================================================
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install libncurses5-dev
sudo apt-get install bison flex m4
#==============================================================

#==============================================================
PWD=`pwd`
PACKAGE_DIR=${PWD}/package
BUILD_DIR=${PWD}/build
PATCH_DIR=${PWD}/patch
RESULT_DIR=/usr/local/arm/4.4.0
SOURCE_DIR=${PWD}/source

HOST=i686-pc-linux-gnu
TARGET=arm-hwlee-linux-gnueabi
TARGET_PREFIX=${RESULT_DIR}/${TARGET}
#==============================================================

#==============================================================
PACKAGE_BINUTILS="binutils-2.19.1"
PACKAGE_BINUTILS_URL=http://oss.ustc.edu.cn/gnu/binutils/binutils-2.19.1.tar.bz2
PACKAGE_KERNEL="linux-2.6.29"
PACKAGE_KERNEL_URL=http://oss.ustc.edu.cn/linux-kernel/v2.6/linux-2.6.29.tar.bz2
PACKAGE_GCC="gcc-4.4.0"
PACKAGE_GCC_URL=http://oss.ustc.edu.cn/gnu/gcc/gcc-4.4.0/gcc-4.4.0.tar.bz2
PACKAGE_GMP="gmp-4.3.0"
PACKAGE_GMP_URL=http://oss.ustc.edu.cn/gnu/gmp/gmp-4.3.0.tar.bz2
PACKAGE_MPFR="mpfr-2.4.1"
PACKAGE_MPFR_URL=http://www.mpfr.org/mpfr-current/mpfr-2.4.1.tar.bz2
PACKAGE_GLIBC="glibc-2.9"
PACKAGE_GLIBC_URL=http://oss.ustc.edu.cn/gnu/glibc/glibc-2.9.tar.bz2
PACKAGE_GLIBCPORTS="glibc-ports-2.9"
PACKAGE_GLIBCPORTS_URL=http://ftp.cross-lfs.org/pub/clfs/conglomeration/glibc/glibc-ports-2.9.tar.bz2
PACKAGE_GDB="gdb-6.8"
PACKAGE_GDB_URL=http://oss.ustc.edu.cn/gnu/gdb/gdb-6.8.tar.bz2
PACKAGE_INSIGHT="insight-6.8"
PACKAGE_INSIGHT_URL=ftp://sourceware.org/pub/insight/releases/insight-6.8.tar.bz2
#==============================================================

#==============================================================
Unpack()
{
	echo -n "Extracting ${1} .."
	rm -rf ${1}
	if test -f ${PACKAGE_DIR}/${1}.tar.*; then
		tar xf ${PACKAGE_DIR}/${1}.tar.* || exit 1 # fixme !
	else
		echo "${1} skipped!"
		exit 1 # fixme
	fi
	echo "OK."
}
#==============================================================

#===================================================================
mkdir -vp ${PACKAGE_DIR} ${BUILD_DIR} ${RESULT_DIR} ${SOURCE_DIR}

cd ${PACKAGE_DIR}
for pkg_url in \
    ${PACKAGE_BINUTILS_URL} \
    ${PACKAGE_KERNEL_URL} \
    ${PACKAGE_GCC_URL} \
    ${PACKAGE_GMP_URL} \
    ${PACKAGE_MPFR_URL} \
    ${PACKAGE_GLIBC_URL} \
    ${PACKAGE_GLIBCPORTS_URL} \
    ${PACKAGE_GDB_URL} \
    ;
do
    pkg_name=`basename ${pkg_url}`
    if [ ! -f ${pkg_name} ]; then
        wget -t 10 -w 5 -P ${PACKAGE_DIR} -c ${pkg_url}
    fi
done

for pkg in \
	${PACKAGE_BINUTILS} \
	${PACKAGE_KERNEL} \
        ${PACKAGE_GCC} \
        ${PACKAGE_GMP} \
        ${PACKAGE_MPFR} \
        ${PACKAGE_GLIBC} \
        ${PACKAGE_GLIBCPORTS} \
        ${PACKAGE_GDB} \
        ${PACKAGE_INSIGHT} \
	; 
do
	cd ${SOURCE_DIR}
	if [ ! -d ${pkg} ]; then
   	        Unpack ${pkg} || exit 1
	fi
done
#==================================================================

#==================================================================
cd ${SOURCE_DIR}
mv ${PACKAGE_GLIBCPORTS} ${PACKAGE_GLIBC}/ports
for pkg in \
	${PACKAGE_BINUTILS} \
	${PACKAGE_KERNEL} \
        ${PACKAGE_GCC} \
        ${PACKAGE_GMP} \
        ${PACKAGE_MPFR} \
        ${PACKAGE_GLIBC} \
        ${PACKAGE_GDB} \
        ${PACKAGE_INSIGHT} \
	; 
do
	cd ${SOURCE_DIR}/${pkg}
	for fpatch in `ls ${PATCH_DIR}/${pkg}* 2>/dev/null`;
	do
		patch -Np1 < ${fpatch}
	done
done
#==================================================================

#=================================================================
echo "Begin Binutils:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
mkdir -pv ${BUILD_DIR}/${PACKAGE_BINUTILS} 
cd ${BUILD_DIR}/${PACKAGE_BINUTILS}
${SOURCE_DIR}/${PACKAGE_BINUTILS}/configure \
        --target=${TARGET} \
        --prefix=${RESULT_DIR} \
        --disable-nls \
        --disable-werror \
        --disable-multilib \
        --enable-shared 
make configure-host
make && make install || exit 1
export PATH=${RESULT_DIR}/bin:${PATH}
#        --build=${HOST} \
#        --host=${HOST} \
#        --enable-poison-system-directories
echo "End Binutils:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
##=================================================================

#=================================================================
cd ${SOURCE_DIR}/${PACKAGE_KERNEL}
make \
        ARCH=arm \
        CROSS_COMPILE=${TARGET}- \
        INSTALL_HDR_PATH=${TARGET_PREFIX} \
        headers_install
#=================================================================

#=================================================================
echo "Begin GCC-1:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
cd ${SOURCE_DIR}
mv ${PACKAGE_GMP} ${PACKAGE_GCC}/gmp 
mv ${PACKAGE_MPFR} ${PACKAGE_GCC}/mpfr 
mkdir -pv ${BUILD_DIR}/${PACKAGE_GCC} 
cd ${BUILD_DIR}/${PACKAGE_GCC}
${SOURCE_DIR}/${PACKAGE_GCC}/configure \
        --build=${HOST} \
        --host=${HOST} \
        --target=${TARGET} \
        --prefix=${RESULT_DIR} \
        --without-headers \
        --with-newlib \
        --with-float=soft \
        --with-cpu=arm920t \
        --with-tune=arm9tdmi \
        --with-gnu-as \
        --with-gnu-ld \
        --disable-nls \
        --disable-decimal-float \
        --disable-libgomp \
        --disable-multilib \
        --disable-libmudflap \
        --disable-libssp \
        --disable-shared \
        --disable-threads \
        --disable-libmudflap \
        --disable-libstdcxx-pch \
        --disable-libffi \
        --enable-languages=c 
make && make install || exit 1
#        --enable-poison-system-directories 
echo "End GCC-1:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
#=================================================================

#=================================================================
echo "Begin Glibc:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
mkdir -pv ${BUILD_DIR}/${PACKAGE_GLIBC} 
cd ${BUILD_DIR}/${PACKAGE_GLIBC}
cat > config.cache << EOF
libc_cv_forced_unwind=yes
libc_cv_c_cleanup=yes
libc_cv_arm_tls=yes
libc_cv_gnu99_inline=yes
EOF
BUILD_CC=gcc \
CC=${TARGET}-gcc \
AR=${TARGET}-ar \
RANLIB=${TARGET}-ranlib \
${SOURCE_DIR}/${PACKAGE_GLIBC}/configure \
        --build=${HOST} \
        --host=${TARGET} \
        --target=${TARGET} \
        --prefix="/usr" \
        --with-headers=${TARGET_PREFIX}/include \
        --with-binutils=${RESULT_DIR}/bin \
        --with-tls \
        --with-__thread \
        --enable-sim \
        --enable-nptl \
        --enable-add-ons \
        --enable-kernel=2.6.29 \
        --disable-profile \
        --without-gd \
        --without-cvs \
        --cache-file=config.cache
make
make install_root=${TARGET_PREFIX} prefix="" install
#--libexecdir=/usr/lib/glibc
# TODO: fix libc.so
rm ${TARGET_PREFIX}/lib/libc.so
cat > ${TARGET_PREFIX}/lib/libc.so << "EOF"
/*  GNU ld script
    Use the shared library, but some functions are only in
    the static library, so try that secondarily.  */
OUTPUT_FORMAT(elf32-littlearm)
GROUP ( libc.so.6 libc_nonshared.a  AS_NEEDED ( ld-linux.so.3 ) )
EOF
echo "End Glibc:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
##=================================================================

##=================================================================
echo "Begin GCC-2:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
mkdir -pv ${BUILD_DIR}/${PACKAGE_GCC}-2 
cd ${BUILD_DIR}/${PACKAGE_GCC}
make clean && make distclean
cd ${BUILD_DIR}/${PACKAGE_GCC}-2
${SOURCE_DIR}/${PACKAGE_GCC}/configure \
        --build=${HOST} \
        --host=${HOST} \
        --target=${TARGET} \
        --prefix=${RESULT_DIR} \
        --with-float=soft \
        --with-cpu=arm920t \
        --with-tune=arm9tdmi \
        --enable-languages=c,c++ \
        --enable-threads=posix \
        --enable-c99 \
        --enable-long-long \
        --enable-shared \
        --enable-__cxa_atexit \
        --enable-nls \
        --disable-libgomp 
make && make install
#        --disable-libgomp 
#        --disable-muitilib \
echo "End GCC-2:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
#=================================================================

#=================================================================
echo "Begin GDB:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
mkdir -pv ${BUILD_DIR}/${PACKAGE_GDB} 
cd ${BUILD_DIR}/${PACKAGE_GDB}
${SOURCE_DIR}/${PACKAGE_GDB}/configure \
        --build=${HOST} \
        --host=${HOST} \
        --target=${TARGET} \
        --disable-werror \
        --enable-sim \
        --prefix=${RESULT_DIR}  
make && make install || exit 1
echo "END GDB:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
#=================================================================

##=================================================================
echo "Begin GDBSERVER:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
sed -i 's/<limits.h>/<linux\/limits.h>/' ${SOURCE_DIR}/${PACKAGE_GDB}/gdb/gdbserver/hostio.c
mkdir -pv ${BUILD_DIR}/${PACKAGE_GDB}/gdbserver 
cd ${BUILD_DIR}/${PACKAGE_GDB}/gdbserver
${SOURCE_DIR}/${PACKAGE_GDB}/gdb/gdbserver/configure \
        --host=${TARGET} \
        --disable-werror \
        --prefix=${TARGET_PREFIX} \
        --with-binutils=${RESULT_DIR}/bin \
        --with-headers=${TARGET_PREFIX}/include 
make CC=${TARGET}-gcc && make install || exit 1
echo "End GDBSERVER:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
        #--build=${HOST} \
        #--target=${TARGET} \
#=================================================================

#=================================================================
echo "Begin INSIGHT:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
mkdir -pv ${BUILD_DIR}/${PACKAGE_INSIGHT} 
cd ${BUILD_DIR}/${PACKAGE_INSIGHT}
${SOURCE_DIR}/${PACKAGE_INSIGHT}/configure \
        --target=${TARGET} \
        --enable-sim \
        --disable-werror \
        --prefix=${RESULT_DIR}  

make && make install || exit 1
echo "End INSIGHT:" $(date +%Y-%m-%d" "%H:%M:%S) >> ${BUILD_DIR}/log.txt 
#=================================================================

echo "============================================================="
echo "=============== All Done. Congratulations! =================="
echo "============================================================="

##=================================================================
#cd ${SOURCE_DIR}/${PACKAGE_KERNEL}
#make \
#        ARCH=arm \
#        CROSS_COMPILE=${TARGET}- \
#        menuconfig
#make \
#        ARCH=arm \
#        CROSS_COMPILE=${TARGET}- \
#        zImage
##=================================================================




