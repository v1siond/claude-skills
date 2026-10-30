#!/usr/bin/env bash
# Run a snippet the post claims runs, and print it as it printed, for a text block under an "Output" line.
#
#   run-snippet.sh <workdir> -- <command...>
#
# Prints "$ <command>", then stdout and stderr interleaved as they came, then "exit <code>". Writes nothing
# itself; the command must not write a database, reach the network or deploy (blog making.md).
set -uo pipefail
[ $# -ge 3 ] && [ "$2" = "--" ] || { sed -n 2,8p "$0"; exit 2; }
dir=$1; shift 2
cd "$dir" || exit 2
printf '$ %s\n' "$*"
"$@" 2>&1
code=$?
printf 'exit %s\n' "$code"
