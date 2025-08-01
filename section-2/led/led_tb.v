`default_nettype none `timescale 1ns / 1ns

module led_tb ();
  logic clk, resetn, led_1;

  always #5 clk <= ~clk;

  initial begin
    $dumpfile("obj_dir/led_tb.vcd");
    $dumpvars(0, led);
    $monitor("LED 1: %b at time %0t", led.led_1, $time);
    clk    = 0;
    resetn = 0;
    #100
    resetn = 1;
    $display("resetn done");
    #1000000
    $finish;
  end

  led # (
   .CLOCK_SPEED(1000)
  ) led (
      .clk  (clk),
      .resetn(resetn),
      .led_1(led_1)
  );
endmodule
