# Generate CMAC and its wrapper, and pack them as a IP in XO format

set min_pkt_len 64
set max_pkt_len 8200
set axi_clk_f   125.00
set synth_jobs  8

set wrkdir [file normalize .]
set board_dir ${wrkdir}/boards
set script_dir ${wrkdir}/scripts
set src_dir ${wrkdir}/src

if {$argc < 2} {
    puts "Usage: vivado -mode batch -source cmac_xopack.tcl -tclargs au\[50|250|280\] <port_id> \[axi_freq\] \[board_rev\]"
    exit
}
if {$argc >= 3} {set axi_clk_f [lindex $argv 2]}
if {$argc >= 4} {set board_rev_override [lindex $argv 3]}

set board [lindex $argv 0]
set qsfp_port [lindex $argv 1]
set board_port ${board}_${qsfp_port}
source ${script_dir}/sanity_check.tcl

set build_dir ${wrkdir}/build/${board_port}
set ip_build_dir ${build_dir}/vivado_ip
file mkdir $ip_build_dir

# Defines part & board_part
source ${board_dir}/${board}.tcl

set krnl_name cmac_${board_port}
set proj_name ${krnl_name}_packprj
create_project -force ${proj_name} ${build_dir}/${proj_name} -part $part
set_property board_part $board_part [current_project]

proc synth_ip {ip_inst num_jobs ip_parent_dir} {
    upgrade_ip [get_ips $ip_inst]
    generate_target synthesis [get_ips $ip_inst]
    set xci_file [get_files ${ip_parent_dir}/${ip_inst}/${ip_inst}.xci]
    export_ip_user_files -of_objects $xci_file -no_script -sync -force
    create_ip_run [get_ips $ip_inst]
    launch_runs ${ip_inst}_synth_1 -jobs $num_jobs
    wait_on_run ${ip_inst}_synth_1
}

# Instantiate CMAC IP
set cmac_usplus cmac_usplus_${qsfp_port}
create_ip -name cmac_usplus -vendor xilinx.com -library ip -module_name $cmac_usplus -dir $ip_build_dir
cmac_set_property $cmac_usplus $qsfp_port
set_property CONFIG.RX_MIN_PACKET_LEN $min_pkt_len [get_ips $cmac_usplus]
set_property CONFIG.RX_MAX_PACKET_LEN $max_pkt_len [get_ips $cmac_usplus]
set_property CONFIG.GT_DRP_CLK $axi_clk_f [get_ips $cmac_usplus]
set_property -dict {
    CONFIG.CMAC_CAUI4_MODE {1}
    CONFIG.NUM_LANES {4x25}
    CONFIG.USER_INTERFACE {AXIS}
    CONFIG.ENABLE_AXI_INTERFACE {1}
    CONFIG.INCLUDE_RS_FEC {1}
    CONFIG.INCLUDE_STATISTICS_COUNTERS {1}
    CONFIG.LANE5_GT_LOC {NA}
    CONFIG.LANE6_GT_LOC {NA}
    CONFIG.LANE7_GT_LOC {NA}
    CONFIG.LANE8_GT_LOC {NA}
    CONFIG.LANE9_GT_LOC {NA}
    CONFIG.LANE10_GT_LOC {NA}
    CONFIG.INS_LOSS_NYQ {20}
    CONFIG.INCLUDE_RS_FEC {1}
    CONFIG.ENABLE_PIPELINE_REG {1}
    CONFIG.TX_FLOW_CONTROL {1}
    CONFIG.RX_FLOW_CONTROL {1}
    CONFIG.RX_CHECK_ACK {1}
} [get_ips $cmac_usplus]
synth_ip $cmac_usplus $synth_jobs $ip_build_dir

# Instantiate AXIS_Data_FIFO IP for clock domain crossing
set cmac_ethcdc axis_cmac_cdc
create_ip -name axis_data_fifo -vendor xilinx.com -library ip -module_name $cmac_ethcdc -dir $ip_build_dir
set_property -dict {
    CONFIG.TDATA_NUM_BYTES {64}
    CONFIG.FIFO_DEPTH {128}
    CONFIG.FIFO_MODE {2}
    CONFIG.FIFO_MEMORY_TYPE {auto}
    CONFIG.IS_ACLK_ASYNC {1}
    CONFIG.TUSER_WIDTH {0}
    CONFIG.HAS_TKEEP {1}
    CONFIG.HAS_TLAST {1}
    CONFIG.SYNCHRONIZATION_STAGES {6}
} [get_ips $cmac_ethcdc]
synth_ip $cmac_ethcdc $synth_jobs $ip_build_dir

# Add IP top-level wrapper and constraints
add_files [glob ${build_dir}/${krnl_name}.v]
add_files [list \
    ${src_dir}/axi_stream_packet_fifo.sv \
    ${src_dir}/axis_cdc_fifo_xpm.v \
    ${src_dir}/axis_packet_counter.v
]
update_compile_order -fileset sources_1
# get_property top [current_fileset] # should be $krnl_name
add_files -fileset constrs_1 [glob ${board_dir}/qsfp_refclk_${board_port}.xdc]
add_files -fileset constrs_1 ${src_dir}/cmac_timing.xdc

