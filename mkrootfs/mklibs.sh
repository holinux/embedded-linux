#!/bin/bash

PACKAGE_PATH="/home/hongwang/Package"
SOURCES_PATH="/home/hongwang/sources"
PREFIX_PATH="/usr/local/arm/4.4.0/arm-hwlee-linux-gnueabi"
TARGET_HOST="arm-hwlee-linux-gnueabi"
SCRIPTS_LIST="libs.list"

#mkdir -pv ${ROOTFS_PATH}
#cp template/* ${ROOTFS_PATH}/ -Rf
#if [ $? -ne 0 ]; then exit 1; fi
#sudo mknod ${ROOTFS_PATH}/dev/console c 5 1
#sudo mknod ${ROOTFS_PATH}/dev/null c 1 3

cd library
cat ${SCRIPTS_LIST} | while read EACHLINE
do
    EACHLINE=$(echo ${EACHLINE} | sed -e '/ *\#/d') 
    if [ ${EACHLINE}XX != XX ]; then
        echo "Calling ${EACHLINE} ..."
        source ${EACHLINE}
    fi
done



