// Chain integrity: SE=1, shift random bits; scan_out must equal scan_in delayed by LEN.
// LEN = scan flop count from build/dc/scan_chains.rpt. Run: make gate_flush LEN=<n>
`timescale 1ns/1ps
module tb_chain_flush;
    integer LEN, k, errs = 0;
    reg clk = 0, scan_in = 0;
    reg hist [0:65535];
    wire scan_out;
    wire signed [34:0] y;
    fir_pipelined dut (.clk(clk), .x_in(16'sd0), .y_out(y), .SE(1'b1), .scan_in0(scan_in), .scan_out0(scan_out));
    always #5 clk = ~clk;
    initial begin
        if (!$value$plusargs("LEN=%d", LEN)) begin $display("need +LEN=<chain length>"); $finish; end
        @(negedge clk);
        for (k = 0; k < LEN + 512; k = k + 1) begin
            if (k >= LEN && scan_out !== hist[k-LEN]) errs = errs + 1;
            hist[k] = $random; scan_in = hist[k];
            @(negedge clk);
        end
        if (errs == 0) $display("PASS: chain length %0d verified", LEN); else $display("FAIL: %0d errors (wrong LEN or broken chain)", errs);
        $finish;
    end
endmodule
