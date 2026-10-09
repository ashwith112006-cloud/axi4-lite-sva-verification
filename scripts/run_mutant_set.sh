#!/bin/bash
# Run a set of operator mutants against one verification environment, in parallel.
# usage: scripts/run_mutant_set.sh <env_dir> <manifest.tsv> <mutant_dir> <out.tsv> [jobs]
#   env_dir  : a checkout whose tb/ is used (e.g. . for HEAD, or a git worktree of an older commit)
#   The slave RTL is never edited: each mutant is a temporary copy in <mutant_dir>.
# VL_FAST=1 compiles the C++ at -O0 (same results, about 2x faster to build).
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ "${1:-}" = "--one" ]; then
  ENV="$2"; SV="$3"; D="$4"; BASE="$5"
  SRCS="$ENV/tb/master/axi4_lite_master.sv $ENV/tb/monitor/axi4_lite_monitor.sv $ENV/tb/scoreboard/axi4_lite_scoreboard.sv $ENV/tb/coverage/axi4_lite_coverage.sv $ENV/tb/assertions/axi4_lite_sva.sv $ENV/tb/tb_top.sv"
  FAST=""; [ "${VL_FAST:-0}" = 1 ] && FAST='OPT_FAST=-O0 OPT_SLOW=-O0 OPT_GLOBAL=-O0'
  rm -rf "$D"; mkdir -p "$D"
  verilator --binary --timing --assert -Wno-fatal -DASSERTIONS --top-module tb_top -Mdir "$D/obj" -o vtb \
    ${FAST:+-MAKEFLAGS "$FAST"} "$SV" $SRCS > "$D/build.log" 2>&1
  if [ ! -x "$D/obj/vtb" ]; then echo -e "$(basename "$D")\tINVALID\t-\t-\t-\t0"; exit 0; fi
  mkdir -p "$D/sim/waves"
  (cd "$D" && timeout 120 stdbuf -o0 "$D/obj/vtb" +verilator+error+limit+1000 > "$D/run.log" 2>&1); rc=$?
  rm -rf "$D/obj" "$D/sim"
  L="$D/run.log"
  rules=$(grep -o "\[SVA_FAIL\] [A-Z0-9_]*" "$L" | awk '{print $2}' | sort -u | paste -sd+)
  ts=$(grep -m1 '\[SVA_FAIL\]' "$L" | sed -E 's/.* at time ([0-9]+).*/\1/')
  tc=$(grep -m1 '\[CHK_FAIL\]' "$L" | sed -E 's/.* at time ([0-9]+).*/\1/')
  wd=0; grep -q WATCHDOG "$L" && wd=1
  grep -E "SCOREBOARD RESULT|EXTRA TESTS" "$L" > "$D/chk.txt"
  sb=0; if [ $rc -eq 124 ] || [ $wd -eq 1 ] || ! cmp -s "$D/chk.txt" "$BASE"; then sb=1; fi
  sva=0; [ -n "$rules" ] && sva=1
  if   [ $sva -eq 1 ] && [ $sb -eq 1 ]; then res=BOTH
  elif [ $sva -eq 1 ]; then res=SVA_ONLY
  elif [ $sb -eq 1 ]; then res=CHECKER_ONLY
  else res=SURVIVED; fi
  echo -e "$(basename "$D")\t$res\t${rules:--}\t${ts:--}\t${tc:--}\t$wd"
  exit 0
fi
ENV="$(cd "$1" && pwd)"; MAN="$2"; MD="$(cd "$3" && pwd)"; OUT="$4"; J="${5:-2}"
W=$(mktemp -d /tmp/mset.XXXX)
"$0" --one "$ENV" "$ROOT/rtl/axi4_lite_slave.sv" "$W/base" /dev/null > /dev/null
grep -E "SCOREBOARD RESULT|EXTRA TESTS" "$W/base/run.log" > "$W/base.txt"
echo "baseline ($ENV): $(tr '\n' ' ' < "$W/base.txt") SVA fails: $(grep -c '\[SVA_FAIL\]' "$W/base/run.log")"
printf "id\tresult\tsva_rules\tt_sva\tt_chk\twatchdog\n" > "$OUT"
tail -n +2 "$MAN" | cut -f1 | xargs -P "$J" -I{} "$0" --one "$ENV" "$MD/{}.sv" "$W/{}" "$W/base.txt" | sort >> "$OUT"
echo "done: $OUT"; tail -n +2 "$OUT" | cut -f2 | sort | uniq -c
