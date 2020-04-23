#!/bin/sh

export PROJECT=vienna_49/vienna
#export TOOLSDIR=/opt/vtcs_toolchain/${PROJECT}/output/host/usr/bin
export TOOLSDIR=/opt/Vatics/vienna_49/buildroot-2017.02.x/output/host/usr/bin

export CROSS_COMPILE=arm-linux-

export TARGET=arm-linux
export PATH=${TOOLSDIR}:${PREFIX}/bin:/usr/local/bin:${PATH}
export KERNELSRC=//home/vtx/workspace/vatics/bsp/linux/kernel/stable
export KERNELINC=${KERNELSRC}/include
export ARCH=arm

#Intentionally empty to avoid plus sign in Kernel version
export LOCALVERSION

# Platfrom definition
export PLATFORMNAME=vienna


