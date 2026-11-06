// Tiny hand-scanned circuit: 4 flops, logic = (a^b), (b&c) etc. Chain: scan_in -> q0 -> q1 -> q2 -> q3 -> scan_out
// Purpose: see shift / capture / shift-out by hand before letting Genus/DC do it for 600+ flops.
module scan_demo (
    input  wire clk, se, scan_in, a, b,
    output wire scan_out, z
);
    wire q0, q1, q2, q3;
    wire d0 = a;
    wire d1 = q0 ^ b;
    wire d2 = q1 & q0;
    wire d3 = q2 | q1;
    scan_ff f0 (clk, se, d0, scan_in, q0);
    scan_ff f1 (clk, se, d1, q0,      q1);
    scan_ff f2 (clk, se, d2, q1,      q2);
    scan_ff f3 (clk, se, d3, q2,      q3);
    assign scan_out = q3;
    assign z = q3;
endmodule
