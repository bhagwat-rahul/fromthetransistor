`default_nettype none `timescale 1ns / 1ns

module baud_gen #(
    parameter int BAUD_RATE = 115200,
    int CLK_FREQ = 100000000,  // 100 MHz
    int OVS_FACTOR = 16  // Oversampling Factor
) (
    input clk,
    input reset,
    output reg baud_tick,
    output reg tick_16x
);
  localparam int unsigned DIVISORFP_16 = (CLK_FREQ << 24) / (BAUD_RATE * OVS_FACTOR);
  localparam int unsigned OVSWIDTH = $clog2(OVS_FACTOR);

  reg [32:0] acc;
  reg [OVSWIDTH-1:0] oversample_counter;
  reg prev_tick_16x;

  wire raw_tick = acc[32];
  wire tick_pulse = raw_tick & ~prev_tick_16x;

  initial begin
    if ((OVS_FACTOR & (OVS_FACTOR - 1)) != 0) $error("OVS_FACTOR must be power of 2");
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      acc <= 33'd0;
      oversample_counter <= {OVSWIDTH{1'b0}};
      baud_tick <= 1'b0;
      prev_tick_16x <= 1'b0;
      tick_16x <= 1'b0;
    end else begin
      acc <= acc + {1'b0, DIVISORFP_16};
      prev_tick_16x <= raw_tick;
      tick_16x <= tick_pulse;

      if (tick_pulse) begin
        if (oversample_counter == OVSWIDTH'(OVS_FACTOR - 1)) begin  // Padding to compute ==
          oversample_counter <= {OVSWIDTH{1'b0}};
          baud_tick <= 1'b1;
        end else begin
          oversample_counter <= oversample_counter + 1'b1;
          baud_tick <= 1'b0;
        end
      end else begin
        baud_tick <= 1'b0;
      end
    end
  end
endmodule

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

module uart_rx (
    input clk,
    reset,
    tick_16x,
    rx_pin,
    config_bits,
    output logic rx_data[7:0],
    data_ready,
    parity_err,
    frame_err
);
  always @(posedge clk) begin
    if (reset) begin
    end
  end
endmodule

module uart (
    input clk,
    reset
);
  always @(posedge clk) begin
    if (reset) begin

    end
  end
endmodule