# Pack project into IP
set ippack_dir ${build_dir}/${krnl_name}_ippack
file mkdir $ippack_dir
ipx::package_project -root_dir $ippack_dir -vendor nus.edu.sg -library RTLKernel -taxonomy /KernelIP -import_files
set_property name ${krnl_name} [ipx::current_core]
set_property display_name ${krnl_name} [ipx::current_core]
set_property display_name "CMAC 100GbE Vitis kernel for ${board_port}." [ipx::current_core]
set_property -dict {
    version {1.0}
    core_revision {1}
    sdx_kernel {true}
    sdx_kernel_type {rtl}
    supported_families {virtexuplus Production virtexuplusHBM Production}
    auto_family_support_level {level_2}
    xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO}
} [ipx::current_core]
if {[version -short] >= 2021.1} {
    puts "INFO: Adding IP DRC properties for Vivado 2021.x or later."
    set_property vitis_drc {ctrl_protocol ap_ctrl_none} [ipx::current_core]
    set_property ipi_drc {ignore_freq_hz false} [ipx::current_core]
}
set_property range 4096 [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axil -of_objects [ipx::current_core]]]

set cmac_xci ${ip_build_dir}/cmac_usplus_${qsfp_port}/cmac_usplus_${qsfp_port}.xci
puts $cmac_xci
puts [ipx::get_files $cmac_xci -of_objects [ipx::get_file_groups xilinx_implementation -of_objects [ipx::current_core]]]
set ethcdc_xci ${ip_build_dir}/axis_cmac_cdc/axis_cmac_cdc.xci
puts $ethcdc_xci
puts [ipx::get_files $ethcdc_xci -of_objects [ipx::get_file_groups xilinx_implementation -of_objects [ipx::current_core]]]

# set_property is_include true [ipx::get_files $cmac_xci -of_objects [ipx::get_file_groups xilinx_implementation -of_objects [ipx::current_core]]]
# set_property is_include true [ipx::get_files $ethcdc_xci -of_objects [ipx::get_file_groups xilinx_implementation -of_objects [ipx::current_core]]]

# IP interface adjustments

# Clock and Reset - Specified inline in cmac_wrapper
# set intf_apclk [ipx::add_bus_interface ap_clk [ipx::current_core]]
# set_property -dict {
#     abstraction_type_vlnv {xilinx.com:signal:clock_rtl:1.0}
#     bus_type_vlnv {xilinx.com:signal:clock:1.0}
# } $intf_apclk
# set intf_apclk_clk [ipx::add_port_map CLK $intf_apclk]
# set_property physical_name ap_clk $intf_apclk_clk
# ipx::associate_bus_interfaces -busif s_axis -clock ap_clk -reset ap_rst_n [ipx::current_core]
# ipx::associate_bus_interfaces -busif m_axis -clock ap_clk -reset ap_rst_n [ipx::current_core]
# ipx::associate_bus_interfaces -busif s_axil -clock ap_clk -reset ap_rst_n [ipx::current_core]

# Gigabit Transceivers of QSFP/Refclk
set intf_gt [ipx::add_bus_interface gt_qsfp [ipx::current_core]]
set_property -dict {
    interface_mode {master}
    abstraction_type_vlnv {xilinx.com:interface:gt_rtl:1.0}
    bus_type_vlnv {xilinx.com:interface:gt:1.0}
} $intf_gt
set intf_gt_rxp [ipx::add_port_map GRX_P $intf_gt]
set_property physical_name gt_rxp $intf_gt_rxp
set intf_gt_rxn [ipx::add_port_map GRX_N $intf_gt]
set_property physical_name gt_rxn $intf_gt_rxn
set intf_gt_txp [ipx::add_port_map GTX_P $intf_gt]
set_property physical_name gt_txp $intf_gt_txp
set intf_gt_txn [ipx::add_port_map GTX_N $intf_gt]
set_property physical_name gt_txn $intf_gt_txn

#set intf_refclk [ipx::add_bus_interface refclk_qsfp [ipx::current_core]]
#set_property -dict {
#    interface_mode {slave}
#    abstraction_type_vlnv {xilinx.com:interface:diff_clock_rtl:1.0}
#    bus_type_vlnv {xilinx.com:interface:diff_clock:1.0}
#} $intf_refclk
#set intf_refclk_n [ipx::add_port_map CLK_N $intf_refclk]
#set_property physical_name gt_refclk_n $intf_refclk_n
#set intf_refclk_p [ipx::add_port_map CLK_P $intf_refclk]
#set_property physical_name gt_refclk_p $intf_refclk_p

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity -kernel -xrt [ipx::current_core]
ipx::save_core [ipx::current_core]

# Finally generate the XO kernel from the packed IP
package_xo -xo_path ${build_dir}/${krnl_name}.xo -kernel_name $krnl_name -ip_directory $ippack_dir -kernel_xml ${build_dir}/kernel_${board_port}.xml -ctrl_protocol ap_ctrl_none

ipx::unload_core [ipx::current_core]
close_project

