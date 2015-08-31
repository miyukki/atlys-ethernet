`timescale 1ns / 1ps

module ether_udp_demo_rx #(
  parameter BASE_MAC_ADDR = { 8'h00, 8'h30, 8'h1b, 8'ha0, 8'ha4, 8'h70 },
  parameter BASE_IP_ADDR  = { 8'd172, 8'd16, 8'd0, 8'd100 },
  parameter UDP_PORT      = 16'd8888
) (
  input  wire       id,
  input  wire       rst,
  input  wire       phy_rx_clk,
  input  wire       phy_rx_dv,
  input  wire [7:0] phy_rx_data,
  output reg  [6:0] data_out
);

initial data_out = 7'b0101010;

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

reg [47:0] src_mac = 48'b0;

always @(posedge rst or posedge phy_rx_clk) begin
  if (rst) begin
    cnt   <= 12'd0;
    state <= 2'h0;
    src_mac <= 48'b0;
  end
  else begin
    if (phy_rx_dv) begin
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
    end
    else begin
      state <= NONE;
      cnt <= 12'd0;
      src_mac <= { data[6], data[7], data[8], data[9], data[10], data[11] };
      if (state == NONE) begin
        if (src_mac == { BASE_MAC_ADDR[47:1], ~id }) begin
          data_out <= data[42][6:0];
        end
      end
    end
  end
end

endmodule
