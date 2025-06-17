`default_nettype none `timescale 1ns / 1ns

/**
In HW this synth's to a permanent non-volatile block of storage that the cpu will always run on reset
The purpose of the bootrom is to just get cpu in an init state to start running other stuff
**/

module bootrom #(
    parameter string INIT_FILE = "bootrom.bin",  // gen from ../bootrom.asm
    parameter logic [15:0] BROM_SIZE_BYTES = 4096,  // 4 KiB Bootrom
    parameter logic [8:0] XLEN = 9'd64,
    parameter logic [8:0] DATA_WIDTH = XLEN,
    localparam int unsigned ADDRWIDTH = $clog2(BROM_SIZE_BYTES)
) (
    input  logic                  clk,
    input  logic [ ADDRWIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] rdata
);

  logic [7:0] mem[BROM_SIZE_BYTES];

  initial $readmemb(INIT_FILE, mem);

  always_ff @(posedge clk) begin
    for (int i = 0; i < (int'(XLEN) / 8); i++) begin
      rdata[i*8+:8] <= mem[int'(addr)+i];
    end
  end

endmodule
