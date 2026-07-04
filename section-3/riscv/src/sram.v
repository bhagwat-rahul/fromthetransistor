`default_nettype none `timescale 1ns / 1ns

module sram #(
    parameter logic[8:0] XLEN  = 64,
    parameter int unsigned DEPTH = 1024
) (
    input logic clk,
    input logic we,
    input logic [$clog2(DEPTH)-1:0] addr,
    input logic [XLEN-1:0] data_in,
    output logic [XLEN-1:0] data_out
);

/** running software simulation **/
`ifdef SIMULATION_RUN

  logic [XLEN-1:0] mem[DEPTH];

  always @(posedge clk) begin
    if (we) mem[addr] <= data_in;
    else data_out <= mem[addr];
  end

  `endif

  /** synth'ing on FPGA **/
  `ifdef FPGA_RUN

  logic [XLEN-1:0] mem[DEPTH];

  always @(posedge clk) begin
    if (we) mem[addr] <= data_in;
    else data_out <= mem[addr];
  end

  `endif

  /** taping out on asic (PDK dependent) **/
  `ifdef ASIC_RUN

  `ifdef PDK_IHP13SG2

  RM_IHPSG13_1P_1024x64_c2_bm_bist i_ihp_sram (
      .A_CLK       (clk),
      .A_MEN       (1'b1),               // Always enable memory block
      .A_WEN       (we),                 // Write when high
      .A_REN       (~we),                // Read when low
      .A_ADDR      (addr[9:0]),          // 10-bit Address Bus
      .A_DIN       (data_in),            // 64-bit Functional Data In
      .A_DLY       (1'b0),               // Margin delay control (default 0)
      .A_DOUT      (data_out),           // 64-bit Functional Data Out
      .A_BM        ({64{1'b1}}),         // Bit mask: set all bits to 1 for full write TODO(rahul): maybe change

      // BIST Interfaces (Tied off to disable testing during functional execution)
      .A_BIST_EN   (1'b0),               // Disable BIST controller wrapper
      .A_BIST_CLK  (1'b0),
      .A_BIST_MEN  (1'b0),
      .A_BIST_WEN  (1'b0),
      .A_BIST_REN  (1'b0),
      .A_BIST_ADDR (10'b0),
      .A_BIST_DIN  (64'b0),
      .A_BIST_BM   (64'b0)
  );

  `endif

  `ifdef PDK_GF180MCUD

  `endif

  `endif

endmodule
