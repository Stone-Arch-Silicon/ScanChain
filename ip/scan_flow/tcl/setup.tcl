# Shared DC setup. All design/lib parameters arrive as env vars from the Makefile.
foreach v {TOP RTL SDC CLK_PORT LIB_DB OUT} {
    if {![info exists ::env($v)]} { puts "ERROR: env $v not set"; exit 1 }
}
set TOP $::env(TOP); set OUT $::env(OUT); set LIB_DB $::env(LIB_DB)
set INC [expr {[info exists ::env(INC_DIRS)] ? $::env(INC_DIRS) : ""}]
file mkdir $OUT
define_design_lib WORK -path $OUT/WORK
set_app_var search_path       ". $INC [file dirname $LIB_DB] $search_path"
set_app_var target_library    [file tail $LIB_DB]
set_app_var link_library      "* [file tail $LIB_DB] dw_foundation.sldb"
set_app_var synthetic_library dw_foundation.sldb

proc load_design {} {
    global TOP OUT
    analyze -format verilog $::env(RTL)
    elaborate $TOP
    current_design $TOP
    link
    uniquify
    check_design > $OUT/check_design.rpt
    read_sdc $::env(SDC)
}
