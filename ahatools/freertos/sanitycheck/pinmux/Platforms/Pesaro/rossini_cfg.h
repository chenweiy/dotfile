#define GPIOC_0_IO_DATA_0          _GPIO(0)
#define GPIOC_0_IO_DATA_1          _GPIO(1)
#define GPIOC_0_IO_DATA_2          _GPIO(2)
#define GPIOC_0_IO_DATA_3          _GPIO(3)
#define GPIOC_0_IO_DATA_4          _GPIO(4)
#define GPIOC_0_IO_DATA_5          _GPIO(5)
#define GPIOC_0_IO_DATA_6          _GPIO(6)
#define GPIOC_0_IO_DATA_7          _GPIO(7)
#define GPIOC_0_IO_DATA_8          _GPIO(8)
#define GPIOC_0_IO_DATA_9          _GPIO(9)
#define GPIOC_0_IO_DATA_10         _GPIO(10)
#define GPIOC_0_IO_DATA_11         _GPIO(11)
#define GPIOC_0_IO_DATA_12         _GPIO(12)
#define GPIOC_0_IO_DATA_13         _GPIO(13)
#define GPIOC_0_IO_DATA_14         _GPIO(14)
#define GPIOC_0_IO_DATA_15         _GPIO(15)
#define SSIC_I_RXD                 _GPIO(16)
#define SSIC_O_BCLK                _GPIO(17)
#define SSIC_O_TXD                 _GPIO(18)
#define SSIC_O_nSEL_0              _GPIO(19)
#define SSIC_O_nSEL_1              _GPIO(20)
#define VIC_I_DEV_0_VSYNC          _GPIO(21)
#define VIC_I_DEV_0_HSYNC          _GPIO(22)
#define VIC_I_DEV_0_DATA_12        _GPIO(23)
#define VIC_I_DEV_0_DATA_13        _GPIO(24)
#define VIC_I_DEV_0_DATA_14        _GPIO(25)
#define VIC_I_DEV_0_DATA_15        _GPIO(26)
#define MSHC_0_I_CARD_nDETECT      _GPIO(27)
#define MSHC_0_IO_DATA_0           _GPIO(28)
#define MSHC_0_IO_DATA_1           _GPIO(29)
#define MSHC_0_IO_DATA_2           _GPIO(30)
#define MSHC_0_IO_DATA_3           _GPIO(31)
#define MSHC_0_IO_CMD              _GPIO(32)
#define MSHC_0_O_TX_CLK            _GPIO(33)
#define MSHC_1_IO_DATA_0           _GPIO(34)
#define MSHC_1_IO_DATA_1           _GPIO(35)
#define MSHC_1_IO_DATA_2           _GPIO(36)
#define MSHC_1_IO_DATA_3           _GPIO(37)
#define MSHC_1_IO_CMD              _GPIO(38)
#define MSHC_1_O_TX_CLK            _GPIO(39)
#define I2SSC_I_RX_BCLK            _GPIO(40)
#define I2SSC_I_TX_BCLK            _GPIO(41)
#define I2SSC_I_RX_WS              _GPIO(42)
#define I2SSC_I_TX_WS              _GPIO(43)
#define I2SSC_I_RXD                _GPIO(44)
#define I2SSC_O_TXD                _GPIO(45)
#define I2SSC_O_MCLK               _GPIO(46)
#define SYS_O_MON_CLK              _GPIO(47)
#define IRDAC_I_SDA                _GPIO(48)
#define HDMITC_IO_DDCSCL           _GPIO(49)
#define HDMITC_IO_DDCSDA           _GPIO(50)
#define HDMITC_IO_CEC              _GPIO(51)
#define VOC_I_REF_CLK              _GPIO(52)
#define VOC_O_BLANK                _GPIO(53)
#define VOC_O_VSYNC                _GPIO(54)
#define VOC_O_HSYNC                _GPIO(55)
#define VOC_O_DATA_0               _GPIO(56)
#define VOC_O_DATA_1               _GPIO(57)
#define VOC_O_DATA_2               _GPIO(58)
#define VOC_O_DATA_3               _GPIO(59)
#define VOC_O_DATA_4               _GPIO(60)
#define VOC_O_DATA_5               _GPIO(61)
#define VOC_O_DATA_6               _GPIO(62)
#define VOC_O_DATA_7               _GPIO(63)
#define VOC_O_DATA_8               _GPIO(64)
#define VOC_O_DATA_9               _GPIO(65)
#define VOC_O_DATA_10              _GPIO(66)
#define VOC_O_DATA_11              _GPIO(67)
#define VOC_O_DATA_12              _GPIO(68)
#define VOC_O_DATA_13              _GPIO(69)
#define VOC_O_DATA_14              _GPIO(70)
#define VOC_O_DATA_15              _GPIO(71)
#define VOC_O_CLK                  _GPIO(72)
#define UARTC_3_I_SDA              _GPIO(73)
#define UARTC_3_O_SDA              _GPIO(74)
#define UARTC_2_I_SDA              _GPIO(75)
#define UARTC_2_O_SDA              _GPIO(76)
#define UARTC_1_I_SDA              _GPIO(77)
#define UARTC_1_O_SDA              _GPIO(78)
#define NFC_IO_DATA_0              _GPIO(79)
#define NFC_IO_DATA_1              _GPIO(80)
#define NFC_IO_DATA_2              _GPIO(81)
#define NFC_IO_DATA_3              _GPIO(82)
#define NFC_IO_DATA_4              _GPIO(83)
#define NFC_IO_DATA_5              _GPIO(84)
#define NFC_IO_DATA_6              _GPIO(85)
#define NFC_IO_DATA_7              _GPIO(86)
#define NFC_O_nWP                  _GPIO(87)
#define NFC_O_nCE                  _GPIO(88)
#define NFC_O_nRE                  _GPIO(89)
#define NFC_O_nWE                  _GPIO(90)
#define NFC_O_ALE                  _GPIO(91)
#define NFC_O_CLE                  _GPIO(92)
#define NFC_I_nRB                  _GPIO(93)
#define I2CC_0_IO_SCL              _GPIO(94)
#define I2CC_0_IO_SDA              _GPIO(95)
#define UARTC_0_I_SDA              _GPIO(96)
#define UARTC_0_O_SDA              _GPIO(97)
#define ARM926U_PAD                _GPIO(98)
#define GMAC_PAD                   _GPIO(99)
#define VIC_REF_CLK                _GPIO(100)
#define VIC_DEFAULT                _GPIO(101)
#define WDT_PAD                    _GPIO(102)
#define GMAC_REF_CLK               _GPIO(103)
#define GMAC_TX_CLK                _GPIO(104)


