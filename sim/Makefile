VCS      := vcs
ROOT     := ../..
BUILD    := build

RTL      := $(ROOT)/rtl/scan_chain.sv
SMOKE_TB := $(ROOT)/tb/tb_scan_chain.sv

.PHONY: simple clean

simple:
	mkdir -p $(BUILD)
	cd $(BUILD) && $(VCS) -full64 -sverilog \
		$(RTL) $(SMOKE_TB) -o simv
	cd $(BUILD) && ./simv

CASCADE_TB := $(ROOT)/tb/tb_scan_chain_cascade.sv

.PHONY: cascade

cascade:
	mkdir -p $(BUILD)/cascade
	cd $(BUILD)/cascade && $(VCS) -full64 -sverilog \
		../../../rtl/scan_chain.sv \
		../../../tb/tb_scan_chain_cascade.sv \
		-top tb_scan_chain_cascade -o simv
	cd $(BUILD)/cascade && ./simv

UVM-HW_TB := $(ROOT)/tb/uvm/uvm_hello_world.sv

.PHONY: uvm-hw

uvm-hw:
	mkdir -p $(BUILD)/uvm
	cd $(BUILD)/uvm && $(VCS) -full64 -sverilog \
		-ntb_opts uvm-1.2 \
		-timescale=1ns/1ps \
		../../../tb/uvm/uvm_hello_world.sv \
		-top tb_top -o simv
	cd $(BUILD)/uvm && ./simv

clean:
	rm -rf $(BUILD)