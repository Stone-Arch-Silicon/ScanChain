# TestMAX ATPG (separate license). Env: TOP OUT CELLS_V
foreach c $::env(CELLS_V) { read_netlist $c -library }
read_netlist $::env(OUT)/scan_netlist.v
run_build_model $::env(TOP)
run_drc $::env(OUT)/scan.spf
set_faults -model stuck
add_faults -all
run_atpg -auto_compression
report_summaries > $::env(OUT)/atpg_summary.rpt
write_patterns $::env(OUT)/patterns.stil -format stil -replace
write_faults   $::env(OUT)/faults.list -all -replace
exit
