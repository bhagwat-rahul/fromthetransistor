`default_nettype none `timescale 1ns / 1ns
import defs_pkg::*;

// Execute / ALU

module exec #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic            clk,
    input logic            resetn,
    input logic [     6:0] opcode,
    input logic [     4:0] rd,
    input logic [     4:0] rs1,
    input logic [     4:0] rs2,
    input logic [     2:0] funct3,
    input logic [     6:0] funct7,
    input logic [XLEN-1:0] imm,
    input logic [XLEN-1:0] pc_in,
    input logic [     3:0] alu_op,
    input logic [     3:0] trap_cause_in,
    input logic [    11:0] csr_addr,
    input logic            is_csr,
    input logic            csr_read,
    input logic            csr_write,
    input logic            trap_in,
    input logic            reg_write_enable,
    input logic            mem_read,
    input logic            mem_write,
    input logic            is_branch,
    input logic            jump,
    input logic            use_pc,
    input logic [XLEN-1:0] rs1_data,
    input logic [XLEN-1:0] rs2_data,
    input logic            stall,
    input logic            flush,
    input logic [XLEN-1:0] csr_rdata,

    output logic [    11:0] csr_addr_out,
    output logic [XLEN-1:0] csr_wdata,
    output logic            csr_read_out,
    output logic            csr_write_out,
    output logic [XLEN-1:0] alu_result,
    output logic [XLEN-1:0] rs2_data_out,
    output logic [XLEN-1:0] pc_out,
    output logic [     4:0] rd_out,
    output logic [     2:0] funct3_out,
    output logic            reg_write_enable_out,
    output logic            mem_read_out,
    output logic            mem_write_out,
    output logic [     3:0] trap_cause_out,
    output logic            trap_out,
    output logic            branch_taken,
    output logic [XLEN-1:0] branch_target,
    output logic            jump_taken,
    output logic [XLEN-1:0] jump_target,
    output logic            exception_occurred,
    output logic [XLEN-1:0] exception_pc,
    output logic [     3:0] exception_cause
);

  logic [11:0] csr_addr_out_reg, csr_addr_out_reg_next;
  logic [XLEN-1:0] csr_wdata_reg, csr_wdata_reg_next;
  logic csr_read_out_reg, csr_read_out_reg_next;
  logic csr_write_out_reg, csr_write_out_reg_next;
  logic [XLEN-1:0] alu_result_reg, alu_result_reg_next;
  logic [XLEN-1:0] rs2_data_out_reg, rs2_data_out_reg_next;
  logic [XLEN-1:0] pc_out_reg, pc_out_reg_next;
  logic [4:0] rd_out_reg, rd_out_reg_next;
  logic [2:0] funct3_out_reg, funct3_out_reg_next;
  logic reg_write_enable_out_reg, reg_write_enable_out_reg_next;
  logic mem_read_out_reg, mem_read_out_reg_next;
  logic mem_write_out_reg, mem_write_out_reg_next;
  logic [3:0] trap_cause_out_reg, trap_cause_out_reg_next;
  logic trap_out_reg, trap_out_reg_next;
  logic branch_taken_reg, branch_taken_reg_next;
  logic [XLEN-1:0] branch_target_reg, branch_target_reg_next;
  logic jump_taken_reg, jump_taken_reg_next;
  logic [XLEN-1:0] jump_target_reg, jump_target_reg_next;
  logic exception_occurred_reg, exception_occurred_reg_next;
  logic [XLEN-1:0] exception_pc_reg, exception_pc_reg_next;
  logic [3:0] exception_cause_reg, exception_cause_reg_next;

  // Internals
  logic [XLEN-1:0] alu_operand_b;
  assign alu_operand_b = (opcode == I) ? imm : rs2_data;

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin
      csr_addr_out_reg         <= 12'd0;
      csr_wdata_reg            <= '0;
      csr_read_out_reg         <= 1'b0;
      csr_write_out_reg        <= 1'b0;
      alu_result_reg           <= '0;
      rs2_data_out_reg         <= '0;
      pc_out_reg               <= '0;
      rd_out_reg               <= 5'd0;
      funct3_out_reg           <= 3'd0;
      reg_write_enable_out_reg <= 1'b0;
      mem_read_out_reg         <= 1'b0;
      mem_write_out_reg        <= 1'b0;
      trap_cause_out_reg       <= 4'd0;
      trap_out_reg             <= 1'b0;
      branch_taken_reg         <= 1'b0;
      branch_target_reg        <= '0;
      jump_taken_reg           <= 1'b0;
      jump_target_reg          <= '0;
      exception_occurred_reg   <= 1'b0;
      exception_pc_reg         <= '0;
      exception_cause_reg      <= 4'd0;
    end else if (flush) begin
      csr_addr_out_reg         <= 12'd0;
      csr_wdata_reg            <= '0;
      csr_read_out_reg         <= 1'b0;
      csr_write_out_reg        <= 1'b0;
      alu_result_reg           <= '0;
      rs2_data_out_reg         <= '0;
      pc_out_reg               <= '0;
      rd_out_reg               <= 5'd0;
      funct3_out_reg           <= 3'd0;
      reg_write_enable_out_reg <= 1'b0;
      mem_read_out_reg         <= 1'b0;
      mem_write_out_reg        <= 1'b0;
      trap_cause_out_reg       <= 4'd0;
      trap_out_reg             <= 1'b0;
      branch_taken_reg         <= 1'b0;
      branch_target_reg        <= '0;
      jump_taken_reg           <= 1'b0;
      jump_target_reg          <= '0;
      exception_occurred_reg   <= 1'b0;
      exception_pc_reg         <= '0;
      exception_cause_reg      <= 4'd0;
    end else if (!stall) begin
      csr_addr_out_reg         <= csr_addr_out_reg_next;
      csr_wdata_reg            <= csr_wdata_reg_next;
      csr_read_out_reg         <= csr_read_out_reg_next;
      csr_write_out_reg        <= csr_write_out_reg_next;
      alu_result_reg           <= alu_result_reg_next;
      rs2_data_out_reg         <= rs2_data_out_reg_next;
      pc_out_reg               <= pc_out_reg_next;
      rd_out_reg               <= rd_out_reg_next;
      funct3_out_reg           <= funct3_out_reg_next;
      reg_write_enable_out_reg <= reg_write_enable_out_reg_next;
      mem_read_out_reg         <= mem_read_out_reg_next;
      mem_write_out_reg        <= mem_write_out_reg_next;
      trap_cause_out_reg       <= trap_cause_out_reg_next;
      trap_out_reg             <= trap_out_reg_next;
      branch_taken_reg         <= branch_taken_reg_next;
      branch_target_reg        <= branch_target_reg_next;
      jump_taken_reg           <= jump_taken_reg_next;
      jump_target_reg          <= jump_target_reg_next;
      exception_occurred_reg   <= exception_occurred_reg_next;
      exception_pc_reg         <= exception_pc_reg_next;
      exception_cause_reg      <= exception_cause_reg_next;
    end
  end

  always_comb begin

    // Stay the same if nothing else
    csr_wdata_reg_next            = csr_wdata_reg;
    alu_result_reg_next           = alu_result_reg;
    branch_taken_reg_next         = branch_taken_reg;
    branch_target_reg_next        = branch_target_reg;
    jump_taken_reg_next           = jump_taken_reg;
    jump_target_reg_next          = jump_target_reg;
    exception_occurred_reg_next   = exception_occurred_reg;
    exception_pc_reg_next         = exception_pc_reg;
    exception_cause_reg_next      = exception_cause_reg;

    // Pass through
    csr_addr_out_reg_next         = csr_addr;
    pc_out_reg_next               = pc_in;
    rd_out_reg_next               = rd;
    funct3_out_reg_next           = funct3;
    reg_write_enable_out_reg_next = reg_write_enable;
    mem_read_out_reg_next         = mem_read;
    mem_write_out_reg_next        = mem_write;
    rs2_data_out_reg_next         = rs2_data;
    trap_out_reg_next             = trap_in;
    trap_cause_out_reg_next       = trap_cause_in;
    csr_read_out_reg_next         = csr_read;
    csr_write_out_reg_next        = csr_write;

    case (alu_op)
      default: ;
      NOP: ;
      ADD: alu_result_reg_next = rs1_data + alu_operand_b;
      SUB: alu_result_reg_next = rs1_data - alu_operand_b;
      AND: alu_result_reg_next = rs1_data & alu_operand_b;
      OR: alu_result_reg_next = rs1_data | alu_operand_b;
      XOR: alu_result_reg_next = rs1_data ^ alu_operand_b;
      SLL: alu_result_reg_next = rs1_data << (alu_operand_b[5:0]);
      SRL: alu_result_reg_next = rs1_data >> (alu_operand_b[5:0]);
      SRA: alu_result_reg_next = $signed(rs1_data) >>> (alu_operand_b[5:0]);
      SLT: alu_result_reg_next = ($signed(rs1_data) < $signed(alu_operand_b)) ? 1 : 0;
      SLTU: alu_result_reg_next = (rs1_data < alu_operand_b) ? 1 : 0;
    endcase

    if (is_branch) begin
      branch_target_reg_next = pc_in + imm;
      case (funct3)
        default: ;
        BEQ: branch_taken_reg_next = (rs1_data == rs2_data);
        BNE: branch_taken_reg_next = (rs1_data != rs2_data);
        BLT: branch_taken_reg_next = ($signed(rs1_data) < $signed(rs2_data));
        BGE: branch_taken_reg_next = ($signed(rs1_data) >= $signed(rs2_data));
        BLTU: branch_taken_reg_next = ((rs1_data) < (rs2_data));
        BGEU: branch_taken_reg_next = ((rs1_data) >= (rs2_data));
      endcase
    end

    if (jump) begin
      jump_taken_reg_next = 1'b1;
      if (opcode == J) begin
        jump_target_reg_next = pc_in + imm;
      end
      if (opcode == JALRI) begin
        jump_target_reg_next = rs1_data + imm;
      end
    end

    if (is_csr) begin
      case (funct3)
        default: ;
        CSRRW:   csr_wdata_reg_next = rs1_data;
        CSRRS:   csr_wdata_reg_next = csr_rdata | rs1_data;
        CSRRC:   csr_wdata_reg_next = csr_rdata & ~rs1_data;
        CSRRWI:  csr_wdata_reg_next = imm;
        CSRRSI:  csr_wdata_reg_next = csr_rdata | imm;
        CSRRCI:  csr_wdata_reg_next = csr_rdata & ~imm;
      endcase
      alu_result_reg_next = csr_rdata;

      if (use_pc) begin
        alu_result_reg_next = pc_in + 64'd4;  // Return address for JAL/JALR
      end
    end

    // Missing in your always_comb block:
    if (opcode == LUI) begin
      alu_result_reg_next = imm;  // LUI: rd = imm (upper 20 bits)
    end
    if (opcode == AUIPC) begin
      alu_result_reg_next = pc_in + imm;  // AUIPC: rd = pc + imm
    end

  end

  assign csr_addr_out         = csr_addr_out_reg;
  assign csr_wdata            = csr_wdata_reg;
  assign csr_read_out         = csr_read_out_reg;
  assign csr_write_out        = csr_write_out_reg;
  assign alu_result           = alu_result_reg;
  assign rs2_data_out         = rs2_data_out_reg;
  assign pc_out               = pc_out_reg;
  assign rd_out               = rd_out_reg;
  assign funct3_out           = funct3_out_reg;
  assign reg_write_enable_out = reg_write_enable_out_reg;
  assign mem_read_out         = mem_read_out_reg;
  assign mem_write_out        = mem_write_out_reg;
  assign trap_cause_out       = trap_cause_out_reg;
  assign trap_out             = trap_out_reg;
  assign branch_taken         = branch_taken_reg;
  assign branch_target        = branch_target_reg;
  assign jump_taken           = jump_taken_reg;
  assign jump_target          = jump_target_reg;
  assign exception_occurred   = exception_occurred_reg;
  assign exception_pc         = exception_pc_reg;
  assign exception_cause      = exception_cause_reg;

endmodule
