`default_nettype none `timescale 1ns / 1ns

module led_tb ();
  logic clk, reset, led_1;

  // Clock generation: 100 MHz
  initial clk = 0;
  always #5 clk <= ~clk;

  // Reset generation: active high for 20 ns
  initial begin
    reset = 1;
    #20 reset = 0;
  end

  // Instantiate the LED module
  led led (
      .clk  (clk),
      .reset(reset),
      .led_1(led_1)
  );
endmodule
