`default_nettype none `timescale 1ns / 1ns

// Register File

module regfile #(
) (
    input logic clk,
    input logic resetn,
    input logic rs1,
    input logic rs2
);

  // Init a reg that always returns 0 and 31 other regs as an intermediate scratchpad

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin

    end
  end

  always_comb begin

  end

endmodule
