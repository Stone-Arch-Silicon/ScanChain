
`timescale 1ns/1ps

module tb_scan_chain_cascade;

    localparam int N = 8;
    localparam int NUM_CHAINS = 4;
    localparam int TOTAL_BITS = N * NUM_CHAINS;

    logic clk = 0;
    logic rst_n, scan_en, scan_in, scan_out;

    logic [N-1:0] data_in  [NUM_CHAINS];
    logic [N-1:0] data_out [NUM_CHAINS];
    logic [NUM_CHAINS:0] scan_link;

    logic [TOTAL_BITS-1:0] expected;
    int tests = 0;
    int errors = 0;

    always #5 clk = ~clk;

    // Connect four scan chains in series
    assign scan_link[0] = scan_in;
    assign scan_out = scan_link[NUM_CHAINS];

    for (genvar i = 0; i < NUM_CHAINS; i++) begin : gen_chains
        scan_chain #(.N(N)) dut (
            .clk      (clk),
            .rst_n    (rst_n),
            .scan_en  (scan_en),
            .scan_in  (scan_link[i]),
            .data_in  (data_in[i]),
            .data_out (data_out[i]),
            .scan_out (scan_link[i+1])
        );
    end

    // Check all register banks and scan output
    task automatic check(input string name);
        logic [TOTAL_BITS-1:0] actual;

        for (int i = 0; i < NUM_CHAINS; i++)
            actual[i*N +: N] = data_out[i];

        tests++;

        if (actual !== expected ||
            scan_out !== expected[TOTAL_BITS-1]) begin
            $error("[%s] Expected=%h, Actual=%h, SO=%b",
                   name, expected, actual, scan_out);
            errors++;
        end
    endtask

    // Advance one clock and update reference model
    task automatic step(input string name);
        @(posedge clk);
        #1;

        if (!rst_n)
            expected = '0;
        else if (scan_en)
            expected = (expected << 1) | TOTAL_BITS'(scan_in);
        else begin
            for (int i = 0; i < NUM_CHAINS; i++)
                expected[i*N +: N] = data_in[i];
        end

        check(name);
        @(negedge clk);
    endtask

    initial begin
        rst_n = 0;
        scan_en = 0;
        scan_in = 0;
        expected = '0;

        for (int i = 0; i < NUM_CHAINS; i++)
            data_in[i] = '0;

        $display("=== Cascaded Scan Chain Test ===");
        $display("Chains: %0d | Width: %0d | Total: %0d",
                 NUM_CHAINS, N, TOTAL_BITS);

        // Test 1: Reset
        step("Reset");
        rst_n = 1;

        // Test 2: Parallel functional load
        data_in[0] = 8'h12;
        data_in[1] = 8'h34;
        data_in[2] = 8'h56;
        data_in[3] = 8'h78;
        step("Parallel Load");

        // Test 3: Shift in a 32-bit pattern
        scan_en = 1;
        localparam logic [TOTAL_BITS-1:0] PATTERN = 32'hDEADBEEF;

        for (int i = TOTAL_BITS-1; i >= 0; i--) begin
            scan_in = PATTERN[i];
            step($sformatf("Shift In %0d", i));
        end

        // Test 4: Shift out and verify serial output
        // Check the outgoing bit before each shift edge.
        for (int i = TOTAL_BITS-1; i >= 0; i--) begin
            if (scan_out !== expected[TOTAL_BITS-1]) begin
                $error("Serial output mismatch at bit %0d", i);
                errors++;
            end

            scan_in = 0;
            step($sformatf("Shift Out %0d", i));
        end

        // Test 5: Return to functional mode
        scan_en = 0;
        data_in[0] = 8'hAA;
        data_in[1] = 8'hBB;
        data_in[2] = 8'hCC;
        data_in[3] = 8'hDD;
        step("Functional Mode Restore");

        // Test 6: Reset after activity
        rst_n = 0;
        step("Final Reset");

        $display("------------------------------");
        $display("Tests: %0d | Errors: %0d", tests, errors);

        if (errors == 0)
            $display("PASS: All cascade tests passed.");
        else
            $fatal(1, "FAIL: %0d errors detected.", errors);

        $finish;
    end

endmodule
