`default_nettype none `timescale 1ns / 1ns

module riscv (
    input clk,
    input reset
);

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Do reset things (init counters and load bootrom?)
    end else begin

    end
  end

  always_comb begin

  end

endmodule
