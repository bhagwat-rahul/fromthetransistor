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
  fsm_e rx_state;

  localparam logic [31:0] OVSWIDTH = $clog2(OVS_FACTOR);
  localparam logic [31:0] BITINDEXWIDTH = $clog2(DATA_BITS);

  localparam logic [4:0] MIDSAMPLE = OVS_FACTOR / 2;
  localparam logic [4:0] LASTTICK = OVS_FACTOR - 1;

  logic [OVSWIDTH-1:0] os_count;
  logic [DATA_BITS-1:0] rx_shift;
  logic [BITINDEXWIDTH-1:0] bit_index;
  logic prev_rx_pin;

  logic midsample = (os_count == OVSWIDTH'(MIDSAMPLE));
  logic lasttick = (os_count == OVSWIDTH'(LASTTICK));

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      rx_state    <= IDLE;
      frame_err   <= 0;
      rx_data     <= 0;
      parity_err  <= 0;
      data_ready  <= 0;
      prev_rx_pin <= 1;
      os_count    <= 0;
      rx_shift    <= 0;
      bit_index   <= 0;
    end else begin
      prev_rx_pin <= rx_pin;
      case (rx_state)
        default: begin
          rx_state <= IDLE;
        end
        IDLE: begin
          os_count   <= 0;
          rx_data    <= 0;
          parity_err <= 0;
          data_ready <= 0;
          frame_err  <= 0;
          if (prev_rx_pin && !rx_pin) begin
            rx_state <= START;
            os_count <= 0;
          end
        end
        START, DATA, ODD_PARITY, STOP, DONE: begin
          if (tick_16x) begin
            os_count <= os_count + 1;
            case (rx_state)
              default: begin
                rx_state <= IDLE;
              end
              START: begin
                if (midsample) begin
                  if (rx_pin == 1'b0) begin
                    os_count  <= 0;
                    bit_index <= 0;
                    rx_state  <= DATA;
                  end else begin
                    rx_state <= IDLE;
                  end
                end
              end

              DATA: begin
                if (midsample) begin
                  rx_shift[bit_index] <= rx_pin;
                end
                if (lasttick) begin
                  os_count <= 0;
                  if (bit_index == BITINDEXWIDTH'(DATA_BITS - 1)) begin
                    rx_state  <= fsm_e'(parity_enable ? ODD_PARITY : STOP);
                    bit_index <= 0;
                  end else begin
                    bit_index <= bit_index + 1;
                  end
                end
              end

              ODD_PARITY: begin
                if (midsample) begin
                  parity_err <= (rx_pin !== ~^rx_shift);
                end
                if (lasttick) begin
                  os_count <= 0;
                  rx_state <= STOP;
                end
              end

              STOP: begin
                if (midsample) begin
                  frame_err <= ~rx_pin;
                end
                if (lasttick) begin
                  os_count <= 0;
                  rx_state <= DONE;
                end
              end

              DONE: begin
                data_ready <= 1;
                rx_data <= rx_shift;
                rx_state <= IDLE;
              end
            endcase
          end
        end
      endcase
    end
  end
endmodule
