#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
mkdir -p sim/results
OUT=sim/results/regression_summary.txt
: > $OUT
echo "[1/4] Clean run, Icarus" >&2
{
echo "== CLEAN RUN (Icarus) =="
./scripts/build.sh | grep -E "EXTRA TESTS|CHECKS|SCOREBOARD RESULT|COVERED BINS|COVERAGE  "
} >> $OUT
echo "[2/4] Clean run, Verilator with assertions" >&2
{
echo "== CLEAN RUN (Verilator + SVA) =="
./scripts/vbuild.sh 2>&1 | grep -E "EXTRA TESTS|CHECKS|SCOREBOARD RESULT|SVA FAILS|SANITY"
} >> $OUT
echo "[3/4] RTL mutants (about 10-15 min, please wait)" >&2
: > sim/results/mutants.txt
for m in MISSING_B MISSING_R BVALID_DROP RDATA_UNSTABLE ILLEGAL_BRESP ILLEGAL_RRESP STRB_IGNORED ADDR_ALIAS; do
  echo "   $m" >&2
  ./scripts/mutate.sh $m >> sim/results/mutants.txt
done
{
echo "== RTL MUTANTS =="
awk '
function flush() { if (name != "") printf "%-16s SVA_caught=%-3s scoreboard=%-4s tests_failed=%s\n", name, sva, sb, tf }
/=== MUTANT:/ { flush(); name=$3; sva="NO"; sb="n/a"; tf="n/a" }
/First SVA failure:/ { if ($0 !~ /none/) sva="YES" }
/SCOREBOARD RESULT/ { sb=$NF }
/EXTRA TESTS/ { tf=$6 }
END { flush() }
' sim/results/mutants.txt
} >> $OUT
echo "[4/4] Master-side faults" >&2
{
echo "== MASTER-SIDE FAULTS =="
./scripts/faults.sh
} >> $OUT
cat $OUT
