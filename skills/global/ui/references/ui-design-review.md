# UI design review, inside ui

Gives him a report he can act on in one read: a scored health table, the 3 to 5 issues that matter most, and every
finding as a row with severity, the rule it breaks (heuristic number or UI doc section), `file:line` and one
concrete fix. Run by the QA or reviewer player on a built screen, at orchestration row V (verify); "run a few
audits of the UI" runs this skill and its sibling ui in one verify wave. Each finding goes back as a
ticket (step 11).

## Stance

- **You review; you change no code.** Fixes are built with ui after a ticket is cut.
- **You decide alone** the key tasks, the viewports and the severity of each finding.
- **You never decide** to fix a finding in the same pass (law 1).

## Non-negotiables

1. **The audit changes no code; each finding goes back as a ticket (orchestration row F).** A request to rewrite in the same message gets the report first and the rewrite as a ticket for ui (a one line fix stays in the findings). When he asks for an improved design with the review, the P0 and P1 findings feed a proposals round (`references/design-proposals.md`) that he approves before the port builds it exactly. Why: no quote of his; the old skill's review-not-build line.
2. **Screens are real:** screenshots of the running app on sandbox data (never a dev database) at the repo's viewports, every region and state (empty, filled, error, selection, narrow). Driving a browser is part of the audit: use every function of the function list once to learn how it works today before judging it. Why: a code and visual check misses how the screen behaves; the review is a usability test meant to improve the UI and the UX.
3. **The repo's UI doc is the house heuristic,** read first and turned into checks; a control that is not the kit's control for its kind of choice is a finding even when it works. Judge as a new user building their first thing. Why: a screen listed and grouped by the data shape, not by what a new user does first, is the finding a new user hits first.
4. **Nothing lost:** every function of the function list is still reachable, checked row by row. Why: a redesign keeps every panel, button and function, better organized, never fewer.
5. **Every finding has evidence and a fix:** a screenshot region or `file:line`, never "feels off"; a finding with no location is dropped. Why: no quote of his; `references/ui-design-review-rubric.md`.
6. **Severity by the user's task** (`references/ui-design-review-rubric.md`): P0 blocks the task, P1 major difficulty, P2 has a workaround, P3 polish. Unsure between two: would he file a ticket about it? Then the higher one; every P0 and P1 is re-checked on screen. Why: no quote of his; `references/ui-design-review-rubric.md`.
7. **Two lenses, then merge:** lens A, the design review (screens plus source), lens B, the code rules (`references/ui-design-review-code-rules.md`). Why: no quote of his; the old skill's two-lens line.

Violating the letter of a law is violating the law.

## Intake

1. The scope: a section, a screen, a flow or the whole app. Missing: the whole app, region by region.
2. The repo's UI doc, control kit and function list.
3. A running server on sandbox data, and the viewports.
4. The key tasks (3 to 6) a person does there, from the function list or his words.

Fixed: the rubric and the finding row. Free: the order regions are reviewed in.

## Pipeline

Serves orchestration row V. Each Output is a section of `report.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Write the scope and the 3 to 6 key tasks; record the line count of the repo's `git status --porcelain` | `Scope:` and `Tasks:`, `Dirty before:` line | Intake |
| 2 | Capture screenshots of each region and state at every viewport | screenshot list | law 2 |
| 3 | Lens A: score the 10 heuristics 0 to 4, the cognitive load checklist, the house heuristics, walk each key task as two personas, list findings. Lens B: the source of the scope against the code rules, findings as `file:line` | scores and findings | `references/ui-design-review-rubric.md`, `references/ui-design-review-code-rules.md` |
| 4 | Merge: dedupe, note where A and B agree and where B caught what A missed, re-check every P0 and P1 on screen | merged list, and a `Rechecked:` line with one entry per P0 and P1 row, entries separated by `;` | law 6 |
| 5 | Rank: P0 first, then P1, by how many key tasks each touches; pick the 3 to 5 priority issues | priority list | law 6 |
| 6 | Write the report and the short reply | `report.md` | Deliverables |

Do not skip 2 or 4. The director may cast the two lenses to two players (orchestration, Size and cast).

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Findings are generic ("improve hierarchy") | No task in mind | Tie each to a key task step and the element on screen | the skill's own troubleshooting, no measurement |
| Every heuristic scores 2 | No rubric | Score with the per-level text in the rubric | the skill's own troubleshooting, no measurement |
| The code rules list dozens of style nits | Rules applied without the kit | Keep the kit's own choices (a rule the kit overrides is not a finding); cap P3s at the top 10 | the skill's own troubleshooting, no measurement |
| The mockup or screen lost functions | Only surface components were read | Check each function-list row on the built screen | a redesign was planned without first using each panel and button, so functions went missing |
