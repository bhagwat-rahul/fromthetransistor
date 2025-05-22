`default_nettype none `timescale 1ns / 1ns

module baud_gen #(
    parameter int BAUD_RATE = 115200,
    int CLK_FREQ = 100000000,  // 100 MHz
    int OVS_FACTOR = 16  // Oversampling Factor
) (
    input clk,
    input reset,
    output reg baud_tick,
    output reg tick_16x
);
  localparam int unsigned DIVISORFP_16 = (CLK_FREQ << 24) / (BAUD_RATE * OVS_FACTOR);
  localparam int unsigned DIVISORINT = DIVISORFP_16[31:24];
  localparam int unsigned OVSWIDTH = $clog2(OVS_FACTOR);
  reg [31:0] acc;
  reg [OVSWIDTH-1:0] oversample_counter;
  always @(posedge clk) begin
    if (reset) begin
      acc <= 0;
      oversample_counter <= 0;
      baud_tick <= 1'b0;
      tick_16x <= 1'b0;
    end else begin
      acc <= acc + 1;
    end
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
