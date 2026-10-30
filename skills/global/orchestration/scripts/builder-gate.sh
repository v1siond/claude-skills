#!/usr/bin/env bash
#
# SUBAGENTSTOP HOOK. The builder gate (orchestration law 7 run by a machine): a player that edited files in a
# git repo does not stop until its own lines pass check-diff, the repo's quick gate and check-report.
# Exit 2 keeps the subagent running and hands it stderr as its next instruction. Read only on every repo.
#
#   builder-gate.sh < SubagentStop hook JSON
#
# INSTALL, in the "hooks" object of ~/.claude/settings.json (no matcher, so every agent type is read):
#
#   "SubagentStop": [ { "hooks": [ { "type": "command", "timeout": 180,
#       "command": "<path to this repo>/skills/global/orchestration/scripts/builder-gate.sh" } ] } ]
#
# Exits 0 at once when stop_hook_active is true, when the transcript is missing, when the agent made no
# Write, Edit, MultiEdit or NotebookEdit call (and no commit) on a file inside a git repo outside
# .claude-workspace, and once an agent was blocked 2 times or this failure set was already blocked.
#
# For a builder, per repo it edited:
#   start   the HEAD at its first edit (git rev-list --before the edit's timestamp); when it committed, the
#           merge base of that and its first commit minus one, so committed pieces are counted.
#   gates   check-diff.sh <repo> <start>, hits kept only for the files it edited, each with file:line, the
#           law and the fix; then bin/standards --quick when the repo has it and is listed in $BUILDER_GATE_TRUSTED; then check-report.sh on
#           last_assistant_message (or the transcript's last text when that is empty).
# Every run is one JSONL line in $BUILDER_GATE_LOG. Block state per agent lives in $BUILDER_GATE_STATE.
set -uo pipefail

SKILLS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECK_DIFF="$SKILLS/engineering-standards/scripts/check-diff.sh"
CHECK_REPORT="$SKILLS/engineering-standards/scripts/check-report.sh"
LOG="${BUILDER_GATE_LOG:-$HOME/.claude/builder-gate.jsonl}"
# bin/standards runs only in a repo listed here, one absolute repo root per line: a hook runs outside every
# permission prompt, so a cloned repo's own script never runs on its say-so.
TRUSTED="${BUILDER_GATE_TRUSTED:-$HOME/.claude/builder-gate-trusted}"
STATE="${BUILDER_GATE_STATE:-$HOME/.claude/builder-gate-state}"
MAX_BLOCKS=2

# A repo's own .git/config never runs a command here: core.fsmonitor would on status.
git() { command git -c core.fsmonitor=false "$@"; }

INPUT="$(cat)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
printf '%s' "$INPUT" >"$WORK/input.json"

# log <result> <reason>: one JSONL line from the run's fields in $WORK.
log() {
  python3 - "$WORK" "$1" "$2" >>"$LOG" 2>/dev/null <<'PY'
import json, os, sys, datetime
work, result, reason = sys.argv[1:4]
def read(name, default):
    p = os.path.join(work, name)
    return json.load(open(p)) if os.path.exists(p) else default
inp = read("input.json", {})
print(json.dumps({
    "ts": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
    "agent_id": inp.get("agent_id", ""),
    "agent_type": inp.get("agent_type", ""),
    "result": result,
    "reason": reason,
    "repos": read("repos.json", []),
}))
PY
}

read -r ACTIVE AGENT_ID TRANSCRIPT <<<"$(python3 - "$WORK/input.json" <<'PY' 2>/dev/null || echo "False - -"
import json, os, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    d = {}
t = d.get("agent_transcript_path") or d.get("transcript_path") or "-"
print(d.get("stop_hook_active", False), d.get("agent_id") or "-", os.path.expanduser(t))
PY
)"

# Without this the agent can never stop: the block would re-trigger itself.
[ "$ACTIVE" = "True" ] && { log pass "stop_hook_active"; exit 0; }
[ -f "$TRANSCRIPT" ] || { log pass "no transcript"; exit 0; }

