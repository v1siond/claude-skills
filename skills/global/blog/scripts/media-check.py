#!/usr/bin/env python3
"""Check every media item of a post folder against post.json and the web rules. Writes nothing; exit 1 on FAIL.

  media-check.py <post-folder> [--plan]
  media-check.py --self-test

Per item (post.json "media"):
  image kinds (screenshot, diagram, image): the file exists under the folder, its extension is a web format
    and matches "format", width and height are read (PIL, or the SVG viewBox), weight under the budget
    (WebP, PNG and JPG 400 KB; SVG 200 KB; cover 1200x630 or larger in 1.91:1 when "cover": true).
  clip, film: mp4 with H.264 (ffprobe), a .webm beside a clip, a poster file ("poster" or <base>-poster.webp),
    a clip at most 15 s and 4 MB.
  code: the lines at its source (repo@sha:path#La-Lb) appear verbatim in post.md.
  every item: alt (not for code or output) of 1 to 150 characters and not the file name, a caption, a
    licence line, and a non empty "seen" line.
--plan checks only the fields, before any file is made. Budgets are house numbers (web-media.md).
"""
from __future__ import annotations

import json, pathlib, re, subprocess, sys, tempfile

HERE = pathlib.Path(__file__).resolve().parent
IMAGE = {"screenshot", "diagram", "image"}
VIDEO = {"clip", "film"}
WEB_EXT = {"webp": {"webp"}, "png": {"png"}, "jpg": {"jpg", "jpeg"}, "jpeg": {"jpg", "jpeg"}, "svg": {"svg"},
           "avif": {"avif"}, "mp4": {"mp4"}, "gif": {"gif"}}
BUDGET = {"svg": 200_000, "default": 400_000}
CODE_SRC = re.compile(r"^(?P<repo>/[^@]+)@(?P<sha>[0-9a-f]{7,40}):(?P<path>[^#]+)#L(?P<a>\d+)-L(?P<b>\d+)$")


def size_of(p: pathlib.Path) -> tuple[int, int] | None:
    if p.suffix == ".svg":
        m = re.search(r'viewBox="\s*[-\d.]+\s+[-\d.]+\s+([\d.]+)\s+([\d.]+)', p.read_text(errors="ignore"))
        return (int(float(m[1])), int(float(m[2]))) if m else None
    try:
        from PIL import Image
        with Image.open(p) as im: return im.size
    except Exception:
        return None


def probe(p: pathlib.Path) -> dict:
    out = subprocess.run(["/usr/bin/ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries",
                          "stream=codec_name,width,height:format=duration", "-of", "json", str(p)],
                         capture_output=True, text=True)
    try:
        j = json.loads(out.stdout)
        s = (j.get("streams") or [{}])[0]
        return {"codec": s.get("codec_name"), "w": s.get("width"), "h": s.get("height"),
                "dur": float(j.get("format", {}).get("duration", 0))}
    except Exception:
        return {}


def check_fields(m: dict) -> list[str]:
    f, kind = [], m.get("kind")
    if kind not in {"code", "output"}:
        alt = str(m.get("alt", ""))
        if not 1 <= len(alt) <= 150: f.append(f"alt is {len(alt)} characters (1 to 150)")
        stem = pathlib.Path(m.get("file", "")).stem.lower()
        if alt and alt.lower().strip().replace(" ", "-") in {stem, pathlib.Path(m.get("file", "")).name.lower()}: f.append("alt is the file name")
        if not m.get("licence"): f.append("licence missing (his own work says so)")
    if not m.get("caption"): f.append("caption missing")
    return f


