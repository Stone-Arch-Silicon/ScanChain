# Plan: scan-chain DFT on a pipelined FIR

DUT: 8-tap pipelined FIR (`rtl/fir_pipelined.v`, ~620 flops). Goal: insert a scan chain, generate ATPG patterns, report stuck-at fault coverage.
EDA is license-bound, so everything is gated: open-source sim in CI, vendor flows run locally (`make genus|dc|atpg|vivado`).

| # | Milestone | Deliverable | Done when | Status |
|---|-----------|-------------|-----------|--------|
| M0 | Scaffold + CI | repo layout, Makefile, GH Actions | `make all` green in CI | done |
| M1 | Functional DUT + golden model | `fir_pipelined.v`, `gen_vectors.py`, `tb_fir.v` | 2048 vectors, 0 mismatches | done (run `make sim`) |
| M2 | Scan by hand (concept) | `scan_ff.v`, `scan_demo.v`, tb | shift/capture/shift PASS; injected stuck-at FAILs | done |
| M3 | Baseline synth | Vivado util/timing; Genus/DC area/timing **without** scan | reports in `build/*`, numbers in `docs/results.md` | next |
| M4 | Scan insertion | Genus (`syn/genus`) and/or DC (`syn/dc`), single chain, SE/scan_in/scan_out | DFT DRC clean, chain length == flop count (~620) | |
| M5 | Scan-netlist verification | gate-level TB: shift pattern, capture, shift out; compare vs RTL model; SE=0 reproduces M1 results ("normal mode") | gate sim PASS both modes | |
| M6 | ATPG + coverage | TestMAX patterns (STIL), coverage report | stuck-at test coverage >= 99%; pattern count recorded | |
| M7 | Experiments | 1 vs 4 chains (test time), coverage vs pattern count, scan area/timing overhead, untestable-fault analysis | table + plots in `docs/results.md` | |
| M8 | Independent fault check (optional) | iverilog stuck-at injection over sampled nets using ATPG patterns | agrees with tool coverage within a few % | |

## Conventions
- Python is the single source of truth for taps/vectors (`model/coeffs.py`); never edit generated `fir_coeffs.vh`.
- No resets in DUT (keeps scan DRC simple); TB flushes with zeros.
- Env vars for vendor flows: `LIB`/`LIB_DB` (timing lib), `LIB_VERILOG` (cell models), `NETLIST`, `SPF`.
- Vendor scripts are templates: command names are standard but flags vary by tool version/PDK; fix on first run.

## Notes
- Latency: y[n] appears 4 edges after the edge sampling x[n].
- Full-precision 35b output (16b x 16b taps + 3 adder levels) so comparison is exact; add truncation later if desired.
