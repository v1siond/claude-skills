#!/usr/bin/env python3
"""SessionStart (compact): put the protocol, the orchestration skill and the project's live score back
into context, so the director resumes from the files and not from the compaction summary."""
from __future__ import annotations
import json
import os
import re
import sys
from pathlib import Path

HOME = Path.home()
WORKSPACE = Path(os.environ.get("CLAUDE_WORKSPACE", str(HOME / ".claude-workspace")))
SKILL = HOME / ".claude/skills/orchestration/SKILL.md"
PROTOCOL = HOME / ".claude/protocol.txt"
PROJECTS = re.escape(str(HOME / "projects"))


def project_of(cwd: str) -> str | None:
    m = re.match(PROJECTS + r"/([^/]+)", cwd or "")
    return m.group(1) if m else None


def current_score(orchestra: Path, limit: int = 60) -> str:
    lines = orchestra.read_text().splitlines()
    start = next((i for i, l in enumerate(lines) if re.match(r"## (Batch .*score|Score)", l)), None)
    if start is None:
        return "\n".join(lines[:limit])
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("## ")), len(lines))
    return "\n".join(lines[start:min(end, start + limit)])


def main() -> None:
    try:
        cwd = json.load(sys.stdin).get("cwd", "")
    except Exception:
        cwd = ""
    out = ["POST COMPACTION. The summary is not the source; the files below are. You are the director.",
           "Before any other tool call: re-read ORCHESTRA.md and the handoff, check every running agent, and",
           "continue the score where it stands, in the order he approved. Never edit a skill to resume work.", ""]
    if PROTOCOL.exists():
        out += [PROTOCOL.read_text(), ""]
    if SKILL.exists():
        out += ["=== skill orchestration (the workflow, in force now) ===", SKILL.read_text(), ""]
    project = project_of(cwd)
    if project:
        ws = WORKSPACE / project
        orchestra, handoff = ws / "ORCHESTRA.md", ws / "HANDOFF-CURRENT.md"
        if orchestra.exists():
            out += [f"=== {orchestra} (current score, read the whole file next) ===", current_score(orchestra), ""]
        if handoff.exists():
            out += [f"=== {handoff} (newest lines, read the whole file next) ===",
                    "\n".join(handoff.read_text().splitlines()[-40:])]
    print("\n".join(out))


if __name__ == "__main__":
    main()
