`default_nettype none `timescale 1ns / 1ns

module led (
    input  logic clk,
    input  logic reset,
    output reg   led_1
);
  // We want to blink an led here
  reg [31:0] count;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      led_1 <= 0;
      count <= 0;
    end else if (count == 99999999) begin
      // Depends on the clock cycle:- 99999999 is 1 second on 100 MHz
      led_1 <= ~led_1;
      $display("LED toggled at time %0t ns", $time);
      count <= 0;
    end else begin
      count <= count + 1;
    end
  end
endmodule