static const unsigned int i2c0_pos_0_pins[] = {
	I2CC_0_IO_SCL,
	I2CC_0_IO_SDA,
};

static const unsigned int i2c0_pos_1_pins[] = {
	GPIOC_0_IO_DATA_13,
	GPIOC_0_IO_DATA_14,
};

static const unsigned int i2c1_pins[] = {
	VIC_I_DEV_0_DATA_14,
	VIC_I_DEV_0_DATA_15,
};

static const unsigned int i2c2_pins[] = {
	MSHC_1_IO_DATA_0,
	MSHC_1_IO_DATA_1,
};

static const unsigned int uart0_pos_0_pins[] = {
	UARTC_0_I_SDA,
	UARTC_0_O_SDA,
};

static const unsigned int modem_pos_0_pins[] = {
	UARTC_3_I_SDA,
	UARTC_3_O_SDA,
	UARTC_2_I_SDA,
	UARTC_2_O_SDA,
	UARTC_1_I_SDA,
	UARTC_1_O_SDA,
	UARTC_0_I_SDA,
	UARTC_0_O_SDA,
};

static const unsigned int uart0_pos_1_pins[] = {
	I2SSC_I_RX_BCLK,
	I2SSC_O_MCLK,
};

static const unsigned int modem_pos_1_pins[] = {
	I2SSC_I_RX_BCLK,
	I2SSC_O_MCLK,
	I2SSC_I_TX_BCLK,
	SYS_O_MON_CLK,
};

