#!/bin/bash
# Check 4: the SKILLS.md entry of <name> matches a fresh catalogue.
# usage: check-entry.sh <name> <scratch folder> [SKILLS.md, default the live one]
# prints "entry: ok" (version line found once, entry diff empty) or the FAIL and the diff; exit 1 on a FAIL.
name=$1; out=$2; live=${3:-/home/visiond/projects/claude/skills/SKILLS.md}; here=$(cd "$(dirname "$0")" && pwd)
[ -n "$name" ] && [ -d "$out" ] || { echo "usage: $0 <name> <scratch folder> [SKILLS.md]"; exit 2; }
python3 "$here/catalog.py" --out "$out/SKILLS.md" >/dev/null || exit 2
e(){ awk -v h="### $name" '$0==h{f=1} f{print} f&&/^Source:/{exit}' "$1"; }
src=$(e "$out/SKILLS.md" | grep '^Source:'); n=$(grep -cxF -- "$src" "$live")
d=$(diff <(e "$out/SKILLS.md") <(e "$live"))
if [ -n "$src" ] && [ "$n" = 1 ] && [ -z "$d" ]; then echo "entry: ok"; exit 0; fi
echo "FAIL: entry of $name differs from a fresh catalogue (Source line found $n times)"; printf '%s\n' "$d"; exit 1
