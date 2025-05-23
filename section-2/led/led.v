`default_nettype none `timescale 1ns / 1ns

module led (
    input clk,
    output reg led_1
);
  // We want to blink an led here
  reg [31:0] count;
  always @(posedge clk) begin
    if (count == 99999999) begin  // Depends on the clock cycle:- 99999999 is 1 second on 100 MHz
      led_1 <= ~led_1;
      count <= 0;
    end else begin
      count <= count + 1;
    end
  end
endmodule
