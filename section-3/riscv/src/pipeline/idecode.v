`default_nettype none `timescale 1ns / 1ns

// Instruction Decode

module idecode #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic            clk,
    input logic            resetn,
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
    output logic            branch_taken,
    output logic            jump
);

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin

    end else begin

    end
  end

  always_comb begin
    if (instr == 0) $display("Error");
  end

endmodule
