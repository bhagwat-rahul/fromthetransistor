`default_nettype none `timescale 1ns / 1ns

// Write back

module writeback #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic clk,
    input logic resetn
);
  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin

    end else begin

    end
  end

  always_comb begin

  end

endmodule
