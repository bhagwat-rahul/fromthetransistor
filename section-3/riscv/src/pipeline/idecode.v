`default_nettype none `timescale 1ns / 1ns

// Instruction Decode

module idecode #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic            clk,
    input logic            resetn,
    input logic            flush,
    input logic            stall,
    input logic [XLEN-1:0] pc,
    input logic [    31:0] instr,
    input logic [    31:0] regfile_rs1,
    input logic [    31:0] regfile_rs2,

    output logic [     6:0] opcode,
    output logic [     4:0] rd,
    output logic [     4:0] rs1,
    output logic [     4:0] rs2,
    output logic [     2:0] funct3,
    output logic [     6:0] funct7,
    output logic [XLEN-1:0] imm,
    output logic [     3:0] alu_op,
    output logic            reg_write_enable,
    output logic            mem_read,
    output logic            mem_write,
    output logic            is_branch,
    output logic            jump
);

  // Internal pipeline registers
  logic [6:0] opcode_reg, opcode_reg_next;
  logic [4:0] rd_reg, rd_reg_next;
  logic [4:0] rs1_reg, rs1_reg_next;
  logic [4:0] rs2_reg, rs2_reg_next;
  logic [2:0] funct3_reg, funct3_reg_next;
  logic [6:0] funct7_reg, funct7_reg_next;
  logic [XLEN-1:0] imm_reg, imm_reg_next;
  logic [3:0] alu_op_reg, alu_op_reg_next;
  logic reg_write_enable_reg, reg_write_enable_reg_next;
  logic mem_read_reg, mem_read_reg_next;
  logic mem_write_reg, mem_write_reg_next;
  logic is_branch_reg, is_branch_reg_next;
  logic jump_reg, jump_reg_next;

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin
      opcode_reg <= 7'b0010011;  // NOP
      rd_reg <= 0;
      rs1_reg <= 5'd0;
      rs2_reg <= 5'd0;
      funct3_reg <= 3'd0;
      funct7_reg <= 7'd0;
      imm_reg <= {XLEN{1'b0}};
      alu_op_reg <= 4'b0;
      reg_write_enable_reg <= 0;
      mem_read_reg <= 0;
      mem_write_reg <= 0;
      is_branch_reg <= 0;
      jump_reg <= 0;
    end else if (flush) begin
      opcode_reg <= 7'b0010011;  // NOP
      rd_reg <= 0;
      rs1_reg <= 5'd0;
      rs2_reg <= 5'd0;
      funct3_reg <= 3'd0;
      funct7_reg <= 7'd0;
      imm_reg <= {XLEN{1'b0}};
      alu_op_reg <= 4'b0;
      reg_write_enable_reg <= 0;
      mem_read_reg <= 0;
      mem_write_reg <= 0;
      is_branch_reg <= 0;
      jump_reg <= 0;
    end else if (!stall) begin
      opcode_reg           <= opcode_reg_next;
      rd_reg               <= rd_reg_next;
      rs1_reg              <= rs1_reg_next;
      rs2_reg              <= rs2_reg_next;
      funct3_reg           <= funct3_reg_next;
      funct7_reg           <= funct7_reg_next;
      imm_reg              <= imm_reg_next;
      alu_op_reg           <= alu_op_reg_next;
      reg_write_enable_reg <= reg_write_enable_reg_next;
      mem_read_reg         <= mem_read_reg_next;
      mem_write_reg        <= mem_write_reg_next;
      is_branch_reg        <= is_branch_reg_next;
      jump_reg             <= jump_reg_next;
    end
  end

  always_comb begin
    // Default control signals (safe defaults)

    imm_reg_next = {XLEN{1'b0}};
    alu_op_reg_next = 4'd0;
    reg_write_enable_reg_next = 1'b0;
    mem_read_reg_next = 1'b0;
    mem_write_reg_next = 1'b0;
    is_branch_reg_next = 1'b0;
    jump_reg_next = 1'b0;

    // Extract from instruction
    opcode_reg_next = instr[6:0];
    rd_reg_next = instr[11:7];
    rs1_reg_next = instr[19:15];
    rs2_reg_next = instr[24:20];
    funct3_reg_next = instr[14:12];
    funct7_reg_next = instr[31:25];

    case (instr[6:0])
      default: ;  // NOP or unknown do nothing
      7'b0110011: ;  // R Type ADD, SUB, XOR, OR, AND, SLT, etc.
      7'b0010011: ;  // I Type ADDI, ORI, ANDI, SLTI, etc.
      7'b0000011: ;  // I Type LB, LH, LW, LBU, LHU (loads)
      7'b1100111: ;  // I Type JALR
      7'b1110011: ;  // I Type ECALL, EBREAK, CSR ops
      7'b0100011: ;  // S Type SB, SH, SW (stores)
      7'b1100011: ;  // B Type BEQ, BNE, BLT, BGE, BLTU, BGEU
      7'b0110111: ;  // U Type LUI
      7'b0010111: ;  // U Type AUIPC
      7'b1101111: ;  // J Type JAL
    endcase
  end

  assign opcode = opcode_reg;
  assign rd = rd_reg;
  assign rs1 = rs1_reg;
  assign rs2 = rs2_reg;
  assign funct3 = funct3_reg;
  assign funct7 = funct7_reg;
  assign imm = imm_reg;
  assign alu_op = alu_op_reg;
  assign reg_write_enable = reg_write_enable_reg;
  assign mem_read = mem_read_reg;
  assign mem_write = mem_write_reg;
  assign is_branch = is_branch_reg;
  assign jump = jump_reg;

endmodule
