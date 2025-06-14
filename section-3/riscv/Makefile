# --- riscv/Makefile ---

# Toolchain
IVERILOG = iverilog
VVP = vvp
VFLAGS = -Wall -g2012

# Paths
SRC_DIR  = src
PIPELINE_DIR = src/pipeline
TEST_DIR = test
BUILD_DIR = build

# Output names
OUT_RISCV     = $(BUILD_DIR)/riscv
OUT_EXEC      = $(BUILD_DIR)/exec
OUT_IDECODE   = $(BUILD_DIR)/idecode
OUT_IFETCH    = $(BUILD_DIR)/ifetch
OUT_MEMACC    = $(BUILD_DIR)/memacc
OUT_WRITEBACK = $(BUILD_DIR)/writeback

# Sources
SRC_RISCV     = $(SRC_DIR)/riscv.v
SRC_EXEC      = $(PIPELINE_DIR)/exec.v
SRC_IDECODE   = $(PIPELINE_DIR)/idecode.v
SRC_IFETCH    = $(PIPELINE_DIR)/ifetch.v
SRC_MEMACC    = $(PIPELINE_DIR)/memacc.v
SRC_WRITEBACK = $(PIPELINE_DIR)/writeback.v

# Testbenches
TB_RISCV     = $(TEST_DIR)/riscv_tb.v
TB_EXEC      = $(TEST_DIR)/exec
TB_IDECODE   = $(TEST_DIR)/idecode
TB_IFETCH    = $(TEST_DIR)/ifetch
TB_MEMACC    = $(TEST_DIR)/memacc
TB_WRITEBACK = $(TEST_DIR)/writeback

# Ensure build dir exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Default rule
all: riscv

# --- Test Targets ---

riscv: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_RISCV) $(SRC_RISCV) $(TB_RISCV)
	$(VVP) $(OUT_RISCV)

exec: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_EXEC) $(SRC_EXEC) $(TB_EXEC)
	$(VVP) $(OUT_EXEC)

idecode: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_IDECODE) $(SRC_IDECODE) $(TB_IDECODE)
	$(VVP) $(OUT_IDECODE)

ifetch: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_IFETCH) $(SRC_IFETCH) $(TB_IFETCH)
	$(VVP) $(OUT_IFETCH)

memacc: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_MEMACC) $(SRC_MEMACC) $(TB_MEMACC)
	$(VVP) $(OUT_MEMACC)

writeback: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_WRITEBACK) $(SRC_WRITEBACK) $(TB_WRITEBACK)
	$(VVP) $(OUT_WRITEBACK)

# --- Cleanup ---
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all riscv clean
