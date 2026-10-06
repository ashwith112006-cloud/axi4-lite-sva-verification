#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
mkdir -p sim/results
for s in 1 2 3 4 5 6 7 8 9 10; do
  timeout 120 stdbuf -o0 sim/vl_obj/vtb +verilator+error+limit+1000 +SEED=$s +RANDN=${RANDN:-100} > /tmp/r_$s.log 2>&1
  chk=$(grep -m1 "CHECKS =" /tmp/r_$s.log | sed 's/  */ /g')
  sb=$(grep "SCOREBOARD RESULT" /tmp/r_$s.log | awk '{print $NF}')
  sva=$(grep "SVA FAILS" /tmp/r_$s.log | awk '{print $NF}')
  tf=$(grep "EXTRA TESTS" /tmp/r_$s.log | awk '{print $6}')
  echo "seed=$s $chk scoreboard=${sb:-none} sva_fails=${sva:-none} tests_failed=${tf:-none}"
done | tee sim/results/random.txt
