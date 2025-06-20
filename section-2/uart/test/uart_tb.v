`default_nettype none `timescale 1ns / 1ns

module uart_tb ();
  // Clock and reset
  logic clk, reset;

  // UART signals
  logic uart_line;  // Connect TX to RX
  logic send_request, parity_enable;
  logic [7:0] tx_data, rx_data;
  logic data_ready, parity_err, frame_err;
  logic tx_busy, tx_done;

  // Test control
  int test_count = 0;
  int pass_count = 0;

  // Instantiate two UART modules for loopback test
  uart #(
      .DATA_BITS (8),
      .BAUD_RATE (115200),
      .CLK_FREQ  (100000000),
      .OVS_FACTOR(16)
  ) uart_tx_inst (
      .clk          (clk),
      .reset        (reset),
      .rx_pin       (1'b1),           // Not used for TX
      .send_request (send_request),
      .tx_data      (tx_data),
      .parity_enable(parity_enable),
      .rx_data      (),               // Not used
      .data_ready   (),               // Not used
      .parity_err   (),               // Not used
      .frame_err    (),               // Not used
      .tx_pin       (uart_line),
      .tx_busy      (tx_busy),
      .tx_done      (tx_done)
  );

  uart #(
      .DATA_BITS (8),
      .BAUD_RATE (115200),
      .CLK_FREQ  (100000000),
      .OVS_FACTOR(16)
  ) uart_rx_inst (
      .clk          (clk),
      .reset        (reset),
      .rx_pin       (uart_line),
      .send_request (1'b0),           // Not used for RX
      .tx_data      (8'h00),          // Not used
      .parity_enable(parity_enable),
      .rx_data      (rx_data),
      .data_ready   (data_ready),
      .parity_err   (parity_err),
      .frame_err    (frame_err),
      .tx_pin       (),               // Not used
      .tx_busy      (),               // Not used
      .tx_done      ()                // Not used
  );

  // Clock generation
  always #5 clk = ~clk;

  // Main test sequence
  initial begin
    $display("=== UART Loopback Test Started ===");

    // Initialize signals
    clk = 0;
    reset = 1;
    send_request = 0;
    tx_data = 8'h00;
    parity_enable = 0;

    // Reset sequence
    #100 reset = 0;
    #200;

    // Test cases
    test_byte(8'h55, 0, "Alternating pattern without parity");
    test_byte(8'hAA, 0, "Alternating pattern without parity");
    test_byte(8'h00, 0, "All zeros without parity");
    test_byte(8'hFF, 0, "All ones without parity");
    test_byte(8'h5A, 1, "Mixed pattern with parity");
    test_byte(8'hA5, 1, "Mixed pattern with parity");
    test_byte(8'h0F, 1, "Low nibble with parity");
    test_byte(8'hF0, 1, "High nibble with parity");

    // Final results
    #1000;
    $display("\n=== Test Results ===");
    $display("Total Tests: %0d", test_count);
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", test_count - pass_count);

    if (pass_count == test_count) $display("*** ALL TESTS PASSED ***");
    else $display("*** SOME TESTS FAILED ***");

    $finish;
  end

  // Test task for sending and verifying a byte
  task automatic test_byte(input logic [7:0] data, input logic parity, input string description);
    begin
      test_count++;
      $display("\nTest %0d: %s", test_count, description);
      $display("Sending: 0x%02h (0b%08b)", data, data);

      // Configure test
      parity_enable = parity;
      tx_data = data;

      // Send data
      send_data(data);

      // Wait for reception
      wait_for_reception();

      // Verify results
      verify_reception(data, parity, description);
    end
  endtask

  // Task to send data
  task automatic send_data(input logic [7:0] data);
    begin
      // Initiate transmission
      send_request = 1;

      // Wait for transmission to start
      wait (tx_busy == 1);
      $display("Transmission started at time %0t", $time);

      // Clear send request
      send_request = 0;

      // Wait for transmission to complete
      wait (tx_done == 1);
      $display("Transmission completed at time %0t", $time);
    end
  endtask

  // Task to wait for data reception and capture data
  logic [7:0] captured_rx_data;
  logic captured_parity_err, captured_frame_err;

  task automatic wait_for_reception();
    begin
      // Wait for data_ready signal
      wait (data_ready == 1);
      $display("Data received at time %0t", $time);

      // Capture data while data_ready is high
      captured_rx_data = rx_data;
      captured_parity_err = parity_err;
      captured_frame_err = frame_err;

      // Wait for data_ready to go low (end of reception cycle)
      wait (data_ready == 0);
    end
  endtask

  // Task to verify received data
  task automatic verify_reception(input logic [7:0] expected_data, input logic parity,
                                  input string description);
    begin
      logic expected_parity;

      // Calculate expected parity (odd parity)
      expected_parity = ~^expected_data;

      $display("Expected: 0x%02h, Received: 0x%02h", expected_data, captured_rx_data);

      // Check data integrity
      if (captured_rx_data == expected_data) begin
        $display("✓ Data match");

        // Check error flags
        if (captured_frame_err) begin
          $display("✗ Frame error detected");
        end else if (parity && captured_parity_err) begin
          $display("✗ Parity error detected");
        end else begin
          $display("✓ No errors detected");
          pass_count++;
          $display("*** PASS ***");
          return;
        end
      end else begin
        $display("✗ Data mismatch");
      end

      $display("*** FAIL ***");
    end
  endtask

  // Monitor for debugging
  initial begin
    $monitor("Time=%0t | TX_PIN=%b | RX_DATA=0x%02h | DATA_READY=%b | PARITY_ERR=%b | FRAME_ERR=%b",
             $time, uart_line, rx_data, data_ready, parity_err, frame_err);
  end

  // Timeout watchdog
  initial begin
    #100000;  // 100us timeout
    $display("ERROR: Test timeout!");
    $finish;
  end

endmodule
