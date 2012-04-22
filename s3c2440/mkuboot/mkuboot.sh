#!/bin/bash
#
# Author: Hongwang <hoakee@gmai.com>
# One Linux fans from University of Sci-Tech of China
# Script to build linux kernel image for embedded ARM board 
# 2009-05-16 first version, 
#

WORKROOT=${PWD}

# ===========================================================================
UBOOT="u-boot-2009.06"
UBOOT_URL="ftp://ftp.denx.de/pub/u-boot/u-boot-2009.06.tar.bz2"

for pkg_url in ${UBOOT_URL}
do
    pkg_name=`basename ${pkg_url}`
    if [ ! -f ${pkg_name} ]; then
        wget --tries=10 --wait=5 --continue ${pkg_url}
    fi
    echo -n "Extracting ${pkg_name} .... "
    tar -xf ${pkg_name} -C ${WORKROOT} 
    echo "Done."
done
# ===========================================================================

# ===========================================================================
cd ${WORKROOT}/${UBOOT}/board/samsung
cp -R smdk2410 Rain2440
sed -i 's/smdk2410.o/Rain2440.o/g' Rain2440/Makefile

cd ${WORKROOT}/${UBOOT}/include/configs
cp smdk2410.h Rain2440.h

cd ${WORKROOT}/${UBOOT}
sed -i 's/smdk2410/Rain2440/g' Makefile
# ===========================================================================

cd ${WORKROOT}/${UBOOT}
sed -i 's/1113/1269/g' board/samsung/Rain2440/lowlevel_init.S
cp -v ${WORKROOT}/files/Rain2440.c board/samsung/Rain2440/
cp -v ${WORKROOT}/files/speed.c cpu/arm920t/s3c24x0/
sed -i '/S3C24X0_REG32.*CLKDIVN/a S3C24X0_REG32   CAMDIVN;' include/s3c24x0.h  

sed -i '/CONFIG_CMD_ELF/ a      \
#define CONFIG_CMD_PING         \
#define CONFIG_CMD_NAND         \
#define CONFIG_SYS_NAND_BASE        \
#define CONFIG_SYS_MAX_NAND_DEVICE 1\
#define NAND_MAX_CHIPS 1        \
#define CMD_SAVEENV             \
#define CONFIG_ENV_OFFSET 0x40000 \
' include/configs/Rain2440.h

sed -i '/CONFIG_BOOTDELAY/,/CONFIG_BOOTCOMMAND/{s/^/\/\//}' include/configs/Rain2440.h
sed -i '/CONFIG_BOOTDELAY/ i \
#define CONFIG_BOOTDELAY        5                       \
#define CONFIG_BOOTARGS         "root=/dev/nfs nfsroot=192.168.1.106:/home/hongwang/nfsroot ip=192.168.1.252:192.168.1.106:192.168.1.1:255.255.255.0:hwlee.net:eth0:off console=ttySAC0,115200 init=/linuxrc mem=65536K console=tty1 fbcon=rotate:0"  \
//#define CONFIG_BOOTARGS         "root=/dev/mtdblock2 console=ttySAC0,115200 init=/linuxrc mem=65536K console=tty1"                                               \
#define CONFIG_ETHADDR          08:00:3e:26:2c:5b       \
#define CONFIG_NETMASK          255.255.255.0           \
#define CONFIG_IPADDR           192.168.1.252           \
#define CONFIG_SERVERIP         192.168.1.106           \
#define CONFIG_SETUP_MEMORY_TAGS                        \
#define CONFIG_CMDLINE_TAG                              \
#define CONFIG_CMDLINE_EDITING  1                       \
#define CONFIG_BOOTCOMMAND	"tftp 0x32000000 uImage; bootm 0x32000000" \
' include/configs/Rain2440.h

sed -i '/CS8900_BUS16/ i \
#define CONFIG_DRIVER_DM9000    1                       \
#define CONFIG_DM9000_BASE      0x20000300              \
#define DM9000_IO               CONFIG_DM9000_BASE      \
#define DM9000_DATA             (CONFIG_DM9000_BASE+4)  \
#define CONFIG_DM9000_USE_16BIT 1                       \
' include/configs/Rain2440.h

sed -i '/CS8900/d' include/configs/Rain2440.h
sed -i 's/SMDK2410\ #\ /Micro2440\ #\ /g' include/configs/Rain2440.h

sed -i '/S3C2410_NAND;/ a \
typedef struct {                        \
        S3C24X0_REG32   NFCONF;         \
        S3C24X0_REG32   NFCONT;         \
        S3C24X0_REG32   NFCMD;          \
        S3C24X0_REG32   NFADDR;         \
        S3C24X0_REG32   NFDATA;         \
        S3C24X0_REG32   NFMECCD0;       \
        S3C24X0_REG32   NFMECCD1;       \
        S3C24X0_REG32   NFSECCD;        \
        S3C24X0_REG32   NFSTAT;         \
        S3C24X0_REG32   NFESTAT0;       \
        S3C24X0_REG32   NFESTAT1;       \
        S3C24X0_REG32   NFMECC0;        \
        S3C24X0_REG32   NFMECC1;        \
        S3C24X0_REG32   NFSECC;         \
        S3C24X0_REG32   NFSBLK;         \
        S3C24X0_REG32   NFEBLK;         \
} \/\*__attribute__((__packed__))\*\/ S3C2440_NAND; \
' include/s3c24x0.h

sed -i '/S3C2410_GetBase_NAND/ i \
static inline S3C2440_NAND * const S3C2440_GetBase_NAND(void)   \
{                                                               \
    return (S3C2440_NAND * const)S3C2410_NAND_BASE;             \
}                                                               \
' include/s3c2410.h

#cp -v ${WORKROOT}/files/nand_flash.c cpu/arm920t/s3c24x0/nand.c
cp -v ${WORKROOT}/files/nand.c cpu/arm920t/s3c24x0/nand.c
sed -i 's/speed.o/speed.o nand.o/g' cpu/arm920t/s3c24x0/Makefile

cp -v ${WORKROOT}/files/start.S cpu/arm920t/start.S
cp -v ${WORKROOT}/files/nand_read.c cpu/arm920t/nand_read.c
sed -i 's/cpu.o/nand_read.o cpu.o/g' cpu/arm920t/Makefile

# ===========================================================================
sed -i 's/weak,//g' lib_arm/board.c
sed -i 's/weak,//g' common/main.c

# ===========================================================================
export BUILD_DIR=${WORKROOT}/build
export MAKEALL_LOGDIR=${WORKROOT}/log
make CROSS_COMPILE=arm-hwlee-linux-gnueabi- distclean
make CROSS_COMPILE=arm-hwlee-linux-gnueabi- Rain2440_config
make CROSS_COMPILE=arm-hwlee-linux-gnueabi- all

#cp -pv ${BUILD_DIR}/u-boot.bin ${WORKROOT}/
#cp -pv ${BUILD_DIR}/tools/mkimage ${WORKROOT}/


