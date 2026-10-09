#!/bin/bash
# First assertion failure vs first scoreboard/directed-check failure for the 11 hand-crafted mutants.
# Uses scripts/mutate.sh, which works on a temporary copy of the slave (rtl/ is never modified),
# then reads each run log. Times in ns; gap in 10 ns clock cycles (checker time - assertion time).
# Output: sim/results/detect_times_handcrafted.tsv
cd "$(dirname "$0")/.." || exit 1
OUT=sim/results/detect_times_handcrafted.tsv
printf "mutant\tfirst_sva_rule\tt_sva_ns\tt_checker_ns\tgap_cycles\twatchdog\n" > "$OUT"
for m in MISSING_B MISSING_R BVALID_DROP RDATA_UNSTABLE ILLEGAL_BRESP ILLEGAL_RRESP \
         STRB_IGNORED ADDR_ALIAS BRESP_UNSTABLE RRESP_UNSTABLE WREADY_STUCK0; do
  echo "   $m" >&2
  ./scripts/mutate.sh "$m" > /dev/null
  L=/tmp/mut_$m/run.log
  s=$(grep -m1 '\[SVA_FAIL\]' "$L")
  rule=$(echo "$s" | grep -o 'A[0-9][0-9]_[A-Z0-9_]*' | head -1)
  ts=$(echo "$s" | sed -nE 's/.* at time ([0-9]+).*/\1/p')
  tc=$(grep -m1 '\[CHK_FAIL\]' "$L" | sed -nE 's/.* at time ([0-9]+).*/\1/p')
  wd=$(grep -q 'WATCHDOG TIMEOUT' "$L" && echo 1 || echo 0)
  awk -v m="$m" -v r="${rule:--}" -v ts="$ts" -v tc="$tc" -v wd="$wd" 'BEGIN {
    a = (ts == "") ? "-" : ts / 1000; c = (tc == "") ? "-" : tc / 1000
    g = (ts == "" || tc == "") ? "-" : (tc - ts) / 10000
    printf "%s\t%s\t%s\t%s\t%s\t%s\n", m, r, a, c, g, wd }' >> "$OUT"
done
cat "$OUT"
