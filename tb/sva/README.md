# Scan Chain SVA Verification

## Overview

This directory contains SystemVerilog assertions and a testbench for verifying the parameterized scan-chain module in `rtl/scan_chain.sv`.

## Verification

The assertions check:

- **Shift behavior:** Registers correctly shift when `scan_en = 1`.
- **Functional load:** Registers capture `data_in` when `scan_en = 0`.
- **Reset:** Registers clear when active-low reset is asserted.
- **Scan output:** `scan_out` matches the most significant register bit.

## Testbench

The testbench exercises:
- All-zero and all-one patterns
- Alternating bit patterns
- Walking-one patterns
- Random input patterns
- Functional loading
- Asynchronous reset
- Transitions between scan and functional modes

## Running the Tests

Requires Synopsys VCS.

From the repository root:

```bash
make -C tb/sva test N=8
```

Other supported configurations:

```bash
make -C tb/sva test N=1
make -C tb/sva test N=16
make -C tb/sva test N=32
```

## Verification Status

**Pending simulation:** The testbench and assertions have not yet been executed with Synopsys VCS since I don't have access.

Compilation, assertion execution, and regression testing need to be completed in an environment with VCS access.