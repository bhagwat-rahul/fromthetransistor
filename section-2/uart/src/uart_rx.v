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
  logic [DATA_BITS-1:0] rx_shift;
  logic [BITINDEXWIDTH-1:0] bit_index, next_bit_index;
  logic midsample;
  logic lasttick;
  logic lastbit;
  logic next_data_ready, next_parity_err, next_frame_err;
  logic parity_err_reg, data_ready_reg, frame_err_reg;
  logic [DATA_BITS-1:0] rx_data_reg, next_rx_data_reg;

  initial begin
    if ((OVS_FACTOR & (OVS_FACTOR - 1)) != 0)
      $fatal(1, "OVS_FACTOR must be power of 2, got %0d", OVS_FACTOR);
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      rx_state       <= IDLE;
      os_count       <= 0;
      rx_shift       <= 0;
      bit_index      <= 0;
      frame_err_reg  <= 0;
      rx_data_reg    <= 0;
      parity_err_reg <= 0;
      data_ready_reg <= 0;
    end else if (tick_16x) begin
      rx_data_reg    <= next_rx_data_reg;
      rx_state       <= next_rx_state;
      os_count       <= next_os_count;
      bit_index      <= next_bit_index;
      data_ready_reg <= next_data_ready;
      parity_err_reg <= next_parity_err;
      frame_err_reg  <= next_frame_err;
    end
  end

  always_comb begin
    lasttick = (os_count == OVSWIDTH'(LASTTICK));
    midsample = (os_count == OVSWIDTH'(MIDSAMPLE));
    lastbit = (bit_index == BITINDEXWIDTH'(DATA_BITS - 1));
    next_rx_state    = rx_state;
    next_os_count    = os_count;
    next_bit_index   = bit_index;
    next_data_ready  = 0;
    next_parity_err  = parity_err_reg;
    next_frame_err   = frame_err_reg;
    next_rx_data_reg = rx_data_reg;
    if (rx_state == IDLE) begin
      next_rx_state   = fsm_e'((rx_pin == 0) ? START : IDLE);
      next_os_count   = 0;
      next_parity_err = 0;
      next_frame_err  = 0;
    end else if (lasttick) begin
      next_os_count = 0;
      case (rx_state)
        default: next_rx_state = IDLE;
        START: begin
          next_rx_state = DATA;
        end
        DATA: begin
          if (lastbit) begin
            next_rx_state = fsm_e'((parity_enable) ? ODD_PARITY : STOP);
            next_rx_data_reg[bit_index] = rx_pin;
            next_bit_index = 0;
          end else begin
            next_bit_index = bit_index + 1;
            next_rx_data_reg[bit_index] = rx_pin;
          end
        end
        ODD_PARITY: begin
          next_parity_err = ~(^rx_data_reg ^ rx_pin);
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
    end else begin
      next_os_count = os_count + 1;
    end
  end

  assign rx_data    = rx_data_reg;
  assign parity_err = parity_err_reg;
  assign data_ready = data_ready_reg;
  assign frame_err  = frame_err_reg;

endmodule
