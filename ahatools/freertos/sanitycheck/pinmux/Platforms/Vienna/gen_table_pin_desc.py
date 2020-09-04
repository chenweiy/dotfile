#!/usr/bin/env python

import os
import sys
import json

# load from file:
with open('./pinGroup.json', 'r') as f:
    try:
        pinGroup = json.load(f)
    # if the file is empty the ValueError will be thrown
    except ValueError:
        pinGroup = {}

with open('./pinNumber.json', 'r') as f:
    try:
        pinNumber = json.load(f)
    # if the file is empty the ValueError will be thrown
    except ValueError:
        pinNumber = {}

with open('./pinGPIO.json', 'r') as f:
    try:
        pinGPIO = json.load(f)
    # if the file is empty the ValueError will be thrown
    except ValueError:
        pinGPIO = {}

pinTable = []

# initial
pinNumber_init = sorted(pinNumber.items(), key=lambda items: items[1])
# print pinNumber

pinTable_item= [["N/A"],["N/A"],["N/A"],["N/A"],["N/A"],["N/A"]]

# print pinTable_item

for i in range(len(pinNumber_init)):
    pinTable.append(pinNumber_init[i][0])
    pinTable.append(pinTable_item)

# print pinNumber[0][0]
# print pinTable

# for i in range(len(pinGroup)):
# for key, value in pinGroup.iteritems():
    

    # for pin, number in value.iteritems(): 
        # index = pinNumber[pin]
        # print index
        # pinTable[index][int(number)+1] = key

# print pinTable[0][1]


        # print pin


f = open( './table_pin_desc.h', 'w')

f.write('// All Pins Description Table \n')
f.write('static PIN_DESC table_pin_desc[] = { \n')

for i in range(len(pinNumber_init)):
    f.write('    {' + str(pinNumber_init[i][0]) + ', {{"N/A"}, {"N/A"}, {"N/A"}, {"N/A"}, {"N/A"}, {"N/A"}}' + '}, \n')

f.write('};\n')
# print (pinTable[0])

f.close()



