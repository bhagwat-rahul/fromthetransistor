`default_nettype none `timescale 1ns / 1ns

module baud_gen #(
    parameter int unsigned BAUD_RATE = 115200,
    parameter int unsigned CLK_FREQ = 100000000,  // 100 MHz
    parameter logic [4:0] OVS_FACTOR = 16  // Oversampling Factor
) (
    input  logic clk,
    input  logic resetn,
    output logic baud_tick,
    output logic tick_16x
);
/* verilator lint_off WIDTHEXPAND */
  localparam logic [47:0] DIVISORFP_16 = (CLK_FREQ << 16) / (BAUD_RATE * OVS_FACTOR);
  localparam int unsigned OVSWIDTH = $clog2(OVS_FACTOR);
/* verilator lint_on WIDTHEXPAND */

  logic [48:0] acc;
  logic [OVSWIDTH-1:0] oversample_counter;
  logic prev_tick_16x, raw_tick, tick_pulse;

  assign raw_tick   = acc[16];
  assign tick_pulse = (raw_tick ^ prev_tick_16x);

  initial begin
    if ((OVS_FACTOR & (OVS_FACTOR - 1)) != 0)
      $fatal(1, "OVS_FACTOR must be power of 2, got %0d", OVS_FACTOR);
  end

  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      acc <= 49'd0;
      oversample_counter <= {OVSWIDTH{1'b0}};
      baud_tick <= 1'b0;
      prev_tick_16x <= 1'b0;
      tick_16x <= 1'b0;
    end else begin
      acc <= acc + {1'b0, DIVISORFP_16};
      prev_tick_16x <= raw_tick;
      tick_16x <= tick_pulse;
      if (tick_pulse) begin
        if (oversample_counter == OVSWIDTH'(int'(OVS_FACTOR) - 1)) begin  // Padding to compute ==
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
