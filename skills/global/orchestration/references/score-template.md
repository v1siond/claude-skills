# ORCHESTRA.md template

## Contents

- The ticket folder, one file per pipeline step
- The ORCHESTRA.md template: Goal, Scope, Cast, Servers, Contracts, Decisions, Score, Waves, Open questions, Log
- A filled understand.md Static and dynamic block
- A filled scope.md and contract.md
- A filled brief
- A filled control.md, integrate.md and qa.md

Lives at `$CLAUDE_WORKSPACE/<project>/ORCHESTRA.md`, which is
`<workspace>/ORCHESTRA.md` as SKILL.md Pipeline defines `<workspace>`. Updated at every pipeline step that writes an Output. A new session reads this first.

Next to it, one folder per ticket holds the files each pipeline step leaves:

```
score/<ticket>/understand.md     row D1, Problem:, the ## Static and dynamic table, Cause: and Debt: (understand-method.md)
score/<ticket>/scope.md          row D2, Build:, Not build:, Reuse: file:line, Buy: package and version, or none with the query run
score/<ticket>/contract.md       row A, the architect: data, API or props and events, files per lane
score/<ticket>/brief.md          row D4, one section per lane, with Contract: and Skills you run: lines
score/<ticket>/director-critic.md rows D4c and D7, ## Before dispatch and ## Before his look, each ending in `Verdict:`
score/<ticket>/control.md        row Dc, one verdict per requirement, each quoting him, plus skills-check.sh output per lane
score/<ticket>/qa/before-<n>.png row V, the same view as after-<n>.png on the last build he approved
score/<ticket>/qa/after-<n>.png  row V, 1920 x 1080, cited by its qa.md row
score/<ticket>/qa/qa.md          row V, one row per sentence of his per view (SKILL.md Check it before you show it)
score/<ticket>/review.md         row V, the reviewer: findings with file:line, last line `Verdict: pass` or `Verdict: fail`
score/<ticket>/subtickets.md     row F, one row per finding: id, parent, lane, his words or why it waits
score/<ticket>/integrate.md      row D6, per seam and gate: command, output, PASS or FAIL, on the final sha
```

A row is BUILT only when the BUILT check in SKILL.md Pipeline passes (`scripts/built-check.sh <workspace> <ticket>` prints `BUILT`).

```
# <Project>, the record

## Goal
"<his words, quoted>"

## Scope
Build:  ...
Reuse:  ... (library, free assets, existing module)
Post batch: ... (only what he placed after this batch, with his words)

## Cast (only the players used; skills from references/skill-map.md)
| Player | Tickets | Skills |
|---|---|---|
| director (lead) | all | orchestration |
| frontend | T3 | testing-standard, ui, engineering-standards (+ references/frontend.md) |

## Servers
Dev server: <the URL he uses, e.g. http://localhost:4000> (row V and his look run here)

## Contracts
- <path to contract doc>, approved <date> by him | pending

## Decisions
D1 <decision>, his words or source, date
D2 <choice the director made>, default it beat, why (he can overturn in one reply)

## Score (the live score)
| Ticket | Role | Depends on | Area / files | Check | Status | Agent / branch |
|---|---|---|---|---|---|---|
| T1 Data model and API contract | architect | none | docs/contract.md | he approves | BUILT | arch-1 / feat/contract |
| T2 Orders endpoint | backend | T1 | lib/app/orders | `mix test test/app/orders_test.exs` red first, then `N tests, 0 failures` | MISSING | |

Check: a command with its expected output, or a measured number with its threshold.

Status: one of his 4 words only, `PENDING`, `IN DEVELOP`, `READY TO REVIEW`, `COMPLETED` (his yes; the row then leaves the Score), with no note in the cell (`references/work-report.md` rule 10). BUILT is the check behind READY TO REVIEW, not a status.

## Waves
W0 architect: T1            done <date>
W0b critic: briefs scored   done <date>
W1 build: T2, T3, T4        running
W2 verify: QA, review       pending

## Open questions
Q1 <question>, context, options. Blocks: T5 only.

## Log
<date> W1 merged, suites 412 tests 0 failures, seam check: 1 field mismatch -> T9
```

## A filled understand.md Static and dynamic block (`score/T2/understand.md`, illustrative)

The steps that fill it are `understand-method.md` 1a to 1f; when a schema is involved, database-architect fills 1b.
`scripts/understand-check.sh score/T2` prints `understand: ok` on this block.

