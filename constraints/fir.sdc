create_clock -name clk -period 5.0 [get_ports clk]   ;# 200 MHz start; tune per library
set_input_delay  1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock clk [all_outputs]
