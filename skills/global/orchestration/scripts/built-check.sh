#!/bin/bash
# BUILT check for one ticket. Usage: built-check.sh <workspace> <ticket>
# Prints BUILT (exit 0) only when every clause holds; otherwise NOT BUILT with the counts (exit 1).
W=$1; T=$2; D=$W/score/$T; Q=$D/qa
e=$( { ls $D/{understand,scope,contract,brief,director-critic,control,review,integrate}.md $Q/qa.md >/dev/null; } 2>&1 | wc -l)  # every row's Output (D1, D2, A, D4, D4c, Dc, V, D6), 0 errors
y=$(grep -cE '^Buy: .+' $D/scope.md 2>/dev/null)                                          # row D2: a Buy: line (a package, or none with its query)
k=$(grep -cE '^(Contract|Skills you run):' $D/brief.md 2>/dev/null)                        # row D4: the Contract: and Skills you run: lines
a=$(grep -c '| *PASS *| *$' $Q/qa.md 2>/dev/null)                                      # 1 or more PASS rows
b=$(grep '^|' $Q/qa.md 2>/dev/null | grep -v '^|[-| ]*$' | grep -vi '| *verdict *| *$' | grep -vc '| *PASS *| *$')  # 0 rows other than header and PASS
s=$(grep '| *PASS *| *$' $Q/qa.md 2>/dev/null | grep -vc 'qa/after-[0-9][0-9]*\.png')       # 0 PASS rows without a numbered screenshot
c=$( { for n in $(grep -o 'qa/after-[0-9][0-9]*\.png' $Q/qa.md 2>/dev/null | grep -o '[0-9]*' | sort -u); do ls $Q/before-$n.png $Q/after-$n.png >/dev/null && ! cmp -s $Q/before-$n.png $Q/after-$n.png || echo same $n; done; } 2>&1 | wc -l)  # each before-<n>/after-<n> pair present and they differ
z=$(find $Q -maxdepth 1 -name '*.png' -size 0 2>/dev/null | wc -l)                     # 0 empty png
f=$(file $Q/*.png 2>&1 | grep -vc '1920 x 1080,')                                        # every png 1920 x 1080
r=$(grep '^Verdict:' $D/review.md 2>/dev/null | tail -1 | grep -c '^Verdict: pass$')      # row V: the reviewer's last Verdict line is pass
g=$(grep -cE '^## (Before dispatch|Before his look)' $D/director-critic.md 2>/dev/null)   # rows D4c and D7: both sections of the director's critic
v=$(grep '^Verdict:' $D/director-critic.md 2>/dev/null | tail -1 | grep -c '^Verdict: ship$')  # the last director critic verdict is ship
l=$(grep -E "^\| [^|]*\| *$T *\|" $W/ORCHESTRA.md 2>/dev/null | grep -ciE 'his look')   # row LOOK: the Score row quotes his look
L=$W/built-check-legacy.txt; leg=0; u=0                                                 # legacy list: legacy-init.sh, written once and sealed
if [ -f $L ]; then h=$(tail -1 $L); ep=$(echo "$h" | awk '/^# written [0-9]+ sha256 /{print $3}'); sum=$(echo "$h" | awk '{print $5}')
  if [ -n "$ep" ] && [ "$(printf '%s\n' "$(grep -v '^#' $L)" | sha256sum | cut -d' ' -f1)" = "$sum" ] && m=$(stat -c %Y $L) && [ "$m" -ge "$ep" ] && [ "$m" -le $((ep+60)) ]; then
    grep -qxF "$T" $L && [ "$(stat -c %Y $D/understand.md 2>/dev/null || echo 0)" -le "$ep" ] && leg=1   # listed and untouched since the list
  else echo "FAIL legacy list seal (edited by hand, or the file is newer than its epoch), list ignored"; fi
fi
[ $leg -eq 1 ] || u=$(bash "$(dirname "$0")/understand-check.sh" $D | grep -c '^FAIL')   # row D1 method (understand-method.md)
[ "$u" -eq 0 ] || echo "FAIL understand.md ($u, run understand-check.sh $D)"
echo "stepFileErrors=$e buy=$y briefLines=$k passRows=$a otherRows=$b passNoShot=$s missingPair=$c emptyPng=$z notFHD=$f reviewPass=$r directorCritic=$g directorShip=$v hisLook=$l understandFail=$u legacy=$leg"
[ "$e" -eq 0 ] && [ "${y:-0}" -ge 1 ] && [ "${k:-0}" -ge 2 ] && [ "${a:-0}" -ge 1 ] && [ "$b" -eq 0 ] && [ "$s" -eq 0 ] && [ "$c" -eq 0 ] && [ "$z" -eq 0 ] && [ "$f" -eq 0 ] && [ "${r:-0}" -eq 1 ] && [ "${g:-0}" -ge 2 ] && [ "${v:-0}" -eq 1 ] && [ "${l:-0}" -ge 1 ] && [ "$u" -eq 0 ] && { echo BUILT; exit 0; }
echo "NOT BUILT"; exit 1
