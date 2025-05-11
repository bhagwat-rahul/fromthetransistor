module led (
    input clk,
    output reg led
);
  // We want to blink an led here
  always @(posedge clk) begin
    led <= 1;
  end
endmodule
