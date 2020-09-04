#!/usr/bin/env python
import sys
import pinmux.pin_check as pincheck
import flashcheck

__version__ = "1.0"

Autoconf = './.config'

platformPath = sys.argv[2] + 'Tools/sanitycheck/pinmux/Platforms/' + sys.argv[1] + '/'

# print platformPath
sys.path.append(platformPath)

def main():
    print('sanitycheck.py v%s - VATICS-RTOS SanityCheck Tool' % __version__)

    print('sanitycheck: Check Pin setting ...')
    pinmux = pincheck.PinMux()
    pinmux.load_pin_file(platformPath)
    pinmux.parsing_config(Autoconf)
    pinmux.fill_pintable()
    pinmux.check_config()
    print('sanitycheck: Check Pin setting ... OK')

    print('sanitycheck: Check Flash Layout setting ...')
    flash = flashcheck.FlashLayout()
    flash.parsing_config(Autoconf)
    flash.check_layout()
    print('sanitycheck: Check Flash Layout setting ... OK')


if __name__ == '__main__':
    main()
