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
  task automatic load_program();
    // Simple program: Add two numbers and store result
    // Assembly:
    //   addi x1, x0, 10    # x1 = 10
    //   addi x2, x0, 20    # x2 = 20
    //   add  x3, x1, x2    # x3 = x1 + x2 = 30
    //   sw   x3, 0(x0)     # store x3 to address 0
    //   addi x4, x0, 1     # x4 = 1 (exit code)
    //   ebreak             # breakpoint/end

    // Machine code (little endian):
    riscv_a.memory_controller_inst.main_memory.mem[32'h8000_0000 >> 3] = 64'h0014009300A00093; // addi x1,x0,10 | addi x2,x0,20
    riscv_a.memory_controller_inst.main_memory.mem[32'h8000_0008 >> 3] = 64'h0020023300210133; // sw x3,0(x0) | add x3,x1,x2
    riscv_a.memory_controller_inst.main_memory.mem[32'h8000_0010 >> 3] = 64'h0010020010006213; // ebreak | addi x4,x0,1

    $display("Program loaded into memory at 0x80000000");
  endtask

  riscv #(
      .XLEN(64)
  ) riscv_a (
      .clk,
      .resetn
  );

endmodule
