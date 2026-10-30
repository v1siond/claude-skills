#!/usr/bin/env python3
"""Measure which skill a real prompt triggers, with the whole skill set installed (so siblings compete).

  trigger-test.py <queries.json> [--skill name ...] [--jobs 2] [--out results.json] [--model claude-opus-5-5]

queries.json: [{"query": "...", "skill": "ship", "should_trigger": true, "cwd": "optional"}, ...]
Each query runs `claude -p` in its row's "cwd" (default: a fresh empty temp dir, so a project skill is tested
from inside its project and a global one from nowhere in particular) with Bash/Edit/Write disabled, so nothing
is written anywhere. Given the shared file, it also reads the private overlay's rows (skills/specific/trigger-queries.json)
when present. The run is stopped after a few tool calls; every Skill invoked by then is recorded.
A should_trigger row passes when its skill was invoked; a should_trigger=false row passes when it was NOT.
"""
from __future__ import annotations
import json, os, pathlib, subprocess, sys, tempfile, time, argparse
from concurrent.futures import ThreadPoolExecutor

SKILLS = pathlib.Path(__file__).resolve().parents[3]
PRIVATE_QUERIES = SKILLS / "specific/trigger-queries.json"
CWD = tempfile.mkdtemp(prefix="trigger-test-")
# session-start runs first on every new session and reads several files, so the cap leaves room after it.
MAX_TOOL_CALLS, TIMEOUT = 12, 240

def run(query: str, model: str | None, cwd: str = CWD) -> list[str]:
    cmd = ["claude", "-p", query, "--output-format", "stream-json", "--verbose",
           "--disallowedTools", "Bash", "Edit", "Write", "NotebookEdit", "Agent", "Workflow"]
    if model: cmd += ["--model", model]
    env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
    p = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, env=env)
    skills, calls, start = [], 0, time.time()
    try:
        for line in p.stdout:
            if time.time() - start > TIMEOUT: break
            try: ev = json.loads(line)
            except ValueError: continue
            if ev.get("type") != "assistant": continue
            for block in ev.get("message", {}).get("content", []):
                if block.get("type") != "tool_use": continue
                calls += 1
                if block.get("name") == "Skill": skills.append(block.get("input", {}).get("skill", "?"))
            if calls >= MAX_TOOL_CALLS: break
    finally:
        p.kill()
    return skills

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("queries"); ap.add_argument("--jobs", type=int, default=2)
    ap.add_argument("--skill", action="append", default=[], help="run only the rows of these skills")
    ap.add_argument("--out", default=None); ap.add_argument("--model", default=None)
    a = ap.parse_args()
    rows = json.load(open(a.queries))
    if pathlib.Path(a.queries).resolve() == SKILLS / "global/skill-craft/references/trigger-queries.json" and PRIVATE_QUERIES.exists():
        rows += json.load(open(PRIVATE_QUERIES))
    if a.skill: rows = [r for r in rows if r["skill"] in a.skill]
    with ThreadPoolExecutor(a.jobs) as ex:
        got = list(ex.map(lambda r: run(r["query"], a.model, r.get("cwd", CWD)), rows))
    passed = 0
    for r, s in zip(rows, got):
        hit = r["skill"] in s
        ok = hit == r.get("should_trigger", True)
        passed += ok
        r["invoked"], r["pass"] = s, ok
        print(f"{'PASS' if ok else 'FAIL'}  {'+' if r.get('should_trigger', True) else '-'}{r['skill']:<26} got={s}  q={r['query'][:70]}")
    print(f"\n{passed}/{len(rows)} passed ({100*passed//max(1,len(rows))}%)")
    if a.out: json.dump(rows, open(a.out, "w"), indent=1)

main()
