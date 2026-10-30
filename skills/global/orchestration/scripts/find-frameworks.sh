#!/usr/bin/env bash
# List the framework documents that govern work in a repo, so the first read of a task is the right one.
#
#   find-frameworks.sh [repo-dir]
#
# Prints, in order: framework indexes (FRAMEWORKS.md), the repo's docs/*.md with their first heading,
# and the Claude workspace folder for the project (frameworks/, *FRAMEWORK*.md, AGENT_BRIEF*, feed-maps/).
# Read only. Prints "none found" per section so an empty result is visible, not silent.
set -uo pipefail

dir="$(cd "${1:-$PWD}" && pwd)"
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")"
ws="${CLAUDE_WORKSPACE:-$HOME/.claude-workspace}"
prune=(-path '*/node_modules' -o -path '*/deps' -o -path '*/_build*' -o -path '*/.claude' -o -path '*/.git' -o -path '*/vendor')

heading() { grep -m1 '^# ' "$1" 2>/dev/null | sed 's/^# //'; }

echo "repo: $root"
echo
echo "== framework indexes"
idx="$(find "$root" -maxdepth 4 \( "${prune[@]}" \) -prune -o -name 'FRAMEWORKS.md' -print 2>/dev/null)"
[ -n "$idx" ] && echo "$idx" || echo "none found"

echo
echo "== docs in the repo"
docs="$(find "$root" -maxdepth 4 \( "${prune[@]}" \) -prune -o -type f -path '*/docs/*.md' -print 2>/dev/null | sort)"
if [ -z "$docs" ]; then echo "none found"; fi
for f in $docs; do printf '%s  |  %s\n' "${f#$root/}" "$(heading "$f")"; done

echo
echo "== workspace"
name="$(basename "$root")"
wdir="$ws/$name"
if [ ! -d "$wdir" ]; then echo "no workspace folder $wdir"; exit 0; fi
found="$(find "$wdir" -maxdepth 2 \( -path "$wdir/frameworks/*" -o -iname '*FRAMEWORK*.md' -o -iname 'AGENT_BRIEF*' -o -type d -name feed-maps \) -print 2>/dev/null | sort)"
[ -n "$found" ] && echo "$found" || echo "none found in $wdir"
[ -f "$ws/_global/PR-REVIEW-FRAMEWORK.md" ] && echo "$ws/_global/PR-REVIEW-FRAMEWORK.md  (reviews, any repo)"
exit 0
