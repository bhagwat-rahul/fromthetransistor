`default_nettype none `timescale 1ns / 1ns

// Memory Access

module memacc #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic clk,
    input logic resetn,

    // Pipeline control
    input logic stall,
    input logic flush,

    // From exec stage
    input logic [XLEN-1:0] alu_result,
    input logic [XLEN-1:0] rs2_data,
    input logic [XLEN-1:0] pc_in,
    input logic [     4:0] rd,
    input logic [     2:0] funct3,
    input logic            reg_write_enable,
    input logic            mem_read,
    input logic            mem_write,
    input logic [     3:0] trap_cause_in,
    input logic            trap_in,
    input logic [    11:0] csr_addr,
    input logic [XLEN-1:0] csr_wdata,
    input logic            csr_read,
    input logic            csr_write,

    // Memory interface
    output logic [XLEN-1:0] mem_addr,
    output logic [XLEN-1:0] mem_wdata,
    output logic            mem_read_req,
    output logic            mem_write_req,
    output logic [     2:0] mem_size,       // 0=byte, 1=half, 2=word, 3=double
    output logic            mem_signed,
    input  logic [XLEN-1:0] mem_rdata,
    input  logic            mem_ready,
    input  logic            mem_error,

    // To writeback stage
    output logic [     4:0] rd_out,
    output logic            reg_write_enable_out,
    output logic [XLEN-1:0] writeback_data,
    output logic [XLEN-1:0] pc_out,

    // Exception/trap propagation (only if needed for trap handling)
    output logic            exception_occurred,
    output logic [XLEN-1:0] exception_pc,
    output logic [     3:0] exception_cause,

    // CSR pass-through (only if CSR writes happen in writeback)
    output logic [    11:0] csr_addr_out,
    output logic [XLEN-1:0] csr_wdata_out,
    output logic            csr_write_out
);

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin

    end else begin

    end
  end

  always_comb begin

  end

  assign rd_out        = rd;
  assign pc_out        = pc_in;
  assign csr_addr_out  = csr_addr;
  assign csr_wdata_out = csr_wdata;
  assign csr_write_out = csr_write;

endmodule
