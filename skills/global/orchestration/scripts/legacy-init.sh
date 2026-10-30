#!/bin/bash
# Writes <workspace>/built-check-legacy.txt once: every ticket folder under score/ whose understand.md exists and has no
# `Problem: ` line today (understood before the row D1 method, orchestration 7.5.4). built-check.sh skips the row D1
# check for these names only. The last line `# written <epoch> sha256 <sum of the names>` seals the list: a name added
# by hand breaks the sum, and a listed ticket whose understand.md is newer than <epoch> is tested anyway.
# Usage: legacy-init.sh <workspace>
W=$1; L=$W/built-check-legacy.txt
[ -d "$W/score" ] || { echo "usage: $0 <workspace>"; exit 2; }
[ -e "$L" ] && { echo "exists: $L (written once, never regenerated)"; exit 1; }
N=$(for d in "$W"/score/*/; do t=$(basename "$d"); [ -f "$d/understand.md" ] && ! grep -q '^Problem: ' "$d/understand.md" && echo "$t"; done)
{ [ -n "$N" ] && printf '%s\n' "$N"; echo "# written $(date +%s) sha256 $(printf '%s\n' "$N" | sha256sum | cut -d' ' -f1)"; } > "$L"
echo "$(grep -vc '^#' "$L") legacy tickets in $L"
