import re, collections, pathlib
R = pathlib.Path("sim/results")
rules = sorted(set(re.findall(r'SVA_FAIL\("(A\d+_\w+)"\)', open("tb/assertions/axi4_lite_sva.sv").read())),
               key=lambda r: int(r[1:3]))
op, hand, flt = collections.defaultdict(list), collections.defaultdict(list), collections.defaultdict(list)
for ln in open(R/"op_mutants.tsv").read().splitlines()[1:]:
    c = ln.split("\t")
    if len(c) >= 7 and c[6] not in ("-", ""):
        for r in c[6].split("+"): op[r].append(c[0])
cur = None
for ln in open(R/"mutants_random_all.txt"):
    m = re.match(r"=== MUTANT: (\w+)", ln)
    if m: cur = m.group(1); continue
    for r in re.findall(r"\[SVA_FAIL\] (A\d+_\w+)", ln):
        if cur not in hand[r]: hand[r].append(cur)
for ln in open(R/"faults.txt"):
    m = re.match(r"(\w+): .*rule=(A\d+_\w+)", ln)
    if m: flt[m.group(2)].append(m.group(1))
out = ["rule\top_mutants\thand_mutants\tfaults\ttotal\twhich"]
print(f"{'rule':24} op hand fault total")
for r in rules:
    t = len(op[r]) + len(hand[r]) + len(flt[r])
    print(f"{r:24} {len(op[r]):2} {len(hand[r]):4} {len(flt[r]):5} {t:5}")
    out.append(f"{r}\t{len(op[r])}\t{len(hand[r])}\t{len(flt[r])}\t{t}\t{' '.join(op[r]+hand[r]+flt[r])}")
(R/"rule_usefulness.tsv").write_text("\n".join(out) + "\n")
print("never fired:", [r for r in rules if not (op[r] or hand[r] or flt[r])])
