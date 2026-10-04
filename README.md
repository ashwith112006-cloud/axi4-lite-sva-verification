# AXI4-Lite Slave: Design and Assertion-Based Verification

Simplified 32-bit AXI4-Lite slave (4 registers at 0x0, 0x4, 0x8, 0xC) with a custom
non-UVM SystemVerilog testbench: master BFM, monitor, scoreboard, manual functional
coverage, 19 SVA assertions, RTL mutants and master-side fault injection.
Academic pre-silicon project, not a complete AXI VIP.

## Layout
- rtl/axi4_lite_slave.sv        slave (has a sim-only ready_delay knob, default 0)
- tb/master, monitor, scoreboard, coverage, assertions, tb_top.sv
- legacy/                       old passive fault-report module (not used)
- scripts/build.sh              Icarus build and run (no SVA)
- scripts/vbuild.sh             Verilator build and run (with SVA)
- scripts/mutate.sh NAME        run one RTL mutant
- scripts/faults.sh             run the 7 master-side faults
- scripts/regress.sh            everything; writes sim/results/regression_summary.txt

## Tools
Icarus Verilog 12.0 and Verilator 5.020 (WSL Ubuntu 24.04). Verilator 5.020 does not
support ## cycle delays, so bounded-response rules use counters. Covergroups are not
supported by either tool, so coverage is manual counters.

## Limitations
One outstanding transaction, no random stimulus, no DECERR or unaligned tests,
21 simple coverage bins, no AWPROT/ARPROT, self-designed fault set.
