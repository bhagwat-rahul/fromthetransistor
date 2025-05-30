`default_nettype none `timescale 1ns / 1ns

module uart_tx #(
    parameter int DATA_BITS = 8
) (
    input  logic                 clk,
    input  logic                 reset,
    input  logic                 baud_tick,
    input  logic                 send_request,
    input  logic [DATA_BITS-1:0] tx_data,
    input  logic                 parity_enable,
    output logic                 tx_pin,
    output logic                 tx_busy,
    output logic                 tx_done
);

  typedef enum {
    IDLE,
    START,
    DATA,
    ODD_PARITY,
    STOP,
    DONE
  } fsm_e;
  fsm_e tx_state;

  localparam int unsigned INDEXWIDTH = $clog2(DATA_BITS);
  logic [INDEXWIDTH-1:0] bit_index;
  logic [ DATA_BITS-1:0] tx_shift;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      tx_pin <= 1'b1;
      tx_shift <= {DATA_BITS{1'b1}};
      tx_state <= IDLE;
      bit_index <= 0;
      tx_busy <= 0;
      tx_done <= 0;

    end else begin
      case (tx_state)
        default: begin
          tx_state <= IDLE;
        end
        IDLE: begin
          tx_done <= 0;
          tx_busy <= 1'b0;
          tx_pin  <= 1'b1;
          if (send_request == 1) begin
            tx_shift <= tx_data;
            tx_busy  <= 1'b1;
            tx_state <= START;
          end
        end
        START, DATA, ODD_PARITY, STOP, DONE: begin
          if (baud_tick) begin
            case (tx_state)
              default: begin
                tx_state <= IDLE;
              end
              START: begin
                tx_pin <= 1'b0;
                tx_busy <= 1;
                bit_index <= 0;
                tx_state <= DATA;
              end
              DATA: begin
                tx_busy <= 1;
                tx_pin  <= tx_shift[bit_index];
                if (bit_index == INDEXWIDTH'(DATA_BITS - 1)) begin
                  if (parity_enable) begin
                    tx_state <= ODD_PARITY;
                  end else begin
                    tx_state <= STOP;
                  end
                end else begin
                  bit_index <= bit_index + 1;
                end
              end
              ODD_PARITY: begin
                tx_pin   <= ~^tx_shift;  // To complete odd parity
                tx_state <= STOP;
              end
              STOP: begin
                tx_busy  <= 1;
                tx_pin   <= 1'b1;
                tx_state <= DONE;
              end
              DONE: begin
                tx_done  <= 1;
                tx_busy  <= 0;
                tx_state <= IDLE;
              end
            endcase
          end
        end
      endcase
    end
  end
endmodule
