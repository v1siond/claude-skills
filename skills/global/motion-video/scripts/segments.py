#!/usr/bin/env python3
"""Cut a live take into film segments by its marks, lay each on its brand plate, and join them.

  segments.py times <spec.json> <marks.json> <segments.json>   resolve marks into from, to, dur, cuts, total
  segments.py build <segments.json> <take.webm> <plates-dir> <seg-dir> [--draft] [id ...]
  segments.py join  <seg-dir> <out.mp4> [--audio music.wav]
  segments.py --self-test

spec.json: {"fps": 30, "size": [1920, 1080], "bpm": 120, "seed": 1, "window": [x, y, w, h],
  "fade": "0xf7f4ef", "fade_in": 0, "fade_out": 0, "segments": [...]}. A segment is a title card
  {"id", "card": {...}, "dur"} or a piece of the take {"id", "a": [mark, offset], "b": [mark, offset],
  "speed", "hold"?, "crop"? [x, y, w, h], "push"? {z0, z1, rate, cx, cy, cx1?, cy1?, delay?}, "caption", "step"}.
  "hold" holds the frame at "a" for that many seconds (the cursor rests on the subject there). marks.json is
  the list of {"name", "t"} the capture wrote; a name marked twice keeps the later one.

`times` is the one owner of segment durations: build trims each take segment to from + dur * speed, so
beat-snap.py moves a cut by changing dur alone. build writes only <seg-dir>/<id>.mp4 and concat.txt (it
rebuilds those files on purpose); join refuses an existing output. Plates are <plates-dir>/<id>.png at the
film size, made by the project's plates page (references/live-take.md). Needs ffmpeg; no network.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile

ENCODE = ["-c:v", "libx264", "-crf", "14", "-preset", "medium", "-pix_fmt", "yuv420p",
          "-color_primaries", "bt709", "-color_trc", "bt709", "-colorspace", "bt709", "-color_range", "tv"]
DRAFT = ["-c:v", "libx264", "-crf", "30", "-preset", "veryfast", "-pix_fmt", "yuv420p"]
CARD_PUSH = 0.025  # a title card zooms 2.5% over its length, so nothing on screen is frozen


def die(msg: str) -> None:
    sys.exit(f"segments.py: {msg}")


def load(path: str) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save(path: str, data: dict) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)


# ---- times ---------------------------------------------------------------------------------------------

def resolve(seg: dict, marks: dict) -> dict:
    s = dict(seg)
    if "card" in s:
        return s
    (ma, da), (mb, db) = s.pop("a"), s.pop("b")
    missing = [m for m in (ma, mb) if m not in marks]
    if missing:
        die(f"{s['id']}: no mark named {', '.join(missing)}")
    s["from"], s["to"] = round(marks[ma] + da, 3), round(marks[mb] + db, 3)
    if s["to"] <= s["from"]:
        die(f"{s['id']}: ends at {s['to']} before it starts at {s['from']}")
    s["dur"] = round(s["hold"] if "hold" in s else (s["to"] - s["from"]) / s.get("speed", 1.0), 3)
    return s


def cut_list(segs: list[dict]) -> tuple[list[float], float]:
    cuts, total = [], 0.0
    for s in segs:
        total = round(total + s["dur"], 3)
        cuts.append(total)
    return cuts[:-1], total


def cmd_times(spec_path: str, marks_path: str, out: str) -> None:
    spec = load(spec_path)
    marks = {m["name"]: m["t"] for m in load(marks_path)}
    segs = [resolve(s, marks) for s in spec["segments"]]
    cuts, total = cut_list(segs)
    save(out, {**spec, "segments": segs, "cuts": cuts, "total": total})
    for s in segs:
        print(f"{s['id']:16} {s.get('from', ''):>9} {s.get('to', ''):>9} {s['dur']:7.2f}")
    print(f"total {total} s, {len(cuts)} cuts -> {out}")


# ---- build ---------------------------------------------------------------------------------------------

def fades(film: dict, dur: float) -> str:
    color, fi, fo = film.get("fade", "black"), film.get("fade_in", 0), film.get("fade_out", 0)
    parts = [f"fade=in:0:{fi}:color={color}"] if fi else []
    parts += [f"fade=out:st={dur - fo / film['fps']:.3f}:d={fo / film['fps']:.3f}:color={color}"] if fo else []
    return "".join("," + p for p in parts)


def push_filter(q: dict, dur: float, fps: int, w: int, h: int) -> str:
    """Zoom from z0 toward z1 after `delay` frames while the centre glides from (cx, cy) to (cx1, cy1)."""
    n, dl = max(int(dur * fps), 1), q.get("delay", 0)
    k = f"min(max(0,on-{dl})/{max(n - dl, 1)},1)"
    cx = f"({q['cx']}+({q.get('cx1', q['cx'])}-{q['cx']})*{k})"
    cy = f"({q['cy']}+({q.get('cy1', q['cy'])}-{q['cy']})*{k})"
    z = f"min({q['z0']}+max(0,on-{dl})*{q['rate']},{q['z1']})"
    return (f"zoompan=z='{z}':x='max(0,min(iw-iw/zoom,{cx}-iw/zoom/2))':"
            f"y='max(0,min(ih-ih/zoom,{cy}-ih/zoom/2))':d=1:s={w}x{h}:fps={fps}")


def card_cmd(film: dict, s: dict, plate: str, out: str, enc: list[str]) -> list[str]:
    fps, (W, H), d = film["fps"], film["size"], s["dur"]
    n = max(int(d * fps), 1)
    vf = (f"scale={W * 2}:{H * 2},zoompan=z='1+{CARD_PUSH}*on/{n}':x='iw/2-iw/zoom/2':y='ih/2-ih/zoom/2'"
          f":d=1:s={W}x{H}:fps={fps}{fades(film, d)},scale=out_color_matrix=bt709:out_range=tv,format=yuv420p")
    return ["-loop", "1", "-framerate", str(fps), "-t", f"{d:.3f}", "-i", plate, "-vf", vf, *enc, out]


def take_cmd(film: dict, s: dict, plate: str, take: str, out: str, enc: list[str]) -> list[str]:
    fps, d, speed = film["fps"], s["dur"], s.get("speed", 1.0)
    x, y, w, h = film["window"]
    end = s["to"] if "hold" in s else s["from"] + d * speed
    hold = f",tpad=stop_mode=clone:stop_duration={d:.3f}" if "hold" in s else ""
    crop = "crop={2}:{3}:{0}:{1},".format(*s["crop"]) if "crop" in s else ""
    fit = push_filter(s["push"], d, fps, w, h) if "push" in s else f"scale={w}:{h}:flags=lanczos"
    fc = (f"[1:v]trim=start={s['from']:.3f}:end={end:.3f},setpts=(PTS-STARTPTS)/{speed},fps={fps}{hold},{crop}{fit}[v];"
          f"[0:v][v]overlay={x}:{y}:shortest=1{fades(film, d)},scale=out_color_matrix=bt709:out_range=tv,format=yuv420p[o]")
    return ["-loop", "1", "-framerate", str(fps), "-i", plate, "-i", take, "-filter_complex", fc,
            "-map", "[o]", "-t", f"{d:.3f}", *enc, out]


def cmd_build(seg_path: str, take: str, plates: str, seg_dir: str, draft: bool, only: list[str]) -> None:
    film = load(seg_path)
    os.makedirs(seg_dir, exist_ok=True)
    enc = DRAFT if draft else ENCODE
    for s in film["segments"]:
        if only and s["id"] not in only:
            continue
        plate, out = os.path.join(plates, s["id"] + ".png"), os.path.join(seg_dir, s["id"] + ".mp4")
        if not os.path.exists(plate):
            die(f"no plate {plate}")
        args = card_cmd(film, s, plate, out, enc) if "card" in s else take_cmd(film, s, plate, take, out, enc)
        subprocess.run(["ffmpeg", "-v", "error", "-y", *args, "-r", str(film["fps"])], check=True)
        print(f"seg {s['id']} {s['dur']:.2f} s")
    with open(os.path.join(seg_dir, "concat.txt"), "w", encoding="utf-8") as f:
        f.writelines(f"file '{s['id']}.mp4'\n" for s in film["segments"])
    print(f"concat {os.path.join(seg_dir, 'concat.txt')}: {len(film['segments'])} segments")


# ---- join ----------------------------------------------------------------------------------------------

def cmd_join(seg_dir: str, out: str, audio: str | None) -> None:
    if os.path.exists(out):
        die(f"{out} exists, delete it first")
    concat = os.path.join(seg_dir, "concat.txt")
    # -shortest on ffmpeg 4.2 with a copied video stream ends the audio up to 2 s early; cut both
    # streams at the video's own length instead and pad the music if it runs short.
    au = ["-i", audio, "-map", "0:v", "-map", "1:a", "-c:a", "aac", "-b:a", "256k", "-af", "apad",
          "-t", video_duration(concat)] if audio else []
    subprocess.run(["ffmpeg", "-v", "error", "-f", "concat", "-safe", "0", "-i", concat, *au,
                    "-c:v", "copy", "-movflags", "+faststart", out], check=True)
    print(f"join {out}")


def video_duration(concat: str) -> str:
    """The joined length, summed from each segment (ffprobe reads no duration from a concat list)."""
    seg_dir = os.path.dirname(concat)
    with open(concat, encoding="utf-8") as f:
        names = [line.strip()[len("file '"):-1] for line in f if line.startswith("file '")]
    total = sum(float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of",
                                      "default=nw=1:nk=1", os.path.join(seg_dir, n)],
                                     check=True, capture_output=True, text=True).stdout.strip())
                for n in names)
    return f"{total:.3f}"


# ---- self test -----------------------------------------------------------------------------------------

def ffmpeg(*args: str) -> None:
    subprocess.run(["ffmpeg", "-v", "error", "-y", *args], check=True)


def probe_frames(path: str) -> int:
    r = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-count_frames", "-show_entries",
                        "stream=nb_read_frames", "-of", "csv=p=0", path], capture_output=True, text=True, check=True)
    return int(r.stdout.strip())


def self_test() -> None:
    d = tempfile.mkdtemp(prefix="segments-test-")
    take, plates = os.path.join(d, "take.webm"), os.path.join(d, "plates")
    os.makedirs(plates)
    ffmpeg("-f", "lavfi", "-i", "testsrc=size=640x360:rate=30:duration=6", "-c:v", "libvpx", "-b:v", "1M", take)
    for sid in ("title", "a", "b"):
        ffmpeg("-f", "lavfi", "-i", "color=c=0xf7f4ef:s=640x360", "-frames:v", "1", os.path.join(plates, sid + ".png"))
    save(os.path.join(d, "marks.json"), [{"name": "go", "t": 0.5}, {"name": "stop", "t": 2.5}, {"name": "go", "t": 3.0}])
    save(os.path.join(d, "spec.json"), {"fps": 30, "size": [640, 360], "bpm": 120, "window": [40, 20, 560, 315],
        "segments": [{"id": "title", "card": {"title": "t"}, "dur": 1.0},
                     {"id": "a", "a": ["go", -2.5], "b": ["stop", 0], "speed": 2.0, "caption": "c"},
                     {"id": "b", "a": ["go", 0], "b": ["go", 0.04], "hold": 1.5,
                      "push": {"z0": 1.0, "z1": 1.1, "rate": 0.002, "cx": 320, "cy": 180}}]})
    seg_json, seg_dir, film = os.path.join(d, "segments.json"), os.path.join(d, "seg"), os.path.join(d, "film.mp4")
    cmd_times(os.path.join(d, "spec.json"), os.path.join(d, "marks.json"), seg_json)
    resolved = load(seg_json)
    cmd_build(seg_json, take, plates, seg_dir, False, [])
    cmd_join(seg_dir, film, None)
    frames = probe_frames(film)
    music, scored = os.path.join(d, "music.wav"), os.path.join(d, "scored.mp4")
    ffmpeg("-f", "lavfi", "-i", "sine=frequency=220:duration=3.5", music)
    cmd_join(seg_dir, scored, music)
    audio = float(subprocess.run(["ffprobe", "-v", "error", "-select_streams", "a:0", "-show_entries",
                                  "stream=duration", "-of", "default=nw=1:nk=1", scored],
                                 check=True, capture_output=True, text=True).stdout.strip())
    ok = (resolved["cuts"] == [1.0, 2.0] and resolved["total"] == 3.5 and frames == 105
          and abs(audio - 3.5) < 0.05)
    print(f"self test {'ok' if ok else 'FAILED'}: cuts {resolved['cuts']}, total {resolved['total']}, "
          f"{frames} frames (want 105), audio {audio:.3f} s (want 3.5); {d}")
    sys.exit(0 if ok else 1)


def main() -> None:
    if "--self-test" in sys.argv:
        self_test()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    t = sub.add_parser("times")
    t.add_argument("spec"); t.add_argument("marks"); t.add_argument("out")
    b = sub.add_parser("build")
    b.add_argument("segments"); b.add_argument("take"); b.add_argument("plates"); b.add_argument("seg_dir")
    b.add_argument("--draft", action="store_true", help="fast low quality encode for the rhythm check")
    b.add_argument("only", nargs="*", help="rebuild only these segment ids")
    j = sub.add_parser("join")
    j.add_argument("seg_dir"); j.add_argument("out"); j.add_argument("--audio")
    ap.add_argument("--self-test", action="store_true", help="build a 3.5 s film from a test pattern and check it")
    a = ap.parse_args()
    handlers = {
        "times": lambda: cmd_times(a.spec, a.marks, a.out),
        "build": lambda: cmd_build(a.segments, a.take, a.plates, a.seg_dir, a.draft, a.only),
        "join": lambda: cmd_join(a.seg_dir, a.out, a.audio),
    }
    handlers[a.cmd]()


main()
