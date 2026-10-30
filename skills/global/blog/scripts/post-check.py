#!/usr/bin/env python3
"""Check a blog post folder at one stage, before the critic sees it. Writes nothing; exit 1 on any FAIL.

  post-check.py <post-folder> --stage outline|draft|final [--deny "Name A,Name B"]
  post-check.py --self-test

outline: post.json shape. title 1 to 70 characters, slug kebab case and equal to the folder name, meta
  description 70 to 160 characters, keyword, intent, kind, promise; every beat has id, heading, claim and
  at least one evidence {type: sha|session|file|external, ref}; a sha ref is 7 or more hex characters, a
  file ref that is an absolute path exists; every media item has id, beat, kind, shows, route, file, alt,
  caption, format (code and output items: id, beat, kind, shows, route, caption, source), and every code
  item a source "repo@sha:path#Lstart-Lend" (an output item's source is the command it ran); every media id is used by a
  beat and every beat media id is in the list; a series has hub, prev and next (or "pending:<row>").
draft: the above, plus post.md exists, its first heading is the title, no em or en dash, every media file
  and every code item's source line appear in post.md, every fenced block with a language other than
  text is preceded by a source line naming a sha, and every text block by a line starting "Output".
final: the above, plus every media file exists under media/ with a non empty "seen" line, and the newest
  critic/final-N.md has every axis score 8 or more and ends with "Verdict: ship".
--deny: names that must not appear in post.json or post.md (case insensitive). Secrets are always
  checked: key or token shapes, private keys, email addresses.
"""
from __future__ import annotations

import json, pathlib, re, sys, tempfile

