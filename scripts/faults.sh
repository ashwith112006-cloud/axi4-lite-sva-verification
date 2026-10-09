#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
mkdir -p sim/results
: > sim/results/faults.txt
names=(x AWVALID_DROP AWADDR_CHANGE WVALID_DROP WDATA_CHANGE WSTRB_CHANGE ARVALID_DROP ARADDR_CHANGE AWVALID_IN_RESET)
for n in 1 2 3 4 5 6 7 8; do
  timeout 60 stdbuf -o0 sim/vl_obj/vtb +verilator+error+limit+1000 +FAULT=$n > /tmp/f_$n.log 2>&1
  inj=$(grep -m1 "FAULT_INJECTED" /tmp/f_$n.log | grep -o "time [0-9]*" | cut -d' ' -f2)
  line=$(grep -m1 "\[SVA_FAIL\]" /tmp/f_$n.log)
  rule=$(echo "$line" | awk '{print $2}')
  t=$(echo "$line" | awk '{print $5}')
  sb=$(grep "SCOREBOARD RESULT" /tmp/f_$n.log | awk '{print $NF}')
  if [ -n "$inj" ] && [ -n "$t" ]; then lat=$(( (t - inj) / 1000 )); else lat="n/a"; fi
  echo "${names[$n]}: injected=${inj:-none} rule=${rule:-none} fail_t=${t:-none} latency_ns=$lat scoreboard=${sb:-none}"
done | tee sim/results/faults.txt
