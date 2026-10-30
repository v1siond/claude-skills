#!/bin/bash
# Law 3 check, run around the row edit alone (works at row 0, before any ticket folder exists).
# Usage: law3-check.sh before <workspace>   (before the edit)
#        law3-check.sh after <workspace>    (after it; prints PASS <n>a<n+1>, exit 0, or FAIL with the diff, exit 1)
# The batch's last row = the last `| ` line under the one heading that `grep -n '^#.*live score' ORCHESTRA.md` prints.
phase=$1; W=$2
[ -f "$W/ORCHESTRA.md" ] || { echo "FAIL: no $W/ORCHESTRA.md"; exit 1; }
[ "$phase" = before ] && { grep '^| \|^#' "$W/ORCHESTRA.md" > "$W/score-before.txt"; echo "saved $W/score-before.txt"; exit 0; }
[ "$phase" = after ] || { echo "usage: law3-check.sh before|after <workspace>"; exit 2; }
[ -f "$W/score-before.txt" ] || { echo "FAIL: run 'before' first"; exit 1; }
h=$(grep -c '^#.*live score' "$W/score-before.txt")
[ "$h" -eq 1 ] || { echo "FAIL: $h headings name the live score, the record needs exactly 1"; exit 1; }
grep '^| \|^#' "$W/ORCHESTRA.md" > "$W/score-after.txt"
n=$(awk '/^#/{f=/live score/} f&&/^\| /{n=NR} END{print n+0}' "$W/score-before.txt")
[ "$n" -gt 0 ] || { echo "FAIL: the live score table has no row"; exit 1; }
d=$(diff "$W/score-before.txt" "$W/score-after.txt" | grep '^[0-9<]')
k=$(diff "$W/score-before.txt" "$W/score-after.txt" | grep -c '^>'); ln=$(grep -n '^| \|^#' "$W/ORCHESTRA.md" | sed -n "${n}p" | cut -d: -f1)
bad=$(sed -n "$((ln+1)),$((ln+k))p" "$W/ORCHESTRA.md" | grep -vc '^| ')   # the k new lines sit right under the last row (by line number), each a | row
echo "$d" | grep -qxE "${n}a$((n+1))(,[0-9]+)?" && [ "$(echo "$d" | wc -l)" -eq 1 ] && [ "$bad" -eq 0 ] && { echo "PASS $d"; exit 0; }
echo "FAIL: want one hunk ${n}a$((n+1)) (after the batch's last row, line $n), got:"; echo "${d:-(no change)}"; exit 1