DASH = re.compile("[\u2014\u2013]")
KEBAB = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
SHA = re.compile(r"^[0-9a-f]{7,40}$")
CODE_SRC = re.compile(r"^(?P<repo>/[^@]+)@(?P<sha>[0-9a-f]{7,40}):(?P<path>[^#]+)#L(?P<a>\d+)-L(?P<b>\d+)$")
SECRETS = [re.compile(p) for p in (r"sk-[A-Za-z0-9]{20,}", r"gh[pousr]_[A-Za-z0-9]{20,}", r"AKIA[0-9A-Z]{16}",
           r"-----BEGIN [A-Z ]*PRIVATE KEY-----", r"\bxox[abp]-[A-Za-z0-9-]{10,}",
           r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}")]
BEAT_KEYS = ["id", "heading", "claim", "evidence", "media"]
MEDIA_KEYS = ["id", "beat", "kind", "shows", "route", "file", "alt", "caption", "format"]
CODE_KEYS = ["id", "beat", "kind", "shows", "route", "caption", "source"]
KINDS = {"screenshot", "clip", "diagram", "film", "code", "image", "output"}


def outline(folder: pathlib.Path, post: dict) -> list[str]:
    f = []
    title = post.get("title", "")
    if not 1 <= len(title) <= 70: f.append(f"title is {len(title)} characters (1 to 70)")
    slug = post.get("slug", "")
    if not KEBAB.match(slug): f.append(f"slug not kebab case: {slug!r}")
    if slug != folder.name: f.append(f"slug {slug!r} differs from the folder {folder.name!r}")
    meta = post.get("meta_description", "")
    if not 70 <= len(meta) <= 160: f.append(f"meta_description is {len(meta)} characters (70 to 160)")
    for k in ("keyword", "intent", "kind", "promise", "row"):
        if not post.get(k): f.append(f"{k} missing")
    kw = post.get("keyword", "").lower()
    first = (title + " " + post.get("promise", "")).lower()
    if kw and not all(w in first for w in kw.split()):
        f.append(f"WARN keyword {kw!r} is not in the title or the promise")
    beats, media = post.get("beats") or [], post.get("media") or []
    if not beats: f.append("no beats")
    used = set()
    for b in beats:
        bid = b.get("id", "?")
        for k in BEAT_KEYS:
            if k not in b or (k != "media" and not b[k]): f.append(f"beat {bid}: {k} missing")
        for e in b.get("evidence") or []:
            t, ref = e.get("type"), str(e.get("ref", ""))
            if t not in {"sha", "session", "file", "external"}: f.append(f"beat {bid}: evidence type {t!r}")
            if t == "sha" and not SHA.match(ref.split()[0] if ref else ""): f.append(f"beat {bid}: sha {ref!r}")
            if t == "file" and ref.startswith("/") and not pathlib.Path(ref.split("#")[0].split(":")[0]).exists():
                f.append(f"beat {bid}: file missing {ref}")
            if t == "session" and not re.search(r"[0-9a-f]{8}\s+\d{2}-\d{2}T\d{2}:\d{2}", ref):
                f.append(f"beat {bid}: session ref needs 'id8 MM-DDTHH:MM': {ref!r}")
        used.update(b.get("media") or [])
    ids = {m.get("id") for m in media}
    for m in media:
        mid = m.get("id", "?")
        textual = m.get("kind") in {"code", "output"}
        for k in (CODE_KEYS if textual else MEDIA_KEYS):
            if not m.get(k): f.append(f"media {mid}: {k} missing")
        if m.get("kind") not in KINDS: f.append(f"media {mid}: kind {m.get('kind')!r} not in {sorted(KINDS)}")
        if m.get("kind") == "code" and not CODE_SRC.match(m.get("source", "")):
            f.append(f"media {mid}: code source must be repo@sha:path#La-Lb, got {m.get('source')!r}")
        if mid not in used: f.append(f"media {mid}: no beat uses it")
        if re.search(r"placeholder|todo|tbd|image here", json.dumps(m), re.I): f.append(f"media {mid}: placeholder text")
    for mid in used - ids: f.append(f"beat media id {mid!r} is not in the media list")
    s = post.get("series")
    if s:
        for k in ("id", "part", "hub", "prev", "next"):
            if k not in s: f.append(f"series: {k} missing (use null for none, pending:<row> for unwritten)")
    return f


def draft(folder: pathlib.Path, post: dict) -> list[str]:
    md_path = folder / "post.md"
    if not md_path.exists(): return ["post.md missing"]
    md = md_path.read_text()
    f = []
    h1 = next((ln[2:].strip() for ln in md.splitlines() if ln.startswith("# ")), "")
    if h1 != post.get("title"): f.append(f"first heading {h1!r} is not the title")
    prose = re.sub(r"^```.*?^```", "", md, flags=re.S | re.M)
    if DASH.search(prose): f.append("em or en dash in post.md prose")
    elif DASH.search(md): f.append("WARN em or en dash inside a code block (verbatim code; pick a range without it if you can)")
    for m in post.get("media") or []:
        if m.get("kind") in {"code", "output"}:
            src = CODE_SRC.match(m.get("source", ""))
            if src and src["sha"][:7] not in md: f.append(f"media {m['id']}: its sha is not named in post.md")
        elif m.get("file") and m["file"] not in md: f.append(f"media {m['id']}: {m['file']} not referenced in post.md")
    lines = md.splitlines()
    in_fence = False
    for i, ln in enumerate(lines):
        if not ln.startswith("```"): continue
        if in_fence: in_fence = False; continue
        in_fence = True
        lang = ln[3:].strip()
        prev = next((p for p in reversed(lines[max(0, i - 3):i]) if p.strip()), "")
        if lang in {"", "text", "console"}:
            if not prev.lower().startswith("output"): f.append(f"post.md line {i + 1}: text block without an 'Output' line before it")
        elif not re.search(r"\b[0-9a-f]{7,40}\b", prev): f.append(f"post.md line {i + 1}: code block without a source line naming a sha")
    return f


def final(folder: pathlib.Path, post: dict) -> list[str]:
    f = []
    for m in post.get("media") or []:
        if m.get("kind") in {"code", "output"}: continue
        p = folder / m.get("file", "")
        if not p.is_file(): f.append(f"media {m.get('id')}: file missing {p}")
        if not str(m.get("seen", "")).strip(): f.append(f"media {m.get('id')}: no 'seen' line (open the file, write what it shows)")
    passes = sorted((folder / "critic").glob("final-*.md"), key=lambda p: int(re.sub(r"\D", "", p.stem) or 0))
    if not passes: return f + ["no critic/final-N.md"]
    text = passes[-1].read_text()
    scores = [int(n) for n in re.findall(r"^\|[^|]+\|\s*(\d{1,2})\s*\|", text, re.M)]
    if not scores: f.append(f"{passes[-1].name}: no score table")
    low = [s for s in scores if s < 8]
    if low: f.append(f"{passes[-1].name}: {len(low)} axis scores under 8")
    if not re.search(r"^Verdict:\s*ship\s*$", text.strip().splitlines()[-1] if text.strip() else "", re.I):
        f.append(f"{passes[-1].name}: last line is not 'Verdict: ship'")
    return f


def people(folder: pathlib.Path, deny: list[str]) -> list[str]:
    f = []
    for name in ("post.json", "post.md"):
        p = folder / name
        if not p.exists(): continue
        text = p.read_text()
        for rx in SECRETS:
            for hit in rx.findall(text):
                if not hit.endswith("@anthropic.com"): f.append(f"{name}: secret or personal data shape {hit[:12]}...")
        for d in deny:
            if d and re.search(re.escape(d), text, re.I): f.append(f"{name}: denied name {d!r}")
    return f


def check(folder: pathlib.Path, stage: str, deny: list[str]) -> list[str]:
    pj = folder / "post.json"
    if not pj.exists(): return ["post.json missing"]
    try: post = json.loads(pj.read_text())
    except json.JSONDecodeError as e: return [f"post.json: {e}"]
    out = outline(folder, post) + people(folder, deny)
    if stage in {"draft", "final"}: out += draft(folder, post)
    if stage == "final": out += final(folder, post)
    return out


def self_test() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        d = pathlib.Path(tmp) / "css-page-transition"
        (d / "critic").mkdir(parents=True)
        post = {"title": "CSS page transition", "slug": "css-page-transition", "row": "P0",
                "meta_description": "How a portal effect replaces a theme dropdown, with the code and a clip of each of the four variants.",
                "keyword": "css page transition", "intent": "Do", "kind": "tutorial", "promise": "A css page transition in four variants.",
                "beats": [{"id": "b1", "heading": "H", "claim": "C", "evidence": [{"type": "sha", "ref": "4b5d3ba"}], "media": ["m1"]}],
                "media": [{"id": "m1", "beat": "b1", "kind": "diagram", "shows": "S", "route": "svg", "file": "media/a.png",
                           "alt": "A", "caption": "C", "format": "png"}]}
        (d / "post.json").write_text(json.dumps(post))
        assert check(d, "outline", []) == [], check(d, "outline", [])
        assert any("post.md missing" in e for e in check(d, "draft", []))
        (d / "post.md").write_text("# CSS page transition\n\n![A](media/a.png)\n\nFrom `x` at 4b5d3ba:\n\n```ts\nconst a = 1\n```\n")
        assert check(d, "draft", []) == [], check(d, "draft", [])
        assert any("denied" in e for e in check(d, "draft", ["transition"]))
        assert any("file missing" in e for e in check(d, "final", []))
        (d / "media").mkdir(); (d / "media/a.png").write_bytes(b"x"); post["media"][0]["seen"] = "the diagram"
        (d / "post.json").write_text(json.dumps(post))
        (d / "critic/final-1.md").write_text("| Promise | 9 | ok |\n| Voice | 8 | ok |\n\nVerdict: ship\n")
        assert check(d, "final", []) == [], check(d, "final", [])
        (d / "critic/final-2.md").write_text("| Promise | 7 | weak |\n\nVerdict: fix\n")
        assert len(check(d, "final", [])) == 2
    print("self-test ok")


def main() -> None:
    a = sys.argv[1:]
    if a == ["--self-test"]: return self_test()
    if len(a) < 3 or a[1] != "--stage" or a[2] not in {"outline", "draft", "final"}:
        sys.exit(__doc__)
    deny = a[a.index("--deny") + 1].split(",") if "--deny" in a else []
    errs = check(pathlib.Path(a[0]).resolve(), a[2], [d.strip() for d in deny])
    fails = [e for e in errs if not e.startswith("WARN")]
    for e in errs: print(e if e.startswith("WARN") else f"FAIL {e}")
    print("ok" if not fails else f"{len(fails)} failures")
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
