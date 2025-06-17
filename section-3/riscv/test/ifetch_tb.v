`default_nettype none `timescale 1ns / 1ns

module ifetch_tb #(
    parameter int unsigned XLEN = 64
) ();

  logic clk, resetn;
  logic pc_valid, stall, flush, imem_valid, imem_ready, imem_err, imem_req, instr_valid;
  logic [31:0] instruction, imem_addr;
  logic [XLEN-1:0] pc_next, imem_data, pc_current;

  initial begin
    $monitor(
        "imem_req: %0d, instr_valid: %0d, instr: %0d, imem_addr = %0d, imem_ready: %0d, state: %0d",
        imem_req, instr_valid, instruction, imem_addr, imem_ready, ifetch_a.state);
    clk    = 0;
    resetn = 0;
    #50 resetn = 1;
    $display("Reset done!");
    pc_valid   = 1;
    pc_next    = 64'hx8000_0000;
    stall      = 0;
    flush      = 0;
    imem_valid = 1;
    imem_ready = 1;
    imem_err   = 0;
    imem_data  = 64'hx726168756C2121;
    #200 $finish;
  end
  always #5 clk = ~clk;


  ifetch #(
      .XLEN(XLEN)
  ) ifetch_a (
      .clk,
      .resetn,
      .pc_valid,
      .stall,
      .flush,
      .imem_valid,
      .imem_ready,
      .imem_err,
      .pc_next,
      .imem_data,

      .imem_req,
      .instr_valid,
      .instruction,
      .imem_addr,
      .pc_current
  );

endmodule
