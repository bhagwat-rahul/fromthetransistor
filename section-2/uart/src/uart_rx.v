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

  localparam int OVSWIDTH = $clog2(16);
  logic [ OVSWIDTH-1:0] os_count;
  logic [DATA_BITS-1:0] rx_shift;


  always @(posedge clk) begin
    if (reset) begin
      rx_state   <= IDLE;
      rx_data    <= 0;
      parity_err <= 0;
      data_ready <= 0;
      frame_err  <= 0;
    end else begin
      unique case (rx_state)
        IDLE: begin
          rx_state   <= IDLE;
          rx_data    <= 0;
          parity_err <= 0;
          data_ready <= 0;
          frame_err  <= 0;
        end

        START: begin
          // TODO: Start rec
        end

        DATA: begin
          rx_state <= ODD_PARITY;
        end

        ODD_PARITY: begin
          rx_state <= STOP;
          // TODO: Parity Check
        end

        STOP: begin
          //  TODO: Stop Rec
          rx_state <= DONE;
        end

        DONE: begin
          // TODO: Done ready for idle
          rx_state <= IDLE;
        end

      endcase
    end
  end
endmodule
