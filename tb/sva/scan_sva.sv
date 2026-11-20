`timescale 1ns/1ps

// Checker for rtl/scan_chain.sv (one parameterized chain).
// Concurrent assertions sample at posedge, BEFORE the DUT's NBA updates.
module scan_sva #(
    parameter int N = 8
)(
    input logic         clk,
    input logic         rst_n,
    input logic         scan_en,
    input logic         scan_in,
    input logic [N-1:0] data_in,
    input logic [N-1:0] data_out,
    input logic         scan_out
);

    initial begin
        if (N < 1)
            $fatal(1, "SVA: N must be >= 1");
    end

    // A scan-enabled rising edge must shift the OLD register state
    // toward the MSB and load the previous scan_in at bit zero.
    // The consequence is observed at the NEXT sampled rising edge.
    property p_shift;
        @(posedge clk) disable iff (!rst_n)
            scan_en |=>
                (data_out === (($past(data_out) << 1) |
                               N'($past(scan_in))));
    endproperty : p_shift

    a_shift: assert property (p_shift)
        else $fatal(1, "SVA SHIFT: register failed to shift");

    
    property p_functional_load;
        @(posedge clk) disable iff (!rst_n)
            !scan_en |=> (data_out === $past(data_in));
    endproperty : p_functional_load

    a_functional_load: assert property (p_functional_load)
        else $fatal(1, "SVA LOAD: functional input was not captured");

    // Reset is active-low
    property p_reset;
        @(posedge clk)
            !rst_n |-> (data_out === '0 && scan_out === 1'b0);
    endproperty : p_reset

    a_reset: assert property (p_reset)
        else $fatal(1, "SVA RESET: state is nonzero during reset");

    // The serial output is permanently driven from the register MSB.
    property p_scan_out;
        @(posedge clk)
            scan_out === data_out[N-1];
    endproperty : p_scan_out

    a_scan_out: assert property (p_scan_out)
        else $fatal(1, "SVA SCAN_OUT: scan_out != data_out[N-1]");

    // Since the reset is ASYNCHRONOUS, also check it between clocks.
    // This procedural immediate assertion is testbench-only code.
    always @(negedge rst_n) begin
        #1;
        assert (data_out === '0 && scan_out === 1'b0)
            else $fatal(1, "ASYNC RESET: outputs failed to clear");
    end

    // Demonstrate the stimulus actually exercised these scenarios.
    c_shift: cover property (@(posedge clk) disable iff (!rst_n)
                              scan_en);
    c_full_scan: cover property (@(posedge clk) disable iff (!rst_n)
                                  scan_en[*N]);
    c_functional_load: cover property (@(posedge clk) disable iff (!rst_n)
                                       !scan_en);
    c_reset: cover property (@(posedge clk) !rst_n);

endmodule
