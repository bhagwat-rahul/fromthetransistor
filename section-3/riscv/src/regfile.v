`default_nettype none `timescale 1ns / 1ns

// Register File

module regfile #(
    parameter logic [8:0] XLEN = 64
) (
    input logic clk,
    input logic resetn,
    input logic we,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [XLEN - 1:0] wd,

    output logic [XLEN-1:0] rd1,
    output logic [XLEN-1:0] rd2
);

  logic [XLEN-1:0] registers[32];
  assign registers[0] = '0;  // 0 reg is hard 0 in risc-v

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin
      for (int i = 0; i < 32; i++) registers[i] <= '0;
    end else if (we && rd != 0) begin
      registers[rd] <= wd;
    end
  end

  always_comb begin
    rd1 = registers[rs1];
    rd2 = registers[rs2];
  end

endmodule
