`timescale 1ns / 1ns

module exec_tb #(
    parameter logic [8:0] XLEN = 9'd64
) ();

  logic clk, resetn;
  // ins
  logic [6:0] opcode;
  logic [4:0] rd, rs1, rs2;
  logic [     2:0] funct3;
  logic [     6:0] funct7;
  logic [XLEN-1:0] imm;
  logic [XLEN-1:0] pc_in;
  logic [     3:0] alu_op;
  logic [     3:0] trap_cause_in;
  logic [    11:0] csr_addr;
  logic            is_csr;
  logic csr_read, csr_write;
  logic trap_in;
  logic reg_write_enable;
  logic mem_read, mem_write;
  logic is_branch;
  logic jump;
  logic use_pc;
  logic [XLEN-1:0] rs1_data, rs2_data;
  logic stall, flush;
  logic [XLEN-1:0] csr_rdata;
  // outs
  logic [11:0] csr_addr_out;
  logic [XLEN-1:0] csr_wdata;
  logic csr_read_out, csr_write_out;
  logic [XLEN-1:0] alu_result;
  logic [XLEN-1:0] rs2_data_out;
  logic [XLEN-1:0] pc_out;
  logic [     4:0] rd_out;
  logic [     2:0] funct3_out;
  logic            reg_write_enable_out;
  logic mem_read_out, mem_write_out;
  logic [     3:0] trap_cause_out;
  logic            trap_out;
  logic            branch_taken;
  logic [XLEN-1:0] branch_target;
  logic            jump_taken;
  logic [XLEN-1:0] jump_target;
  logic            exception_occurred;
  logic [XLEN-1:0] exception_pc;
  logic [     3:0] exception_cause;

  always #5 clk = ~clk;
  initial begin
    clk = 0;
    resetn = 0;
    #50 resetn = 1;
    $display("reset asserted");
    $finish();
  end
  exec #(
      .XLEN(XLEN)
  ) exec_a (
      .clk,
      .resetn,
      .opcode,
      .rd,
      .rs1,
      .rs2,
      .funct3,
      .funct7,
      .imm,
      .pc_in,
      .alu_op,
      .trap_cause_in,
      .csr_addr,
      .is_csr,
      .csr_read,
      .csr_write,
      .trap_in,
      .reg_write_enable,
      .mem_read,
      .mem_write,
      .is_branch,
      .jump,
      .use_pc,
      .rs1_data,
      .rs2_data,
      .stall,
      .flush,
      .csr_rdata,

      .csr_addr_out,
      .csr_wdata,
      .csr_read_out,
      .csr_write_out,
      .alu_result,
      .rs2_data_out,
      .pc_out,
      .rd_out,
      .funct3_out,
      .reg_write_enable_out,
      .mem_read_out,
      .mem_write_out,
      .trap_cause_out,
      .trap_out,
      .branch_taken,
      .branch_target,
      .jump_taken,
      .jump_target,
      .exception_occurred,
      .exception_pc,
      .exception_cause
  );

endmodule
