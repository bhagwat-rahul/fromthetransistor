`default_nettype none
`timescale 1ns / 1ns

// Control and Status Register (CSR) Unit
// Implements RISC-V Machine Mode CSRs

module csr_unit #(
    parameter logic [8:0] XLEN = 9'd64
) (
    input logic             clk,
    input logic             resetn,

    // CSR Interface from Memory Stage
    input logic [    11:0]  csr_addr,
    input logic [XLEN-1:0]  csr_wdata,
    input logic             csr_read,
    input logic             csr_write,

    // Exception/Interrupt Interface
    input logic             exception_occurred,
    input logic [XLEN-1:0]  exception_pc,
    input logic [     3:0]  exception_cause,
    input logic             mret_instruction,

    // External Interrupts
    input logic             external_interrupt,
    input logic             timer_interrupt,
    input logic             software_interrupt,

    // Performance Counters
    input logic             instruction_retired,

    // CSR Outputs
    output logic [XLEN-1:0] csr_rdata,
    output logic            csr_access_fault,

    // Trap Vector and Control
    output logic [XLEN-1:0] trap_vector,
    output logic            trap_taken,
    output logic [XLEN-1:0] trap_pc,

    // Global Interrupt Enable
    output logic            global_interrupt_enable
);

  // ========================================================================
  // CSR Address Definitions (Machine Mode)
  // ========================================================================

  // Machine Information Registers
  localparam logic [11:0] CSR_MVENDORID = 12'hF11;
  localparam logic [11:0] CSR_MARCHID   = 12'hF12;
  localparam logic [11:0] CSR_MIMPID    = 12'hF13;
  localparam logic [11:0] CSR_MHARTID   = 12'hF14;

  // Machine Trap Setup
  localparam logic [11:0] CSR_MSTATUS   = 12'h300;
  localparam logic [11:0] CSR_MISA      = 12'h301;
  localparam logic [11:0] CSR_MIE       = 12'h304;
  localparam logic [11:0] CSR_MTVEC     = 12'h305;

  // Machine Trap Handling
  localparam logic [11:0] CSR_MSCRATCH  = 12'h340;
  localparam logic [11:0] CSR_MEPC      = 12'h341;
  localparam logic [11:0] CSR_MCAUSE    = 12'h342;
  localparam logic [11:0] CSR_MTVAL     = 12'h343;
  localparam logic [11:0] CSR_MIP       = 12'h344;

  // Machine Counters
  localparam logic [11:0] CSR_MCYCLE    = 12'hB00;
  localparam logic [11:0] CSR_MINSTRET  = 12'hB02;
  localparam logic [11:0] CSR_MCYCLEH   = 12'hB80;  // Upper 32 bits (RV32 only)
  localparam logic [11:0] CSR_MINSTRETH = 12'hB82;  // Upper 32 bits (RV32 only)

  // ========================================================================
  // CSR Storage Registers
  // ========================================================================

  // Machine Status Register (mstatus)
  logic             mstatus_mie;      // Machine Interrupt Enable
  logic             mstatus_mpie;     // Previous Machine Interrupt Enable
  logic [1:0]       mstatus_mpp;      // Previous Privilege Mode (11=Machine)

  // Machine ISA Register (misa) - Read Only
  logic [1:0]       misa_mxl;         // Machine XLEN
  logic [25:0]      misa_extensions;  // Supported extensions

  // Machine Interrupt Enable (mie)
  logic             mie_meie;         // Machine External Interrupt Enable
  logic             mie_mtie;         // Machine Timer Interrupt Enable
  logic             mie_msie;         // Machine Software Interrupt Enable

  // Machine Trap Vector (mtvec)
  logic [XLEN-3:0]  mtvec_base;       // Base address
  logic [1:0]       mtvec_mode;       // Vector mode (0=Direct, 1=Vectored)

  // Machine Trap Handling
  logic [XLEN-1:0]  mscratch;         // Machine Scratch Register
  logic [XLEN-1:0]  mepc;             // Machine Exception PC
  logic             mcause_interrupt; // Interrupt flag
  logic [XLEN-2:0]  mcause_code;      // Exception/Interrupt code
  logic [XLEN-1:0]  mtval;            // Machine Trap Value

  // Machine Interrupt Pending (mip) - Some bits read-only
  logic             mip_meip;         // Machine External Interrupt Pending
  logic             mip_mtip;         // Machine Timer Interrupt Pending
  logic             mip_msip;         // Machine Software Interrupt Pending

  // Performance Counters
  logic [63:0]      mcycle;           // Machine Cycle Counter
  logic [63:0]      minstret;         // Machine Instructions Retired Counter

  // Machine Information (Read-Only)
  logic [XLEN-1:0]  mvendorid;        // Vendor ID
  logic [XLEN-1:0]  marchid;          // Architecture ID
  logic [XLEN-1:0]  mimpid;           // Implementation ID
  logic [XLEN-1:0]  mhartid;          // Hardware Thread ID

  // ========================================================================
  // Internal Signals
  // ========================================================================

  logic csr_write_valid;
  logic csr_read_valid;
  logic interrupt_pending;
  logic take_trap;

  // ========================================================================
  // CSR Access Control
  // ========================================================================

  always_comb begin
    csr_write_valid = 1'b0;
    csr_read_valid = 1'b0;
    csr_access_fault = 1'b0;

    // Check if CSR address is valid and accessible
    case (csr_addr)
      // Machine Information Registers (Read-Only)
      CSR_MVENDORID, CSR_MARCHID, CSR_MIMPID, CSR_MHARTID: begin
        csr_read_valid = csr_read;
        csr_write_valid = 1'b0;  // Read-only
        if (csr_write) csr_access_fault = 1'b1;
      end

      // Machine Trap Setup
      CSR_MSTATUS, CSR_MISA, CSR_MIE, CSR_MTVEC: begin
        csr_read_valid = csr_read;
        csr_write_valid = csr_write;
      end

      // Machine Trap Handling
      CSR_MSCRATCH, CSR_MEPC, CSR_MCAUSE, CSR_MTVAL, CSR_MIP: begin
        csr_read_valid = csr_read;
        csr_write_valid = csr_write;
      end

      // Machine Counters
      CSR_MCYCLE, CSR_MINSTRET: begin
        csr_read_valid = csr_read;
        csr_write_valid = csr_write;
      end

      // Upper 32-bit counters (RV32 only)
      CSR_MCYCLEH, CSR_MINSTRETH: begin
        if (XLEN == 32) begin
          csr_read_valid = csr_read;
          csr_write_valid = csr_write;
        end else begin
          csr_access_fault = csr_read || csr_write;
        end
      end

      default: begin
        csr_access_fault = csr_read || csr_write;
      end
    endcase
  end

  // ========================================================================
  // CSR Read Logic
  // ========================================================================

  always_comb begin
    csr_rdata = '0;

    if (csr_read_valid) begin
      case (csr_addr)
        // Machine Information
        CSR_MVENDORID: csr_rdata = mvendorid;
        CSR_MARCHID:   csr_rdata = marchid;
        CSR_MIMPID:    csr_rdata = mimpid;
        CSR_MHARTID:   csr_rdata = mhartid;

        // Machine Status
        CSR_MSTATUS: begin
          csr_rdata = '0;
          csr_rdata[3]    = mstatus_mie;   // MIE
          csr_rdata[7]    = mstatus_mpie;  // MPIE
          csr_rdata[12:11] = mstatus_mpp;  // MPP
        end

        // Machine ISA
        CSR_MISA: begin
          if (XLEN == 64) begin
            csr_rdata = {2'b10, 36'b0, misa_extensions};  // MXL=10 for RV64
          end else begin
            csr_rdata = {{(XLEN-32){1'b0}}, 2'b01, 4'b0, misa_extensions};   // MXL=01 for RV32
          end
        end

        // Machine Interrupt Enable
        CSR_MIE: begin
          csr_rdata = '0;
          csr_rdata[11] = mie_meie;  // MEIE
          csr_rdata[7]  = mie_mtie;  // MTIE
          csr_rdata[3]  = mie_msie;  // MSIE
        end

        // Machine Trap Vector
        CSR_MTVEC: begin
          csr_rdata = {mtvec_base, mtvec_mode};
        end

        // Machine Trap Handling
        CSR_MSCRATCH: csr_rdata = mscratch;
        CSR_MEPC:     csr_rdata = mepc;
        CSR_MCAUSE:   csr_rdata = {mcause_interrupt, mcause_code};
        CSR_MTVAL:    csr_rdata = mtval;

        // Machine Interrupt Pending
        CSR_MIP: begin
          csr_rdata = '0;
          csr_rdata[11] = mip_meip;  // MEIP
          csr_rdata[7]  = mip_mtip;  // MTIP
          csr_rdata[3]  = mip_msip;  // MSIP
        end

        // Machine Counters
        CSR_MCYCLE: begin
          if (XLEN == 64) begin
            csr_rdata = mcycle;
          end else begin
            csr_rdata = {{(XLEN-32){1'b0}}, mcycle[31:0]};
          end
        end

        CSR_MINSTRET: begin
          if (XLEN == 64) begin
            csr_rdata = minstret;
          end else begin
            csr_rdata = {{(XLEN-32){1'b0}}, minstret[31:0]};
          end
        end

        // Upper 32-bit counters (RV32 only)
        CSR_MCYCLEH: begin
          if (XLEN == 32) begin
            csr_rdata = {{(XLEN-32){1'b0}}, mcycle[63:32]};
          end
        end

        CSR_MINSTRETH: begin
          if (XLEN == 32) begin
            csr_rdata = {{(XLEN-32){1'b0}}, minstret[63:32]};
          end
        end

        default: csr_rdata = '0;
      endcase
    end
  end

  // ========================================================================
  // Interrupt Logic
  // ========================================================================

  always_comb begin
    // Update interrupt pending bits (external sources)
    mip_meip = external_interrupt;
    mip_mtip = timer_interrupt;
    mip_msip = software_interrupt;

    // Check for pending and enabled interrupts
    interrupt_pending = (mip_meip & mie_meie) |
                       (mip_mtip & mie_mtie) |
                       (mip_msip & mie_msie);

    // Take interrupt if globally enabled and interrupt pending
    take_trap = exception_occurred || (interrupt_pending && mstatus_mie);

    // Global interrupt enable output
    global_interrupt_enable = mstatus_mie;
  end

  // ========================================================================
  // Trap Handling Logic
  // ========================================================================

  always_comb begin
    trap_taken = take_trap;
    trap_pc = mepc;  // PC to return to after trap

    // Calculate trap vector
    if (mtvec_mode == 2'b00) begin
      // Direct mode - same vector for all traps
      trap_vector = {mtvec_base, 2'b00};
    end else begin
      // Vectored mode - different vectors for interrupts
      if (interrupt_pending && mstatus_mie) begin
        // Interrupt vector = base + 4 * cause
        if (mip_msip & mie_msie) begin
          trap_vector = {mtvec_base, 2'b00} + ({{(XLEN-4){1'b0}}, 4'd3} << 2);
        end else if (mip_mtip & mie_mtie) begin
          trap_vector = {mtvec_base, 2'b00} + ({{(XLEN-4){1'b0}}, 4'd7} << 2);
        end else if (mip_meip & mie_meie) begin
          trap_vector = {mtvec_base, 2'b00} + ({{(XLEN-4){1'b0}}, 4'd11} << 2);
        end else begin
          trap_vector = {mtvec_base, 2'b00};
        end
      end else begin
        // Exception - use base address
        trap_vector = {mtvec_base, 2'b00};
      end
    end
  end

  // ========================================================================
  // CSR Update Logic
  // ========================================================================

  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      // Reset all CSRs to default values
      mstatus_mie      <= 1'b0;
      mstatus_mpie     <= 1'b0;
      mstatus_mpp      <= 2'b11;  // Machine mode

      mie_meie         <= 1'b0;
      mie_mtie         <= 1'b0;
      mie_msie         <= 1'b0;

      mtvec_base       <= '0;
      mtvec_mode       <= 2'b00;  // Direct mode

      mscratch         <= '0;
      mepc             <= '0;
      mcause_interrupt <= 1'b0;
      mcause_code      <= '0;
      mtval            <= '0;

      mcycle           <= 64'b0;
      minstret         <= 64'b0;

      // Machine Information (implementation-specific)
      mvendorid        <= '0;      // No vendor ID
      marchid          <= '0;      // No architecture ID
      mimpid           <= '0;      // No implementation ID
      mhartid          <= '0;      // Hart 0

    end else begin

      // Performance counters (always increment)
      mcycle <= mcycle + 1;
      if (instruction_retired) begin
        minstret <= minstret + 1;
      end

      // Handle traps (exceptions and interrupts)
      if (take_trap) begin
        // Save current state
        mstatus_mpie <= mstatus_mie;
        mstatus_mpp  <= 2'b11;  // Current mode (Machine)
        mstatus_mie  <= 1'b0;   // Disable interrupts

        // Save trap information
        mepc <= exception_pc;

        if (interrupt_pending && mstatus_mie) begin
          // Handle interrupt
          mcause_interrupt <= 1'b1;
          if (mip_msip & mie_msie) begin
            mcause_code <= 'd3;  // Machine software interrupt
          end else if (mip_mtip & mie_mtie) begin
            mcause_code <= 'd7;  // Machine timer interrupt
          end else if (mip_meip & mie_meie) begin
            mcause_code <= 'd11; // Machine external interrupt
          end
          mtval <= '0;  // Not used for interrupts
        end else begin
          // Handle exception
          mcause_interrupt <= 1'b0;
          /* verilator lint_off WIDTHEXPAND */
          mcause_code <= exception_cause;
          /* verilator lint_on WIDTHEXPAND */
          mtval <= exception_pc;  // Fault address (simplified)
        end
      end

      // Handle MRET instruction
      else if (mret_instruction) begin
        mstatus_mie <= mstatus_mpie;  // Restore previous interrupt enable
        mstatus_mpie <= 1'b1;         // Set MPIE
        mstatus_mpp <= 2'b00;         // Set MPP to User mode (if supported)
      end

      // Handle CSR writes
      else if (csr_write_valid) begin
        case (csr_addr)
          CSR_MSTATUS: begin
            mstatus_mie  <= csr_wdata[3];
            mstatus_mpie <= csr_wdata[7];
            mstatus_mpp  <= csr_wdata[12:11];
          end

          CSR_MIE: begin
            mie_meie <= csr_wdata[11];
            mie_mtie <= csr_wdata[7];
            mie_msie <= csr_wdata[3];
          end

          CSR_MTVEC: begin
            mtvec_base <= csr_wdata[XLEN-1:2];
            mtvec_mode <= csr_wdata[1:0];
          end

          CSR_MSCRATCH: mscratch <= csr_wdata;
          CSR_MEPC:     mepc <= csr_wdata;

          CSR_MCAUSE: begin
            mcause_interrupt <= csr_wdata[XLEN-1];
            mcause_code <= csr_wdata[XLEN-2:0];
          end

          CSR_MTVAL: mtval <= csr_wdata;

          CSR_MCYCLE: begin
            if (XLEN == 64) begin
              mcycle <= csr_wdata;
            end else begin
              mcycle[31:0] <= csr_wdata[31:0];
            end
          end

          CSR_MINSTRET: begin
            if (XLEN == 64) begin
              minstret <= csr_wdata;
            end else begin
              minstret[31:0] <= csr_wdata[31:0];
            end
          end

          CSR_MCYCLEH: begin
            if (XLEN == 32) begin
              mcycle[63:32] <= csr_wdata[31:0];
            end
          end

          CSR_MINSTRETH: begin
            if (XLEN == 32) begin
              minstret[63:32] <= csr_wdata[31:0];
            end
          end

          default: ; // Ignore writes to read-only or invalid CSRs
        endcase
      end
    end
  end

  // ========================================================================
  // Initialize Machine ISA Register
  // ========================================================================

  always_comb begin
    // Set supported extensions (basic RV32I/RV64I)
    misa_extensions = 26'b0;
    misa_extensions[8] = 1'b1;  // 'I' - Base integer ISA
    // Add other extensions as implemented (M, A, F, D, C, etc.)
  end

endmodule
