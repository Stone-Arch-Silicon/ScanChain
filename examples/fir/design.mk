# Per-design contract. Copy this folder to add a design. Included by the top Makefile (DESIGN_DIR is set).
TOP      := fir_pipelined
RTL      := $(DESIGN_DIR)/rtl/fir_pipelined.v
INC_DIRS := $(DESIGN_DIR)/rtl $(DESIGN_DIR)
SDC      := $(DESIGN_DIR)/constraints/fir.sdc
CLK_PORT := clk
TB_FUNC  := $(DESIGN_DIR)/tb/tb_fir.v        # functional TB; compiled with -DSCAN against the scan netlist
TB_DEFS  := -DX_HEX='"$(DESIGN_DIR)/vectors/x.hex"' -DY_HEX='"$(DESIGN_DIR)/vectors/y_exp.hex"'

prep:
	python3 $(DESIGN_DIR)/model/gen_vectors.py
sim: prep
	mkdir -p build && iverilog -g2012 $(TB_DEFS) $(addprefix -I,$(INC_DIRS)) -o build/fir.vvp $(RTL) $(TB_FUNC) && vvp build/fir.vvp | tee build/sim.log | tail -5 && grep -q PASS build/sim.log
