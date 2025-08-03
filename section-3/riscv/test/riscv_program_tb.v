`default_nettype none `timescale 1ns / 1ns

module riscv_program_tb ();

  logic clk, resetn;

  // verilator lint_off BLKSEQ
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ

  initial begin
    $display("=== Starting RISC-V Program Test ===");

    clk    = 0;
    resetn = 1;
    load_program();

    $display("Resetting processor...");
    #20 resetn = 0;
    #20 resetn = 1;
    $display("Reset done, starting execution...");

    // Monitor execution
    monitor_execution();

    $display("\n=== Simulation completed - inspect registers above ===");
    $display("=== Use $finish in your simulator to exit ===");
  end

  // Task to load a comprehensive test program
  task automatic load_program();
    logic [31:0] base_addr;
    base_addr = 32'h00001000 >> 3; // Use address 0x1000, convert to memory array index (8-byte aligned)

    $display("Loading test program at base address index: %d (0x%08h)", base_addr, 32'h00001000);

    // Program: Test basic arithmetic and control flow
    // 0x00001000: ADDI x1, x0, 10    # x1 = 10
    // 0x00001004: ADDI x2, x0, 20    # x2 = 20
    // 0x00001008: ADD  x3, x1, x2    # x3 = x1 + x2 = 30
    // 0x0000100C: SUB  x4, x2, x1    # x4 = x2 - x1 = 10
    // 0x00001010: BEQ  x1, x1, +8    # Branch taken (x1 == x1)
    // 0x00001014: ADDI x5, x0, 99    # Should be skipped
    // 0x00001018: ADDI x6, x0, 42    # x6 = 42 (branch target)
    // 0x0000101C: JAL  x7, +8        # Jump and link
    // 0x00001020: ADDI x8, x0, 88    # Should be skipped
    // 0x00001024: ADDI x9, x0, 77    # x9 = 77 (jump target)
    // 0x00001028: EBREAK             # Breakpoint to stop

    // Load instructions (little endian format for 64-bit memory)
    riscv_a.memory_controller_inst.main_memory.mem[base_addr + 0] = {32'h01400113, 32'h00a00093}; // ADDI x2,20 | ADDI x1,10
    riscv_a.memory_controller_inst.main_memory.mem[base_addr + 1] = {32'h40110233, 32'h002081b3}; // SUB x4,x2,x1 | ADD x3,x1,x2
    riscv_a.memory_controller_inst.main_memory.mem[base_addr + 2] = {32'h06300293, 32'h00108463}; // ADDI x5,99 | BEQ x1,x1,+8
    riscv_a.memory_controller_inst.main_memory.mem[base_addr + 3] = {32'h008003ef, 32'h02a00313}; // JAL x7,+8 | ADDI x6,42
    riscv_a.memory_controller_inst.main_memory.mem[base_addr + 4] = {32'h04d00493, 32'h05800413}; // ADDI x9,77 | ADDI x8,88
    riscv_a.memory_controller_inst.main_memory.mem[base_addr + 5] = {32'h00000013, 32'h00100073}; // NOP | EBREAK

    $display("Program loaded:");
    $display("  0x00001000: ADDI x1, x0, 10    # x1 = 10");
    $display("  0x00001004: ADDI x2, x0, 20    # x2 = 20");
    $display("  0x00001008: ADD  x3, x1, x2    # x3 = 30");
    $display("  0x0000100C: SUB  x4, x2, x1    # x4 = 10");
    $display("  0x00001010: BEQ  x1, x1, +8    # Branch taken");
    $display("  0x00001014: ADDI x5, x0, 99    # Skipped");
    $display("  0x00001018: ADDI x6, x0, 42    # x6 = 42");
    $display("  0x0000101C: JAL  x7, +8        # Jump to 0x00001024");
    $display("  0x00001020: ADDI x8, x0, 88    # Skipped");
    $display("  0x00001024: ADDI x9, x0, 77    # x9 = 77");
    $display("  0x00001028: EBREAK             # Stop");
  endtask

  // Monitor execution and register file
  task automatic monitor_execution();
    integer cycle = 0;
    logic [63:0] prev_pc = 64'h0;

    forever begin
      @(posedge clk);
      cycle = cycle + 1;

      // Display PC changes and instruction fetch
      if (riscv_a.pc !== prev_pc || cycle <= 10) begin
        $display("Cycle %4d: PC=0x%08h, Instr=0x%08h, pc[2]=%b, ifetch_pc=0x%08h, ifetch_pc[2]=%b",
                 cycle, riscv_a.pc, riscv_a.if_instruction, riscv_a.pc[2],
                 riscv_a.ifetch_inst.pc_current_r, riscv_a.ifetch_inst.pc_current_r[2]);
        $display("          ifetch_state=%s, pc_valid=%b, stall=%b, flush=%b, imem_req=%b",
                 riscv_a.ifetch_inst.state.name(), riscv_a.pc_valid, riscv_a.pipeline_stall,
                 riscv_a.pipeline_flush, riscv_a.imem_req);
        $display("          pc_next=0x%08h, next_pc_current=0x%08h, next_imem_addr=0x%08h",
                 riscv_a.ifetch_inst.pc_next, riscv_a.ifetch_inst.next_pc_current_r,
                 riscv_a.ifetch_inst.next_imem_addr_r);
        if (riscv_a.pc !== prev_pc) prev_pc = riscv_a.pc;
      end

      // Display register writes with detailed debug info
      if (riscv_a.regfile_we && riscv_a.regfile_rd != 0) begin
        $display("          -> x%0d = 0x%016h (%0d) [WB: rd=%d, data=0x%016h, we=%b]",
                 riscv_a.regfile_rd, riscv_a.regfile_wd, riscv_a.regfile_wd,
                 riscv_a.mem_rd_out, riscv_a.mem_writeback_data, riscv_a.mem_reg_write_enable_out);
        $display("          -> Instruction at PC=0x%08h: 0x%08h, opcode=0x%02h, rd=%d, rs1=%d, rs2=%d",
                 riscv_a.id_pc_out, riscv_a.if_instruction,
                 riscv_a.id_opcode, riscv_a.id_rd, riscv_a.id_rs1, riscv_a.id_rs2);
      end

      // Display branch/jump taken
      if (riscv_a.branch_taken) begin
        $display("          -> Branch taken to 0x%08h", riscv_a.branch_target);
      end

      if (riscv_a.jump_taken) begin
        $display("          -> Jump taken to 0x%08h", riscv_a.jump_target);
      end

      // Stop on EBREAK or after too many cycles
      if (cycle > 200) begin
        $display("ERROR: Simulation timeout after %0d cycles", cycle);
        $display("\n=== Final Register State ===");
        display_registers();
        $finish;
      end

      // Check for EBREAK (trap)
      if (riscv_a.id_trap && riscv_a.id_trap_cause == 4'd3) begin
        $display("EBREAK encountered - stopping simulation");
        $display("\n=== Final Register State ===");
        display_registers();
        $display("\n=== Test completed - use $finish to exit ===");
        break;
      end
    end
  endtask

  // Display register file contents
  task automatic display_registers();
    $display("x0 = 0x%016h  x1 = 0x%016h  x2 = 0x%016h  x3 = 0x%016h",
             64'h0, riscv_a.regfile_inst.registers[1],
             riscv_a.regfile_inst.registers[2], riscv_a.regfile_inst.registers[3]);
    $display("x4 = 0x%016h  x5 = 0x%016h  x6 = 0x%016h  x7 = 0x%016h",
             riscv_a.regfile_inst.registers[4], riscv_a.regfile_inst.registers[5],
             riscv_a.regfile_inst.registers[6], riscv_a.regfile_inst.registers[7]);
    $display("x8 = 0x%016h  x9 = 0x%016h",
             riscv_a.regfile_inst.registers[8], riscv_a.regfile_inst.registers[9]);
  endtask

  riscv #(
      .XLEN(64),
      .RESETVEC(64'h00001000)  // Set reset vector to our program location
  ) riscv_a (
      .clk,
      .resetn
  );

endmodule
