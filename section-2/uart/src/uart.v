`default_nettype none `timescale 1ns / 1ns

module uart #(
    parameter int DATA_BITS = 8,
    parameter int unsigned BAUD_RATE = 115200,
    parameter int unsigned CLK_FREQ = 100000000,  // 100 MHz
    parameter logic [4:0] OVS_FACTOR = 16
) (
  `ifdef SIMULATION_RUN
    input  logic clk,
  `endif
    input logic       resetn,
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

`ifdef FPGA_RUN
logic clk;
SB_HFOSC #(.CLKHF_DIV("0b10")) hfosc_inst (
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk)
);
`endif

  logic baud_tick, tick_16x;

  initial begin
    if ((OVS_FACTOR & (OVS_FACTOR - 1)) != 0)
      $fatal(1, "OVS_FACTOR must be power of 2, got %0d", OVS_FACTOR);
    if (DATA_BITS > 15) $fatal(1, "DATA_BITS must be 15 or below, got %0d", DATA_BITS);
    if (CLK_FREQ > 100000000) $fatal(1, "CLK_FREQ must be below 100MHz, got %0d", DATA_BITS);
    if (BAUD_RATE % 9600 != 0 || BAUD_RATE < 9600 || BAUD_RATE > 115200)
      $fatal(1, "BAUD_RATE must be multiple of 9600 upto 115200, got:- %0d", BAUD_RATE);
  end

  baud_gen #(
      .BAUD_RATE (BAUD_RATE),
      .CLK_FREQ  (CLK_FREQ),
      .OVS_FACTOR(OVS_FACTOR)
  ) baud_gen_a (
      .clk(clk),
      .resetn(resetn),
      .baud_tick(baud_tick),
      .tick_16x(tick_16x)
  );

  uart_rx #(
      .DATA_BITS (DATA_BITS),
      .OVS_FACTOR(OVS_FACTOR)
  ) uart_rx_a (
      .clk(clk),
      .resetn(resetn),
      .tick_16x(tick_16x),
      .rx_pin(rx_pin),
      .parity_enable(parity_enable),
      .rx_data(rx_data),
      .data_ready(data_ready),
      .parity_err(parity_err),
      .frame_err(frame_err)
  );

  uart_tx #(
      .DATA_BITS(DATA_BITS)
  ) uart_tx_a (
      .clk(clk),
      .resetn(resetn),
      .baud_tick(baud_tick),
      .tx_data(tx_data),
      .send_request(send_request),
      .parity_enable(parity_enable),
      .tx_pin(tx_pin),
      .tx_busy(tx_busy),
      .tx_done(tx_done)
  );
endmodule
