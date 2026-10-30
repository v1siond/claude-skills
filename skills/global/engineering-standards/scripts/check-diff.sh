#!/usr/bin/env bash
# Count the lines a change adds that break a zero rule of engineering-standards (laws 1, 8, 9, 10, 11). Read only.
#
#   check-diff.sh <repo-dir> <start sha>   untracked files count as added
#
# <start sha> is the `Start:` line of the report, `git rev-parse HEAD` run before the first edit (Pipeline step 1),
# so pieces committed during the work are counted. A base git cannot resolve exits 2. With no base it reads HEAD,
# which sees only uncommitted lines.
#
# Prints each hit as file: line under its rule, then one count line per rule.
# Pass: every count is 0 (exit 0). Exit 1 on any hit; a hit kept on purpose is named in the report with its reason
# (an Elixir `with ... else` that reshapes an error, a `style` that only sets a CSS variable).
set -uo pipefail

dir="$(cd "${1:-$PWD}" && pwd)"
base="${2:-HEAD}"
cd "$dir" || exit 2
git rev-parse --verify --quiet "$base^{commit}" >/dev/null || { [ "$base" = HEAD ] && ! git rev-parse --verify --quiet HEAD >/dev/null; } || { echo "bad base: $base"; exit 2; }

added() {
  git diff -U0 "$base" -- . | awk '/^\+\+\+ b\//{f=substr($0,7)} /^\+[^+]/{print f": "substr($0,2)}'
  git ls-files --others --exclude-standard | while read -r f; do
    [ -f "$f" ] && sed "s|^|$f: |" "$f"
  done
}

code='[.](ex|exs|heex|eex|leex|erb|html|ts|tsx|js|jsx|mjs|cjs|mts|cts|vue|svelte|astro|haml|slim|rb|py)$'
lines="$(added)"
total=0
rule() {  # rule <name> <regex over "file: line"> ; file must be code (first field)
  local hits
  hits="$(printf '%s\n' "$lines" | awk -F': ' -v c="$code" '$1 ~ c' | grep -E "$2")"
  local n=0; [ -n "$hits" ] && n="$(printf '%s\n' "$hits" | wc -l)"
  [ "$n" -gt 0 ] && { echo "== $1"; printf '%s\n' "$hits"; }
  echo "$1: $n"
  total=$((total + n))
}

# Law 1: no else block (a guard or a second function clause covers nearly every case).
# One pattern per file type, each matching only an else that opens a block:
#   Elixir, eex, heex, Ruby: a line that starts with `else` (or `<% else`) and ends there, or goes on with do, %> or a #
#     comment. The keyword form `else: 2` (one-line or multi-line `if`) is an expression and is allowed.
#   Python: `else:` at the start of the line. `a if c else b` is allowed.
#   JS, TS, Vue, html: `else` at the start of the line after an optional `}`, or after a `;` on the same line.
#     `c ? a : b` is allowed.
rule "else block" '^[^:]+[.](ex|exs|heex|eex|leex|erb|rb): [[:space:]]*(<%[[:space:]]*)?else\b[[:space:]]*(do\b|%>|#|$)|^[^:]+[.]py: [[:space:]]*else[[:space:]]*:|^[^:]+[.](ts|tsx|js|jsx|mjs|cjs|vue|svelte|html): (([[:space:]]*\}?[[:space:]]*|.*;[[:space:]]*)else\b([^-]|$)|[^/]*[}][[:space:]]*else\b)'
# Law 8: no commented-out code. A comment line whose text is a statement: a definition, a declaration with =,
# a call that ends the line, a return, a pipe, an `if` that opens a block, an assignment, `} else`, or a lone `end`
# or `}`.
rule "commented-out code" '^[^:]+: [[:space:]]*(#|//|/[*]|[{]/[*]|<!--|<%!--|-#|/!)[[:space:]]*(defmodule[[:space:]]+[A-Z]|defp?[[:space:]]+[a-z_]+[?!]?,[[:space:]]*do:|import[[:space:]]+([a-z_]+[[:space:]]+from|["'\''])|[}][[:space:]]*catch\b|[A-Z][A-Za-z0-9_]*[.][a-z_]+[!?]?[[:space:]]+["A-Za-z@:]|[a-z_]+[.][a-z_]+[!?]$|<[.]?[A-Za-z][A-Za-z0-9.]*([[:space:]>/]|$)|defp?[[:space:]]+[a-z_]+[?!]?[(]|(export[[:space:]]+)?(const|let|var)[[:space:]]+[A-Za-z_]+[[:space:]]*=|export[[:space:]]+(default|function|class)\b|import[[:space:]]+([{*]|[A-Z])|(alias|require|use)[[:space:]]+[A-Z][A-Za-z.]*$|await[[:space:]]+[A-Za-z_.]+[(]|throw[[:space:]]+new\b|class[[:space:]]+[A-Z][A-Za-z0-9_]*[[:space:]]*([:({]|$)|@[a-z_]+[[:space:]]+[0-9"%\[{:]|[{][:a-z].*[}][[:space:]]*=[[:space:]]|return(;|[[:space:]]+[^[:space:]]+;?|[[:space:]].*[;)}])$|[A-Za-z_][A-Za-z0-9_.]*[!?]?[(][^)]*[)][[:space:]]*;?([[:space:]]*[*]/)?$|[A-Za-z_][A-Za-z0-9_.]*[(].*([[:space:]]do|->|[{(,])$|end$|[}];?$|[}][[:space:]]*else|[|]>|(if|unless|for|while|case|cond)[[:space:]].*([[:space:]]do|[{]|:)$|[a-z_][A-Za-z0-9_.]*[[:space:]]*([+-]?=)[[:space:]]*[^=[:space:]])'
# Law 9: a comment never carries his name or a quoted prompt (666 lines across 247 files on 09-13).
# His name counts on any line; a prompt phrase counts only inside a comment (#, //, /*, *, <!--, %).
rule "his name or a prompt in code" '^[^:]+: (.*(Alexander|Pulido)|(.*(#|//|/\*|<!--)|[[:space:]]*(\*|%)).*(\bAlex\b|as requested|he asked|he said|he wants|his words|per his|the user (asked|wants|said|requested)|user.s request|[Pp]rompt:))'
# Law 10: no inline style; Tailwind first, ITCSS files for the rest.
rule "inline style" ':.*([^-]style=[{"'\'']|:style=|[.]style[.][A-Za-z]+[[:space:]]*=[^=]|setAttribute[(].style|assign[(][^,]*[.]style[[:space:],])'
# Law 11: a lint or type check is fixed, never muted, unless he said yes.
rule "muted check" ':.*(credo:disable|eslint-disable|rubocop:disable|@ts-ignore|@ts-nocheck|@ts-expect-error|#[[:space:]]*noqa|type:[[:space:]]*ignore|pylint: disable|biome-ignore|prettier-ignore|sobelow_skip|nowarn_function)'

echo "total: $total"
[ "$total" -eq 0 ]
