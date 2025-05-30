`default_nettype none `timescale 1ns / 1ns

module uart_rx_tb ();

  logic clk, reset;
  logic tick_16x, rx_pin, parity_enable;
  logic rx_data, data_ready, parity_err, frame_err;

  initial begin
    $display("Holding reset for 20ns");
    reset = 1'b1;
    #20;  // Hold reset for 20ns
    reset = 1'b0;
  end

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 100 MHz clk
    $display("Simulation started with 100MHz clock");
  end

  uart_rx uart_rx_1 (
      .clk,
      .reset,
      .tick_16x,
      .rx_pin,
      .parity_enable,

      .rx_data,  // [DATA_BITS-1:0]
      .data_ready,
      .parity_err,
      .frame_err
  );

endmodule
