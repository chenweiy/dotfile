#!/usr/bin/env python

import logging

logging.basicConfig(level=logging.INFO)

Autoconf = './test_flash.config'


class FlashLayout:
    ''' Flash layout '''

    def __init__(self):
        self.checkdone_l = []
        self.partition_d = dict()

    def parsing_config(self, config_file=None):

        f = open(config_file, 'r')
        lines = f.readlines()

        for line in lines:
            line = line.strip()

            if '#' not in line:
                if 'CONFIG_FLASH_' in line:
                    flash_name = line.split('=')[0]
                    flash_name = flash_name.replace('CONFIG_FLASH_', '')

                    if(('OFFSET' not in flash_name) and ('SIZE' not in
                                                         flash_name)):
                        flash_value = line.split('=')[1]

                        if 'y' in flash_value:
                            if flash_name not in self.partition_d:
                                self.partition_d[flash_name] = []
                            continue

                    if 'OFFSET' in flash_name:
                        flash_name_tmp = flash_name.replace('_OFFSET', '')
                        if flash_name_tmp in self.partition_d:
                            offset_tmp = line.split('=')[1]
                            self.partition_d[flash_name_tmp].append(
                                int(offset_tmp, 16))

                    if 'SIZE' in flash_name:
                        flash_name_tmp = flash_name.replace('_SIZE', '')
                        if flash_name_tmp in self.partition_d:
                            size_tmp = line.split('=')[1]
                            self.partition_d[flash_name_tmp].append(
                                int(size_tmp, 16))

        f.close()

        logging.debug('flash partition: ' + str(self.partition_d))

    def check_layout(self, layout_d=None):
        if layout_d is None:
            layout_d = self.partition_d

        for key, item in layout_d.items():
            result = 1
            logging.debug('item:' + str(item[0]) + '@ ' + str(item[1]))

            for i in self.checkdone_l:
                logging.debug('i:' + str(i[0]) + '@ ' + str(i[0] + i[1]))

                if((item[0] + item[1] - 1) < i[0]) or (item[0] > (i[0] +
                                                                  i[1] - 1)):
                    result = 1
                else:
                    result = 0
                    logging.error('Flash layout has a conflict, '
                                  'check your setting on menuconfig')
                    raise Exception

            if 1 == result:
                self.checkdone_l.append(item)
                logging.debug('suscess add: ' + str(item))
            # else:
                # logging.debug('conflict1: ' + str(item))
                # logging.debug('conflict2: ' + str(i))

        logging.debug('Result' + str(self.checkdone_l))


if __name__ == '__main__':
    # test = {'a': [1, 4], 'b': [7, 10], 'c': [4, 6], 'd': [5, 7]}

    print('sanitycheck: Check flash layout setting ...')
    flash = FlashLayout()
    flash.parsing_config(Autoconf)
    flash.check_layout()
    print('sanitycheck: Check flash layout setting ... OK')
