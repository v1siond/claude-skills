#!/usr/bin/env bash
# Push gate: a PreToolUse hook on Bash. A `git push` goes out only when every commit it sends was stamped by
# pre-deploy.sh: every gate of the repo's profile green on a clean tree at that exact commit. For Elixir that is
# mix format, credo --strict, compile with warnings as errors and the full suite; Ruby rubocop and its suite;
# JavaScript lint, typecheck, test and build (the profiles live in pre-deploy.sh).
#
# Exit 0 lets the call run. Exit 2 blocks it and the stderr text tells the agent what to run.
#   push-gate.sh --check <repo-dir> [refspec...]   the same decision, from a terminal
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMPS="$HOME/.claude/push-gate"

block() { echo "PUSH GATE: $1" >&2; exit 2; }

check_refs() { # <repo-dir> <refspec...>
  local dir="$1"; shift
  local root repo refs=("$@") r src sha
  root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || exit 0
  repo="$(basename "$root")"
  [ ${#refs[@]} -eq 0 ] && refs=(HEAD)
  for r in "${refs[@]}"; do
    src="${r#+}"; src="${src%%:*}"
    [ -z "$src" ] && continue   # ":branch" deletes a remote branch, nothing new leaves
    sha="$(git -C "$root" rev-parse --verify -q "$src^{commit}")" || block "cannot resolve '$src' in $root"
    [ -f "$STAMPS/$repo@$sha" ] && continue
    block "$repo $src ($(git -C "$root" rev-parse --short "$sha")) has no green gate run. Commit everything, then run
  bash $SCRIPT_DIR/pre-deploy.sh $root
fix every row that is not PASS, commit, and rerun until it prints 'stamped:'. Then push again."
  done
}

if [ "${1:-}" = --check ]; then shift; check_refs "$@"; echo "push gate: open"; exit 0; fi

input="$(cat)"
cmd="$(jq -r '.tool_input.command // empty' <<< "$input")"
cwd="$(jq -r '.cwd // empty' <<< "$input")"
grep -qE '(^|[;&|(`[:space:]])git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+push([[:space:]]|$)' <<< "$cmd" || exit 0

# One segment per git push in the command; the repo is the -C dir, else the last cd before it, else the cwd.
python3 - "$cmd" "$cwd" <<'PY' | while IFS=$'\t' read -r dir refs; do
import re, shlex, sys, os
cmd, cwd = sys.argv[1], sys.argv[2]
here = cwd
for seg in re.split(r'&&|\|\||;|\|', cmd):
    try:
        w = shlex.split(seg)
    except ValueError:
        w = seg.split()
    if not w:
        continue
    if w[0] == 'cd' and len(w) > 1:
        here = os.path.join(here, os.path.expanduser(w[1]))
        continue
    if w[0] != 'git' or 'push' not in w or '--delete' in w or '-d' in w:
        continue
    d, i = here, 1
    while i < len(w) and w[i] != 'push':
        if w[i] == '-C' and i + 1 < len(w):
            d = os.path.join(d, os.path.expanduser(w[i + 1])); i += 2; continue
        i += 1
    args = [a for a in w[i + 1:] if not a.startswith('-')]
    refs = args[1:]  # args[0] is the remote
    print(d + '\t' + ' '.join(refs))
PY
  read -r -a arr <<< "$refs"
  check_refs "$dir" "${arr[@]}" || exit 2
done
exit "${PIPESTATUS[1]:-0}"
