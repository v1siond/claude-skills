---
name: database-architect
description: Analyzes a database schema against the context he gives (what the system must do and how it behaves) to find gaps, issues, improvements and potential issues, invoked before the schema is judged or a table is added, deriving the domain first (static vs dynamic and the owner of each fact), each finding with evidence, severity, the smallest fix and its migration path. Run by the director at orchestration row D1 and the architect cast early when a ticket adds or changes a table, and for a new project. Use when he says "database architect", "analyze the following database schema", "analyze the database", "review the schema", "schema gaps", "data model issues", "static and dynamic data", "what data should be repeated". Do NOT use for the code structure plan (engineering-standards `/home/visiond/projects/claude/skills/global/engineering-standards/references/software-architecture.md`) or running a data migration (ship).
metadata:
  author: Alexander Pulido
  version: 1.1.0
  triggers: ["database architect", "analyze the following database schema", "analyze the database schema", "analyze this schema", "analyze the database", "review the schema", "schema review", "schema gaps", "database schema", "data model issues", "data model review", "static and dynamic data", "what data should be repeated", "database design"]
---

# Database architect

Reads a database schema in the light of the system he describes and returns the findings that matter for that
system: facts stored twice, facts on the wrong owner, missing constraints, cardinality the context contradicts,
gaps, improvements, and scaling and migration risks, each with its fix and migration path. Run by the director at step 1 and the architect player.
The outcome: every fact of his system has one owner, and every gap in the schema is a finding with a fix he can run.

## When to use

- He gives a context (a game, an app, a flow) and a schema, a migration folder or a database, and asks what is wrong or missing.
- Orchestration step 1 or 2 of a ticket that adds or changes a table, a column or an association.
- A new project: the first schema is checked against his description before the first migration is written.

## When not to use

- Where a function or module lives, the component tree, the plan's nine sections: engineering-standards `/home/visiond/projects/claude/skills/global/engineering-standards/references/software-architecture.md` (the architect expert).
- Running a schema or data migration on staging or production: ship.
- A wrong value seen in the app with no schema question: bug-investigation.
- A slow query in a diff: review.

## Stance

- **You derive the domain from his context before you open the schema.** The schema is judged against it, never against a generic ideal.
- **You decide alone** the severity of each finding and the smallest fix; log each as `DECISION ... (S<n>)` in ORCHESTRA.md Decisions, `S<n>` the row of the understand.md table it changes (orchestration Stance).
- **You never decide** to design past his context; a need he did not state goes under Open questions, worded as a question to him.
- **You never change** a table yourself; the fix goes to the spec and the builders build it.

## Non-negotiables

