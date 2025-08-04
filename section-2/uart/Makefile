# --- uart/Makefile ---
# Toolchain
VERILATOR = verilator
VFLAGS = --binary --trace -DSIMULATION_RUN

# Paths
SRC_DIR  = src
TEST_DIR = test
BUILD_DIR = obj_dir

# Output names
OUT_TX   = $(BUILD_DIR)/Vuart_tx_tb
OUT_RX   = $(BUILD_DIR)/Vuart_rx_tb
OUT_BAUD = $(BUILD_DIR)/Vbaud_gen_tb
OUT_UART = $(BUILD_DIR)/Vuart_tb
OUT_UART_LB = $(BUILD_DIR)/Vuart_loopback_tb

# Sources
SRC_TX   = $(SRC_DIR)/uart_tx.v
SRC_RX   = $(SRC_DIR)/uart_rx.v
SRC_BAUD = $(SRC_DIR)/baud_gen.v
SRC_UART = $(SRC_DIR)/uart.v $(SRC_TX) $(SRC_RX) $(SRC_BAUD)
SRC_UART_LB = $(SRC_DIR)/uart_loopback.v $(SRC_DIR)/uart.v $(SRC_DIR)/uart_tx.v $(SRC_DIR)/uart_rx.v $(SRC_DIR)/baud_gen.v

# Testbenches
TB_TX    = $(TEST_DIR)/uart_tx_tb.v
TB_RX    = $(TEST_DIR)/uart_rx_tb.v
TB_BAUD  = $(TEST_DIR)/baud_gen_tb.v
TB_UART  = $(TEST_DIR)/uart_tb.v
TB_UART_LB  = $(TEST_DIR)/uart_loopback_tb.v

# Default rule
all: tx rx baud uart

# Ensure build dir exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# --- Test Targets ---
tx: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_TX) $(SRC_TX) --top-module uart_tx_tb
	./$(OUT_TX)

rx: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_RX) $(SRC_RX) --top-module uart_rx_tb
	./$(OUT_RX)

baud: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_BAUD) $(SRC_BAUD) --top-module baud_gen_tb
	./$(OUT_BAUD)

uart: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_UART) $(SRC_UART) --top-module uart_tb
	./$(OUT_UART)

uart_lb: $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) $(TB_UART_LB) $(SRC_UART_LB) --top-module uart_loopback_tb
	./$(OUT_UART_LB)

show_uart:
	yosys -p "read_verilog -sv src/uart.v src/uart_rx.v src/uart_tx.v src/baud_gen.v; synth -top uart; select uart; show"

show_tx:
	yosys -p "read_verilog -sv src/uart_tx.v; synth -top uart_tx; show"

show_rx:
	yosys -p "read_verilog -sv src/uart_rx.v; synth -top uart_rx; show"

show_baud:
	yosys -p "read_verilog -sv src/baud_gen.v; synth -top baud_gen; show"

# --- Cleanup ---
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all tx rx baud uart uart_lb clean
