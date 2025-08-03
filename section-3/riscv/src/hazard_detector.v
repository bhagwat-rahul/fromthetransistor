`default_nettype none `timescale 1ns / 1ns

module hazard_detector #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic clk,
    input logic resetn,

    // ========================================================================
    // Pipeline Stage Inputs for Hazard Detection
    // ========================================================================

    // Instruction Fetch Stage
    input logic            if_valid,
    input logic [31:0]     if_instruction,

    // Instruction Decode Stage
    input logic            id_valid,
    input logic [4:0]      id_rs1,
    input logic [4:0]      id_rs2,
    input logic [4:0]      id_rd,
    input logic            id_reg_write_enable,
    input logic            id_mem_read,
    input logic            id_mem_write,
    input logic            id_is_branch,
    input logic            id_jump,
    input logic            id_is_csr,

    // Execute Stage
    input logic            ex_valid,
    input logic [4:0]      ex_rd,
    input logic            ex_reg_write_enable,
    input logic            ex_mem_read,
    input logic            ex_mem_write,
    input logic            ex_is_branch,
    input logic            ex_jump,
    input logic            ex_branch_taken,
    input logic            ex_jump_taken,
    input logic            ex_is_csr,

    // Memory Access Stage
    input logic            mem_valid,
    input logic [4:0]      mem_rd,
    input logic            mem_reg_write_enable,
    input logic            mem_mem_read,
    input logic            mem_mem_write,
    input logic            mem_stall_internal, // From memory controller
    input logic            mem_is_csr,

    // Writeback Stage
    input logic            wb_valid,
    input logic [4:0]      wb_rd,
    input logic            wb_reg_write_enable,

    // Control flow hazards
    input logic            pipeline_flush_request,

    // ========================================================================
    // Hazard Detection Outputs
    // ========================================================================

    // Stall signals for each pipeline stage
    output logic           stall_if,
    output logic           stall_id,
    output logic           stall_ex,
    output logic           stall_mem,
    output logic           stall_wb,

    // Flush signals for each pipeline stage
    output logic           flush_if,
    output logic           flush_id,
    output logic           flush_ex,
    output logic           flush_mem,
    output logic           flush_wb,

    // Combined hazard stall signal
    output logic           hazard_stall,

    // Forwarding control signals (for future forwarding unit)
    output logic [1:0]     forward_rs1_sel,  // 00=reg, 01=ex, 10=mem, 11=wb
    output logic [1:0]     forward_rs2_sel   // 00=reg, 01=ex, 10=mem, 11=wb
);

  // ========================================================================
  // Internal hazard detection logic
  // ========================================================================

  logic load_use_hazard;
  logic data_hazard_rs1;
  logic data_hazard_rs2;
  logic structural_hazard;
  logic control_hazard;
  logic csr_hazard;

  // ========================================================================
  // Load-Use Hazard Detection
  // ========================================================================
  // Occurs when the instruction in ID stage needs a result from a load
  // instruction currently in EX stage

  always_comb begin
    load_use_hazard = 1'b0;

    if (id_valid && ex_valid && ex_mem_read && ex_reg_write_enable) begin
      // Check if ID stage instruction uses the register being loaded in EX
      if ((ex_rd != 5'd0) &&
          ((id_rs1 == ex_rd) || (id_rs2 == ex_rd))) begin
        load_use_hazard = 1'b1;
      end
    end
  end

  // ========================================================================
  // Data Hazard Detection (RAW - Read After Write)
  // ========================================================================
  // Detect when an instruction needs a register that's being written by
  // a previous instruction still in the pipeline

  always_comb begin
    data_hazard_rs1 = 1'b0;
    data_hazard_rs2 = 1'b0;

    if (id_valid && (id_rs1 != 5'd0)) begin
      // Check hazard with EX stage
      if (ex_valid && ex_reg_write_enable && (ex_rd == id_rs1) && (ex_rd != 5'd0)) begin
        data_hazard_rs1 = 1'b1;
      end
      // Check hazard with MEM stage
      else if (mem_valid && mem_reg_write_enable && (mem_rd == id_rs1) && (mem_rd != 5'd0)) begin
        data_hazard_rs1 = 1'b1;
      end
      // Check hazard with WB stage
      else if (wb_valid && wb_reg_write_enable && (wb_rd == id_rs1) && (wb_rd != 5'd0)) begin
        data_hazard_rs1 = 1'b1;
      end
    end

    if (id_valid && (id_rs2 != 5'd0)) begin
      // Check hazard with EX stage
      if (ex_valid && ex_reg_write_enable && (ex_rd == id_rs2) && (ex_rd != 5'd0)) begin
        data_hazard_rs2 = 1'b1;
      end
      // Check hazard with MEM stage
      else if (mem_valid && mem_reg_write_enable && (mem_rd == id_rs2) && (mem_rd != 5'd0)) begin
        data_hazard_rs2 = 1'b1;
      end
      // Check hazard with WB stage
      else if (wb_valid && wb_reg_write_enable && (wb_rd == id_rs2) && (wb_rd != 5'd0)) begin
        data_hazard_rs2 = 1'b1;
      end
    end
  end

  // ========================================================================
  // Structural Hazard Detection
  // ========================================================================
  // Occurs when multiple instructions compete for the same hardware resource

  always_comb begin
    structural_hazard = 1'b0;

    // Memory access conflict: both EX and MEM stages trying to access memory
    if (ex_valid && mem_valid) begin
      if ((ex_mem_read || ex_mem_write) && (mem_mem_read || mem_mem_write)) begin
        structural_hazard = 1'b1;
      end
    end

    // Memory controller stall propagation
    if (mem_stall_internal) begin
      structural_hazard = 1'b1;
    end
  end

  // ========================================================================
  // Control Hazard Detection
  // ========================================================================
  // Occurs when branch/jump instructions change the control flow

  always_comb begin
    control_hazard = 1'b0;

    // Branch/jump taken in EX stage - need to flush earlier stages
    if (ex_valid && (ex_branch_taken || ex_jump_taken)) begin
      control_hazard = 1'b1;
    end

    // External flush request
    if (pipeline_flush_request) begin
      control_hazard = 1'b1;
    end
  end

  // ========================================================================
  // CSR Hazard Detection
  // ========================================================================
  // CSR instructions must be handled carefully to maintain program order

  always_comb begin
    csr_hazard = 1'b0;

    // Stall if there's a CSR instruction in any pipeline stage
    // This ensures CSR operations complete in order
    if (id_valid && id_is_csr) begin
      if (ex_valid || mem_valid || wb_valid) begin
        csr_hazard = 1'b1;
      end
    end

    // Also stall if there's already a CSR instruction in the pipeline
    if ((ex_valid && ex_is_csr) || (mem_valid && mem_is_csr)) begin
      csr_hazard = 1'b1;
    end
  end

  // ========================================================================
  // Forwarding Control Logic
  // ========================================================================
  // Generate forwarding select signals for a future forwarding unit

  always_comb begin
    // Default: use register file data
    forward_rs1_sel = 2'b00;
    forward_rs2_sel = 2'b00;

    // RS1 forwarding
    if (id_valid && (id_rs1 != 5'd0)) begin
      if (mem_valid && mem_reg_write_enable && (mem_rd == id_rs1) && (mem_rd != 5'd0) && !mem_mem_read) begin
        forward_rs1_sel = 2'b10; // Forward from MEM stage
      end
      else if (wb_valid && wb_reg_write_enable && (wb_rd == id_rs1) && (wb_rd != 5'd0)) begin
        forward_rs1_sel = 2'b11; // Forward from WB stage
      end
    end

    // RS2 forwarding
    if (id_valid && (id_rs2 != 5'd0)) begin
      if (mem_valid && mem_reg_write_enable && (mem_rd == id_rs2) && (mem_rd != 5'd0) && !mem_mem_read) begin
        forward_rs2_sel = 2'b10; // Forward from MEM stage
      end
      else if (wb_valid && wb_reg_write_enable && (wb_rd == id_rs2) && (wb_rd != 5'd0)) begin
        forward_rs2_sel = 2'b11; // Forward from WB stage
      end
    end
  end

  // ========================================================================
  // Stall and Flush Control Logic
  // ========================================================================

  always_comb begin
    // Default: no stalls or flushes
    stall_if  = 1'b0;
    stall_id  = 1'b0;
    stall_ex  = 1'b0;
    stall_mem = 1'b0;
    stall_wb  = 1'b0;

    flush_if  = 1'b0;
    flush_id  = 1'b0;
    flush_ex  = 1'b0;
    flush_mem = 1'b0;
    flush_wb  = 1'b0;

    // Load-use hazard: stall IF and ID, bubble in EX
    if (load_use_hazard) begin
      stall_if = 1'b1;
      stall_id = 1'b1;
      flush_ex = 1'b1;
    end

    // Data hazard without forwarding: stall pipeline
    else if ((data_hazard_rs1 || data_hazard_rs2) && !load_use_hazard) begin
      stall_if = 1'b1;
      stall_id = 1'b1;
    end

    // Structural hazard: stall earlier stages
    else if (structural_hazard) begin
      stall_if  = 1'b1;
      stall_id  = 1'b1;
      stall_ex  = 1'b1;
      stall_mem = mem_stall_internal; // Only stall MEM if it's actually the memory causing the stall
    end

    // CSR hazard: stall until pipeline is clear
    else if (csr_hazard) begin
      stall_if = 1'b1;
      stall_id = 1'b1;
    end

    // Control hazard: flush affected stages
    if (control_hazard) begin
      flush_if = 1'b1;
      flush_id = 1'b1;
      flush_ex = 1'b1;
    end
  end

  // ========================================================================
  // Combined hazard stall output
  // ========================================================================

  always_comb begin
    hazard_stall = stall_if || stall_id || stall_ex || stall_mem || stall_wb;
  end

endmodule
