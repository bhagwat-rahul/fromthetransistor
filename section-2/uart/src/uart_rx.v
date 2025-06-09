`default_nettype none `timescale 1ns / 1ns

module uart_rx #(
    parameter logic [3:0] DATA_BITS  = 8,
    parameter logic [4:0] OVS_FACTOR = 16
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
  fsm_e rx_state, next_rx_state;

  localparam logic [31:0] OVSWIDTH = $clog2(OVS_FACTOR);
  localparam logic [31:0] BITINDEXWIDTH = $clog2(DATA_BITS);
  localparam logic [4:0] MIDSAMPLE = OVS_FACTOR / 2;
  localparam logic [4:0] LASTTICK = OVS_FACTOR - 1;

  logic [OVSWIDTH-1:0] os_count, next_os_count;
  logic [DATA_BITS-1:0] rx_shift, next_rx_shift;
  logic [BITINDEXWIDTH-1:0] bit_index, next_bit_index;
  logic midsample = (os_count == OVSWIDTH'(MIDSAMPLE));
  logic lasttick = (os_count == OVSWIDTH'(LASTTICK));
  logic lastbit = (bit_index == BITINDEXWIDTH'(DATA_BITS - 1));
  logic next_data_ready, next_parity_err, next_frame_err;

  initial begin
    if ((OVS_FACTOR & (OVS_FACTOR - 1)) != 0)
      $fatal(1, "OVS_FACTOR must be power of 2, got %0d", OVS_FACTOR);
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      rx_state   <= IDLE;
      frame_err  <= 0;
      rx_data    <= 0;
      parity_err <= 0;
      data_ready <= 0;
      os_count   <= 0;
      rx_shift   <= 0;
      bit_index  <= 0;
    end else if (tick_16x) begin
      rx_state   <= next_rx_state;
      os_count   <= next_os_count;
      bit_index  <= next_bit_index;
      rx_shift   <= next_rx_shift;
      data_ready <= next_data_ready;
      parity_err <= next_parity_err;
      frame_err  <= next_frame_err;
    end
  end

  always_comb begin
    next_rx_state   = rx_state;
    next_os_count   = os_count;
    next_bit_index  = bit_index;
    next_rx_shift   = rx_shift;
    next_data_ready = 0;
    next_parity_err = parity_err;
    next_frame_err  = frame_err;
    case (rx_state)
      default: next_rx_state = IDLE;
      IDLE: begin
        next_rx_state   = fsm_e'((rx_pin == 0) ? START : IDLE);
        next_os_count   = 0;
        next_rx_shift   = 0;
        next_parity_err = 0;
        next_frame_err  = 0;
      end
      START: begin

      end
      DATA: begin  // TODO: Handling of samples is incorrect fix
        if (lastbit) begin
          next_rx_shift[bit_index] = rx_pin;
          next_rx_state            = fsm_e'((parity_enable) ? ODD_PARITY : STOP);
          next_bit_index           = 0;
        end else if (midsample) begin
          next_rx_state            = DATA;
          next_rx_shift[bit_index] = rx_pin;
          next_bit_index           = bit_index + 1;
        end else begin

        end
      end
      ODD_PARITY: begin
        next_parity_err = ~^rx_shift;
        next_rx_state   = STOP;
      end
      STOP: begin
        next_frame_err = (rx_pin == 0) ? 1 : 0;
        next_rx_state  = DONE;
      end
      DONE: begin
        next_data_ready = 1;
        next_rx_state   = IDLE;
      end
    endcase
  end

endmodule
