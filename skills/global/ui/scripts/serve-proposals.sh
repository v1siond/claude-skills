#!/usr/bin/env bash
# Serve a folder of HTML design proposals on a random high port, on this machine only by default.
#
#   serve-proposals.sh <dir>
#
# Writes <dir>/index.html (a link per *.html page) only when the folder has none, starts
# python3 -m http.server bound to $SERVE_BIND (default 127.0.0.1; 0.0.0.0 only when he asks for the LAN URL)
# on a free port between 8700 and 9700 in the background for at most 2 hours, and prints the localhost URL,
# the LAN URL when bound beyond localhost, and the PID to stop it with `kill <pid>`. On WSL2, Windows reaches
# a 127.0.0.1 listener through localhost forwarding.
set -euo pipefail

dir="$(cd "${1:?usage: serve-proposals.sh <dir>}" && pwd)"
ls "$dir"/*.html >/dev/null 2>&1 || { echo "no .html files in $dir" >&2; exit 2; }

if [ ! -f "$dir/index.html" ]; then
  {
    echo '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
    echo "<title>Proposals</title><style>body{font:16px/1.5 system-ui;margin:2rem;background:#fff;color:#111}a{display:block;margin:.4rem 0}</style>"
    echo "<h1>Proposals</h1>"
    for f in "$dir"/*.html; do
      name="$(basename "$f")"
      [ "$name" = index.html ] && continue
      echo "<a href=\"$name\">${name%.html}</a>"
    done
  } > "$dir/index.html"
fi

port=""
for _ in $(seq 1 20); do
  candidate=$(( 8700 + RANDOM % 1000 ))
  if ! (exec 3<>/dev/tcp/127.0.0.1/$candidate) 2>/dev/null; then port=$candidate; break; fi
done
[ -n "$port" ] || { echo "no free port found between 8700 and 9700" >&2; exit 3; }

bind="${SERVE_BIND:-127.0.0.1}"
nohup timeout 2h python3 -I -m http.server "$port" --bind "$bind" --directory "$dir" >"$dir/.server.log" 2>&1 &
pid=$!
for _ in $(seq 1 25); do
  (exec 3<>/dev/tcp/127.0.0.1/$port) 2>/dev/null && break
  sleep 0.2
done
kill -0 "$pid" 2>/dev/null || { echo "server failed to start, see $dir/.server.log" >&2; exit 4; }

echo "local: http://localhost:$port/"
if [ "$bind" != 127.0.0.1 ]; then
  lan="$(hostname -I 2>/dev/null | awk '{print $1}')"
  [ -n "$lan" ] && echo "lan:   http://$lan:$port/"
fi
echo "pid:   $pid  (stop with: kill $pid)"
