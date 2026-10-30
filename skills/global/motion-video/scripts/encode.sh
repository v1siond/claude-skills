#!/usr/bin/env bash
# ffmpeg steps for a seek(t) film. Reads frames or a film, writes only the output named; refuses to
# overwrite an existing output (delete it first, on purpose).
#
#   encode.sh video <frames-dir> <out.mp4> [fps=30] [subframes=1] [audio-file]
#   encode.sh sheet <frames-dir|film.mp4> <out.png> [cols=6] [tile-width=320]
#   encode.sh scan  <film.mp4> [threshold=0.25]     frames that jump from the previous one, with times
#   encode.sh loud  <in-audio> <out.wav>            two-pass loudnorm to -14 LUFS, true peak -1.5 dB
#   encode.sh probe <film.mp4>                      size, fps, frame count, duration, pixel format
#   encode.sh frozen <stills-dir> [level=0.5]       neighbouring stills that barely differ (mean gray
#                                                    difference under level, of 255)
#   encode.sh frozen <film.mp4> [seconds=2]         every stretch of the film or draft frozen that long
#
# Frames are render.mjs output: f_<index>.png (subframes interleaved) or still_<t>.png.
set -euo pipefail

die() { echo "encode.sh: $*" >&2; exit 1; }
command -v ffmpeg >/dev/null || die "ffmpeg not on PATH"
fresh() { [ ! -e "$1" ] || die "$1 exists, delete it first"; }

frames_glob() {
  local dir=$1
  ls "$dir"/f_*.png >/dev/null 2>&1 && { echo "$dir/f_*.png"; return; }
  ls "$dir"/still_*.png >/dev/null 2>&1 && { echo "$dir/still_*.png"; return; }
  die "no f_*.png or still_*.png in $dir"
}

cmd_video() {
  local dir=$1 out=$2 fps=${3:-30} sub=${4:-1} audio=${5:-}
  fresh "$out"
  local files; files=$(ls "$dir"/f_*.png 2>/dev/null | wc -l)
  [ "$files" -gt 0 ] || die "no f_*.png in $dir"
  [ $((files % sub)) -eq 0 ] || die "$files files is not a whole number of frames at $sub subframes"
  local blend=""
  # tmix averages each frame's subframes (motion blur); select keeps one output per frame. tmix drops its
  # last output at end of stream, so tpad clones the tail and -frames:v cuts back to the exact count.
  [ "$sub" -gt 1 ] && blend="tpad=stop=$sub:stop_mode=clone,tmix=frames=$sub,select='eq(mod(n\\,$sub)\\,$((sub - 1)))',setpts=N/($fps*TB),"
  local vf="${blend}scale=trunc(iw/2)*2:trunc(ih/2)*2:out_color_matrix=bt709:out_range=tv,format=yuv420p"
  local in=(-framerate $((fps * sub)) -pattern_type glob -i "$dir/f_*.png")
  local want=$((files / sub))
  # Audio is padded with silence and cut at the film's length; -frames:v would cut the audio short on ffmpeg 4.
  local au=(-frames:v "$want")
  [ -n "$audio" ] && au=(-i "$audio" -map 0:v -map 1:a -c:a aac -b:a 256k -filter:a apad -t "$(awk "BEGIN{print $want/$fps}")")
  ffmpeg -hide_banner -loglevel error "${in[@]}" "${au[@]}" -filter:v "$vf" -r "$fps" \
    -c:v libx264 -preset slow -crf 16 -color_primaries bt709 -color_trc bt709 -colorspace bt709 \
    -color_range tv -movflags +faststart "$out"
  local got; got=$(ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -of csv=p=0 "$out")
  echo "video $out: $got frames, expected $want"
  [ "$got" -eq "$want" ] || die "frame count mismatch: frames were dropped or duplicated"
}

cmd_sheet() {
  local src=$1 out=$2 cols=${3:-6} w=${4:-320}
  fresh "$out"
  if [ -d "$src" ]; then
    local glob; glob=$(frames_glob "$src")
    local n; n=$(ls $glob | wc -l)
    local every=$(( (n + 29) / 30 ))   # at most 30 tiles
    local tiles=$(( (n + every - 1) / every ))
    local rows=$(( (tiles + cols - 1) / cols ))
    ffmpeg -hide_banner -loglevel error -pattern_type glob -i "$glob" \
      -vf "select='not(mod(n\\,$every))',scale=$w:-1,tile=${cols}x${rows}:padding=4:color=gray" -frames:v 1 "$out"
  else
    ffmpeg -hide_banner -loglevel error -i "$src" -vf "fps=1,scale=$w:-1,tile=${cols}x5:padding=4:color=gray" -frames:v 1 "$out"
  fi
  echo "sheet $out"
}

