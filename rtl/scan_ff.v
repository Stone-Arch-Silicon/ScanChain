// Mux-D scan flop: SE=0 -> functional D, SE=1 -> scan input SI.
module scan_ff (
    input  wire clk, input wire se, input wire d, input wire si,
    output reg  q
);
    always @(posedge clk) q <= se ? si : d;
endmodule
