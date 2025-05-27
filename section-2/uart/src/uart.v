`default_nettype none `timescale 1ns / 1ns

module uart (
    input logic clk,
    input logic reset
);

  // wire baud_tick, tick_16x;
  // wire rx_pin, rx_data, data_ready, parity_err, frame_err;
  // wire tx_data, send_request, tx_pin, tx_busy, tx_done;
  // wire config_bits;

  // baud_gen baud_gen_a (
  //     .clk,
  //     .reset,
  //     .baud_tick,
  //     .tick_16x
  // );

  // uart_rx uart_rx_a (
  //     .clk,
  //     .reset,
  //     .tick_16x,
  //     .rx_pin,
  //     .config_bits,
  //     .rx_data,
  //     .data_ready,
  //     .parity_err,
  //     .frame_err
  // );

  // uart_tx uart_tx_a (
  //     .clk,
  //     .reset,
  //     .baud_tick,
  //     .tx_data,
  //     .send_request,
  //     .config_bits,
  //     .tx_pin,
  //     .tx_busy,
  //     .tx_done
  // );

  always @(posedge clk) begin
    if (reset) begin

    end
  end
endmodule
