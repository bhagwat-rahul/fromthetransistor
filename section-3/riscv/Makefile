# --- riscv/Makefile ---

# Toolchain
VERILATOR = verilator
VFLAGS = --binary --trace

# Paths
SRC_DIR  = src
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

# Sources
SRC_RISCV     = $(SRC_DIR)/riscv.v
SRC_EXEC      = $(PIPELINE_DIR)/exec.v
SRC_IDECODE   = $(PIPELINE_DIR)/idecode.v
SRC_IFETCH    = $(PIPELINE_DIR)/ifetch.v
SRC_MEMACC    = $(PIPELINE_DIR)/memacc.v
SRC_WRITEBACK = $(PIPELINE_DIR)/writeback.v

# Testbenches
TB_RISCV     = $(TEST_DIR)/riscv_tb.v
TB_EXEC      = $(TEST_DIR)/exec_tb.v
TB_IDECODE   = $(TEST_DIR)/idecode_tb.v
TB_IFETCH    = $(TEST_DIR)/ifetch_tb.v
TB_MEMACC    = $(TEST_DIR)/memacc_tb.v
TB_WRITEBACK = $(TEST_DIR)/writeback_tb.v

# Ensure build dir exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Default rule
all: riscv

# --- Test Targets ---

riscv: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_RISCV)  $(SRC_RISCV)
	./$(OUT_RISCV)

exec: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS)  $(TB_EXEC) $(SRC_EXEC)
	./$(OUT_EXEC)

idecode: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS)  $(TB_IDECODE) $(SRC_IDECODE)
	./$(OUT_IDECODE)

ifetch: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS)  $(TB_IFETCH) $(SRC_IFETCH)
	./$(OUT_IFETCH)

memacc: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_MEMACC) $(SRC_MEMACC)
	./$(OUT_MEMACC)

writeback: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_WRITEBACK) $(SRC_WRITEBACK)
	./$(OUT_WRITEBACK)

show_idecode:
	yosys yosys/synthidecode.ys

show_ifetch:
	yosys yosys/syntifetch.ys

# --- Cleanup ---
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all riscv clean
