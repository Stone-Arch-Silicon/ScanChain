# Sky130 hd. Set SKY130_ROOT to .../sky130A/libs.ref/sky130_fd_sc_hd (open_pdks layout; adjust if yours differs).
SKY130_ROOT ?= /path/to/sky130A/libs.ref/sky130_fd_sc_hd
LIB_SRC  ?= $(SKY130_ROOT)/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
LIB_DB   ?= $(CURDIR)/lib/sky130_hd_tt.db
CELLS_V  ?= $(SKY130_ROOT)/verilog/primitives.v $(SKY130_ROOT)/verilog/sky130_fd_sc_hd.v
SIM_DEFS ?= -DFUNCTIONAL -DUNIT_DELAY=\#0
