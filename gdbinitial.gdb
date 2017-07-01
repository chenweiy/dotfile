target remote 192.168.17.149:2331
load
monitor halt

echo Start running\n

b UART_IRQHandler
b UART_Send_dma
b apbc_dma_interrupt
b APBC_DMA_Transfer
b main
c

define attach_cpu
    target remote 192.168.17.149:2331
    file ../../_build/Vienna/test_UART/test_UART.elf
    monitor halt
    monitor regs
end

define savetrace
    set $traceptr = (unsigned long)&RecorderData
    set $traceptr_end = $traceptr + 0x100000
    printf "Dump tracedata to trace.bin @ %x ~ %x\n", $traceptr, $traceptr_end
    dump binary memory trace.bin $traceptr $traceptr_end
end

define saveconsole
    set $consoleptr = (unsigned long)&bConsoleOutputBuffer
    set $consoleptr_end = $consoleptr + 0x10000
    printf "Dump consoledata to console.bin @ %x ~ %x\n", $consoleptr, $consoleptr_end
    dump binary memory console.bin $consoleptr $consoleptr_end
end

define dataabort
    set $cpsr = $spsr
    set $PC = $lr
    bt
end
