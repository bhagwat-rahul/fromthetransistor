`default_nettype none `timescale 1ns / 1ns

module uart_tx (
    input clk,
    reset,
    baud_tick,
    logic tx_data[7:0],
    send_request,
    config_bits,
    output logic tx_pin,
    tx_busy,
    tx_done
);

  typedef enum {
    IDLE,
    START,
    DATA,
    EVEN_PARITY,  // Even number of 1s including parity bit
    STOP,
    DONE
  } fsm_e;
  fsm_e state;

  reg [2:0] bit_index;
  reg [7:0] shift;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      tx_pin <= 1'b1;
      shift  <= 8'b1111_1111;
    end else begin
      unique case (state)
        IDLE: begin
          tx_busy <= 1'b0;
          tx_pin  <= 1'b1;
          if (send_request == 1) begin
            shift   <= tx_data;
            tx_busy <= 1'b1;
            state   <= START;
          end
        end
        START, DATA, EVEN_PARITY, STOP, DONE: begin
          if (baud_tick) begin
            unique case (state)
              START: begin
                tx_pin <= 1'b0;
                state  <= DATA;
              end
              DATA: begin
                tx_pin <= shift[bit_index-1];
                if (bit_index < 3'b111) begin
                  bit_index <= bit_index + 1;
                end else begin
                  state <= EVEN_PARITY;
                  bit_index <= 3'b000;
                end
              end
              EVEN_PARITY: begin
                tx_pin <= 1'b1;  // TODO: Complete even or odd parity
                state  <= STOP;
              end
              STOP: begin
                tx_pin <= 1'b1;
                state  <= DONE;
              end
              DONE: begin
                state <= IDLE;
              end
            endcase
          end
        end
      endcase
    end
  end
endmodule
