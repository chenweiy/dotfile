#
# MACRO List
# - mmrlist 
# - mmrread ADDR
# - mmrwrite ADDR VALUE 
# - cpureset
# - saveyuv ADDR [FILE]
# - saveifp CHN
# - saveisp CHN
# - dmac_debug ENABLE
# - dmac_show_descriptor
# - clk_show
#
echo "\n>>> Vienna.GDB <<<\n"

set $mmr_ca5u_p3 = 0xb1f00000
set $mmr_watchdog = $mmr_ca5u_p3 + 0x620
set $mmr_sysc = 0xb3f00000
set $mmr_intc = 0xb4400000

set $mmr_vic  = 0xb4500000
set $mmr_voc  = 0xb4600000
set $mmr_ifpe = 0xb4800000
set $mmr_ispe = 0xb4900000
set $mmr_jebe = 0xb4b00000
set $mmr_dmac0 = 0xb4200000
set $mmr_dmac1 = 0xb4300000

set $mmr_mshc0 = 0xb8100000
set $mmr_mshc1 = 0xb8200000
set $mmr_i2c0 = 0xb2d00000
set $mmr_i2c1 = 0xb2e00000
set $mmr_i2c2 = 0xb2f00000
set $mmr_spi0 = 0xb2100000
set $mmr_spi1 = 0xb2200000
set $mmr_spi2 = 0xb2300000
set $mmr_spi3 = 0xb2300000
set $mmr_uart0 = 0xb2700000
set $mmr_uart1 = 0xb2800000
set $mmr_uart2 = 0xb3b00000
set $mmr_uart3 = 0xb3c00000
set $mmr_uart4 = 0xb3d00000

define mmrlist

    if $argc == 0
		printf "SYSC      = %x\n", $mmr_sysc
		printf "WATCHDOG  = %x\n", $mmr_watchdog
		printf "INTC      = %x\n", $mmr_intc

		printf "VIC       = %x\n", $mmr_vic
		printf "VOC       = %x\n", $mmr_voc
		printf "IFPE      = %x\n", $mmr_ifpe
		printf "ISPE      = %x\n", $mmr_ispe
		printf "JEBE      = %x\n", $mmr_jebe
		printf "DMAC0      = %x\n", $mmr_dmac0
		printf "DMAC1      = %x\n", $mmr_dmac1

		printf "MSHC0	  = %x\n", $mmr_mshc0
		printf "MSHC1	  = %x\n", $mmr_mshc1
		printf "I2C0	  = %x\n", $mmr_i2c0
		printf "I2C1	  = %x\n", $mmr_i2c1
		printf "I2C2	  = %x\n", $mmr_i2c2
		printf "SPI0	  = %x\n", $mmr_spi0
		printf "SPI1	  = %x\n", $mmr_spi1
		printf "SPI2	  = %x\n", $mmr_spi2
		printf "SPI3	  = %x\n", $mmr_spi3
		printf "UART0	  = %x\n", $mmr_uart0
		printf "UART1	  = %x\n", $mmr_uart1
		printf "UART2     = %x\n", $mmr_uart2
		printf "UART3     = %x\n", $mmr_uart3
		printf "UART4     = %x\n", $mmr_uart4
	end
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
# Set WatchDog mode
   set $scuctrl = *($mmr_watchdog + 0x8)
   set $scuctrl = $scuctrl | 0x8
   set *($mmr_watchdog + 0x8) = $scuctrl
# Disable WatchDog 
   set $scuctrl = $scuctrl & ~(0x1)
   set *($mmr_watchdog + 0x8) = $scuctrl
# Ensure no Prescale
   set $scuctrl = $scuctrl & ~0xff00
   set *($mmr_watchdog + 0x8) = $scuctrl
# Reload counter 
   set *($mmr_watchdog + 0x0) = 0x300
# Set Prescaler
   set $scuctrl = $scuctrl | (124 << 8)
   set *($mmr_watchdog + 0x8) = $scuctrl
# Enable WatchDog
   set $scuctrl = $scuctrl | (0x1)
   set *($mmr_watchdog + 0x8) = $scuctrl
end


