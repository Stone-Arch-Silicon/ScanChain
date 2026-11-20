VCS      := vcs
ROOT     := ../..
BUILD    := build

RTL      := $(ROOT)/rtl/scan_chain.sv
SMOKE_TB := $(ROOT)/tb/tb_scan_chain.sv

.PHONY: smoke clean

smoke:
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
		../../../tb/smoke/tb_scan_chain_cascade.sv \
		-top tb_scan_chain_cascade -o simv
	cd $(BUILD)/cascade && ./simv


clean:
	rm -rf $(BUILD)