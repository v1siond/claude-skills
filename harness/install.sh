#!/usr/bin/env bash
# Recreates the Claude Code setup of this repo on a machine: links every skill and agent into
# ~/.claude, and copies the hooks, the protocol and the report check there. Safe to run again:
# a link that already points at the right place and a file that is already the same are left alone,
# a file that differs is saved as <file>.bak.<time> before the copy, and a link or folder that points
# elsewhere is skipped, never replaced.
#
#   harness/install.sh --dry-run   print each action, change nothing
#   harness/install.sh             do it
#
# settings.json and CLAUDE.md are never written: merge harness/settings.example.json into
# ~/.claude/settings.json and harness/CLAUDE.md into your own CLAUDE.md by hand.
set -euo pipefail

DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HARNESS="$REPO/harness"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
# The folder that holds your projects, where a CLAUDE.md for all of them would live; only named in the todo line.
PROJECTS_DIR="${PROJECTS_DIR:-$(dirname "$REPO")}"

run() {
  echo "$*"
  [ "$DRY" -eq 1 ] && return 0
  "$@"
}

link() {
  local target="$1" name="$2"
  if [ -L "$name" ] && [ "$(readlink "$name")" = "$target" ]; then
    echo "ok      $name"
    return 0
  fi
  if [ -e "$name" ] || [ -L "$name" ]; then
    echo "skip    $name exists and points elsewhere; move it away first"
    return 0
  fi
  run ln -s "$target" "$name"
}

copy() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    echo "ok      $dst"
    return 0
  fi
  run mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] && run cp -p "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  run cp -p "$src" "$dst"
}

[ "$DRY" -eq 1 ] && echo "dry run: nothing is changed"

run mkdir -p "$CLAUDE_HOME/skills" "$CLAUDE_HOME/agents" "$CLAUDE_HOME/hooks" "$CLAUDE_HOME/mods"

# Skills: global/<name> and specific/<scope>/<name>, each folder holding a SKILL.md.
while IFS= read -r skill_md; do
  dir="$(dirname "$skill_md")"
  link "$dir" "$CLAUDE_HOME/skills/$(basename "$dir")"
done < <(find "$REPO/skills" -mindepth 2 -maxdepth 4 -name SKILL.md | sort)

# Agents: the goldfish reviewers.
for agent in "$REPO"/agents/*.md; do
  link "$agent" "$CLAUDE_HOME/agents/$(basename "$agent")"
done

# Hooks, protocol and the report check: copies, so an edit here is installed on purpose.
for f in protocol.txt report-format.md report-format-check.py stop-report-format.sh usage-guard.sh usage-statusline.sh; do
  copy "$HARNESS/$f" "$CLAUDE_HOME/$f"
done
for f in "$HARNESS"/hooks/*; do
  copy "$f" "$CLAUDE_HOME/hooks/$(basename "$f")"
done

# Mods: sources only; the generated .claude-plugin/types folder is not in the repo.
while IFS= read -r f; do
  copy "$f" "$CLAUDE_HOME/mods/${f#"$HARNESS"/mods/}"
done < <(find "$HARNESS/mods" -type f | sort)

echo "todo    merge $HARNESS/CLAUDE.md into your own CLAUDE.md by hand (for example $PROJECTS_DIR/CLAUDE.md); it names its author, so edit the name and paths"

if [ ! -f "$CLAUDE_HOME/settings.json" ]; then
  echo "todo    $CLAUDE_HOME/settings.json is missing: start from $HARNESS/settings.example.json and fill each <placeholder>"
else
  echo "todo    compare $CLAUDE_HOME/settings.json with $HARNESS/settings.example.json by hand"
fi
