`timescale 1ns / 1ps

module main #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0
) (
  input  wire RST,
  input  wire CLK_100M,
  input  wire BTN,

  // Ethernet
  output wire ETH_RST,
  output wire ETH_CLK,
  /*output wire ETH_MDC_PAD_O,
  input  wire ETH_MD_PAD_IO,*/
  // input  wire ETH_COL,
  // input  wire ETH_CRS,

  input  wire       ETH_TX_CLK,
  output wire       ETH_TX_ER,
  output wire       ETH_TX_EN,
  output wire [7:0] ETH_TX_DATA,

  input  wire       ETH_RX_CLK,
  input  wire       ETH_RX_ER,
  input  wire       ETH_RX_DV,
  input  wire [7:0] ETH_RX_DATA,

  // Debug
  /*input  wire       SW,*/
  output wire [7:0] LED
);

/*------------------------------------------*
 * Ethernet                                 *
 *------------------------------------------*/

// Timing
wire CLK_125M;

ether_timing ether_timing (
  .rst       (RST),
  .clk_100   (CLK_100M),
  .phy_rst   (ETH_RST),
  .phy_clk   (ETH_CLK),
  .clk_125   (CLK_125M)
);

// TX
ether_sample_packet_tx sample_tx (
  .trig     (BTN),
  .rst      (RST),
  .clk_100  (CLK_100M),
  .clk_125  (CLK_125M),
  .phy_clk  (ETH_CLK),
  .phy_rst  (ETH_RST),
  .phy_er   (ETH_TX_ER),
  .phy_en   (ETH_TX_EN),
  .phy_data (ETH_TX_DATA)
);

// RX
ether_debug_packet_rx debug_rx (
  .rst         (RST),
  .clk_100     (CLK_100M),
  .clk_125     (CLK_125M),
  .phy_rx_clk  (ETH_RX_CLK),
  .phy_rx_data (ETH_RX_DATA),
  .out         (LED)
);

endmodule
