// 8-tap pipelined FIR, 16b signed in, 35b signed full-precision out (no truncation -> exact check).
// y[n] = sum h[k]*x[n-k]. Latency: y[n] valid 4 clock edges after the edge that samples x[n].
// No resets on purpose: pure feed-forward pipeline, flushes itself; keeps scan insertion simple.
// Stages: (1) tap delay line  (2) multiply regs  (3) adder L1  (4) adder L2  (5) output add
module fir_pipelined (
    input  wire               clk,
    input  wire signed [15:0] x_in,
    output reg  signed [34:0] y_out
);
`include "fir_coeffs.vh"

    reg  signed [15:0] xr [0:7];
    reg  signed [31:0] p  [0:7];
    reg  signed [32:0] s1 [0:3];
    reg  signed [33:0] s2 [0:1];
    integer i;

    always @(posedge clk) begin
        xr[0] <= x_in;
        for (i = 1; i < 8; i = i + 1) xr[i] <= xr[i-1];

        p[0] <= xr[0] * H0;  p[1] <= xr[1] * H1;
        p[2] <= xr[2] * H2;  p[3] <= xr[3] * H3;
        p[4] <= xr[4] * H4;  p[5] <= xr[5] * H5;
        p[6] <= xr[6] * H6;  p[7] <= xr[7] * H7;

        s1[0] <= p[0] + p[1];  s1[1] <= p[2] + p[3];
        s1[2] <= p[4] + p[5];  s1[3] <= p[6] + p[7];

        s2[0] <= s1[0] + s1[1];
        s2[1] <= s1[2] + s1[3];

        y_out <= s2[0] + s2[1];
    end
endmodule
