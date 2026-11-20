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

clean:
	rm -rf $(BUILD)