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
    output logic [     3:0] trap_cause,
    output logic [    11:0] csr_addr,
    output logic            is_csr,
    output logic            csr_read,
    output logic            csr_write,
    output logic            trap,
    output logic            reg_write_enable,
    output logic            mem_read,
    output logic            mem_write,
    output logic            is_branch,
    output logic            jump
);

  localparam logic [3:0]
  NOP  = 4'b0000,
  ADD  = 4'b0001,
  SUB  = 4'b0010,
  AND  = 4'b0011,
  OR   = 4'b0100,
  XOR  = 4'b0101,
  SLL  = 4'b0110,
  SRL  = 4'b0111,
  SRA  = 4'b1000,
  SLT  = 4'b1001,
  SLTU = 4'b1010;

  // Internal pipeline registers
  logic [6:0] opcode_reg, opcode_reg_next;
  logic [4:0] rd_reg, rd_reg_next;
  logic [4:0] rs1_reg, rs1_reg_next;
  logic [4:0] rs2_reg, rs2_reg_next;
  logic [2:0] funct3_reg, funct3_reg_next;
  logic [6:0] funct7_reg, funct7_reg_next;
  logic [XLEN-1:0] imm_reg, imm_reg_next;
  logic [3:0] alu_op_reg, alu_op_reg_next;
  logic [3:0] trap_cause_reg, trap_cause_reg_next;
  logic [11:0] csr_addr_reg, csr_addr_reg_next;
  logic trap_reg, trap_reg_next;
  logic reg_write_enable_reg, reg_write_enable_reg_next;
  logic mem_read_reg, mem_read_reg_next;
  logic mem_write_reg, mem_write_reg_next;
  logic is_branch_reg, is_branch_reg_next;
  logic jump_reg, jump_reg_next;
  logic is_csr_reg, is_csr_reg_next;
  logic csr_read_reg, csr_read_reg_next;
  logic csr_write_reg, csr_write_reg_next;

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin
      opcode_reg           <= 7'b0010011;  // NOP
      rd_reg               <= 0;
      rs1_reg              <= 5'd0;
      rs2_reg              <= 5'd0;
      funct3_reg           <= 3'd0;
      funct7_reg           <= 7'd0;
      imm_reg              <= {XLEN{1'b0}};
      alu_op_reg           <= NOP;
      reg_write_enable_reg <= 0;
      mem_read_reg         <= 0;
      mem_write_reg        <= 0;
      is_branch_reg        <= 0;
      jump_reg             <= 0;
      trap_cause_reg       <= 4'd0;
      csr_addr_reg         <= 12'd0;
      trap_reg             <= 0;
      is_csr_reg           <= 0;
      csr_read_reg         <= 0;
      csr_write_reg        <= 0;
    end else if (flush) begin
      opcode_reg           <= 7'b0010011;  // NOP
      rd_reg               <= 0;
      rs1_reg              <= 5'd0;
      rs2_reg              <= 5'd0;
      funct3_reg           <= 3'd0;
      funct7_reg           <= 7'd0;
      imm_reg              <= {XLEN{1'b0}};
      alu_op_reg           <= NOP;
      reg_write_enable_reg <= 0;
      mem_read_reg         <= 0;
      mem_write_reg        <= 0;
      is_branch_reg        <= 0;
      jump_reg             <= 0;
      trap_cause_reg       <= 4'd0;
      csr_addr_reg         <= 12'd0;
      trap_reg             <= 0;
      is_csr_reg           <= 0;
      csr_read_reg         <= 0;
      csr_write_reg        <= 0;
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
      trap_cause_reg       <= trap_cause_reg_next;
      csr_addr_reg         <= csr_addr_reg_next;
      trap_reg             <= trap_reg_next;
      is_csr_reg           <= is_csr_reg_next;
      csr_read_reg         <= csr_read_reg_next;
      csr_write_reg        <= csr_write_reg_next;
    end
  end

  always_comb begin
    // Default control signals (safe defaults)
    imm_reg_next              = {XLEN{1'b0}};
    alu_op_reg_next           = NOP;
    reg_write_enable_reg_next = 1'b0;
    mem_read_reg_next         = 1'b0;
    mem_write_reg_next        = 1'b0;
    is_branch_reg_next        = 1'b0;
    jump_reg_next             = 1'b0;
    is_csr_reg_next           = 1'b0;
    csr_addr_reg_next         = 12'd0;
    csr_write_reg_next        = 1'b0;
    csr_read_reg_next         = 1'b0;
    trap_reg_next             = 1'b0;
    trap_cause_reg_next       = 4'd0;

    // Extract from instruction
    opcode_reg_next           = instr[6:0];
    rd_reg_next               = instr[11:7];
    rs1_reg_next              = instr[19:15];
    rs2_reg_next              = instr[24:20];
    funct3_reg_next           = instr[14:12];
    funct7_reg_next           = instr[31:25];

    case (instr[6:0])
      default: begin
        trap_reg_next = 1'b1;
        trap_cause_reg_next = 4'd2;  // Illegal instruction
      end
      7'b0000000: ;  // NOP
      7'b0110011: begin
        reg_write_enable_reg_next = 1'b1;
        is_branch_reg_next        = 1'b0;
        case ({
          funct7_reg_next, funct3_reg_next
        })
          default:         alu_op_reg_next = NOP;
          10'b0000000_000: alu_op_reg_next = ADD;
          10'b0100000_000: alu_op_reg_next = SUB;
          10'b0000000_111: alu_op_reg_next = AND;
          10'b0000000_110: alu_op_reg_next = OR;
          10'b0000000_100: alu_op_reg_next = XOR;
          10'b0000000_001: alu_op_reg_next = SLL;
          10'b0000000_101: alu_op_reg_next = SRL;
          10'b0100000_101: alu_op_reg_next = SRA;
          10'b0000000_010: alu_op_reg_next = SLT;
          10'b0000000_011: alu_op_reg_next = SLTU;
        endcase
      end  // R Type ADD, SUB, XOR, OR, AND, SLT, etc.
      7'b0010011: begin
        reg_write_enable_reg_next = 1'b1;
        is_branch_reg_next        = 1'b0;
        imm_reg_next              = {{(XLEN - 12) {instr[31]}}, instr[31:20]};
        case (funct3_reg_next)
          default: alu_op_reg_next = NOP;
          3'b000:  alu_op_reg_next = ADD;  // ADDI
          3'b111:  alu_op_reg_next = AND;  // ANDI
          3'b110:  alu_op_reg_next = OR;  // ORI
          3'b100:  alu_op_reg_next = XOR;  // XORI
          3'b010:  alu_op_reg_next = SLT;  // SLTI
          3'b011:  alu_op_reg_next = SLTU;  // SLTIU
          3'b001:  alu_op_reg_next = SLL;  // SLLI
          3'b101: begin
            if (instr[30] == 0) alu_op_reg_next = SRL;  // SRLI
            else alu_op_reg_next = SRA;  // SRAI
          end
        endcase
      end  // I Type ADDI, ORI, ANDI, SLTI, etc. (alu-ops)
      7'b0000011: begin
        mem_read_reg_next = 1'b1;
        is_branch_reg_next = 1'b0;
        alu_op_reg_next = ADD;
        imm_reg_next = {{(XLEN - 12) {instr[31]}}, instr[31:20]};
        reg_write_enable_reg_next = 1'b1;
      end  // I Type LB, LH, LW, LBU, LHU (loads)
      7'b1100111: begin
        reg_write_enable_reg_next = 1'b1;
        is_branch_reg_next        = 1'b0;
        alu_op_reg_next           = ADD;
        jump_reg_next             = 1'b1;
        imm_reg_next              = {{(XLEN - 12) {instr[31]}}, instr[31:20]};
      end  // I Type JALR
      7'b1110011: begin
        is_branch_reg_next = 1'b0;
        if (instr[14:12] == 3'b000) begin  // ECALL/EBREAK (funct3 = 000)
          unique case (instr[31:20])  // funct12
            12'h000: begin  // ECALL
              trap_reg_next       = 1'b1;
              trap_cause_reg_next = 4'd8;  // + offset for current mode
            end
            12'h001: begin  // EBREAK
              trap_reg_next       = 1'b1;
              trap_cause_reg_next = 4'd3;  // Breakpoint
            end
            default: begin
              trap_reg_next       = 1'b1;
              trap_cause_reg_next = 4'd2;  // Illegal instruction
            end
          endcase
        end else begin  // CSR instructions
          is_csr_reg_next = 1;
          csr_addr_reg_next = instr[31:20];  // CSR address
          reg_write_enable_reg_next = (rd_reg_next != 5'd0);  // Only write to rd if rd != x0

          case (funct3_reg_next)
            3'b001: begin  // CSRRW - CSR Read/Write
              csr_read_reg_next = (rd_reg_next != 5'd0);
              csr_write_reg_next = 1'b1;
              imm_reg_next = {XLEN{1'b0}};  // Use rs1 value, not immediate
            end
            3'b010: begin  // CSRRS - CSR Read/Set
              csr_read_reg_next = 1'b1;
              csr_write_reg_next = (rs1_reg_next != 5'd0);  // Only write if rs1 != x0
              imm_reg_next = {XLEN{1'b0}};  // Use rs1 value
            end
            3'b011: begin  // CSRRC - CSR Read/Clear
              csr_read_reg_next = 1'b1;
              csr_write_reg_next = (rs1_reg_next != 5'd0);  // Only write if rs1 != x0
              imm_reg_next = {XLEN{1'b0}};  // Use rs1 value
            end
            3'b101: begin  // CSRRWI - CSR Read/Write Immediate
              csr_read_reg_next = (rd_reg_next != 5'd0);
              csr_write_reg_next = 1'b1;
              imm_reg_next = {{(XLEN - 5) {1'b0}}, rs1_reg_next};  // Zero-extend uimm[4:0]
            end
            3'b110: begin  // CSRRSI - CSR Read/Set Immediate
              csr_read_reg_next = 1'b1;
              csr_write_reg_next = (rs1_reg_next != 5'd0);  // Only write if uimm != 0
              imm_reg_next = {{(XLEN - 5) {1'b0}}, rs1_reg_next};  // Zero-extend uimm[4:0]
            end
            3'b111: begin  // CSRRCI - CSR Read/Clear Immediate
              csr_read_reg_next = 1'b1;
              csr_write_reg_next = (rs1_reg_next != 5'd0);  // Only write if uimm != 0
              imm_reg_next = {{(XLEN - 5) {1'b0}}, rs1_reg_next};  // Zero-extend uimm[4:0]
            end
            default: begin  // Illegal CSR instruction
              trap_reg_next = 1'b1;
              trap_cause_reg_next = 4'd2;  // Illegal instruction
            end
          endcase
        end
      end  // I Type ECALL, EBREAK, CSR ops
      7'b0100011: begin
        is_branch_reg_next        = 1'b0;
        reg_write_enable_reg_next = 1'b0;
        mem_write_reg_next        = 1'b1;
        alu_op_reg_next           = ADD;
        imm_reg_next              = {{(XLEN - 12) {instr[31]}}, instr[31:25], instr[11:7]};
      end  // S Type SB, SH, SW (stores)
      7'b1100011: begin
        is_branch_reg_next = 1'b1;
        imm_reg_next = {
          {(XLEN - 13) {instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0
        };
      end  // B Type BEQ, BNE, BLT, BGE, BLTU, BGEU
      7'b0110111: begin
        is_branch_reg_next        = 1'b0;
        reg_write_enable_reg_next = 1'b1;
        imm_reg_next              = {{(XLEN - 32) {instr[31]}}, instr[31:12], 12'b0};
      end  // U Type LUI
      7'b0010111: begin
        reg_write_enable_reg_next = 1'b1;
        is_branch_reg_next        = 1'b0;
        alu_op_reg_next           = ADD;
        imm_reg_next              = {{(XLEN - 32) {instr[31]}}, instr[31:12], 12'b0};
      end  // U Type AUIPC
      7'b1101111: begin
        reg_write_enable_reg_next = 1'b1;
        is_branch_reg_next = 1'b0;
        alu_op_reg_next = ADD;
        jump_reg_next = 1'b1;
        imm_reg_next = {
          {(XLEN - 21) {instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0
        };
      end  // J Type JAL
    endcase
  end

  assign opcode           = opcode_reg;
  assign rd               = rd_reg;
  assign rs1              = rs1_reg;
  assign rs2              = rs2_reg;
  assign funct3           = funct3_reg;
  assign funct7           = funct7_reg;
  assign imm              = imm_reg;
  assign alu_op           = alu_op_reg;
  assign reg_write_enable = reg_write_enable_reg;
  assign mem_read         = mem_read_reg;
  assign mem_write        = mem_write_reg;
  assign is_branch        = is_branch_reg;
  assign jump             = jump_reg;
  assign trap             = trap_reg;
  assign trap_cause       = trap_cause_reg;
  assign is_csr           = is_csr_reg;
  assign csr_addr         = csr_addr_reg;
  assign csr_write        = csr_write_reg;
  assign csr_read         = csr_read_reg;

endmodule
