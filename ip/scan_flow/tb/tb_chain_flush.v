// Generic chain-integrity check. Design supplies dut_inst.vh, which instantiates the scan netlist using
// signals clk, SE, scan_in, scan_out (and ties its other inputs). Shifts random bits; scan_out == scan_in delayed LEN.
`timescale 1ns/1ps
module tb_chain_flush;
    integer LEN, k, errs = 0;
    reg clk = 0, SE = 1, scan_in = 0;
    wire scan_out;
    reg hist [0:65535];
    `include "dut_inst.vh"
    always #5 clk = ~clk;
    initial begin
        if (!$value$plusargs("LEN=%d", LEN)) begin $display("need +LEN=<chain length>"); $finish; end
        @(negedge clk);
        for (k = 0; k < LEN + 512; k = k + 1) begin
            if (k >= LEN && scan_out !== hist[k-LEN]) errs = errs + 1;
            hist[k] = $random; scan_in = hist[k];
            @(negedge clk);
        end
        if (errs == 0) $display("PASS: chain length %0d verified", LEN);
        else $display("FAIL: %0d errors (wrong LEN or broken chain)", errs);
        $finish;
    end
endmodule
