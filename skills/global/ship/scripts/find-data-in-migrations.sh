#!/usr/bin/env bash
# Find row changes hiding in SCHEMA migrations, and migration versions that collide.
#
#   find-data-in-migrations.sh [repo-dir] [--base <ref>] [--all]
#
# Looks at the migration files added or changed since <base> (default: merge-base with origin/HEAD,
# origin/master, origin/main or origin/staging), plus untracked ones. --all scans every migration.
# Ecto (priv/repo/migrations/*.exs), Rails (db/migrate/*.rb) and node (migrations/*.js) are covered.
# Read only. Exit 1 when a migration touches rows or a changed migration reuses a version.
set -uo pipefail

target="${1:-$PWD}"
[[ "$target" == --* ]] && target="$PWD" || shift || true
base="" all=0
while [ $# -gt 0 ]; do
  case "$1" in
    --base) base="$2"; shift ;;
    --all) all=1 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo: $target" >&2; exit 2; }
cd "$root" || exit 2
specs=(':(glob)**/priv/repo/migrations/*.exs' ':(glob)**/db/migrate/*.rb' ':(glob)**/migrations/*.js' ':(exclude)deps/**' ':(exclude)node_modules/**' ':(exclude)**/node_modules/**')

if [ $all = 0 ] && [ -z "$base" ]; then
  for ref in origin/HEAD origin/master origin/main origin/staging; do
    base="$(git merge-base HEAD "$ref" 2>/dev/null)" && break
  done
fi

if [ $all = 1 ] || [ -z "$base" ]; then
  [ -z "$base" ] && [ $all = 0 ] && echo "no origin base found, scanning every migration"
  files="$(git ls-files -- "${specs[@]}"; git ls-files --others --exclude-standard -- "${specs[@]}")"
else
  echo "base: $(git rev-parse --short "$base")"
  files="$(git diff --name-only --diff-filter=AM "$base" -- "${specs[@]}"; git ls-files --others --exclude-standard -- "${specs[@]}")"
fi
files="$(printf '%s\n' "$files" | sort -u | grep -v '^$')"
[ -z "$files" ] && { echo "ok: no migration added or changed"; exit 0; }
echo "checking $(printf '%s\n' "$files" | wc -l) migration file(s)"

ROW_CHANGE='(UPDATE|DELETE|INSERT)[[:space:]]|backfill|(Repo|repo\(\))\.(insert|update|delete|query|all|one|get|stream|transaction)|update_all|delete_all|insert_all|find_each|update_column|\.save!?\b|bulkUpdate|bulkInsert|bulkDelete'
SCHEMA_ONLY='on_delete:|on_update:|ON (DELETE|UPDATE)|(BEFORE|AFTER|OR) (INSERT|UPDATE|DELETE)|^[0-9]+:[[:space:]]*(#|//|\*)'
hits=0
while IFS= read -r f; do
  found="$(grep -nE "$ROW_CHANGE" "$f" | grep -vE "$SCHEMA_ONLY")"
  [ -z "$found" ] && continue
  hits=$((hits + 1))
  echo "DATA IN MIGRATION: $f"
  printf '%s\n' "$found" | head -6 | sed 's/^/    /'
done <<< "$files"

# Versions: two migrations with the same timestamp, the second is silently skipped as "already up".
# deps/* is included because a git dep can share the database and the schema_migrations table.
dupes=0
versions="$( { git ls-files -- "${specs[@]}"; git ls-files --others --exclude-standard -- "${specs[@]}"; ls deps/*/priv/repo/migrations/*.exs 2>/dev/null; } \
  | sort -u | sed -nE 's#^(.*/)?([0-9]{12,14})_[^/]*$#\2 &#p' | sort)"
while read -r v; do
  [ -z "$v" ] && continue
  same="$(awk -v v="$v" '$1 == v {print $2}' <<< "$versions")"
  grep -qxF -f <(printf '%s\n' "$files") <<< "$same" || continue
  dupes=$((dupes + 1))
  echo "VERSION REUSED: $v"
  printf '%s\n' "$same" | sed 's/^/    /'
done < <(awk '{print $1}' <<< "$versions" | uniq -d)

[ $hits -eq 0 ] && [ $dupes -eq 0 ] && { echo "ok: schema only, no reused version"; exit 0; }
echo "move every row change into the project's data migration module (see the ship skill references)"
exit 1
