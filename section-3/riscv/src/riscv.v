`default_nettype none `timescale 1ns / 1ns

module riscv (
    input clk,
    input reset
);

  localparam int unsigned ADDRWIDTH = 8;
  localparam int unsigned DATAWIDTH = 64;

  logic [ADDRWIDTH-1:0] bromaddr;
  logic [DATAWIDTH-1:0] bromrdata;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // TODO: Random inits, fix
      bromaddr  <= 0;
      bromrdata <= 0;
    end else begin

    end
  end

  always_comb begin

  end

  bootrom #(
      .INIT_FILE ("bootrom.bin"),  // gen from ../bootrom.asm
      .ADDR_WIDTH(ADDRWIDTH),
      .DATA_WIDTH(DATAWIDTH)
  ) bootrom (
      .clk,
      .addr (bromaddr),
      .rdata(bromrdata)
  );

endmodule
