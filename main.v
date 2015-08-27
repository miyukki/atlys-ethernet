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
  /*output wire ETH_RST,
  output wire ETH_MDC_PAD_O,
  input  wire ETH_MD_PAD_IO,*/
  // input  wire ETH_COL,
  // input  wire ETH_CRS,

  /*output wire       ETH_TX_CLK,
  output wire       ETH_TX_ER,
  output wire       ETH_TX_EN,
  output wire [7:0] ETH_TX_DATA,

  input  wire       ETH_RX_CLK,
  input  wire       ETH_RX_ER,
  input  wire       ETH_RX_DV,*/
  input  wire [7:0] ETH_RX_DATA,

  // Debug
  /*input  wire       SW,*/
  output reg  [7:0] LED
);

// Clock generator
wire CLK_125M, pll_locked, pll_clk_bufin, pll_clk_bufout;
wire clk_0, clk_unused_1, clk_unused_2, clk_unused_3, clk_unused_4, clk_unused_5;

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
  .CLKOUT0               (clk_0),
  .CLKOUT1               (clk_unused_1),
  .CLKOUT2               (clk_unused_2),
  .CLKOUT3               (clk_unused_3),
  .CLKOUT4               (clk_unused_4),
  .CLKOUT5               (clk_unused_5),
  // Status and control signals
  .LOCKED                (pll_locked),
  .RST                   (RST),
   // Input clock control
  .CLKFBIN               (pll_clk_bufin),
  .CLKIN                 (CLK_100M)
);

BUFG clkfbin_bufg (
  .I(pll_clk_bufout),
  .O(pll_clk_bufin)
);

BUFG clkout0_bufg (
  .I(clk_0),
  .O(CLK_125M)
);

// Ethernet
/*reg [7:0] state;*/
/*wire LED */
/*assign LED = state;*/
/*assign ETH_RST = RST;*/

always @(posedge RST or posedge CLK_125M) begin
  if (RST) begin
    LED <= FALSE;
  end
  else begin
    LED <= ETH_RX_DATA;
  end
end

endmodule
