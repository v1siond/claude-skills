# Time tracking, inside session-start

Every prompt is timed against the right project, and every session ends with a summary he can hand to
management. The director runs it: it starts at session-start step 5 and closes the session after the orchestration
of orchestration row D7. It carries no ticket workflow of its own.

## Contents

- Stance: you are the director keeping the clock
- Non-negotiables
- Intake
- Pipeline
- Gotchas

## Stance: you are the director keeping the clock

- **You decide alone** the task names, the project folder (from the session-start script) and the trimming of a long block.
- **You tell him in one line** when starting your timer ends another session's timer.
- **You never decide** that tracking blocks the work: a second failed command is said in the reply and the work goes on.

## Non-negotiables

1. **`TRACK_PROJECT` is set on every call:** `TRACK_PROJECT=<workspace folder> $CLAUDE_WORKSPACE/track "<task>"`; `export TRACK_PROJECT=<workspace folder>` does not survive between Bash calls here, and an unset variable lands the entries in `_global/`. The folder comes from the session-start script. Why: no quote of his; the v2.1.0 troubleshooting row on hours landing in `_global/`. → Pipeline step 2
2. **`track --status` runs before the first start,** because the machine has one timer (`/tmp/track_timer.pid`, `/tmp/track_current.json`) and a new start stops another session's task and writes that stop line into this project's file. Why: no quote of his; the v2.1.0 troubleshooting row on a task from another project.
3. **Task names are plain words with 0 double quotes,** for example `ticket 8: payout reversal fix`; the tool builds its JSON by hand and a `"` writes a line no reader can parse. Why: no quote of his; the v2.1.0 line on the tool's hand-built JSON.
4. **The blocks come from `scripts/day-summary.py`, never `track --summary`,** which pairs starts and ends by task name over the whole file and prints negative totals. Why: no quote of his; the v2.1.0 troubleshooting row on negative minutes.
5. **The time entry is written in the workspace, never the repo:** `<workspace>/<p>/time_entries/`, and `git status --porcelain` in the repo lists 0 of its paths. Why: time entries live in a `time_entries/` folder inside each project folder of the workspace, one per project, never in a repo. → `examples/session-summary.md`
6. **A block flagged `check: long` is trimmed to the last real activity** (last commit, last prompt) and the reply says it was trimmed. Why: no quote of his; the v2.1.0 troubleshooting row on a 6h overnight block.
7. **The time entry is written in his voice:** `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>` prints `clean`. Why: no quote of his; the writing skill, his voice, and the entry is read by management.

Violating the letter of a law is violating the law.

## Intake

1. The project folder name (session-start).
2. The task of each prompt, in a few plain words.
3. At the end: `entries.jsonl` for the day plus what shipped (commits, tickets) for the Delivered list.

Fixed: the tool path, the entries file, the table shape. Free: task wording and Delivered bullets.

## Pipeline

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | `$CLAUDE_WORKSPACE/track --status`; a live task from another project goes to Gotchas row 1 first | `Tracking:` or a clear status | law 2 |
| 2 | Start: `TRACK_PROJECT=<p> $CLAUDE_WORKSPACE/track "session start"`; anything but `Tracking: <task>` is a failure, report its output as is | start line in `entries.jsonl` | law 1 |
| 3 | Each new prompt with new work: `TRACK_PROJECT=<p> $CLAUDE_WORKSPACE/track "<task>"` with the new task name; it stops the previous task. The timer keeps running while players and QA work, since their time counts toward the ticket | one start line per task | law 3 |
| 4 | End: `TRACK_PROJECT=<p> $CLAUDE_WORKSPACE/track --stop` | stop line | |
| 5 | `python3 /home/visiond/projects/claude/skills/global/session-start/scripts/day-summary.py <p> --date <YYYY-MM-DD>` (UTC), or `--since <date>T20:00 --until <next date>T05:00` across midnight | blocks table | laws 4, 6 |
| 6 | At the session end and when a ticket finishes, write `$CLAUDE_WORKSPACE/<p>/time_entries/<YYYY-MM-DD>-<short-topic>.md`: the blocks table, one row per ticket so each row is a time entry for management, then the Delivered list | the file | `examples/session-summary.md` |
| 7 | `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>`; fix each hit | `clean` | law 7 |

On a failed command: read its output, fix the cause (wrong folder, missing python3), retry once. A second failure:
say so in the reply and carry on; tracking never blocks the task.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| `--status` shows a task from another project | Another session is timing on the shared `/tmp` timer | Starting yours ends theirs, and theirs gets no stop line in its own file; tell him in one line, then start; the day summary marks the foreign stop lines. The lasting fix is a per-project PID and current file in the tool, his call | no quote of his; the v2.1.0 troubleshooting row |
| Negative minutes, or a task "in progress" for days | `track --summary` pairs by name | `scripts/day-summary.py` | no quote of his; the v2.1.0 troubleshooting row |
| Hours missing from the project | `TRACK_PROJECT` unset, entries went to `_global/` | Run day-summary on `_global` for that day and move the blocks into the project summary by hand | no quote of his; the v2.1.0 troubleshooting row |
| The tool's help says `./scripts/track` and `docs/time_tracking/` | A stale header | The real tool is `$CLAUDE_WORKSPACE/track`, entries in `<p>/time_entries/entries.jsonl` | no quote of his; the v2.1.0 troubleshooting row |
| A block of 6h overnight | Checkpoints fire every 5 minutes while the timer runs, worked or not | Trim to the last commit or prompt; the session JSONL timestamps show the last real turn | no quote of his; the v2.1.0 troubleshooting row |
| `track --help` started a timer named `--help` | Every argument is read as a task name | Use `--status`; stop the stray task with `--stop` | measured in the lane that rewrote this skill; no date kept |
