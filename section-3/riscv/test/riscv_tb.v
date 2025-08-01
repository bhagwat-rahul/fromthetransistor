`default_nettype none `timescale 1ns / 1ns

module riscv_tb ();

  logic clk, resetn;

  // verilator lint_off BLKSEQ
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ


  initial begin
    clk    = 0;
    resetn = 1;
    $monitor("Program at: %0h Next is : %0h", riscv_a.pc, riscv_a.next_pc);
    #20 resetn = 0;
    $display("resetting");
    #100 resetn = 1;
    $display("reset done");
    #1000 $finish;
  end

  riscv #(
      .XLEN(64)
  ) riscv_a (
      .clk,
      .resetn
  );

endmodule
