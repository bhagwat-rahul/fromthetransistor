`default_nettype none `timescale 1ns / 1ns

module sram #(
    parameter logic[8:0] XLEN  = 64,
    parameter int unsigned DEPTH = 262144
) (
    input wire clk,
    input wire we,
    input wire [$clog2(DEPTH)-1:0] addr,
    input wire [XLEN-1:0] data_in,
    output reg [XLEN-1:0] data_out
);

/** running software simulation **/
`ifdef SIMULATION_RUN

  reg [XLEN-1:0] mem[DEPTH];

  always @(posedge clk) begin
    if (we) mem[addr] <= data_in;
    else data_out <= mem[addr];
  end

  `endif

  /** synth'ing on FPGA **/
  `ifdef FPGA_RUN

  reg [XLEN-1:0] mem[DEPTH];

  always @(posedge clk) begin
    if (we) mem[addr] <= data_in;
    else data_out <= mem[addr];
  end

  `endif

  /** taping out on asic (dep's on PDK) **/
  `ifdef ASIC_RUN

  `endif

endmodule
