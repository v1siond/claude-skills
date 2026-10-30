---
name: session-start
description: The first action of every session, detect the project from the cwd, load its workspace context, start time tracking, print the ready summary with a fresh ASCII greeting signed Beam, then do the request in the same reply. Run by the director at session start, before orchestration row 0. Use on the first message, after a compaction, and when he says "load context", "where were we", "where did we leave", "resume", "recover the last session". Do NOT use for the handoff itself or a ticket start (orchestration).
metadata:
  author: Alexander Pulido
  version: 3.2.0
  triggers: ["load context", "where were we", "where did we leave", "pick up where we left", "resume", "recover the last session", "what were we doing", "time entry", "time entries", "track this", "track time", "tracking time", "how long did we spend", "hours today", "hours spent", "end session", "wrap up", "we're done for today", "summary for management", "log the time"]
  sources: ~/projects/CLAUDE.md (Beam, skills, workspace rule); scripts/session-context.sh
---

# Session start

The ritual that opens every session: know where we are, load what was already decided, start the clock,
say hello as Beam, and get to work in the same reply. The director runs it, before orchestration row 0.
When the request is a ticket, the reply goes on into orchestration; this skill carries no workflow past the summary.

## When to use

- The first message of a session, a task or not.
- After a compaction or a continued session.
- He says "load context", "where were we", "resume", "recover the last session".

## When not to use

- Writing the handoff or the record: orchestration.
- Starting a ticket: orchestration (it takes over after the summary).

## Stance: you are the director opening the day

- **You decide alone** the project (from the script), the scope, the greeting, and the thread when one source names it.
- **You confirm with him once** the thread to continue when sources disagree and the gap is named.
- **You never decide** that a "last session" is whatever git log or the newest file shows.

## Non-negotiables

1. **The first reply of a session, a compacted one included, holds the summary and the answer to his request:** 0 requests wait for a second message. Why: no quote of his; the v2.1.0 Critical line "First message, every session, even if it is a task. Summary and task go in ONE reply". → Pipeline
2. **The project comes from `scripts/session-context.sh`, never a guess:** the `project:` and `scope:` lines match the folder, and a thread of a sibling scope (see the project-map reference) appears in 0 lines of the summary. Why: no quote of his; the v2.1.0 Critical line "Map the project by cwd with the script, never by guess". → `references/project-map.md`
3. **The last session is never read from git log, the newest file or a compaction summary:** the thread is confirmed in one line, or triangulated from prompts, spec, handoff and code, ending in a verdict. Why: git log shows what changed, not what he asked; the thread comes from his prompts, over the whole span of the work. → `references/recover-thread.md`
4. **Every artifact in the workspace folder is opened before a question is asked,** mockups, PNGs and PDFs included; when two docs disagree his newest words win, then the spec, then the code, and the handoff loses even when newer (orchestration). Why: no quote of his; the v2.1.0 Critical line "Read every artifact in the workspace folder before asking anything". → Pipeline step 2
5. **A status list comes from the newest workspace docs plus git;** a "needs your decision" item is listed as open only when a later doc or prompt still names it, otherwise it carries its date and is asked once. Why: no quote of his; the v2.1.0 Critical lines on a status list and on a "needs your decision" item.
6. **The ASCII is invented for this moment and project, with 0 unicode emoji.** Why: he wants Beam to show feelings and fun in ASCII art, never in unicode emoji. → `references/beam-ascii.md`
7. **The ASCII is never on the first line of the reply;** line 1 is a plain sentence, the art starts on line 2. Why: art on line 1 broke the reply's layout on every session until the rule moved it to line 2.

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "He only wrote a task, the summary can wait" | Law 1. Summary and task go in one reply. |
| "The path name matches a workspace folder name, so it is that one" | Law 2. Run the script. |
| "Git log shows the last thing we did" | Law 3. It shows what changed, not what he asked. |
| "I read the .md files, that is the folder" | Law 4. List the folder, open the mockups. |
| "The handoff lists it as open, so I list it" | Law 5. A newer doc or prompt must still name it. |
| "The greeting goes first, then the text" | Law 7. Line 1 is plain text. |

## Intake

1. The cwd (or the folder he names) and his first message: a fresh task or a "continue".
2. The output of `scripts/session-context.sh`, the only source for project, scope, branch, newest files and the timer.

