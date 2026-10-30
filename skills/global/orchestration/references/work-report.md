# Work report, inside orchestration

Two shapes, written only at a checkpoint: a standup of 3 to 6 lines while work goes on, and a full report
shaped like a PR when the batch finishes or work stops. A question is a card, asked once. The director writes
both (orchestration law 18; the full report at row D7). The Stop hook checks the shapes. It carries no
workflow of its own.
It guarantees he reads a short status only when there is something new, a full report he can QA from when work stops, and each question once, with its context.

## Contents

- Stance: you are the director reporting to the one who validates
- Non-negotiables
- Intake
- Pipeline
- Gotchas
- Deliverables: a standup, a full report, a question card
- Check it before you show it

## Stance: you are the director reporting to the one who validates

- **You decide alone** when a checkpoint is reached (law 1), the wording of each line, and which questions survive the grep (law 6).
- **You never decide** that a row is DONE: only his verdict is, and a row he validated leaves every list.
- **You never decide** that a design question is asked in words: it comes with a rendered picture or its path (`references/work-report-rules.md`).

## Non-negotiables

1. **A report is written only at a checkpoint:** a row finishes a step (QA, a commit, a critic), something blocks, or work is about to stop. Never on a timer, never at each collect, and never twice with nothing new. Why: reports written during work came out incomplete, out of order, and repeated the last one with small changes, spending tokens on nothing new.
2. **While work goes on, the report is a standup of 3 to 6 lines, no heading, no table:** `Working on: <part> of <number: ticket>`, `Needs before done: <what>`, `Then: <next row>`, `Waiting on you: <short title> (asked <MM-DD HH:MM>), <short title> (asked <MM-DD HH:MM>)` (only if any), `Batch: <n> of <m> done`. Why: between checkpoints he needs a quick status the way a person gives it at a standup: which part of which ticket, what it needs before done, what waits on him.
3. **When the batch finishes or work stops, the report is a full report shaped like a PR, these headings in this order:** `## What changed` (per ticket touched, what he will see), `## Commits` (sha, subject, branch, pushed or local), `## How to QA` (setup first: server and port, migrations, env vars, seeds; then per ticket: open X, do Y, expect Z, the before and after shot paths), `## Not done` (and known issues), `## Questions for you` (a card per open question, only if any), `## Following` (the spec or doc and the record path; the batch in one line; the full ticket list only when he asks). Why: when work stops he needs what changed, what to do to QA it (env setup, commands to run) and the tickets or spec the work follows, in the order a PR gives them.
4. **A question is a card the turn it comes up, and every item waiting on his review carries a link to the file he reviews (a markdown link to its full path):** `What it is` (plain words, a picture or path when it is about looks), `Why it matters` (what it blocks, which row waits), `Options` (what he would see change under each, and its cost), `My recommendation`. Why: questions came with no explanation or context and repeated across reports, a "my call" line gave him nothing to answer from, and a review item with no link left him searching for the file.
5. **After its card, every open question shares the one `Waiting on you` line of each standup, named by a short title with the date and time it was first asked, never the card again;** the full report repeats the card of each question still open. Example: `Waiting on you: the bell quest (asked 10-26 18:52), heart pieces (asked 10-26 18:52)`. Why: the same card in every report, with small changes, hides what is new.
6. **A question he already answered is never asked:** before writing a card, run orchestration law 11a's grep (docs, workspace, skills, the record, his earlier prompts). A question about what a concept contains (story, quest order, looks, layout) is not his either: the expert skill that owns it decides it from what is being built and lists it as a decision for his review after the proposal (for concepts, the concept designer skill's Deliverables); a question that changes what gets built (a new map, a new system, a row's cost) still comes to him as a card. Why: open questions repeated ones he had answered many times; concept questions (a quest chain, what a boss drops) reached him when the concept designer should have decided them from the game being built and let him review the proposal; the one card he kept (whether a house door leads to a real interior map) changed what gets built.
7. **His answer goes into the owning skill the same turn** (skill skill-craft), so the question is never asked again. Why: an answer recorded in the owning skill is read by every later session, so the question ends.
8. **A ticket is written "number: plain name", in the order he approved:** the number is the row's place in that order, the name says what he sees change in the app, with the number that proves it when one exists ("Village builds 9 to 11 of its 12 houses, was 2 to 5"), never the kind of task, and a letter and number code (C8, AU-T1, M4b) never appears. A row he validated is left out; the numbers of the rest do not change. Why: a letter and number code tells him nothing, a task code alone is hard to follow, and validated tickets in a list hide the open ones.
9. **`Batch: <n> of <m> done` counts the director's rows only:** his QA and decisions never count; an ask he adds joins the batch (orchestration law 3) and raises `<m>`; a row counts as done when built-check prints `BUILT`. No percent and no time estimate. Why: the count measures the director's work; his QA and decisions are not part of it, and every ask he adds grows the total.
10. **Every ticket list and the Score's Status column use his 4 statuses, the word alone, no note beside it:** `PENDING` (not started), `IN DEVELOP` (built, fixed, in QA or sent back: everything before ready), `READY TO REVIEW` (QA PASS in the app; `scripts/batch-check.sh <workspace> <batch> <row folder>` prints `READY` for a batch row, `scripts/built-check.sh <workspace> <ticket>` prints `BUILT` for a ticket run alone), `COMPLETED` (his yes), and a COMPLETED row is removed from the list the turn he says it. A ticket list is ONE table, `# | Ticket | Status`, rows sorted `READY TO REVIEW` first, then `IN DEVELOP`, then `PENDING`, never split into one table per status. Shas, verdicts and notes go in the Log, never in the Status cell. Why: these are the 4 statuses he set; any other word or a note in the cell makes the status unclear, and one table with `READY TO REVIEW` on top shows first what waits on him.
11. **The ticket list under `## Following` keeps his approved order: rows are never sorted by what is active, waiting or new.** Why: he reads the list in his approved order (1, 3, 4, 5, 6) unless he asked to work out of order.
12. **Review, audit and analysis output goes into a workspace file** (`$CLAUDE_WORKSPACE/<project>/`) in the shape its skill sets; the reply names the file under `## What changed`. A gate from another project is misrouted: say so in one line and carry on. Why: the v2.3.0 line "For a review, audit or analysis turn: the findings file first".
13. **A status comes from the newest workspace docs plus git,** never memory alone. Why: the v2.3.0 line "A status list is built from the newest workspace docs and git".
14. **Retired by the 10-26 report redesign, each named here.** Why: the old report repeated the ticket list, percents and mixed formats in every update.
    - The percent and estimated time left on every update (10-21), and the tickets table with a completion percent on every report (10-14 18:04).
    - The tickets as a table `| # | Ticket | Status | Left |` (10-25): now a list under `## Following`, only when he asks.
    - The epic line on every report, rows done of rows total per epic (10-14, mixed formats): now the one `Batch: <n> of <m> done` line.
    - The batch numbered list, one numbered line per batch naming what it ends on (same 10-14 change): now the one `Batch: <n> of <m> done` line. The epic and batch rules were lines 12 to 17 of the old game-engine rules, `git -C /home/visiond/projects/claude show 6300e5f:skills/global/orchestration/references/work-report-rules.md`.

Violating the letter of a law is violating the law.

## Intake

1. ORCHESTRA.md: the live Score, its approved order, the rows he validated, the open questions with the date each was asked.
2. What happened since the last report: commits on the branch, step files written, what blocks.
3. For a full report: the dev server URL and port, migrations, env vars and seeds the QA needs, and each row's `qa/before-<n>.png` and `qa/after-<n>.png`.

Fixed: the two shapes, the four card labels, the 4 status words. Free: the wording of each line.

## Pipeline

Serves orchestration row D7 and every checkpoint before it; each Output is a block of the reply.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Name the checkpoint (a step finished, a block, a stop); none reached = no report | the checkpoint in one line of the record's Log | law 1 |
| 2 | Work goes on: write the standup | 3 to 6 lines, first `Working on:` | laws 2, 9 |
| 3 | The batch finished or work stops: write the full report from the record and git | `## What changed` to `## Following` | laws 3, 8, 10, 11 |
| 4 | A new question: grep (orchestration law 11a), then the card the turn it comes up; an old one: its short title on the one shared `Waiting on you` line | the card or the line | laws 4 to 7 |
| 5 | `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh` on the report text; fix every FAIL | `clean` | writing |
| 6 | A review, audit or analysis turn: the findings file first, then the report names it | the file path | law 12 |

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The same report posted over and over with small changes, tokens spent | A report at every collect, with the whole ticket list each time | Laws 1 and 2: a standup at a checkpoint only | reports at every collect repeated the same content and spent tokens |
| A question with no context, repeated in every report | Asked as one line, never as a card | Laws 4 and 5: the card once, then a short title on the shared standup line | questions came as one line with no explanation or context |
| A full report he cannot QA from | No setup and no steps per ticket | Law 3: `## How to QA` with the server, migrations, env vars and seeds first | a full report had no env setup or commands to QA from |
| A stop gate asks for a `docs/SPEC.md` clause comparison outside game-engine | A game-engine gate fired in the wrong repo | One line saying it is misrouted, then continue | The v2.3.0 troubleshooting row |
| A measured finding is read as true for every carrier or tenant | No scope stated | The line says the scope (carrier, agency, feed type) it was measured on | The v2.3.0 troubleshooting row |
| He gave the diagnosis and the report explains another layer | Re-deriving his diagnosis | Report the change he scoped, one line on anything adjacent | The v2.3.0 troubleshooting row |
| The list mixes formats and spec task numbers | The ticket names were the director's own | Law 8: the project's tickets, in his format | ticket lists mixed spec task numbers with his ticket names |
| The list is unclear | Codes and a sorted order | Laws 8 and 11 | a list of letter and number codes in a sorted order was unclear to him |

## Deliverables: a standup, a full report, a question card

Illustrative (names, shas and paths invented to show the shape; a real report copies the record and git).

A standup:

```
Working on: the river bank pass of 4: Rivers cut through the forest map
Needs before done: QA in the browser on the forest map, before and after shots
Then: 5: Bridges where a road meets a river
Waiting on you: wood or stone bridges (asked 10-26 18:52), the river fish sprite (asked 10-26 19:05)
Batch: 3 of 7 done
```

A full report:

```
## What changed
- 4: Rivers cut through the forest map. A generated forest now has 1 to 2 rivers crossing it edge to edge; before, 0.
- 5: Bridges where a road meets a river. Each road crossing a river gets a bridge tile, 3 on the seed below.

## Commits
- 1a2b3c4 rivers: carve a river path across the forest generator (master, local)
- 5d6e7f8 bridges: place a bridge where a road meets water (master, local)

## How to QA
Setup: his dev server at http://localhost:5173 (backend on 4000); run `mix ecto.migrate`; no new env vars; seed with `mix run priv/repo/seeds.exs`.
1. Rivers: open the editor, generate a forest with seed 42, expect a river from the west edge to the east edge. Shots: score/4/qa/before-1.png, score/4/qa/after-1.png
2. Bridges: on the same map, follow the road north, expect a bridge tile on each of the 3 crossings. Shots: score/5/qa/before-1.png, score/5/qa/after-1.png

## Not done
- 6: River fish. Not started; it waits on 5.

## Questions for you
### Wood or stone bridges on the forest map?
What it is: the bridge tile on a forest road, picture at score/5/qa/after-1.png.
Why it matters: row 5 ships with wood today; row 7 (the village) reuses the same tile.
Options: wood, as now (no cost); stone (one new tile, about 1 hour, the village bridge changes too).
My recommendation: wood on forest roads, stone only in the village.

## Following
docs/GENERATION.md, sections Rivers and Roads; the record at <workspace>/ORCHESTRA.md. Batch: 5 of 7 done.
```

## Check it before you show it

1. A standup: `grep -c . <report>` prints 3 to 6, `head -1 <report>` starts `Working on:`, `grep -c '^#' <report>` prints 0.
2. A full report: `grep '^## ' <report>` prints the headings of law 3 in that order (`## Questions for you` only if any).
3. `python3 ~/.claude/report-format-check.py --text <report>` prints nothing (the checks the Stop hook runs).
4. `grep -cE '\b[A-Z]{1,3}[0-9]+\b' <reply>` prints 0 (no letter and number code), on every reply that names a ticket, a finding or a question, a question card and a status answer included, not only a standup or a full report: a finding is written by what he sees ("the bridge cannot be crossed"), never by its code.
5. `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <report>` prints `clean`.

A failing check goes back to pipeline step 2 or 3, then check again; when the same failure repeats twice, change the approach.
