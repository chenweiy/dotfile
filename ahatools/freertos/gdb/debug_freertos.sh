#!/bin/bash

#### Usage Check ######
if [ $# -lt 1 ]; then
    echo "Usage: $0 [APP]"
    exit 1
fi

if [ ! -f $PWD/gdb.conf ]; then
	echo -e "\nStart GDB Failed!!!! \n"
	echo "Please create gdb.conf file as the follwing content"
	echo ""
	echo "  SERVERIP=\"localhost:2331\""
	echo ""
	exit 1
fi

source $PWD/gdb.conf

if [ ! -n "$SERVERIP" ]; then
	echo -e "\n Start GDB Failed!!!! \n"
	echo ""
	echo "  Can't find SERVERIP in gdb.conf"
	echo ""
	exit 1
fi
#### User Setup ########


SCRIPT_BASE=$PWD/Tools/gdb/scripts
# Chance's PC
#SERVERIP="192.168.17.125:2331"
#SERVERIP="172.23.4.41:2331"
#SERVERIP="localhost:2331"
#SERVERIP="172.23.4.43:2331"
#SERVERIP="172.23.6.201:2331"

if [[ -z "${APP_PATH}" ]];then
	APP_PATH=./Demo
fi

#### Internal Variables ########
APPNAME=$1
FREERTOS_PATH=$PWD


#### Read APP Config ########
source $FREERTOS_PATH/$APP_PATH/$APPNAME/include/generated/auto.conf

#### Platform Judgement ########
if [ "$CONFIG_PLATFORM_VIENNA" == "y" ]; then
    PLATFORM=Vienna
    PLAT=1
fi

if [ "$CONFIG_PLATFORM_PESARO" == "y" ]; then
    PLATFORM=Pesaro
    PLAT=0
fi

echo "APP_PATH=$APP_PATH/$APPNAME" 
echo "RTOS Root=$FREERTOS_PATH"
echo "Platform=$PLATFORM"

#### Generate APP base gdb file.########
export APPGDB=$APPNAME.gdb


ELF=$FREERTOS_PATH/_build/$PLATFORM/$APP_PATH/$APPNAME/$APPNAME.elf
echo "set \$APP=\"$APPNAME\"" > app.gdb
echo "set \$APP_GDB=\"$APPGDB\"" >> app.gdb
echo "set \$APP_ELF=\"$ELF\"" >> app.gdb
echo "set \$PLATFORM=$PLAT" >> app.gdb
echo "set \$TEXT_ADDR=$CONFIG_TEXT_ADDRESS" >> app.gdb 
if [ -f "$APP" ]; then
    echo "include $APPGDB" >> app.gdb
fi

echo "file $ELF" > load_app.gdb
echo "target remote $SERVERIP" > connect.gdb

#ssh livanwu@172.23.4.43 "~/reset_target.sh reset"
#echo "Sleep 2"
#sleep 2
arm-none-eabi-gdb -d $SCRIPT_BASE -x main.gdb -tui
