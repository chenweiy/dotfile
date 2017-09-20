#!/usr/bin/env python

import sys
import string
import commands
import subprocess
from time import sleep

true = True
false = False

gdbserver = 'JLinkGDBServer'
windows = '0:0'
target = 'ARM9'
# target = 'Cortex-A5'


def main(argv):
    argc = len(argv)

    # if argc != 2:
        # print ('[*] gdb_server.py by Chance.Yang')
        # print ('[*] usage: %s <process name>' % (argv[0]))
        # sys.exit(1)

    # prog = argv[1]
    
    while true:
        pstr = commands.getoutput('ps -A | grep %s' % (gdbserver))

        if pstr == '':
            print('[+] NO process: %s' % (gdbserver))
            break
        else:
            pid = string.split(pstr)[0]
            # print(pid)
        
            if pid == '':
                print ('[!] error finding the PID of process %s' % (gdbserver))
                sys.exit(1)

            commands.getoutput('kill -9 %s' % pid)
            break
    
    print('[+] restart target ...')
    sleep(3)

    print('[+] start: %s' % (gdbserver))
    subprocess.Popen(['tmux', 'send-keys', '-t', windows, './JLinkGDBServer -select USB -device ', 
        target, ' -if JTAG -speed 12000 -ir', 'Enter'])

    # sleep(1)
    # commands.getoutput('arm-none-eabi-gdb -tui %s -x gdbinitial.gdb' % (prog))
    # gdb_prog = subprocess.Popen(['arm-none-eabi-gdb', '-tui', prog, '-x',
        # 'gdbinitial.gdb'])
    # gdb_prog.wait()

if __name__ == '__main__':
    main(sys.argv)
    sys.exit(0)

# EOF