def check_file(folder: pathlib.Path, m: dict, md: str) -> list[str]:
    f, kind = [], m.get("kind")
    if kind == "code":
        src = CODE_SRC.match(m.get("source", ""))
        if not src: return [f"source not repo@sha:path#La-Lb: {m.get('source')!r}"]
        out = subprocess.run(["git", "-C", src["repo"], "show", f"{src['sha']}:{src['path']}"], capture_output=True, text=True)
        if out.returncode: return [f"git show failed: {out.stderr.strip()}"]
        want = "\n".join(out.stdout.split("\n")[int(src["a"]) - 1:int(src["b"])])
        if not md: return ["post.md not written yet"]
        if want not in md: f.append("the block in post.md differs from the lines at its sha (paste code-extract.py output)")
        return f
    if kind == "output": return f
    p = folder / m.get("file", "")
    if not p.is_file(): return [f"file missing: {m.get('file')}"]
    ext = p.suffix.lstrip(".").lower()
    if ext not in WEB_EXT.get(str(m.get("format", "")).lower(), set()): f.append(f"extension .{ext} does not match format {m.get('format')!r}")
    if kind in IMAGE:
        if ext == "gif": f.append("gif on the web: make it a clip (web.sh clip)")
        wh = size_of(p)
        if not wh: f.append("width and height unreadable")
        weight = p.stat().st_size
        if weight > BUDGET.get(ext, BUDGET["default"]): f.append(f"{weight} bytes over the {BUDGET.get(ext, BUDGET['default'])} budget")
        if m.get("cover") and wh and (wh[0] < 1200 or wh[1] < 630 or abs(wh[0] / wh[1] - 1.905) > 0.05):
            f.append(f"cover is {wh[0]}x{wh[1]}, wants 1200x630 or larger at 1.91:1")
    if kind in VIDEO:
        info = probe(p)
        if info.get("codec") != "h264": f.append(f"codec {info.get('codec')!r}, wants h264 mp4")
        poster = folder / m["poster"] if m.get("poster") else p.with_name(p.stem + "-poster.webp")
        if not poster.is_file(): f.append(f"poster missing: {poster.name}")
        if kind == "clip":
            if not p.with_suffix(".webm").is_file(): f.append("webm beside the clip missing")
            if info.get("dur", 0) > 15.5: f.append(f"clip is {info.get('dur'):.1f} s (at most 15)")
            if p.stat().st_size > 4_000_000: f.append(f"clip is {p.stat().st_size} bytes (at most 4 MB)")
    if not str(m.get("seen", "")).strip(): f.append("no 'seen' line: open the file and write what it shows")
    return f


def check(folder: pathlib.Path, plan: bool = False) -> list[str]:
    pj = folder / "post.json"
    if not pj.exists(): return ["post.json missing"]
    post = json.loads(pj.read_text())
    md = (folder / "post.md").read_text() if (folder / "post.md").exists() else ""
    out = []
    for m in post.get("media") or []:
        errs = check_fields(m) + ([] if plan else check_file(folder, m, md))
        out += [f"{m.get('id', '?')}: {e}" for e in errs]
    return out


def self_test() -> None:
    from PIL import Image
    with tempfile.TemporaryDirectory() as tmp:
        d = pathlib.Path(tmp); (d / "media").mkdir()
        Image.new("RGB", (1200, 630), "white").save(d / "media/cover.png")
        (d / "media/flow.svg").write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 400"></svg>')
        media = [{"id": "m1", "kind": "image", "file": "media/cover.png", "format": "png", "cover": True, "alt": "The four portal effects side by side",
                  "caption": "c", "licence": "his own", "seen": "four panels"},
                 {"id": "m2", "kind": "diagram", "file": "media/flow.svg", "format": "svg", "alt": "Flow of a world change",
                  "caption": "c", "licence": "his own", "seen": "boxes"}]
        (d / "post.json").write_text(json.dumps({"media": media}))
        assert check(d) == [], check(d)
        media[0]["format"] = "webp"; media[1]["seen"] = ""
        (d / "post.json").write_text(json.dumps({"media": media}))
        assert len(check(d)) == 2, check(d)
        assert check(d, plan=True) == [], check(d, plan=True)
    print("self-test ok")


def main() -> None:
    a = sys.argv[1:]
    if a == ["--self-test"]: return self_test()
    if not a: sys.exit(__doc__)
    errs = check(pathlib.Path(a[0]).resolve(), "--plan" in a)
    for e in errs: print(f"FAIL {e}")
    print("ok" if not errs else f"{len(errs)} failures")
    sys.exit(1 if errs else 0)


if __name__ == "__main__":
    main()
