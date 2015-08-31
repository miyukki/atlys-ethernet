`timescale 1ns / 1ps

module ether_sample_packet_rx (
  input  wire       rst,
  input  wire       clk_100,
  input  wire       clk_125,
  input  wire       phy_rx_clk,
  input  wire       phy_rx_dv,
  input  wire [7:0] phy_rx_data,
  input  wire [7:0] address,
  output wire [7:0] out
);

/*------------------------------------------*
 * CRC Calculate                            *
 *------------------------------------------*/

reg           crc_en;
wire   [31:0] crc_out;
assign        crc_clear = (cnt == 12'h08);

crc crc_calc (
  .clk     (phy_rx_clk),
  .reset   (rst),
  .clear   (crc_clear),
  .data    (phy_rx_data),
  .calc    (crc_en),
  .crc_out (crc_out)
);

/*------------------------------------------*
 * Receive sample packet                    *
 *------------------------------------------*/

reg [7:0]  data [0:2047];
reg [11:0] cnt;

localparam NONE  = 2'h0;
localparam PRE   = 2'h1;
localparam DATA  = 2'h2;
localparam CRC   = 2'h3;
reg [1:0]  state = NONE;

always @(posedge rst or posedge phy_rx_clk) begin
  if (rst) begin
    cnt   <= 12'd0;
    state <= 2'h0;
  end
  else if (phy_rx_dv) begin
    case (state)
      NONE: if (phy_rx_data == 8'h55) begin
        state <= PRE;
        cnt <= cnt + 12'd1;
      end
      PRE: begin
        if (phy_rx_data == 8'h55) begin
          cnt <= cnt + 12'd1;
        end
        else if (cnt == 12'd07 && phy_rx_data == 8'hd5) begin
          state <= DATA;
          cnt <= cnt + 12'd1;
        end
        else begin
          state <= NONE;
          cnt <= 12'd0;
        end
      end
      DATA: begin
        data[cnt-12'd8] <= phy_rx_data;
        cnt <= cnt + 12'd1;
      end
    endcase
    if (cnt == 12'd1400) begin
      state <= NONE;
      cnt <= 12'd0;
    end
  end
end

assign out = data[address];

endmodule
