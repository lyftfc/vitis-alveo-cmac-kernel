# Board specific parameters for Alveo U200

set part xcu200-fsgd2104-2-e
set board_part xilinx.com:au200:part0:1.3

proc cmac_set_property {cmac_ip port_id} {
    if {$port_id == 0} {
        set_property -dict {
            CONFIG.ETHERNET_BOARD_INTERFACE {qsfp0_4x}
            CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp0_156mhz}
            CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y6}
            CONFIG.GT_GROUP_SELECT {X1Y48~X1Y51}
            CONFIG.LANE1_GT_LOC {X1Y48}
            CONFIG.LANE2_GT_LOC {X1Y49}
            CONFIG.LANE3_GT_LOC {X1Y50}
            CONFIG.LANE4_GT_LOC {X1Y51}
        } [get_ips $cmac_ip]
    } else {
        set_property -dict {
            CONFIG.ETHERNET_BOARD_INTERFACE {qsfp1_4x}
            CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp1_156mhz}
            CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y7}
            CONFIG.GT_GROUP_SELECT {X1Y44~X1Y47}
            CONFIG.LANE1_GT_LOC {X1Y44}
            CONFIG.LANE2_GT_LOC {X1Y45}
            CONFIG.LANE3_GT_LOC {X1Y46}
            CONFIG.LANE4_GT_LOC {X1Y47}
        } [get_ips $cmac_ip]
    }
    set_property CONFIG.GT_REF_CLK_FREQ 156.25 [get_ips $cmac_ip]
}
