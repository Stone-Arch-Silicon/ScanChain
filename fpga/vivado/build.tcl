# Vivado baseline (no scan) synth for area/timing comparison. Usage: vivado -mode batch -source fpga/vivado/build.tcl -tclargs <part>
set part [expr {[llength $argv] ? [lindex $argv 0] : "xc7z020clg400-1"}]
read_verilog rtl/fir_pipelined.v
synth_design -top fir_pipelined -part $part -include_dirs rtl
read_xdc constraints/fir.xdc
report_utilization -file build/vivado/util.rpt
report_timing_summary -file build/vivado/timing.rpt
