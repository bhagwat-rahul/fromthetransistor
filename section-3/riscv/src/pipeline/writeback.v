`default_nettype none `timescale 1ns / 1ns

// Write back

module writeback #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic             clk,
    input logic             resetn,
    input logic             stall,
    input logic             flush,
    input logic [     4:0]  rd_in,
    input logic             reg_write_enable_in,
    input logic [XLEN-1:0]  writeback_data_in,
    input logic             exception_occurred_in,
    input logic [XLEN-1:0]  exception_pc_in,
    input logic [     3:0]  exception_cause_in,

    output logic [     4:0] regfile_rd,
    output logic [XLEN-1:0] regfile_wd,
    output logic            regfile_we,
    output logic            exception_out,
    output logic [XLEN-1:0] exception_pc_out,
    output logic [     3:0] exception_cause_out
);

always_comb begin
    if (!resetn) begin
        regfile_rd          = 5'd0;
        regfile_wd          = '0;
        regfile_we          = 1'b0;
        exception_out       = 1'b0;
        exception_pc_out    = '0;
        exception_cause_out = 4'd0;
    end else begin
        regfile_rd          = rd_in;
        regfile_wd          = writeback_data_in;
        regfile_we          = reg_write_enable_in && !exception_occurred_in && !flush && !stall;
        exception_out       = exception_occurred_in && !flush;
        exception_pc_out    = exception_pc_in;
        exception_cause_out = exception_cause_in;
    end
end

endmodule
