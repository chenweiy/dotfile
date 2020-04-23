#!/bin/sh

export PROJECT=vienna
export TOOLSDIR=/opt/Vatics/vienna_49/buildroot-2017.02.x/output/host/usr/bin

export CROSS_COMPILE=arm-linux-

export TARGET=arm-linux
export PATH=${TOOLSDIR}:${PREFIX}/bin:/usr/local/bin:${PATH}
#export KERNELINC=/opt/Vatics/vienna_49/linux-4.9-pm/include
#export KERNELSRC=/opt/Vatics/vienna_49/build.linux-4.9-pm
#export KERNELSRC=//home/chance/workspace/vatics/bsp/linux/kernel/linux-4.9/
export KERNELSRC=//home/vtx/workspace/vatics/bsp/linux/kernel/stable
export KERNELINC=${KERNELSRC}/include
export ARCH=arm

#Intentionally empty to avoid plus sign in Kernel version
#export LOCALVERSION=

# Platfrom definition
export PLATFORMNAME=vienna
