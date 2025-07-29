`default_nettype none `timescale 1ns / 1ns

// Memory Access

module memacc #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic             clk,
    input logic             resetn,
    input logic             stall,
    input logic             flush,
    input logic [XLEN-1:0]  alu_result,
    input logic [XLEN-1:0]  rs2_data,
    input logic [XLEN-1:0]  pc_in,
    input logic [     4:0]  rd,
    input logic [     2:0]  funct3,
    input logic             reg_write_enable,
    input logic             mem_read,
    input logic             mem_write,
    input logic [     3:0]  trap_cause_in,
    input logic             trap_in,
    input logic [    11:0]  csr_addr,
    input logic [XLEN-1:0]  csr_wdata,
    input logic             csr_read,
    input logic             csr_write,
    input logic [XLEN-1:0]  mem_rdata,
    input logic             mem_ready,
    input logic             mem_error,

    output logic [XLEN-1:0] mem_addr,
    output logic [XLEN-1:0] mem_wdata,
    output logic            mem_read_req,
    output logic            mem_write_req,
    output logic [     2:0] mem_size,       // 0=byte, 1=half, 2=word, 3=double
    output logic            mem_signed,
    output logic [     4:0] rd_out,
    output logic            reg_write_enable_out,
    output logic [XLEN-1:0] writeback_data,
    output logic [XLEN-1:0] pc_out,
    output logic            exception_occurred,
    output logic [XLEN-1:0] exception_pc,
    output logic [     3:0] exception_cause,
    output logic [    11:0] csr_addr_out,
    output logic [XLEN-1:0] csr_wdata_out,
    output logic            csr_write_out
);

logic [XLEN-1:0] mem_addr_reg, mem_addr_reg_next;
logic [XLEN-1:0] mem_wdata_reg, mem_wdata_reg_next;
logic            mem_read_req_reg, mem_req_reg_next;
logic            mem_write_req_reg, mem_write_req_reg_next;
logic [     2:0] mem_size, mem_size_reg, mem_size_reg_next;
logic            mem_signed_reg, mem_signed_reg_next;
logic [     4:0] rd_out_reg, rd_out_reg_next;
logic            reg_write_enable_out_reg, reg_write_enable_out_reg_next;
logic [XLEN-1:0] writeback_data_reg, writeback_data_reg_next;
logic [XLEN-1:0] pc_out_reg, pc_out_reg_next;
logic            exception_occurred_reg, exception_occurred_reg_next;
logic [XLEN-1:0] exception_pc_reg, exception_pc_reg_next;
logic [     3:0] exception_cause_reg, exception_cause_reg_next;
logic [    11:0] csr_addr_out_reg, csr_addr_out_reg_next;
logic [XLEN-1:0] csr_wdata_out_reg, csr_wdata_out_reg_next;
logic            csr_write_out_reg, csr_write_out_reg_next;

always_ff @(posedge clk or negedge resetn) begin
  if (resetn == 0) begin
    mem_addr_reg           <= '0;
    mem_wdata_reg          <= '0;
    mem_read_req_reg       <= 1'b0;
    mem_write_req_reg      <= 1'b0;
    mem_size_reg           <= 3'd0;
    mem_signed_reg         <= 1'b0;
    rd_out_reg             <= 5'd0;
    reg_write_enable_out_reg <= 1'b0;
    writeback_data_reg     <= '0;
    pc_out_reg             <= '0;
    exception_occurred_reg <= 1'b0;
    exception_pc_reg       <= '0;
    exception_cause_reg    <= 4'd0;
    csr_addr_out_reg       <= 12'd0;
    csr_wdata_out_reg      <= '0;
    csr_write_out_reg      <= 1'b0;
  end else if (flush) begin
    mem_addr_reg           <= '0;
    mem_wdata_reg          <= '0;
    mem_read_req_reg       <= 1'b0;
    mem_write_req_reg      <= 1'b0;
    mem_size_reg           <= 3'd0;
    mem_signed_reg         <= 1'b0;
    rd_out_reg             <= 5'd0;
    writeback_data_reg     <= '0;
    pc_out_reg             <= '0;
    exception_occurred_reg <= 1'b0;
    exception_pc_reg       <= '0;
    exception_cause_reg    <= 4'd0;
    csr_addr_out_reg       <= 12'd0;
    csr_wdata_out_reg      <= '0;
    csr_write_out_reg      <= 1'b0;
    reg_write_enable_out_reg <= 1'b0;

  end else if (!stall) begin
    mem_addr_reg           <= mem_addr_reg_next;
    mem_wdata_reg          <= mem_wdata_reg_next;
    mem_read_req_reg       <= mem_read_req_reg_next;
    mem_write_req_reg      <= mem_write_req_reg_next;
    mem_size_reg           <= mem_size_reg_next;
    mem_signed_reg         <= mem_signed_reg_next;
    rd_out_reg             <= rd_out_reg_next;
    writeback_data_reg     <= writeback_data_reg_next;
    pc_out_reg             <= pc_out_reg_next;
    exception_occurred_reg <= exception_occurred_reg_next;
    exception_pc_reg       <= exception_pc_reg_next;
    exception_cause_reg    <= exception_cause_reg_next;
    csr_addr_out_reg       <= csr_addr_out_reg_next;
    csr_wdata_out_reg      <= csr_wdata_out_reg_next;
    csr_write_out_reg      <= csr_write_out_reg_next;
    reg_write_enable_out_reg <= reg_write_enable_out_reg_next;
  end
