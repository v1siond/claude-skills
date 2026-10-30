#!/bin/bash
# usage: bump-check.sh <SKILL.md copy taken at Intake> <SKILL.md now>; exit 1 on the FAIL.
# Prints "bumped" or "same" or "FAIL: body changed, version not bumped".
[ -s "$1" ] && [ -s "$2" ] && grep -q "^  version:" "$1" || { echo "usage: $0 <intake copy> <SKILL.md>"; exit 2; }
v1=$(grep -m1 "^  version:" "$1"); v2=$(grep -m1 "^  version:" "$2")
if cmp -s <(grep -v "^  version:" "$1") <(grep -v "^  version:" "$2"); then echo same
elif [ "$v1" = "$v2" ]; then echo "FAIL: body changed, version not bumped"; exit 1; else echo bumped; fi
