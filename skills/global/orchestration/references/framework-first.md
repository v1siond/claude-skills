# Framework first, inside orchestration

Makes the first read of every task the written framework for its context, and the last step that framework's
checklist, walked for every member. Run by the director in orchestration row D1 (understand) and by the
architect when it writes the contract; every brief names the framework.
It guarantees no task starts without the written framework for its context, and none is reported done before its checklist is walked.

## Contents

- Stance
- Non-negotiables
- Intake
- Pipeline
- Gotchas

## Stance

- **You read the doc before the code and say which doc.** The reply opens with "Following <DOC>.md".
- **You decide alone** which row of the index matches the context and where a new doc lives; log it as a DECISION.
- **You never decide** that no framework is needed for a non-trivial change, or that a doc is wrong without checking the code.

## Non-negotiables

1. **The first read of a task is the framework, and the reply names it.** Why: work started without the docs and guidelines of its context ignored what he had already shared and written down.
2. **No framework: research it and write it before any work.** Why: a context with no doc was worked from recall; one is found or researched and written before anything is done (water: the water framework; tile design with none: research the fundamentals, best practices and examples, then write it). → `references/framework-first-framework-template.md`
3. **The checklist is the gate:** each item has evidence before "done", and a family (every tile, species, biome, page) has evidence for every member. Why: the visual checks ran on one object and skipped the rest; they hold for every region of every biome.
4. **Shared knowledge goes into the doc in the same turn,** as a numbered fact with its source. Why: knowledge he shared and no doc held was ignored; a link left in a reply is relearned wrongly next session.
5. **Read the doc and check the code it names.** Why: docs go stale (SKILL.md Gotchas row 2); when they disagree, his newest words win, then the spec, then the code, and the stale side is fixed in the same change. → Gotchas row 2
6. **Every brief carries the doc path** and "return the checklist walk with evidence per item". Why: a builder that never saw the doc cannot walk its checklist.

Violating the letter of a law is violating the law.

## Intake

1. The task and its context: water, tests, pricing, a feed, a review.
2. The index: `scripts/find-frameworks.sh <repo-dir>` (default: the current repo); the per-project map is `references/framework-first-project-indexes.md`.
3. Everything he shared in the conversation: links, videos (skill research), images, corrections.

Fixed: the doc is read first, the checklist is walked last. Free: where a new doc lives (repo `docs/`).

## Pipeline

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Run `scripts/find-frameworks.sh <repo-dir>`; read the index it finds | the index path in the reply | `references/framework-first-project-indexes.md` |
| 2 | Find the row for the context; read that doc whole; state "Following <DOC>.md" | the line in the reply and a Framework section in `score/<ticket>/understand.md` | law 1 |
| 3 | Grep the functions, tables and commands the doc names; fix the stale side | drift list with the fix, or "0 drift" | law 5 |
| 4 | No row and no doc: research with skill research (real products, primary sources, 1 citation per claim); write the doc from the template in the repo `docs/`; add its row to the index | the new doc and its index row | `references/framework-first-framework-template.md` |
| 5 | He shared something: add a numbered fact with URL and date, video timestamp, or his quote and date, before applying it | doc diff | law 4 |
| 6 | Do the work from the doc, citing its section per non-trivial change | section cites in the commit or report | |
| 7 | Put the doc path in the brief's reference field and "return the checklist walk" in its deliverables (orchestration row D4) | the brief fields | law 6 |
| 8 | Walk the checklist item by item; render or test every member of a family | `score/<ticket>/walk.md`, one `- ` line per item and member: evidence or "not verified, because ..." | law 3 |

Do not skip steps 2, 5 and 8. A script section that prints `none found` is a result, not a failure; a doc the code contradicts twice in one task: stop and reconcile the doc first.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The CLAUDE.md path for a doc does not exist | the doc moved | the script finds the live one; tell him the CLAUDE.md line is stale, never edit CLAUDE.md | the CLAUDE.md path does not exist; `ls` of its folder lists other files |
| Two docs disagree | one is stale | his newest words, then the spec, then the code; a handoff or summary loses even when newer; `git log` shows which came later | work started without reading context, code, history and docs together, and was not documented after |
| He asks "did you follow it?" | the checklist was skipped or walked on one member | walk it now, every item, every member, and report the walk | he had to ask for the framework to be followed after its visual steps ran on one object |
| A framework written from recall | research skipped because a URL failed | fetch another source; record in the doc which URL failed | the hitbox system was built without searching how real engines solve it |
| A bridge delivered with gaps, 3 days in | the objects framework was not followed and nothing was checked per member | law 3, walk the checklist before reporting | a bridge took 3 days and still had unmatched sides and gaps in the wooden path |
| A question asked that a doc answers | the doc was not read | law 1; read before asking | questions kept reaching him that the docs and the old code already answered |
