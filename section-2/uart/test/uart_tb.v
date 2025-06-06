`default_nettype none `timescale 1ns / 1ns

module uart_tb ();

  logic clk, reset, rx_pin, send_request, parity_enable;
  logic frame_err, tx_pin, tx_busy, tx_done, data_ready, parity_err;
  logic [7:0] tx_data, rx_data;
  initial parity_enable = 1;

  uart uart (
      .clk(clk),
      .reset(reset),
      .rx_pin(rx_pin),
      .send_request(send_request),
      .tx_data(tx_data),
      .parity_enable(parity_enable),

      .rx_data(rx_data),
      .data_ready(data_ready),
      .parity_err(parity_err),
      .frame_err(frame_err),
      .tx_pin(tx_pin),
      .tx_busy(tx_busy),
      .tx_done(tx_done)
  );

  always_comb rx_pin = tx_pin;
  always #5 clk = ~clk;

  initial begin
    clk = 1'b0;
    $display("bout to reset at time:- %0t", $time);
    reset = 1'b1;
    #10 reset = 1'b0;
    $display("done reset at time:- %0t", $time);
    $finish;
  end

endmodule
