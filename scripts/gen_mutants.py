#!/usr/bin/env python3
import re, random, os, argparse, collections
ap = argparse.ArgumentParser()
ap.add_argument("--src", default="rtl/axi4_lite_slave.sv")
ap.add_argument("--max", type=int, default=30)
ap.add_argument("--seed", type=int, default=1)
ap.add_argument("--out", default="/tmp/mutants")
ap.add_argument("--manifest", default="sim/results/mutant_manifest.tsv")
a = ap.parse_args()

SKIP = re.compile(r'^\s*(//|module\b|endmodule\b|input\b|output\b|inout\b|parameter\b|localparam\b|logic\b|reg\b|wire\b|typedef\b|`)')

def match_paren(s, i):
    d = 0
    for j in range(i, len(s)):
        if s[j] == '(': d += 1
        elif s[j] == ')':
            d -= 1
            if d == 0: return j
    return -1

def mutants_for(code):
    r = []
    for m in re.finditer(r'(?<![=!<>])==(?!=)', code): r.append(("EQ_TO_NEQ", code[:m.start()] + "!=" + code[m.end():]))
    for m in re.finditer(r'!=(?!=)', code): r.append(("NEQ_TO_EQ", code[:m.start()] + "==" + code[m.end():]))
    for m in re.finditer(r'&&', code): r.append(("AND_TO_OR", code[:m.start()] + "||" + code[m.end():]))
    for m in re.finditer(r'\|\|', code): r.append(("OR_TO_AND", code[:m.start()] + "&&" + code[m.end():]))
    for m in re.finditer(r"1'b([01])", code):
        r.append(("BIT_FLIP", code[:m.start()] + "1'b" + ("0" if m.group(1) == "1" else "1") + code[m.end():]))
    for m in re.finditer(r'\bif\s*\(', code):
        o = m.end() - 1; c = match_paren(code, o)
        if c > 0: r.append(("IF_NEGATE", code[:o] + "(!" + code[o:c+1] + ")" + code[c+1:]))
    for m in re.finditer(r'<=', code):
        if code[:m.start()].count('(') - code[:m.start()].count(')') != 0: continue
        semi = code.find(';', m.end())
        if semi < 0: continue
        rhs = code[m.end():semi].strip()
        for tag, val, same in (("STUCK0", "'0", r"^(\d*'[bdh]0+|'0)$"), ("STUCK1", "'1", r"^(\d*'b1+|'1)$")):
            if re.match(same, rhs): continue
            r.append((tag, code[:m.end()] + " " + val + code[semi:]))
    for m in re.finditer(r"(\d+)'([dh])([0-9a-fA-F_]+)", code):
        base = 10 if m.group(2) == 'd' else 16
        try: v = int(m.group(3).replace('_', ''), base)
        except ValueError: continue
        w = int(m.group(1))
        for tag, nv in (("CONST_PLUS1", v + 1), ("CONST_MINUS1", v - 1)):
            if nv < 0 or nv >= 2 ** w: continue
            s = str(nv) if base == 10 else format(nv, 'x')
            r.append((tag, code[:m.start(3)] + s + code[m.end(3):]))
    return r

lines = open(a.src).read().splitlines(keepends=True)
sites = []
for i, line in enumerate(lines):
    if SKIP.match(line): continue
    code, sep, com = line.partition('//')
    for op, new in mutants_for(code):
        if new != code: sites.append((op, i, code.strip(), new.strip(), new + sep + com))

random.seed(a.seed)
groups = collections.defaultdict(list)
for s in sites: groups[s[0]].append(s)
for g in groups.values(): random.shuffle(g)
sel = []
while len(sel) < a.max and any(groups.values()):
    for op in sorted(groups):
        if groups[op] and len(sel) < a.max: sel.append(groups[op].pop())

os.makedirs(a.out, exist_ok=True); os.makedirs("sim/results", exist_ok=True)
with open(a.manifest, "w") as mf:
    mf.write("id\tline\toperator\toriginal\tmutated\n")
    for n, (op, i, o, nw, full) in enumerate(sel, 1):
        mid = "m%03d" % n
        t = lines[:]; t[i] = full
        open(f"{a.out}/{mid}.sv", "w").write("".join(t))
        mf.write(f"{mid}\t{i+1}\t{op}\t{o}\t{nw}\n")
print("total possible sites:", len(sites), "| selected:", len(sel))
for op in sorted(set(s[0] for s in sites)):
    print(f"  {op}: {sum(1 for s in sites if s[0]==op)} sites, {sum(1 for s in sel if s[0]==op)} selected")
