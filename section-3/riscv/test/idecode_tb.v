`timescale 1ns / 1ns

module idecode_tb;

  // Parameters
  parameter logic [8:0] XLEN = 9'd64;

  // Testbench signals
  logic            clk;
  logic            resetn;
  logic            flush;
  logic            stall;
  logic [    31:0] instr;
  logic [XLEN-1:0] pc;
  logic [XLEN-1:0] regfile_rs1;
  logic [XLEN-1:0] regfile_rs2;

  // DUT outputs
  logic [     6:0] opcode;
  logic [     4:0] rd;
  logic [     4:0] rs1;
  logic [     4:0] rs2;
  logic [     2:0] funct3;
  logic [     6:0] funct7;
  logic [XLEN-1:0] imm;
  logic [XLEN-1:0] pc_out;
  logic [     3:0] alu_op;
  logic [     3:0] trap_cause;
  logic [    11:0] csr_addr;
  logic            is_csr;
  logic            csr_read;
  logic            csr_write;
  logic            trap;
  logic            reg_write_enable;
  logic            mem_read;
  logic            mem_write;
  logic            is_branch;
  logic            jump;
  logic            use_pc;

  // Test control variables
  int              test_count = 0;
  int              pass_count = 0;
  int              fail_count = 0;

  // DUT instantiation
  idecode #(
      .XLEN(XLEN)
  ) dut (
      .clk(clk),
      .resetn(resetn),
      .flush(flush),
      .stall(stall),
      .instr(instr),
      .pc(pc),
      .regfile_rs1(regfile_rs1),
      .regfile_rs2(regfile_rs2),
      .opcode(opcode),
      .rd(rd),
      .rs1(rs1),
      .rs2(rs2),
      .funct3(funct3),
      .funct7(funct7),
      .imm(imm),
      .pc_out(pc_out),
      .alu_op(alu_op),
      .trap_cause(trap_cause),
      .csr_addr(csr_addr),
      .is_csr(is_csr),
      .csr_read(csr_read),
      .csr_write(csr_write),
      .trap(trap),
      .reg_write_enable(reg_write_enable),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .is_branch(is_branch),
      .jump(jump),
      .use_pc(use_pc)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test result checking task
  task automatic check_result(input string test_name, input logic expected_reg_write,
                              input logic expected_mem_read, input logic expected_mem_write,
                              input logic expected_is_branch, input logic expected_jump,
                              input logic expected_trap, input logic [3:0] expected_alu_op,
                              input logic [XLEN-1:0] expected_imm = 64'd0,
                              input logic [XLEN-1:0] imm_mask = 64'hFFFFFFFFFFFFFFFF);
    test_count++;

    if (reg_write_enable === expected_reg_write &&
        mem_read === expected_mem_read &&
        mem_write === expected_mem_write &&
        is_branch === expected_is_branch &&
        jump === expected_jump &&
        trap === expected_trap &&
        alu_op === expected_alu_op &&
        ((imm & imm_mask) === (expected_imm & imm_mask))) begin
      $display("PASS: %s", test_name);
      pass_count++;
    end else begin
      $display("FAIL: %s", test_name);
      $display("  Expected: reg_wr=%b, mem_r=%b, mem_w=%b, branch=%b, jump=%b, trap=%b, alu_op=%b",
               expected_reg_write, expected_mem_read, expected_mem_write, expected_is_branch,
               expected_jump, expected_trap, expected_alu_op);
      $display("  Got:      reg_wr=%b, mem_r=%b, mem_w=%b, branch=%b, jump=%b, trap=%b, alu_op=%b",
               reg_write_enable, mem_read, mem_write, is_branch, jump, trap, alu_op);
      if (imm_mask !== 64'd0) begin
        $display("  Expected imm: %h, Got: %h (Mask: %h)", expected_imm, imm, imm_mask);
      end
      fail_count++;
    end
  endtask

  // Helper task to wait for clock edge and allow combinational logic to settle
  task automatic tick();
    @(posedge clk);
    #1;  // Small delay to allow combinational logic to settle
  endtask

  // Test stimulus
  initial begin
    $display("Starting RISC-V Instruction Decode Testbench");

    // Initialize signals
    resetn = 0;
    flush = 0;
    stall = 0;
    instr = 32'h00000013;  // NOP (ADDI x0, x0, 0)
    pc = 64'h1000;
    regfile_rs1 = 64'h0;
    regfile_rs2 = 64'h0;

    // Reset sequence
    repeat (3) @(posedge clk);
    resetn = 1;
    tick();

    // Test 1: R-type instructions
    $display("\n=== Testing R-type Instructions ===");

    // ADD x1, x2, x3
    instr = 32'b0000000_00011_00010_000_00001_0110011;
    pc = 64'h1000;
    tick();
    check_result("ADD", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0001);

    // SUB x4, x5, x6
    instr = 32'b0100000_00110_00101_000_00100_0110011;
    tick();
    check_result("SUB", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0010);

    // XOR x7, x8, x9
    instr = 32'b0000000_01001_01000_100_00111_0110011;
    tick();
    check_result("XOR", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0101);

    // Test 2: I-type ALU instructions
    $display("\n=== Testing I-type ALU Instructions ===");

    // ADDI x1, x2, 100
    instr = 32'b000001100100_00010_000_00001_0010011;
    tick();
    check_result("ADDI", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0001, 64'h64);

    // XORI x3, x4, -1
    instr = 32'b111111111111_00100_100_00011_0010011;
    tick();
    check_result("XORI", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0101, 64'hFFFFFFFFFFFFFFFF);

    // Test 3: Load instructions
    $display("\n=== Testing Load Instructions ===");

    // LW x1, 8(x2)
    instr = 32'b000000001000_00010_010_00001_0000011;
    tick();
    check_result("LW", 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0001, 64'h8);

    // Test 4: Store instructions
    $display("\n=== Testing Store Instructions ===");

    // SW x3, 12(x4)
    instr = 32'b0000000_00011_00100_010_01100_0100011;
    tick();
    check_result("SW", 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 4'b0001, 64'hC);

    // Test 5: Branch instructions
    $display("\n=== Testing Branch Instructions ===");

    // BEQ x1, x2, 16 (branch target = PC + 16)
    instr = 32'b0000000_00010_00001_000_01000_1100011;
    tick();
    check_result("BEQ", 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 4'b0000, 64'h10);

    // Test 6: Jump instructions
    $display("\n=== Testing Jump Instructions ===");

    // JAL x1, 2048
    instr = 32'b00000000100000000000_00001_1101111;
    tick();
    check_result("JAL", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 4'b0001, 64'h800);

    // JALR x1, x2, 4
    instr = 32'b000000000100_00010_000_00001_1100111;
    tick();
    check_result("JALR", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 4'b0001, 64'h4);

    // Test 7: U-type instructions
    $display("\n=== Testing U-type Instructions ===");

    // LUI x1, 0x12345
    instr = 32'b00010010001101000101_00001_0110111;
    tick();
    check_result("LUI", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 64'h12345000);

    // AUIPC x2, 0x12345
    instr = 32'b00010010001101000101_00010_0010111;
    tick();
    check_result("AUIPC", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0001, 64'h12345000);

    // Test 8: CSR instructions
    $display("\n=== Testing CSR Instructions ===");

    // CSRRW x1, mstatus, x2 (CSR address 0x300)
    instr = 32'b001100000000_00010_001_00001_1110011;
    tick();
    if (is_csr && csr_addr == 12'h300 && csr_read && csr_write && reg_write_enable) begin
      $display("PASS: CSRRW");
      pass_count++;
    end else begin
      $display("FAIL: CSRRW - CSR signals incorrect");
      fail_count++;
    end
    test_count++;

    // Test 9: System instructions
    $display("\n=== Testing System Instructions ===");

    // ECALL
    instr = 32'b000000000000_00000_000_00000_1110011;
    tick();
    check_result("ECALL", 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 4'b0000);

    // Test 10: Illegal instruction
    $display("\n=== Testing Illegal Instructions ===");

    instr = 32'hFFFFFFFF;  // Invalid opcode
    tick();
    check_result("Illegal Instruction", 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 4'b0000);

    // Test 11: Pipeline control
    $display("\n=== Testing Pipeline Control ===");

    // Test stall
    instr = 32'b000001100100_00010_000_00001_0010011;  // ADDI
    stall = 1;
    tick();
    // Outputs should remain from previous instruction
    stall = 0;
    tick();
    check_result("After Stall", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0001);

    // Test flush
    flush = 1;
    tick();
    flush = 0;
    tick();
    check_result("After Flush (NOP)", 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0000);

    // Test 12: Edge cases
    $display("\n=== Testing Edge Cases ===");

    // NOP (ADDI x0, x0, 0)
    instr = 32'h00000013;
    tick();
    check_result("NOP", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0001, 64'h0);

    // Final results
    $display("\n=== Test Results ===");
    $display("Total tests: %d", test_count);
    $display("Passed: %d", pass_count);
    $display("Failed: %d", fail_count);

    if (fail_count == 0) begin
      $display("ALL TESTS PASSED!");
    end else begin
      $display("SOME TESTS FAILED!");
    end

    $finish;
  end

  // Timeout watchdog
  initial begin
    #100000;  // 100us timeout
    $display("ERROR: Testbench timeout!");
    $finish;
  end

  // Optional: Dump waveforms
  initial begin
    $dumpfile("build/idecode_tb.vcd");
    $dumpvars(0, idecode_tb);
  end

endmodule
