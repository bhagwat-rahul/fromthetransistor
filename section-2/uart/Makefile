# --- uart/Makefile ---

# Toolchain
IVERILOG = iverilog
VVP = vvp
VFLAGS = -Wall -g2012

# Paths
SRC_DIR  = src
TEST_DIR = test
BUILD_DIR = build

# Output names
OUT_TX   = $(BUILD_DIR)/tx
OUT_RX   = $(BUILD_DIR)/rx
OUT_BAUD = $(BUILD_DIR)/baud
OUT_UART = $(BUILD_DIR)/uart

# Sources
SRC_TX   = $(SRC_DIR)/uart_tx.v
SRC_RX   = $(SRC_DIR)/uart_rx.v
SRC_BAUD = $(SRC_DIR)/baud_gen.v
SRC_UART = $(SRC_DIR)/uart.v $(SRC_TX) $(SRC_RX) $(SRC_BAUD)

# Testbenches
TB_TX    = $(TEST_DIR)/uart_tx_tb.v
TB_RX    = $(TEST_DIR)/uart_rx_tb.v
TB_BAUD  = $(TEST_DIR)/baud_gen_tb.v
TB_UART  = $(TEST_DIR)/uart_tb.v

# Default rule
all: test_tx test_rx test_baud test_uart

# Ensure build dir exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# --- Test Targets ---

tx: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_TX) $(SRC_TX) $(TB_TX)
	$(VVP) $(OUT_TX)

rx: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_RX) $(SRC_RX) $(TB_RX)
	$(VVP) $(OUT_RX)

baud: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_BAUD) $(SRC_BAUD) $(TB_BAUD)
	$(VVP) $(OUT_BAUD)

uart: $(BUILD_DIR)
	$(IVERILOG) $(VFLAGS) -o $(OUT_UART) $(SRC_UART) $(TB_UART)
	$(VVP) $(OUT_UART)

show_uart:
	yosys yosys/synthuart.ys

show_uart_tx:
	yosys yosys/synthuart_tx.ys

show_uart_rx:
	yosys yosys/synthuart_rx.ys

show_baud_gen:
	yosys yosys/synthbaudgen.ys

# --- Cleanup ---
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all test_tx test_rx test_baud test_uart clean
