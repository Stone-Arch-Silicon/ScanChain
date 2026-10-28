.PHONY: all vectors sim scan_demo scan_demo_fault genus dc atpg vivado clean
all: vectors sim scan_demo
vectors:
	python3 model/gen_vectors.py
sim: vectors
	mkdir -p build && iverilog -g2012 -I rtl -o build/fir.vvp rtl/fir_pipelined.v tb/tb_fir.v && vvp build/fir.vvp | tee build/sim.log | tail -5 && grep -q PASS build/sim.log
scan_demo:
	mkdir -p build && iverilog -o build/sd.vvp rtl/scan_ff.v rtl/scan_demo.v tb/tb_scan_demo.v && vvp build/sd.vvp
scan_demo_fault:
	mkdir -p build && iverilog -DSTUCK_Q1_0 -o build/sdf.vvp rtl/scan_ff.v rtl/scan_demo.v tb/tb_scan_demo.v && vvp build/sdf.vvp
genus:
	mkdir -p build/genus && genus -f syn/genus/run.tcl -log build/genus/genus.log
dc:
	mkdir -p build/dc && dc_shell -f syn/dc/run.tcl | tee build/dc/dc.log
atpg:
	mkdir -p build/atpg && tmax -shell -f atpg/tmax/run.tcl | tee build/atpg/tmax.log
vivado:
	mkdir -p build/vivado && vivado -mode batch -source fpga/vivado/build.tcl
clean:
	rm -rf build
