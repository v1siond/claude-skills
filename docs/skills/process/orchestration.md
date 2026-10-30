# orchestration

| | |
|---|---|
| Type | process |
| Scope | global (every repo) |
| Source | [`skills/global/orchestration/SKILL.md`](../../../skills/global/orchestration/SKILL.md), version 7.4.3 |
| Run by | the director |

## What it is for

The only process for all development, in every project. A director runs players who each do one kind of work
with the skills for it, and controls every result against his words and the docs. Every other skill is a
complement a player runs inside this pipeline (SKILL.md lines 13 to 15). It also owns every report: a standup
at a checkpoint, a full report when work stops (law 18).

## When to use it, and when not

Use it for any request that changes code, data, docs or assets: a bug, a feature, a batch, a whole app; and
when work resumes after a break, a token reset or a compaction (When to use, lines 18 to 21).

Do not use it for a pure question about how something works with no change: answer it, no record. How to
write a test belongs to testing-standard (When not to use, lines 23 to 26).

## Who runs it and its place in orchestration

It is orchestration. The director never plays an instrument: no feature code, a ticket is written and
dispatched instead, and every report is a claim until `control.md` gives it a verdict (Stance, lines 28 to 33).
The cast and the skills each role runs are in
[`references/skill-map.md`](../../../skills/global/orchestration/references/skill-map.md) and
[`references/role-cards.md`](../../../skills/global/orchestration/references/role-cards.md).

## Pipeline, short

| Step | What | File it leaves |
|---|---|---|
| 0 | Log his words; every ask joins the current batch | `PROMPT-LOG.md`, new Score rows |
| 1 | Understand the docs, skills and code of the area | `score/<ticket>/understand.md` |
| 2 | Spec and plan quoting him; goldfish lenses read them fresh | spec file, `score/<ticket>/goldfish.md` |
| STOP | His yes on the spec and plan for new work | his yes in `ORCHESTRA.md` |
| 3 | Size the rows and lanes; cast only the roles needed | Cast in `ORCHESTRA.md` |
| 4 | Brief each ticket, no field empty | `brief.md` |
| 5 | Critic on the briefs, default reject | `critic-brief.md`, every axis 8 or more |
| 6 | Dispatch | agent ids on the Score row |
| 7 | Control each report requirement by requirement | `control.md` |
| 8 | Integrate the lanes, run each seam | `integrate.md` |
| 9 | QA in the browser on his dev server, before and after | `qa/before-*.png`, `qa/after-*.png`, `qa.md` |
| 10 | Critic on the result against his words | `critic-result.md` |
| 11 | Findings go back to step 4 as tickets | new rows |
| 12 | Present on his dev server, the report | the report |
| STOP | His verdict; DONE is his | his words in `ORCHESTRA.md` |

Source: Pipeline table, SKILL.md lines 101 to 117. A row is BUILT only when `scripts/built-check.sh` prints
`BUILT` (line 120).

## Scripts

- `scripts/built-check.sh <workspace> <ticket>`: the BUILT check (step files, qa.md rows, numbered 1920x1080 before and after pairs).
- `scripts/law3-check.sh`: checks a new ask was placed after the batch's last row, approved order unchanged.
- `scripts/agent-load.sh`: how many agents may launch now on this box.
- `scripts/builder-gate.sh`: a SubagentStop hook (law 7 run by a machine): a player that edited files does not stop until its lines pass check-diff, the repo's quick gate and check-report. It is not wired in today's settings (see [harness.md](../../harness.md)).
- `scripts/find-frameworks.sh [repo]`: lists the framework documents that govern work in a repo, for law 17.

## Key laws

1. The pipeline runs for every request that changes code, data, docs or assets, every step, in order (line 37).
2. His words are copied, never interpreted (line 38).
3. Every ask joins the current batch the turn he says it; the approved order is never changed (line 39).
4. A spec and a plan exist before any build (line 41).
5. Nothing is built that he did not ask for (line 42).
7. Every player codes to engineering-standards and tests to testing-standard, enforced at step 7 (line 44).
9. QA uses the real app in the browser; only that makes a row BUILT (line 47).
10. Builders never verify themselves (line 48).
13. Every step leaves a file (line 52). 14. Nothing leaves the machine without his yes (line 53).
15. One main checkout, one test database, parallel lanes own disjoint files (line 54).
16. Claude's own files live in the workspace, never in a repo (line 55).
18. Two report shapes, checked in part by the Stop hook (line 57).

## Handoffs

- Session start hands over at step 0 (session-start Pipeline row 7).
- Step 2 uses writing (spec) and engineering-standards (`plan.md`), then the four goldfish agents in [`agents/`](../../../agents) per `references/critic.md` section Goldfish.
- Step 4 names engineering-standards, testing-standard and the cast's skills in every brief.
- Step 9 runs testing-standard and ui; a bug goes to bug-investigation; a push is ship.
- A correction to how a job runs goes to skill-craft, never into this skill by hand (Red flags row "I'll add a rule").

## Best practices, from its Gotchas (lines 131 to 147)

- Run step 9 for every row before BUILT; a code critic is not QA.
- Run step 7 against the docs: a player once invented a second height rule.
- Put his words in the brief as written; "Z-WIDTH / Depth" is not "width and depth".
- Apply laws 8a and 8b: test first on frontend and engine work left players looping with no feature to try.
- `git worktree list` must print 1 line (law 15).
- After a compaction, reread the Score and ticket files; the post-compact hook prints them.
- `TaskStop` each agent the moment its report lands.
- Write report items as "number: plain name" in his approved order.

## Red flags (lines 61 to 77)

"This new ask is out of scope", "I'll reorder the wave", "He means width and depth", "The player says it's
done", "The critic passed, mark it BUILT", "Tests are green, so it works", "I'll just fix this file myself",
"The summary says where we were". Each names the law it breaks.

## Evals

Trigger rows in [`skill-craft/references/trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
scenarios O1 and O2 in [`skill-craft/references/behaviour-evals.md`](../../../skills/global/skill-craft/references/behaviour-evals.md);
three more scenarios in the Evals section (lines 193 to 200), each RED from a Gotchas row.
