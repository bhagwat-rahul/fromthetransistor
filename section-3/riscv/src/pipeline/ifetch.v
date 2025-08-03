`default_nettype none `timescale 1ns / 1ns

// Instruction Fetch

module ifetch #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic            clk,
    input logic            resetn,
    input logic            pc_valid,
    input logic            stall,
    input logic            flush,
    input logic            imem_valid,
    input logic            imem_ready,
    input logic            imem_err,
    input logic [XLEN-1:0] pc_next,
    /* verilator lint_off UNUSEDSIGNAL */
    input logic [XLEN-1:0] imem_data,   // TODO : Handle top 32 bit if using RV C ext, etc.
    /* verilator lint_on UNUSEDSIGNAL */

    output logic            imem_req,
    output logic            instr_valid,
    output logic [    31:0] instruction,
    output logic [    31:0] imem_addr,
    output logic [XLEN-1:0] pc_current

);

  typedef enum {
    IDLE,
    REQ,
    WAIT_RESP,
    DONE
  } ifetch_fsm_t;
  ifetch_fsm_t state, next_state;

  logic [XLEN-1:0] pc_current_r, next_pc_current_r;
  logic [31:0] instruction_r, imem_addr_r, next_instruction_r, next_imem_addr_r;
  logic imem_req_r, instr_valid_r, next_imem_req_r, next_instr_valid_r;

  always_ff @(posedge clk or negedge resetn) begin
    if (resetn == 0) begin
      state <= IDLE;
      pc_current_r  <= '0;
      instruction_r <= 32'b0;
      instr_valid_r <= 1'b0;
      imem_req_r    <= 1'b0;
      imem_addr_r   <= 32'b0;
    end else begin
      state         <= next_state;
      pc_current_r  <= next_pc_current_r;
      instruction_r <= next_instruction_r;
      instr_valid_r <= next_instr_valid_r;
      imem_req_r    <= next_imem_req_r;
      imem_addr_r   <= next_imem_addr_r;
    end
  end

  always_comb begin
    next_state = state;
    next_pc_current_r = pc_current_r;
    next_instruction_r = instruction_r;
    next_instr_valid_r = instr_valid_r;
    next_imem_req_r = imem_req_r;
    next_imem_addr_r = imem_addr_r;
    case (state)
      default: next_state = IDLE;
      IDLE: begin
        next_imem_req_r = 0;
        next_instr_valid_r = 0;
        next_state = (pc_valid == 1 && !stall && !flush) ? REQ : IDLE;
      end
      REQ: begin
        next_pc_current_r  = pc_next;
        next_instr_valid_r = 0;
        next_imem_addr_r   = pc_next[31:0];
        next_imem_req_r    = 1;
        next_state         = WAIT_RESP;  // TODO: Handle memfetch delays once we scale
      end
      WAIT_RESP: begin
        next_imem_req_r = 1;
        next_instr_valid_r = 0;
        // Capture instruction when memory is ready
        if (imem_valid && imem_ready && !imem_err && !flush) begin
          next_instruction_r = (pc_current_r[2] ? imem_data[63:32] : imem_data[31:0]);
        end
        next_state = (imem_valid && imem_ready && !imem_err) ?
        (flush ? IDLE : DONE) : (flush ? IDLE : WAIT_RESP)
            ;  // TODO: Handle err cases properly later
      end
      DONE: begin
        next_imem_req_r = 0;
        next_instr_valid_r = (flush) ? 0 : 1;
        // Instruction was already captured in WAIT_RESP, just clear if flushed
        if (flush) next_instruction_r = 32'b0;
        next_state = stall ? DONE : flush ? IDLE : pc_valid ? REQ : IDLE;
      end
    endcase
  end

  assign imem_req    = imem_req_r;
  assign instr_valid = instr_valid_r;
  assign instruction = instruction_r;
  assign pc_current  = pc_current_r;
  assign imem_addr   = imem_addr_r;

endmodule
