#!/usr/bin/env bash
# Read-only facts for the session-start ready summary: cwd, project and workspace, branch, stack,
# newest workspace context files, last time entry, and whether a timer is already running.
#   session-context.sh [dir]      (default: the current directory)
# Writes nothing. Safe to run any time.
set -uo pipefail

WS="${CLAUDE_WORKSPACE:-$HOME/.claude-workspace}"
P="$HOME/projects"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$(cd "${1:-$PWD}" 2>/dev/null && pwd)" || { echo "error: cannot cd to ${1:-$PWD}"; exit 1; }

# Project Map, by cwd. The rows live outside this repo, one file per project, in the private overlay
# (${CLAUDE_PRIVATE_SKILLS:-skills/specific}/profiles/*.sh) and then ~/.claude/local-skills/profiles/*.sh:
#   PROJECT_ROWS+=("<glob>|<id>|<label>")   the first static row whose glob matches the cwd names the project;
#                                            id "-" names it after the folder under the glob, after every static row
#   scope_<id>() { ... }                     optional: sets SCOPE, KEEP or DROP (find filters) and prints scope:
#   note_<id>() { ... }                      optional: prints note: lines
#   context_<id>() { ... }                   optional: extra context lines after a KEEP listing
# <id> in a function name has every character outside [A-Za-z0-9_] turned into _.
PROJECT_ROWS=()
for f in "${CLAUDE_PRIVATE_SKILLS:-$SCRIPT_DIR/../../../specific}"/profiles/*.sh "$HOME"/.claude/local-skills/profiles/*.sh; do
  [ -f "$f" ] && . "$f"
done

project_for() {
  local d="$1" row glob id label n
  for row in "${PROJECT_ROWS[@]}"; do
    IFS='|' read -r glob id label <<<"$row"
    [ "$id" != - ] && [[ $d == $glob ]] && { echo "$id|$label"; return; }
  done
  for row in "${PROJECT_ROWS[@]}"; do
    IFS='|' read -r glob id label <<<"$row"
    [ "$id" = - ] && [[ $d == $glob ]] && { n="${d#${glob%/\*}/}"; n="${n%%/*}"; echo "$n|$n (not in the CLAUDE.md map)"; return; }
  done
  case "$d" in
    $P/*)  n="${d#$P/}";  n="${n%%/*}"; echo "$n|$n (not in the CLAUDE.md map)" ;;
    $P)    echo "projects-root|projects root" ;;
    *)     echo "_global|outside ~/projects" ;;
  esac
}
hook() { declare -F "$1_${PROJECT//[^A-Za-z0-9_]/_}" >/dev/null && "$1_${PROJECT//[^A-Za-z0-9_]/_}"; return 0; }

IFS='|' read -r PROJECT LABEL <<<"$(project_for "$DIR")"
echo "cwd:        $DIR"
echo "project:    $PROJECT  ($LABEL)"

# Scope inside a shared workspace: a project's scope_<id> narrows the files listed to one thread.
SCOPE=""; KEEP=(); DROP=()
hook scope
if [ -d "$WS/$PROJECT" ]; then echo "workspace:  $WS/$PROJECT/"; else echo "workspace:  $WS/$PROJECT/ (MISSING, create it only when there is something to save)"; fi
hook note

# Branch: the repo at cwd, or every repo one level down (a project folder holding several repos).
if git -C "$DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  TOP="$(git -C "$DIR" rev-parse --show-toplevel)"
  echo "branch:     $(git -C "$DIR" branch --show-current 2>/dev/null || echo detached) ($TOP)"
  echo "changed:    $(git -C "$DIR" status --porcelain 2>/dev/null | wc -l) files uncommitted"
  echo "commits:"; git -C "$DIR" log --oneline -3 2>/dev/null | cut -c1-120 | sed 's/^/  /'
else
  TOP="$DIR"
  for r in "$DIR"/*/; do
    git -C "$r" rev-parse --show-toplevel >/dev/null 2>&1 || continue
    echo "branch:     $(basename "$r"): $(git -C "$r" branch --show-current 2>/dev/null) ($(git -C "$r" status --porcelain 2>/dev/null | wc -l) uncommitted)"
  done
fi

# Stack, from the files at the repo root.
stack=""
for f in mix.exs package.json Gemfile pyproject.toml requirements.txt Chart.yaml go.mod Cargo.toml; do
  [ -e "$TOP/$f" ] && stack="$stack $f"
done
echo "stack:     ${stack:- none detected at $TOP}"

# Newest context files in the workspace: handoffs, state, plans, ticket lists, prompt log.
if [ -d "$WS/$PROJECT" ]; then
  echo "context (newest first):"
  if [ ${#KEEP[@]} -gt 0 ]; then
    find -L "$WS/$PROJECT" -maxdepth 3 -type f "${KEEP[@]}" -iname '*.md' \
      -printf '%TY-%Tm-%Td %TH:%TM  %p\n' 2>/dev/null | sort -r | head -8 | sed 's/^/  /'
    hook context
  else
    find -L "$WS/$PROJECT" -maxdepth 2 -type f "${DROP[@]}" \
      \( -iname '*handoff*' -o -iname 'STATE.md' -o -iname 'PLAN*.md' -o -iname 'TICKETS*.md' -o -iname 'OPEN_WORK*' \
         -o -iname 'ORCHESTRA*.md' -o -iname 'BATCH__*' -o -iname 'PROMPT-LOG*' -o -iname '*SESSION*' -o -iname '*_STATUS.md' \) \
      -printf '%TY-%Tm-%Td %TH:%TM  %p\n' 2>/dev/null | sort -r | head -8 | sed 's/^/  /'
    echo "newest anything:"
    find -L "$WS/$PROJECT" -maxdepth 1 -type f ! -name entries.jsonl "${DROP[@]}" -printf '%TY-%Tm-%Td %TH:%TM  %f\n' 2>/dev/null | sort -r | head -5 | sed 's/^/  /'
  fi
  E="$WS/$PROJECT/time_entries/entries.jsonl"
  [ -f "$E" ] && echo "last tracked: $(tail -1 "$E" | python3 -c 'import json,sys; e=json.loads(sys.stdin.read()); print(e["ts"], e["type"], e["ref"])' 2>/dev/null)"
fi

echo "global:     $P/CLAUDE.md ($(wc -l <"$P/CLAUDE.md") lines)"

# Timer: the track tool keeps ONE timer in /tmp for every session on the machine.
if [ -f /tmp/track_current.json ]; then
  echo "timer:      RUNNING $(cat /tmp/track_current.json). Starting a new one ends it (see the session-start skill)."
else
  echo "timer:      none running"
fi
