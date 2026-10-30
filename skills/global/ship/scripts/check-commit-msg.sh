#!/usr/bin/env bash
# Check commit messages against his voice rules. Read only.
#
#   check-commit-msg.sh -m "fix: stop prepending the base url"   one message
#   check-commit-msg.sh -f .git/COMMIT_EDITMSG                    a message file
#   check-commit-msg.sh -r origin/master..HEAD [-C repo]          every commit in a range
#
# Exit 0 when every message is clean, 1 when any rule is broken, 2 on bad usage.
set -uo pipefail

PREFIX='^(feat|fix|chore|refactor|test|docs|ci|perf|build|style|revert)(\([a-z0-9_./-]+\))?!?: [^ ]'
FILLER='\b(implement(s|ed)?|introduc(e|es|ed)|enabl(e|es|ed)|enhanc(e|es|ed)|comprehensive|leverag(e|es|ed)|robust|seamless(ly)?)\b'
ATTRIBUTION='co-authored-by|\bclaude\b|anthropic|generated with|\bAI\b|🤖'
ANTITHESIS='rather than|, not |which is (the|exactly)'

repo="." mode="" arg=""
while [ $# -gt 0 ]; do
  case "$1" in
    -m|-f|-r) mode="$1"; arg="${2:-}"; shift ;;
    -C) repo="${2:-.}"; shift ;;
    *) echo "usage: $0 -m <msg> | -f <file> | -r <range> [-C repo]" >&2; exit 2 ;;
  esac
  shift
done
[ -z "$mode" ] && { echo "usage: $0 -m <msg> | -f <file> | -r <range> [-C repo]" >&2; exit 2; }

problems=0
check_one() {
  local label="$1" msg="$2" subject issues=()
  msg="$(grep -v '^#' <<< "$msg")"
  subject="$(head -1 <<< "$msg")"
  # bump.sh writes its own "Bump version to X.Y.Z" commit; that one is the script's, leave it.
  [[ "$subject" =~ ^Bump\ version\ to\  ]] && { echo "skip  $label  $subject"; return; }
  grep -qE "$PREFIX" <<< "$subject" || issues+=("subject needs a lowercase conventional prefix (feat: fix: chore: ...)")
  [[ "$subject" =~ \.$ ]] && issues+=("subject ends with a period")
  grep -qiE "$FILLER" <<< "$subject" && issues+=("filler word in subject: $(grep -oiE "$FILLER" <<< "$subject" | head -1)")
  grep -q $'\xe2\x80\x94\|\xe2\x80\x93' <<< "$msg" && issues+=("em or en dash, use a full stop, comma, colon or parentheses")
  grep -qiE "$ATTRIBUTION" <<< "$msg" && issues+=("attribution or AI mention: $(grep -oiE "$ATTRIBUTION" <<< "$msg" | head -1)")
  local anti; anti="$(grep -oiE "$ANTITHESIS" <<< "$msg" | wc -l)"
  [ "$anti" -ge 2 ] && issues+=("$anti antithesis phrases (rather than / , not / which is), rewrite plainly")
  [ ${#issues[@]} -eq 0 ] && { echo "ok    $label  $subject"; return; }
  problems=$((problems + 1))
  echo "FIX   $label  $subject"
  printf '      - %s\n' "${issues[@]}"
}

case "$mode" in
  -m) check_one "message" "$arg" ;;
  -f) [ -r "$arg" ] || { echo "cannot read $arg" >&2; exit 2; }; check_one "$(basename "$arg")" "$(cat "$arg")" ;;
  -r)
    shas="$(git -C "$repo" rev-list --no-merges "$arg" 2>&1)" || { echo "$shas" >&2; exit 2; }
    [ -z "$shas" ] && { echo "no commits in $arg"; exit 0; }
    while read -r sha; do check_one "$(git -C "$repo" rev-parse --short "$sha")" "$(git -C "$repo" log -1 --format=%B "$sha")"; done <<< "$shas"
    ;;
esac
[ $problems -eq 0 ] && exit 0
echo "$problems message(s) need a rewrite (references/git-workflow-commit-voice.md)"
exit 1
