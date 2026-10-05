#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
MAN=sim/results/mutant_manifest.tsv
OUT=sim/results/op_mutants.tsv
SRCS="tb/master/axi4_lite_master.sv tb/monitor/axi4_lite_monitor.sv tb/scoreboard/axi4_lite_scoreboard.sv tb/coverage/axi4_lite_coverage.sv tb/assertions/axi4_lite_sva.sv tb/tb_top.sv"
build_run () { # $1=slave file $2=dir
  rm -rf "$2"; mkdir -p "$2"
  verilator --binary --timing --assert -Wno-fatal -DASSERTIONS --top-module tb_top -Mdir "$2/obj" -o vtb "$1" $SRCS > "$2/build.log" 2>&1
  [ -x "$2/obj/vtb" ] || return 99
  timeout 120 stdbuf -o0 "$2/obj/vtb" $MUT_ARGS > "$2/run.log" 2>&1
  return $?
}
build_run rtl/axi4_lite_slave.sv /tmp/mutants/base
grep -E "SCOREBOARD RESULT|EXTRA TESTS" /tmp/mutants/base/run.log > /tmp/mutants/base.txt
echo "BASELINE SVA fails: $(grep -c '\[SVA_FAIL\]' /tmp/mutants/base/run.log) (must be 0)"
echo "BASELINE checker lines:"; cat /tmp/mutants/base.txt
printf "id\tline\toperator\toriginal\tmutated\tresult\tsva_rules\n" > $OUT
tail -n +2 $MAN | while IFS=$'\t' read -r id line op orig mut; do
  build_run /tmp/mutants/$id.sv /tmp/mutants/run_$id; rc=$?
  if [ $rc -eq 99 ]; then res=INVALID; rules=-
  else
    D=/tmp/mutants/run_$id
    rules=$(grep -o "\[SVA_FAIL\] [A-Z0-9_]*" $D/run.log | awk '{print $2}' | sort -u | paste -sd+)
    grep -E "SCOREBOARD RESULT|EXTRA TESTS" $D/run.log > $D/chk.txt
    sb=0
    if [ $rc -eq 124 ] || grep -q WATCHDOG $D/run.log || ! cmp -s $D/chk.txt /tmp/mutants/base.txt; then sb=1; fi
    sva=0; [ -n "$rules" ] && sva=1
    if   [ $sva -eq 1 ] && [ $sb -eq 1 ]; then res=BOTH
    elif [ $sva -eq 1 ]; then res=SVA_ONLY
    elif [ $sb  -eq 1 ]; then res=CHECKER_ONLY
    else res=SURVIVED; fi
    [ -z "$rules" ] && rules=-
  fi
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$id" "$line" "$op" "$orig" "$mut" "$res" "$rules" | tee -a $OUT
done
echo; echo "SUMMARY:"; tail -n +2 $OUT | cut -f6 | sort | uniq -c
