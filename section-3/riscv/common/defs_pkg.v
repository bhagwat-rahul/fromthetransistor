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

  localparam logic [2:0] BEQ = 3'h0, BNE = 3'h1, BLT = 3'h4, BGE = 3'h5, BLTU = 3'h6, BGEU = 3'h7;

  localparam logic [6:0]
  R     = 7'b0110011,
  I     = 7'b0010011,
  J     = 7'b1101111,
  JALRI = 7'b1100111,
  LUI   = 7'b0110111,
  AUIPC = 7'b0010111;

  localparam logic [2:0]
  CSRRW  = 3'b001,
  CSRRS  = 3'b010,
  CSRRC  = 3'b011,
  CSRRWI = 3'b101,
  CSRRSI = 3'b110,
  CSRRCI = 3'b111;

  localparam logic[2:0]
  BYTE   = 3'd0,
  HALF   = 3'd1,
  WORD   = 3'd2,
  DOUBLE = 3'd3;

endpackage
