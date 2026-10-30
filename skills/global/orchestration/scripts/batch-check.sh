#!/bin/bash
# READY TO REVIEW check for one row of a batch (law 6). Usage: batch-check.sh <workspace> <batch> <row folder>
# Each team member's file holds the row: builder build.md, architect contract.md, reviewer review.md, QA qa.md.
# Prints READY (exit 0) only when every clause holds; otherwise NOT READY with the counts (exit 1).
W=$1; B=$W/score/batch-$2; R=$3; D=$W/score/$R; n=${R%%-*}
b=$( { cat $D/*.md 2>/dev/null; grep -E "^$n \| " $B/review.md 2>/dev/null | grep -i "no commits"; } | grep -ciE "\b[0-9a-f]{8}\b|no commits")  # builder: the row files name 1 or more commit shas, or the reviewer found no commits for a row whose behaviour already held
c=$(grep -cE "^$n \| " $B/contract.md 2>/dev/null)                                          # architect: one line for the row (the seam, or "no seam")
v=$(grep -E "^$n \| " $B/review.md 2>/dev/null | tail -1 | grep -c '| pass$')               # reviewer: the row's last line ends "| pass" (0 Blocker, 0 Major)
s=$(awk '/^## /{buf=""} {buf=buf $0 "\n"} END{printf "%s", buf}' $D/qa/qa.md 2>/dev/null)  # QA: the last section of qa.md (the newest recheck)
a=$(printf '%s' "$s" | grep -c '| *PASS *| *$')                                             # 1 or more PASS rows
f=$(printf '%s' "$s" | grep -ciE '\| *(FAIL|NOT RUN|NOT WALKED|BLOCKED|PARTIAL)[^|]*\| *$')  # 0 rows of any other verdict
echo "build=$b contract=$c review=$v passRows=$a otherRows=$f"
[ "${b:-0}" -ge 1 ] && [ "${c:-0}" -ge 1 ] && [ "${v:-0}" -eq 1 ] && [ "${a:-0}" -ge 1 ] && [ "${f:-0}" -eq 0 ] && { echo READY; exit 0; }
echo "NOT READY"; exit 1
