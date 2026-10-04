#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
mkdir -p sim/results
for m in MISSING_B MISSING_R BVALID_DROP RDATA_UNSTABLE ILLEGAL_BRESP ILLEGAL_RRESP STRB_IGNORED ADDR_ALIAS; do
  ./scripts/mutate.sh $m
done | tee sim/results/mutants.txt
