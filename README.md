# AXI4-Lite Slave: Design and Assertion-Based Verification

Simplified 32-bit AXI4-Lite slave (4 registers at 0x0, 0x4, 0x8, 0xC) with a custom
non-UVM SystemVerilog testbench: master BFM, monitor, scoreboard, manual coverage
counters, 19 SVA assertions, RTL mutants, master-side fault injection and
seeded random (custom xorshift PRNG) traffic. Academic pre-silicon project, not a complete AXI VIP.

## Results
| Check | Result |
|---|---|
| seeded random (custom xorshift PRNG) (10 seeds, own xorshift generator, random backpressure) | 133 checks/seed, 0 errors, 0 SVA fails |
| RTL mutants | 8/8 detected (6 by SVA, 2 by scoreboard only: STRB_IGNORED, ADDR_ALIAS) |
| Master-side faults | 7/7 caught by SVA, 5 ns detection latency |
| Unaligned addresses | Return SLVERR |

Full results: `sim/results/`

## How to run

## Layout
- rtl/axi4_lite_slave.sv   slave (sim-only ready_delay knob, default 0)
- tb/                      master, monitor, scoreboard, coverage, assertions, tb_top.sv
- scripts/                 build, regression, mutant and fault scripts
- legacy/                  old fault-report module (not used)
- docs/                    study notes

## Tools
Icarus Verilog 12.0, Verilator 5.020 (WSL Ubuntu 24.04). Verilator 5.020 lacks ##
cycle delays, so bounded-response rules use counters. Neither tool supports
covergroups, so coverage uses manual counters.

## Limitations
One outstanding transaction, no DECERR, no AWPROT/ARPROT, simple coverage bins,
self-designed fault set.
