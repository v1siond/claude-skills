#!/bin/bash
# Checks 2 to 5 of SKILL.md "Check it before you show it". Usage: check-findings.sh <db folder> <schema file>
# The db folder holds findings.md and domain.md. Prints one line per failure, then "findings: ok" (exit 0) or
# "findings: <n> FAIL" (exit 1).
D=$1; F=$D/findings.md; M=$D/domain.md; S=$2
[ -f "$F" ] && [ -f "$M" ] && [ -f "$S" ] || { echo "FAIL missing findings.md, domain.md or the schema file"; echo "findings: 1 FAIL"; exit 1; }
X=$(mktemp); R=$(mktemp); C=$(mktemp); trap 'rm -f "$X" "$R" "$C"' EXIT
# The finding rows are the numbered rows above the first Kept debt or Open questions heading; for Check 3 a file
# reference (seed.sql:1-2, order.ex:29) is dropped, so a file name never counts as a table.column
awk '/^## (Kept debt|Open questions)/{exit} {print}' "$F" > "$R"
sed -E 's/[a-z0-9_]+\.(sql|rb|exs|ex|ts|js|py)\b(:[0-9-]+)?//g' "$R" > "$C"
# Check 2: every finding row has its 7 cells filled
c2=$(awk -F'|' '$2 ~ /^ *[0-9]+ *$/ {for(i=2;i<=8;i++) if ($i ~ /^ *$/) n++} END{print n+0}' "$R")
[ "$c2" -eq 0 ] || echo "EMPTY CELLS $c2" >> $X
# Check 3: every Evidence cell names a backticked table.column, and each one whose table is in the schema has that column (cells marked absent skipped)
awk -F'|' '$2 ~ /^ *[0-9]+ *$/ && $5 !~ /`[a-z_][a-z0-9_]*\.[a-z_][a-z0-9_]*[` ]/ {gsub(/ /,"",$2); print "NO COLUMN", $2}' "$C" >> $X
awk -F'|' '$2 ~ /^ *[0-9]+ *$/ && $5 !~ /absent|no [a-z]+ column/ {print $5}' "$C" | grep -oE '`[a-z_][a-z0-9_]*\.[a-z_][a-z0-9_]*`' | tr -d '`' |
  while IFS=. read t c; do grep -qiE "create table $t\b" "$S" && { grep -qw "$c" "$S" || echo "MISSING $t.$c"; }; done >> $X
# Check 4: every finding names an entity of domain.md in its Evidence or Finding cell
awk -F'|' 'NR==FNR {e=tolower($2); gsub(/ *\(.*\)|^ +| +$/,"",e); if ($0 ~ /^[|]/ && e !~ /^(entity|-+)$/) E[e]=1; next}
  $2 ~ /^ *[0-9]+ *$/ {h=0; for (k in E) if (index(tolower($5 $6), k)) h=1; if (!h) print "NO ENTITY", $2}' "$M" "$R" >> $X
# Check 5: needs his context does not state sit under one Open questions heading
[ "$(grep -c '^## Open questions' "$F")" -eq 1 ] || echo "OPEN QUESTIONS heading count is not 1" >> $X
n=$(wc -l < $X); cat $X
[ "$n" -eq 0 ] && { echo "findings: ok"; exit 0; }; echo "findings: $n FAIL"; exit 1
