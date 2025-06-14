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
OUT_RISCV   = $(BUILD_DIR)/riscv

# Sources
SRC_RISCV     = $(SRC_DIR)/riscv.v
SRC_EXEC      = $(PIPELINE_DIR)/exec.v
SRC_IDECODE   = $(PIPELINE_DIR)/idecode.v
SRC_IFETCH    = $(PIPELINE_DIR)/ifetch.v
SRC_MEMACC    = $(PIPELINE_DIR)/memacc.v
SRC_WRITEBACK = $(PIPELINE_DIR)/writeback.v

# Testbenches
TB_RISCV    = $(TEST_DIR)/riscv_tb.v

# Ensure build dir exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Default rule
all: riscv

# --- Test Targets ---

riscv: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_RISCV) $(SRC_RISCV) $(TB_RISCV)
	$(VVP) $(OUT_RISCV)

# --- Cleanup ---
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all riscv clean
