`default_nettype none `timescale 1ns / 1ns

// Execute / ALU

module exec #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic clk,
    input logic resetn,
    input logic [XLEN-1:0] pc,
    input logic [31:0] instr,
    input logic [5:0] opcode,
    input logic [1:0] funct_3,
    input logic [5:0] funct_7,
    input logic [XLEN-1:0] imm,
    input logic [3:0] rs1_addr,
    input logic [3:0] rs2_addr,
    input logic [3:0] rd_addr

);
  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin

    end else begin

    end
  end

  always_comb begin

  end

endmodule
