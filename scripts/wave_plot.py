# wave_plot.py - draw a clean timing diagram from a VCD file
# usage: python3 wave_plot.py <file.vcd> <out.png> <t_start_ns> <t_end_ns> <sig1,sig2,...> [marker_ns:label ...]
#        python3 wave_plot.py <file.vcd> --list
import sys, re
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def parse(path):
    scope, ids, ts = [], {}, 1.0
    data, t = {}, 0
    unit = {"s": 1e9, "ms": 1e6, "us": 1e3, "ns": 1.0, "ps": 1e-3, "fs": 1e-6}
    with open(path) as f:
        txt = f.read()
    head, _, body = txt.partition("$enddefinitions")
    m = re.search(r"\$timescale\s+(\d+)\s*([a-z]+)\s+\$end", head)
    if m: ts = int(m.group(1)) * unit[m.group(2)]
    for tok in re.finditer(r"\$scope\s+\w+\s+(\S+)\s+\$end|\$upscope|\$var\s+\w+\s+(\d+)\s+(\S+)\s+(\S+)(?:\s+\[[^\]]*\])?\s+\$end", head):
        if tok.group(1): scope.append(tok.group(1))
        elif tok.group(0).startswith("$upscope"): scope.pop()
        else:
            w, i, n = int(tok.group(2)), tok.group(3), tok.group(4)
            ids.setdefault(i, []).append((".".join(scope + [n]), w))
            data.setdefault(i, [])
    for line in body.splitlines():
        line = line.strip()
        if not line or line.startswith("$"): continue
        if line[0] == "#": t = int(line[1:]) * ts; continue
        if line[0] in "bBrR":
            v, i = line[1:].split()
        else:
            v, i = line[0], line[1:]
        if i in data: data[i].append((t, v))
    names = {}
    for i, lst in ids.items():
        for n, w in lst: names[n] = (i, w)
    return names, data

def find(names, short):
    c = [n for n in names if n.lower().split(".")[-1] == short.lower()]
    if not c: c = [n for n in names if n.lower().endswith(short.lower())]
    if not c: sys.exit(f"signal '{short}' not found; run with --list")
    return sorted(c, key=lambda n: (n.count("."), len(n)))[0]

def value_at(ch, t):
    v = "x"
    for tt, vv in ch:
        if tt <= t: v = vv
        else: break
    return v

def main():
    vcd = sys.argv[1]
    names, data = parse(vcd)
    if sys.argv[2] == "--list":
        for n, (i, w) in sorted(names.items()): print(w, n)
        return
    out, t0, t1 = sys.argv[2], float(sys.argv[3]), float(sys.argv[4])
    sigs = sys.argv[5].split(",")
    marks = [(float(a.split(":")[0]), a.split(":", 1)[1]) for a in sys.argv[6:]]
    plt.rcParams.update({"font.family": "serif", "font.serif": ["Times New Roman", "Liberation Serif", "DejaVu Serif"], "font.size": 8})
    rows = len(sigs)
    fig, ax = plt.subplots(figsize=(3.45, 0.32 * rows + 0.55), dpi=300)
    for r, s in enumerate(sigs):
        full = find(names, s); i, w = names[full]
        ch = data[i]
        y = rows - 1 - r
        pts = [(t0, value_at(ch, t0))] + [(t, v) for t, v in ch if t0 < t < t1] + [(t1, None)]
        ax.text(t0 - (t1 - t0) * 0.02, y + 0.35, s.upper(), ha="right", va="center", fontsize=7.5)
        for k in range(len(pts) - 1):
            ta, va = pts[k]; tb = pts[k + 1][0]
            if w == 1:
                lv = 0.7 if va == "1" else 0.0
                ax.plot([ta, tb], [y + lv, y + lv], color="black", lw=0.8)
                if k + 1 < len(pts) - 1:
                    nv = 0.7 if pts[k + 1][1] == "1" else 0.0
                    ax.plot([tb, tb], [y + lv, y + nv], color="black", lw=0.8)
            else:
                d = (t1 - t0) * 0.006
                ax.fill([ta + d, tb - d, tb, tb - d, ta + d, ta], [y + 0.7, y + 0.7, y + 0.35, y, y, y + 0.35], fc="#eef3f8", ec="black", lw=0.6)
                try: lab = "0x%X" % int(va, 2)
                except ValueError: lab = "X"
                if tb - ta > (t1 - t0) * 0.08:
                    ax.text((ta + tb) / 2, y + 0.35, lab, ha="center", va="center", fontsize=6.5)
    for k, (tm, lab) in enumerate(marks):
        ax.axvline(tm, color="#c00000", lw=0.8, ls="--")
        off = (t1 - t0) * 0.008
        ax.text(tm - off if k % 2 == 0 else tm + off, rows + 0.05, lab, color="#c00000",
                ha="right" if k % 2 == 0 else "left", va="bottom", fontsize=7)
    ax.set_xlim(t0, t1); ax.set_ylim(-0.25, rows + 0.45)
    ax.set_yticks([]); ax.set_xlabel("Time (ns)", fontsize=7.5)
    ax.tick_params(axis="x", labelsize=7)
    for sp in ("top", "right", "left"): ax.spines[sp].set_visible(False)
    fig.tight_layout(pad=0.2); fig.savefig(out, dpi=300); print("saved", out)

main()
