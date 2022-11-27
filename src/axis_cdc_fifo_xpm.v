`timescale 1ns / 1ps

module axis_cdc_fifo_xpm (
    input   wire        s_axis_aclk,
    input   wire        m_axis_aclk,
    input   wire        s_axis_aresetn,

    input   wire        s_axis_tvalid,
    input   wire        s_axis_tready,
    input   wire [511:0] s_axis_tdata,
    input   wire [63:0] s_axis_tkeep,
    input   wire        s_axis_tlast,

    input   wire        m_axis_tvalid,
    input   wire        m_axis_tready,
    input   wire [511:0] m_axis_tdata,
    input   wire [63:0] m_axis_tkeep,
    input   wire        m_axis_tlast
);

axi_stream_packet_fifo #(
    .CLOCKING_MODE      ("independent_clock"),
    .FIFO_MEMORY_TYPE   ("auto"),
    .FIFO_DEPTH         (128),
    .TDATA_WIDTH        (512),
    .ECC_MODE           ("no_ecc"),
    .RELATED_CLOCKS     (0),
    .CDC_SYNC_STAGES    (2)
) axis_pkt_fifo_inst (
    .s_axis_tvalid      (s_axis_tvalid),
    .s_axis_tready      (s_axis_tready),
    .s_axis_tdata       (s_axis_tdata),
    .s_axis_tstrb       ({64{1'b1}}),
    .s_axis_tkeep       (s_axis_tkeep),
    .s_axis_tlast       (s_axis_tlast),
    .s_axis_tid         (0),
    .s_axis_tdest       (0),
    .s_axis_tuser       (0),
  
    .m_axis_tvalid      (m_axis_tvalid),
    .m_axis_tready      (m_axis_tready),
    .m_axis_tdata       (m_axis_tdata),
    .m_axis_tstrb       (),
    .m_axis_tkeep       (m_axis_tkeep),
    .m_axis_tlast       (m_axis_tlast),
    .m_axis_tid         (),
    .m_axis_tdest       (),
    .m_axis_tuser       (),
  
    .prog_full_axis     (),
    .wr_data_count_axis (),
    .almost_full_axis   (),
    .prog_empty_axis    (),
    .rd_data_count_axis (),
    .almost_empty_axis  (),

    .injectsbiterr_axis (1'b0),
    .injectdbiterr_axis (1'b0),
    .sbiterr_axis       (),
    .dbiterr_axis       (),

    .s_aresetn          (s_axis_aresetn),
    .s_aclk             (s_axis_aclk),
    .m_aclk             (m_axis_aclk)
);

endmodule