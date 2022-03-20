# Board specific parameters for Alveo U280

set part xcu280-fsvh2892-2L-e
set board_part xilinx.com:au280:part0:1.1

proc cmac_set_property {cmac_ip port_id} {
    if {$port_id == 0} {
        set_property -dict {
            CONFIG.ETHERNET_BOARD_INTERFACE {qsfp0_4x}
            CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp0_156mhz}
            CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y6}
            CONFIG.GT_GROUP_SELECT {X1Y40~X1Y43}
            CONFIG.LANE1_GT_LOC {X0Y40}
            CONFIG.LANE2_GT_LOC {X0Y41}
            CONFIG.LANE3_GT_LOC {X0Y42}
            CONFIG.LANE4_GT_LOC {X0Y43}
        } [get_ips $cmac_ip]
    } else {
        set_property -dict {
            CONFIG.ETHERNET_BOARD_INTERFACE {qsfp1_4x}
            CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp1_156mhz}
            CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y7}
            CONFIG.GT_GROUP_SELECT {X0Y44~X0Y47}
            CONFIG.LANE1_GT_LOC {X0Y44}
            CONFIG.LANE2_GT_LOC {X0Y45}
            CONFIG.LANE3_GT_LOC {X0Y46}
            CONFIG.LANE4_GT_LOC {X0Y47}
        } [get_ips $cmac_ip]
    }
    set_property CONFIG.GT_REF_CLK_FREQ 156.25 [get_ips $cmac_ip]
}