cmd_scan() {
  local film=$1 th=${2:-0.25}
  ffmpeg -hide_banner -i "$film" -vf "select='gt(scene\\,$th)',showinfo" -f null - 2>&1 \
    | sed -n 's/.*pts_time:\([0-9.]*\).*/jump at \1 s/p'
  echo "scan done (threshold $th): every line above is a jump; each must be an intended cut"
}

cmd_loud() {
  local in=$1 out=$2
  fresh "$out"
  local json; json=$(ffmpeg -hide_banner -i "$in" -af loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 | sed -n '/^{/,/^}/p')
  [ -n "$json" ] || die "loudnorm first pass printed no measurement"
  local m; m=$(python3 -I -c 'import json,sys; d=json.loads(sys.stdin.read()); print(":".join("%s=%s" % (k, d[v]) for k, v in [("measured_I","input_i"),("measured_TP","input_tp"),("measured_LRA","input_lra"),("measured_thresh","input_thresh"),("offset","target_offset")]))' <<<"$json")
  ffmpeg -hide_banner -loglevel error -i "$in" -af "loudnorm=I=-14:TP=-1.5:LRA=11:$m:linear=true" -ar 48000 "$out"
  echo "loud $out (measured $m)"
}

cmd_frozen() {
  local src=$1
  if [ -f "$src" ]; then
    local secs=${2:-2}
    ffmpeg -hide_banner -i "$src" -vf "freezedetect=n=-60dB:d=$secs" -f null - 2>&1 \
      | sed -n 's/.*freeze_start: *\([0-9.]*\).*/frozen from \1 s/p; s/.*freeze_duration: *\([0-9.]*\).*/  for \1 s/p'
    echo "frozen done: every stretch above is a still picture for $secs s or more; each must be a hold the brief names"
    return
  fi
  local level=${2:-0.5} glob; glob=$(frames_glob "$src")
  python3 -I - "$level" $glob <<'PY'
import subprocess, sys
level, files = float(sys.argv[1]), sys.argv[2:]
def gray(f):
    return subprocess.run(["ffmpeg", "-v", "error", "-i", f, "-vf", "scale=160:90", "-f", "rawvideo",
                           "-pix_fmt", "gray", "-"], capture_output=True, check=True).stdout
prev = None
for f in files:
    cur = gray(f)
    if prev is not None:
        diff = sum(abs(a - b) for a, b in zip(prev[1], cur)) / len(cur)
        if diff < level:
            print(f"frozen {prev[0].rsplit('/', 1)[-1]} -> {f.rsplit('/', 1)[-1]}  mean difference {diff:.3f}")
    prev = (f, cur)
print(f"frozen done ({len(files)} stills, level {level}): each pair above shows no visible change")
PY
}

cmd_probe() {
  ffprobe -v error -select_streams v:0 -count_frames \
    -show_entries stream=width,height,r_frame_rate,nb_read_frames,pix_fmt,color_space,color_range:format=duration \
    -of default=nw=1 "$1"
}

sub=${1:-}; shift || true
case "$sub" in
  video) [ $# -ge 2 ] || die "video <frames-dir> <out.mp4> [fps] [subframes] [audio]"; cmd_video "$@" ;;
  sheet) [ $# -ge 2 ] || die "sheet <frames-dir|film> <out.png> [cols] [width]"; cmd_sheet "$@" ;;
  scan)  [ $# -ge 1 ] || die "scan <film.mp4> [threshold]"; cmd_scan "$@" ;;
  loud)  [ $# -ge 2 ] || die "loud <in-audio> <out.wav>"; cmd_loud "$@" ;;
  probe) [ $# -ge 1 ] || die "probe <film.mp4>"; cmd_probe "$@" ;;
  frozen) [ $# -ge 1 ] || die "frozen <stills-dir> [level] | <film.mp4> [seconds]"; cmd_frozen "$@" ;;
  -h|--help) sed -n '2,14p' "$0" ;;
  *) sed -n '2,14p' "$0"; exit 2 ;;
esac
