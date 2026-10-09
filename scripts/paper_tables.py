#!/usr/bin/env python3
# Numbers for the paper that are not printed by heldout.py:
#   Table VII  - rule firings by rule group (153 non-equivalent operator mutants, 11 hand-crafted, 8 faults)
#   per-rule firing counts (every rule fires at least once)
#   timing     - bugs with both an assertion time and a checker time (hand-crafted + operator)
# Reads only existing result files in sim/results/.
import csv, re
from collections import Counter
R = "sim/results/"
EQUIV = {r["id"] for r in csv.DictReader(open(R + "equivalent_mutants.tsv"), delimiter="\t")}
fin = {r["id"]: r for r in csv.DictReader(open(R + "op_mutants_all_final.tsv"), delimiter="\t")}
ne = [i for i in sorted(fin) if i not in EQUIV]

def rules_of(field):
    return sorted({x[:3] for x in field.split("+") if re.match(r"A\d\d", x)})

op = Counter(r for i in ne for r in rules_of(fin[i]["sva_rules"]))

hand, cur = Counter(), None  # final-environment logs of the 11 hand-crafted mutants
blocks = {}
for f in ("mutants.txt", "mutants_extra.txt"):
    for ln in open(R + f):
        m = re.match(r"=== MUTANT: (\w+) ===", ln)
        if m: cur = m.group(1); blocks[cur] = set(); continue
        m = re.search(r"\[SVA_FAIL\] (A\d\d)_", ln)
        if m and cur and "First SVA failure" not in ln: blocks[cur].add(m.group(1))
for s in blocks.values(): hand.update(s)

flt = Counter(re.search(r"rule=(A\d\d)_", ln).group(1) for ln in open(R + "faults.txt") if "rule=A" in ln)

groups = [("Master hold/stability", "A01-A07", range(1, 8)), ("Slave hold/stability", "A08-A12", range(8, 13)),
          ("Response legality", "A13-A14", (13, 14)), ("Reset", "A15, A24", (15, 24)),
          ("Request before response", "A16-A17", (16, 17)), ("Response wait", "A18-A19", (18, 19)),
          ("READY wait", "A20-A22", (20, 21, 22)), ("Early READY", "A23", (23,))]
print(f"== Table VII: rule firings by group ({len(ne)} non-equivalent operator, {len(blocks)} hand-crafted, {sum(flt.values())} faults) ==")
print(f"{'group':26}{'rules':10}{'operator':>9}{'hand':>6}{'faults':>8}")
for name, lab, rr in groups:
    ks = [f"A{n:02d}" for n in rr]
    print(f"{name:26}{lab:10}{sum(op[k] for k in ks):>9}{sum(hand[k] for k in ks):>6}{sum(flt[k] for k in ks):>8}")

print("\n== per-rule firings (operator / hand / faults) ==")
never = []
for n in range(1, 25):
    k = f"A{n:02d}"
    print(f"{k}: {op[k]:3} / {hand[k]} / {flt[k]}")
    if op[k] + hand[k] + flt[k] == 0: never.append(k)
print("rules that never fired:", never or "none")

print("\n== bugs with both an assertion time and a checker time (gap = checker - assertion, 10 ns cycles) ==")
both = []
for r in csv.DictReader(open(R + "detect_times_handcrafted.tsv"), delimiter="\t"):
    if r["t_sva_ns"] != "-" and r["t_checker_ns"] != "-":
        both.append((r["mutant"], float(r["t_checker_ns"]) - float(r["t_sva_ns"]), r["watchdog"]))
for i in ne:
    r = fin[i]
    if r["t_sva"] not in ("", "-") and r["t_chk"] not in ("", "-"):
        both.append((i, (int(r["t_chk"]) - int(r["t_sva"])) / 1000, r["watchdog"]))
for m, gap, wd in both:
    print(f"{m:16} gap {gap / 10:+7.1f} cycles  watchdog={wd}")
same = sum(1 for _, g, _ in both if g == 0)
print(f"total {len(both)}: same edge {same}, assertion earlier {sum(1 for _, g, _ in both if g > 0)}, "
      f"checker earlier {sum(1 for _, g, _ in both if g < 0)}")
hangs = [i for i in ne if fin[i]["watchdog"] == "1"]
print(f"operator hangs: {len(hangs)}; with a checker failure before the hang: "
      f"{[i for i in hangs if fin[i]['t_chk'] not in ('', '-')]}")
