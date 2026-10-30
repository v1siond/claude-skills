#!/usr/bin/env bash
# Pre-deploy protocol: run every gate the repo's CI runs (plus his standing ones), against the tree as it
# is now, and print one pass/fail row per gate. Never stops at the first failure.
#
#   pre-deploy.sh                    the repo containing the cwd
#   pre-deploy.sh <repo-dir>         that repo
#   pre-deploy.sh <dir> --list       print the gates it would run, run nothing
#   pre-deploy.sh <dir> --only a,b   run only the named gates
#   pre-deploy.sh <dir> --skip a,b   run every gate except these
#   pre-deploy.sh <dir> --install    run the dependency install gates too (npm ci, yarn, mix deps.get)
#   pre-deploy.sh <dir> --clean-env  run every gate with local secrets stripped, the way CI sees the env
#
# Read only apart from running the checks: it never pushes, tags, deploys, seeds or migrates a database
# outside the test env. A gate whose command matches the FORBIDDEN pattern below is refused, not run.
# Logs: $PRE_DEPLOY_LOGS (default ${TMPDIR:-/tmp}/pre-deploy/<repo>-<time>/<gate>.log).
set -uo pipefail

FORBIDDEN='git (push|commit|tag|merge|rebase|reset)|publish\.sh|bump\.sh|(^|[ /])deploy|railway|gigalixir|netlify|heroku|ecto\.(migrate|rollback|reset|drop)|db:(migrate|drop|reset)|mix run|data_migrate|seed'
SECRETS_TO_STRIP=(GCS_CREDENTIALS_JSON GCS_BUCKET_NAME GOOGLE_APPLICATION_CREDENTIALS)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED_FLAG_SECONDS=600

target="${1:-$PWD}"
[[ "$target" == --* ]] && target="$PWD" || shift || true
mode=run only="" skip="" install=0 clean_env=0
while [ $# -gt 0 ]; do
  case "$1" in
    --list) mode=list ;;
    --only) only="$2"; shift ;;
    --skip) skip="$2"; shift ;;
    --install) install=1 ;;
    --clean-env) clean_env=1 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo: $target" >&2; exit 2; }
repo="$(basename "$root")"
stamp="$(date +%Y%m%d-%H%M%S)"
logs="${PRE_DEPLOY_LOGS:-${TMPDIR:-/tmp}/pre-deploy/$repo-$stamp}"

G_NAME=() G_DIR=() G_NODE=() G_CMD=() G_KIND=()
# gate <name> <subdir> <node-version or -> <kind: mixtest|jest|playwright|rspec|plain|install> <command>
gate() { G_NAME+=("$1"); G_DIR+=("$2"); G_NODE+=("$3"); G_KIND+=("$4"); G_CMD+=("$5"); }

has_dep() { grep -qs "$1" "$root/mix.exs" "$root/mix.lock" "$root"/apps/*/mix.exs; }
has_script() { python3 -c "import json,sys;sys.exit(0 if '$2' in json.load(open('$1/package.json')).get('scripts',{}) else 1)" 2>/dev/null; }

elixir_core() { # <env prefix> <credo flags>
  local e="$1"
  gate format . - plain "$e mix format --check-formatted"
  has_dep credo && gate credo . - plain "$e mix credo --strict"
  gate compile . - plain "$e mix compile --force --warnings-as-errors"
}
data_in_migrations() { gate data-in-migrations . - plain "bash '$SCRIPT_DIR/../../ship/scripts/find-data-in-migrations.sh' ."; }

# ---------------------------------------------------------------------------- per-repo profiles (CI files)
# A project's profiles live outside this repo, one file per project, in the private overlay
# (${CLAUDE_PRIVATE_SKILLS:-skills/specific}/profiles/*.sh) and then ~/.claude/local-skills/profiles/*.sh. Each file
# defines its profile_<name> functions (with gate, elixir_core, has_dep, data_in_migrations, $root, $install) and adds
#   PROFILE_ROWS+=("<root glob>|<function>")   the first row whose glob matches the repo root wins, before the case below
PROFILE_ROWS=()
for f in "${CLAUDE_PRIVATE_SKILLS:-$SCRIPT_DIR/../../../specific}"/profiles/*.sh "$HOME"/.claude/local-skills/profiles/*.sh; do
  [ -f "$f" ] && . "$f"
done

profile_claude_skills() {
  gate skills-lint . - plain "python3 skills/global/skill-craft/scripts/lint-skills.py"
  gate python-compile . - plain "find skills harness -name '*.py' -not -path '*/__pycache__/*' -print0 | xargs -0 -r -n1 python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read(), sys.argv[1])'"
  gate bash-syntax . - plain "find skills harness -name '*.sh' -print0 | xargs -0 -r -n1 bash -n"
}

# ---------------------------------------------------------------------------- generic, by stack
profile_generic() {
  local node="-"
  [ -f "$root/.nvmrc" ] && node="$(tr -d 'v \n' < "$root/.nvmrc")"
  if [ -f "$root/mix.exs" ]; then
    local m=""
    [ -f "$root/mise.toml" ] || [ -f "$root/.mise.toml" ] && m="mise exec --"
    elixir_core "MIX_ENV=test $m"
    gate test . - mixtest "$m mix test"
    data_in_migrations
  fi
  if [ -f "$root/package.json" ]; then
    [ "$node" = "-" ] && node=24
    local s
    for s in lint typecheck format:check; do has_script "$root" "$s" && gate "$s" . "$node" plain "npm run $s"; done
    has_script "$root" typecheck || { [ -f "$root/tsconfig.json" ] && gate tsc . "$node" plain "npx tsc --noEmit"; }
    if has_script "$root" test:ci; then gate test . "$node" jest "npm run test:ci"; elif has_script "$root" test; then gate test . "$node" jest "npm test"; fi
    has_script "$root" build && gate build . "$node" plain "npm run build"
    for s in test:e2e e2e; do has_script "$root" "$s" && { gate e2e . "$node" playwright "npm run $s"; break; }; done
  fi
  if [ -f "$root/Gemfile" ]; then
    grep -qs rubocop "$root/Gemfile.lock" && gate rubocop . - plain "bundle exec rubocop"
    [ -d "$root/spec" ] && gate rspec . - rspec "bundle exec rspec"
  fi
  if [ -f "$root/pyproject.toml" ]; then
    command -v ruff > /dev/null && gate ruff . - plain "ruff check ."
    gate pytest . - plain "python3 -m pytest -q"
  fi
  [ -f "$root/Chart.yaml" ] && gate helm-lint . - plain "helm lint ."
  return 0
}

profile_for() {
  local row glob fn
  for row in "${PROFILE_ROWS[@]}"; do
    IFS='|' read -r glob fn <<<"$row"
    [[ $root == $glob ]] && { echo "$fn"; return; }
  done
  case "$root" in
    */projects/claude) echo profile_claude_skills ;;
    *) echo profile_generic ;;
  esac
}
"$(profile_for)"

