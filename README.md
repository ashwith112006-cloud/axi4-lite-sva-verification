# AXI4-Lite Slave: Design and Assertion-Based Verification

Simplified 32-bit AXI4-Lite slave (4 registers at 0x0, 0x4, 0x8, 0xC) with a custom
non-UVM SystemVerilog testbench: master BFM, monitor, scoreboard, manual coverage
counters, 24 SVA assertions, RTL mutants, master-side fault injection and
seeded random (custom xorshift PRNG) traffic. Academic pre-silicon project, not a complete AXI VIP.

## Results
| Check | Result |
|---|---|
| Clean directed run (Icarus and Verilator) | 25/25 extra tests, scoreboard PASS, 0 SVA fails, 21/21 defined coverage bins |
| Seeded random traffic (10 seeds x 100 transactions, xorshift PRNG, random backpressure 0-3 cycles) | 205 checks/seed, 0 errors, 0 SVA fails |
| Hand-crafted RTL mutants (11) | 11/11 detected; 9 by SVA; STRB_IGNORED and ADDR_ALIAS by scoreboard only |
| Operator-style RTL mutants (30, seed 1) | 28/28 non-equivalent detected (9 with SVA); 2 equivalent survivors (m019, m023) |
| All 171 operator mutants, held-out 141 (m031-m171) | 125 non-equivalent: original env (19 rules) 116 detected, 38 with SVA; final env (24 rules) 121 detected, 53 with SVA, 4 by SVA only; 18 equivalent mutants listed in sim/results/equivalent_mutants.tsv |
| Assertion vs checker detection time | 18 bugs with both times: same clock edge in 12, assertion earlier in 3 (2, 2, 19 cycles), checker earlier in 3 (9, 9, 117 cycles) |
| Master-side faults (8) | 8/8 caught by the intended rule (A01-A07 at the next clock edge after injection; A24 on the first edge in reset) |
| Rule usefulness | all 24 rules fired on at least one mutant or fault (sim/results/rule_usefulness.tsv) |
| Slave code coverage (Verilator) | line 16/16, branch 46/46, toggle 344/346 (2 constant bits) |
| Unaligned addresses | Return SLVERR |

Full results: `sim/results/`

## How to run

    bash scripts/build.sh                    # Icarus, no SVA
    bash scripts/vbuild.sh                   # Verilator with 24 SVA rules
    bash scripts/regress.sh                  # clean runs, hand-crafted mutants, faults
    bash scripts/random.sh                   # 10 seeds x 100 random transactions
    python3 scripts/gen_mutants.py --seed 1  # create operator mutants in /tmp/mutants
    bash scripts/run_mutants.sh              # run operator mutants
    bash scripts/faults.sh                   # 8 master-side faults
    bash scripts/cov.sh                      # slave line/branch/toggle coverage
    python3 scripts/rule_table.py            # which rule caught which mutant/fault

    # all 171 operator mutants, original (19-rule) vs final (24-rule) environment
    python3 scripts/gen_mutants.py --seed 1 --max 1000 --out /tmp/mutants_all --manifest sim/results/mutant_manifest_all.tsv
    git worktree add /tmp/env_stage1 c9b88ab
    VL_FAST=1 bash scripts/run_mutant_set.sh . sim/results/mutant_manifest_all.tsv /tmp/mutants_all sim/results/op_mutants_all_final.tsv 8
    VL_FAST=1 bash scripts/run_mutant_set.sh /tmp/env_stage1 sim/results/mutant_manifest_all.tsv /tmp/mutants_all sim/results/op_mutants_all_stage1.tsv 8
    python3 scripts/heldout.py


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
self-designed fault set; X-checks not possible (Verilator is 2-state); results are for one 4-register slave.
