#!/usr/bin/env bash
# Web encodes for post media. Writes only the outputs named; refuses to overwrite an existing output.
#
#   web.sh webp  <in.png> <out.webp> [quality=82]           still to WebP (cwebp), prints size and bytes
#   web.sh clip  <take.webm|mp4> <out-base> [start=0] [len]  <base>.mp4 (H.264 yuv420p faststart, no audio),
#                                                             <base>.webm (VP9), <base>-poster.webp
#   web.sh frames <clip> <out-prefix> [n=3]                  n PNG frames spread over the clip, to open
#   web.sh strip <take> <out.png> <from> [len=5] [fps=2]     one tiled image of the take from <from>, to find
#                                                             the clip start by eye (wall clock marks drift)
#   web.sh sheet <media-dir> <out.png>                       contact sheet of every image and poster
set -euo pipefail
FF=/usr/bin/ffmpeg; FP=/usr/bin/ffprobe
refuse() { for f in "$@"; do [ ! -e "$f" ] || { echo "refusing to overwrite $f" >&2; exit 1; }; done; }
dur() { "$FP" -v error -show_entries format=duration -of csv=p=0 "$1"; }
cmd=${1:-}; shift || true
case "$cmd" in
  webp)
    in=$1; out=$2; q=${3:-82}; refuse "$out"
    cwebp -quiet -q "$q" -metadata none "$in" -o "$out"
    python3 -I -c 'import sys,os;from PIL import Image;i=Image.open(sys.argv[1]);print(sys.argv[1],"%dx%d"%i.size,os.path.getsize(sys.argv[1]),"bytes")' "$out" 2>/dev/null \
      || echo "$out $(stat -c %s "$out") bytes" ;;
  clip)
    in=$1; base=$2; ss=${3:-0}; len=${4:-}
    refuse "$base.mp4" "$base.webm" "$base-poster.webp"
    t=(); [ -n "$len" ] && t=(-t "$len")
    "$FF" -v error -ss "$ss" "${t[@]}" -i "$in" -an -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2,fps=30" \
      -c:v libx264 -pix_fmt yuv420p -crf 23 -preset slow -movflags +faststart "$base.mp4"
    "$FF" -v error -ss "$ss" "${t[@]}" -i "$in" -an -vf "fps=30" -c:v libvpx-vp9 -b:v 0 -crf 34 -row-mt 1 "$base.webm"
    mid=$(python3 -I -c "print(round(float('$(dur "$base.mp4")')/2,2))")
    "$FF" -v error -ss "$mid" -i "$base.mp4" -frames:v 1 -c:v libwebp -quality 82 "$base-poster.webp"
    for f in "$base.mp4" "$base.webm" "$base-poster.webp"; do echo "$f $(stat -c %s "$f") bytes"; done
    "$FP" -v error -select_streams v:0 -show_entries stream=codec_name,width,height -show_entries format=duration -of compact=p=0 "$base.mp4" ;;
  frames)
    in=$1; pre=$2; n=${3:-3}; d=$(dur "$in")
    for i in $(seq 1 "$n"); do
      t=$(python3 -I -c "print(round($d*$i/($n+1),2))"); out="$pre-$i.png"; refuse "$out"
      "$FF" -v error -ss "$t" -i "$in" -frames:v 1 "$out"; echo "$out at ${t}s"
    done ;;
  strip)
    in=$1; out=$2; from=$3; len=${4:-5}; fps=${5:-2}; refuse "$out"
    n=$(python3 -I -c "import math;print(max(1,math.ceil($len*$fps)))")
    "$FF" -v error -ss "$from" -i "$in" -t "$len" -vf "fps=$fps,scale=320:-1,tile=5x$(( (n+4)/5 ))" -frames:v 1 "$out"
    echo "$out from ${from}s, one tile every $(python3 -I -c "print(1/$fps)")s, left to right" ;;
  sheet)
    dir=$1; out=$2; refuse "$out"
    mapfile -t files < <(find "$dir" -maxdepth 1 -type f \( -name '*.webp' -o -name '*.png' -o -name '*.jpg' \) | sort)
    [ ${#files[@]} -gt 0 ] || { echo "no images in $dir" >&2; exit 1; }
    montage "${files[@]}" -geometry 480x300+8+8 -tile 3x -label '%f' -background white "$out"
    echo "$out ${#files[@]} images" ;;
  *) sed -n 2,11p "$0"; exit 2 ;;
esac
