#!/usr/bin/env python3
"""Turn a WebVTT or SRT subtitle file into a clean timestamped transcript.

YouTube auto captions roll: every line is shown twice (once with word timing tags, once plain in a
10 ms cue) and each cue repeats the previous line. This keeps the first time each line appears, with
the start time of the cue that introduced it.

  vtt-to-text.py <file.vtt|file.srt> [source-url]

Prints `[hh:mm:ss] text` lines. With a source url, a header line names it; a takeaway links to a
moment as <url>?t=<seconds>s.
"""
import re
import sys

TIME = re.compile(r"(\d+):(\d{2}):(\d{2})[.,](\d{3})\s+-->")
TAG = re.compile(r"<[^>]+>")


def seconds(match):
    hours, minutes, secs, _ = match.groups()
    return int(hours) * 3600 + int(minutes) * 60 + int(secs)


def stamp(total):
    return f"{total // 3600:02d}:{total % 3600 // 60:02d}:{total % 60:02d}"


def cues(lines):
    start, text = None, []
    for raw in lines:
        line = raw.rstrip("\n")
        found = TIME.search(line)
        if found:
            if start is not None:
                yield start, text
            start, text = seconds(found), []
            continue
        if start is None or line.strip().isdigit():
            continue
        clean = TAG.sub("", line).strip()
        if clean:
            text.append(clean)
    if start is not None:
        yield start, text


def transcript(lines):
    recent = []
    for start, text in cues(lines):
        for line in text:
            if line in recent:
                continue
            recent = (recent + [line])[-3:]
            yield start, line


def main(argv):
    if len(argv) < 2:
        sys.exit("usage: vtt-to-text.py <file.vtt|file.srt> [source-url]")
    url = argv[2] if len(argv) > 2 else ""
    with open(argv[1], encoding="utf-8", errors="replace") as handle:
        rows = list(transcript(handle))
    if not rows:
        sys.exit(f"no caption text found in {argv[1]}")
    if url:
        print(f"# source: {url}")
    for start, line in rows:
        print(f"[{stamp(start)}] {line}")


if __name__ == "__main__":
    main(sys.argv)
