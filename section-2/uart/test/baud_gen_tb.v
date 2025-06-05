`default_nettype none `timescale 1ns / 1ns

module baud_gen_tb ();

  logic baud_tick, tick_16x, reset, clk;

  initial begin
    clk = 0;
    baud_tick = 0;
    tick_16x = 0;
    reset = 1;
    #50 reset = 0;
  end

  always #5 clk = ~clk;  // 10ns period, 100MHz clock
  initial $monitor("Time=%0t baud_tick=%b tick_16x=%b", $time, baud_tick, tick_16x);

  baud_gen baud_gen (
      .clk,
      .reset,
      .baud_tick,
      .tick_16x
  );

endmodule
