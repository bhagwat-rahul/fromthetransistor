`timescale 1ns / 1ns

module writeback_tb #(
    parameter logic [8:0] XLEN = 9'd64
) ();

  logic clk, resetn;
  logic             stall;
  logic             flush;
  logic [     4:0]  rd_in;
  logic             reg_write_enable_in;
  logic [XLEN-1:0]  writeback_data_in;
  logic             exception_occurred_in;
  logic [XLEN-1:0]  exception_pc_in;
  logic [     3:0]  exception_cause_in;

  logic [     4:0] regfile_rd;
  logic [XLEN-1:0] regfile_wd;
  logic            regfile_we;
  logic            exception_out;
  logic [XLEN-1:0] exception_pc_out;
  logic [     3:0] exception_cause_out;

  writeback #(
      .XLEN(XLEN)
  ) writeback_a (
      .clk,
      .resetn,
      .stall,
      .flush,
      .rd_in,
      .reg_write_enable_in,
      .writeback_data_in,
      .exception_occurred_in,
      .exception_pc_in,
      .exception_cause_in,
      .regfile_rd,
      .regfile_wd,
      .regfile_we,
      .exception_out,
      .exception_pc_out,
      .exception_cause_out
  );

  /* verilator lint_off BLKSEQ */
  always #5 clk = ~clk;
  /* verilator lint_on BLKSEQ */

  initial begin
    clk    = 0;
    resetn = 0;
    #50
    resetn = 1;
    $display("reset asserted");
    $finish;
  end

endmodule
