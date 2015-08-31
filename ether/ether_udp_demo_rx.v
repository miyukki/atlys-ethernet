`timescale 1ns / 1ps

module ether_udp_demo_rx (
  input  wire       rst,
  input  wire       clk_100,
  input  wire       clk_125,
  input  wire       phy_rx_clk,
  input  wire       phy_rx_dv,
  input  wire [7:0] phy_rx_data,
  input  wire [7:0] address,
  output wire [7:0] out
);

endmodule
