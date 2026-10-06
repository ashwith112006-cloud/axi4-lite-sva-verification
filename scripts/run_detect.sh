#!/bin/bash
# first SVA fire vs first non-assertion checker fire, per operator mutant
OUT=sim/results/detect_time.tsv
printf "id\tfirst_sva\tt_sva\tfirst_chk\tt_chk\tgap_cycles\twatchdog\tclass\n" > $OUT
tm() { sed -E 's/.* at time ([0-9]+).*/\1/'; }
for L in /tmp/mutants/*/run.log; do
  D=$(basename $(dirname $L)); [ "$D" = base ] && continue
  s=$(grep -m1 '\[SVA_FAIL\]' $L); c=$(grep -m1 '\[CHK_FAIL\]' $L)
  wd=0; grep -q WATCHDOG $L && wd=1
  sbf=0; grep -q 'SCOREBOARD RESULT: FAIL' $L && sbf=1
  sr="-"; ts="-"; cr="-"; tc="-"; gap="-"
  [ -n "$s" ] && { sr=$(echo "$s" | awk '{print $2}'); ts=$(echo "$s" | tm); }
  [ -n "$c" ] && { cr=$(echo "$c" | awk '{print $2}'); tc=$(echo "$c" | tm); }
  if [ -n "$s" ] && [ -n "$c" ]; then
    gap=$(( (tc - ts) / 10000 ))
    if [ "$tc" -lt "$ts" ]; then cls=CHK-first; else cls=SVA-first; fi
  elif [ -n "$s" ]; then
    if [ $sbf -eq 1 ] || [ $wd -eq 1 ]; then cls=SVA+end-of-test; else cls=SVA-only; fi
  elif [ -n "$c" ]; then cls=CHK-only
  elif [ $wd -eq 1 ]; then cls=timeout
  elif [ $sbf -eq 1 ]; then cls=end-of-test
  else cls=survived; fi
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" $D $sr $ts $cr $tc $gap $wd $cls >> $OUT
done
column -t -s$'\t' $OUT
cut -f8 $OUT | tail -n +2 | sort | uniq -c
