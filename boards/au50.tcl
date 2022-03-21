# Board specific parameters for Alveo U50

set part xcu50-fsvh2104-2-e
# Board rev 1.0 is used in xilinx_u50_gen3x16_xdma_201920_3
# For rev 1.2, change DIFFCLK_BOARD_INTERFACE to qsfp_161mhz
set board_part xilinx.com:au50:part0:1.0

proc cmac_set_property {cmac_ip port_id} {
    set_property -dict {
        CONFIG.ETHERNET_BOARD_INTERFACE {qsfp_4x}
        CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp_refclk0}
        CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y4}
        CONFIG.GT_GROUP_SELECT {X0Y28~X0Y31}
        CONFIG.LANE1_GT_LOC {X0Y28}
        CONFIG.LANE2_GT_LOC {X0Y29}
        CONFIG.LANE3_GT_LOC {X0Y30}
        CONFIG.LANE4_GT_LOC {X0Y31}
    } [get_ips $cmac_ip]
    set_property CONFIG.GT_REF_CLK_FREQ 161.1328125 [get_ips $cmac_ip]
}
