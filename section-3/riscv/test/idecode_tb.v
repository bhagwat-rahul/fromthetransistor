`default_nettype none `timescale 1ns / 1ns

module idecode_tb #(
    parameter int unsigned XLEN = 64
) ();

  logic clk, resetn;

  logic [6:0] opcode;
  logic [4:0] rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [XLEN-1:0] imm, pc;
  logic [3:0] alu_op;
  logic [31:0] instr, regfile_rs1, regfile_rs2;
  logic reg_write_enable, mem_read, mem_write, is_branch, jump;
  logic flush, stall;

  always #5 clk = ~clk;

  initial begin
    clk    = 0;
    resetn = 0;
    flush = 0;
    stall = 0;
    pc = 64'h80000;
    #50 resetn = 1;
    $display("Reset done!");
    #200 $finish;
  end

  idecode #(
      .XLEN(9'd64)
  ) idecode_a (
      .clk,
      .resetn,
      .flush,
      .stall,
      .pc,
      .instr,
      .regfile_rs1,
      .regfile_rs2,

      .opcode,
      .rd,
      .rs1,
      .rs2,
      .funct3,
      .funct7,
      .imm,
      .alu_op,
      .reg_write_enable,
      .mem_read,
      .mem_write,
      .is_branch,
      .jump
  );

endmodule
