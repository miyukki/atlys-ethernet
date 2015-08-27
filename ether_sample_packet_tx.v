`timescale 1ns / 1ps

module ether_sample_packet_tx # (
  parameter TRUE  = 1'b1,
  parameter FALSE = 1'b0
) (
  input  wire       rst,
  input  wire       clk,
  output reg        er,
  output reg        en,
  output reg  [7:0] data
);

initial er   = 1'b0;
initial en   = 1'b0;
initial data = 8'b0;

reg [11:0] cnt = 12'b0;

always @(posedge rst or posedge clk) begin
  if (rst) begin
   en   <= 1'b0;
   data <= 8'b0;
   cnt  <= 12'd0;
  end
  else begin
    case (cnt)
      12'h00: begin
        en   <= 1'b1;
        data <= 8'h55;
      end
      12'h01: data <= 8'h55;	// Preamble
      12'h02: data <= 8'h55;
      12'h03: data <= 8'h55;
      12'h04: data <= 8'h55;
      12'h05: data <= 8'h55;
      12'h06: data <= 8'h55;
      12'h07: data <= 8'hd5;	// Preable + Start Frame Delimiter
      12'h08: data <= 8'hff;	// Destination MAC address = FF-FF-FF-FF-FF-FF-FF
      12'h09: data <= 8'hff;
      12'h0a: data <= 8'hff;
      12'h0b: data <= 8'hff;
      12'h0c: data <= 8'hff;
      12'h0d: data <= 8'hff;
      12'h0e: data <= 8'h00;	// Source MAC address = 00-30-1b-a0-a4-8e
      12'h0f: data <= 8'h30;
      12'h10: data <= 8'h1b;
      12'h11: data <= 8'ha0;
      12'h12: data <= 8'ha4;
      12'h13: data <= 8'h8e;
      12'h14: data <= 8'h08;	// Protocol Type = ARP (0x0806)
      12'h15: data <= 8'h06;
      12'h16: data <= 8'h00;	// Harware Type = Ethernet (1)
      12'h17: data <= 8'h01;
      12'h18: data <= 8'h08;	// Protocol Type = IP (0x0800)
      12'h19: data <= 8'h00;
      12'h1a: data <= 8'h06;	// Hardware size = 6
      12'h1b: data <= 8'h04;	// Protocol size = 4
      12'h1c: data <= 8'h00;	// Opcode = request (1)
      12'h1d: data <= 8'h01;
      12'h1e: data <= 8'h00;	// Sender MAC address = 00-30-1b-a0-a4-8e
      12'h1f: data <= 8'h30;
      12'h20: data <= 8'h1b;
      12'h21: data <= 8'ha0;
      12'h22: data <= 8'ha4;
      12'h23: data <= 8'h8e;
      12'h24: data <= 8'd10;	// Sender IP address = 10.0.21.10
      12'h25: data <= 8'd0;
      12'h26: data <= 8'd21;
      12'h27: data <= 8'd10;
      12'h28: data <= 8'h00;	// Target MAC address = 00-00-00-00-00-00
      12'h29: data <= 8'h00;
      12'h2a: data <= 8'h00;
      12'h2b: data <= 8'h00;
      12'h2c: data <= 8'h00;
      12'h2d: data <= 8'h00;
      12'h2e: data <= 8'd10;	// Target IP address = 10.0.21.99
      12'h2f: data <= 8'd0;
      12'h30: data <= 8'd21;
      12'h31: data <= 8'd99;
      12'h32: data <= 8'h00;	// Padding Area
      12'h33: data <= 8'h00;
      12'h34: data <= 8'h00;
      12'h35: data <= 8'h00;
      12'h36: data <= 8'h00;
      12'h37: data <= 8'h00;
      12'h38: data <= 8'h00;
      12'h39: data <= 8'h00;
      12'h3a: data <= 8'h00;
      12'h3b: data <= 8'h00;
      12'h3c: data <= 8'h00;
      12'h3d: data <= 8'h00;
      12'h3e: data <= 8'h00;
      12'h3f: data <= 8'h00;
      12'h40: data <= 8'h00;
      12'h41: data <= 8'h00;
      12'h42: data <= 8'h00;
      12'h43: data <= 8'h00;
      12'h44: data <= 8'h00;	// Frame Check Sequence = 0x00000000
      12'h45: data <= 8'h00;
      12'h46: data <= 8'h00;
      12'h47: data <= 8'h00;
      12'h48: begin
        en   <= 1'b0;
        data <= 8'h00;
      end
      default: data <= 8'h0;
    endcase
  end
end

endmodule
