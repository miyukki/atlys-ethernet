`timescale 1ns / 1ps

module main #(
  parameter TRUE = 1'b1,
  parameter FALSE = 1'b0
) (
  // Reset
  input  wire RST,

  // Clock
  input  wire CLK_100M,

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
  output reg  [7:0] LED
);

// Clock generator
wire CLK_125M, pll_clk, pll_locked, pll_clk_bufin, pll_clk_bufout;

PLL_BASE #(
  .BANDWIDTH              ("OPTIMIZED"),
  .CLK_FEEDBACK           ("CLKFBOUT"),
  .COMPENSATION           ("SYSTEM_SYNCHRONOUS"),
  .DIVCLK_DIVIDE          (2),
  .CLKFBOUT_MULT          (15),
  .CLKFBOUT_PHASE         (0.000),
  .CLKOUT0_DIVIDE         (6),
  .CLKOUT0_PHASE          (0.000),
  .CLKOUT0_DUTY_CYCLE     (0.500),
  .CLKIN_PERIOD           (10.0),
  .REF_JITTER             (0.010))
pll_base_inst (
  .CLKFBOUT              (pll_clk_bufout),
  .CLKOUT0               (pll_clk),
  .LOCKED                (pll_locked),
  .RST                   (RST),
  .CLKFBIN               (pll_clk_bufin),
  .CLKIN                 (CLK_100M)
);

BUFG clkfbin_bufg (
  .I(pll_clk_bufout),
  .O(pll_clk_bufin)
);

BUFG clkout0_bufg (
  .I(pll_clk),
  .O(CLK_125M)
);

// Ethernet
reg [7:0] cnt = 8'b0;
assign ETH_RST = RST;
assign ETH_CLK = CLK_125M;

always @(posedge RST or posedge CLK_125M) begin
  if (RST) begin
    cnt <= 8'b0;
    LED <= 8'b0;
  end
  else begin
    cnt      <= cnt + 1;
    LED[6:0] <= ETH_RX_DATA[6:0];
    LED[7]   <= cnt[7];
  end
end

ether_sample_packet_tx sample_tx (
  .clk  (CLK_125M),
  .er   (ETH_TX_ER),
  .en   (ETH_TX_EN),
  .data (ETH_TX_DATA)
);

endmodule
