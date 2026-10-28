-include config.mk
export LIB_SRC LIB_DB CELLS_V CHAINS
LEN ?= 0
.PHONY: all vectors sim scan_demo scan_demo_fault db dc_base dc_scan gate_sim gate_flush atpg clean
all: vectors sim scan_demo
vectors:
	python3 model/gen_vectors.py
sim: vectors
	mkdir -p build && iverilog -g2012 -I rtl -o build/fir.vvp rtl/fir_pipelined.v tb/tb_fir.v && vvp build/fir.vvp | tee build/sim.log | tail -5 && grep -q PASS build/sim.log
scan_demo:
	mkdir -p build && iverilog -o build/sd.vvp rtl/scan_ff.v rtl/scan_demo.v tb/tb_scan_demo.v && vvp build/sd.vvp
scan_demo_fault:
	mkdir -p build && iverilog -DSTUCK_Q1_0 -o build/sdf.vvp rtl/scan_ff.v rtl/scan_demo.v tb/tb_scan_demo.v && vvp build/sdf.vvp
# ---- Synopsys flow (needs config.mk) ----
db:
	lc_shell -f scripts/lib2db.tcl
dc_base:
	mkdir -p build/dc && dc_shell -f syn/dc/baseline.tcl | tee build/dc/baseline.log
dc_scan:
	mkdir -p build/dc && dc_shell -f syn/dc/scan.tcl | tee build/dc/scan.log
gate_sim:    # scan netlist in functional mode (SE=0) must still match the golden model
	mkdir -p build && iverilog -g2012 -DSCAN -I rtl -o build/gate.vvp $(CELLS_V) build/dc/fir_scan_netlist.v tb/tb_fir.v && vvp build/gate.vvp | tail -3
gate_flush:  # make gate_flush LEN=<flops in chain>
	mkdir -p build && iverilog -g2012 -o build/flush.vvp $(CELLS_V) build/dc/fir_scan_netlist.v tb/tb_chain_flush.v && vvp build/flush.vvp +LEN=$(LEN) | tail -3
atpg:
	mkdir -p build/atpg && tmax -shell -f atpg/tmax/run.tcl | tee build/atpg/tmax.log
clean:
	rm -rf build
