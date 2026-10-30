#!/usr/bin/env bash
# Toolchain check: what the repo pins, what CI uses, what THIS shell resolves, and the line that fixes it.
# Read only: it reads pin files and asks each tool for its version. It installs and changes nothing.
#
#   toolchain-check.sh [repo-dir]
#
# Exit 1 when the shell resolves a different node, elixir or erlang than the repo pins.
set -uo pipefail

notes_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/specific"
target="${1:-$PWD}"
root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || (cd "$target" && pwd))"
cd "$root" || exit 2
mismatches=0
row() { printf '%-9s %-22s %-22s %-24s %s\n' "$@"; }
bad() { mismatches=$((mismatches + 1)); }

pin_from_tool_versions() { [ -r .tool-versions ] && awk -v t="$1" '$1 == t {print $2; exit}' .tool-versions; }
pin_from_mise() { [ -r mise.toml ] && sed -nE "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*\"([^\"]+)\".*/\1/p" mise.toml | head -1; }
ci_files() { ls .gitlab-ci.yml ci/*.yml .github/workflows/*.y*ml 2>/dev/null; }
ci_pin() {
  local files; files="$(ci_files)"; [ -z "$files" ] && return
  case "$1" in
    node) grep -hoE "(image: *node:|node-version: *['\"]?)[0-9][0-9.]*" $files | grep -oE '[0-9][0-9.]*$' | sort -u | paste -sd, - ;;
    elixir) grep -hoE "(image: *(hexpm/)?elixir:|elixir-version: *['\"]?)[0-9][0-9.]*" $files | grep -oE '[0-9][0-9.]*$' | sort -u | paste -sd, - ;;
    erlang) grep -hoE "(otp-version: *['\"]?|erlang-)[0-9][0-9.]*" $files | grep -oE '[0-9][0-9.]*$' | sort -u | paste -sd, - ;;
  esac
}
mise_managed=0; [ -r mise.toml ] && mise_managed=1

echo "repo: $root"
[ -r .tool-versions ] && echo "pins: .tool-versions"
[ $mise_managed = 1 ] && echo "pins: mise.toml (asdf shims shadow mise here, prefix commands with 'mise exec --')"
[ -r .nvmrc ] && echo "pins: .nvmrc"
echo
row tool pinned ci "this shell" fix

# Node: pinned by .nvmrc, .tool-versions (nodejs or node), mise, or package.json engines.
node_pin="$(cat .nvmrc 2>/dev/null | tr -d 'v[:space:]')"
[ -z "$node_pin" ] && node_pin="$(pin_from_tool_versions nodejs)"
[ -z "$node_pin" ] && node_pin="$(pin_from_tool_versions node)"
[ -z "$node_pin" ] && node_pin="$(pin_from_mise node)"
engines="$( [ -r package.json ] && sed -nE 's/.*"node" *: *"([^"]+)".*/\1/p' package.json | head -1)"
node_ci="$(ci_pin node)"
want="${node_ci%%,*}"; [ -z "$want" ] && want="$node_pin"
if [ -n "$want$engines" ] || [ -r package.json ]; then
  have="$(node -v 2>/dev/null | tr -d v)"; have="${have:-none}"
  [ -z "$want" ] && want="$(cat ~/.nvm/alias/default 2>/dev/null)"
  fix="ok"
  if [ "${have%%.*}" != "${want%%.*}" ]; then
    bad
    dir="$(ls -d ~/.nvm/versions/node/v"$want" 2>/dev/null)"
    [ -z "$dir" ] && dir="$(ls -d ~/.nvm/versions/node/v"${want%%.*}".* 2>/dev/null | sort -V | tail -1)"
    if [ -n "$dir" ]; then fix="export PATH=$dir/bin:\$PATH"; else fix="source ~/.nvm/nvm.sh && nvm install $want"; fi
  fi
  row node "${node_pin:-none}${engines:+ (engines $engines)}" "${node_ci:-none}" "$have" "$fix"
  [ "${have%%.*}" = "10" ] && echo "          v10 is the inherited PATH of non-interactive shells; jest then prints only 'Unexpected token .'"
fi

# Elixir and Erlang: asdf resolves .tool-versions per directory, mise only through 'mise exec'.
if [ -r mix.exs ]; then
  run() { if [ $mise_managed = 1 ]; then mise exec -- "$@"; else "$@"; fi; }
  ex_out="$(run elixir --version 2>&1)"
  ex_have="$(sed -nE 's/^Elixir ([0-9][0-9.]*).*/\1/p' <<< "$ex_out")"
  # The runtime OTP, not the one elixir was compiled with (a 1.17 built on OTP 25 runs fine on 27).
  otp_have="$(run erl -noshell -eval 'io:put_chars(erlang:system_info(otp_release)), halt().' 2>/dev/null)"
  ex_pin="$(pin_from_tool_versions elixir)"; [ -z "$ex_pin" ] && ex_pin="$(pin_from_mise elixir)"
  erl_pin="$(pin_from_tool_versions erlang)"; [ -z "$erl_pin" ] && erl_pin="$(pin_from_mise erlang)"
  ex_want="${ex_pin%%-otp*}"
  fix="ok"
  if [ -z "$ex_have" ]; then
    bad; fix="elixir did not start: $(head -1 <<< "$ex_out" | cut -c1-60)"
  elif [ -n "$ex_want" ] && [ "${ex_have%.*}" != "$(cut -d. -f1-2 <<< "$ex_want")" ]; then
    bad
    if [ $mise_managed = 1 ]; then fix="prefix with: mise exec --"
    elif [ -d ~/.asdf/installs/elixir/"$ex_pin" ]; then fix="run from the repo dir (asdf reads .tool-versions there)"
    else fix="asdf install elixir $ex_pin"; fi
  fi
  row elixir "${ex_pin:-none}" "$(ci_pin elixir || true)" "${ex_have:-none}" "$fix"
  fix="ok"
  if [ -n "$erl_pin" ] && [ -n "$otp_have" ] && [ "${erl_pin%%.*}" != "$otp_have" ]; then
    bad; fix="erl resolves OTP $otp_have, the pin says $erl_pin; asdf install erlang $erl_pin"
  fi
  row erlang "${erl_pin:-none}" "$(ci_pin erlang || true)" "OTP ${otp_have:-?}" "$fix"
fi

# Ruby: asdf per directory.
if [ -r Gemfile ]; then
  rb_pin="$(pin_from_tool_versions ruby)"; [ -z "$rb_pin" ] && rb_pin="$(cat .ruby-version 2>/dev/null)"
  rb_have="$(ruby -e 'print RUBY_VERSION' 2>/dev/null)"
  fix="ok"; [ -n "$rb_pin" ] && [ "$rb_have" != "$rb_pin" ] && { bad; fix="asdf install ruby $rb_pin, run from the repo dir"; }
  row ruby "${rb_pin:-none}" "-" "${rb_have:-none}" "$fix"
fi

# Repo quirks that are not versions: tab separated `<basename glob>\t<note>` lines in the private overlay.
echo
base="$(basename "$root")"
for notes in "$notes_dir"/*/facts/engineering-standards-toolchain-notes.tsv; do
  [ -r "$notes" ] || continue
  while IFS=$'\t' read -r glob note; do
    # shellcheck disable=SC2254
    case "$base" in $glob) echo "note: $note" ;; esac
  done < "$notes"
done
[ $mismatches -eq 0 ] && { echo "toolchain: matches"; exit 0; }
echo "toolchain: $mismatches mismatch(es), apply the fix column in this shell before running anything"
exit 1
