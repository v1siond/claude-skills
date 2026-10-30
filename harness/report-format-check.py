#!/usr/bin/env python3
"""Reads the last assistant message of a transcript and prints one line per way it breaks the report shapes.

Prints nothing when the message passes. Called by stop-report-format.sh; run it by hand on a saved message
with --text <file>. The shapes are orchestration law 18 and ~/.claude/report-format.md:

- a standup: the first line starts "Working on:" (or a bold "**Working on:**"), 3 to 6 lines in all, and at most
  one line starting "Waiting on you:" (every open question shares it);
- a full report: has a heading line "## What changed", so it must also have a heading line "## How to QA", and
  each question under the heading line "## Questions for you" (one per "### " heading) must carry
  "Why it matters" and "My recommendation"; a Questions section holding only "None." passes;
- a heading line is a line holding only the heading; a heading named inside a sentence is not one;
- fenced code blocks are skipped by the shape checks (an example of a report is not a report);
- any other message passes the shape checks (an answer is not an update);
- every message: no em dash and no en dash, fenced code blocks included.
"""
import json
import re
import sys

STANDUP_START = re.compile(r"^\*{0,2}Working on:")
WAITING = re.compile(r"^\*{0,2}Waiting on you:")
STANDUP_LINES = range(3, 7)
FULL_REPORT = "## What changed"
HOW_TO_QA = "## How to QA"
QUESTIONS = "## Questions for you"
NO_QUESTIONS = "None."
CARD_LABELS = ("Why it matters", "My recommendation")
FENCE = re.compile(r"^```.*?^```", re.M | re.S)
DASHES = ((chr(0x2014), "em dash"), (chr(0x2013), "en dash"))


def last_assistant_text(path: str) -> str:
    """The text of the final assistant message carrying text, joined across its blocks."""
    text = ""

    with open(path, encoding="utf-8", errors="replace") as handle:
        for line in handle:
            joined = message_text(line.strip())
            if joined.strip():
                text = joined

    return text


def message_text(line: str) -> str:
    """The text blocks of one transcript line when it is an assistant message, else an empty string."""
    try:
        entry = json.loads(line) if line else {}
    except ValueError:
        return ""

    message = entry.get("message") or {}
    if entry.get("type") != "assistant" and message.get("role") != "assistant":
        return ""

    content = message.get("content")
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""

    blocks = [b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"]
    return "\n".join(b for b in blocks if b.strip())


def heading(text: str, name: str):
    """The match of a line holding only the heading `name`, or None: a heading named inside a sentence is not one."""
    return re.search(rf"^{re.escape(name)}\s*$", text, re.M)


def section(text: str, name: str) -> str:
    """Everything under one "## " heading line, up to the next "## " heading line."""
    found = heading(text, name)
    if not found:
        return ""

    rest = text[found.end():]
    nxt = re.search(r"^## ", rest, re.M)
    return rest[: nxt.start()] if nxt else rest


def dash_failures(text: str) -> list:
    return [f"  There is an {name} in the message. Full stop, comma or colon instead." for dash, name in DASHES if dash in text]


def standup_failures(lines: list) -> list:
    return standup_length_failures(lines) + waiting_failures(lines)


def standup_length_failures(lines: list) -> list:
    if len(lines) in STANDUP_LINES:
        return []
    return [f"  A standup is 3 to 6 lines; this one has {len(lines)}. Keep Working on, Needs before done, Then, Waiting on you, Batch; every open question shares the one Waiting on you line."]


def waiting_failures(lines: list) -> list:
    waiting = [l for l in lines if WAITING.match(l.strip())]
    if len(waiting) < 2:
        return []
    return [f"  A standup has one Waiting on you line; this one has {len(waiting)}. Put every open question on that one line, each a short title with the time it was first asked: Waiting on you: the bell quest (asked 10-26 18:52), heart pieces (asked 10-26 18:52)."]


def card_failures(text: str) -> list:
    body = section(text, QUESTIONS).strip()
    if body in ("", NO_QUESTIONS):
        return []

    cards = [c for c in re.split(r"^### ", body, flags=re.M) if c.strip()]
    out = []
    for card in cards:
        missing = [label for label in CARD_LABELS if label not in card]
        if missing:
            title = card.strip().splitlines()[0][:80]
            out.append(f"  The question \"{title}\" has no {' and no '.join(missing)}. A card: What it is, Why it matters, Options, My recommendation.")
    return out


def full_report_failures(text: str) -> list:
    out = []
    if not heading(text, HOW_TO_QA):
        out.append("  A full report needs \"## How to QA\": setup (server and port, migrations, env vars, seeds), then per ticket open X, do Y, expect Z.")
    return out + card_failures(text)


def failures(text: str) -> list:
    if not text.strip():
        return []  # a turn with no message is not a bad update

    out = dash_failures(text)  # the dash check reads the full text, fenced blocks included
    shape = FENCE.sub("", text)
    if not shape.strip():
        return out  # a message that is only fenced blocks has no shape to check

    lines = [l for l in shape.strip().splitlines() if l.strip()]
    if STANDUP_START.match(lines[0].strip()):
        return out + standup_failures(lines)
    if heading(shape, FULL_REPORT):
        return out + full_report_failures(shape)
    return out


def read_text(args: list) -> str:
    if args[0] == "--text":
        with open(args[1], encoding="utf-8", errors="replace") as handle:
            return handle.read()
    return last_assistant_text(args[0])


def main() -> int:
    args = sys.argv[1:]
    if not args or (args[0] == "--text" and len(args) < 2):
        return 0

    for line in failures(read_text(args)):
        print(line)

    return 0


if __name__ == "__main__":
    sys.exit(main())
