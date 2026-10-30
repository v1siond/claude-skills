#!/usr/bin/env bash
# Status line: shows the plan's 5-hour and 7-day usage and saves the numbers for usage-guard.sh.
# Claude Code sends rate_limits on stdin only for claude.ai Pro/Max, and only after the first API response.
input=$(cat)
state="$HOME/.claude/usage-state.json"

limits=$(printf '%s' "$input" | jq -c '.rate_limits // empty' 2>/dev/null)
if [ -n "$limits" ]; then
  printf '%s' "$limits" | jq -c --arg at "$(date +%s)" '. + {saved_at: ($at | tonumber)}' > "$state.tmp" && mv "$state.tmp" "$state"
  # Sessions on different accounts each write the shared file, so each also keeps its own copy for the guard.
  sid=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
  [ -n "$sid" ] && cp "$state" "$HOME/.claude/usage-state.$sid.json"
fi

five=$(printf '%s' "$limits" | jq -r '.five_hour.used_percentage // empty' 2>/dev/null)
week=$(printf '%s' "$limits" | jq -r '.seven_day.used_percentage // empty' 2>/dev/null)
reset=$(printf '%s' "$limits" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)

[ -z "$five" ] && { echo "5h usage: waiting for first reply"; exit 0; }
when=""
[ -n "$reset" ] && when=" (resets $(date -d "@$reset" +%H:%M))"
printf '5h %.0f%%%s · hard stop at 95%%' "$five" "$when"
[ -n "$week" ] && printf ' | week %.0f%% · hard stop at 98%%' "$week"
echo
