// shift in pattern (SE=1) -> capture one clock (SE=0) -> shift out (SE=1), compare to expected.
// Optional +define+STUCK_Q1_0 forces q1 stuck-at-0 to show the fault is caught at scan_out.
`timescale 1ns/1ps
module tb_scan_demo;
    reg clk=0, se=0, scan_in=0, a=0, b=0;
    wire scan_out, z;
    scan_demo dut(clk, se, scan_in, a, b, scan_out, z);
    always #5 clk = ~clk;
`ifdef STUCK_Q1_0
    initial forever begin @(posedge clk); #1 force dut.q1 = 1'b0; end
`endif
    reg [3:0] pat = 4'b1011;     // q0..q3 after loading (q3 loaded first)
    reg [3:0] got; integer i;
    // expected capture: d0=a=1, d1=q0^b, d2=q1&q0, d3=q2|q1 with q0=pat[0],q1=pat[1],q2=pat[2]
    wire [3:0] exp = {pat[2]|pat[1], pat[1]&pat[0], pat[0]^1'b0, 1'b1};
    initial begin
        a=1; b=0; se=1;
        for (i=3;i>=0;i=i-1) begin scan_in = pat[i]; @(negedge clk); end   // shift in
        se=0; @(negedge clk);                                              // capture
        se=1; for (i=0;i<4;i=i+1) begin got[3-i]=scan_out; @(negedge clk); end // shift out (q3 first)
        $display("expected=%b got=%b -> %s", exp, got, (got===exp)?"PASS":"FAIL (fault detected)");
        $finish;
    end
endmodule
