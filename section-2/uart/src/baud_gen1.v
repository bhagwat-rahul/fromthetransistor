`default_nettype none `timescale 1ns / 1ns

module baud_gen1 #(
    parameter logic [31:0] CLK_FREQ = 100000000,  // Maz ~ 4294 MHz
    parameter logic [17:0] BAUD_RATE = 115200,  // Upto 18 bits for flex
    parameter logic [4:0] OVS_FACTOR = 16  // Max upto 16 since 5 bits
) (
    input  logic clk,
    input  logic reset,
    output logic baud_tick,
    output logic tick_16x
);

  localparam logic [31:0] BAUDDIVISOR = CLK_FREQ / (BAUD_RATE * OVS_FACTOR);

  logic [31:0] count;
  logic [ 4:0] oversample_count;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      $display("reset");
      count <= 32'b0;
      oversample_count <= 0;
      tick_16x <= 0;
      baud_tick <= 0;
    end else begin
      // $display("clocking at time: 0%t ns and count %b", $time, count);
      baud_tick <= 0;  // Default: clear every cycle
      tick_16x <= 0;
      count <= count + 1;
      if (count == BAUDDIVISOR) begin
        $display("count = baud");
        oversample_count <= oversample_count + 1;
        tick_16x <= 1;
        count <= 0;
        $display("tick16 at : ", $time);
        if (oversample_count == OVS_FACTOR) begin
          baud_tick <= 1;
          $display("baud");
          oversample_count <= 0;
        end
      end
    end
  end
endmodule

module baud1_tb ();

  logic baud_tick, tick_16x, reset, clk;

  initial begin
    reset = 1'b1;
    #20;  // Hold reset for 20ns
    reset = 1'b0;
  end

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 10ns period, 100MHz clock
  end
  baud_gen1 baud_gen1 (
      .clk,
      .reset,
      .baud_tick,
      .tick_16x
  );
endmodule
