make -C sim simple

make -C sim cascade

make -C sim uvm-hw

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

Behavior:
- all registers should immediately clear to zero (regarldess of clock)
- Functional mode: On each rising edge, data_out should load data_in and scan_in should be ignored.
- Scan mode: On each rising edge, registers should shift left by one bit, inserting scan_in at bit 0 and data_in should be ignored
- Scan output: scan_out continuously reflects the most-significant register bit, including before it is shifted out.
- Changing scan_en shouldn't affect register contents until the next rising edge.
- Cascading: Multiple instances connected through scan_out and scan_in must behave as one continuous scan chain.
- Parameterization