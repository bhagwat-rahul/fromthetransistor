`default_nettype none `timescale 1ns / 1ns

module riscv_tb ();

  logic clk, resetn;

  always #5 clk = ~clk;  // 100 MHz

  initial begin
    clk    = 0;
    resetn = 1;
    $monitor("Program at: %0h Next is : %0h", riscv_a.pc, riscv_a.next_pc);
    #20 resetn = 0;
    $display("resetting");
    #100 resetn = 1;
    $display("reset done");
    #6000 $finish;
  end

  riscv #(
      .RESETVEC(64'h8000_0000)
  ) riscv_a (
      .clk,
      .resetn
  );

endmodule
