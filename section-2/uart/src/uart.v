`default_nettype none `timescale 1ns / 1ns

module uart (
    input logic       clk,
    input logic       reset,
    input logic       rx_pin,
    input logic       send_request,
    input logic [7:0] tx_data,
    input logic       parity_enable,

    output logic [7:0] rx_data,
    output logic       data_ready,
    output logic       parity_err,
    output logic       frame_err,
    output logic       tx_pin,
    output logic       tx_busy,
    output logic       tx_done
);

  logic baud_tick, tick_16x;

  baud_gen baud_gen_a (
      .clk(clk),
      .reset(reset),
      .baud_tick(baud_tick),
      .tick_16x(tick_16x)
  );

  uart_rx uart_rx_a (
      .clk(clk),
      .reset(reset),
      .tick_16x(tick_16x),
      .rx_pin(rx_pin),
      .parity_enable(parity_enable),
      .rx_data(rx_data),
      .data_ready(data_ready),
      .parity_err(parity_err),
      .frame_err(frame_err)
  );

  uart_tx uart_tx_a (
      .clk(clk),
      .reset(reset),
      .baud_tick(baud_tick),
      .tx_data(tx_data),
      .send_request(send_request),
      .parity_enable(parity_enable),
      .tx_pin(tx_pin),
      .tx_busy(tx_busy),
      .tx_done(tx_done)
  );
endmodule
