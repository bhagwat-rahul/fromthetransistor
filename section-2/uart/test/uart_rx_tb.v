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
    $monitor(
        "RX Data: %b and rx_pin: %b, frame err: %b, data_ready: %b, state: %0d, os_count: %0d, time: %0t",
        rx_data, rx_pin, frame_err, data_ready, uart_rx_1.rx_state, uart_rx_1.os_count, $time);
    clk = 0;
    reset = 1;
    rx_pin = 1;
    parity_enable = 1;
    #50 reset = 0;
    $display("reset done!");
    wait_ticks(16);
    send_uart_frame(8'b0100_1110, 1);
    wait_ticks(34);
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

  task automatic send_uart_frame(input logic [7:0] data, input logic parity);
    int i;
    // Start bit
    rx_pin = 0;
    wait_ticks(16);
    // Data bits (LSB first)
    for (i = 0; i < 8; i++) begin
      rx_pin = data[i];
      wait_ticks(16);
    end
    // Parity bit
    rx_pin = parity;
    wait_ticks(16);
    // Stop bit
    rx_pin = 1;
    wait_ticks(16);
  endtask

  task automatic wait_ticks(input int num_ticks);
    int count;
    begin
      count = 0;
      while (count < num_ticks) begin
        @(posedge clk);
        if (tick_16x) count++;
      end
    end
  endtask

endmodule
