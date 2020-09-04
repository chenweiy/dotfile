#!/usr/bin/env python
'''
To use it, you need create a header file(ex: rossini_cfg.h) first.
And, it will generate 2 JSON file, including 'pinGroup.json' and 'pinNumber.json'.


pinGroup.json:
    * Format: 
        {
            "pin Group": {
                "pin A": option number
                "pin B": option number
            }
        }
    * Option number is the integer that the option position of pin for this pin group.        
      And,it need fill manually after generate file.

pinNumber.json:
    * Format:
        {
            "pin": pin number
            "pin A": 0,
            "pin B": 1,
            ...
            "VIC_REF_CLK": 100
        }

Note:
    * The header file need have two kinds of data, like
        1. define the number of GPIO pin
            EX: 
                #define PIN                        _GPIO(number)
                ...
                #define SSIC_I_RXD                 _GPIO(16)
                #define SSIC_O_BCLK                _GPIO(17)
        2. declare the structure of pin group
            EX:
                static const unsigned int {pin group}_pins[] = {
                        pin A,
                        pin B,
                };
                
                static const unsigned int i2c0_pos_0_pins[] = {
                        I2CC_0_IO_SCL,
                        I2CC_0_IO_SDA,
                };

    
    * Option number need fill manually in pinGroup after generate file.

Usage:
    python gen_cfg.py 
    
'''
import json
import os.path
import sys

def RepresentsInt(s):
    try: 
        int(s)
        return True
    except ValueError:
        return False

filePath = './vienna_cfg.h'

if not os.path.isfile(filePath):
    print 'You need creat a file which name is ' + filePath + ' \n'
    sys.exit(0)

if os.path.isfile("./pinGroup.json"):
    print 'pinGroup.json already exist.'
    print 'If you want to generate a new pinGroup.json, you need delete pinGroup.json file first.\n'
    sys.exit(0)


group_cfg = {}
pinNumber = {}

f = open( filePath, 'r')

lines = f.readlines()

# generate pinNumber
for line in lines:
    line = line.strip()

    if '#define' in line:
        define, name, value = line.split(' ', 2)
        
        if '_GPIO' in value:
            value = value.strip()
            value = value.replace('_GPIO(', '')
            value = value.replace(')', '')
            value = int(value)
            # print(value)
        elif RepresentsInt(value):
            value = int(value)
        else:
            print '#define {pin} has a error'
            
        
        name = name.strip()
        # print name
        pinNumber[name] = value

# print pinNumber

# generate pinGroup
for i in range(0, len(lines)):
    line = lines[i]
    line = line.strip()

    if 'static const unsigned' in line:
        name = line.split()[4]
        
        name = name.replace('_pins[]', '')
        name = name.strip();
        # print name
        group_cfg[name] = {}       
        while '}' not in line:
            i = i + 1
            
            line = lines[i]
            line = line.strip()
            
            if not line:
                continue
            
            if '}' in line:
                break
            
            line = line.split(',')[0]
            
            group_cfg[name][line] = 0 
            # print line 
            
            
# print group_cfg
f.close() 

f = open('./pinNumber.json', 'w')
f.write(json.dumps(pinNumber, indent = 4, sort_keys = True))
f.close()

f = open('./pinGroup.json', 'w')
f.write(json.dumps(group_cfg, indent = 4, sort_keys = True))
f.close()

