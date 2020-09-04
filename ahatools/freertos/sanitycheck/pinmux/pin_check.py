#!/usr/bin/env python
'''
To Use it, you need generate pinGroup.json, pinGPIO.json and pinNumber.json
from gen_cfg.py and gen_gpio.py first. And, it will show the message of
pin conflict.

Usage:
    python pin_check.py {Platform Name}

Note:
    pinGroup.json, pinGPIO.json and pinNumber need be added on
    {Platform Name}'s folder.
'''

import json
import sys

__version__ = "1.0-beta0"

# pin have three status (Not config, OK , Conflict)
flagCheck = ['Not Config', 'OK', 'Conflict']

class PinMux():
    def __init__(self):
        self.optionNumber = 0
        # Record pin group, gpio, agpo which was used.
        self.groupEnable = []
        self.gpioEnable = []
        self.agpoEnable = []
        # the status table of all pins
        self.pinTable = []

        self.pinGroup = dict()
        self.pinNumber = dict()
        self.pinGPIO = dict()
        self.pinAGPO = dict()

    def load_pin_file(self, platformPath):
        # load from file:
        with open(platformPath + 'setting.json', 'r') as f:
            try:
                data = json.load(f)
                self.optionNumber = int(data['optionNumber'])
            # if the file is empty the ValueError will be thrown
            except ValueError:
                self.optionNumber = []

        with open(platformPath + 'pinGroup.json', 'r') as f:
            try:
                self.pinGroup = json.load(f)
            # if the file is empty the ValueError will be thrown
            except ValueError:
                self.pinGroup = {}

        with open(platformPath + 'pinNumber.json', 'r') as f:
            try:
                self.pinNumber = json.load(f)
            # if the file is empty the ValueError will be thrown
            except ValueError:
                self.pinNumber = {}

        with open(platformPath + 'pinGPIO.json', 'r') as f:
            try:
                self.pinGPIO = json.load(f)
            # if the file is empty the ValueError will be thrown
            except ValueError:
                self.pinGPIO = {}
        
        with open(platformPath + 'pinAGPO.json', 'r') as f:
            try:
                self.pinAGPO = json.load(f)
            # if the file is empty the ValueError will be thrown
            except ValueError:
                self.pinAGPO = {}

        # print pinGroup
        # print len(pinNumber)

    def parsing_config(self, config_file):
        f = open(config_file, 'r')
        lines = f.readlines()

        # Record pin group, gpio, agpo which was used.
        # EX:
        #       groupEnable = ['i2c1', 'ssic0', 'sssic_pos_1']
        #       gpioEnable  = ['GPIO_0_0', 'GPIO_1_1', 'GPIO_2_2']
        #       agpoEnable  = [[pos, pin], [0,1], [0,2], [1,6]]
        for line in lines:
            line = line.strip()

            if '#' not in line:
                # check if Platform is correct
                if 'CONFIG_PLATFORM_' in line:
                    name = line.split('=')[0]
                    name = name.replace('CONFIG_PLATFORM_', '')
                    name = name.lower()
                    comp = sys.argv[1].lower()

                    if name != comp:
                        print('### ERROR ### Platform and .config is '
                              'inconsistent, you can make menuconfig again.')
                        raise Exception

                if 'CONFIG_PIN_GROUP_' in line:
                    name = line.split('=')[0]
                    name = name.replace('CONFIG_PIN_GROUP_', '')
                    name = name.lower()

                    self.groupEnable.append(name)

                if 'CONFIG_PIN_GPIO_' in line:
                    if 'ENABLE' in line:
                        continue

                    name = line.split('=')[0]
                    name = name.replace('CONFIG_PIN_', '')

                    self.gpioEnable.append(name)

                if 'CONFIG_PIN_AGPO_' in line:
                    if 'CONFIG_PIN_AGPO_POS' in line:
                        pos = line.split('=')[1]
                    else:
                        pin = line.split('=')[0]
                        pin = pin.replace('CONFIG_PIN_AGPO_', '')

                        self.agpoEnable.append([pos, pin])

        # print(groupEnable)
        # print(gpioEnable)
        # print(agpoEnable)
        f.close()

    def fill_pintable(self):
        # initial pinTable = ['Not Config', 'OFF', 'OFF', 'OFF', 'OFF', 'OFF']
        for i in range(len(self.pinNumber)):
            self.pinTable.append([flagCheck[0]])

            for j in range(self.optionNumber):
                self.pinTable[i].append('OFF')

        # printr(self.pinTable)

        # Check pin group and fill pinTable
        for i in range(len(self.groupEnable)):
            for key, value in self.pinGroup[self.groupEnable[i]].iteritems():
                number = self.pinNumber[key]

                # check if pin option can use together
                if 'OFF' not in self.pinTable[number][value+1]:
                    continue

                self.pinTable[number][value+1] = self.groupEnable[i]

                if self.pinTable[number][0] == flagCheck[0]:
                    # Not Config -> ok
                    self.pinTable[number][0] = flagCheck[1]
                    # print pinTable[number]
                elif self.pinTable[number][0] == flagCheck[1]:
                    # ok -> Conflict
                    self.pinTable[number][0] = flagCheck[2]
                    # print pinTable[number]

        # Check pin GPIO and fill pinTable
        for i in range(len(self.gpioEnable)):
            number, bit = self.gpioEnable[i].split('_')[1:]
            value = int(self.pinGPIO[self.gpioEnable[i]])

            pinID = int(int(number) * 32 + int(bit))
            # print number
            # print pinID
            # print pinTable[pinID][value+1]
            self.pinTable[pinID][value+1] = self.gpioEnable[i]

            if self.pinTable[pinID][0] == flagCheck[0]:
                # Not Config -> ok
                self.pinTable[pinID][0] = flagCheck[1]
                # print pinTable[pinID]
            elif self.pinTable[pinID][0] == flagCheck[1]:
                # ok -> Conflict
                self.pinTable[pinID][0] = flagCheck[2]

        # Check pin AGPO and fill pinTable
        for i in range(len(self.agpoEnable)):
            pos = self.agpoEnable[i][0]
            pin = self.agpoEnable[i][1]
            
            pinID = int(self.pinAGPO[pos]['pin'][int(pin)])
            agpo_option = int(self.pinAGPO[str(pos)]['option'])
            # print(pinID)
            # print(agpo_option)

            self.pinTable[pinID][
                agpo_option + 1] = 'AGPO_' + pos + '[' + pin + ']'

            if self.pinTable[pinID][0] == flagCheck[0]:
                # Not Config -> ok
                self.pinTable[pinID][0] = flagCheck[1]
                # print pinTable[pinID]
            elif self.pinTable[pinID][0] == flagCheck[1]:
                # ok -> Conflict
                self.pinTable[pinID][0] = flagCheck[2]

    def check_config(self):
        # print the mesage of pin conflict
        check = 0
        for i in range(len(self.pinTable)):
            # check if conflict
            if self.pinTable[i][0] == flagCheck[2]:
                print('### Error ###  Pin Conflict: pin number(%d): ' % i)
                print(self.pinTable[i][1:])

                check = check + 1

        if check > 0:
            print('### Error### [make pinshow] can show the status of all pins')
            raise Exception


if __name__ == '__main__':
    Autoconf = './test_pin.config'
    platformPath = './Platforms/' + sys.argv[1] + '/'

    print('pin_check.py v%s - VATICS-RTOS Pinmux Check Tool' % __version__)
    print('Check Pin Setting ...')
    pinmux = PinMux()
    pinmux.load_pin_file(platformPath)
    pinmux.parsing_config(Autoconf)
    pinmux.fill_pintable()
    pinmux.check_config()
    print('Check Pin Setting ... OK')
