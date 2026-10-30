# session-start

| | |
|---|---|
| Type | process |
| Scope | global (every repo) |
| Source | [`skills/global/session-start/SKILL.md`](../../../skills/global/session-start/SKILL.md), version 3.1.0 |
| Run by | the director, before orchestration step 0 |

## What it is for

The ritual that opens every session: know where we are, load what was already decided, start the clock, say
hello as Beam, and get to work in the same reply (SKILL.md lines 13 to 16). It carries no workflow past the
summary; a ticket goes on into orchestration.

## When to use it, and when not

Use it on the first message of a session, a task or not; after a compaction or a continued session; when he
says "load context", "where were we", "resume", "recover the last session" (lines 18 to 22).

Do not use it to write the handoff or the record, or to start a ticket: both are orchestration (lines 24 to 27).

## Who runs it and its place in orchestration

The director, before step 0. [`CLAUDE.md`](../../../harness/CLAUDE.md) rule 1 makes it the first action of a
session; Pipeline row 7 hands a ticket to orchestration step 0.

## Pipeline, short (lines 69 to 77)

1. Run `scripts/session-context.sh` (read-only): the `Project:` and `Branch:` lines.
2. Read the files it lists, newest first: STATE.md, the newest handoff, ORCHESTRA.md, the last time entry; list the workspace folder and open each mockup or image.
3. Load the project rule that `references/project-map.md` names.
4. For "continue" or "recover": find the spec or plan, name the thread in one line and confirm.
5. Start time tracking (`references/time-tracking.md`).
6. Print the summary with a greeting invented for the moment (`references/beam-ascii.md`).
7. Handle his request in the same reply.

## Scripts

- `scripts/session-context.sh`: detects the project from the cwd and lists the workspace files to read.
- `scripts/day-summary.py`: the day's time entries, per project.

## Key laws (lines 37 to 43)

1. The first reply holds the summary and the answer to his request.
2. The project comes from `session-context.sh`, never a guess.
3. The last session is never read from git log, the newest file or a compaction summary.
4. Every artifact in the workspace folder is opened before a question is asked.
5. A status list comes from the newest workspace docs plus git.
6. The ASCII is invented for this moment and project, 0 unicode emoji.
7. The ASCII is never on the first line of the reply.

## Handoffs

- To orchestration step 0 for any ticket.
- The post-compact hook ([`harness/hooks/post-compact.py`](../../../harness/hooks/post-compact.py)) prints the protocol, the orchestration skill, the Score and the handoff tail; this skill then reads the whole files.

## Best practices, from its Gotchas (lines 89 to 100)

- Trust the script's `project:` line; a sibling folder with a similar name was loaded once by guess.
- Rebuild the thread from prompts, spec, handoff and code, never from git log alone.
- PROMPT-LOG.md and dated handoffs are the durable record; session logs rot.
- Open every artifact in the folder before asking about a mockup.
- Set `TRACK_PROJECT`, or hours land in `_global/`.

## Red flags (lines 47 to 56)

"He only wrote a task, the summary can wait", "Git log shows the last thing we did", "I read the .md files,
that is the folder", "The greeting goes first".

## Evals

Trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
scenarios S1, T1 and S2 in the Evals section (lines 162 to 170), prompts in `scenarios.py`.
