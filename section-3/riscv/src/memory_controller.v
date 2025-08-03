`default_nettype none `timescale 1ns / 1ns

module memory_controller #(
    parameter logic [8:0] XLEN = 9'd64,
    parameter int unsigned MEM_DEPTH = 262144  // 1MB = 256K words
) (
    input logic clk,
    input logic resetn,
    input  logic            imem_req,
    input  logic [    31:0] imem_addr,
    input  logic [XLEN-1:0] mem_addr,
    input  logic [XLEN-1:0] mem_wdata,
    input  logic            mem_read_req,
    input  logic            mem_write_req,
    input  logic [     2:0] mem_size,
    input  logic            mem_signed,

    output logic            imem_valid,
    output logic            imem_ready,
    output logic            imem_err,
    output logic [XLEN-1:0] imem_data,
    output logic [XLEN-1:0] mem_rdata,
    output logic            mem_ready,
    output logic            mem_error
);

localparam logic [3:0]
NOP  = 4'b0000,
ADD  = 4'b0001,
SUB  = 4'b0010,
AND  = 4'b0011,
OR   = 4'b0100,
XOR  = 4'b0101,
SLL  = 4'b0110,
SRL  = 4'b0111,
SRA  = 4'b1000,
SLT  = 4'b1001,
SLTU = 4'b1010;

localparam logic [2:0] BEQ = 3'h0, BNE = 3'h1, BLT = 3'h4, BGE = 3'h5, BLTU = 3'h6, BGEU = 3'h7;

localparam logic [6:0]
R     = 7'b0110011,
I     = 7'b0010011,
J     = 7'b1101111,
JALRI = 7'b1100111,
LUI   = 7'b0110111,
AUIPC = 7'b0010111;

localparam logic [2:0]
CSRRW  = 3'b001,
CSRRS  = 3'b010,
CSRRC  = 3'b011,
CSRRWI = 3'b101,
CSRRSI = 3'b110,
CSRRCI = 3'b111;

localparam logic[2:0]
BYTE   = 3'd0,
HALF   = 3'd1,
WORD   = 3'd2,
DOUBLE = 3'd3;


  // SRAM interface signals
  logic sram_we;
  logic [$clog2(MEM_DEPTH)-1:0] sram_addr;
  logic [XLEN-1:0] sram_data_in, sram_data_out;

  sram #(
      .XLEN (XLEN),
      .DEPTH(MEM_DEPTH)
  ) main_memory (
      .clk(clk),
      .we(sram_we),
      .addr(sram_addr),
      .data_in(sram_data_in),
      .data_out(sram_data_out)
  );

  // Memory controller state machine
  typedef enum logic [1:0] {
    IDLE,
    INST_ACCESS,
    DATA_ACCESS
  } mem_state_t;

  mem_state_t state, next_state;

  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    next_state   = IDLE;
    sram_we      = 1'b0;
    sram_addr    = '0;
    sram_data_in = '0;
    imem_valid   = 1'b0;
    imem_ready   = 1'b0;
    imem_err     = 1'b0;
    imem_data    = '0;
    mem_ready    = 1'b0;
    mem_error    = 1'b0;
    mem_rdata    = '0;

    case (state)
      default: next_state = IDLE;

      IDLE: begin
        if (imem_req) begin
          next_state = INST_ACCESS;
          sram_addr = imem_addr[2+$clog2(MEM_DEPTH):3];  // Convert byte address to 64-bit word address
          sram_we = 1'b0;
        end else if (mem_read_req || mem_write_req) begin
          next_state = DATA_ACCESS;
          sram_addr = mem_addr[2+$clog2(MEM_DEPTH):3];   // Convert byte address to 64-bit word address
          sram_we = mem_write_req;
          sram_data_in = mem_wdata;
        end
      end

      INST_ACCESS: begin
        imem_data  = sram_data_out;
        imem_valid = 1'b1;
        imem_ready = 1'b1;
        next_state = IDLE;
      end

      DATA_ACCESS: begin
        if (mem_read_req) begin
          // Handle different load sizes with sign extension
          case (mem_size)
            BYTE: begin
              if (mem_signed) mem_rdata = {{(XLEN - 8) {sram_data_out[7]}}, sram_data_out[7:0]};
              else mem_rdata = {{(XLEN - 8) {1'b0}}, sram_data_out[7:0]};
            end
            HALF: begin
              if (mem_signed) mem_rdata = {{(XLEN - 16) {sram_data_out[15]}}, sram_data_out[15:0]};
              else mem_rdata = {{(XLEN - 16) {1'b0}}, sram_data_out[15:0]};
            end
            WORD: begin
              if (mem_signed) mem_rdata = {{(XLEN - 32) {sram_data_out[31]}}, sram_data_out[31:0]};
              else mem_rdata = {{(XLEN - 32) {1'b0}}, sram_data_out[31:0]};
            end
            DOUBLE: begin
              mem_rdata = sram_data_out;
            end
            default: mem_rdata = sram_data_out;
          endcase
        end
        mem_ready  = 1'b1;
        next_state = IDLE;
      end
    endcase
  end

endmodule
