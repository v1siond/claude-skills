#!/bin/bash
# Step 1 and 2a check (references/understand-method.md). Usage: understand-check.sh <ticket folder> [spec file] [PROMPT-LOG.md]
# Prints one "FAIL <what>" line per broken step, then "understand: ok" (exit 0) or "understand: <n> FAIL" (exit 1).
D=$1; U=$D/understand.md; S=${2:-$D/spec.md}; P=${3:-$(dirname "$(dirname "$D")")/PROMPT-LOG.md}
[ -f "$U" ] || { echo "FAIL understand.md missing"; echo "understand: 1 FAIL"; exit 1; }
X=$(mktemp); trap 'rm -f "$X"' EXIT
n=0; f(){ echo "FAIL $1"; n=$((n+1)); }
[ "$(grep -c '^Problem: ' "$U")" = 1 ] || f "1a Problem: line, need exactly 1"                       # 1a the base problem in its context
[ "$(grep -c '^## Static and dynamic' "$U")" = 1 ] || f "1b heading ## Static and dynamic, need exactly 1"
T=$(awk '/^## Static and dynamic/{s=1;next} s&&/^## /{exit} s' "$U")                                   # the 1b section
none=$(printf '%s\n' "$T" | grep -c '^none: ')
# 1b rows: id, bucket, owner after (columns found by header name); 1f STATIC with a placement key in Owner after
rows=$(printf '%s\n' "$T" | awk -F'|' '
  /^\|/ && !h {for(i=2;i<NF;i++){c=tolower($i); if(c~/^ *# *$/)id=i; if(c~/static or dynamic|bucket/)b=i; if(c~/owner after/)o=i}; h=1; next}
  /^\|[-| ]*$/ {next}
  /^\|/ && h {k++; r=(id?$id:"S" k); gsub(/ /,"",r); print r "\t" toupper($b) "\t" tolower($o) "\t" (o?1:0)}')
[ "$none" -ge 1 ] || [ -n "$rows" ] || f "1b no table rows and no none: line"
[ "$none" -ge 1 ] || ! printf '%s\n' "$rows" | awk -F'\t' '$4==0{e=1} END{exit !e}' || f "1b no Owner after column"
printf '%s\n' "$rows" | awk -F'\t' '$2 ~ /^ *STATIC/ && $3 ~ /per placement|placement|map_unit|unit_key|each placed|per map/ {print $1}' |
  while read r; do echo "FAIL 1f contradiction $r: STATIC with a placement key in Owner after (resolve from his words, never a question)"; done > $X
c=$(wc -l < $X); cat $X; n=$((n+c))
[ "$(grep -c '^Cause: ' "$U")" = 1 ] || f "1c Cause: line, need exactly 1"
[ "$none" -ge 1 ] || grep '^Cause: ' "$U" | grep -qE '(^|[^A-Za-z0-9])S[0-9]+([^0-9]|$)' || f "1c Cause: names no S row"
d=$(grep '^Debt: ' "$U"); [ "$(grep -c '^Debt: ' "$U")" = 1 ] || f "1e Debt: line, need exactly 1"
if [ -n "$d" ] && [ "$d" != "Debt: none" ] && printf '%s\n' "${d#Debt: }" | tr ';' '\n' | grep -vqE 'row [A-Za-z0-9]+'; then f "1e a Debt item names no row <id>"; fi
# 1d rules in the spec, or in brief.md on the bug path
R=$S; grep -q '^## Rules' "$R" 2>/dev/null || R=$D/brief.md
if grep -q '^## Rules' "$R" 2>/dev/null; then
  awk '/^## Rules/{s=1;next} s&&/^## /{exit} s&&/^R[0-9]+\./' "$R" | while IFS= read -r l; do
    q=$(printf '%s' "$l" | grep -oE '"[^"]+"' | head -1 | tr -d '"')
    { [ -n "$q" ] && grep -qF -- "$q" "$P" 2>/dev/null; } || echo "FAIL 1d ${l%%.*}: no fragment of his words found in PROMPT-LOG.md"
  done > $X; c=$(wc -l < $X); cat $X; n=$((n+c))
fi
# 2a every task (a ### <id>. heading, or a row of the first table right under the Tasks heading) names an R or S row
if [ -f "$S" ]; then
  awk -v re='(^|[^A-Za-z0-9])[RS][0-9]+([^0-9]|$)' 'function chk(l){if(l!~re) print "FAIL 2a task with no R or S row (cut, REJECT small rules first): " substr(l,1,80)}
    /^## .*([Tt]asks|[Pp]lan)/{s=1;t=0;done=0;next} s&&/^## /{s=0} !s{next}
    /^### [A-Z]*[0-9]+[a-z]?[.:) ]/{done=1; chk($0); next}
    /^\|/ && !done {if(!t){t=1;next} if($0~/^\|[-| ]*$/)next; chk($0); next}
    t{done=1}' "$S" > $X
  c=$(wc -l < $X); cat $X; n=$((n+c))
fi
# 1f STOP card questions cite an S row or "no data"; none on a STATIC row
for k in "$D"/stop-card*.md; do [ -f "$k" ] || continue
  grep -E '^## [0-9]+\.' "$k" | while IFS= read -r q; do
    s=$(printf '%s' "$q" | grep -oE 'S[0-9]+' | head -1)
    if [ -z "$s" ]; then printf '%s' "$q" | grep -q 'no data' || echo "FAIL 1f $(basename "$k") question cites no S row: ${q:0:70}"
    elif printf '%s\n' "$rows" | awk -F'\t' -v s="$s" '$1==s && $2 ~ /^ *STATIC/{e=1} END{exit !e}'; then echo "FAIL 1f $(basename "$k") question on STATIC row $s (resolve from his words)"; fi
  done; done > $X; c=$(wc -l < $X); cat $X; n=$((n+c))
[ "$n" -eq 0 ] && { echo "understand: ok"; exit 0; }; echo "understand: $n FAIL"; exit 1
