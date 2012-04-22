#!/bin/bash

#wget --tries=10 --wait=5 http://mirrors.163.com/sources.list.karmic 
#sudo mv sources.list.karmic /etc/apt/sources.list

sudo apt-get install xinetd
sudo apt-get install pure-ftpd openssh-server subversion
sudo apt-get install build-essential
sudo apt-get install libncurses5-dev autoconf automake libtool
sudo apt-get install bison flex m4
sudo apt-get install vim-gnome cscope ctags
sudo apt-get install rar unrar
unrar x vim.rar

mkdir /home/hongwang/tftproot
mkdir /home/hongwang/nfsroot

sudo cat >> /etc/xinetd.d/tftp  <<EOF
service tftp
{
    protocol        = udp
    port            = 69
    socket_type     = dgram
    wait            = yes
    user            = nobody
    server          = /usr/sbin/in.tftpd
    server_args     = /home/hongwang/tftproot
    disable         = no
}
EOF

sudo apt-get install tftpd-hpa
/etc/init.d/tftpd-hpa restart


sudo apt-get install nfs-kernel-server
sudo cat > exports << "EOF"
/home/hongwang/nfsroot *(rw,sync,no_subtree_check)
EOF
sudo mv exports /etc/
sudo /etc/init.d/nfs-kernel-server restart


sudo apt-get install ckermit
cat > .mykermrc << "EOF"
set line /dev/ttyUSB0
set speed 115200
set carrier-watch off
set handshake none
set flow-control none
robust
set file type bin
set file name lit
set rec pack 1000
set send pack 1000
set window 5
EOF

sudo apt-get update
sudo apt-get upgrade

