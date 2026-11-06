# scan-flow: reusable scan-chain DFT flow (Design Compiler / DFT Compiler / TestMAX)
```
ip/scan_flow/   reusable flow: tcl/ (DC, DFT, ATPG), tb/ (chain flush), demo/ (hand-built scan), configs/ (sky130, tsmc180), scripts/
examples/fir/   example design: 8-tap pipelined FIR + Python golden model (add your own via design.mk)
docs/           PLAN.md, ROLES.md, dc_setup.md
```
Quick start (open-source sim): `make all`. Synopsys flow: `cp config.mk.example config.mk`, then
`make db dc_base dc_scan gate_sim gate_flush LEN=<n> atpg` (`DESIGN=<name> PDK=<sky130|tsmc180> CHAINS=<n>`). See docs/dc_setup.md.
Never commit TSMC library files, netlists or reports.
