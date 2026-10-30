#!/usr/bin/env bash
# Checks 4 and 5 of engineering-standards on a plan or a player's report. Read only.
#
#   check-report.sh <plan or report>
#
# Strips list marks (bullets and numbers), bold and backticks, then reads each labelled line plus the list items
# or indented lines right under it; a blank line, a prose line, the next label or a heading ends it.
#   reused: lines under `Reused:` that hold a file:line, or `none, searched <grep|rg|git grep command>`.
#   facts:  lines under `Facts:` that hold `copy -> owner` (or the arrow sign), the owner a path, module,
#           column or key (a dot, slash or colon in it).
# Exit 0 when reused is 1 or more; facts is read only when the change moved or copied a fact (check 5).
set -uo pipefail
[ -f "${1:-}" ] || { echo "usage: check-report.sh <plan or report>"; exit 2; }
LABELS='Start|Standards read|Reused|Facts|check-diff|Self-read|Gates|Test mode|Stack|Scenarios|Red|Green|Mutation|Not verified'
# block <file> <label>: the label line, then the list items or indented lines right under it.
block() {
  awk -v L="$2" -v LABELS="$LABELS" '
    { raw=$0; s=$0; sub(/^[-*>[:space:]]*([0-9]+[.)][[:space:]]*)?/, "", s); gsub(/\*\*|`/, "", s) }
    s ~ "^("L")[^:]*:" { p=1; print s; next }
    p && (s ~ "^("LABELS")[^:]*:" || s ~ /^#/ || s ~ /^[[:space:]]*$/) { p=0; next }
    p && raw ~ /^[[:space:]>]*([-*]|[0-9]+[.)])[[:space:]]|^[[:space:]]+[^[:space:]]/ { print s; next }
    p { p=0 }' "$1"
}
reused=$(block "$1" Reused | grep -cE '([A-Za-z0-9_.-]*/)*([A-Za-z0-9_-]+\.[A-Za-z0-9]+|Makefile|Dockerfile|Gemfile|Rakefile|Procfile|Justfile):[0-9]+|none, searched (grep|rg|git grep) .+')
facts=$(block "$1" Facts | grep -cE '.+ (->|→) .*[A-Za-z_]{2,}[./:][A-Za-z_]')
echo "reused: $reused"
echo "facts: $facts"
[ "$reused" -gt 0 ]