define saveyuv
  if $argc == 0 || $argc > 2
    help saveframe
    show user $arg0
  else
    if $argc == 1
      set $yuvfilename = "test.yuv"
    end
    set $frameaddr = $arg0
    set $yaddr = ((TFrameInfo *)$frameaddr)->apbyVirtBuff[0]
    set $cbaddr = ((TFrameInfo *)$frameaddr)->apbyVirtBuff[1]
    set $craddr = ((TFrameInfo *)$frameaddr)->apbyVirtBuff[2]
    set $fwidth = ((TFrameInfo *)$frameaddr)->dwWidth
    set $fheight = ((TFrameInfo *)$frameaddr)->dwHeight
    set $ysize = $fwidth * $fheight
    set $cbsize = $ysize /4
    set $crsize = $ysize /4

    printf "Save frame to file "
    if $argc == 1
      printf "test.yuv\n"
    end
    printf "Frame Res %u x %u\n", $fwidth, $fheight
    printf "-- Y Addr %x Size %u!!\n", $yaddr, $ysize
    printf "-- U Addr %x Size %u!!\n", $cbaddr, $cbsize
    printf "-- V Addr %x Size %u!!\n", $craddr, $crsize

    if $argc == 2
	  if ($yaddr != 0 && $ysize != 0)
        shell rm $arg1
        append binary memory $arg1 $yaddr $yaddr+$ysize
        append binary memory $arg1 $cbaddr $cbaddr+$cbsize
        append binary memory $arg1 $craddr $craddr+$crsize
        printf "Save file Done..!!\n"
	  end
    else
	  if ($yaddr != 0 && $ysize != 0)	
        shell rm test.yuv
        append binary memory test.yuv $yaddr $yaddr+$ysize
        append binary memory test.yuv $cbaddr $cbaddr+$cbsize
        append binary memory test.yuv $craddr $craddr+$crsize
        printf "output Save file test.yuv Done..!!\n"
	  end	
    end 
  end
end
document saveyuv
   Save YUV frame int a file.. 
   Syntax: saveframe ADDR [FILE]
end


define saveifp
  if $argc != 1 
    help saveyuv
    show user $arg0
  else
	set $total = g_ifpe_frame_count
	set $i = 0
	while ($i < $total)
	  set $frameaddr = IFPE_OutFrame[$arg0][$i]
	  printf "IFPE Channel %d Frame %d Addr %08x\n", $arg0, $i, $frameaddr 
	  eval "saveyuv 0x%x ifp-%d-%d.yuv", $frameaddr, $arg0, $i
	  set $i = $i + 1
	end
  end
end
document saveifp
   Save IFP All Output YUV frame into files.. 
   Syntax: saveifp CHANNEL 
end


define saveisp
  if $argc != 1 
    help saveyuv
    show user $arg0
  else	  
	set $total = g_ispe_frame_count
	set $i = 0
	while ($i < $total)
## Original Output	
	  set $frameaddr = &ISPE_OriOutFrameBuff[$arg0][$i]
	  printf "ISPE_OriOutFrameBuff[%d][%d] Addr %08x\n", $arg0, $i, $frameaddr 
	  eval "saveyuv 0x%x isp-ori-%d-%d.yuv", $frameaddr, $arg0, $i
##  Resized Output
  	  set $frameaddr = &ISPE_ResOutFrameBuff[$arg0][$i]
	  printf "ISPE_ResOutFrameBuff[%d][%d] Addr %08x\n", $arg0, $i, $frameaddr
	  eval "saveyuv 0x%x isp-res-%d-%d.yuv", $frameaddr, $arg0, $i
##
	  set $i = $i + 1
	end
  end
end
document saveisp
   Save ISPE Original and Resized[0] Output YUV frame into files.. 
   Syntax: saveisp CHANNEL 
end

define dmac_debug 
    if $arg0 == 1
		break vpl_dmac_locals.c:206
		set $dmac_break_number = $bpnum	
	    commands
			dmac_show_descriptor ptDevInfo->aptMMRInfo[dwWriteIndex]->dwDescriptor
        end
    else
        del $dmac_break_number
    end
end
document dmac_debug
	DMAC debug control. Setup interrupt flag to watch MMR.
    syntax: dmac_debug (0/1)	
end

