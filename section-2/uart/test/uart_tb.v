`default_nettype none `timescale 1ns / 1ns

module uart_tb ();

  logic clk, reset, rx_pin, send_request, parity_enable;  // ins
  logic frame_err, tx_pin, tx_busy, tx_done, data_ready, parity_err;  // outs
  logic [7:0] tx_data, rx_data;
  initial parity_enable = 1;  // or 1, depending on your test


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

  initial begin
    $display("bout to reset");
    reset = 1'b1;  // Assert reset
    #10;
    reset = 1'b0;  // De-assert reset after 10ns
    $display("done reset");
  end

  initial begin
    $display("WE clocking");
    clk = 1'b0;
    forever #5 clk = ~clk;  // Toggle every 1 time units (period = 2)
  end

  initial begin
    $display("we here");
    tx_data = 8'b1101_0011;
    send_request = 1;
    @(posedge clk);
    send_request = 0;
    // Wait for data_ready from receiver
    $display("we waiting");
    wait (data_ready == 1);
    $display("done waiting");
    // Check if received data matches transmitted data
    if (rx_data === tx_data)
      $display("Test Passed: Received data matches transmitted data: %b", rx_data);
    else
      $display(
          "Test Failed: Received data (%b) does not match transmitted data (%b)", rx_data, tx_data
      );

    // Optionally, finish simulation
    $finish;
  end

endmodule
