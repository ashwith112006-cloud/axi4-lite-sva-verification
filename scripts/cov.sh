#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
SRCS="tb/master/axi4_lite_master.sv tb/monitor/axi4_lite_monitor.sv tb/scoreboard/axi4_lite_scoreboard.sv tb/coverage/axi4_lite_coverage.sv tb/assertions/axi4_lite_sva.sv tb/tb_top.sv"
O=/tmp/cov2; rm -rf $O /tmp/covrun; mkdir -p /tmp/covrun
verilator --cc --exe --build --timing --assert -Wno-fatal -DASSERTIONS --coverage --top-module tb_top -Mdir $O -o vtb rtl/axi4_lite_slave.sv $SRCS "$PWD/scripts/cov_main.cpp" > /tmp/cov2_build.log 2>&1 || { tail -15 /tmp/cov2_build.log; exit 1; }
(mkdir -p /tmp/covrun/d && cd /tmp/covrun/d && $O/vtb +verilator+error+limit+1000 > run.log 2>&1)
for s in 1 2 3 4 5 6 7 8 9 10; do mkdir -p /tmp/covrun/s$s; (cd /tmp/covrun/s$s && $O/vtb +verilator+error+limit+1000 +SEED=$s +RANDN=100 > run.log 2>&1); done
grep -L 'SCOREBOARD RESULT: PASS' /tmp/covrun/*/run.log
grep -L 'SVA FAILS = 0' /tmp/covrun/*/run.log
verilator_coverage --write /tmp/covrun/merged.dat /tmp/covrun/*/coverage.dat
grep -a 'axi4_lite_slave.sv' /tmp/covrun/merged.dat | awk '{ t=($0 ~ /v_toggle/)?"toggle":($0 ~ /v_branch/)?"branch":"line"; n[t]++; if ($NF==0) z[t]++ } END { for (k in n) print k, n[k], z[k]+0 }'
