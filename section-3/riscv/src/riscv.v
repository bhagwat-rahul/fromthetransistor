`default_nettype none `timescale 1ns / 1ns

module riscv #(
    parameter logic [63:0] RESETVEC = 64'hx8000_0000
) (
    input clk,
    input resetn
);

  reg [63:0] pc, next_pc;

  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      pc <= RESETVEC;
    end else begin
      pc <= next_pc;
    end
  end

  always_comb begin
    next_pc = pc;  // stay the same if nothing
  end

endmodule
