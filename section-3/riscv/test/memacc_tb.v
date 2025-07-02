`timescale 1ns / 1ns

module memacc_tb #(
    parameter logic [8:0] XLEN = 9'd64
) ();

  logic clk, resetn;

  memacc #(
      .XLEN(XLEN)
  ) memacc_a (
      .clk,
      .resetn
  );

endmodule
