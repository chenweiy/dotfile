#
# MACRO List
# - cpurest
# - mmrlist 
# - mmrread ADDR
# - mmrwrite ADDR VALUE 
#

echo "\n>>> Pesaro.GDB <<<\n\n"
set $mmr_intc = 0x86000000

set $mmr_vic  = 0x87000000
set $mmr_voc  = 0x88000000

# MSHC
set $mmr_mshc0 = 0x92000000
set $mmr_mshc1 = 0x93000000

# UART
set $mmr_uart0 = 0xab800000
set $mmr_uart1 = 0xac000000
set $mmr_uart2 = 0xac800000
set $mmr_uart3 = 0xad000000

# WatchDog
set $mmr_watchdog = 0xad800000

set $mmr_pll      = 0xaf000000

set $mmr_sysc     = 0xaf800000

set $mmr_rtc      = 0xaa800000

set $mmr_timer    = 0xab000000

define mmrlist
    printf "INTC      = %x\n", $mmr_intc
    printf "VIC       = %x\n", $mmr_vic
    printf "VOC       = %x\n", $mmr_voc
    printf "MSHC0     = %x\n", $mmr_mshc0
    printf "MSHC1     = %x\n", $mmr_mshc1
    printf "UART0     = %x\n", $mmr_uart0
    printf "UART1     = %x\n", $mmr_uart1
    printf "UART2     = %x\n", $mmr_uart2
    printf "UART3     = %x\n", $mmr_uart3
    printf "WATCHDOG  = %x\n", $mmr_watchdog
    printf "PLL       = %x\n", $mmr_pll
    printf "SYSC      = %x\n", $mmr_sysc
    printf "RTC       = %x\n", $mmr_rtc
    printf "TIMER     = %x\n", $mmr_timer
end

define mmrread
    print /x *$arg0
end
define mmrwrite
    dont-repeat
    set *($arg0) = $arg1
    mmrread $arg0
end

define cpureset
   set *($mmr_watchdog + 04) = 0x0
   set *($mmr_watchdog + 10) = 0x300
   set *($mmr_watchdog + 14) = 0x0
   set *($mmr_watchdog + 18) = 0x28791166
   set *($mmr_watchdog + 04) = 0x7
end

