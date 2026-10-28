# fir-scan-dft
Scan-chain DFT (muxed-scan, stuck-at ATPG, fault coverage) on a pipelined FIR filter.

```
rtl/     fir_pipelined.v (DUT), scan_ff.v + scan_demo.v (hand-built scan example)
tb/      tb_fir.v (self-checking), tb_scan_demo.v
model/   Python golden model, vector + coeff generator
syn/dc/  baseline.tcl, scan.tcl (Design Compiler)   atpg/tmax/  ATPG
docs/    PLAN.md (milestones), dc_setup.md (DC checklist)
```
Quick start: `make all` (needs iverilog, python3). Synopsys flow: `docs/dc_setup.md`.
