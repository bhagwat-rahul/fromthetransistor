`default_nettype none `timescale 1ns / 1ns

module uart_loopback_tb ();

initial begin
  clk = 0;
  resetn = 0;
  #100 resetn = 1;
  $display("loopback test started, reset done");
  $monitor("rx data: %b", rx_data);
  tx_data = 8'b1101_0101;
  send_request = 1;
  #20;  // 2 clock cycles
  send_request = 0;
  #100000
  $finish;
end

logic [7:0]  tx_data, rx_data;
logic clk, resetn, send_request, parity_enable;
logic data_ready, parity_err, frame_err, tx_busy, tx_done;

always #5 clk = ~clk;


uart_loopback #(
    .DATA_BITS(8),
    .BAUD_RATE(115200),
    .CLK_FREQ(100000000),  // 100 MHz
    .OVS_FACTOR(16)
) dut (
  `ifdef SIMULATION_RUN
    .clk(clk),
  `endif
    .resetn(resetn),
    .send_request(send_request),
    .tx_data(tx_data),
    .parity_enable(parity_enable),

    .rx_data(rx_data),
    .data_ready(data_ready),
    .parity_err(parity_err),
    .frame_err(frame_err),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

endmodule;
