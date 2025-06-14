`default_nettype none `timescale 1ns / 1ns

// Instruction Fetch

module ifetch #(

) (
    input logic        clk,
    input logic        resetn,
    input logic        pc_valid,
    input logic        stall,
    input logic        flush,
    input logic        imem_valid,
    input logic        imem_ready,
    input logic        imem_err,
    input logic [63:0] pc_next,
    input logic [63:0] imem_data,

    output logic        imem_req,
    output logic        instr_valid,
    output logic [31:0] instruction,
    output logic [63:0] pc_current,
    output logic [31:0] imem_addr
);

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin

    end else begin

    end
  end

  always_comb begin

  end

endmodule