# THE AGENT'S EDITS, per repo: files from its edit tools and from the commits it made, the timestamp of its
# first edit there, its commits in order, and its last text. Writes $WORK/edits.json.
python3 - "$TRANSCRIPT" "$WORK" <<'PY'
import json, os, re, subprocess, sys
transcript, work = sys.argv[1:3]
EDIT_TOOLS = {"Write": "file_path", "Edit": "file_path", "MultiEdit": "file_path", "NotebookEdit": "notebook_path"}
SHA = re.compile(r"\b[0-9a-f]{7,40}\b")

def git(repo, *args):
    r = subprocess.run(["git", "-c", "core.fsmonitor=false", "-C", repo, *args], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else ""

def repo_of(path):
    d = os.path.dirname(path)
    while d and not os.path.isdir(d):
        d = os.path.dirname(d)
    return git(d, "rev-parse", "--show-toplevel") if d else ""

repos, commit_calls, last_text = {}, {}, ""

def add(path, ts):
    if not path or "/.claude-workspace/" in path:
        return
    path = os.path.abspath(os.path.expanduser(path))
    repo = repo_of(path)
    if not repo:
        return
    r = repos.setdefault(repo, {"files": [], "first_ts": ts, "commits": []})
    rel = os.path.relpath(path, repo)
    if rel not in r["files"]:
        r["files"].append(rel)

for line in open(transcript, errors="replace"):
    try:
        d = json.loads(line)
    except Exception:
        continue
    content = (d.get("message") or {}).get("content")
    if not isinstance(content, list):
        continue
    ts, cwd = d.get("timestamp", ""), d.get("cwd", "")
    for c in content:
        kind = c.get("type")
        if d.get("type") == "assistant" and kind == "text" and c.get("text", "").strip():
            last_text = c["text"]
        if kind == "tool_use" and c.get("name") in EDIT_TOOLS:
            add((c.get("input") or {}).get(EDIT_TOOLS[c["name"]], ""), ts)
        if kind == "tool_use" and c.get("name") == "Bash" and re.search(r"\bgit\b.*\bcommit\b", (c.get("input") or {}).get("command", ""), re.S):
            commit_calls[c.get("id")] = (c["input"]["command"], cwd, ts)
        if kind == "tool_result" and c.get("tool_use_id") in commit_calls:
            command, cwd, ts = commit_calls.pop(c["tool_use_id"])
            out = c.get("content")
            out = out if isinstance(out, str) else " ".join(x.get("text", "") for x in out or [] if isinstance(x, dict))
            repo = git(cwd or ".", "rev-parse", "--show-toplevel")
            if not repo or "/.claude-workspace/" in repo + "/":
                continue
            for sha in SHA.findall(out):
                full = git(repo, "rev-parse", "--verify", "--quiet", sha + "^{commit}")
                subject = git(repo, "log", "-1", "--format=%s", full) if full else ""
                # Its own commit: the subject it wrote is in the command it ran.
                if not subject or subject[:40] not in command:
                    continue
                r = repos.setdefault(repo, {"files": [], "first_ts": ts, "commits": []})
                if full in r["commits"]:
                    continue
                r["commits"].append(full)
                for f in git(repo, "show", "--name-only", "--format=", full).splitlines():
                    if f and f not in r["files"]:
                        r["files"].append(f)

json.dump({"repos": repos, "last_text": last_text}, open(os.path.join(work, "edits.json"), "w"))
PY

N_REPOS="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["repos"]))' "$WORK/edits.json" 2>/dev/null || echo 0)"
[ "$N_REPOS" -gt 0 ] || { log pass "not a builder: no repo edits"; exit 0; }

# The agent's final message, for check-report.
python3 - "$WORK" <<'PY'
import json, os, sys
work = sys.argv[1]
msg = json.load(open(os.path.join(work, "input.json"))).get("last_assistant_message") or ""
msg = msg if msg.strip() else json.load(open(os.path.join(work, "edits.json")))["last_text"]
open(os.path.join(work, "report.md"), "w").write(msg)
PY

# Law and fix per check-diff rule (engineering-standards SKILL.md laws 1, 8, 9, 10, 11).
fix_for() {
  case "$1" in
    "else block") echo "engineering-standards law 1|Move the else branch into a second function clause with a when guard, or return early; a with ... else that reshapes an error may stay, named on the Self-read line." ;;
    "commented-out code") echo "engineering-standards law 8|Delete the commented-out line; git history keeps it." ;;
    "his name or a prompt in code") echo "engineering-standards law 9|Rewrite the comment to say why the code does this; drop his name and any quoted prompt." ;;
    "inline style") echo "engineering-standards law 10|Move the style into Tailwind classes or the ITCSS file; a style that only sets a CSS variable may stay, named in the report." ;;
    "muted check") echo "engineering-standards law 11|Fix the lint or type finding and remove the disable comment; it stays only with his yes in the thread." ;;
    *) echo "engineering-standards|Fix the line." ;;
  esac
}

