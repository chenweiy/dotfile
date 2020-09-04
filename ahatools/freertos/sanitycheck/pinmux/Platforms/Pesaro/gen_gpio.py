
import json

pinGPIO = {}

for i in range(3):
    for j in range(32):
        if i == 0 and j < 16:
            pinGPIO['GPIO_' + str(i) + '_' + str(j)] = 0
        else:
            pinGPIO['GPIO_' + str(i) + '_' + str(j)] = 3


f = open('./pinGPIO.json', 'w')
f.write(json.dumps(pinGPIO, indent = 4, sort_keys = True))
f.close()

