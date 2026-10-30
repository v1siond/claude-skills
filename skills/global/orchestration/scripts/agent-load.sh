#!/usr/bin/env bash
# Before fanning out agents: how loaded is the box, what browsers and test runs are alive, which test ports
# are taken, and a free port to hand the next agent. Read-only: it lists processes, it never kills any.
#   agent-load.sh [port-range-start]     (default 4100)
set -uo pipefail

START="${1:-4100}"
CORES=$(nproc)
read -r L1 L5 _ < /proc/loadavg
MEM_FREE=$(awk '/MemAvailable/ {printf "%.1f", $2/1048576}' /proc/meminfo)

# Claude's own Bash calls carry the searched word in their command line, so they are left out of the count.
count() { pgrep -fa "$1" 2>/dev/null | grep -v -e shell-snapshots -e agent-load.sh -e 'playwright-mcp\|@playwright/mcp' | wc -l; }

echo "cores:        $CORES"
echo "load:         $L1 (1m)  $L5 (5m)"
echo "mem free:     ${MEM_FREE} GiB"
echo "browsers:     chrome/chromium $(count 'chrome|chromium|headless_shell'), chromedriver $(count chromedriver), playwright $(count 'playwright')"
echo "test runs:    mix test $(count 'mix test'), rspec $(count rspec), jest/vitest $(count 'jest|vitest')"
echo "dev servers:  phx.server $(count 'phx.server'), next $(count 'next-server|next dev'), rails s $(count 'rails s|puma')"

# Ports agents commonly collide on: 3000s (web apps), 4000s (Phoenix dev/test, 4002 is shared by several repos).
TAKEN=$(ss -ltnH 2>/dev/null | awk '{print $4}' | sed 's/.*://' | sort -n | uniq)
echo "taken ports:  $(printf '%s\n' "$TAKEN" | awk '($1>=3000 && $1<=3020) || ($1>=4000 && $1<=4200) || $1==6328' | tr '\n' ' ')"
p=$START
while printf '%s\n' "$TAKEN" | grep -qx "$p"; do p=$((p + 1)); done
echo "free port:    $p (first free from $START)"

# A rough ceiling: about 5 agents on this 4 core box was the measured limit, fewer when load is already high.
CAP=$(( CORES + 1 )); [ "$CAP" -gt 5 ] && CAP=5
BUSY=$(awk -v l="$L1" -v c="$CORES" 'BEGIN { print (l > c) ? 1 : 0 }')
[ "$BUSY" -eq 1 ] && CAP=$(( CAP / 2 ))
[ "$CAP" -lt 1 ] && CAP=1
echo "agents now:   at most $CAP more (one browser stack at a time on the whole box)"
[ "$BUSY" -eq 1 ] && echo "warning:      load $L1 is above $CORES cores. Queue the rest, do not fan out."
exit 0