FEEDBACK="$WORK/feedback.txt"
: >"$FEEDBACK"
echo '[]' >"$WORK/repos.json"
FAILED=0

python3 -c 'import json,sys; [print(k) for k in json.load(open(sys.argv[1]))["repos"]]' "$WORK/edits.json" >"$WORK/repo-list"
while read -r REPO; do
  # START: the HEAD at its first edit, pulled back to before its first commit when it committed.
  read -r FIRST_TS FIRST_COMMIT <<<"$(python3 -c 'import json,sys; r=json.load(open(sys.argv[1]))["repos"][sys.argv[2]]; print(r["first_ts"] or "-", (r["commits"] or ["-"])[0])' "$WORK/edits.json" "$REPO")"
  START=""
  [ "$FIRST_TS" != "-" ] && START="$(git -C "$REPO" rev-list -1 --first-parent --before="$FIRST_TS" HEAD 2>/dev/null)"
  if [ "$FIRST_COMMIT" != "-" ]; then
    PARENT="$(git -C "$REPO" rev-parse --verify --quiet "$FIRST_COMMIT^" 2>/dev/null)"
    START="$([ -n "$START" ] && [ -n "$PARENT" ] && git -C "$REPO" merge-base "$START" "$PARENT" 2>/dev/null || echo "${START:-$PARENT}")"
  fi
  START="${START:-HEAD}"

  python3 -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["repos"][sys.argv[2]]["files"]))' "$WORK/edits.json" "$REPO" >"$WORK/files"

  # GATE 1: check-diff from the start, hits kept only for the files this agent edited.
  bash "$CHECK_DIFF" "$REPO" "$START" >"$WORK/diff.out" 2>&1
  DIFF_EXIT=$?
  : >"$WORK/hits"
  RULE=""
  while IFS= read -r LINE; do
    case "$LINE" in
      "== "*) RULE="${LINE#== }"; continue ;;
      *": "[0-9]*|"total: "*) [[ "$LINE" =~ ^[a-z\ -]+:\ [0-9]+$ ]] && { RULE=""; continue; } ;;
    esac
    [ -n "$RULE" ] || continue
    FILE="${LINE%%: *}"
    grep -qxF -- "$FILE" "$WORK/files" || continue
    TEXT="${LINE#*: }"
    NUM="$(grep -nxF -- "$TEXT" "$REPO/$FILE" 2>/dev/null | head -1 | cut -d: -f1)"
    IFS='|' read -r LAW FIX <<<"$(fix_for "$RULE")"
    printf '%s:%s %s (%s). %s\n' "$FILE" "${NUM:-?}" "$RULE" "$LAW" "$FIX" >>"$WORK/hits"
  done <"$WORK/diff.out"
  HITS="$(grep -c . "$WORK/hits" || true)"
  DIFF_STATUS=pass
  [ "$DIFF_EXIT" -eq 2 ] && DIFF_STATUS=error
  [ "$HITS" -gt 0 ] && DIFF_STATUS=fail

  # GATE 2: the repo's quick gate, when it has one and the repo is on the trusted list.
  QUICK_STATUS=skip
  if [ -x "$REPO/bin/standards" ] && grep -qxF -- "$REPO" "$TRUSTED" 2>/dev/null; then
    QUICK_STATUS=pass
    (cd "$REPO" && timeout 120 bin/standards --quick) >"$WORK/quick.raw" 2>&1 || QUICK_STATUS=fail
    sed 's/\x1b\[[0-9;]*m//g' "$WORK/quick.raw" >"$WORK/quick.out"
  fi

  # GATE 3: check-report on its final message.
  REPORT_STATUS=skip
  if [ -s "$WORK/report.md" ]; then
    bash "$CHECK_REPORT" "$WORK/report.md" >"$WORK/report.out" 2>&1 && REPORT_STATUS=pass || REPORT_STATUS=fail
  fi

  {
    [ "$DIFF_STATUS" = fail ] && {
      echo "check-diff.sh $REPO $START: $HITS hit(s) in lines you added (first 20):"
      head -20 "$WORK/hits"
      echo
    }
    [ "$DIFF_STATUS" = error ] && {
      echo "check-diff.sh $REPO $START could not run (first 20 lines):"
      head -20 "$WORK/diff.out"
      echo
    }
    [ "$QUICK_STATUS" = fail ] && {
      echo "bin/standards --quick in $REPO failed (engineering-standards law 11, fix each finding, never mute it). Lines that matter:"
      grep -E 'FAIL|^       ' "$WORK/quick.out" | head -20
      echo
    }
    [ "$REPORT_STATUS" = fail ] && {
      echo "check-report.sh on your final message: $(tr '\n' ' ' <"$WORK/report.out")"
      echo "Add a line 'Reused: <file:line you reused>' or 'Reused: none, searched <grep command>' (engineering-standards law 4, check 4) to your final report."
      echo
    }
  } >>"$FEEDBACK"
  [ "$DIFF_STATUS" != pass ] || [ "$QUICK_STATUS" = fail ] || [ "$REPORT_STATUS" = fail ] && FAILED=1

  python3 - "$WORK/repos.json" "$REPO" "$START" "$DIFF_STATUS" "$HITS" "$QUICK_STATUS" "$REPORT_STATUS" "$WORK/files" "$WORK/report.out" <<'PY'
