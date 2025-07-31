`default_nettype none `timescale 1ns / 1ns
import defs_pkg::*;

module riscv #(
    parameter logic [8:0] XLEN = 9'd64,
    parameter logic [31:0] BASE_RESETVEC = 32'h8000_0000,
    parameter logic [XLEN-1:0] RESETVEC = {{(XLEN - 32) {1'b0}}, BASE_RESETVEC}
) (
    input clk,
    input resetn
);

  initial begin
    if ((XLEN != 32) & (XLEN != 64)) $fatal(1, "XLEN invalid please use 32/64, got: %0d", XLEN);
  end

  // ============================================================================
  // Pipeline Control Signals
  // ============================================================================
  logic pipeline_stall, pipeline_flush;
  logic mem_stall;
  logic hazard_stall;

  // PC Management
  logic [XLEN-1:0] pc, next_pc;
  logic pc_valid;
  logic branch_taken, jump_taken;
  logic [XLEN-1:0] branch_target, jump_target;

  // ============================================================================
  // Inter-Stage Pipeline Signals
  // ============================================================================

  // IF -> ID signals
  logic            if_instr_valid;
  logic [    31:0] if_instruction;
  logic [XLEN-1:0] if_pc_current;

  // ID -> EX signals
  logic [     6:0] id_opcode;
  logic [     4:0] id_rd, id_rs1, id_rs2;
  logic [     2:0] id_funct3;
  logic [     6:0] id_funct7;
  logic [XLEN-1:0] id_imm;
  logic [XLEN-1:0] id_pc_out;
  logic [     3:0] id_alu_op;
  logic [     3:0] id_trap_cause;
  logic [    11:0] id_csr_addr;
  logic            id_is_csr;
  logic            id_csr_read, id_csr_write;
  logic            id_trap;
  logic            id_reg_write_enable;
  logic            id_mem_read, id_mem_write;
  logic            id_is_branch;
  logic            id_jump;
  logic            id_use_pc;

  // EX -> MEM signals
  logic [    11:0] ex_csr_addr_out;
  logic [XLEN-1:0] ex_csr_wdata;
  logic            ex_csr_read_out, ex_csr_write_out;
  logic [XLEN-1:0] ex_alu_result;
  logic [XLEN-1:0] ex_rs2_data_out;
  logic [XLEN-1:0] ex_pc_out;
  logic [     4:0] ex_rd_out;
  logic [     2:0] ex_funct3_out;
  logic            ex_reg_write_enable_out;
  logic            ex_mem_read_out, ex_mem_write_out;
  logic [     3:0] ex_trap_cause_out;
  logic            ex_trap_out;
  logic            ex_exception_occurred;
  logic [XLEN-1:0] ex_exception_pc;
  logic [     3:0] ex_exception_cause;

  // MEM -> WB signals
  logic [     4:0] mem_rd_out;
  logic            mem_reg_write_enable_out;
  logic [XLEN-1:0] mem_writeback_data;
  logic [XLEN-1:0] mem_pc_out;
  logic            mem_exception_occurred;
  logic [XLEN-1:0] mem_exception_pc;
  logic [     3:0] mem_exception_cause;
  logic [    11:0] mem_csr_addr_out;
  logic [XLEN-1:0] mem_csr_wdata_out;
  logic            mem_csr_write_out;

  // ============================================================================
  // Register File Signals
  // ============================================================================
  logic [     4:0] regfile_rs1, regfile_rs2, regfile_rd;
  logic [XLEN-1:0] regfile_rs1_data, regfile_rs2_data, regfile_wd;
  logic            regfile_we;

  // ============================================================================
  // Memory Interface Signals
  // ============================================================================

  // Instruction Memory
  logic            imem_req, imem_valid, imem_ready, imem_err;
  logic [    31:0] imem_addr;
  logic [XLEN-1:0] imem_data;

  // Data Memory
  logic [XLEN-1:0] dmem_addr, dmem_wdata, dmem_rdata;
  logic            dmem_read_req, dmem_write_req, dmem_ready, dmem_error;
  logic [     2:0] dmem_size;
  logic            dmem_signed;

  // ============================================================================
  // Exception/CSR Signals
  // ============================================================================
  logic            wb_exception_out;
  logic [XLEN-1:0] wb_exception_pc_out;
  logic [     3:0] wb_exception_cause_out;
  logic [XLEN-1:0] csr_rdata; // TODO: Connect to CSR module when implemented

  // ============================================================================
  // PC Management Logic
  // ============================================================================
  assign pipeline_stall = mem_stall || hazard_stall;
  assign pipeline_flush = branch_taken || jump_taken;

  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      pc <= RESETVEC;
      pc_valid <= 1'b1;
    end else if (!pipeline_stall) begin
      if (branch_taken) begin
        pc <= branch_target;
      end else if (jump_taken) begin
        pc <= jump_target;
      end else begin
        pc <= pc + 4; // Normal increment
      end
      pc_valid <= 1'b1;
    end else begin
      pc_valid <= 1'b0; // Stall PC
    end
  end

  // ============================================================================
  // Pipeline Stage Instantiations
  // ============================================================================

  // Instruction Fetch Stage
  ifetch #(
    .XLEN(XLEN)
  ) ifetch_inst (
    .clk(clk),
    .resetn(resetn),
    .pc_valid(pc_valid),
    .stall(pipeline_stall),
    .flush(pipeline_flush),
    .imem_valid(imem_valid),
    .imem_ready(imem_ready),
    .imem_err(imem_err),
    .pc_next(pc),
    .imem_data(imem_data),
    // Outputs
    .imem_req(imem_req),
    .instr_valid(if_instr_valid),
    .instruction(if_instruction),
    .imem_addr(imem_addr),
    .pc_current(if_pc_current)
  );

  // Instruction Decode Stage
  idecode #(
    .XLEN(XLEN)
  ) idecode_inst (
    .clk(clk),
    .resetn(resetn),
    .flush(pipeline_flush),
    .stall(pipeline_stall),
    .instr(if_instruction),
    .pc(if_pc_current),
    .regfile_rs1(regfile_rs1_data),
    .regfile_rs2(regfile_rs2_data),
    // Outputs
    .opcode(id_opcode),
    .rd(id_rd),
    .rs1(id_rs1),
    .rs2(id_rs2),
    .funct3(id_funct3),
    .funct7(id_funct7),
    .imm(id_imm),
    .pc_out(id_pc_out),
    .alu_op(id_alu_op),
    .trap_cause(id_trap_cause),
    .csr_addr(id_csr_addr),
    .is_csr(id_is_csr),
    .csr_read(id_csr_read),
    .csr_write(id_csr_write),
    .trap(id_trap),
    .reg_write_enable(id_reg_write_enable),
    .mem_read(id_mem_read),
    .mem_write(id_mem_write),
    .is_branch(id_is_branch),
    .jump(id_jump),
    .use_pc(id_use_pc)
  );

  // Execute Stage
  exec #(
    .XLEN(XLEN)
  ) exec_inst (
    .clk(clk),
    .resetn(resetn),
    .opcode(id_opcode),
    .rd(id_rd),
    .rs1(id_rs1),
    .rs2(id_rs2),
    .funct3(id_funct3),
    .funct7(id_funct7),
    .imm(id_imm),
    .pc_in(id_pc_out),
    .alu_op(id_alu_op),
    .trap_cause_in(id_trap_cause),
    .csr_addr(id_csr_addr),
    .is_csr(id_is_csr),
    .csr_read(id_csr_read),
    .csr_write(id_csr_write),
    .trap_in(id_trap),
    .reg_write_enable(id_reg_write_enable),
    .mem_read(id_mem_read),
    .mem_write(id_mem_write),
    .is_branch(id_is_branch),
    .jump(id_jump),
    .use_pc(id_use_pc),
    .rs1_data(regfile_rs1_data),
    .rs2_data(regfile_rs2_data),
    .stall(pipeline_stall),
    .flush(pipeline_flush),
    .csr_rdata(csr_rdata),
    // Outputs
    .csr_addr_out(ex_csr_addr_out),
    .csr_wdata(ex_csr_wdata),
    .csr_read_out(ex_csr_read_out),
    .csr_write_out(ex_csr_write_out),
    .alu_result(ex_alu_result),
    .rs2_data_out(ex_rs2_data_out),
    .pc_out(ex_pc_out),
    .rd_out(ex_rd_out),
    .funct3_out(ex_funct3_out),
    .reg_write_enable_out(ex_reg_write_enable_out),
    .mem_read_out(ex_mem_read_out),
    .mem_write_out(ex_mem_write_out),
    .trap_cause_out(ex_trap_cause_out),
    .trap_out(ex_trap_out),
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .jump_taken(jump_taken),
    .jump_target(jump_target),
    .exception_occurred(ex_exception_occurred),
    .exception_pc(ex_exception_pc),
    .exception_cause(ex_exception_cause)
  );

  // Memory Access Stage
  memacc #(
    .XLEN(XLEN)
  ) memacc_inst (
    .clk(clk),
    .resetn(resetn),
    .stall(pipeline_stall),
    .flush(pipeline_flush),
    .alu_result(ex_alu_result),
    .rs2_data(ex_rs2_data_out),
    .pc_in(ex_pc_out),
    .rd(ex_rd_out),
    .funct3(ex_funct3_out),
    .reg_write_enable(ex_reg_write_enable_out),
    .mem_read(ex_mem_read_out),
    .mem_write(ex_mem_write_out),
    .trap_cause_in(ex_trap_cause_out),
    .trap_in(ex_trap_out),
    .csr_addr(ex_csr_addr_out),
    .csr_wdata(ex_csr_wdata),
    .csr_write(ex_csr_write_out),
    .mem_rdata(dmem_rdata),
    .mem_ready(dmem_ready),
    .mem_error(dmem_error),
    // Outputs
    .mem_addr(dmem_addr),
    .mem_wdata(dmem_wdata),
    .mem_read_req(dmem_read_req),
    .mem_write_req(dmem_write_req),
    .mem_stall(mem_stall),
    .mem_size(dmem_size),
    .mem_signed(dmem_signed),
    .rd_out(mem_rd_out),
    .reg_write_enable_out(mem_reg_write_enable_out),
    .writeback_data(mem_writeback_data),
    .pc_out(mem_pc_out),
    .exception_occurred(mem_exception_occurred),
    .exception_pc(mem_exception_pc),
    .exception_cause(mem_exception_cause),
    .csr_addr_out(mem_csr_addr_out),
    .csr_wdata_out(mem_csr_wdata_out),
    .csr_write_out(mem_csr_write_out)
  );

  // Writeback Stage
  writeback #(
    .XLEN(XLEN)
  ) writeback_inst (
    .clk(clk),
    .resetn(resetn),
    .stall(pipeline_stall),
    .flush(pipeline_flush),
    .rd_in(mem_rd_out),
    .reg_write_enable_in(mem_reg_write_enable_out),
    .writeback_data_in(mem_writeback_data),
    .exception_occurred_in(mem_exception_occurred),
    .exception_pc_in(mem_exception_pc),
    .exception_cause_in(mem_exception_cause),
    // Outputs
    .regfile_rd(regfile_rd),
    .regfile_wd(regfile_wd),
    .regfile_we(regfile_we),
    .exception_out(wb_exception_out),
    .exception_pc_out(wb_exception_pc_out),
    .exception_cause_out(wb_exception_cause_out)
  );

  // ============================================================================
  // Supporting Module Instantiations
  // ============================================================================

  // Register File
  regfile #(
    .XLEN(XLEN)
  ) regfile_inst (
    .clk(clk),
    .resetn(resetn),
    .we(regfile_we),
    .rs1(id_rs1),
    .rs2(id_rs2),
    .rd(regfile_rd),
    .wd(regfile_wd),
    .rd1(regfile_rs1_data),
    .rd2(regfile_rs2_data)
  );

  // Memory Controller
  memory_controller #(
    .XLEN(XLEN),
    .MEM_DEPTH(262144)
  ) memory_controller_inst (
    .clk(clk),
    .resetn(resetn),
    // Instruction Memory Interface
    .imem_req(imem_req),
    .imem_addr(imem_addr),
    .imem_valid(imem_valid),
    .imem_ready(imem_ready),
    .imem_err(imem_err),
    .imem_data(imem_data),
    // Data Memory Interface
    .mem_addr(dmem_addr),
    .mem_wdata(dmem_wdata),
    .mem_read_req(dmem_read_req),
    .mem_write_req(dmem_write_req),
    .mem_size(dmem_size),
    .mem_signed(dmem_signed),
    .mem_rdata(dmem_rdata),
    .mem_ready(dmem_ready),
    .mem_error(dmem_error)
  );

  // Hazard Detector (placeholder - implement as needed)
  hazard_detector #(
    .XLEN(XLEN)
  ) hazard_detector_inst (
    .clk(clk),
    .resetn(resetn)
    // TODO: Add hazard detection signals
  );

  // ============================================================================
  // Temporary assignments (until CSR module is implemented)
  // ============================================================================
  assign csr_rdata = '0; // TODO: Connect to actual CSR module
  assign hazard_stall = 1'b0; // TODO: Connect to hazard detector outputs

endmodule
