`default_nettype none `timescale 1ns / 1ns

module uart_testbench (
    input clk,
    reset
);
  always @(posedge clk) begin
    if (reset) begin

    end
  end
endmodule
