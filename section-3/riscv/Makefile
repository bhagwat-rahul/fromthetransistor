# --- riscv/Makefile ---

# Toolchain
VERILATOR = verilator
VFLAGS = --binary --trace -I$(COMMON_DIR) $(COMMON_SRC) -DSIMULATION_RUN

# Paths
SRC_DIR  = src
COMMON_DIR = common
COMMON_SRC = $(wildcard $(COMMON_DIR)/*.v $(COMMON_DIR)/*.sv)
PIPELINE_DIR = src/pipeline
TEST_DIR = test
BUILD_DIR = obj_dir

# Output names
OUT_RISCV     = $(BUILD_DIR)/Vriscv_tb
OUT_EXEC      = $(BUILD_DIR)/Vexec_tb
OUT_IDECODE   = $(BUILD_DIR)/Videcode_tb
OUT_IFETCH    = $(BUILD_DIR)/Vifetch_tb
OUT_MEMACC    = $(BUILD_DIR)/Vmemacc_tb
OUT_WRITEBACK = $(BUILD_DIR)/Vwriteback_tb
OUT_PROG      = $(BUILD_DIR)/Vriscv_program_tb

# Sources
SRC_RISCV     = $(SRC_DIR)/riscv.v
SRC_EXEC      = $(PIPELINE_DIR)/exec.v
SRC_IDECODE   = $(PIPELINE_DIR)/idecode.v
SRC_IFETCH    = $(PIPELINE_DIR)/ifetch.v
SRC_MEMACC    = $(PIPELINE_DIR)/memacc.v
SRC_WRITEBACK = $(PIPELINE_DIR)/writeback.v

# Supporting module sources
SRC_REGFILE      = $(SRC_DIR)/regfile.v
SRC_MEMORY_CTRL  = $(SRC_DIR)/memory_controller.v
SRC_HAZARD_DET   = $(SRC_DIR)/hazard_detector.v
SRC_SRAM         = $(SRC_DIR)/sram.v

# Pipeline sources (all pipeline modules)
PIPELINE_SOURCES = $(SRC_IFETCH) $(SRC_IDECODE) $(SRC_EXEC) $(SRC_MEMACC) $(SRC_WRITEBACK)

# All sources needed for full RISC-V processor
ALL_RISCV_SOURCES = $(SRC_RISCV) $(PIPELINE_SOURCES) $(SRC_REGFILE) $(SRC_MEMORY_CTRL) $(SRC_HAZARD_DET) $(SRC_SRAM)

# Testbenches
TB_RISCV     = $(TEST_DIR)/riscv_tb.v
TB_EXEC      = $(TEST_DIR)/exec_tb.v
TB_IDECODE   = $(TEST_DIR)/idecode_tb.v
TB_IFETCH    = $(TEST_DIR)/ifetch_tb.v
TB_MEMACC    = $(TEST_DIR)/memacc_tb.v
TB_WRITEBACK = $(TEST_DIR)/writeback_tb.v
TB_PROG = $(TEST_DIR)/riscv_program_tb.v

# Ensure build dir exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Default rule
all: riscv

# --- Test Targets ---

riscv: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_RISCV) $(ALL_RISCV_SOURCES) --top-module riscv_tb
	./$(OUT_RISCV)

prog: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_PROG) $(ALL_RISCV_SOURCES) --top-module riscv_program_tb
	./$(OUT_PROG)

exec: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_EXEC) $(SRC_EXEC) --top-module exec_tb
	./$(OUT_EXEC)

idecode: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_IDECODE) $(SRC_IDECODE) --top-module idecode_tb
	./$(OUT_IDECODE)

ifetch: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_IFETCH) $(SRC_IFETCH) --top-module ifetch_tb
	./$(OUT_IFETCH)

memacc: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_MEMACC) $(SRC_MEMACC) --top-module memacc_tb
	./$(OUT_MEMACC)

writeback: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_WRITEBACK) $(SRC_WRITEBACK) --top-module writeback_tb
	./$(OUT_WRITEBACK)

show_idecode:
	yosys -p "read_verilog -sv src/pipeline/idecode.v ; synth ; show"

show_ifetch:
	yosys -p "read_verilog -sv src/pipeline/ifetch.v ; synth ; show"

# --- Cleanup ---
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all riscv clean
