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

  localparam int unsigned INDEXWIDTH = $clog2(DATA_BITS);
  logic [INDEXWIDTH-1:0] bit_index, next_bit_index;
  logic [DATA_BITS-1:0] tx_shift, next_tx_shift;
  logic tx_pin_reg, next_tx_pin;
  logic tx_busy_reg, next_tx_busy;
  logic tx_done_reg, next_tx_done;
  fsm_e tx_state, next_tx_state;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      tx_shift    <= {DATA_BITS{1'b1}};
      tx_state    <= IDLE;
      bit_index   <= 0;
      tx_pin_reg  <= 1;
      tx_busy_reg <= 0;
      tx_done_reg <= 0;
    end else begin
      if (baud_tick) begin
        tx_state    <= next_tx_state;
        bit_index   <= next_bit_index;
        tx_shift    <= next_tx_shift;
        tx_pin_reg  <= next_tx_pin;
        tx_busy_reg <= next_tx_busy;
        tx_done_reg <= next_tx_done;
      end
    end
  end

  always_comb begin
    next_tx_state  = tx_state;
    next_bit_index = bit_index;
    next_tx_shift  = tx_shift;
    next_tx_pin    = tx_pin_reg;
    next_tx_busy   = tx_busy_reg;
    next_tx_done   = tx_done_reg;
    case (tx_state)
      default: next_tx_state = IDLE;
      IDLE: begin
        next_tx_done = 0;
        next_tx_busy = 0;
        next_tx_pin  = 1;
        if (send_request == 1) begin
          next_tx_shift = tx_data;
          next_tx_busy  = 1;
          next_tx_state = START;
        end
      end
      START: begin
        next_tx_state  = DATA;
        next_tx_pin    = 0;
        next_tx_busy   = 1;
        next_bit_index = 0;
      end
      DATA: begin
        next_tx_busy = 1;
        next_tx_pin  = tx_shift[bit_index];
        if (bit_index == (DATA_BITS - 1)) begin
          next_tx_state  = fsm_e'(parity_enable) ? ODD_PARITY : STOP;
          next_bit_index = 0;
        end else begin
          next_tx_state  = DATA;
          next_bit_index = bit_index + 1;
        end
      end
      ODD_PARITY: begin
        next_tx_pin   = ~^tx_shift;
        next_tx_busy  = 1;
        next_tx_state = STOP;
      end
      STOP: begin
        next_tx_busy  = 1;
        next_tx_pin   = 1;
        next_tx_state = DONE;
      end
      DONE: begin
        next_tx_done  = 1;
        next_tx_busy  = 0;
        next_tx_state = IDLE;
        next_tx_pin   = 1;
      end
    endcase
  end

  assign tx_pin  = tx_pin_reg;
  assign tx_busy = tx_busy_reg;
  assign tx_done = tx_done_reg;

endmodule
