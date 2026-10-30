#!/usr/bin/env python3
"""Verdicts for performance-expert, from numbers a probe wrote to JSON. Read only; standard library only.

  perf-verdict.py frames <before.json> [<after.json>] [--budget-ms 8.33]  (default 1000/120)
      file: {"scene": "...", "count": <int above 0, objects on screen>, "runs": [[frame ms, ...], ...]}
      prints per file the median and p95 of each run, the median of medians, the budget verdict; with two files,
      "keep" when the after median beats the before median by more than the before run spread, else "drop".
  perf-verdict.py leak <pairs.json> [--tolerance 0.10]
      file: [{"heap": <bytes after GC>, "listeners": n, "nodes": n, "canvases": n (in every pair or in none)}, ...] one per pair
      prints "leak: ok" or "leak: FAIL <what grew>"; a heap whose every second half pair is above every first half
      pair FAILs as still rising.
Exit 0 on pass, 1 on a FAIL line, 2 on bad input.
"""
from __future__ import annotations
import argparse, json, statistics, sys

# A run needs enough frames for a p95 to mean something: 300 frames is 2.5 s at 120 fps (the protocol's length).
MIN_FRAMES = 300
# Three runs, median of medians: one run alone cannot show the run to run spread (Lighthouse CI numberOfRuns 3).
MIN_RUNS = 3
# Law 4: 10 pairs. Proposed, needs a number: no source states a count; a leak of one item per open shows as 10 items.
MIN_PAIRS = 10


def p95(xs: list[float]) -> float:
    s = sorted(xs)
    return s[min(len(s) - 1, int(round(0.95 * (len(s) - 1))))]


def summary(path: str, budget: float) -> tuple[float, float, bool]:
    d = json.load(open(path))
    runs = d.get("runs") or []
    c = d.get("count")
    if not isinstance(c, int) or isinstance(c, bool) or c <= 0:
        print(f"FAIL {path}: count is {c!r}, needs an int above 0; an empty scene reports a perfect frame, assert content first")
        sys.exit(1)
    if len(runs) < MIN_RUNS or any(len(r) < MIN_FRAMES for r in runs):
        print(f"FAIL {path}: need {MIN_RUNS} runs of {MIN_FRAMES} frames or more, got {[len(r) for r in runs]}")
        sys.exit(1)
    meds = [statistics.median(r) for r in runs]
    if min(meds) <= 0:
        raise ValueError(f"{path}: a run median is {min(meds)} ms; frame times must be above 0")
    for i, r in enumerate(runs, 1):
        print(f"{path} run {i}: median {meds[i-1]:.2f} ms, p95 {p95(r):.2f} ms, {len(r)} frames")
    med = statistics.median(meds)
    ok = med <= budget
    print(f"{path}: scene {d.get('scene', '?')}, count {d['count']}, median of medians {med:.2f} ms "
          f"({1000 / med:.0f} fps), budget {budget:.2f} ms: {'pass' if ok else 'FAIL over budget'}")
    return med, max(meds) - min(meds), ok


def frames(a) -> int:
    before, spread, ok = summary(a.before, a.budget_ms)
    if not a.after: return 0 if ok else 1
    after, _, after_ok = summary(a.after, a.budget_ms)
    gain = before - after
    verdict = "keep" if gain > spread else "drop"
    print(f"{verdict}: before {before:.2f} ms, after {after:.2f} ms, gain {gain:.2f} ms, noise {spread:.2f} ms")
    if verdict == "keep" and not after_ok: print(f"FAIL: kept, but the after median is over the {a.budget_ms:.2f} ms budget")
    return 0 if verdict == "keep" and after_ok else 1


def leak(a) -> int:
    pairs = json.load(open(a.pairs))
    if not isinstance(pairs, list): raise ValueError("the file must be a JSON list, one object per pair")
    if len(pairs) < MIN_PAIRS:
        print(f"FAIL: need {MIN_PAIRS} pairs or more (law 4), got {len(pairs)}"); return 1
    first, bad = pairs[0], []
    if first["heap"] <= 0: raise ValueError("pair 1 heap must be above 0 bytes")
    for i, p in enumerate(pairs, 1):  # every pair against pair 1, so a climb that falls back by the last pair still fails
        if p["heap"] > first["heap"] * (1 + a.tolerance):
            bad.append(f"pair {i} heap {first['heap']} -> {p['heap']} bytes (+{100 * (p['heap'] / first['heap'] - 1):.1f}%)")
        for k in ("listeners", "nodes"):
            if p[k] != first[k]: bad.append(f"pair {i} {k} {first[k]} -> {p[k]}")
    if any("canvases" in p for p in pairs) and max(p["canvases"] for p in pairs[len(pairs) // 2:]) > max(p["canvases"] for p in pairs[:len(pairs) // 2]):
        bad.append(f"canvases still rising in the second half ({[p['canvases'] for p in pairs]})")
    # A cache keyed on a moving value grows the heap a little on every open with listeners and nodes flat, under the
    # 10% line: every second half pair above every first half pair is that climb.
    heaps, half = [p["heap"] for p in pairs], len(pairs) // 2
    heap_mb = [round(h / 2**20, 1) for h in heaps]
    if min(heaps[half:]) > max(heaps[:half]):
        bad.append(f"heap still rising in the second half ({heap_mb} MB)")
    print(f"pairs {len(pairs)}, heap {heap_mb} MB")
    if bad: print("leak: FAIL " + "; ".join(bad)); return 1
    print("leak: ok"); return 0


def main() -> None:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    f = sub.add_parser("frames"); f.add_argument("before"); f.add_argument("after", nargs="?")
    # 1000 / 120 unrounded: the 120 fps he names (10-28). A frame ms is the interval between the app's own
    # requestAnimationFrame callbacks, so a 120 Hz display cannot go under it. Pass --budget-ms 16.67 for 60 fps.
    f.add_argument("--budget-ms", type=float, default=1000 / 120)
    l = sub.add_parser("leak"); l.add_argument("pairs")
    # 10% of heap after GC: our threshold, no source states one; tighten it once a clean baseline shows its noise.
    l.add_argument("--tolerance", type=float, default=0.10)
    a = ap.parse_args()
    try: sys.exit(frames(a) if a.cmd == "frames" else leak(a))
    except (OSError, ValueError, KeyError, TypeError) as e:
        print(f"bad input: {e}"); sys.exit(2)


if __name__ == "__main__":
    main()
