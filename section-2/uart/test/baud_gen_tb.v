`default_nettype none `timescale 1ns / 1ns

module baud_gen_tb ();

  logic baud_tick, tick_16x, resetn, clk;

  // verilator lint_off BLKSEQ
  always #5 clk = ~clk;
  // verilator lint_on BLKSEQ


  initial begin
    clk   = 0;
    resetn = 0;
    #50 resetn = 1;
    $monitor("Time=%0t baud_tick=%b tick_16x=%b", $time, baud_tick, tick_16x);
    #700;
    $finish;
  end

  baud_gen baud_gen (
      .clk,
      .resetn,
      .baud_tick,
      .tick_16x
  );

endmodule
