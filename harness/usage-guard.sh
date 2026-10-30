#!/usr/bin/env bash
# PreToolUse guard: blocks every tool call (the session's and every subagent's) once a plan usage window reaches
# its stop line, and warns a few points earlier so agents commit what they have. Reads the numbers the status
# line saved; a reading from a window that has already reset is ignored.
# 5-hour window: stop at 100, warn at 95 (the whole window is usable).
state="$HOME/.claude/usage-state.json"
# Prefer this session's own reading: another session on another account overwrites the shared file.
sid=$(jq -r '.session_id // empty' 2>/dev/null)
[ -n "$sid" ] && [ -f "$HOME/.claude/usage-state.$sid.json" ] && state="$HOME/.claude/usage-state.$sid.json"

[ -f "$state" ] || exit 0
date +%s > "$HOME/.claude/usage-guard.last-run"
now=$(date +%s)

# prints "<pct> <resets_at>" for a window that is still current, nothing otherwise
reading() {
  jq -r --arg key "$1" --argjson now "$now" '
    .[$key] | select(. != null and .used_percentage != null and (.resets_at == null or .resets_at > $now))
    | "\(.used_percentage | floor) \(.resets_at // 0)"' "$state" 2>/dev/null
}

until_text() {
  [ "$1" -gt 0 ] && echo " until $(date -d "@$1" '+%a %H:%M')"
}

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
  exit 0
}

warnings=""
check_window() {
  local key=$1 label=$2 stop_at=$3 warn_at=$4 pct reset
  read -r pct reset < <(reading "$key")
  [ -z "$pct" ] && return
  [ "$pct" -ge "$stop_at" ] && deny "HARD STOP: ${label} plan usage is at ${pct}% (limit set at ${stop_at}%). Every tool call is blocked$(until_text "$reset"). Do not retry. Stop working and report what is committed and what is not."
  [ "$pct" -ge "$warn_at" ] && warnings+="USAGE WARNING: ${label} plan usage is at ${pct}%. Everything stops at ${stop_at}%. Keep working at full pace until the stop; keep the handoff current so the next session can resume (his words 10-22: \"you're free to go till 100% token usage, 10-22\"). "
}

check_window five_hour 5-hour 100 95
# Weekly: stop and warn at the lines passed below.
check_window seven_day weekly 100 99

[ -n "$warnings" ] && jq -n --arg c "$warnings" '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $c}}'
exit 0