# Every repo with a CI file gets ci-coverage: a CI test or lint step with no gate above, or a job on a floating
# *-latest runner, is NOT READY. A stamp then means "what CI runs, ran here", not "what the profile happens to list".
if compgen -G "$root/.github/workflows/*.y*ml" > /dev/null || [ -f "$root/.gitlab-ci.yml" ]; then
  mkdir -p "$logs"; printf '%s\n' "${G_CMD[@]}" > "$logs/gates.txt"
  gate ci-coverage . - plain "python3 '$SCRIPT_DIR/ci-coverage.py' . '$logs/gates.txt'"
fi

[ ${#G_NAME[@]} -eq 0 ] && { echo "no gates found for $root (no mix.exs, package.json, Gemfile, pyproject.toml or Chart.yaml)" >&2; exit 2; }

selected() {
  local n="$1"
  [ -n "$only" ] && [[ ",$only," != *",$n,"* ]] && return 1
  [ -n "$skip" ] && [[ ",$skip," == *",$n,"* ]] && return 1
  return 0
}

node_bin() { # exact version, else newest installed with the same major
  local v="$1" dir="$HOME/.nvm/versions/node"
  [ -d "$dir/v$v" ] && { echo "$dir/v$v/bin"; return; }
  local major="${v%%.*}" hit
  hit="$(ls -d "$dir"/v"$major".* 2>/dev/null | sort -V | tail -1)"
  [ -n "$hit" ] && echo "$hit/bin"
}

head_sha="$(git -C "$root" rev-parse --short HEAD)"
branch="$(git -C "$root" branch --show-current)"
dirty="$(git -C "$root" status --porcelain | wc -l)"
echo "repo:    $root"
echo "tree:    $branch @ $head_sha, $dirty uncommitted path(s)"

if [ "$mode" = list ]; then
  for i in "${!G_NAME[@]}"; do selected "${G_NAME[$i]}" && printf '%-28s %-34s node=%-9s %s\n' "${G_NAME[$i]}" "${G_DIR[$i]}" "${G_NODE[$i]}" "${G_CMD[$i]}"; done
  exit 0
fi

mkdir -p "$logs"
echo "logs:    $logs"
echo
R_NAME=() R_RES=() R_TIME=() R_SUM=()

summarise() { # <kind> <log> <exit> -> sets res, sum
  local kind="$1" log="$2" rc="$3"
  res=$([ "$rc" -eq 0 ] && echo PASS || echo FAIL); sum=""
  case "$kind" in
    mixtest)
      local fin lines
      fin="$(grep -c 'Finished in' "$log")"
      lines="$(grep -oE '([0-9]+ doctests?, )?([0-9]+ propert(y|ies), )?[0-9]+ tests?, [0-9]+ failures?(, [0-9]+ (excluded|skipped|invalid))*' "$log" | paste -sd ';' -)"
      sum="${lines:-no summary line} ($fin x Finished in)"
      [ "$fin" -eq 0 ] && res=NORUN
      local apps; apps="$(for a in "$root"/apps/*/test; do [ -n "$(find "$a" -name '*_test.exs' -print -quit 2>/dev/null)" ] && echo "$a"; done | wc -l)"
      [ "$apps" -gt 0 ] && [ "$fin" -gt 0 ] && [ "$fin" -lt "$apps" ] && { res=NORUN; sum="$sum, expected $apps apps"; }
      grep -qE 'CompileError|SyntaxError|TokenMissingError|cannot compile module' "$log" && [ "$res" = PASS ] && res=FAIL
      grep -qE ' [1-9][0-9]* failures?' <<< "$lines" && res=FAIL ;;
    jest) sum="$(grep -E '^(Tests|Test Suites):' "$log" | paste -sd ';' -)"; [ -z "$sum" ] && [ "$res" = PASS ] && res=NORUN ;;
    playwright) sum="$(grep -E '^\s+[0-9]+ (passed|failed|flaky|skipped)' "$log" | sed 's/^ *//' | paste -sd ';' -)"; [ -z "$sum" ] && [ "$res" = PASS ] && res=NORUN ;;
    rspec) sum="$(grep -E '[0-9]+ examples?, [0-9]+ failures?' "$log" | paste -sd ';' -)"; [ -z "$sum" ] && [ "$res" = PASS ] && res=NORUN ;;
    *) sum="$(grep -iE 'error|fail|not found|warning' "$log" | tail -1 | cut -c1-90)"
       [ -z "$sum" ] && sum="$(grep -Ev '^\s*$' "$log" | tail -1 | cut -c1-90)" ;;
  esac
  [ "$rc" -eq 127 ] && sum="command not found ($(grep -m1 'not found' "$log" | cut -c1-60)), deps missing? rerun with --install"
  return 0
}

