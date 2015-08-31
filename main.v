`timescale 1ns / 1ps

module main #(
  parameter BASE_MAC_ADDR = { 8'h00, 8'h30, 8'h1b, 8'ha0, 8'ha4, 8'h8e },
  parameter BASE_IP_ADDR  = { 8'd172, 8'd16, 8'd0, 8'd230 }
) (
  input  wire RST,
  input  wire CLK_100M,
  input  wire BTN,

  // Ethernet
  output wire ETH_RST,
  output wire ETH_CLK,

  input  wire       ETH_TX_CLK,
  output wire       ETH_TX_ER,
  output wire       ETH_TX_EN,
  output wire [7:0] ETH_TX_DATA,

  input  wire       ETH_RX_CLK,
  input  wire       ETH_RX_ER,
  input  wire       ETH_RX_DV,
  input  wire [7:0] ETH_RX_DATA,

  // Debug
  input  wire [7:0] SW,
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
ether_udp_demo_tx demo_tx (
  .id          (SW[7]),
  .trig        (BTN),
  .rst         (RST),
  .clk_125     (CLK_125M),
  .phy_tx_clk  (ETH_TX_CLK),
  .phy_tx_er   (ETH_TX_ER),
  .phy_tx_en   (ETH_TX_EN),
  .phy_tx_data (ETH_TX_DATA),
  .data_in     (SW[6:0])
);

/*ether_sample_packet_tx sample_tx (
  .trig     (BTN),
  .rst      (RST),
  .clk_100  (CLK_100M),
  .clk_125  (CLK_125M),
  .phy_clk  (ETH_CLK),
  .phy_rst  (ETH_RST),
  .phy_er   (ETH_TX_ER),
  .phy_en   (ETH_TX_EN),
  .phy_data (ETH_TX_DATA)
);*/

// RX
ether_udp_demo_rx demo_rx (
  .id          (SW[7]),
  .rst         (RST),
  .phy_rx_clk  (ETH_RX_CLK),
  .phy_rx_dv   (ETH_RX_DV),
  .phy_rx_data (ETH_RX_DATA),
  .data_out    (LED[6:0])
);

/*ether_sample_packet_rx sample_rx (
  .rst         (RST),
  .clk_100     (CLK_100M),
  .clk_125     (CLK_125M),
  .phy_rx_clk  (ETH_RX_CLK),
  .phy_rx_dv   (ETH_RX_DV),
  .phy_rx_data (ETH_RX_DATA),
  .address     (SW),
  .out         (LED)
);*/
/*ether_debug_packet_rx debug_rx (
  .rst         (RST),
  .clk_100     (CLK_100M),
  .clk_125     (CLK_125M),
  .phy_rx_clk  (ETH_RX_CLK),
  .phy_rx_dv   (ETH_RX_DV),
  .phy_rx_data (ETH_RX_DATA),
  .address     (SW),
  .out         (LED)
);*/

assign LED[7] = SW[7];

endmodule