static const unsigned int uart1_pos_0_pins[] = {
	UARTC_1_I_SDA,
	UARTC_1_O_SDA,
};

static const unsigned int uart1_pos_1_pins[] = {
	HDMITC_IO_DDCSCL,
	HDMITC_IO_DDCSDA,
};

static const unsigned int uart2_pos_0_pins[] = {
	UARTC_2_I_SDA,
	UARTC_2_O_SDA,
};

static const unsigned int uart2_pos_1_pins[] = {
	I2SSC_I_RXD,
	I2SSC_O_TXD,
};

static const unsigned int uart3_pos_0_pins[] = {
	UARTC_3_I_SDA,
	UARTC_3_O_SDA,
};

static const unsigned int uart3_pos_1_pins[] = {
	NFC_O_nRE,
	NFC_I_nRB,
};

static const unsigned int arm926u_pins[] = {
	ARM926U_PAD,
};

static const unsigned int gmac_pins[] = {
	GMAC_PAD,
};

static const unsigned int gmac_ref_clk_pins[] = {
	GMAC_REF_CLK,
};

static const unsigned int gmac_tx_clk_pins[] = {
	GMAC_TX_CLK,
};

static const unsigned int hdmitc_pins[] = {
	HDMITC_IO_DDCSCL,
	HDMITC_IO_DDCSDA,
	HDMITC_IO_CEC,
};

static const unsigned int i2ssc_ext_slave_pins[] = {
	I2SSC_I_RX_BCLK,
	I2SSC_I_TX_BCLK,
	I2SSC_I_RX_WS,
	I2SSC_I_TX_WS,
	I2SSC_I_RXD,
	I2SSC_O_TXD,
};

static const unsigned int i2ssc_ext_master_pins[] = {
	I2SSC_I_RX_BCLK,
	I2SSC_I_TX_BCLK,
	I2SSC_I_RX_WS,
	I2SSC_I_TX_WS,
	I2SSC_I_RXD,
	I2SSC_O_TXD,
	I2SSC_O_MCLK,
};

static const unsigned int irdac_pins[] = {
	IRDAC_I_SDA,
};

static const unsigned int monitor_pins[] = {
	SYS_O_MON_CLK,
};

static const unsigned int mshc0_pins[] = {
	MSHC_0_I_CARD_nDETECT,
	MSHC_0_IO_DATA_0,
	MSHC_0_IO_DATA_1,
	MSHC_0_IO_DATA_2,
	MSHC_0_IO_DATA_3,
	MSHC_0_IO_CMD,
	MSHC_0_O_TX_CLK,
};

static const unsigned int mshc0_pos_0_pins[] = {
	GPIOC_0_IO_DATA_15,
};

static const unsigned int mshc0_pos_1_pins[] = {
	HDMITC_IO_CEC,
};

static const unsigned int mshc1_pins[] = {
	MSHC_1_IO_DATA_0,
	MSHC_1_IO_DATA_1,
	MSHC_1_IO_DATA_2,
	MSHC_1_IO_DATA_3,
	MSHC_1_IO_CMD,
	MSHC_1_O_TX_CLK,
};

static const unsigned int nfc_pins[] = {
	NFC_IO_DATA_0,
	NFC_IO_DATA_1,
	NFC_IO_DATA_2,
	NFC_IO_DATA_3,
	NFC_IO_DATA_4,
	NFC_IO_DATA_5,
	NFC_IO_DATA_6,
	NFC_IO_DATA_7,
	NFC_O_nWP,
	NFC_O_nCE,
	NFC_O_nRE,
	NFC_O_nWE,
	NFC_O_ALE,
	NFC_O_CLE,
	NFC_I_nRB,
};