for i in "${!G_NAME[@]}"; do
  name="${G_NAME[$i]}"; selected "$name" || continue
  dir="$root/${G_DIR[$i]}"; cmd="${G_CMD[$i]}"; log="$logs/$name.log"
  if grep -qE "$FORBIDDEN" <<< "$cmd"; then R_NAME+=("$name"); R_RES+=(REFUSED); R_TIME+=(0); R_SUM+=("command matches the forbidden list"); continue; fi
  path="$PATH"
  if [ "${G_NODE[$i]}" != - ]; then
    nb="$(node_bin "${G_NODE[$i]}")"
    [ -z "$nb" ] && { R_NAME+=("$name"); R_RES+=(MISSING); R_TIME+=(0); R_SUM+=("node ${G_NODE[$i]} not installed under nvm"); continue; }
    path="$nb:$PATH"
  fi
  envp=(env)
  [ $clean_env = 1 ] && for s in "${SECRETS_TO_STRIP[@]}"; do envp+=(-u "$s"); done
  envp+=("PATH=$path")
  [ $clean_env = 1 ] && envp+=(CI=true)
  printf '%-28s running ... ' "$name"
  t0=$SECONDS
  (cd "$dir" && "${envp[@]}" bash -c "$cmd") > "$log" 2>&1
  rc=$?
  dt=$((SECONDS - t0))
  summarise "${G_KIND[$i]}" "$log" "$rc"
  [ "$dt" -ge $RED_FLAG_SECONDS ] && sum="$sum [over 10 min, red flag]"
  echo "$res (exit $rc, ${dt}s)"
  R_NAME+=("$name"); R_RES+=("$res"); R_TIME+=("$dt"); R_SUM+=("$sum")
done

echo
printf '| %-26s | %-7s | %6s | %s\n' gate result time summary
printf '|%s|%s|%s|%s\n' "----------------------------" "---------" "--------" "--------"
bad=0
for i in "${!R_NAME[@]}"; do
  printf '| %-26s | %-7s | %5ss | %s\n' "${R_NAME[$i]}" "${R_RES[$i]}" "${R_TIME[$i]}" "${R_SUM[$i]}"
  [ "${R_RES[$i]}" = PASS ] || bad=$((bad + 1))
done
echo
echo "tested:  $branch @ $head_sha with $dirty uncommitted path(s). Ship exactly this tree, or rerun."
partial=""
[ -n "$only$skip" ] && partial=" (PARTIAL: --only/--skip used, this is not a ready verdict for the repo)"
[ ${#R_NAME[@]} -eq 0 ] && { echo "verdict: NOT READY (0 gates ran)$partial"; exit 1; }
if [ $bad -eq 0 ]; then
  echo "verdict: READY (${#R_NAME[@]} gates green)$partial"
  # The push gate (push-gate.sh) lets a push through only for a commit stamped here: every gate, clean tree.
  if [ -z "$partial" ] && [ "$dirty" -eq 0 ]; then
    stamps="$HOME/.claude/push-gate"; mkdir -p "$stamps"
    printf '%s %s %s\n' "$(date -u +%FT%TZ)" "${#R_NAME[@]}" "$(IFS=,; echo "${R_NAME[*]}")" > "$stamps/$repo@$(git -C "$root" rev-parse HEAD)"
    echo "stamped: $stamps/$repo@$(git -C "$root" rev-parse HEAD) (the push gate lets this commit out)"
  fi
  exit 0
fi
echo "verdict: NOT READY ($bad of ${#R_NAME[@]} gates not green)$partial. Logs in $logs"
exit 1
