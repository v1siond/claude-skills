#!/usr/bin/env bash
#
# STOP HOOK. In a git repo with changed files, refuses to let a turn end when its last message breaks the
# report shapes of orchestration law 18 (written out in ~/.claude/report-format.md).
# Exit 2 blocks and feeds stderr back.
#
# INSTALL, in the "hooks" object of ~/.claude/settings.json, alongside any other Stop hook:
#
#   "Stop": [ { "hooks": [ { "type": "command", "timeout": 60,
#       "command": "$HOME/.claude/stop-report-format.sh" } ] } ]
#
# What report-format-check.py checks, on the last assistant message with text:
#   a standup (first line starts "Working on:" or "**Working on:**") has 3 to 6 lines and at most one line
#   starting "Waiting on you:";
#   a full report (has a heading line "## What changed") has a heading line "## How to QA", and each "### "
#   question under the heading line "## Questions for you" carries "Why it matters" and "My recommendation"
#   (a Questions section holding only "None." passes);
#   a heading line holds only the heading: a heading named inside a sentence is not one;
#   any message has no em dash and no en dash;
#   a message in neither shape passes the shape checks (an answer is not an update).
#
# What this script adds: it stays quiet when the stop hook is already active, when the turn changed no files
# (images and docs/renders/ do not count), and when the same change set was already blocked once
# (.git/.stop-report-format-seen holds its fingerprint).
set -uo pipefail

INPUT="$(cat)"

read -r ACTIVE HOOK_CWD TRANSCRIPT <<<"$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(d.get("stop_hook_active", False), d.get("cwd", "") or ".", d.get("transcript_path", "") or "-")
except Exception:
    print(False, ".", "-")' 2>/dev/null || echo "False . -")"

# Without this the session can never end: the block would re-trigger itself forever.
[ "$ACTIVE" = "True" ] && exit 0
[ -f "$TRANSCRIPT" ] || exit 0

cd "$HOOK_CWD" 2>/dev/null || exit 0
REPO="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$REPO" || exit 0

# WORK CHANGED FILES, or there is no update to check. Generated output does not count as work.
CHANGED="$(git status --porcelain 2>/dev/null \
  | awk '{print $NF}' \
  | grep -vE '\.(png|jpg|jpeg|gif|webp|ico|woff2?)$' \
  | grep -vE '^docs/renders/' || true)"

[ -z "$CHANGED" ] && exit 0

# NEW work since the last block. The same change set never blocks twice, so a turn that is still talking
# about work already reported is left alone.
SEEN="$REPO/.git/.stop-report-format-seen"
FINGERPRINT="$(printf '%s' "$CHANGED" | tr '\n' ' ')|$(git diff HEAD 2>/dev/null | md5sum | cut -d' ' -f1)"
[ -f "$SEEN" ] && [ "$(cat "$SEEN")" = "$FINGERPRINT" ] && exit 0

FAILURES="$(python3 "$HOME/.claude/report-format-check.py" "$TRANSCRIPT" 2>/dev/null)" || FAILURES=""

[ -z "$FAILURES" ] && exit 0

printf '%s' "$FINGERPRINT" >"$SEEN"

{
  echo "STOP BLOCKED. The report is not in shape (orchestration law 18, ~/.claude/report-format.md):"
  echo
  printf '%s\n' "$FAILURES"
  echo
  echo "Rewrite the LAST message in one of the two shapes, then finish:"
  echo
  echo "  A standup, 3 to 6 lines: Working on: / Needs before done: / Then: / Waiting on you: <title> (asked <MM-DD HH:MM>), <title> (asked <MM-DD HH:MM>), one line shared by every open question / Batch: <n> of <m> done"
  echo "  A full report: ## What changed, ## Commits, ## How to QA, ## Not done, ## Questions for you (only if any), ## Following"
  echo "  Each question is a ### card: What it is, Why it matters, Options, My recommendation"
} >&2

exit 2