import json, os, sys
path, repo, start, diff, hits, quick, report, files, report_out = sys.argv[1:10]
counts = dict(l.split(": ", 1) for l in open(report_out).read().splitlines() if ": " in l) if os.path.exists(report_out) else {}
rows = json.load(open(path))
rows.append({"repo": repo, "start": start, "files": len(open(files).read().split()),
             "gates": {"check-diff": diff, "standards-quick": quick, "check-report": report},
             "counts": {"diff_hits": int(hits), **{k: int(v) for k, v in counts.items() if v.isdigit()}}})
json.dump(rows, open(path, "w"))
PY
  rm -f "$WORK/report.out"
done <"$WORK/repo-list"

[ "$FAILED" -eq 0 ] && { log pass "gates green"; exit 0; }

# LOOP GUARD: the same failure set blocks once more at most, and an agent is blocked 2 times at most.
mkdir -p "$STATE"
SEEN="$STATE/$AGENT_ID"
FINGERPRINT="$(md5sum <"$FEEDBACK" | cut -d' ' -f1)"
touch "$SEEN"
BLOCKS="$(grep -c . "$SEEN")"
SAME="$(grep -cxF "$FINGERPRINT" "$SEEN")"
[ "$BLOCKS" -ge "$MAX_BLOCKS" ] && { log fail-released "blocked $BLOCKS times already"; exit 0; }
[ "$SAME" -ge 2 ] && { log fail-released "same failure set blocked twice"; exit 0; }
echo "$FINGERPRINT" >>"$SEEN"

{
  echo "BUILDER GATE. Your lines do not pass the gates yet (orchestration law 7, engineering-standards). Fix each, commit by path, then finish with the report:"
  echo
  cat "$FEEDBACK"
  echo "Block $((BLOCKS + 1)) of $MAX_BLOCKS. A hit kept on purpose is named in the report with its reason."
} | sed 's/No such file or directory/file not found/g' >&2   # that phrase makes Claude Code read exit 2 as a broken hook
log block "block $((BLOCKS + 1)) of $MAX_BLOCKS"
exit 2