define dmac_show_descriptor
	set $dmac_ctrl = *$arg0
	set $dmac_srcY= *($arg0+4)
	set $dmac_srcCB= *($arg0+8)
	set $dmac_srcCR= *($arg0+12)
	set $dmac_dstY= *($arg0+16)
	set $dmac_dstCB= *($arg0+20)
	set $dmac_dstCR= *($arg0+24)
	set $dmac_srcStride = *($arg0+32)
	set $dmac_width = *($arg0+36)
	set $dmac_height = *($arg0+40)
	set $dmac_dstStride = *($arg0+44)
	set $dmac_filling00= *($arg0+48)
	set $dmac_filling01= *($arg0+52)
	set $dmac_mask = *($arg0+56)
	set $dmac_alpha = *($arg0+60)
	set $dmac_mask_stride = *($arg0+64)
	set $dmac_nextDesc = *($arg0+68)

	printf "Desciptor 0x%08x --\n", $arg0
	printf "  CTRL          = 0x%08x", $dmac_ctrl
	if ($dmac_ctrl & (0x3 << 21))
		printf " (SRC Compressed)"
	end

	if ($dmac_ctrl & (0x3 << 23))
		printf " (DST Compressed)"
	end

	set $dmac_mode = (($dmac_ctrl & 0xf00) >> 8)
	if ($dmac_mode == 0x1)
		printf " (2D)" 
	end
	if ($dmac_mode == 0x6)
		printf " (Alpha Blending)"
	end
	if ($dmac_mode == 0x7)
		printf " (Vertical Alpha Blending)"
	end
	if ($dmac_mode == 0x8)
		printf " (Index OSD)"
	end
	if ($dmac_mode == 0x3)
		printf " (Privacy Mask)"
	end
	if ($dmac_mode == 0x2)
		printf " (Constant Filling)"
	end

	if ($dmac_ctrl & 0x1000)
		printf " (Component Mode)"
	end

	printf "\n"

	printf "  SRC Y/CB/CR	= 0x%08x / 0x%08x / 0x%08x\n", $dmac_srcY, $dmac_srcCB, $dmac_srcCR
	printf "  SRC STRIDE	= 0x%08x \n", $dmac_srcStride
	printf "  DST Y/CB/CR	= 0x%08x / 0x%08x / 0x%08x\n", $dmac_dstY, $dmac_dstCB, $dmac_dstCR
	printf "  DST STRIDE	= 0x%08x \n", $dmac_dstStride
	printf "  WIDTH/HEIGHT	= %u x %u\n", $dmac_width, $dmac_height
	printf "  FILLING_00    = 0x%08x\n", $dmac_filling00 
	printf "  FILLING_01    = 0x%08x\n", $dmac_filling01
	printf "  MASK / STRIDE = 0x%08x / %u\n", $dmac_mask, $dmac_mask_stride
	printf "  ALPHA	        = 0x%08x\n", $dmac_alpha
	printf "  NEXT DESC     = 0x%08x\n", $dmac_nextDesc
end
document dmac_show_descriptor
   show DMAC descriptor information.
   Syntax: dmac_show_descriptor DESC_ADDR
end

