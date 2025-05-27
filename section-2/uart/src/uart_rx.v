`default_nettype none `timescale 1ns / 1ns

module uart_rx #(
    parameter int DATA_BITS = 8
) (
    input logic clk,
    input logic reset,
    input logic tick_16x,
    input logic rx_pin,
    input logic parity_enable,
    output logic [DATA_BITS-1:0] rx_data,
    output logic data_ready,
    output logic parity_err,
    output logic frame_err
);

  typedef enum {
    IDLE,
    START,
    DATA,
    ODD_PARITY,
    STOP,
    DONE
  } fsm_e;
  fsm_e rx_state;

  always @(posedge clk) begin
    if (reset) begin
    end
  end
endmodule
