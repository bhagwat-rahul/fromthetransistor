`default_nettype none `timescale 1ns / 1ns

module riscv_program_tb ();

  logic clk, resetn;

  // verilator lint_off BLKSEQ
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  initial begin
    $monitor("Time: %0t | PC: 0x%08h | Instruction: 0x%08h",
             $time, riscv_a.pc, riscv_a.if_instruction);

    clk    = 0;
    resetn = 1;
    load_program();
    $display("=== Starting RISC-V Program Test ===");
    #20 resetn = 0;
    $display("Resetting processor...");
    #20 resetn = 1;
    $display("Reset done, starting execution...");

    #100 $finish;
  end

  // Task to load a simple test program
  // TODO: Make this more legit
  task automatic load_program();
    // Machine code (little endian):
    riscv_a.memory_controller_inst.main_memory.mem[0] = {32'h00a00093, 32'h00000013};
    riscv_a.memory_controller_inst.main_memory.mem[1] = {32'h002081b3, 32'h01400113};
    riscv_a.memory_controller_inst.main_memory.mem[2] = {32'h00000013, 32'h00100073};
    $display("Program loaded into memory at 0x80000000");
  endtask

  riscv #(
      .XLEN(64)
  ) riscv_a (
      .clk,
      .resetn
  );

endmodule
