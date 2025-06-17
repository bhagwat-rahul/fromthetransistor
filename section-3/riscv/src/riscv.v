`default_nettype none `timescale 1ns / 1ns

module riscv #(
    parameter logic [8:0] XLEN = 9'd64,  // Upto 128 if needed, realistically only 32/64
    parameter logic [31:0] BASE_RESETVEC = 32'h8000_0000,
    parameter logic [XLEN-1:0] RESETVEC = {{(XLEN - 32) {1'b0}}, BASE_RESETVEC}
) (
    input clk,
    input resetn
);

  initial begin
    if ((XLEN != 32) & (XLEN != 64)) $fatal(1, "XLEN invalid please use 32/64, got: %0d", XLEN);
  end

  reg [XLEN-1:0] pc, next_pc;

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin
      pc <= RESETVEC;
    end else begin
      pc <= next_pc;
    end
  end

  always_comb begin
    next_pc = pc;
  end


  /* Module Instantiations

  regfile #(.XLEN(9'd64)) regfile_a (.clk,.resetn,.we,.rs1,.rs2,.rd,.wd,.rd1,.rd2);

  */

endmodule
