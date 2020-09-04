#!/usr/bin/env python
'''
To Use it, you need generate pinGroup.json, pinGPIO.json(gpio,agpo) and pinNumber.json from gen_cfg.py and gen_gpio.py first.
And, it will show the status of all pins.

Usage:
    python pin_show.py {Platform Name}

Note:
    pinGroup.json, pinGPIO.json and pinNumber need be added on {Platform Name}'s folder.
'''

import json
import sys

# Autoconf = './../Demo/test_AGPO/.config'
Autoconf = './.config'

platformPath = './../../Tools/sanitycheck/pinmux/Platforms/' + sys.argv[1] + '/'

sys.path.append(platformPath)

optionNumber = 0
agpo_cfg = []
agpo_option = 0

# Record pin group, gpio, agpo which was used.
groupEnable = []
gpioEnable = []
agpoEnable = []

# the status table of all pins
pinTable = []

# pin have three status (Not config, ok , Conflict)
flagCheck = ['Not Config', 'OK', 'Conflict']


# load from file:
with open(platformPath + 'setting.json', 'r') as f:
    try:
        data = json.load(f)
        optionNumber = int(data['optionNumber'])
        agpo_cfg = data['agpo_cfg']
        agpo_option = data['agpo_option']
        # if the file is empty the ValueError will be thrown
    except ValueError:
        optionNumber = []
        agpo_cfg = []
        agpo_option = []

with open(platformPath + 'pinGroup.json', 'r') as f:
    try:
        pinGroup = json.load(f)
    # if the file is empty the ValueError will be thrown
    except ValueError:
        pinGroup = {}

with open(platformPath + 'pinNumber.json', 'r') as f:
    try:
        pinNumber = json.load(f)
    # if the file is empty the ValueError will be thrown
    except ValueError:
        pinNumber = {}

with open(platformPath + 'pinGPIO.json', 'r') as f:
    try:
        pinGPIO = json.load(f)
    # if the file is empty the ValueError will be thrown
    except ValueError:
        pinGPIO = {}

# print pinGroup
# print len(pinNumber)

# autoconf
f = open(Autoconf, 'r')
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
                print('### ERROR ### Platform and .config is inconsistent, you can make menuconfig again.')
                raise Exception

        if 'CONFIG_PIN_GROUP_' in line:
            name = line.split('=')[0]
            name = name.replace('CONFIG_PIN_GROUP_', '')
            name = name.lower()

            groupEnable.append(name)

        if 'CONFIG_PIN_GPIO_' in line:
            name = line.split('=')[0]
            name = name.replace('CONFIG_PIN_', '')

            gpioEnable.append(name)

        if 'CONFIG_PIN_AGPO_' in line:
            if 'CONFIG_PIN_AGPO_POS' in line:
                pos = line.split('=')[1]
            else:
                pin = line.split('=')[0]
                pin = pin.replace('CONFIG_PIN_AGPO_', '')

                agpoEnable.append([pos, pin])


# print(groupEnable)
# print gpioEnable
# print agpoEnable

f.close()

# initial pinTable = ['Not Config', 'OFF', 'OFF', 'OFF', 'OFF', 'OFF']
for i in range(len(pinNumber)):
    pinTable.append([flagCheck[0]])

    for j in range(optionNumber):
        pinTable[i].append('OFF')

# print pinTable

# Check pin group and fill pinTable
for i in range(len(groupEnable)):
    for key, value in pinGroup[groupEnable[i]].iteritems():
        number = pinNumber[key]

        pinTable[number][value+1] = groupEnable[i]

        if pinTable[number][0] == flagCheck[0]: # Not Config -> ok
            pinTable[number][0] = flagCheck[1]
            # print pinTable[number]
        elif pinTable[number][0] == flagCheck[1]: # ok -> Conflict
            pinTable[number][0] = flagCheck[2]

# Check pin GPIO and fill pinTable
for i in range(len(gpioEnable)):
    number, bit = gpioEnable[i].split('_')[1:]
    value = int(pinGPIO[gpioEnable[i]])

    pinID = int(int(number) * 32 + int(bit))
    # print number
    # print pinID
    # print pinTable[pinID][value+1]
    pinTable[pinID][value+1] = gpioEnable[i]

    if pinTable[pinID][0] == flagCheck[0]: # Not Config -> ok
        pinTable[pinID][0] = flagCheck[1]
        # print pinTable[pinID]
    elif pinTable[pinID][0] == flagCheck[1]: # ok -> Conflict
        pinTable[pinID][0] = flagCheck[2]

# Check pin AGPO and fill pinTable
for i in range(len(agpoEnable)):
    pos = agpoEnable[i][0]
    pin = agpoEnable[i][1]

    pinID = int(int(agpo_cfg[int(pos)]) + int(pin))
    # print pinID

    pinTable[pinID][agpo_option+1] = 'AGPO_' + pos + '[' + pin + ']'

    if pinTable[pinID][0] == flagCheck[0]: # Not Config -> ok
        pinTable[pinID][0] = flagCheck[1]
        # print pinTable[pinID]
    elif pinTable[pinID][0] == flagCheck[1]: # ok -> Conflict
        pinTable[pinID][0] = flagCheck[2]

# print the status of all pins
print('--  Show the status of all pins  --')
print('Pin(Number): [status, (option 0)(option 1)(option 2)(option 3)(option 4)]')

for i in range(len(pinTable)):
    print('Pin(%3d)' %(i), pinTable[i][:])