define clk_show
	set $clk0_base = $mmr_sysc + 0x28
	set $clk1_base = $mmr_sysc + 0x2c
	set $clk2_base = $mmr_sysc + 0x30

	set $clk0_val = *$clk0_base
	set $clk1_val = *$clk1_base
	set $clk2_val = *$clk2_base

	set $disp_cnt = 0

	printf "CLK0 = 0x%08x \n", $clk0_val
	printf "CLK1 = 0x%08x \n", $clk1_val
	printf "CLK2 = 0x%08x \n", $clk2_val

	printf "Clock0 enabled list:\n    "
	if ($clk0_val & (0x1 << 0))
		printf "AGPOC[0] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 1))
		printf "AHBC0[1] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 2))
		printf "AHBC1[2] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 3))
		printf "APBC3C[3] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 4))
		printf "APBC[4] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 5))
		printf "AXIC[5] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 6))
		printf "BRC[6] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 7))
		printf "CA5U-APB[7] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 8))
		printf "CA5U[8] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 9))
		printf "CDCE-H264[9] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 10))
		printf "CDCE-H264-Decoder[10] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 11))
		printf "CDCE-H264-Encoder[11] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 12))
		printf "CDCE-H265[12] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 13))
		printf "DCE[13] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 14))
		printf "DDR-ARB[14] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 15))
		printf "DDR-AHB[15] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 16))
		printf "DDR-APB[16] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 17))
		printf "DDR-HDR[17] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 18))
		printf "DDR-SDR[18] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 19))
		printf "DMAC0[19] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 20))
		printf "DMAC1[20] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 21))
		printf "EFUSE[21] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 22))
		printf "EQOSC[22] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 23))
		printf "EQOSC-RMII[23] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 24))
		printf "GPIOC0[24] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 25))
		printf "GPIOC1[25] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 26))
		printf "GPIOC2[26] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 27))
		printf "HSSIC-APB[27] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 28))
		printf "HSSIC-DEV0-CH0[28] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 29))
		printf "HSSIC-DEV0-CH1[29] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 30))
		printf "HSSIC-DEV1[30] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk0_val & (0x1 << 31))
		printf "HSSIC-PEL[31] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	printf "\n"

	printf "Clock1 enabled list:\n    "
	if ($clk1_val & (0x1 << 0))
		printf "I2CC0[0] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 1))
		printf "I2CC1[1] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 2))
		printf "I2CC2[2] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 3))
		printf "I2SSC[3] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 4))
		printf "I2SSC-RX[4] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 5))
		printf "I2SSC-TX[5] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 6))
		printf "IFPE[6] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 7))
		printf "INTC[7] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 8))
		printf "IRDAC[8] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 9))
		printf "ISPE-CACHE[9] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 10))
		printf "ISPE[10] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 11))
		printf "ISPE-GTR[11] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 12))
		printf "JDBE[12] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 13))
		printf "JEBE[12] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 14))
		printf "MBC[13] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 15))
		printf "MBC-P0-DDR[15] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 16))
		printf "MBC-P1-DDR[16] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 17))
		printf "MBC-P2-DMA0[17] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 18))
		printf "MBC-P2-DMA1[18] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 19))
		printf "MBC-P2-DMA2[19] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 20))
		printf "MBC-P3-DDR[20] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 21))
		printf "MBC-P4-BUS0-DDR[21] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 22))
		printf "MBC-P4-BUS1-DDR[22] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 23))
		printf "MBC-P6-DDR[23] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 24))
		printf "MBC-P7-DDR[24] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 25))
		printf "MBC-P9-DDR[25] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 26))
		printf "MBC-P13-DDR[26] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 27))
		printf "MBC-P14-DDR[27] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 28))
		printf "MBC-P15-DDR[28] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 29))
		printf "MEAE[29] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 30))
		printf "RESERVED[30] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk1_val & (0x1 << 31))
		printf "RESERVED[31] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	printf "\n"

	printf "Clock2 enabled list:\n    "
	if ($clk2_val & (0x1 << 0))
		printf "MIPIC-APB[0] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 1))
		printf "MIPIC-PHY[1] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 2))
		printf "MIPIC-RX[2] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 3))
		printf "MIPIC-TX[3] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 4))
		printf "MM3101U-APB[4] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 5))
		printf "MM3101U[5] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 6))
		printf "MSHC0[6] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 7))
		printf "MSHC1[7] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 8))
		printf "NFC[8] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 9))
		printf "PLLC-APB[9] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 10))
		printf "PLLC-REF[10] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 11))
		printf "SSIC0[11] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 12))
		printf "SSIC1[12] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 13))
		printf "SSIC2[13] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 14))
		printf "SSIC3[14] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 15))
		printf "SYSC[15] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 16))
		printf "TMRC[16] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 17))
		printf "UART0[17] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 18))
		printf "UART1[18] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 19))
		printf "UART2[19] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 20))
		printf "UART3[20] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 21))
		printf "UART4[21] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 22))
		printf "USBC-ADP[22] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 23))
		printf "USBC-AHB[23] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 24))
		printf "USBC-APB[24] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 25))
		printf "USBC-CORE[25] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 26))
		printf "USBC-PHY[26] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 27))
		printf "VIC0[27] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 28))
		printf "VIC1[28] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 29))
		printf "VOC[29] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 30))
		printf "X2HBRGC0[30] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	if ($clk2_val & (0x1 << 31))
		printf "X2HBRGC1[31] / "
		set $disp_cnt = $disp_cnt + 1
		if ($disp_cnt % 6 == 0)
			printf "\n    "
		end
	end
	printf "\n"

end

document clk_show
   show clock current status.
   Syntax: clk_show 
end

