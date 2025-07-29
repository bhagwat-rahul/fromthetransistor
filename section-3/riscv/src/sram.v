`default_nettype none `timescale 1ns / 1ns

`ifdef SIMULATION_RUN
module sram #(
    parameter int unsigned XLEN  = 32,
    parameter int unsigned DEPTH = 262144
) (
    input wire clk,
    input wire we,
    input wire [$clog2(DEPTH)-1:0] addr,
    input wire [XLEN-1:0] data_in,
    output reg [XLEN-1:0] data_out
);
  reg [XLEN-1:0] mem[DEPTH];

  always @(posedge clk) begin
    if (we) mem[addr] <= data_in;
    else data_out <= mem[addr];
  end
endmodule
`endif

`ifdef FPGA_RUN

`endif

`ifdef ASIC_RUN

`endif