```
Problem: a character is kept once per level, so the same character drifts between levels; the base is who owns a character.

## Static and dynamic

| # | Fact | Static or dynamic | Owner today (file:line) | Owner after | His words |
|---|---|---|---|---|---|
| S1 | a character's sprite sheet and stats | STATIC, kept once, shared by every level | `level_characters.sprite_sheet`, copied per level (`schema.sql:41`) | `characters.sprite_sheet`, one row | "one character, every level" |
| S2 | where the character stands and what it does in one level | DYNAMIC, held by the level | `level_characters.position`, `level_characters.actions` (`schema.sql:43`) | `level_characters.position`, `.actions` | "placed in each level" |
| S3 | the level's terrain | STATIC, built once | `levels.terrain` (`schema.sql:12`) | `levels.terrain` | "the level's ground" |

Cause: S1 has one copy per level, so a level edited alone drifts from the others.
Debt: per level stat overrides stay a jsonb column until row T7 (the mission rules ticket, which pays it).
```

The spec (a bug: brief.md) holds the rules of 1d, and every task row names the R or S row it serves (2a):

```
## Rules
R1. a character is one row, read by every level ("one character, every level")

## Tasks
| # | Task | Serves |
|---|---|---|
| 1 | move sprite_sheet and stats to characters, level_characters keeps position and actions | R1, S1, S2 |
```

A ticket that stores no data writes the heading, then `none: <why>`, and still `Problem:`, `Cause:` and `Debt:`:

```
Problem: the button shows last year's brand colour.

## Static and dynamic

none: a label colour in the CSS, no record is read or written

Cause: the token in `theme.css:8` names the old colour.
Debt: none
```

## A filled scope.md and contract.md (`score/T2/`)

```
# T2 scope
Build: the Agent column on the orders list and detail
Not build: agent search, agent avatars (absent from his words)
Reuse: lib/app/agents.ex:12 Agents.name/1; assets/js/components/Table.tsx:30 column renderer
Buy: none, searched `npm search react table column` and the repo kit (Table.tsx already renders columns)
```

```
# T2 contract (architect)
GET /api/orders/:id -> {"id": int, "agent_name": string | null}
Backend lane: lib/app/orders.ex, lib/app_web/controllers/order_controller.ex
Frontend lane: assets/js/pages/Orders.tsx (reads agent_name, shows "None" for null)
```

## A filled brief (`score/T2/brief.md`)

An illustrative ticket (the quote, paths and numbers are invented to show the shape; a real brief copies
his words from `<workspace>/PROMPT-LOG.md`). Every field present and none empty; the row D4c critic scores this file.

```
# T2 Orders endpoint (backend)

His words: "orders must show the agent name in the Agent column" (10-24 09:12, PROMPT-LOG.md line 88)
Contract: score/T2/contract.md (row A)
Reference: docs/orders.md section Agent column
Inputs: test/fixtures/orders_with_agents.json
Files owned: lib/app/orders.ex, lib/app_web/controllers/order_controller.ex, test/app/orders_test.exs
Skills you run: engineering-standards, testing-standard
Test mode: D3 in ORCHESTRA.md Decisions, default
Check: `mix test test/app/orders_test.exs` fails first on the agent name, then prints `6 tests, 0 failures`
Report: the diff paths, the check output before and after, each requirement with file:line
```

## A filled control.md, integrate.md and qa.md (same illustrative ticket)

```
# T2 control (row Dc)
| His words | Requirement | Where | Verdict |
|---|---|---|---|
| "orders must show the agent name in the Agent column" | agent name in the payload | lib/app/orders.ex:42 | PASS |
| (none) | added field `producer_alias` | lib/app/orders.ex:57 | REJECT, absent from his words (law 5) |
```

```
# T2 integrate (row D6)
| Seam | Command | Output | Verdict |
|---|---|---|---|
| backend T2 to frontend T3 | `curl -s localhost:4000/api/orders/1 \| jq .agent_name` | "Ada Lovelace" | PASS |
```

```
# T2 qa (row V)
| His sentence | View | URL on his dev server | Screenshot (1920x1080) | Verdict |
|---|---|---|---|---|
| "orders must show the agent name in the Agent column" | orders list | http://localhost:4000/orders | qa/after-1.png | PASS |
| "orders must show the agent name in the Agent column" | order detail | http://localhost:4000/orders/1 | qa/after-2.png | PASS |
```
