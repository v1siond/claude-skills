#!/usr/bin/env bash
# Check text written under his name before it goes anywhere: docs, specs, MR/PR text and comments,
# Slack drafts, time entries, commit messages, reports.
#
#   check-text.sh <file...>            scan files
#   echo "text" | check-text.sh        scan stdin
#   check-text.sh --staged             scan only the lines added in `git diff --cached`
#   check-text.sh --diff               scan only the lines added in `git diff` (working tree)
#   add --strict to fail on the style warnings too
#
# FAIL (exit 1): em or en dash, distancing phrases, Claude attribution.
# WARN (exit 0 unless --strict): antithesis ("X, not Y", "rather than"), AI filler words.
# Read-only. Never edits the text.
set -uo pipefail

strict=0
mode=files
args=()
for a in "$@"; do
  case "$a" in
    --strict) strict=1 ;;
    --staged) mode=staged ;;
    --diff) mode=diff ;;
    *) args+=("$a") ;;
  esac
done

fails=0
warns=0

scan() {
  local src="$1" label="$2" out
  out=$(grep -nP '\x{2014}|\x{2013}' "$src") && { printf '%s\n' "$out" | sed "s|^|FAIL $label: dash: |"; fails=1; }
  out=$(grep -niE "not mine|pre-?existing|already in the (working )?tree|from an earlier session|that was there before|I didn.t touch" "$src") \
    && { printf '%s\n' "$out" | sed "s|^|FAIL $label: distancing: |"; fails=1; }
  out=$(grep -niE "co-authored-by|generated with \[?claude|written by (claude|an ai)|as an ai" "$src") \
    && { printf '%s\n' "$out" | sed "s|^|FAIL $label: attribution: |"; fails=1; }
  out=$(grep -niE "rather than|, not [a-z]|\bisn.t [^.]{1,40}, it.s\b|\bnot just\b|\bnot only\b" "$src") \
    && { printf '%s\n' "$out" | sed "s|^|WARN $label: antithesis: |"; warns=1; }
  out=$(grep -niwE "genuinely|precisely|seamless(ly)?|leverag(e|es|ing)|delve|robust|comprehensive|crucial|it.s worth noting|in summary|let.s dive|game.changer|elevate" "$src") \
    && { printf '%s\n' "$out" | sed "s|^|WARN $label: filler: |"; warns=1; }
  return 0
}

added_lines() {
  git diff "$@" -U0 2>/dev/null | grep '^+' | grep -v '^+++' | sed 's/^+//'
}

case "$mode" in
  staged|diff)
    git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "error: not inside a git repo"; exit 2; }
    t=$(mktemp)
    if [ "$mode" = staged ]; then added_lines --cached >"$t"; else added_lines >"$t"; fi
    scan "$t" "$mode"
    rm -f "$t"
    ;;
  files)
    if [ ${#args[@]} -eq 0 ]; then
      t=$(mktemp); cat >"$t"; scan "$t" stdin; rm -f "$t"
    else
      for f in "${args[@]}"; do
        [ -r "$f" ] || { echo "error: cannot read $f"; fails=1; continue; }
        scan "$f" "$f"
      done
    fi
    ;;
esac

[ $fails -eq 1 ] && exit 1
[ $warns -eq 1 ] && [ $strict -eq 1 ] && exit 1
[ $warns -eq 1 ] && { echo "clean of hard failures, warnings above are for a reread"; exit 0; }
echo "clean"
