`default_nettype none `timescale 1ns / 1ns

module uart_rx (
    input clk,
    reset,
    tick_16x,
    rx_pin,
    config_bits,
    output logic rx_data[7:0],
    data_ready,
    parity_err,
    frame_err
);

  always @(posedge clk) begin
    if (reset) begin
    end
  end
endmodule
