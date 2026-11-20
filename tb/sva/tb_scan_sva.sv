`timescale 1ns/1ps

`ifndef SCAN_LEN
`define SCAN_LEN 8
`endif

module tb_scan_sva;
    localparam int N = `SCAN_LEN;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic scan_en = 1'b0;
    logic scan_in = 1'b0;
    logic [N-1:0] data_in = '0;
    logic [N-1:0] data_out;
    logic scan_out;

    int unsigned shift_edges = 0;
    int unsigned load_edges  = 0;
    int unsigned reset_edges = 0;

    // 10 
    always #5 clk = ~clk;

    
    scan_chain #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .scan_en(scan_en),
        .scan_in(scan_in), .data_in(data_in),
        .data_out(data_out), .scan_out(scan_out)
    );

    scan_sva #(.N(N)) checks (
        .clk(clk), .rst_n(rst_n), .scan_en(scan_en),
        .scan_in(scan_in), .data_in(data_in),
        .data_out(data_out), .scan_out(scan_out)
    );

    always @(posedge clk) begin
        if (!rst_n)
            reset_edges++;
        else if (scan_en)
            shift_edges++;
        else
            load_edges++;
    end

    // Drive at negedge so the DUT can sample safely at posedge.
    task automatic shift_bit(input logic value);
        @(negedge clk);
        scan_en = 1'b1;
        scan_in = value;
        data_in = N'($urandom);  
        @(posedge clk);
        #1;                      
    endtask

    task automatic shift_pattern(input logic [N-1:0] pattern);
        for (int i = N-1; i >= 0; i--)
            shift_bit(pattern[i]);
    endtask

    task automatic load_parallel(input logic [N-1:0] value);
        @(negedge clk);
        scan_en = 1'b0;
        data_in = value;
        scan_in = ~scan_in;      // Should be ignored in functional mode.
        @(posedge clk);
        #1;
    endtask

    initial begin : run_tests
        logic [N-1:0] pattern;

        if (N < 1)
            $fatal(1, "TB: N must be >= 1");

        fork
            begin
                #1000000;
                $fatal(1, "TIMEOUT: simulation did not finish");
            end
        join_none

        $display("=== Scan chain SVA verification: N=%0d ===", N);

        repeat (3) @(negedge clk);
        rst_n = 1'b1;

        // 1. Functional load, then serial shifts.
        load_parallel('1);
        shift_pattern('0);
        shift_pattern('1);

        // 2. Alternating patterns, both polarities.
        pattern = '0;
        for (int i = 0; i < N; i++)
            pattern[i] = ((i % 2) == 0);
        shift_pattern(pattern);
        shift_pattern(~pattern);

        // 3. Walking one at every position.
        for (int pos = 0; pos < N; pos++) begin
            pattern = '0;
            pattern[pos] = 1'b1;
            shift_pattern(pattern);
        end

        // 4. Random scan inputs.
        for (int test_no = 0; test_no < 10; test_no++) begin
            for (int i = 0; i < N; i++)
                pattern[i] = $urandom_range(0, 1);
            shift_pattern(pattern);
        end

        // 5. Functional loads replace the prior scan data.
        load_parallel('0);
        load_parallel('1);

        // 6. Flush functional data through scan output.
        shift_pattern('0);

        // 7. Assert asynchronous reset between rising edges.
        @(negedge clk);
        rst_n = 1'b0;
        scan_en = 1'b0;
        data_in = '0;
        #1;
        if (data_out !== '0 || scan_out !== 1'b0)
            $fatal(1, "TB: asynchronous reset did not clear outputs");

        repeat (2) @(posedge clk);
        #1;
        rst_n = 1'b1;

        // Verify the chain remains usable after reset.
        load_parallel('1);
        shift_pattern('0);

        // Leave time for the final |=> obligations to be evaluated.
        @(negedge clk);
        scan_en = 1'b0;
        data_in = '0;
        repeat (2) @(posedge clk);
        #1;

        if (shift_edges < N*5 || load_edges < 3 || reset_edges < 2)
            $fatal(1, "TB: insufficient exercise: shifts=%0d loads=%0d resets=%0d",
                   shift_edges, load_edges, reset_edges);

        $display("PASS: N=%0d shifts=%0d loads=%0d reset_edges=%0d",
                 N, shift_edges, load_edges, reset_edges);
        $finish;
    end
endmodule
