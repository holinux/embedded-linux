#!/bin/bash
#
# Author: Hongwang <hoakee@gmai.com>
# One Linux fans from University of Sci-Tech of China
# Script to make rootfs images for embedded ARM-Linux board 
# 2009-05- first version, without mdev support
#

#ROOTFS=/home/hongwang/nfsroot
ROOTFS=${PWD}/rootfs
PACKAGE=${PWD}/package
SOURCES=${PWD}/sources
rm -Rf ${ROOTFS} ${SOURCES}
mkdir -pv ${ROOTFS} ${PACKAGE} ${SOURCES}

#===========================================================================
echo -n "===== Step 1: Create standard directories .... "
#===========================================================================
mkdir -pv ${ROOTFS}/{bin,boot,dev,etc,opt,home,lib,mnt}
mkdir -pv ${ROOTFS}/{proc,media/{floppy,cdrom},sbin,srv,sys}
mkdir -pv ${ROOTFS}/etc/init.d
mkdir -pv ${ROOTFS}/var/{lock,log,mail,run,spool}
mkdir -pv ${ROOTFS}/var/{opt,cache,lib/{misc,locate},local}
install -dv -m 0750 ${ROOTFS}/root
install -dv -m 1777 ${ROOTFS}{/var,}/tmp
mkdir -pv ${ROOTFS}/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv ${ROOTFS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${ROOTFS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${ROOTFS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
for dir in ${ROOTFS}/usr{,/local}; do
      ln -sfnv share/{man,doc,info} ${dir}
done
#===========================================================================
echo "Done."
#===========================================================================

#===========================================================================
echo -n "===== Step 2: Creating /etc/inittab .... "
#===========================================================================
cat > ${ROOTFS}/etc/inittab<< "EOF"
# /etc/inittab
::sysinit:/etc/init.d/rcS
#ttySAC0::askfirst:-/bin/sh
s3c2410_serial0::askfirst:-/bin/sh
tty1::askfirst:-/bin/sh
tty2::askfirst:-/bin/sh
tty3::askfirst:-/bin/sh
tty4::askfirst:-/bin/sh
tty5::askfirst:-/bin/sh
tty6::askfirst:-/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
# Put a getty on the serial line (for a terminal)
# uncomment this line if your using a serial console
#::respawn:/sbin/getty -L ttyS0 115200 vt100
EOF
#===========================================================================
echo "Done."
#===========================================================================

#===========================================================================
echo -n "===== Step 3: Creating /etc/init.d/rcS .... "
#===========================================================================
cat > ${ROOTFS}/etc/init.d/rcS << "EOF"
#!/bin/sh
ifconfig eth0 192.168.1.252 netmask 255.255.255.0
route add default gw 192.168.1.1
mount -a
mkdir /dev/pts
mount -t devpts devpts /dev/pts
echo /sbin/mdev > /proc/sys/kernel/hotplug
#sysctl -w kernel.hotplug=/sbin/mdev
mdev -s
EOF
chmod +x ${ROOTFS}/etc/init.d/rcS
#===========================================================================
echo "Done."
#===========================================================================

#===========================================================================
echo -n "===== Step 4: Creating /etc/fstab .... "
#===========================================================================
cat > ${ROOTFS}/etc/fstab << "EOF"
# Begin /etc/fstab
# file system  mount-point  type   options        dump  fsck order
proc            /proc       proc   defaults         0     0
tmpfs           /tmp        tmpfs  defaults         0     0
sysfs           /sys        sysfs  defaults         0     0
tmpfs           /dev        tmpfs  defaults         0     0 
#devpts         /dev/pts    devpts gid=4,mode=620   0     0
# End /etc/fstab
EOF
#===========================================================================
echo "Done."
#===========================================================================

#===========================================================================
echo -n "===== Step 5: Creating /etc/profile .... "
#===========================================================================
cat > ${ROOTFS}/etc/profile << "EOF"
# /etc/profile

# Set the initial path
export PATH=/bin:/usr/bin
if [ `id -u` -eq 0 ] ; then
    PATH=/bin:/sbin:/usr/bin:/usr/sbin
    unset HISTFILE
fi

# Setup some environment variables.
export USER=`id -un`
export LOGNAME=$USER
export HOSTNAME=`/bin/hostname`
export HISTSIZE=1000
export HISTFILESIZE=1000
export PAGER='/bin/more '
export EDITOR='/bin/vi'

# End /etc/profile
EOF
#===========================================================================
echo "Done."
#===========================================================================

#===========================================================================
echo -n "===== Step 6: Creating /etc/resolv.conf .... "
#===========================================================================
cat > ${ROOTFS}/etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf
domain arm-hwlee-linux.net
nameserver 202.38.64.1
nameserver 202.38.64.7
# End /etc/resolv.conf
EOF
#===========================================================================
echo "Done."
#===========================================================================

#===========================================================================
echo -n "===== Step 7: Create device node in /dev .... "
#===========================================================================
cd ${ROOTFS}/dev
sudo mknod console c 5 1
sudo mknod null c 1 3
#sudo mknod ttySAC0 c 204 64
#sudo mknod mtdblock0 b 31 0
#sudo mknod mtdblock1 b 31 1
#sudo mknod mtdblock2 b 31 2
#===========================================================================
echo "Done."
#===========================================================================

#echo "arm-hwlee-linux" > ${ROOTFS}/etc/HOSTNAME
#
#cat > ${ROOTFS}/etc/hosts << "EOF"
## Begin /etc/hosts (network card version)
#
#127.0.0.1 localhost
#[192.168.1.1] [<HOSTNAME>.example.org] [HOSTNAME]
#
## End /etc/hosts (network card version)
#EOF
#
#cat > ${ROOTFS}/etc/passwd << "EOF"
#root::0:0:root:/root:/bin/bash
#daemon:x:2:2:daemon:/sbin:/bin/false
#nobody:x:65534:65534:nobody:/:/bin/false
#EOF
#
#cat > ${ROOTFS}/etc/group << "EOF"
#root:x:0:
#bin:x:1:
#sys:x:2:
#kmem:x:3:
#tty:x:4:
#tape:x:5:
#daemon:x:6:
#floppy:x:7:
#disk:x:8:
#lp:x:9:
#dialout:x:10:
#audio:x:11:
#video:x:12:
#utmp:x:13:
#usb:x:14:
#cdrom:x:15:
#uucp:x:32:
#nobody:x:65534:
#EOF

#=====================================================================
echo "====================================================================="
echo "========= Step 2: Compile and Install Busybox ======================="
echo "====================================================================="
BUSYBOX="busybox-1.17.1"
BUSYBOX_URL="http://busybox.net/downloads/busybox-1.17.1.tar.bz2"

cd ${PACKAGE}
for pkg_url in ${BUSYBOX_URL}
do
    pkg_name=`basename ${pkg_url}`
    if [ ! -f ${pkg_name} ]; then
        wget --tries=10 --wait=5 --continue ${pkg_url}
    fi
    echo -n "Extracting ${pkg_name} .... "
    tar -xf ${pkg_name} -C ${SOURCES}
    echo "Done."
done

cd ${SOURCES}/${BUSYBOX}
sed -i 's/\(text.*=.*PS1=.*\)w /\1w/' shell/ash.c
sed -i 's/\(text.*=.*PS1=\)/\1Hwlee:/' shell/ash.c
#make defconfig
#echo CONFIG_STATIC=y >> .config
#echo CONFIG_FEATURE_EDITING_FANCY_PROMPT=y >> .config
make ARCH=arm CROSS_COMPILE=arm-hwlee-linux-gnueabi- menuconfig
make ARCH=arm CROSS_COMPILE=arm-hwlee-linux-gnueabi-
make ARCH=arm CROSS_COMPILE=arm-hwlee-linux-gnueabi- CONFIG_PREFIX=${ROOTFS} install

#source ../../mksoftware.sh

echo "============================================================="
echo "=============== All Done. Congratulations! =================="
echo "============================================================="



