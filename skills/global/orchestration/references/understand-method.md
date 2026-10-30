# Step 1, understand: the method

His framework for every ticket, the bug path included. The framework is the method running through his last 10 or
so prompts, never the single latest instruction.
Row D1 runs 1a to 1f in order and writes them into `score/<ticket>/understand.md`; row D3 runs 2a. A schema is
read by database-architect, which fills 1b with its domain method; the steps stay here.

## Contents
- The steps
- The bug path
- The director rule on data
- The check

## The steps

| # | Step | Line in understand.md (or the spec) | Why |
|---|---|---|---|
| 1a | Take the problem to its base in its context before any fix: what the system must do, what is broken at the base, in one sentence. A fix tried, a file to patch or a symptom is not the base. | `Problem: <the base problem, in its context>` once, before the table | brute forcing a fix leaves debt; understanding the problem at its most basic level, in its context, picks the approach |
| 1b | Split every fact of the area into static and dynamic, with its one owner today and after; a dynamic fact keeps a row for its static part. Rows are numbered S1, S2 ... | `## Static and dynamic`, the table of `score-template.md`, or `none: <why>` | most data falls in two buckets: static, built once and the same everywhere (terrain, tilesets, a unit's sprites and stats), and dynamic, what a map does with it (events, positions, items taken); even dynamic data has a static part |
| 1c | Name the cause from the table: the row whose copy or owner is wrong. | `Cause: ... S<n> ...` once | the fix starts at that base point and goes from there |
| 1d | The smallest rule set that meets his words, one rule per line, each with the fragment of his words it meets. A rule his words do not need is not written; it goes to 1e. | `## Rules` in the spec (a bug: in brief.md), lines `R1. <rule> ("<his words>")` | simple small rules that grow over time with the needs keep the change direct and never overcomplicated |
| 1e | Debt in a controlled way: each debt kept names the later row and the context that pays it. | `Debt: none` or `Debt: <what> until row <id> (<context>); ...` once | debt left on purpose, for a known later row in a known context, is valid; debt left by accident is not |
| 1f | Contradictions in the table are resolved from his words before any question (below). | the resolution in the S row's His words cell | a question his earlier answers settle sends him back to reread them for the director |
| 2a | At row D3, a spec task or a goldfish finding that only adds machinery his words do not need is cut. Every spec task cites the R or S row it serves; a task citing neither is cut and logged in ORCHESTRA.md Log as `REJECT small rules first: <task>`. | the spec's task table, each row naming `R<n>` or `S<n>` | scope creep is caught at the plan, before any build |

## The bug path

A small bug (no spec of its own, critic.md Size) still runs 1a to 1f; its `## Rules` go in brief.md, and 2a applies
to the brief's tasks. A bug that stores no data writes `none: <why>` under the heading and still `Problem:`,
`Cause:` and `Debt:`.

## The director rule on data

- A director DECISION on data (a table, a record, an owner, a copy) cites its S row: `DECISION ... (S<n>)`.
- A STATIC row whose owner after carries a placement key (a per placement or per map record, a map unit, a unit key,
  "each placed ... its own") is a contradiction: a fact that is the same everywhere cannot be owned by each place.
  It is resolved from his words (the table's His words cell, his answers on file, PROMPT-LOG.md), never by a STOP
  card question: the thing gets one record, placed many times (a DECISION "each placed X becomes its own record" is the
  same contradiction), and the placement keeps only where it stands, what triggers it and what it
  does there. When two of his answers seem to conflict (a short card answer against his statement of the base
  problem), the statement of the base problem rules, and the DECISION quotes both. Why: on row 157 the row "who a character is" was STATIC with a per placement owner and became
  STOP card question 7; he rejected the question and its options and pointed back to his earlier answers.
- A STOP card question cites the S row it is about; a question on a STATIC row is cut.

## The check

`scripts/understand-check.sh <ticket folder> [spec file] [PROMPT-LOG.md]` prints one `FAIL <what>` line per broken
step and `understand: ok` when none; `built-check.sh` runs it on every ticket outside the legacy list. It checks:
`Problem:` once; the heading once, with an `Owner after` column or `none:`; 0 STATIC rows with a placement key in
Owner after; `Cause:` once naming an S row (or the table is `none:`); `Debt: none` or every `;` item naming
`row <id>`; when a spec or brief with `## Rules` exists, every R line holds a quoted fragment found in PROMPT-LOG.md,
and every task (a `### <id>.` task heading, or a row of the first table right under the Tasks heading) names an R or S row; every STOP card question names an S row or
`no data`, and 0 name a STATIC row. The critic (row D4c) reads the rest: whether `Problem:` is the base and not a
symptom, whether each DECISION on data cites its S row.
