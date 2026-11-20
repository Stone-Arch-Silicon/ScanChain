
`timescale 1ns/1ps

module tb_scan_chain;

    localparam int N = 8;

    logic clk = 0;
    logic rst_n;
    logic scan_en;
    logic scan_in;
    logic [N-1:0] data_in;
    logic [N-1:0] data_out;
    logic scan_out;

    logic [N-1:0] expected;
    int tests = 0;
    int errors = 0;

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Device Under Test
    scan_chain #(.N(N)) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .scan_en  (scan_en),
        .scan_in  (scan_in),
        .data_in  (data_in),
        .data_out (data_out),
        .scan_out (scan_out)
    );

    // Check outputs against reference model
    task automatic check(input string name);
        tests++;

        if (data_out !== expected ||
            scan_out !== expected[N-1]) begin
            $error("[%s] Expected=%b, Got=%b, SO=%b",
                   name, expected, data_out, scan_out);
            errors++;
        end
    endtask

    // Apply one clock cycle
    task automatic step(input string name);
        @(posedge clk);
        #1;

        if (!rst_n)
            expected = '0;
        else if (scan_en)
            expected = (expected << 1) | N'(scan_in);
        else
            expected = data_in;

        check(name);
        @(negedge clk);
    endtask

    initial begin
        // Initialize
        rst_n   = 0;
        scan_en = 0;
        scan_in = 0;
        data_in = '0;
        expected = '0;

        $display("=== Scan Chain Testbench (N=%0d) ===", N);

        // Test 1: Reset
        step("Reset");

        // Test 2: Functional parallel load
        rst_n = 1;
        data_in = 8'b1010_1100;
        step("Functional Load");

        // Test 3: Scan shifting
        scan_en = 1;

        for (int i = 0; i < N; i++) begin
            scan_in = (i % 2);
            step($sformatf("Scan Shift %0d", i));
        end

        // Test 4: Functional mode after scan
        scan_en = 0;
        data_in = 8'b1100_0011;
        step("Return to Functional Mode");

        // Test 5: Shift out loaded pattern
        scan_en = 1;
        scan_in = 0;

        for (int i = 0; i < N; i++)
            step($sformatf("Shift Out %0d", i));

        // Test 6: Reset after activity
        rst_n = 0;
        step("Reset After Activity");

        // Summary
        $display("------------------------------");
        $display("Tests: %0d | Errors: %0d", tests, errors);

        if (errors == 0)
            $display("PASS: All scan-chain tests passed.");
        else
            $fatal(1, "FAIL: %0d errors detected.", errors);

        $finish;
    end

endmodule
