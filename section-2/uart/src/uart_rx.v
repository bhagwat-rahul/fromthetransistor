`default_nettype none `timescale 1ns / 1ns

module uart_rx #(
    parameter logic [3:0] DATA_BITS  = 8,  // Max 15
    parameter logic [4:0] OVS_FACTOR = 16  // Max 31
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

  logic [OVSWIDTH-1:0] os_count;
  logic [DATA_BITS-1:0] rx_shift;
  logic [BITINDEXWIDTH-1:0] bit_index;
  logic midsample = (os_count == OVSWIDTH'(MIDSAMPLE));
  logic lasttick = (os_count == OVSWIDTH'(LASTTICK));

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
    end else begin
      rx_state <= next_rx_state;
    end
  end

  always_comb begin
    case (rx_state)
      default: next_rx_state = IDLE;
      IDLE: ;
      START: ;
      DATA: ;
      ODD_PARITY: ;
      STOP: ;
      DONE: ;
    endcase
  end

endmodule
