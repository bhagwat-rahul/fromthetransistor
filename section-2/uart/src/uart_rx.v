`default_nettype none `timescale 1ns / 1ns

module uart_rx (
    input logic clk,
    input logic reset,
    input logic tick_16x,
    input logic rx_pin,
    input logic config_bits,
    output logic rx_data[7:0],
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
  fsm_e state;

  always @(posedge clk) begin
    if (reset) begin
    end
  end
endmodule
