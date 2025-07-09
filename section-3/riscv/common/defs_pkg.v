`default_nettype none `timescale 1ns / 1ns

package defs_pkg;

  localparam logic [3:0]
  NOP  = 4'b0000,
  ADD  = 4'b0001,
  SUB  = 4'b0010,
  AND  = 4'b0011,
  OR   = 4'b0100,
  XOR  = 4'b0101,
  SLL  = 4'b0110,
  SRL  = 4'b0111,
  SRA  = 4'b1000,
  SLT  = 4'b1001,
  SLTU = 4'b1010;

  localparam logic [6:0] LUI = 7'b0110111, AUIPC = 7'b0010111;

  localparam logic [2:0] BEQ = 3'h0, BNE = 3'h1, BLT = 3'h4, BGE = 3'h5, BLTU = 3'h6, BGEU = 3'h7;

  localparam logic [6:0] R = 7'b0110011, I = 7'b0010011, J = 7'b1101111, jalrI = 7'b1100111;

endpackage
