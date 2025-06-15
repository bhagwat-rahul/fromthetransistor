`default_nettype none `timescale 1ns / 1ns

module baud_gen_tb ();

  logic baud_tick, tick_16x, reset, clk;

  // verilator lint_off BLKSEQ
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ


  initial begin
    clk   = 0;
    reset = 1;
    #50 reset = 0;
    $monitor("Time=%0t baud_tick=%b tick_16x=%b", $time, baud_tick, tick_16x);
    #100000;
    $finish;
  end

  baud_gen baud_gen (
      .clk,
      .reset,
      .baud_tick,
      .tick_16x
  );

endmodule
