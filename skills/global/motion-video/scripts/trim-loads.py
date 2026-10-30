#!/usr/bin/env python3
"""Measure the loading or blank frames at the head and tail of every take segment.

  trim-loads.py <segments.json> <take.webm> [--ratio 0.5] [--fps 30] [id ...]
  trim-loads.py --self-test

For each segment that comes from the take (cards are skipped), the take is decoded from `from` to its end at
160x90 gray. A frame counts as loading when its contrast (standard deviation of the pixels) is under
--ratio times the segment's median contrast: a blank page, a white tail, a skeleton or a spinner on an
empty screen. The script prints, per segment, the seconds of loading frames at the head and the tail, and
the offsets in take seconds that would drop them. It measures and does not decide: a slow reveal can read
as loading, so every line is read against the stills before an offset is changed in the spec.
Needs numpy and ffmpeg; writes nothing.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile

import numpy as np

W, H = 160, 90


def frames(take: str, start: float, end: float, fps: int) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-ss", f"{start:.3f}", "-to", f"{end:.3f}", "-i", take,
                          "-vf", f"fps={fps},scale={W}:{H}", "-f", "rawvideo", "-pix_fmt", "gray", "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.uint8).reshape(-1, H, W).astype(np.float32)


def run_length(flags: np.ndarray) -> int:
    """How many leading entries are True."""
    off = np.flatnonzero(~flags)
    return len(flags) if len(off) == 0 else int(off[0])


def measure(stack: np.ndarray, ratio: float) -> tuple[int, int]:
    contrast = stack.reshape(len(stack), -1).std(axis=1)
    loading = contrast < ratio * np.median(contrast)
    return run_length(loading), run_length(loading[::-1])


def segment_end(s: dict) -> float:
    return s["to"] if "hold" in s else s["from"] + s["dur"] * s.get("speed", 1.0)


def report(film: dict, take: str, ratio: float, fps: int, only: list[str]) -> list[tuple[str, float, float]]:
    rows = []
    for s in film["segments"]:
        if "card" in s or (only and s["id"] not in only):
            continue
        stack = frames(take, s["from"], segment_end(s), fps)
        if len(stack) == 0:
            print(f"{s['id']:16} no frames decoded between {s['from']} and {segment_end(s):.3f}")
            continue
        head, tail = measure(stack, ratio)
        lead, trail = head / fps, tail / fps
        rows.append((s["id"], lead, trail))
        hint = f"from {s['from'] + lead:.2f}, end {segment_end(s) - trail:.2f}" if head or tail else "none"
        print(f"{s['id']:16} head {lead:5.2f} s  tail {trail:5.2f} s  of {len(stack) / fps:5.2f} s   drop: {hint}")
    return rows


def self_test() -> None:
    d = tempfile.mkdtemp(prefix="trim-loads-test-")
    take = os.path.join(d, "take.mp4")
    white = "color=c=white:s=320x180:r=30:d={}"
    subprocess.run(["ffmpeg", "-v", "error", "-f", "lavfi", "-i", white.format(1), "-f", "lavfi",
                    "-i", "testsrc=size=320x180:rate=30:duration=3", "-f", "lavfi", "-i", white.format(0.5),
                    "-filter_complex", "[0:v][1:v][2:v]concat=n=3:v=1[v]", "-map", "[v]", "-c:v", "libx264",
                    "-pix_fmt", "yuv420p", take], check=True)
    film = {"segments": [{"id": "s01", "from": 0.0, "to": 4.5, "dur": 4.5, "speed": 1.0}]}
    rows = report(film, take, 0.5, 30, [])
    ok = rows == [("s01", 1.0, 0.5)]
    print(f"self test {'ok' if ok else 'FAILED'}: {rows} (want head 1.0, tail 0.5); {d}")
    sys.exit(0 if ok else 1)


def main() -> None:
    if "--self-test" in sys.argv:
        self_test()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("segments", help="segments.json written by segments.py times")
    ap.add_argument("take")
    ap.add_argument("only", nargs="*", help="only these segment ids")
    ap.add_argument("--ratio", type=float, default=0.5)
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--self-test", action="store_true", help="measure a white, pattern, white test clip")
    a = ap.parse_args()
    with open(a.segments, encoding="utf-8") as f:
        report(json.load(f), a.take, a.ratio, a.fps, a.only)


main()
