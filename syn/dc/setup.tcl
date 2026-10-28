# Shared DC setup. Env: LIB_DB (required), CHAINS (default 1)
set TOP fir_pipelined
if {![info exists ::env(LIB_DB)]} { puts "ERROR: set LIB_DB"; exit 1 }
set LIB_DB $::env(LIB_DB)
file mkdir build/dc
define_design_lib WORK -path build/dc/WORK
set_app_var search_path      ". rtl $search_path [file dirname $LIB_DB]"
set_app_var target_library   [file tail $LIB_DB]
set_app_var link_library     "* [file tail $LIB_DB] dw_foundation.sldb"
set_app_var synthetic_library dw_foundation.sldb

proc load_fir {} {
    global TOP
    analyze -format verilog rtl/fir_pipelined.v
    elaborate $TOP
    current_design $TOP
    link
    uniquify
    check_design > build/dc/check_design.rpt
    read_sdc constraints/fir.sdc
}
