# Board specific parameters for Alveo U250

set part xcu250-figd2104-2l-e
set board_part xilinx.com:au250:part0:1.3

proc cmac_set_property {cmac_ip port_id} {
    if {$port_id == 0} {
        set_property -dict {
            CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y8}
            CONFIG.GT_GROUP_SELECT {X1Y44~X1Y47}
            CONFIG.LANE1_GT_LOC {X1Y44}
            CONFIG.LANE2_GT_LOC {X1Y45}
            CONFIG.LANE3_GT_LOC {X1Y46}
            CONFIG.LANE4_GT_LOC {X1Y47}
            CONFIG.ETHERNET_BOARD_INTERFACE {qsfp0_4x}
            CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp0_156mhz}
        } [get_ips $cmac_ip]
    } else {
        set_property -dict {
            CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y7}
            CONFIG.GT_GROUP_SELECT {X1Y40~X1Y43}
            CONFIG.LANE1_GT_LOC {X1Y40}
            CONFIG.LANE2_GT_LOC {X1Y41}
            CONFIG.LANE3_GT_LOC {X1Y42}
            CONFIG.LANE4_GT_LOC {X1Y43}
            CONFIG.ETHERNET_BOARD_INTERFACE {qsfp1_4x}
            CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp1_156mhz}
        } [get_ips $cmac_ip]
    }
    set_property CONFIG.GT_REF_CLK_FREQ 156.25 [get_ips $cmac_ip]
}