1. **The context comes first and the schema is read against it.** `domain.md` exists before the first finding. Why: a schema judged against a generic ideal gets columns his system never needs and misses the facts his context depends on. → Pipeline step 1
2. **His request has no fixed format;** take the context from whatever he wrote, and ask only for a part that is missing. Why: his example request shows one way the ask can look, and the next ask will be worded differently. → Intake
3. **Every entity is split static vs dynamic, down to its parts, by orchestration row D1 (`/home/visiond/projects/claude/skills/global/orchestration/references/understand-method.md` 1a to 1f, which owns the method) and the filled block in `/home/visiond/projects/claude/skills/global/orchestration/references/score-template.md`.** A dynamic record still has a static part; that part lives once and the instance points at it. A change one instance makes to a static fact (a hero's stats changed at the start of a mission, items lost) is stored on the instance, never by editing or copying the static row. Why: a unit's sprite, animation, attacks and stats are static even when the unit moves on a map, and a copy per map lets the copies drift. → Pipeline step 2
4. **Every finding has evidence (a `table.column`, with the file:line after it for a seed or sequence), severity, the smallest fix and a migration path** (schema migration, data migration, or both). A finding missing one of the four is cut. A column the table lacks is cited marked `(absent)`, and a seed or sequence finding cites the column it lands in (`levels.id`, `seed.sql:1-2`). Why: a finding without these four cannot be checked, ranked or run, so it never reaches the schema. → Deliverables
5. **Debt is kept only on purpose, and named:** a finding left unfixed carries the reason and the context that will fix it. Why: an issue that is better fixed in a known later context is valid debt; an unnamed one is not. → Deliverables
6. **The findings feed the orchestration architect:** they go into `understand.md` at step 1 and the spec at step 2, beside the plan of engineering-standards. Why: findings kept in a side file never reach the architect expert or the orchestration architect, who design the new project from them. → `/home/visiond/projects/claude/skills/global/orchestration/references/role-cards.md` Architect

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "I will read the tables first and see what looks off" | Law 1 broken. Write `domain.md` from his context first. |
| "Each level has its own copy of the character, that is just how levels work" | Law 3 broken. The character's static part is shared; only the placement is per level. |
| "Add a version column, an audit table and sharding while we are here" | Designing past his context. Put it under Open questions. |
| "The ORM association exists, so the database enforces it" | Step 3 skipped. Check the foreign key and the unique index in the schema itself. |
| "Fix it by rewriting the tables" | Law 4: the smallest fix, with its migration path. |

## Intake

Have these from files or his message, never from memory:
1. His context: what the system must do and how it behaves, in his words, copied into `domain.md`.
2. The schema: a schema dump (`pg_dump --schema-only`, `structure.sql`, `schema.rb`), the migrations folder, or the ORM schema files, read whole.
3. The ORM layer when one exists: every association and validation, to compare with the database.
4. ORCHESTRA.md Decisions and `score/<ticket>/understand.md`, where the findings land.

Missing context = orchestration law 11a grep first; no hit, then ask him one question naming the missing part, then wait. Fixed: the 7 steps, the 4 parts of a finding, the severity scale in Deliverables. Free: the order findings are listed in (default: severity, high first).

## Pipeline

Serves orchestration row D1 (understand, run by the director) and row A (the architect's contract, every ticket).

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Domain from his context: the entities, what each does, who acts on it | `score/<ticket>/db/domain.md`, one `| entity | what it does | who acts on it |` row per entity | law 1 |
| 2 | Per entity and per part: static or dynamic and the one owner of each fact, as rows of orchestration row D1's `## Static and dynamic` table (shape and filled example: `/home/visiond/projects/claude/skills/global/orchestration/references/score-template.md`) | the table in `score/<ticket>/understand.md` | law 3 |
| 3 | Read the schema: tables, primary keys, foreign keys, unique indexes, checks, nullability, polymorphic owner columns, jsonb columns holding relations, ORM associations vs database constraints | `score/<ticket>/db/schema.md`: one line per table, `x has many y`, `foo has one bar`, and each constraint the ORM claims that the database lacks | Intake 2, 3 |
| 4 | Compare step 2 with step 3; one finding per mismatch, in the 7 kinds: stored twice, wrong owner, missing constraint, cardinality vs context, gap, improvement, scaling or migration risk | `score/<ticket>/db/findings.md` rows | Deliverables |
| 5 | Per finding: the smallest fix and its migration path (schema only, data backfill, or both, in run order) | the Fix and Migration columns | ship for the run |
| 6 | Debt kept on purpose and Open questions | `findings.md` sections Kept debt and Open questions | law 5 |
| 7 | Hand off: the high findings into `understand.md` (step 1) or the spec (step 2) | the lines in that file | law 6 |

Do not skip 1, 2 or 3. A finding written before `domain.md` is redone from step 1.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| 1. A review that proposes columns his context never asked for (an `active` flag, currency, shipping, tax, `created_at`) | The schema was read before the domain | `domain.md` and the split first; a need he did not state goes under Open questions | scenario D2 without arm, 3 of 3 runs (`/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md` database-architect run 2) |
| 2. Findings in prose with no severity and no migration per finding | No finding format | Law 4: the 7 cell row of Deliverables, Check 2 | scenarios D1 and D3 without arm, 0 of 6 runs with a severity per finding (`/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md` database-architect run 2) |
| 3. Identity and placement columns listed as two groups, with no row per fact marked static or dynamic | The split was skipped for a quick table rewrite | Law 3: Pipeline step 2, one row per fact | scenario D1 without arm, 0 of 3 runs (strict reading; the loose reading counts the two groups as a split, 3 of 3, `/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md` database-architect run 2 note) |

## Deliverables

- `score/<ticket>/db/domain.md`, `schema.md`, `findings.md` (the ticket folder of orchestration; for a question with no ticket, the same three files plus `understand.md` holding only the `## Static and dynamic` table, in the scratch folder).
- `findings.md` row shape, filled example:

| # | Kind | Severity | Evidence | Finding | Smallest fix | Migration |
|---|---|---|---|---|---|---|
| 1 | stored twice | high | `level_characters.sprite_sheet`, `level_characters.stats` | Context: one character in many levels. Static sprite and stats copied per level row | `characters` table owns sprite and stats; `level_characters` keeps `character_id` FK, position, actions | schema: add `characters`, FK; data: one row per distinct character, backfill FK, drop copied columns |

- Severity: high = a fact can diverge or a row can be orphaned today; medium = the context's next feature breaks on it; low = cost with no wrong data.
- Kept debt row: the finding number, why it stays, the context that will fix it.

## Check it before you show it

| # | Check | Pass | A FAIL goes back to |
|---|---|---|---|
| 1 | `grep -c '^## Static and dynamic' understand.md`; entity rows: `grep -cP '^\x7c *[^\x7c\- ]' domain.md` minus 1 (the header) | 1; 1 or more | step 1 or 2 |
| 2 | Every finding row has its 7 cells filled: `/home/visiond/projects/claude/skills/global/database-architect/scripts/check-findings.sh score/<ticket>/db <schema file>`, its Check 2 line | no `EMPTY CELLS` line | step 4 or 5 |
| 3 | Every Evidence cell names a backticked `table.column`, and each one whose table is in the schema has that column (cells marked absent skipped for the second part, which reads the `create table` lines of a SQL dump, `pg_dump --schema-only` or `structure.sql`; a file name such as `seed.sql` never counts): the same script, its Check 3 lines | no `NO COLUMN` line and no `MISSING` line (a planted `orders.totl` prints `MISSING orders.totl`) | step 3 |
| 4 | Every finding names an entity of `domain.md` in its Evidence or Finding cell: the same script, its Check 4 line | no `NO ENTITY` line | step 1 |
| 5 | Needs his context does not state sit under one Open questions heading: the same script, its Check 5 line. The bound (no fix adding a feature he did not state) is judged by eval D2 | the script prints `findings: ok` | step 6 |

## Critic loop

No loop of its own. The findings go into `understand.md` or the spec and are read by the orchestration critics: the step 5 critic for understand.md, the goldfish critic lens at step 2 for the spec (`/home/visiond/projects/claude/skills/global/orchestration/references/critic.md` Goldfish), with their rounds and verdicts; a Blocker or Major on a finding goes back to step 4.

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py /home/visiond/projects/claude/skills/global/database-architect` prints `ok   database-architect` (for this skill's own edits).
- [ ] `domain.md` written from his context before the schema was read.
- [ ] orchestration row D1's `## Static and dynamic` table filled, one row per fact, with one owner per fact.
- [ ] `schema.md` lists every table, its associations and every ORM claim the database lacks.
- [ ] Every finding has evidence, severity, smallest fix and migration path; Checks 1 to 5 pass.
- [ ] Kept debt and Open questions written; nothing designed past his context.
- [ ] High findings in `understand.md` or the spec.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `/home/visiond/projects/claude/skills/global/database-architect/scripts/check-findings.sh <db folder> <schema file>`: Checks 2 to 5, prints `findings: ok` or one line per failure.
- engineering-standards `/home/visiond/projects/claude/skills/global/engineering-standards/references/software-architecture.md` the architect expert: the plan that builds on these findings.
- `/home/visiond/projects/claude/skills/global/orchestration/references/role-cards.md` Architect, `/home/visiond/projects/claude/skills/global/orchestration/references/skill-map.md` architect row.
- ship for running the migrations named in a finding.

## Evals

Trigger rows: the database-architect rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json`.
Behaviour scenarios, scored in `/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md` section database-architect, run 2: claude-sonnet-5-5, 3 runs per arm, the clean method. RED and GREEN are the measured results:

| # | Scenario | RED baseline (without) | GREEN (with) |
|---|---|---|---|
| D1 | One merchant in 3 levels, the same look and stats; `level_characters` copies them and the seed copies already differ | 3/9 (6/9 on the loose reading, Gotcha 3): names the drift and asks which value wins, but no static or dynamic row per fact and no severity or migration per finding | 9/9: domain and split tables, a finding per mismatch with table.column, severity, fix and migration, the drift held for his choice |
| D2 | A shop context and a schema, "analyze the following database schema" | 3/9: no domain step; an `active` flag, currency, shipping or `created_at` proposed in all 3 runs | 9/9: domain and split first, every finding on an entity, currency and statuses under Open questions |
| D3 | One payer per order, deleted with it; Ecto claims a foreign key, a unique index and a cascade the database lacks | 6/9: all 3 claims and the clean data step found, no severity per finding | 9/9: the same, each finding with severity and migration |

At 1.0.6 (run 4 of that section, D1 with arm only, 3 runs): D1 7/9, each miss a kept debt finding whose Migration cell says "None now."; and 4 D2 and D3 GREEN cuts of run 2 fail the stricter Check 3 (`NO COLUMN`: an absent column named only by its table, or an index).
