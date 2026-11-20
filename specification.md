Parameters:
- N: Scan chain width (default 8, minimum 1).
-

IO:
- clk: Rising-edge clock.
- rst_n: Active-low asynchronous reset.
- scan_en: Selects functional (0) or scan (1) mode.
- scan_in: Serial input.
- data_in[N-1:0]: Parallel input.
- data_out[N-1:0]: Current register contents.
- scan_out: Serial output (data_out[N-1]).