# Run from the repository root: make -C tb/sva test N=8
# Uses VCS, matching the existing sim/Makefile in ScanChain.

VCS ?= vcs
N ?= 8

ROOT := $(abspath ../..)
BUILD := $(CURDIR)/build
RTL := $(ROOT)/rtl/scan_chain.sv
SVA := $(CURDIR)/scan_sva.sv
TB := $(CURDIR)/tb_scan_sva.sv

.PHONY: all test clean
all: test

test:
	mkdir -p $(BUILD)
	cd $(BUILD) && $(VCS) -full64 -sverilog -assert svaext \
		-timescale=1ns/1ps +define+SCAN_LEN=$(N) \
		$(RTL) $(SVA) $(TB) -top tb_scan_sva -o simv
	cd $(BUILD) && ./simv

clean:
	rm -rf $(BUILD)
