`default_nettype none `timescale 1ns / 1ns

module memory_controller #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic clk,
    input logic resetn
);

always @(posedge clk or negedge resetn) begin
  if (!resetn) begin

  end else begin

  end
end

always_comb begin

end

endmodule
