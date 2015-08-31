`timescale 1ns / 1ps
`define FALSE 1'b0
`define TRUE  1'b1

module ether_udp_demo_tx #(
  parameter BASE_MAC_ADDR = { 8'h00, 8'h30, 8'h1b, 8'ha0, 8'ha4, 8'h70 },
  parameter BASE_IP_ADDR  = { 8'd172, 8'd16, 8'd0, 8'd100 },
  parameter UDP_PORT      = 16'd8888
) (
  input  wire       id,
  input  wire       trig,
  input  wire       rst,
  input  wire       clk_125,
  input  wire       phy_tx_clk,
  output reg        phy_tx_er,
  output reg        phy_tx_en,
  output reg  [7:0] phy_tx_data,
  input  wire [6:0] data_in
);

initial phy_tx_er   = 1'b0;
initial phy_tx_en   = 1'b0;
initial phy_tx_data = 8'b0;

/*------------------------------------------*
 * Timing                                   *
 *------------------------------------------*/

reg  [20:0] interval_cnt = 21'd0;
wire        interval_clk = (interval_cnt == 21'd10000);

always @(posedge rst or posedge clk_125) begin
  if (rst) begin
    interval_cnt <= 21'd0;
  end
  else begin
    interval_cnt <= interval_cnt + 21'd1;
  end
end

/*------------------------------------------*
 * CRC Calculate                            *
 *------------------------------------------*/

reg           crc_en;
wire   [31:0] crc_out;
assign        crc_clear = (cnt == 12'd08);

crc crc_calc (
  .clk     (clk_125),
  .reset   (rst),
  .clear   (crc_clear),
  .data    (phy_tx_data),
  .calc    (crc_en),
  .crc_out (crc_out)
);

/*------------------------------------------*
 * Transmit sample packet                   *
 *------------------------------------------*/

reg [11:0] cnt = 12'b0;

always @ (posedge trig or posedge interval_clk or posedge clk_125) begin
  if (trig | interval_clk) begin
    phy_tx_en   <= `FALSE;
    phy_tx_data <= 8'b0;
    crc_en      <= `FALSE;
    cnt         <= 12'd0;
  end
  else begin
    case (cnt)
      12'd00: begin
        phy_tx_en   <= `TRUE;
        phy_tx_data <= 8'h55;
        crc_en      <= `TRUE;
      end
      // Ethernet
      12'd01: phy_tx_data <= 8'h55;  // Preamble
      12'd02: phy_tx_data <= 8'h55;
      12'd03: phy_tx_data <= 8'h55;
      12'd04: phy_tx_data <= 8'h55;
      12'd05: phy_tx_data <= 8'h55;
      12'd06: phy_tx_data <= 8'h55;
      12'd07: phy_tx_data <= 8'hd5;  // Preable + Start Frame Delimiter
      12'd08: phy_tx_data <= 8'hff;
      12'd09: phy_tx_data <= 8'hff;
      12'd10: phy_tx_data <= 8'hff;
      12'd11: phy_tx_data <= 8'hff;
      12'd12: phy_tx_data <= 8'hff;
      12'd13: phy_tx_data <= 8'hff;
      // 12'd08: phy_tx_data <= BASE_MAC_ADDR[47:40];  // Destination MAC address = FF-FF-FF-FF-FF-FF-FF
      // 12'd09: phy_tx_data <= BASE_MAC_ADDR[39:32];
      // 12'd10: phy_tx_data <= BASE_MAC_ADDR[31:24];
      // 12'd11: phy_tx_data <= BASE_MAC_ADDR[23:16];
      // 12'd12: phy_tx_data <= BASE_MAC_ADDR[15:8];
      // 12'd13: phy_tx_data <= BASE_MAC_ADDR[7:0] + ~id;
      12'd14: phy_tx_data <= BASE_MAC_ADDR[47:40];  // Source MAC address = 00-30-1b-a0-a4-8e
      12'd15: phy_tx_data <= BASE_MAC_ADDR[39:32];
      12'd16: phy_tx_data <= BASE_MAC_ADDR[31:24];
      12'd17: phy_tx_data <= BASE_MAC_ADDR[23:16];
      12'd18: phy_tx_data <= BASE_MAC_ADDR[15:8];
      12'd19: phy_tx_data <= { BASE_MAC_ADDR[7:1], id };
      12'd20: phy_tx_data <= 8'h08;  // Protocol Type = IP (0x0800)
      12'd21: phy_tx_data <= 8'h00;
      // IP
      12'd22: phy_tx_data <= 8'h45;  // Version & Header length
      12'd23: phy_tx_data <= 8'h00;  // Service type
      12'd24: phy_tx_data <= 8'h00;  // Length-A
      12'd25: phy_tx_data <= 8'd46;  // Length-B
      12'd26: phy_tx_data <= 8'h00;  // Identification-A
      12'd27: phy_tx_data <= 8'h00;  // Identification-B
      12'd28: phy_tx_data <= 8'h40;  // Flags & Fragment offset-A
      12'd29: phy_tx_data <= 8'h00;  // Flags & Fragment offset-B
      12'd30: phy_tx_data <= 8'h40;  // TTL
      12'd31: phy_tx_data <= 8'h11;  // Protocol (UDP)
      12'd32: phy_tx_data <= 8'h00;  // Checksum
      12'd33: phy_tx_data <= 8'h00;  // Checksum
      12'd34: phy_tx_data <= BASE_IP_ADDR[31:24];  // Sender IP address = 10.0.21.10
      12'd35: phy_tx_data <= BASE_IP_ADDR[23:16];
      12'd36: phy_tx_data <= BASE_IP_ADDR[15:8];
      12'd37: phy_tx_data <= { BASE_IP_ADDR[7:1], id };
      /*12'd38: phy_tx_data <= 8'd255;
      12'd39: phy_tx_data <= 8'd255;
      12'd40: phy_tx_data <= 8'd255;
      12'd41: phy_tx_data <= 8'd255;*/
      12'd38: phy_tx_data <= BASE_IP_ADDR[31:24];  // Target IP address = 10.0.21.99
      12'd39: phy_tx_data <= BASE_IP_ADDR[23:16];
      12'd40: phy_tx_data <= BASE_IP_ADDR[15:8];
      12'd41: phy_tx_data <= { BASE_IP_ADDR[7:1], ~id };
      // UDP
      12'd42: phy_tx_data <= UDP_PORT[15:8]; // Source port
      12'd43: phy_tx_data <= UDP_PORT[7:0];
      12'd44: phy_tx_data <= UDP_PORT[15:8]; // Dest port
      12'd45: phy_tx_data <= UDP_PORT[7:0];
      12'd46: phy_tx_data <= 8'h00; // Length
      12'd47: phy_tx_data <= 8'd26;
      12'd48: phy_tx_data <= 8'h00; // Checksum
      12'd49: phy_tx_data <= 8'h00;
      12'd50: phy_tx_data <= { 1'b0, data_in }; // Data
      12'd51: phy_tx_data <= 8'hdd;
      12'd52: phy_tx_data <= 8'hdd;
      12'd53: phy_tx_data <= 8'hdd;
      12'd54: phy_tx_data <= 8'hdd;
      12'd55: phy_tx_data <= 8'hdd;
      12'd56: phy_tx_data <= 8'hdd;
      12'd57: phy_tx_data <= 8'hdd;
      12'd58: phy_tx_data <= 8'hdd;
      12'd59: phy_tx_data <= 8'hdd;
      12'd60: phy_tx_data <= 8'hdd;
      12'd61: phy_tx_data <= 8'hdd;
      12'd62: phy_tx_data <= 8'hdd;
      12'd63: phy_tx_data <= 8'hdd;
      12'd64: phy_tx_data <= 8'hdd;
      12'd65: phy_tx_data <= 8'hdd;
      12'd66: phy_tx_data <= 8'hdd;
      12'd67: phy_tx_data <= 8'hdd;
      // Ethernet CRC
      12'd68: begin
        phy_tx_data <= crc_out[31:24];
        crc_en      <= `FALSE;
      end
      12'd69: phy_tx_data <= crc_out[23:16];
      12'd70: phy_tx_data <= crc_out[15:8];
      12'd71: phy_tx_data <= crc_out[7:0];
    endcase
    if (cnt == 12'd72) begin
      phy_tx_en <= `FALSE;
      phy_tx_data <= 8'h00;
    end
    else begin
      cnt <= cnt + 12'd1;
    end
  end
end

endmodule
