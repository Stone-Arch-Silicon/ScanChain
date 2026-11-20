`timescale 1ns/1ps
module scan_chain #(
    parameter int N = 8
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic         scan_en,
    input  logic         scan_in,
    input  logic [N-1:0] data_in,
    output logic [N-1:0] data_out,
    output logic         scan_out
);
    initial begin
        assert (N >= 1)
            else $fatal(1, "Scan chain width N must be >= 1");
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= '0;
        else if (scan_en)
            data_out <= (data_out << 1) | N'(scan_in);
        else
            data_out <= data_in;
    end

    assign scan_out = data_out[N-1];

endmodule