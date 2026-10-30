# The harness

The harness is everything around the skills that makes a Claude Code session behave the same way every time:
the rules injected on every prompt, the hooks that fire on session events, the status line, two mods, and the
five goldfish agents. Every file named here is copied under [`harness/`](../harness) (the live copies sit in
`~/.claude`), except the push gate and the agents, which already live in this repo. The wiring is
[`harness/settings.example.json`](../harness/settings.example.json), the live `~/.claude/settings.json` with every
env value replaced by a placeholder.

To install on a machine: `harness/install.sh --dry-run` prints what it would do; without the flag it links every
skill and agent into `~/.claude`, skipping any name that already exists, and copies the hooks, protocol and
report check there, saving a `<file>.bak.<time>` of any file it replaces. It never writes `settings.json` or a
`CLAUDE.md`; merge the examples by hand.

## Contents

- [What fires when](#what-fires-when)
- [protocol.txt](#protocoltxt)
- [CLAUDE.md](#claudemd)
- [UserPromptSubmit: the skill router](#userpromptsubmit-the-skill-router)
- [SessionStart compact: post-compact.py](#sessionstart-compact-post-compactpy)
- [PreToolUse: usage guard](#pretooluse-usage-guard)
- [PreToolUse: push gate](#pretooluse-push-gate)
- [Stop: the report check](#stop-the-report-check)
- [Status line](#status-line)
- [Mods](#mods)
- [Agents](#agents)
- [Plugins, env and permissions](#plugins-env-and-permissions)
- [Not wired](#not-wired)

## What fires when

| Event (settings.json) | Matcher | Command | Timeout | Effect |
|---|---|---|---|---|
| SessionStart | `startup\|resume\|clear` | `cat ~/.claude/protocol.txt` | | the rules enter the context |
| SessionStart | `compact` | `python3 ~/.claude/hooks/post-compact.py` | | the files to resume from enter the context |
| UserPromptSubmit | | `cat ~/.claude/protocol.txt` | | the rules again, on every prompt |
| UserPromptSubmit | | `~/.claude/hooks/skill-router.py` | 5 s | one `SKILL CHECK:` line |
| PreToolUse | `*` | `~/.claude/usage-guard.sh` | 5 s | blocks every tool at the usage stop line |
| PreToolUse | `Bash` | `skills/global/ship/scripts/push-gate.sh` | 20 s | blocks a `git push` with no green gate stamp |
| Stop | | `~/.claude/stop-report-format.sh` | 60 s | refuses a turn whose report is out of shape |
| statusLine | | `~/.claude/usage-statusline.sh` | refresh 30 s | shows usage, saves the readings the guard uses |

Source: the `hooks` and `statusLine` objects of `settings.example.json`.

## protocol.txt

[`harness/protocol.txt`](../harness/protocol.txt), 22 lines, "only what no skill can hold". Printed at session
start and on every prompt, so it survives a compaction and every long thread.

- Rule 0 (lines 3 to 5): orchestration is the base for every development task.
- Rule 0b (lines 6 to 9): SKILL CHECK first; the router line names candidates; else read the top of `SKILLS.md`.
- Rule 1 (lines 10 to 11): do what he asked, as he worded it; check each of his sentences against what he will see.
- Rule 2 (line 12): answer first, plain words.
- Rule 3 (lines 13 to 17): local commits are free (by path, his voice, no Co-Authored-By); nothing leaves the machine without his yes; standing permissions in ship.
- Rule 4 (lines 18 to 19): no em or en dashes; all code in his repos is ours.
- Rule 5 (lines 20 to 22): Claude context lives in `.claude-workspace/<project>/`, never in a repo or an auto-memory file.

## CLAUDE.md

[`harness/CLAUDE.md`](../harness/CLAUDE.md) is the copy of the `CLAUDE.md` in the folder that holds all the
projects. It names the assistant (Beam), points at the skills and `SKILLS.md`, and sets four habits:
orchestration as base (rule 0), session-start on the first message (rule 1), SKILL CHECK on every task (rule 2),
and corrections into the owning skill, never a memory file, a hook or CLAUDE.md (rule 3).

## UserPromptSubmit: the skill router

[`harness/hooks/skill-router.py`](../harness/hooks/skill-router.py) reads every `~/.claude/skills/*/SKILL.md`
frontmatter on each prompt and prints one line.

- **Table.** `metadata.triggers` are lowercase phrases; a trailing `*` marks a stem. `metadata.root` limits a project skill to its repo folders; `metadata.always: true` lists that project skill on every prompt under its root (docstring, lines 4 to 9; `load`, `in_scope`).
- **Order.** Project skills first, then globals; longer phrase matches rank higher; at most 6 names (`MAX_HITS`).
- **Hand rows** (`HAND`): "release" or "tag" for ship, any URL or YouTube link for research, a ticket code like `C38` for orchestration, film words for motion-video.
- **Review.** A prompt that asks for a review goes first to skill-craft when it says "skill", to ui when it names a screen word, else to review (`review_skill`).
- **The line.** When orchestration matched, or a work verb (fix, build, add, continue...) or a ticket code sits next to a development skill, the line says orchestration is the workflow and lists the rest. With no match it says to read the top of `SKILLS.md`. Otherwise it lists the skills to invoke (`line`).
- **Off switch.** `SKILL_ROUTER_OFF` set, or PyYAML missing, prints nothing; task notifications are skipped (`main`).

## SessionStart compact: post-compact.py

[`harness/hooks/post-compact.py`](../harness/hooks/post-compact.py) runs after a compaction. It prints, in
order: a "POST COMPACTION" header telling the director to re-read ORCHESTRA.md and the handoff and check every
running agent; the whole `protocol.txt`; the whole orchestration `SKILL.md`; the Score section of the project's
`ORCHESTRA.md` (up to 60 lines); and the last 40 lines of `HANDOFF-CURRENT.md`. The project is the first folder
under `projects/` in the cwd. This is orchestration Gotchas row "After a compaction the director works from the
summary".

## PreToolUse: usage guard

[`harness/usage-guard.sh`](../harness/usage-guard.sh) runs before every tool call, the session's and every
subagent's. It reads the plan usage the status line saved (this session's own file first) and ignores a reading
from a window that already reset. Today's thresholds in code: 5-hour window stop at 100, warn at 95; weekly
window stop at 100, warn at 99 (`check_window` calls, lines 40 and 43). At the stop line it denies the call with
"HARD STOP"; at the warn line it adds a warning to the context.

## PreToolUse: push gate

[`skills/global/ship/scripts/push-gate.sh`](../skills/global/ship/scripts/push-gate.sh) runs before every Bash
call. When the command holds a `git push`, every commit it would send must have a stamp
`~/.claude/push-gate/<repo>@<sha>`, which only `ship/scripts/pre-deploy.sh` writes after every gate of the repo's
profile passed on a clean tree. No stamp: exit 2 with the command to run. It enforces ship law 2; his yes for the
push is still needed (ship law 1). `push-gate.sh --check <repo>` gives the same answer from a terminal.

## Stop: the report check

[`harness/stop-report-format.sh`](../harness/stop-report-format.sh) with
[`harness/report-format-check.py`](../harness/report-format-check.py) and
[`harness/report-format.md`](../harness/report-format.md). When a turn ends in a git repo with changed files
(images and `docs/renders/` do not count), it checks the last assistant message:

- a standup (first line `Working on:`) has 3 to 6 lines and at most one `Waiting on you:` line;
- a full report (a `## What changed` heading) has `## How to QA`, and each question card under `## Questions for you` carries "Why it matters" and "My recommendation";
- no message has an em or en dash;
- a message in neither shape passes the shape checks.

On a failure it exits 2 and prints the two shapes. The same change set never blocks twice (fingerprint in
`.git/.stop-report-format-seen`), and it stays quiet when the stop hook is already active. This is
orchestration law 18.

## Status line

[`harness/usage-statusline.sh`](../harness/usage-statusline.sh) runs every 30 seconds. It saves the
`rate_limits` Claude Code passes it to `~/.claude/usage-state.json` and a per-session copy, which the usage guard
reads, and prints the 5-hour and weekly usage with the reset time.

## Mods

Two mods load through `CLAUDE_CODE_PLUGIN_DIRS`; their sources are in [`harness/mods/`](../harness/mods). The
generated `.claude-plugin/types` folder of each is not copied.

- **agents-live** (`hooks/register.tsx`): a live pane with what each background agent is saying and running.
- **token-guard** (`hooks/register.ts`): a live token meter in the status line, plan-limit alerts, and compactions that keep the working state.

Each has a `tests/` folder and its description in `.claude-plugin/plugin.json`.

## Agents

[`agents/`](../agents) holds five read-only reviewers, linked into `~/.claude/agents/`: tools Read, Grep and Glob,
`omitClaudeMd: true`, so each knows only the files in its brief. The director sends all lenses in one message at
the end of orchestration step 2 (codebase and concept also at step 10). Each starts from reject: a point passes
only from a line it can quote.

| Agent | Reads | Asks |
|---|---|---|
| `goldfish-comprehension` | the spec only, never his words | can the doc be understood alone |
| `goldfish-critic` | spec, `plan.md`, his words, named docs | what is missing, contradictory, more than asked, already built |
| `goldfish-concept` | the spec or result, its concept art folder, the rubric the brief names | does the doc or build match the approved pictures |
| `goldfish-codebase` | `plan.md`, the repo, the expert skill | is every claim about today's code true |
| `goldfish-readiness` | `plan.md` | can a builder start each task with no decision left |

Source: each agent's frontmatter and the Goldfish section of
[`orchestration/references/critic.md`](../skills/global/orchestration/references/critic.md).

## Plugins, env and permissions

- Plugins the example enables, the ones the skills call: superpowers, frontend-design and code-review, all from the official marketplace. Optional, turned on only when you use the service: github, gitlab, playwright, sentry, stripe, firebase, code-simplifier, claude-md-management, explanatory-output-style, skill-creator. Each plugin you enable can add tools and hooks to every session, so turn on only the ones you use.
- `CLAUDE_WORKSPACE`: the folder for records, plans and reports, outside every repo (default `~/.claude-workspace`).
- Env names: `CLAUDE_CODE_DISABLE_TERMINAL_TITLE`, `CLAUDE_CODE_PLUGIN_DIRS` (the two mods), `CLAUDE_CODE_AUTO_COMPACT_WINDOW`; values are placeholders in the example.
- Permissions allow Read, Glob and Grep without a prompt. Effort level medium.

## Not wired

- [`orchestration/scripts/builder-gate.sh`](../skills/global/orchestration/scripts/builder-gate.sh) is written as a SubagentStop hook (a player that edited files does not stop until check-diff, the quick gate and check-report pass), but `settings.json` has no SubagentStop entry today. When wired, it runs a repo's own `bin/standards` only for a repo whose path is a line in `~/.claude/builder-gate-trusted` (or the file `BUILDER_GATE_TRUSTED` names); every other repo gets only the generic checks.
