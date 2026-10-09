#!/usr/bin/env python3
# Compare the original (19-rule) and final (24-rule) environments on the operator mutants.
# Held-out set = m031..m171 (not used when A20-A24 and the later directed checks were written).
import csv, sys
R = "sim/results/"
EQUIV = {  # judged by inspection of the final-environment survivors (see sim/results/equivalent_mutants.tsv)
 "m019","m023","m031","m035","m059","m072","m076","m107","m133","m134",
 "m139","m143","m149","m150","m151","m152","m159","m161"}
fin = {r["id"]: r for r in csv.DictReader(open(R+"op_mutants_all_final.tsv"), delimiter="\t")}
st1 = {r["id"]: r for r in csv.DictReader(open(R+"op_mutants_all_stage1.tsv"), delimiter="\t")}
def rules(r): return [] if r["sva_rules"] in ("-", "") else r["sva_rules"].split("+")
def det(r): return r["result"] in ("BOTH", "CHECKER_ONLY", "SVA_ONLY")
def chk(r): return r["result"] in ("BOTH", "CHECKER_ONLY")
def sva(r, maxrule=99): return any(int(x[1:3]) <= maxrule for x in rules(r))
def summary(ids, name):
    ne = [i for i in ids if i not in EQUIV]
    n = len(ne)
    rows = [
      ("Original env (19 rules, 21 checks)", sum(det(st1[i]) for i in ne), sum(sva(st1[i]) for i in ne), sum(sva(st1[i]) and not chk(st1[i]) for i in ne)),
      ("Final env, rules A01-A19 only",      sum(chk(fin[i]) or sva(fin[i],19) for i in ne), sum(sva(fin[i],19) for i in ne), sum(sva(fin[i],19) and not chk(fin[i]) for i in ne)),
      ("Final env (24 rules, 25 checks)",    sum(det(fin[i]) for i in ne), sum(sva(fin[i]) for i in ne), sum(sva(fin[i]) and not chk(fin[i]) for i in ne)),
    ]
    print(f"\n== {name}: {len(ids)} mutants, {len(ids)-n} equivalent, {n} non-equivalent ==")
    print(f"{'environment':38} detected      with SVA   SVA only")
    for lab, d, s, so in rows: print(f"{lab:38} {d:3}/{n} ({100*d/n:4.1f}%)  {s:3} ({100*s/n:4.1f}%)  {so:3}")
    surv = [i for i in ne if not det(fin[i])]
    print("final-env non-equivalent survivors:", surv)
    return rows, n
ids = sorted(fin)
summary(ids[:30], "Original 30 (m001-m030)")
summary(ids[30:], "Held-out 141 (m031-m171)")
summary(ids, "All 171")
# rules that fired on held-out mutants (final env)
from collections import Counter
c = Counter(x for i in ids[30:] if i not in EQUIV for x in rules(fin[i]))
print("\nheld-out rule firings (final env):", dict(sorted(c.items())))
# detection-time gaps where both an assertion and a timed checker failure exist
print("\nmutants with both an assertion time and a checker failure time (final env):")
for i in ids:
    r = fin[i]
    if r["t_sva"] != "-" and r["t_chk"] != "-":
        g = (int(r["t_chk"]) - int(r["t_sva"])) // 10000
        print(f"  {i} first SVA {int(r['t_sva'])//1000} ns, first checker {int(r['t_chk'])//1000} ns, gap {g} cycles, rules {r['sva_rules']}")
