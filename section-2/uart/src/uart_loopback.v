`default_nettype none `timescale 1ns / 1ns

module uart_loopback #(
    parameter int DATA_BITS = 8,
    parameter int unsigned BAUD_RATE = 115200,
    parameter int unsigned CLK_FREQ = 100000000,  // 100 MHz
    parameter logic [4:0] OVS_FACTOR = 16
) (
  `ifdef SIMULATION_RUN
    input  logic        clk,
  `endif
    input  logic        resetn,
    input  logic        send_request,
    input  logic [7:0]  tx_data,
    input  logic        parity_enable,

    output logic [7:0]  rx_data,
    output logic        data_ready,
    output logic        parity_err,
    output logic        frame_err,
    output logic        tx_busy,
    output logic        tx_done
);

    logic tx_pin_loop;

    uart #(
        .DATA_BITS  (DATA_BITS),
        .BAUD_RATE  (BAUD_RATE),
        .CLK_FREQ   (CLK_FREQ),
        .OVS_FACTOR (OVS_FACTOR)
    ) uart_inst (
      `ifdef SIMULATION_RUN
        .clk           (clk),
      `endif
        .resetn        (resetn),
        .rx_pin        (tx_pin_loop),   // Loopback connection!
        .send_request  (send_request),
        .tx_data       (tx_data),
        .parity_enable (parity_enable),
        .rx_data       (rx_data),
        .data_ready    (data_ready),
        .parity_err    (parity_err),
        .frame_err     (frame_err),
        .tx_pin        (tx_pin_loop),   // Output drives rx_pin
        .tx_busy       (tx_busy),
        .tx_done       (tx_done)
    );

endmodule
