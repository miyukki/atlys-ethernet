`timescale 1ns / 1ps

module ether_debug_packet_rx (
  input  wire       rst,
  input  wire       clk_100,
  input  wire       clk_125,
  input  wire       phy_rx_clk,
  input  wire       phy_rx_dv,
  input  wire [7:0] phy_rx_data,
  input  wire [7:0] address,
  output wire [7:0] out
);

reg [7:0]    data [0:2047];
reg [7:0]    counter;

always @(posedge rst or posedge phy_rx_clk) begin
  if (rst) begin
    counter <= 8'b0;
  end
  else if (phy_rx_dv) begin
    data[counter] <= phy_rx_data;
    counter       <= counter + 8'd1;
  end
end

assign out = data[address];

endmodule
