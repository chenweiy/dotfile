#!/bin/sh

#python /home/chance/workspace/vatics/bsp/utilities/pinstool/pin_check.py ./arch/arm/boot/dts/m5s.dts

usage()
{
	echo "-n  debugging information"
	echo "-v  verbose information"
	echo "-s  silent information"
    echo "-p  pesaro platform"
}

#EXTRA_CFLAGS="EXTRA_CFLAGS=\"-g -D__FPGA__\""
EXTRA_CFLAGS="EXTRA_CFLAGS=-g"
#[ $# -eq 0 ] && VERBOSE="> /dev/null" || VERBOSE=
PLATFORM="Vienna"

while getopts 'nvsph' option
do
	case $option in
		n)
            EXTRA_CFLAGS=
			;;
		v)
			VERBOSE=
			;;
		s)
			VERBOSE="> /dev/null"
			;;
        p)
            PLATFORM="Pesaro"
            ;;
		h|?)
			usage
			exit 2
			;;
	esac
done
shift `expr $OPTIND - 1`


if [ $# -eq 0 ]; then

if [ ${PLATFORM} = Pesaro ];then
    echo "Platform is ${PLATFORM}"

    BUILD_CMD="make -j$(cat /proc/cpuinfo|grep processor|wc -l) ${EXTRA_CFLAGS} ${VERBOSE}"
    BUILD_CMD=$BUILD_CMD" && "
    BUILD_CMD=$BUILD_CMD"  cat arch/arm/boot/zImage  arch/arm/boot/dts/m3c_evb.dtb > m3c_zImage.dtb"
    BUILD_CMD=$BUILD_CMD" && "
    BUILD_CMD=$BUILD_CMD" scp m3c_zImage.dtb chance.yang@172.17.0.6:/tftpboot/chance"
else
    echo "Platform is Vienna"

    BUILD_CMD="make -j$(cat /proc/cpuinfo|grep processor|wc -l) ${EXTRA_CFLAGS} ${VERBOSE}"
    BUILD_CMD=$BUILD_CMD" && "
    BUILD_CMD=$BUILD_CMD"  cat arch/arm/boot/zImage  arch/arm/boot/dts/m5s.dtb > m5s_zImage.dtb"
    BUILD_CMD=$BUILD_CMD" && "
    BUILD_CMD=$BUILD_CMD" scp m5s_zImage.dtb chance.yang@172.17.0.6:/tftpboot/chance"
fi
# BUILD_CMD=$BUILD_CMD" && "
# BUILD_CMD=$BUILD_CMD"  cp arch/arm/boot/zImage /srv/tftp/Schubert/zImage-4.9 "
# BUILD_CMD=$BUILD_CMD" && "
# BUILD_CMD=$BUILD_CMD"  cp arch/arm/boot/dts/m5s.dtb  /srv/tftp/Schubert/"
# BUILD_CMD=$BUILD_CMD" && "
# BUILD_CMD=$BUILD_CMD"  cp arch/arm/boot/dts/m5s-shark-parallel.dtb  /srv/tftp/Schubert/"

#BUILD_CMD=$BUILD_CMD"  cat arch/arm/boot/zImage  arch/arm/boot/dts/m5s.dtb > /srv/tftp/Schubert/zImage-4.9+dtb-m5s"
#BUILD_CMD=$BUILD_CMD" && "
#BUILD_CMD=$BUILD_CMD" cat arch/arm/boot/zImage  arch/arm/boot/dts/m5s-rdk-lvds-mipi-v1.dtb > /srv/tftp/Schubert/zImage-4.9+dtb-m5s-rdk-lvds-mipi-v1"
#BUILD_CMD=$BUILD_CMD" && "
#BUILD_CMD=$BUILD_CMD" cat arch/arm/boot/zImage  arch/arm/boot/dts/m5s-rdk-parallel-v1.dtb > /srv/tftp/Schubert/zImage-4.9+dtb-m5s-rdk-parallel-v1"

else
BUILD_CMD="make -j$(cat /proc/cpuinfo|grep processor|wc -l) ${EXTRA_CFLAGS} $* ${VERBOSE}"
fi


### DO NOT USE THIS ONE. System will almost hang.
#BUILD_CMD="make -j ${EXTRA_CFLAGS} > /dev/null &&  cat arch/arm/boot/zImage  arch/arm/boot/dts/m3c_evb.dtb > /srv/tftp/Rossini/kernel.m3c_evb"

echo $BUILD_CMD
sh -c "$BUILD_CMD"
