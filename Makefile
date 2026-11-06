all: sim demo
-include config.mk
DESIGN     ?= fir
PDK        ?= sky130
CHAINS     ?= 1
LEN        ?= 0
DESIGN_DIR := examples/$(DESIGN)
include $(DESIGN_DIR)/design.mk
-include ip/scan_flow/configs/$(PDK).mk
OUT := build/$(DESIGN)/$(PDK)/dc
export TOP RTL INC_DIRS SDC CLK_PORT CHAINS OUT LIB_SRC LIB_DB CELLS_V
FLOW := ip/scan_flow

.PHONY: all prep sim demo demo_fault db dc_base dc_scan gate_sim gate_flush atpg clean
demo:
	mkdir -p build && iverilog -o build/sd.vvp $(FLOW)/demo/scan_ff.v $(FLOW)/demo/scan_demo.v $(FLOW)/demo/tb_scan_demo.v && vvp build/sd.vvp
demo_fault:
	mkdir -p build && iverilog -DSTUCK_Q1_0 -o build/sdf.vvp $(FLOW)/demo/scan_ff.v $(FLOW)/demo/scan_demo.v $(FLOW)/demo/tb_scan_demo.v && vvp build/sdf.vvp
db:
	lc_shell -f $(FLOW)/scripts/lib2db.tcl
dc_base:
	mkdir -p $(OUT) && dc_shell -f $(FLOW)/tcl/baseline.tcl | tee $(OUT)/baseline.log
dc_scan:
	mkdir -p $(OUT) && dc_shell -f $(FLOW)/tcl/scan.tcl | tee $(OUT)/scan.log
gate_sim:   # scan netlist, SE=0: must still match the design's golden model
	mkdir -p build && iverilog -g2012 -DSCAN $(SIM_DEFS) $(TB_DEFS) $(addprefix -I,$(INC_DIRS)) -o build/gate.vvp $(CELLS_V) $(OUT)/scan_netlist.v $(TB_FUNC) && vvp build/gate.vvp | tail -3
gate_flush: # make gate_flush LEN=<scan cells in chain>
	mkdir -p build && iverilog -g2012 $(SIM_DEFS) $(addprefix -I,$(INC_DIRS)) -o build/flush.vvp $(CELLS_V) $(OUT)/scan_netlist.v $(FLOW)/tb/tb_chain_flush.v && vvp build/flush.vvp +LEN=$(LEN) | tail -3
atpg:
	tmax -shell -f $(FLOW)/tcl/atpg.tcl | tee $(OUT)/atpg.log
clean:
	rm -rf build
