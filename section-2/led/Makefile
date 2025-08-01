PROJ    = led
PIN_DEF = led.pcf
DEVICE  = up5k
PACKAGE = sg48
OBJ_DIR = obj_dir

YOSYS     := $(shell which yosys)
NEXTPNR   := $(shell which nextpnr-ice40)
ICEPACK   := $(shell which icepack)
ICEPROG   := $(shell which iceprog)
IVERILOG  := $(shell which iverilog)
VVP       := $(shell which vvp)

# Targets
all: $(OBJ_DIR)/$(PROJ).bin

$(OBJ_DIR)/%.json: %.v | $(OBJ_DIR)
	$(YOSYS) -p 'read_verilog -sv -DFPGA_RUN $<; chparam -set CLOCK_SPEED 12000000 $(PROJ); synth_ice40 -top $(PROJ) -json $@'

$(OBJ_DIR)/%.asc: $(PIN_DEF) $(OBJ_DIR)/%.json
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) --asc $@ --pcf $(PIN_DEF) --json $(OBJ_DIR)/$*.json

$(OBJ_DIR)/%.bin: $(OBJ_DIR)/%.asc
	$(ICEPACK) $< $@

# Simulation targets
$(OBJ_DIR)/$(PROJ)_tb.vvp: $(PROJ).v $(PROJ)_tb.v | $(OBJ_DIR)
	$(IVERILOG) -g2012 -DSIMULATION_RUN -o $@ $^

sim: $(OBJ_DIR)/$(PROJ)_tb.vvp
	$(VVP) $<

$(OBJ_DIR)/$(PROJ)_tb.vcd: sim

show_sim: $(OBJ_DIR)/$(PROJ)_tb.vcd
	gtkwave $< &

upload: $(OBJ_DIR)/$(PROJ).bin
	sudo $(ICEPROG) $<

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(OBJ_DIR)

.PHONY: all upload clean sim view show_sim
