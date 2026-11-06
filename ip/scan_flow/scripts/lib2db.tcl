# lc_shell -f scripts/lib2db.tcl   (needs env LIB_SRC, LIB_DB). DC reads .db, not .lib.
read_lib $::env(LIB_SRC)
set n [get_object_name [index_collection [get_libs] 0]]
file mkdir [file dirname $::env(LIB_DB)]
write_lib $n -format db -output $::env(LIB_DB)
exit
