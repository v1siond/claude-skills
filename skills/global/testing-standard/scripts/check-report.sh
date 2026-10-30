#!/usr/bin/env bash
# Check 1 of testing-standard on a player's report. Read only.
#
#   check-report.sh <report> [ORCHESTRA.md] [batch]
#
# Reads the first `Test mode:` line of the report outside a `>` quote, after list marks, bold and backticks are
# stripped, and takes its mode (add browser tests or default; the mode sets the frontend only). Reads the batch Decision from
# ORCHESTRA.md: the last line naming `Test mode` (with `batch <batch>` when given) and a mode; no such line means
# default. Prints `test mode: 0|1`, `report: <mode>`, `decision: <mode>`, `match: yes|no`.
# Exit 0 when the line is there and its mode equals the Decision.
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: check-report.sh <report> [ORCHESTRA.md] [batch]"; exit 2; }
mode_of() { grep -oE 'add browser tests|default' | head -1; }
line=$(grep -vE '^[[:space:]]*>' "$1" | sed -E 's/^[-*[:space:]]*([0-9]+[.)][[:space:]]*)?//; s/\*\*//g; s/`//g' | grep -m1 -E '^Test mode:')
found=0; [ -n "$line" ] && found=1
report=$(printf '%s\n' "$line" | mode_of); report=${report:-none}
decision=default
if [ -n "${2:-}" ]; then
  [ -f "$2" ] || { echo "no file: $2"; exit 2; }
  pick=$(grep -E '^[-* ]*D[0-9]+ Test mode' "$2" | { [ -n "${3:-}" ] && grep -E "batch ${3}\b" || cat; } | grep -E 'add browser tests|default' | tail -1)
  d=$(printf '%s\n' "$pick" | mode_of); decision=${d:-default}
fi
match=no; [ "$found" = 1 ] && [ "$report" = "$decision" ] && match=yes
echo "test mode: $found"; echo "report: $report"; echo "decision: $decision"; echo "match: $match"
[ "$match" = yes ]
