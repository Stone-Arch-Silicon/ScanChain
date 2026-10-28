# Synthesis WITHOUT scan: area/timing reference + expected flop count.
source syn/dc/setup.tcl
load_fir
compile_ultra
report_area            > build/dc/base_area.rpt
report_timing          > build/dc/base_timing.rpt
report_reference       > build/dc/base_cells.rpt
report_cell -nosplit   > build/dc/base_cell_list.rpt   ;# count sequential cells here
report_qor             > build/dc/base_qor.rpt
write -format verilog -hierarchy -output build/dc/baseline_netlist.v
write_sdc build/dc/baseline.sdc
exit
