#!/bin/sh

export PROJECT=pesaro
##### Linux Kbuild #####
export ARCH=arm
export CPU=arm
export CROSS_COMPILE=arm-linux-

##### VATICS Stuff #####
export TOOLSDIR=/opt/Vatics/pesaro/build.buildroot-2018.02.y/arm-eabi-uclibc/usr/bin
export TARGET=arm-linux
export PATH=${TOOLSDIR}:${PREFIX}/bin:/usr/local/bin:${PATH}
export KERNELSRC=//home/vtx/workspace/vatics/bsp/linux/kernel/stable
export KERNELINC=${KERNELSRC}/include

#Intentionally empty to avoid plus sign in Kernel version
export LOCALVERSION=

# Platfrom definition
export PLATFORMNAME=pesaro
export PRODUCTNAME=pesaro

