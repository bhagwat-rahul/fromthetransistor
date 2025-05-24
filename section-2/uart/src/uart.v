`default_nettype none `timescale 1ns / 1ns

module uart (
    input clk,
    reset
);

  wire baud_tick_1;
  wire tick_16x_1;

  baud_gen baud_gen_a (
      .clk(clk),
      .reset(reset),
      .baud_tick(baud_tick_1),
      .tick_16x(tick_16x_1)
  );

  always @(posedge clk) begin
    if (reset) begin

    end
  end
endmodule
