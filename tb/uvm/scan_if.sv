
`timescale 1ns/1ps

interface scan_if #(parameter int N = 8) (
    input logic clk
);

    logic rst_n;
    logic scan_en;
    logic scan_in;
    logic [N-1:0] data_in;
    logic [N-1:0] data_out;
    logic scan_out;

    // Signals driven by the testbench
    modport driver (
        input  clk,
        output rst_n, scan_en, scan_in, data_in,
        input  data_out, scan_out
    );

    // Signals observed by the monitor
    modport monitor (
        input clk, rst_n, scan_en, scan_in,
              data_in, data_out, scan_out
    );

endinterface
