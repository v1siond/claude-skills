#!/usr/bin/env bash
# Print a repo's stack and the test, browser and lint commands it already defines, so tests are written
# and run with the repo's own tools.
#
#   detect-test-stack.sh [repo-dir]
#
# Read only. Looks at mix.exs (deps, aliases), package.json scripts, Gemfile, pyproject, Makefile,
# playwright configs, tool versions and CI files. Prints "none" for a section with nothing in it.
set -uo pipefail

dir="$(cd "${1:-$PWD}" && pwd)"
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")"
cd "$root" || exit 1
echo "repo: $root"

section() { echo; echo "== $1"; }
or_none() { local out; out="$(cat)"; [ -n "$out" ] && echo "$out" || echo "none"; }

section "stack"
{
  [ -f mix.exs ] && echo "elixir (mix.exs)"
  [ -f package.json ] && echo "node (package.json)"
  [ -f Gemfile ] && echo "ruby (Gemfile)"
  { [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f Pipfile ]; } && echo "python"
  [ -f Chart.yaml ] && echo "helm chart"
  ls assets/package.json apps/*/assets/package.json 2>/dev/null | sed 's/^/frontend inside elixir: /'
} | or_none

section "runtime versions"
cat .tool-versions .nvmrc .ruby-version .python-version 2>/dev/null | or_none

section "elixir test deps"
cat mix.exs apps/*/mix.exs 2>/dev/null | grep -oE '\{:(wallaby|phoenix_test_playwright|phoenix_test|stream_data|propcheck|mox|bypass|ex_machina|excoveralls|credo|dialyxir|sobelow)[^}]*\}' | sort -u | or_none

section "mix aliases mentioning test"
cat mix.exs apps/*/mix.exs 2>/dev/null | grep -E '^\s*(test|"test|e2e|"e2e|ci|check)[a-z.":]*\s*[:=]' | sort -u | or_none

section "package.json scripts (test, e2e, lint, type)"
for p in package.json assets/package.json apps/*/assets/package.json; do
  [ -f "$p" ] || continue
  python3 -I -c 'import json,sys
d=json.load(open(sys.argv[1]))
for k,v in d.get("scripts",{}).items():
    if any(w in k for w in ("test","e2e","lint","type","check","format")): print(f"{sys.argv[1]}: {k} = {v}")
deps={**d.get("dependencies",{}),**d.get("devDependencies",{})}
for k in ("@playwright/test","jest","vitest","fast-check","cypress"):
    if k in deps: print(f"{sys.argv[1]}: dep {k} {deps[k]}")' "$p"
done | or_none

section "ruby test gems"
grep -oE "gem '(rspec[a-z-]*|capybara|cuprite|selenium-webdriver|rubocop[a-z-]*|factory_bot[a-z_]*)'" Gemfile 2>/dev/null | sort -u | or_none

section "python test tools"
grep -hoE '(pytest|hypothesis|ruff|mypy|black)[^ ,"]*' pyproject.toml requirements*.txt Pipfile 2>/dev/null | sort -u | or_none

section "browser test config and scripts"
ls -d playwright*.config.* tests/e2e/playwright.config.* bin/e2e test/e2e test/*/features apps/*/test/*/features 2>/dev/null | or_none

section "Makefile targets"
grep -oE '^[a-zA-Z0-9_-]+:' Makefile 2>/dev/null | tr -d ':' | tr '\n' ' ' | or_none

section "CI test steps"
grep -hE '(mix (test|credo|format|compile)|npm (run )?test|npx (playwright|tsc|jest)|yarn test|rspec|pytest|bin/e2e)' .gitlab-ci.yml .github/workflows/*.yml 2>/dev/null | sed 's/^ *//' | sort -u | or_none
exit 0
