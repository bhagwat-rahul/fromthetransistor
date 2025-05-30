`default_nettype none `timescale 1ns / 1ns

module uart_rx_tb ();

  logic clk, reset;
  logic tick_16x, rx_pin, parity_enable;
  logic [7:0] rx_data;
  logic data_ready, parity_err, frame_err;

  initial begin
    reset = 1'b1;
    $display("Holding reset for 20ns");
    #20;
    reset = 1'b0;
  end

  initial begin
    clk = 1'b0;
    $display("Simulation starting with 100MHz clock");
    forever #5 clk = ~clk;
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
