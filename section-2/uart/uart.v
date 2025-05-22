module baud_gen #(
    parameter int BAUD_RATE = 115200,
    int CLK_FREQ = 100000000,  // 100 MHz
    int OVS_FACTOR = 16  // Oversampling Factor
) (
    input  clk,
    reset,
    output tick_16x
);
  localparam int DIVISORFP_16 = (CLK_FREQ << 16) / (BAUD_RATE * OVS_FACTOR);  // float divisor
  always @(posedge clk) begin
  end
endmodule

module uart_tx (
    input  clk,
    reset,
    baud_tick,
    tx_data[7:0],
    send_request,
    config_bits,
    output tx_pin,
    tx_busy,
    tx_done
);
endmodule

module uart_rx (
    input  clk,
    reset,
    tick_16x,
    rx_pin,
    config_bits,
    output rx_data[7:0],
    data_ready,
    parity_err,
    frame_err
);
endmodule

module uart (
    input clk,
    reset
);
endmodule
