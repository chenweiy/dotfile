#!/usr/bin/env python
#
# A thin Python wrapper around addr2line, convert any suitable looking hex numbers
# found in the output into function and line numbers.
#
#

import argparse
# import re
import os
import os.path
import subprocess
import sys

def main():
    parser = argparse.ArgumentParser(description='VATICS-RTOS output filter tool', prog='filteroutput')
    parser.add_argument(
        '--elf', '-e',
        help="ELF file (*.elf file) to load symbols"),
    parser.add_argument(
        '--addr', '-a', nargs='+',
        help="enter address what you want to convert them to line numbers"),
    parser.add_argument(
        '--file', '-f',
        help="console output to analyse core dump"),

    args = parser.parse_args()

    if args.elf is None:
        print("Please specify one with the --elf option.\n")
        sys.exit(1)
    elif not os.path.exists(args.elf):
        print("ELF file '%s' not found \n" % args.elf)
        print("Please specify one with the --elf option.\n")
        sys.exit(1)

    # calculte length of argv
    # length = len(sys.argv)
    # print("%d" % length)

    # print(len(args.addr))

    if args.file is not None:
        f = open(args.file, 'r')
        lines = f.readlines()
        hit = 0

        for line in lines:
            line = line.strip()

            if hit == 1:
                if line == '':
                    break
                if 'HALT' in line:
                    break

                if not line.startswith("0x"):
                    line = "0x"+line
                
                # print(line)

                addr2line = subprocess.check_output(["arm-none-eabi-addr2line","-pfia","-e","%s" % args.elf, line], cwd=".").strip()
                if not addr2line.endswith(": ?? ??:0"):
                    print(" %s\n"  %(addr2line.strip()))
                

            if 'Stack Trace Dump' in line:
                hit = 1

    if args.addr is not None:
        for i,addr in enumerate(args.addr):
            # print i, addr
            if not addr.startswith("0x"):
                addr = "0x"+addr

            addr2line = subprocess.check_output(["arm-none-eabi-addr2line","-pfia","-e","%s" % args.elf, addr], cwd=".").strip()
            # if not addr2line.endswith(": ?? ??:0"):
            print(" %s\n"  %(addr2line.strip()))

if __name__ == "__main__":
    main()
