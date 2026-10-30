#!/usr/bin/env python3
"""Print lines of a file at a commit as a source line plus a fenced block, ready to paste into post.md.

  code-extract.py <repo> <sha> <path> <start> <end> [--lang ts] [--json]
  code-extract.py --self-test

Reads with `git -C <repo> show <sha>:<path>`, so the lines are what the commit holds, never the working
tree. The source line names the path, the short sha and the line range; post-check.py and media-check.py
look for it. --json prints {"source", "lines"} for media-check.py. Writes nothing.
"""
from __future__ import annotations

import json, subprocess, sys, tempfile, pathlib

LANG = {".ts": "ts", ".tsx": "tsx", ".js": "js", ".mjs": "js", ".jsx": "jsx", ".ex": "elixir", ".exs": "elixir",
        ".py": "python", ".sh": "bash", ".css": "css", ".json": "json", ".yml": "yaml", ".yaml": "yaml",
        ".md": "markdown", ".html": "html", ".sql": "sql"}


def lines_at(repo: str, sha: str, path: str, start: int, end: int) -> list[str]:
    out = subprocess.run(["git", "-C", repo, "show", f"{sha}:{path}"], capture_output=True, text=True)
    if out.returncode: sys.exit(f"git show {sha}:{path} failed: {out.stderr.strip()}")
    rows = out.stdout.split("\n")
    if not 1 <= start <= end <= len(rows): sys.exit(f"range {start}-{end} outside 1-{len(rows)}")
    return rows[start - 1:end]


def block(repo: str, sha: str, path: str, start: int, end: int, lang: str | None = None) -> str:
    rows = lines_at(repo, sha, path, start, end)
    full = subprocess.run(["git", "-C", repo, "rev-parse", "--short=7", sha], capture_output=True, text=True).stdout.strip() or sha[:7]
    lang = lang or LANG.get(pathlib.Path(path).suffix, "")
    return f"From `{path}` at `{full}`, lines {start} to {end}:\n\n```{lang}\n" + "\n".join(rows) + "\n```\n"


def self_test() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        run = lambda *a: subprocess.run(["git", "-C", tmp, *a], check=True, capture_output=True, text=True)
        run("init", "-q"); (pathlib.Path(tmp) / "a.ts").write_text("one\ntwo\nthree\n")
        run("add", "."); run("-c", "user.name=t", "-c", "user.email=t@t", "commit", "-qm", "x")
        (pathlib.Path(tmp) / "a.ts").write_text("changed\n")
        sha = run("rev-parse", "HEAD").stdout.strip()
        out = block(tmp, sha, "a.ts", 2, 3)
        assert "```ts\ntwo\nthree\n```" in out and sha[:7] in out, out
    print("self-test ok")


def main() -> None:
    a = sys.argv[1:]
    if a == ["--self-test"]: return self_test()
    if len(a) < 5: sys.exit(__doc__)
    repo, sha, path, start, end = a[0], a[1], a[2], int(a[3]), int(a[4])
    lang = a[a.index("--lang") + 1] if "--lang" in a else None
    if "--json" in a:
        print(json.dumps({"source": f"{repo}@{sha}:{path}#L{start}-L{end}", "lines": lines_at(repo, sha, path, start, end)}))
    else:
        print(block(repo, sha, path, start, end, lang), end="")


if __name__ == "__main__":
    main()
