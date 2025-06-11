`default_nettype none `timescale 1ns / 1ns

/**
In HW this synth's to a permanent non-volatile block of storage that the cpu will always run on reset
The purpose of the bootrom is to just get cpu in an init state to start running other stuff
**/

module bootrom #(
    parameter string       INIT_FILE  = "bootrom.bin",  // gen from ../bootrom.asm
    parameter int unsigned ADDR_WIDTH = 8,
    parameter int unsigned DATA_WIDTH = 64
) (
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] rdata
);

  logic [DATA_WIDTH-1:0] mem[(1<<ADDR_WIDTH)-1];

  initial begin
    if (!(DATA_WIDTH % 8 == 0)) begin
      $fatal(0, "DATA_WIDTH must be a byte (8) multiple, got: (%0d)", DATA_WIDTH);
    end
    $readmemb(INIT_FILE, mem);
  end

  always_ff @(posedge clk) begin
    rdata <= mem[addr];
  end

endmodule
