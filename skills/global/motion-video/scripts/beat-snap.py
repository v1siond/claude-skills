#!/usr/bin/env python3
"""Snap every cut of a film to the nearest beat of its score, and write the cut list the score reads.

  beat-snap.py <segments.json> <out.json> [--grid beat|half|bar] [--max 0.15]
  beat-snap.py --self-test

Reads the bpm and each segment's dur (segments.py times wrote them). Each cut, and the end of the film,
moves to the nearest grid point when that is at most --max seconds away (0.15 s keeps a reveal on its
action); a cut farther than that stays where it is and is listed as off the grid. Only dur changes:
segments.py build trims the take to from + dur * speed, and score.py swells into the new cuts, so the
picture and the music share one cut list. Prints every move; refuses to overwrite an existing output.
"""
from __future__ import annotations

import argparse
import json
import os
import sys

GRID_BEATS = {"half": 0.5, "beat": 1.0, "bar": 4.0}


def snap(boundaries: list[float], step: float, limit: float) -> list[tuple[float, float, bool]]:
    """Per boundary: (original, new, snapped)."""
    out = []
    for c in boundaries:
        g = round(round(c / step) * step, 3)
        ok = abs(g - c) <= limit + 1e-9
        out.append((c, g if ok else c, ok))
    return out


def resnap(film: dict, grid: str, limit: float) -> tuple[dict, list[tuple[str, float, float, bool]]]:
    segs = film["segments"]
    step = 60.0 / film.get("bpm", 120) * GRID_BEATS[grid]
    boundaries, total = [], 0.0
    for s in segs:
        total = round(total + s["dur"], 3)
        boundaries.append(total)
    moves = snap(boundaries, step, limit)
    new, prev = [], 0.0
    for s, (_, b, _) in zip(segs, moves):
        new.append({**s, "dur": round(b - prev, 3)})
        prev = b
    ends = [b for _, b, _ in moves]
    rows = [(s["id"], c, b, ok) for s, (c, b, ok) in zip(segs, moves)]
    return {**film, "segments": new, "cuts": ends[:-1], "total": ends[-1], "grid": round(step, 3)}, rows


def print_rows(rows: list[tuple[str, float, float, bool]], step: float) -> None:
    for sid, c, b, ok in rows:
        state = f"moved {b - c:+.3f} s" if ok and b != c else ("on the grid" if ok else "OFF THE GRID, kept")
        print(f"{sid:16} ends {c:8.3f} -> {b:8.3f}  {state}")
    off = sum(not ok for *_, ok in rows)
    print(f"grid {step:.3f} s: {len(rows) - off} of {len(rows)} ends on the grid, {off} kept off it")


def self_test() -> None:
    film = {"bpm": 120, "segments": [{"id": "a", "dur": 1.1}, {"id": "b", "dur": 1.15}, {"id": "c", "dur": 2.0}]}
    out, rows = resnap(film, "beat", 0.15)
    print_rows(rows, out["grid"])
    durs = [s["dur"] for s in out["segments"]]
    ok = durs == [1.0, 1.25, 2.0] and out["cuts"] == [1.0, 2.25] and out["total"] == 4.25
    print(f"self test {'ok' if ok else 'FAILED'}: durs {durs}, cuts {out['cuts']}, total {out['total']}")
    sys.exit(0 if ok else 1)


def main() -> None:
    if "--self-test" in sys.argv:
        self_test()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("segments")
    ap.add_argument("out")
    ap.add_argument("--grid", choices=sorted(GRID_BEATS), default="beat")
    ap.add_argument("--max", type=float, default=0.15, help="largest shift in seconds")
    ap.add_argument("--self-test", action="store_true", help="snap three made up segments and check them")
    a = ap.parse_args()
    if os.path.exists(a.out):
        sys.exit(f"beat-snap.py: {a.out} exists, delete it first")
    with open(a.segments, encoding="utf-8") as f:
        film = json.load(f)
    out, rows = resnap(film, a.grid, a.max)
    print_rows(rows, out["grid"])
    with open(a.out, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
    print(f"wrote {a.out}")


main()
