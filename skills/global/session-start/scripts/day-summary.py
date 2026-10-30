#!/usr/bin/env python3
"""Turn a project's entries.jsonl into the blocks table he keeps in time_entries/<date>-<topic>.md.

  day-summary.py [project] [--date YYYY-MM-DD | --since YYYY-MM-DDTHH:MM] [--until ...]

project defaults to $TRACK_PROJECT. Times are UTC, like the entries. Read-only: prints markdown, writes nothing.

Why not `track --summary`: it pairs starts and ends BY TASK NAME over the whole file, so a name used twice
("session start") pairs one day's start with another day's end and prints negative minutes, and it never
filters by day. This pairs in time order instead: a block runs from its start to its own end, or to the
next start, or to its last checkpoint.
"""
import argparse, json, os, pathlib, sys
from datetime import datetime, timezone

WS = pathlib.Path(os.environ.get("CLAUDE_WORKSPACE", str(pathlib.Path.home() / ".claude-workspace")))
LONG_BLOCK_MIN = 180  # a block this long may be a timer left running while nobody worked


def parse_ts(s):
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def load(path):
    entries, bad = [], 0
    for line in path.read_text(errors="replace").splitlines():
        if not line.strip():
            continue
        try:
            e = json.loads(line)
            e["_t"] = parse_ts(e["ts"])
            entries.append(e)
        except (ValueError, KeyError):
            bad += 1  # a task name with a double quote breaks the tool's hand-built JSON
    return sorted(entries, key=lambda e: e["_t"]), bad


def blocks(entries):
    out, cur, foreign = [], None, 0

    def close(end, how):
        nonlocal cur
        if cur:
            cur["end"], cur["how"] = end, how
            out.append(cur)
        cur = None

    for e in entries:
        kind, ref, t = e.get("type"), e.get("ref", ""), e["_t"]
        if kind == "prompt_start":
            close(t, "next task")
            cur = {"ref": ref, "start": t, "seen": t}
        elif kind == "checkpoint" and cur and ref == cur["ref"]:
            cur["seen"] = t
        elif kind == "checkpoint" and not cur:
            cur = {"ref": ref, "start": t, "seen": t}  # the task started before the window
        elif kind == "prompt_end" and cur and ref == cur["ref"]:
            close(t, "stopped")
        elif kind == "prompt_end":
            foreign += 1  # another session's timer was ended from this project (shared /tmp timer)
    if cur:
        cur["end"], cur["how"] = cur["seen"], "still running"
        out.append(cur)
    return out, foreign


def merge(bs):
    merged = []
    for b in bs:
        if merged and merged[-1]["ref"] == b["ref"] and (b["start"] - merged[-1]["end"]).total_seconds() <= 600:
            merged[-1]["end"], merged[-1]["how"] = b["end"], b["how"]
            continue
        merged.append(dict(b))
    return merged


def hm(minutes):
    return f"{minutes // 60}h{minutes % 60:02d}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("project", nargs="?", default=os.environ.get("TRACK_PROJECT"))
    ap.add_argument("--date", help="UTC day, YYYY-MM-DD (default today)")
    ap.add_argument("--since")
    ap.add_argument("--until")
    a = ap.parse_args()
    if not a.project:
        sys.exit("error: give a project or export TRACK_PROJECT")

    path = WS / a.project / "time_entries" / "entries.jsonl"
    if not path.exists():
        sys.exit(f"error: no entries at {path}")

    if a.since:
        lo = parse_ts(a.since if "+" in a.since or a.since.endswith("Z") else a.since + "+00:00")
        hi = parse_ts(a.until + "+00:00") if a.until else datetime.now(timezone.utc)
    else:
        day = a.date or datetime.now(timezone.utc).strftime("%Y-%m-%d")
        lo = parse_ts(day + "T00:00:00+00:00")
        hi = parse_ts(day + "T23:59:59+00:00")

    entries, bad = load(path)
    entries = [e for e in entries if lo <= e["_t"] <= hi]
    if not entries:
        print(f"No entries for {a.project} between {lo:%Y-%m-%d %H:%M} and {hi:%Y-%m-%d %H:%M} UTC.")
        return

    bs, foreign = blocks(entries)
    bs = merge(bs)
    total = 0
    print(f"Tracked blocks for {a.project} (UTC, from entries.jsonl):\n")
    print("| Block | From | To | Time |")
    print("|---|---|---|---|")
    for b in bs:
        mins = max(0, int((b["end"] - b["start"]).total_seconds() // 60))
        total += mins
        flag = " (no stop in window)" if b["how"] == "still running" else ""
        flag += " (check: long, trim to last real activity)" if mins >= LONG_BLOCK_MIN else ""
        print(f"| {b['ref']}{flag} | {b['start']:%H:%M} | {b['end']:%H:%M} | {hm(mins)} |")
    print(f"| **Total** | | | **{hm(total)}** |")
    if foreign:
        print(f"\nNote: {foreign} stop line(s) for another task were written here by the shared timer.")
    if bad:
        print(f"Note: {bad} unreadable line(s) skipped in entries.jsonl.")


if __name__ == "__main__":
    main()
