# Synthesis WITHOUT scan: area/timing/flop-count reference.
source ip/scan_flow/tcl/setup.tcl
load_design
compile_ultra
report_area          > $OUT/base_area.rpt
report_timing        > $OUT/base_timing.rpt
report_qor           > $OUT/base_qor.rpt
report_reference     > $OUT/base_cells.rpt
report_cell -nosplit > $OUT/base_cell_list.rpt
write -format verilog -hierarchy -output $OUT/base_netlist.v
write_sdc $OUT/base.sdc
exit