end

always_comb begin
  // Default: pass through previous values (for stall case)
  mem_addr_reg_next           = mem_addr_reg;
  mem_wdata_reg_next          = mem_wdata_reg;
  mem_read_req_reg_next       = mem_read_req_reg;
  mem_write_req_reg_next      = mem_write_req_reg;
  mem_size_reg_next           = mem_size_reg;
  mem_signed_reg_next         = mem_signed_reg;
  rd_out_reg_next             = rd_out_reg;
  writeback_data_reg_next     = writeback_data_reg;
  pc_out_reg_next             = pc_out_reg;
  exception_occurred_reg_next = exception_occurred_reg;
  exception_pc_reg_next       = exception_pc_reg;
  exception_cause_reg_next    = exception_cause_reg;
  csr_addr_out_reg_next       = csr_addr_out_reg;
  csr_wdata_out_reg_next      = csr_wdata_out_reg;
  csr_write_out_reg_next      = csr_write_out_reg;
  reg_write_enable_out_reg_next = reg_write_enable_out_reg;

  // Update with new values from execute stage
  mem_addr_reg_next           = alu_result;
  mem_wdata_reg_next          = rs2_data;
  mem_read_req_reg_next       = mem_read;
  mem_write_req_reg_next      = mem_write;
  mem_signed_reg_next         = (funct3[2] == 1'b0); // signed if bit 2 is 0
  rd_out_reg_next             = rd;
  pc_out_reg_next             = pc_in;
  exception_occurred_reg_next = trap_in;
  exception_pc_reg_next       = pc_in;
  exception_cause_reg_next    = trap_cause_in;
  csr_addr_out_reg_next       = csr_addr;
  csr_wdata_out_reg_next      = csr_wdata;
  csr_write_out_reg_next      = csr_write;
  reg_write_enable_out_reg_next = reg_write_enable;

  // Set memory size based on funct3
  unique case (funct3[1:0])
    2'b00: mem_size_reg_next = 3'd0; // byte
    2'b01: mem_size_reg_next = 3'd1; // half
    2'b10: mem_size_reg_next = 3'd2; // word
    2'b11: mem_size_reg_next = 3'd3; // double
  endcase

  // Select writeback data
  if (mem_read && mem_ready) begin
    // Process loaded data based on size and signedness
    writeback_data_reg_next = process_load_data(mem_rdata, funct3);
  end else begin
    // For non-load instructions, pass through ALU result
    writeback_data_reg_next = alu_result;
  end
end

// Output assignments
assign mem_addr            = mem_addr_reg;
assign mem_wdata           = mem_wdata_reg;
assign mem_read_req        = mem_read_req_reg;
assign mem_write_req       = mem_write_req_reg;
assign mem_size            = mem_size_reg;
assign mem_signed          = mem_signed_reg;
assign rd_out              = rd_out_reg;
assign writeback_data      = writeback_data_reg;
assign pc_out              = pc_out_reg;
assign exception_occurred  = exception_occurred_reg;
assign exception_pc        = exception_pc_reg;
assign exception_cause     = exception_cause_reg;
assign csr_addr_out        = csr_addr_out_reg;
assign csr_wdata_out       = csr_wdata_out_reg;
assign csr_write_out       = csr_write_out_reg;
assign reg_write_enable_out = reg_write_enable_out_reg;

endmodule
