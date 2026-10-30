#!/usr/bin/env bash
# Release preflight: everything to know BEFORE running bump.sh and publish.sh. Read only.
# It never fetches, bumps, tags, pushes or deploys; it reads the repo as it is.
#
#   release-preflight.sh [repo-dir]
#
# Prints: branch and tree state, the version file vs the newest tag of the repo's scheme, the tag the next
# patch bump would create (and whether it already exists), what publish.sh will push, and whether that tag
# matches the CI trigger that deploys production. Exit 1 when something must be fixed first.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-$PWD}"
root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo: $target" >&2; exit 2; }
cd "$root" || exit 2
repo="$(basename "$root")"
blockers=0 warnings=0
block() { blockers=$((blockers + 1)); echo "BLOCK  $*"; }
warn()  { warnings=$((warnings + 1)); echo "WARN   $*"; }
info()  { echo "       $*"; }

# Scheme per repo: tag prefix, version file, prod trigger (regex a tag must match), where prod goes. The rows live
# outside this repo, one file per project, in the private overlay (${CLAUDE_PRIVATE_SKILLS:-skills/specific}/profiles/*.sh)
# and then ~/.claude/local-skills/profiles/*.sh, each verified against that repo's publish.sh and CI files:
#   RELEASE_ROWS+=("<repo basename glob>|<prefix>|<version file>|<trigger regex>|<prod target>")
#   RELEASE_NOTES+=("<repo>: <how it releases instead>")   printed when no row matches
RELEASE_ROWS=() RELEASE_NOTES=()
for f in "${CLAUDE_PRIVATE_SKILLS:-$SCRIPT_DIR/../../../specific}"/profiles/*.sh "$HOME"/.claude/local-skills/profiles/*.sh; do
  [ -f "$f" ] && . "$f"
done
scheme=""
for row in "${RELEASE_ROWS[@]}"; do
  IFS='|' read -r glob prefix vfile trigger target_env <<<"$row"
  [[ $repo == $glob ]] && { scheme=$row; break; }
done
if [ -z "$scheme" ]; then
  echo "no release scheme known for $repo (no bump.sh/publish.sh pair here?)"
  for n in "${RELEASE_NOTES[@]}"; do echo "  $n"; done
  exit 2
fi

publish="$(ls publish.sh deploy/publish.sh 2>/dev/null | head -1)"
bump="$(ls bump.sh deploy/bump.sh 2>/dev/null | head -1)"
echo "repo:      $root"
echo "scripts:   ${bump:-none} / ${publish:-none}"
[ -z "$publish" ] && block "no publish.sh found"

branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo DETACHED)"
echo "branch:    $branch @ $(git rev-parse --short HEAD)"
case "$branch" in
  master|main) ;;
  *) block "publish.sh tags and pushes the CHECKED OUT branch ($branch). Releases go from master after staging was checked." ;;
esac

dirty="$(git status --porcelain | wc -l)"
[ "$dirty" -gt 0 ] && block "$dirty uncommitted path(s). bump.sh may commit them (some bump.sh scripts run 'git add --all'), and the tag would not match the tested tree."

upstream="$(git rev-parse --abbrev-ref '@{u}' 2>/dev/null)"
if [ -n "$upstream" ]; then
  read -r behind ahead <<< "$(git rev-list --left-right --count "$upstream...HEAD")"
  echo "upstream:  $upstream, $ahead ahead, $behind behind (as of the last fetch, this script does not fetch)"
  [ "$behind" -gt 0 ] && block "$behind commit(s) behind $upstream. Pull first or the release misses them."
  [ "$ahead" -gt 0 ] && warn "$ahead local commit(s) not on $upstream yet; publish.sh will push them with the tag."
  for s in origin/staging; do
    git rev-parse -q --verify "$s" >/dev/null || continue
    missing="$(git rev-list --count "HEAD..$s")"
    [ "$missing" -gt 0 ] && warn "$missing commit(s) on $s are not in $branch. If staging was the thing he checked, merge it first."
  done
fi

[ -r "$vfile" ] || { block "version file '$vfile' missing"; echo "verdict: NOT READY"; exit 1; }
version="$(tr -d '[:space:]' < "$vfile")"; version="${version#v}"
latest="$(git tag -l "${prefix}[0-9]*" --sort=-v:refname | head -1)"
echo "version:   $vfile says $version, newest ${prefix:-bare} tag is ${latest:-none}"
latest_v="${latest#"$prefix"}"
if [ -n "$latest" ] && [ "$(printf '%s\n%s\n' "$version" "$latest_v" | sort -V | tail -1)" != "$version" ]; then
  warn "$vfile ($version) lags the newest tag ($latest). bump from $version would land on an existing number. Set $vfile to $latest_v first, or pass explicit versions to bump.sh."
fi

IFS=. read -r ma mi pa <<< "$version"
next="$ma.$mi.$((pa + 1))"
start="$(( pa + 1 ))"
while git rev-parse -q --verify "refs/tags/$prefix$ma.$mi.$start" >/dev/null; do start=$((start + 1)); done
echo "next tag:  ${prefix}$next (patch bump)"
[ "$start" != "$((pa + 1))" ] && block "tag ${prefix}$next already exists; the first free patch is ${prefix}$ma.$mi.$start"

if [ -z "$trigger" ]; then
  info "prod: $target_env"
elif [[ "${prefix}$next" =~ $trigger ]]; then
  info "prod: ${prefix}$next matches the CI trigger, it deploys $target_env"
else
  block "${prefix}$next does NOT match the prod trigger ($trigger), nothing would deploy"
fi
legacy="$(git tag -l '[0-9]*.[0-9]*.[0-9]*' | wc -l)"
[ -n "$prefix" ] && [ "$legacy" -gt 0 ] && info "$legacy legacy bare N.N.N tags exist; they never match the current scheme, ignore them when reading 'latest'"

echo
[ $blockers -gt 0 ] && { echo "verdict: NOT READY ($blockers blocker(s), $warnings warning(s))"; exit 1; }
echo "verdict: preflight clean ($warnings warning(s)). Gates next (ship), then bump and publish only on his yes."
