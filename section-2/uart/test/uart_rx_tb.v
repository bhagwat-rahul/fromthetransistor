`default_nettype none `timescale 1ns / 1ns

module uart_rx_tb ();

  logic clk, reset;
  logic tick_16x, rx_pin, parity_enable;
  logic [7:0] rx_data;
  logic data_ready, parity_err, frame_err;
  logic [1:0] counter;

  uart_rx uart_rx_1 (
      .clk,
      .reset,
      .tick_16x,
      .rx_pin,
      .parity_enable,
      .rx_data,
      .data_ready,
      .parity_err,
      .frame_err
  );

  always #5 clk = ~clk;

  initial begin
    clk   = 0;
    reset = 1;
    #50 reset = 0;
    $display("reset done!");
    wait (tick_16x) $display("Got tick");
    rx_pin = 0;
    $monitor("RX Data is: %b", rx_data);
    $finish;
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter  <= 0;
      tick_16x <= 0;
    end else begin
      if (counter == 3) begin
        counter  <= 0;
        tick_16x <= 1;
      end else begin
        counter  <= counter + 1;
        tick_16x <= 0;
      end
    end
  end
endmodule
