# Memory and handoff, inside orchestration

What gets written down for the next session, where it lives, and how it is kept true. The director keeps it;
players write their own state to the workspace before they report (orchestration brief). Global: it serves
the record of orchestration (law 13, `ORCHESTRA.md`) and the recovery of session-start, and carries no
workflow of its own.
It guarantees the next session continues exactly where this one stopped, from files, with nothing kept in memory files.

## Contents

- Stance: you are the director keeping the record
- Non-negotiables
- Intake
- Pipeline
- Gotchas

## Stance: you are the director keeping the record

- **You write only what his words, the spec or the code confirm.** A handoff you cannot source is not written.
- **You decide alone** where a note goes (`references/memory-and-handoff-where-things-go.md`) and the wording of a status line; log a placement you were unsure of as a DECISION.
- **You never decide** that a note is a memory file; there are none.

## Non-negotiables

1. **Claude context stays out of repos:** plans, specs, notes, handoffs and time entries live in `$CLAUDE_WORKSPACE/<project>/`, so `git status --porcelain` in the repo lists 0 paths of a `CLAUDE.md`, a `.claude/` or a plan. This law owns where a spec lives; other skills point here. Why: a repo holds code and the docs a teammate reads; Claude docs (context, sessions, notes) live in one folder outside every repo, a subfolder per repo. → `references/memory-and-handoff-where-things-go.md`
2. **Real docs go in the repo:** README, `docs/`, ADRs, runbooks and API docs a teammate expects. Why: the rule against docs in the repo covers Claude docs only; documentation a teammate needs belongs in the repo when the change calls for it.
3. **No memory file is written.** A correction goes to the skill that owns the job (skill-craft). Why: memory files were never read back and only slowed startup. → `references/memory-and-handoff-where-things-go.md`
4. **The record is current after each status change and before each compaction:** `ORCHESTRA.md` for any ticket (orchestration law 13), the dated handoff for a session with no Score. Why: a cut session continues without rebuilding its state only when the record marked what is ready and what is left as the work went. → `examples/handoff.md`
5. **An older record is reconciled before it is trusted:** its claims against `git log`, `git status` and his prompts since its date. Why: a list trusted from an old record missed the session's tickets and listed validated work; git shows what changed, his prompts show what he asked. → `/home/visiond/projects/claude/skills/global/session-start/references/recover-thread.md`
6. **A change that altered architecture updates the repo docs in the same turn;** "docs are done" is said only when `git diff --stat` lists the doc file. Why: the v2.1.0 line "ship docs with every batch" (retired memory ship-docs-with-every-batch).
7. **Every note passes `check-text.sh`** (`bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>` prints `clean`). Why: writing, the plain-words rule.

Violating the letter of a law is violating the law.

## Intake

1. The note or the state to keep, with his exact words when he gave them.
2. The project folder (session-start) and the newest `ORCHESTRA.md` or handoff in it.
3. For a reconciliation: `git log --since=<record date>`, `git status`, his prompts since that date.

Fixed: the placement table, the 7 headings of the handoff. Free: the wording of status lines.

## Pipeline

Serves orchestration law 13 and the recovery of session-start. Each Output is a file or a line in the reply.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Classify the note with the table | `Goes to:` the row and the path | `references/memory-and-handoff-where-things-go.md` |
| 2 | A correction or a procedure: hand it to skill-craft and stop | the skill step named | skill-craft |
| 3 | State: update `ORCHESTRA.md` (Score row, Log), or the dated handoff when no Score exists | the file, with his prompts, what he validated, uncommitted files, next step | `examples/handoff.md` |
| 4 | Reconcile an older record against git and his prompts | `Reconciled:` the commands run and the claims that changed | `/home/visiond/projects/claude/skills/global/session-start/references/recover-thread.md` |
| 5 | Architecture changed: update the repo docs in the same turn | doc file in `git diff --stat` | law 6 |
| 6 | `check-text.sh` on every file written | `clean` | law 7 |

Do not skip 4 when the record is older than the current session.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The list of tickets is out of date and lists validated work | An old record was trusted alone | Law 5: prompts, spec, record and code are reconciled; his verdict is recorded, never self-certified | a ticket list missed the session's tickets and listed validated work, the third time it was asked for |
| The session cut and the next one could not continue | The prompts and the state were not stored | Law 4 | a cut session had to be rebuilt by hand before work could continue |
| Only the last session was checked | The work spans several | Read the whole prompt history over the span (session-start) | only the last session was read while the work spanned several |
| A subagent's work was lost when it ended | It reported only in its final message | The brief tells it to write its state to the workspace before reporting (orchestration) | The v2.1.0 troubleshooting row |
| After compaction the next step is gone | The summary dropped it | The record already holds the next step (law 4); the post-compact hook prints the files | he asked whether compaction was dropping the state |
| An old memory file says what a skill contradicts | Memories are retired | The skill wins; a fact still missing goes into its owning skill | the retired memories held facts that belonged in skills |
| Claude files in a repo | Context written beside the code | Move them to the workspace | Claude docs were found in the repo folder |
