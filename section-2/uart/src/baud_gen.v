`default_nettype none `timescale 1ns / 1ns

module baud_gen #(
    parameter int unsigned BAUD_RATE = 115200,
    int unsigned CLK_FREQ = 100000000,  // 100 MHz
    int unsigned OVS_FACTOR = 16  // Oversampling Factor
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
