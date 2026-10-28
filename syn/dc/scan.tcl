# Synthesis + DFT Compiler muxed-scan insertion.
source syn/dc/setup.tcl
load_fir
set chains [expr {[info exists ::env(CHAINS)] ? $::env(CHAINS) : 1}]

set_scan_configuration -style multiplexed_flip_flop -chain_count $chains
set_dft_signal -view existing_dft -type ScanClock   -port clk -timing {45 55}
set_dft_signal -view spec -type ScanEnable  -port SE -active_state 1 -create_port SE
for {set i 0} {$i < $chains} {incr i} {
    set_scan_path chain$i -scan_data_in scan_in$i -scan_data_out scan_out$i -create_dedicated_scan_ports true
}
create_test_protocol
compile_ultra -scan
dft_drc -verbose            > build/dc/dft_drc_pre.rpt
preview_dft -show all       > build/dc/preview_dft.rpt
insert_dft
compile_ultra -scan -incremental
dft_drc -verbose            > build/dc/dft_drc_post.rpt
report_scan_path -view existing_dft -chain all > build/dc/scan_chains.rpt
report_scan_path -view existing_dft -cell all  > build/dc/scan_cells.rpt
report_area   > build/dc/scan_area.rpt
report_timing > build/dc/scan_timing.rpt
report_qor    > build/dc/scan_qor.rpt
write -format verilog -hierarchy -output build/dc/fir_scan_netlist.v
write_sdc build/dc/fir_scan.sdc
write_test_protocol -output build/dc/fir_scan.spf
exit
