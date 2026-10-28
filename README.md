# fir-scan-dft
Scan-chain DFT (muxed-scan, stuck-at ATPG, fault coverage) on a pipelined FIR filter.

```
rtl/     fir_pipelined.v (DUT), scan_ff.v + scan_demo.v (hand-built scan example)
tb/      tb_fir.v (self-checking), tb_scan_demo.v
model/   Python golden model, vector + coeff generator
syn/     genus/, dc/ scan-insertion templates     atpg/tmax/  ATPG template
fpga/    vivado/ baseline synth                   docs/PLAN.md  milestones
```
Quick start: `make all` (needs iverilog, python3). Vendor flows: see `docs/PLAN.md`.
