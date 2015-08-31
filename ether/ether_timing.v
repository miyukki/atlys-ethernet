`timescale 1ns / 1ps

module ether_timing (
  input  wire rst,
  input  wire clk_100,
  output wire phy_rst,
  output wire phy_clk,
  output wire clk_125
);

/*------------------------------------------*
 * Clock                                    *
 *------------------------------------------*/

wire pll_clk, pll_locked, pll_clk_bufin, pll_clk_bufout;

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
  .RST                   (rst),
  .CLKFBIN               (pll_clk_bufin),
  .CLKIN                 (clk_100)
);

BUFG clkfbin_bufg (
  .I(pll_clk_bufout),
  .O(pll_clk_bufin)
);

BUFG clkout0_bufg (
  .I(pll_clk),
  .O(clk_125)
);

assign phy_clk = clk_125;

/*------------------------------------------*
 * Cold start                               *
 *------------------------------------------*/

reg  [20:0] coldsys_cnt = 21'd0;
wire        coldsys_rst = (coldsys_cnt == 21'd10000);
assign      phy_rst     = coldsys_rst;

always @(posedge rst or posedge clk_100) begin
  if (rst) begin
    coldsys_cnt <= 21'd0;
  end
  else begin
    coldsys_cnt <= coldsys_rst ? 21'd10000 : coldsys_cnt + 21'd1;
  end
end

endmodule
