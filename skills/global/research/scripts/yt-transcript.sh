#!/usr/bin/env bash
# Download the subtitles of one video with yt-dlp (no browser cookies) and write a clean
# timestamped transcript next to them.
#
#   yt-transcript.sh <url> [out-dir] [sub-lang]
#
# out-dir defaults to ./transcripts. sub-lang defaults to the plain English tracks: the CLAUDE.md
# pattern "en.*" also matches every machine translation (en-de, en-fr...) and YouTube answers those
# with HTTP 429. Prints the transcript path on the last line. Exits non zero, with yt-dlp's own error
# output left on screen, when no subtitle file came back.
set -euo pipefail

url="${1:?usage: yt-transcript.sh <url> [out-dir] [sub-lang]}"
out="${2:-./transcripts}"
lang="${3:-en,en-orig,en-US,en-GB}"
here="$(cd "$(dirname "$0")" && pwd)"

command -v yt-dlp >/dev/null || { echo "yt-dlp not on PATH (expected ~/.local/bin/yt-dlp)" >&2; exit 2; }
mkdir -p "$out"

id="$(yt-dlp --skip-download --print id "$url")"
title="$(yt-dlp --skip-download --print title "$url")"

# A failure on one track must not hide the tracks that did download; the check below decides.
yt-dlp --skip-download --write-sub --write-auto-sub --sub-lang "$lang" --sub-format vtt \
  --output "$out/$id.%(ext)s" "$url" || echo "yt-dlp exited non zero, checking what was saved" >&2

vtt="$(ls -1S "$out/$id".*.vtt 2>/dev/null | head -1 || true)"
if [ -z "$vtt" ]; then
  echo "no subtitles in '$lang' for $id. List what exists with: yt-dlp --list-subs '$url'" >&2
  exit 3
fi

txt="$out/$id.txt"
{
  echo "# title: $title"
  python3 -I "$here/vtt-to-text.py" "$vtt" "https://youtu.be/$id"
} > "$txt"

echo "lines: $(grep -c '^\[' "$txt")  language file: $(basename "$vtt")"
echo "$txt"
