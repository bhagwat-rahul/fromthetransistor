`default_nettype none `timescale 1ns / 1ns

// | Clock Cycle | IF stage       | ID stage        | EX stage         | MEM stage           | WB stage            |
// | ----------- | -------------- | --------------- | ---------------- | ------------------- | ------------------- |
// | 1           | Fetch Instr #1 | —               | —                | —                   | —                   |
// | 2           | Fetch Instr #2 | Decode Instr #1 | —                | —                   | —                   |
// | 3           | Fetch Instr #3 | Decode Instr #2 | Execute Instr #1 | —                   | —                   |
// | 4           | Fetch Instr #4 | Decode Instr #3 | Execute Instr #2 | Mem Access Instr #1 | —                   |
// | 5           | Fetch Instr #5 | Decode Instr #4 | Execute Instr #3 | Mem Access Instr #2 | Write Back Instr #1 |

module riscv #(
    parameter logic [63:0] RESETVEC = 64'hx8000_0000
) (
    input clk,
    input resetn
);

  reg [63:0] pc, next_pc;

  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      pc <= RESETVEC;
    end else begin
      pc <= next_pc;
    end
  end

  always_comb begin
    next_pc = pc;  // stay the same if nothing
  end

endmodule
