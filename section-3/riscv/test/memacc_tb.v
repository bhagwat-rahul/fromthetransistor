`default_nettype none  `timescale 1ns / 1ns

module memacc_tb #(
    parameter logic [8:0] XLEN = 9'd64
) ();

  logic clk, resetn;
  logic stall;
  logic flush;
  logic [XLEN-1:0] alu_result;
  logic [XLEN-1:0] rs2_data;
  logic [XLEN-1:0] pc_in;
  logic [     4:0] rd;
  logic [     2:0] funct3;
  logic            reg_write_enable;
  logic            mem_read;
  logic            mem_write;
  logic [     3:0] trap_cause_in;
  logic            trap_in;
  logic [    11:0] csr_addr;
  logic [XLEN-1:0] csr_wdata;
  logic            csr_read;
  logic            csr_write;
  logic [XLEN-1:0] mem_addr;
  logic [XLEN-1:0] mem_wdata;
  logic            mem_read_req;
  logic            mem_write_req;
  logic [     2:0] mem_size; // 0=byte, 1=half, 2=word, 3=double
  logic            mem_signed;
  logic [XLEN-1:0] mem_rdata;
  logic            mem_ready;
  logic            mem_error;
  logic            mem_stall;
  logic [     4:0] rd_out;
  logic            reg_write_enable_out;
  logic [XLEN-1:0] writeback_data;
  logic [XLEN-1:0] pc_out;
  logic            exception_occurred;
  logic [XLEN-1:0] exception_pc;
  logic [     3:0] exception_cause;
  logic [    11:0] csr_addr_out;
  logic [XLEN-1:0] csr_wdata_out;
  logic            csr_write_out;

  memacc #(
    .XLEN(9'd64)
  ) memacc1 (
      .clk,
      .resetn,
      .stall,
      .flush,
      .alu_result,
      .rs2_data,
      .pc_in,
      .rd,
      .funct3,
      .reg_write_enable,
      .mem_read,
      .mem_write,
      .trap_cause_in,
      .trap_in,
      .csr_addr,
      .csr_wdata,
      .csr_write,
      .mem_addr,
      .mem_wdata,
      .mem_read_req,
      .mem_write_req,
      .mem_size,
      .mem_signed,
      .mem_rdata,
      .mem_ready,
      .mem_error,
      .mem_stall,
      .rd_out,
      .reg_write_enable_out,
      .writeback_data,
      .pc_out,
      .exception_occurred,
      .exception_pc,
      .exception_cause,
      .csr_addr_out,
      .csr_wdata_out,
      .csr_write_out
  );

  // verilator lint_off BLKSEQ
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  initial begin
    clk = 0;
    resetn = 0;
    #50
    resetn = 1;
    $display("reset asserted");
    $finish;
  end

endmodule
