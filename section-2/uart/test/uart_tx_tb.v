`default_nettype none `timescale 1ns / 1ns

module uart_tx_tb ();

  logic clk, resetn, baud_tick, send_request, parity_enable;
  logic [7:0] tx_data;
  logic tx_pin, tx_busy, tx_done;
  logic [5:0] counter;

  uart_tx tx1 (
      .clk,
      .resetn,
      .baud_tick,
      .send_request,
      .tx_data,
      .parity_enable,
      .tx_pin,
      .tx_busy,
      .tx_done
  );

  always #5 clk = ~clk;

  initial begin
    $monitor("Tx Pin: %b, state: %0d, time %0t", tx_pin, tx1.tx_state, $time);
    clk = 0;
    baud_tick = 0;
<<<<<<< Updated upstream
    resetn = 0;
    #50 resetn = 1;
=======
    resetn = 1;
    #50 resetn = 0;
>>>>>>> Stashed changes
    #100 send_request = 1;
    $display("Clocking, reset done");
    tx_data = 8'b0101_0101;
    parity_enable = 1;
    wait (baud_tick) $display("Got baud");
    wait (tx_busy == 1);
    $display("Transmission started, tx_busy asserted");
    wait (tx_done == 1);
    $display("Data bits: %b (LSB first)", tx_data);
    send_request = 0;
    #2000 $finish;
  end

  always_ff @(posedge clk or negedge resetn) begin
<<<<<<< Updated upstream
    if (!resetn) begin
=======
    if (resetn) begin
>>>>>>> Stashed changes
      counter   <= 0;
      baud_tick <= 0;
    end else begin
      if (counter == 54) begin
        counter   <= 0;
        baud_tick <= 1;
      end else begin
        counter   <= counter + 1;
        baud_tick <= 0;
      end
    end
  end

endmodule
