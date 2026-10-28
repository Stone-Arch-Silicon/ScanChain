// Self-checking TB. Preamble of zeros flushes X's (no resets in DUT), then vectors; y[k-5] checked at negedge k.
`timescale 1ns/1ps
module tb_fir;
    parameter N = 2048;
    reg clk = 0;
    reg  signed [15:0] x_in = 0;
    wire signed [34:0] y_out;
    reg  [15:0] xmem [0:N-1];
    reg  [34:0] ymem [0:N-1];
    integer k, errs = 0;
`ifdef SCAN   // gate-level scan netlist: functional mode, chain idle
    fir_pipelined dut (.clk(clk), .x_in(x_in), .y_out(y_out), .SE(1'b0), .scan_in0(1'b0), .scan_out0());
`else
    fir_pipelined dut (.clk(clk), .x_in(x_in), .y_out(y_out));
`endif
    always #5 clk = ~clk;
    initial begin
        $readmemh("vectors/x.hex", xmem);
        $readmemh("vectors/y_exp.hex", ymem);
        repeat (16) @(negedge clk);                       // flush with zeros
        for (k = 0; k < N + 5; k = k + 1) begin
            if (k >= 5 && y_out !== ymem[k-5]) begin
                errs = errs + 1;
                if (errs < 10) $display("MISMATCH n=%0d got=%h exp=%h", k-5, y_out, ymem[k-5]);
            end
            x_in = (k < N) ? xmem[k] : 16'sd0;
            @(negedge clk);
        end
        if (errs == 0) $display("PASS: %0d samples", N); else $display("FAIL: %0d errors", errs);
        $finish;
    end
endmodule
