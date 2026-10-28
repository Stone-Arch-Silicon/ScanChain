# Design Compiler setup checklist

1. **Tools + licenses:** `which dc_shell lc_shell` (on a cluster: `module load` the Synopsys module first). DFT Compiler is a separate license feature from DC: if `insert_dft` errors on licensing, that's why. ATPG needs TestMAX.
2. **Library:** you need (a) a `.lib`, (b) a `.db` (DC cannot read `.lib`), (c) Verilog cell models for gate sim.
   - `cp config.mk.example config.mk`, fill in `LIB_SRC`, `LIB_DB`, `CELLS_V`
   - `make db` converts `.lib` -> `.db` via Library Compiler (skip if your PDK already ships a `.db`)
   - **Must contain scan flops** (e.g. `SDFF*` cells with `test_cell` groups): `grep -c test_cell $LIB_SRC` should be > 0. With no scan cells DFT Compiler cannot do scan replacement.
3. **Run order:** `make dc_base` -> `make dc_scan` -> `make gate_sim` -> `make gate_flush LEN=<n>` -> `make atpg`
4. **What good looks like:**
   - `dft_drc_pre/post.rpt`: 0 violations
   - `scan_chains.rpt`: chain length n = number of scan cells (use as `LEN`)
   - `gate_sim`: PASS (SE=0 reproduces the golden outputs); `gate_flush`: PASS
5. **Chain length is not 619.** DC removes constant/duplicate flops, so take n from `scan_chains.rpt` and compare to the sequential cell count in `base_cell_list.rpt`.
6. **Common errors:** `TEST-xxx` rule violations (read `dft_drc_pre.rpt`), "no scan equivalent" for a flop (library lacks scan cell), `SE`/`scan_in` ports not created (check the `-create_port` lines in `scan.tcl`; flags vary a bit by DC version).