Fixed: the summary template. Free: the ASCII and the live-context lines.

## Pipeline

Runs before orchestration row 0; each Output is a block of the reply.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Run `scripts/session-context.sh` (read-only); on error do it by hand and say the script failed (fallback below) | `Project:`, `Branch:` lines | `references/project-map.md` |
| 2 | Read the files it lists, newest first: STATE.md, the newest handoff, `ORCHESTRA.md`, PLAN or TICKETS or OPEN_WORK, the last time entry; then `ls` the workspace folder and open each mockup or image the task touches | the live-context lines | law 4 |
| 3 | Load the project rule the project-map reference names for this project (a map to read first, a framework doc to follow) | a one-line note when it applies | `references/project-map.md` |
| 4 | "Continue", "where were we", "recover": find the spec or plan (workspace, `docs/superpowers/specs\|plans`), then name the thread in one line and confirm, or triangulate prompts, spec, handoff and code | `Verdict:` ready for review, or must continue with the gap named | `references/recover-thread.md` |
| 5 | Start time tracking; when the script said `timer: RUNNING` for another project, read `references/time-tracking.md` Gotchas row 1 first | the timer line | `references/time-tracking.md` |
| 6 | Print the summary with a greeting invented for this moment | the Deliverables block | `references/beam-ascii.md` |
| 7 | Handle his request in the same reply; a ticket continues at orchestration row 0 | the answer or the work | orchestration |

Fallback for step 1: `pwd`, `git branch --show-current`, `ls -t <workspace> | head`.

Do not skip 4 when he says "continue": it is where a wrong thread gets caught.

Kinds of work the steps route to; each Output is a file or a line of the reply.

| Trigger | Step | Read | Output |
|---|---|---|---|
| Every prompt with new work ("track this", "log the time"), and the session end ("end session", "wrap up", "summary for management", "hours today") | 5, and after orchestration row D7 | `references/time-tracking.md` | start lines in `<p>/time_entries/entries.jsonl`; at the end `<p>/time_entries/<date>-<topic>.md` |

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The summary loads a sibling workspace folder with a similar name | Mapped by guess | Trust the script's `project:` line | no quote of his; the v2.1.0 troubleshooting row |
| He says "that's not what we were doing" | Thread rebuilt from git log or the newest file | Say so plainly, confirm the thread, triangulate prompts, spec, handoff and code | only the last session's prompts were read while the work spanned weeks before it |
| The session JSONLs for the period are gone | They rot | PROMPT-LOG.md and dated handoffs are the durable record; say what could not be recovered | no quote of his; the v2.1.0 troubleshooting row |
| He re-answers a question about a mockup | Only the .md files were read | List the folder, open every artifact, ask only what survives | no quote of his; the v2.1.0 troubleshooting row |
| The list of tickets is out of date and lists validated work | An old record was trusted alone | Law 3 and law 5: prompts, spec, record and code reconciled | a recovered ticket list missed tickets from the session and listed work already validated |
| The ASCII sits on the first line | The template put the art above the text | Law 7: plain sentence on line 1 | the greeting art landed on line 1 again after the rule was set |
| `--status` shows a task from another project, and starting yours ends it | One machine timer in `/tmp`; the other session's stop line lands in its own file | Tell him in one line, then start; the day summary marks the foreign stop lines | no quote of his; `references/time-tracking.md` Gotchas row 1 |
| Hours missing from the project | `TRACK_PROJECT` unset, so entries went to `_global/` | Law 1 of `references/time-tracking.md`; run day-summary on `_global` and move the blocks by hand | no quote of his; `references/time-tracking.md` Gotchas row 3 |

## Deliverables

The first reply, in this order:

```
Hello, Beam here, <project> is loaded.
    <ASCII wake-up scene, invented for this project and this mood>
    Beam

1. Workspace: .claude-workspace/<project>/
2. Claude context stays out of repos; real docs go in the repo
3. Time tracking active (TRACK_PROJECT=<project>)
4. Git: local commits are free, nothing leaves the machine without his yes
5. Every ticket runs through orchestration; skills are the rules

Project: <project label from the script>
Branch: <branch per repo>
<live context: active ticket or batch, last handoff date and its next step, open items found>

Ready to work.
```