static const unsigned int ssic_pos_0_pins[] = {
	SSIC_I_RXD,
	SSIC_O_BCLK,
	SSIC_O_TXD,
	SSIC_O_nSEL_0,
	SSIC_O_nSEL_1,
};

static const unsigned int ssic_pos_1_pins[] = {
	VIC_I_DEV_0_DATA_12,
	VIC_I_DEV_0_DATA_13,
	VIC_I_DEV_0_DATA_14,
	VIC_I_DEV_0_DATA_15,
};

static const unsigned int vic_dev0_sec0_pins[] = {
	VIC_DEFAULT,
};

static const unsigned int vic_dev0_sec1_pins[] = {
	VIC_I_DEV_0_VSYNC,
	VIC_I_DEV_0_HSYNC,
};

static const unsigned int vic_dev0_sec2_pins[] = {
	VIC_I_DEV_0_DATA_12,
	VIC_I_DEV_0_DATA_13,
	VIC_I_DEV_0_DATA_14,
	VIC_I_DEV_0_DATA_15,
};

static const unsigned int vic_dev1_sec0_pins[] = {
	GPIOC_0_IO_DATA_0,
	GPIOC_0_IO_DATA_1,
	GPIOC_0_IO_DATA_2,
	GPIOC_0_IO_DATA_3,
	GPIOC_0_IO_DATA_4,
	GPIOC_0_IO_DATA_5,
	GPIOC_0_IO_DATA_6,
	GPIOC_0_IO_DATA_7,
	GPIOC_0_IO_DATA_8,
};

static const unsigned int vic_dev1_sec1_pins[] = {
	GPIOC_0_IO_DATA_13,
	GPIOC_0_IO_DATA_14,
};

static const unsigned int vic_dev1_sec2_pins[] = {
	GPIOC_0_IO_DATA_9,
	GPIOC_0_IO_DATA_10,
	GPIOC_0_IO_DATA_11,
	GPIOC_0_IO_DATA_12,
};

static const unsigned int vic_ref_clk_pins[] = {
	VIC_REF_CLK,
};

static const unsigned int voc_16bit_pins[] = {
	VOC_O_BLANK,
	VOC_O_VSYNC,
	VOC_O_HSYNC,
	VOC_O_DATA_0,
	VOC_O_DATA_1,
	VOC_O_DATA_2,
	VOC_O_DATA_3,
	VOC_O_DATA_4,
	VOC_O_DATA_5,
	VOC_O_DATA_6,
	VOC_O_DATA_7,
	VOC_O_DATA_8,
	VOC_O_DATA_9,
	VOC_O_DATA_10,
	VOC_O_DATA_11,
	VOC_O_DATA_12,
	VOC_O_DATA_13,
	VOC_O_DATA_14,
	VOC_O_DATA_15,
	VOC_O_CLK,
};

static const unsigned int voc_24bit_pins[] = {
	VOC_O_BLANK,
	VOC_O_VSYNC,
	VOC_O_HSYNC,
	VOC_O_DATA_0,
	VOC_O_DATA_1,
	VOC_O_DATA_2,
	VOC_O_DATA_3,
	VOC_O_DATA_4,
	VOC_O_DATA_5,
	VOC_O_DATA_6,
	VOC_O_DATA_7,
	VOC_O_DATA_8,
	VOC_O_DATA_9,
	VOC_O_DATA_10,
	VOC_O_DATA_11,
	VOC_O_DATA_12,
	VOC_O_DATA_13,
	VOC_O_DATA_14,
	VOC_O_DATA_15,
	VOC_O_CLK,
	UARTC_3_I_SDA,
	UARTC_3_O_SDA,
	UARTC_2_I_SDA,
	UARTC_2_O_SDA,
	UARTC_1_I_SDA,
	UARTC_1_O_SDA,
	UARTC_0_I_SDA,
	UARTC_0_O_SDA,
};

static const unsigned int voc_ref_clk_pins[] = {
	VOC_I_REF_CLK,
};

static const unsigned int wdt_pins[] = {
	WDT_PAD,
};

