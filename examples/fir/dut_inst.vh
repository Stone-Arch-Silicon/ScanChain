// Instantiates the scan netlist for tb_chain_flush; data inputs tied off, outputs unused.
wire signed [34:0] y_unused;
fir_pipelined dut (.clk(clk), .x_in(16'sd0), .y_out(y_unused), .SE(SE), .scan_in0(scan_in), .scan_out0(scan_out));