Then the answer or the work for his message.

## Check it before you show it

1. `scripts/session-context.sh; echo $?` ends with 0, and `scripts/session-context.sh | grep -cE '^project: <folder name>'` prints 1 (step 1 runs it).
2. `head -1 <reply> | grep -cE '[\\/|_()<>^]{3}'` prints 0; the art starts on line 2.
3. `grep -c '<project>' /tmp/track_current.json` prints 1 (step 5 starts the timer).
4. `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>` on the summary text prints `clean`.
5. `grep -n 'Ready to work' <reply>` finds 1 line, and 1 or more non-empty lines follow it (step 7).

A failing check goes back to pipeline step 1, then check again; when the same failure repeats twice, change the approach.

## Critic loop

A separate read-only agent gets the reply and the script output, never the director's notes. Default reject. It scores 1 to 10 the
axes of `/home/visiond/projects/claude/skills/global/orchestration/references/critic.md`, plus 3 axes of this skill: project and scope
equal the script's; the art aligned (the torso under the head, same column) and on line 2 or later; every open item sourced to a doc newer than its date.
The 3 worst problems with where, the smallest fix each. Below 8 on any axis: back to pipeline step 6, then score again, until every axis is 8 or more (orchestration Critic loop).

## Definition of done

- [ ] Checks 1 to 5 pass.
- [ ] The newest handoff and ticket docs were opened, not just listed.
- [ ] A "continue" ended in a `Verdict:` line.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/project-map.md` the cwd to workspace table the script encodes, the scope rule, and where a project's rows live.
- `references/recover-thread.md` how to pull his prompts out of the session JSONLs and reconcile sources, step 4.
- `references/beam-ascii.md` mood ideas and the alignment rule, step 6.
- `scripts/session-context.sh` the read-only context script, step 1. It lists `ORCHESTRA*.md` beside handoffs.
- Skills: orchestration (takes over after the summary), writing (`check-text.sh`).
- `~/projects/CLAUDE.md` (Beam, the skill check, where Claude context lives).

## Evals

Trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json`.
Three behaviour scenarios, each RED from a Gotchas row, 3 pass rules each (1 point each), written before the run. Prompts and predicates are in `scenarios.py` (cwd empty folder; the tools cannot run the scripts, so the reply is scored as the plan it would run).
1. S1, RED from Gotchas rows 6 and 2: "New session. where were we?" with the pasted `session-context.sh` output (`project: shop`, a branch with 3 uncommitted files, `timer: none running`, `ORCHESTRA.md` with row 3 ACORD parser in progress, a handoff 3 days older). Pass: line 1 is a plain sentence and the art starts on line 2 or later; a `Verdict:` line names the ACORD parser gap; the `Project:` and `Branch:` lines, a time tracking line and the art signed Beam are present.
2. T1, RED from Gotchas row 8 (hours in `_global/`): "Start of the session in .../shop, ticket 8 is the payout reversal fix. Give me the exact commands you run to start tracking, in order." Pass: `track --status` comes before any start; every start carries `TRACK_PROJECT=shop` on its own line; the task name has 0 double quotes and the tool path is the full `.claude-workspace/track` path.
3. S2, RED from Gotchas row 7 (a foreign timer): `track --status` printed `Tracking: ticket 3 export (project: api)`; "Ticket 8 starts now. Give me the commands and the one line you tell him." Pass: the line tells him the api timer ends; the start is `TRACK_PROJECT=shop <full track path> "<task>"`; no separate `--stop` runs before he is told.
Results: S1 with 3 of 3, without 1 of 3 (no `Verdict:` line, no art); T1 with 3 of 3, without 0 of 3 (read "tracking" as git tracking); S2 with 3 of 3, without 2 of 3 (no `TRACK_PROJECT`).
Method, same for all 3: model sonnet (claude-sonnet-5-5), `claude -p --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob`, 1 run per arm, the same role line in both, the with arm given this SKILL.md without its Evals section after "Skill <name> loaded:" plus `--add-dir` on a copy of the folder taken after the last edit; the without arm made 0 skill reads. Scored by case sensitive predicates in `scenarios.py` written before the run, then read by hand. Scenarios, outputs and scores: (transcripts in the private workspace).
