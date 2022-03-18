# Board specific parameters for Alveo U50

set part xcu50-fsvh2104-2-e
set board_part xilinx.com:au50:part0:1.2

proc cmac_set_property {cmac_ip port_id} {
    set_property -dict {
        CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y4}
        CONFIG.GT_GROUP_SELECT {X0Y28~X0Y31}
        CONFIG.LANE1_GT_LOC {X0Y28}
        CONFIG.LANE2_GT_LOC {X0Y29}
        CONFIG.LANE3_GT_LOC {X0Y30}
        CONFIG.LANE4_GT_LOC {X0Y31}
        CONFIG.ETHERNET_BOARD_INTERFACE {qsfp_4x}
        CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp_161mhz}
    } [get_ips $cmac_ip]
    set_property CONFIG.GT_REF_CLK_FREQ 161.1328125 [get_ips $cmac_ip]
}
