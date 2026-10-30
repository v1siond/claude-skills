#!/usr/bin/env bash
# Checks a runbook has the PR format of references/write-docs.md law 12:
# the four sections in order, and every ticket under QA with numbered steps or a "-> validate" line.
# Usage: check-runbook.sh <runbook.md>   Pass: prints "runbook: ok", exit 0.
set -u
f="$1"
want=("## Description of changes" "## What was implemented" "## Setup" "## QA steps per ticket")
got=$(grep -n '^## ' "$f")
prev=0; fail=0
for h in "${want[@]}"; do
  n=$(printf '%s\n' "$got" | grep -F ":$h" | head -1 | cut -d: -f1)
  if [ -z "$n" ]; then echo "FAIL missing section: $h"; fail=1; continue; fi
  if [ "$n" -le "$prev" ]; then echo "FAIL out of order: $h (line $n)"; fail=1; fi
  prev=$n
done
qa=$(awk '/^## QA steps per ticket/{on=1;next} /^## /{on=0} on' "$f")
printf '%s\n' "$qa" | awk '
  /^\*\*.*\*\*$/ { if (t!="" && !ok) { print "FAIL ticket without steps or -> validate: " t; bad=1 } t=$0; ok=0; next }
  /^[0-9]+\. / || /^-> validate/ { ok=1 }
  END { if (t!="" && !ok) { print "FAIL ticket without steps or -> validate: " t; bad=1 } if (t=="") { print "FAIL no ticket under QA steps per ticket"; bad=1 } exit bad }' || fail=1
[ "$fail" -eq 0 ] && echo "runbook: ok"
exit "$fail"
