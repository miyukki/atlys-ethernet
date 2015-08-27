`timescale 1ns / 1ps

module ether_sample_packet_tx # (
  parameter TRUE  = 1'b1,
  parameter FALSE = 1'b0
) (
  input  wire       trig,
  input  wire       rst,
  input  wire       clk_125,
  input  wire       clk_100,
  output wire       phy_clk,
  output wire       phy_rst,
  output reg        phy_er,
  output reg        phy_en,
  output reg  [7:0] phy_data
);

initial phy_er   = 1'b0;
initial phy_en   = 1'b0;
initial phy_data = 8'b0;
assign  phy_clk  = clk_125;

/*------------------------------------------*
 * Timing ans cold start                    *
 *------------------------------------------*/

reg  [20:0] coldsys_cnt = 21'd0;
wire        coldsys_rst = (coldsys_cnt == 21'h100000);
assign      phy_rst     = coldsys_rst;

always @(posedge rst or posedge clk_100) begin
  if (rst) begin
    coldsys_cnt <= 21'd0;
  end
  else begin
    coldsys_cnt <= coldsys_rst ? 21'h100000 : coldsys_cnt + 21'h1;
  end
end

/*------------------------------------------*
 * CRC Calculate                            *
 *------------------------------------------*/

reg           crc_en;
wire   [31:0] crc_out;
assign        crc_clear = (cnt == 12'h08);

crc crc_calc (
  .clk(clk_125),
  .reset(rst),
  .clear(crc_clear),
  .data(phy_data),
  .calc(crc_en),
  .crc_out(crc_out)
);

/*------------------------------------------*
 * Transmit sample packet                   *
 *------------------------------------------*/

reg [11:0] cnt = 12'b0;
always @(posedge trig or posedge clk_125) begin
  if (trig) begin
    phy_en      <= 1'b0;
    phy_data    <= 8'b0;
    crc_en      <= 1'b0;
    cnt         <= 12'd0;
  end
  else begin
    case (cnt)
      12'h00: begin
        phy_en   <= 1'b1;
        phy_data <= 8'h55;
      end
      12'h01: phy_data <= 8'h55;	// Preamble
      12'h02: phy_data <= 8'h55;
      12'h03: phy_data <= 8'h55;
      12'h04: phy_data <= 8'h55;
      12'h05: phy_data <= 8'h55;
      12'h06: phy_data <= 8'h55;
      12'h07: phy_data <= 8'hd5;	// Preable + Start Frame Delimiter
      12'h08: phy_data <= 8'hff;	// Destination MAC address = FF-FF-FF-FF-FF-FF-FF
      12'h09: phy_data <= 8'hff;
      12'h0a: phy_data <= 8'hff;
      12'h0b: phy_data <= 8'hff;
      12'h0c: phy_data <= 8'hff;
      12'h0d: phy_data <= 8'hff;
      12'h0e: phy_data <= 8'h00;	// Source MAC address = 00-30-1b-a0-a4-8e
      12'h0f: phy_data <= 8'h30;
      12'h10: phy_data <= 8'h1b;
      12'h11: phy_data <= 8'ha0;
      12'h12: phy_data <= 8'ha4;
      12'h13: phy_data <= 8'h8e;
      12'h14: phy_data <= 8'h08;	// Protocol Type = ARP (0x0806)
      12'h15: phy_data <= 8'h06;
      12'h16: phy_data <= 8'h00;	// Harware Type = Ethernet (1)
      12'h17: phy_data <= 8'h01;
      12'h18: phy_data <= 8'h08;	// Protocol Type = IP (0x0800)
      12'h19: phy_data <= 8'h00;
      12'h1a: phy_data <= 8'h06;	// Hardware size = 6
      12'h1b: phy_data <= 8'h04;	// Protocol size = 4
      12'h1c: phy_data <= 8'h00;	// Opcode = request (1)
      12'h1d: phy_data <= 8'h01;
      12'h1e: phy_data <= 8'h00;	// Sender MAC address = 00-30-1b-a0-a4-8e
      12'h1f: phy_data <= 8'h30;
      12'h20: phy_data <= 8'h1b;
      12'h21: phy_data <= 8'ha0;
      12'h22: phy_data <= 8'ha4;
      12'h23: phy_data <= 8'h8e;
      12'h24: phy_data <= 8'd10;	// Sender IP address = 10.0.21.10
      12'h25: phy_data <= 8'd0;
      12'h26: phy_data <= 8'd21;
      12'h27: phy_data <= 8'd10;
      12'h28: phy_data <= 8'h00;	// Target MAC address = 00-00-00-00-00-00
      12'h29: phy_data <= 8'h00;
      12'h2a: phy_data <= 8'h00;
      12'h2b: phy_data <= 8'h00;
      12'h2c: phy_data <= 8'h00;
      12'h2d: phy_data <= 8'h00;
      12'h2e: phy_data <= 8'd10;	// Target IP address = 10.0.21.99
      12'h2f: phy_data <= 8'd0;
      12'h30: phy_data <= 8'd21;
      12'h31: phy_data <= 8'd99;
      12'h32: phy_data <= 8'h00;	// Padding Area
      12'h33: phy_data <= 8'h00;
      12'h34: phy_data <= 8'h00;
      12'h35: phy_data <= 8'h00;
      12'h36: phy_data <= 8'h00;
      12'h37: phy_data <= 8'h00;
      12'h38: phy_data <= 8'h00;
      12'h39: phy_data <= 8'h00;
      12'h3a: phy_data <= 8'h00;
      12'h3b: phy_data <= 8'h00;
      12'h3c: phy_data <= 8'h00;
      12'h3d: phy_data <= 8'h00;
      12'h3e: phy_data <= 8'h00;
      12'h3f: phy_data <= 8'h00;
      12'h40: phy_data <= 8'h00;
      12'h41: phy_data <= 8'h00;
      12'h42: phy_data <= 8'h00;
      12'h43: phy_data <= 8'h00;
      12'h44: begin
        phy_data <= crc_out[31:24];
        crc_en   <= 1'b1;
      end
      12'h45: phy_data <= crc_out[23:16];
      12'h46: phy_data <= crc_out[15:8];
      12'h47: phy_data <= crc_out[7:0];
      12'h48: begin
        phy_en   <= 1'b0;
        phy_data <= 8'h00;
        crc_en   <= 1'b0;
      end
      default: phy_data <= 8'h0;
    endcase
    cnt <= cnt + 12'd1;
  end
end

endmodule
