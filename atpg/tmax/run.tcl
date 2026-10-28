# TestMAX ATPG (separate Synopsys license from DC -- confirm you have it). Run: make atpg
read_netlist $::env(CELLS_V) -library
read_netlist build/dc/fir_scan_netlist.v
run_build_model fir_pipelined
run_drc build/dc/fir_scan.spf
set_faults -model stuck
add_faults -all
run_atpg -auto_compression
report_summaries > build/atpg/summary.rpt
write_patterns build/atpg/patterns.stil -format stil -replace
write_faults build/atpg/faults.list -all -replace
exit
