`timescale 1ns / 1ns

module writeback_tb #(
    parameter logic [8:0] XLEN = 9'd64
) ();

  logic clk, resetn;

  writeback #(
      .XLEN(XLEN)
  ) writeback_a (
      .clk,
      .resetn
  );
endmodule
