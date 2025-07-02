`timescale 1ns / 1ns

module exec_tb #(
    parameter logic [8:0] XLEN = 9'd64
) ();

  logic clk, resetn;
  logic [1:0] funct_3;
  logic [3:0] rs1_addr, rs2_addr, rd_addr;
  logic [5:0] opcode, funct_7;
  logic [31:0] instr;
  logic [XLEN-1:0] pc, imm;

  exec #(
      .XLEN(XLEN)
  ) exec_a (
      .clk,
      .resetn,
      .pc,
      .instr,
      .opcode,
      .funct_3,
      .funct_7,
      .imm,
      .rs1_addr,
      .rs2_addr,
      .rd_addr
  );
endmodule
