`default_nettype none `timescale 1ns / 1ns

module led #(
    parameter logic [31:0] CLOCK_SPEED = 1000
) (
  `ifdef SIMULATION
    input  logic clk,
  `endif
    input  logic resetn,
    output logic led_1
);

`ifdef FPGA
logic clk;
SB_HFOSC #(.CLKHF_DIV("0b10")) hfosc_inst (
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk)
);
`endif

  logic [31:0] count;

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin
      led_1 <= 0;
      count <= 0;
    end else if (count == CLOCK_SPEED) begin
      led_1 <= ~led_1;
      count <= 0;
    end else begin
      count <= count + 1;
    end
  end
endmodule
