---
name: performance-expert
description: Makes a web app or a game measurably fast, invoked before any performance change or audit is planned, measure first, budgets as numbers, the N opens leak test, the render loop, caches with bounds, merged data, the server side, every after number beside its before. Run by the builder and the QA player, with the project's expert skill. Use when he says "performance expert", "performance audit", "blazingly fast", "memory leak", "fps", "frame rate", "maps don't open quickly", "takes forever to load". Do NOT use for a diff review for N+1 or a slow query (review) or a bug with no speed or memory number in it (bug-investigation).
metadata:
  author: Alexander Pulido
  version: 1.4.0
  triggers: ["performance expert", "performance audit", "performance optimization", "performance optimisation", "fix the performance", "the performance is", "performance atrocit*", "performance attrocit*", "blazingly fast", "make it fast", "memory leak*", "leaks memory", "fps", "120fps", "60fps", "frame rate", "framerate", "frame budget", "drops frames", "stutter*", "laggy", "heap snapshot", "heap grows", "maps don't open quickly", "don't open quickly", "open quickly", "takes forever to load", "take forever to load", "slow to load", "load time", "map switch*", "worse every time", "worse everytime", "render loop", "draw calls", "re-rendering"]
  sources: the performance research of 2026-10-27 and 2026-10-28 (references/sources.md)
---

# Performance expert

Turns "it is slow" into a baseline table, a budget as a number, one change at a time and an after table beside the
before, for the editor, the play loop, the page and the server. Run with the project's expert skill, which holds that
project's probes, budgets and file:line leads.

## When to use

- He names speed, fps, a frame drop, lag, load or switch time, memory growth or a leak.
- A ticket's work is a performance change or an audit (`/home/visiond/projects/claude/skills/global/orchestration/references/skill-map.md` row performance work).

## When not to use

- A review of a diff for N+1, a slow query or a missing index: review (its performance lens).
- A wrong picture or a broken feature with no ms, fps or MB in it: bug-investigation.
- The test file that turns a met budget into a gate: testing-standard writes it; this skill gives the number.

## Stance

- **You measure, then change.** No line of a fix is written before the baseline table exists.
- **You decide alone:** the scene list, the worst item to take first, the probe; log each as a DECISION.
- **You never decide:** dropping a visual feature, a lower budget, or a move to WebGL or another engine. Each goes to
  him with the number that failed.

## Non-negotiables

1. **No change before a baseline: scene named, content count > 0, median and p95 frame ms of 3 runs of 300 frames; the spread of the 3 run medians is the noise a gain must beat.** Why: an audit with no baseline cannot say whether a change helped, and deeper audits of the editor and play mode start from numbers. → `references/measuring.md` Frame numbers
2. **The budget is a number: frame ms = 1000 / target fps (8.33 ms at 120 fps), a long task is over 50 ms.** Why: the visual range once ran at 120 fps or more and later stopped at 15; with no budget as a number, the fall went unnoticed. → `references/measuring.md`
3. **Counts before ms: objects stored, objects drawn, draw calls a frame, queries per request, requests per screen.** Why: maps are built with the fewest cells and tiles possible, the way houses are; only a count shows whether they are. → `references/checklist.md` items 1, 2
4. **Memory is proved by the N opens test: 10 pairs, GC before each read, every pair's heap within 10% of pair 1, listeners and nodes equal, and the heap does not climb: every second half pair above every first half pair FAILs.** Why: the editor got slower on every open of the app, and every memory leak is fixed; a leak shows as heap climbing across opens. → `references/measuring.md` The N opens leak test
5. **Every cache has a size cap or a named clear event, and every effect returns its cleanup.** Why: an unbounded cache or an effect with no cleanup grows memory on every open. → `references/checklist.md` items 10, 11
6. **One change between before and after, same scenes and runs; kept only when `scripts/perf-verdict.py frames` prints `keep`; a gain at or under the printed `noise` is a `drop`. A `keep` with the after median over the budget stays kept, the script prints `FAIL: kept, but the after median is over the <ms> ms budget` (exit 1), and the work goes back to step 6 for the next change.** Why: the goal is a game that is blazingly fast by measurement; a change kept on feel can be noise or a regression. → `scripts/perf-verdict.py`
7. **Open and switch are timed (click to first full rate frame in ms, API ms and KB) and must not grow past the first baseline's ms, logged as a DECISION; the target ms is the one he sets from the first audit's baseline table; until he gives it, the first baseline is the ceiling only and a pass against it is not reported as "fast".** Why: maps took 10 s or more to open, worst when going from one map to another. → `references/measuring.md` Load and switch timing
8. **The server is counted: queries per request constant in the row count, an index on every foreign key a delete or join uses.** Why: missing indexes, and many individual requests where one merged query returns the same data, slow every load. → `references/measuring.md` Server side
9. **Re-renders are counted per action with the React Profiler; a render with unchanged props is a finding.** Why: pages re-rendered too often, and the wrong components re-rendered at the wrong moment. → `references/checklist.md` item 16
10. **A met budget becomes a gate test: a backend budget always gets one (backend is test driven in every batch); a frontend budget gets one in `add browser tests`, otherwise a `qa.md` row with the number.** Why: performance problems raised long before went unchecked and came back; a gate keeps a met budget met. → testing-standard

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "It feels faster now" | Law 6. Run `perf-verdict.py frames before.json after.json`. |
| "I'll add a cache, that will fix it" | Laws 1 and 5. Baseline first; the cache gets a cap. |
| "Listener adds and removes balance, so no leak" | Law 4. Counts prove nothing; run the 10 pairs. |
| "The test scene hits 144 fps" | Law 1. Count > 0 first (Gotcha 1). |
| "Three fixes in one go saves time" | Law 6. One change, or the gain has no owner. |
| "Switch to WebGL" | Stance. Canvas plan measured first; his call with the number. |
| "The query is fast on dev" | Law 8. Count queries per request; plan on realistic rows. |

## Intake

1. His words: the screen, the mode, the view and the number he saw ("120 to 15 fps").
2. The target fps or ms; none given: 120 fps (8.33 ms) for a game view, INP at or under 200 ms for a page. The open and switch target ms: from his words when he gave one, else the first audit's baseline table goes to him as the number to set it from.
3. The project expert's performance reference: probes, budgets, leads, the e2e perf command.
4. His data: a seed or a copied record, its size; his dev server URL for step 9.

Fixed: measure first, the numbers of laws 2 and 4, one change. Free: the scene list, the probe, the fix.

## Pipeline

Serves orchestration row D1 (steps 1 to 6), row D4 (7), row Dc (8, 10) and row V (9).

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Scenes: fixed data, size, mode, the worst view, each switch he names on and off | `score/<ticket>/perf-baseline.md` Scenes | `references/measuring.md` Scenes |
| 2 | Assert count > 0; record counts, median, p95, fps; 3 runs; the spread of the run medians (max minus min) is the noise | Baseline table and `before-<scene>.json`; noise ms | `references/measuring.md` |
| 3 | CPU profile the worst scene: top 10 self time functions, file:line | Profile section | `references/measuring.md` CPU profile |
| 4 | N opens test, 10 pairs | `pairs.json` of 10 pairs, `HeapProfiler.collectGarbage` before each read; `perf-verdict.py leak` prints `leak: ok` only when every pair's heap is within 10% of pair 1, listeners and nodes are equal and the heap does not climb (every second half pair above every first half pair FAILs) | `references/measuring.md` |
| 5 | Time open and switch; count queries and requests per open | Load section | `references/measuring.md` |
| 6 | Pick the single worst item over budget; name its cause from the checklist. A wait already cut to within 2 times its budget (a 10 s open now 2 to 3 s) gets no further round on the wait itself: the rest is hidden the way games do (a transition between maps, the loader drawn into it) and the next worst item is picked; a small gain is not chased while bigger items wait | Worst line: item, number, the checklist row, and the engine row of `references/checklist.md` How engines do it; no row fits: run skill research on how two engines solve it | `references/checklist.md` (items, then How engines do it) |
| 7 | Brief: the scene, the budget as a number, the command and its pass output | the brief's check field | orchestration row D4 |
| 8 | After the one change: the same scenes and runs; after beside before | after table beside before; `perf-verdict.py frames` prints `keep`, the gain above the printed `noise` | law 6 |
| 9 | QA on his dev server: fps and heap on his page with his data | `qa.md` row with both numbers | orchestration row V |
| 10 | Gate the met budget: a test (backend always, frontend in `add browser tests`), else a `qa.md` row with the number | the test path or the `qa.md` row, in the after table | testing-standard (owns the test mode) |

Do not skip 1, 2 or 8. A `drop` at step 8 reverts the change and goes back to step 6.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| 1. A perfect frame time | The scene drew 0 objects | Assert count > 0 first | an e2e perf gate asserts the tile count first because an empty canvas reported a perfect frame (the expert skill's rendering reference of a project in the private overlay) |
| 2. Drawing tuned, no gain | Too many objects drawn | Count first, merge or batch | a count defect fixed with no drawing change took a play loop over its 120 fps budget, "The count was the defect, not the drawing" (the figures in the expert skill's rendering reference of a project in the private overlay) |
| 3. 10 fps zoomed out | One draw call per tile | Batch into chunks | Godot PR 92797: 573,440 calls at about 10 fps to 36 at more than 130 fps [3] |
| 4. Pairs balanced, leak still there | Counted the code | Run the 10 pairs | grep over the app code: 42 `addEventListener` against 41 `removeEventListener`, while the editor still got slower on every open |
| 5. Profile says `(program)` | GPU bound frame | Frame Rendering Stats, `about:gpu` | "Never plan off `(program)`" (the expert skill's rendering reference of a project in the private overlay) |
| 6. Headless ms disagree with his page | The headless browser rasterises in software (SwiftShader) | Counts from the headless run, ms from his page (step 9) | "report counts as engine facts and milliseconds as measured here directions" (the expert skill's rendering reference of a project in the private overlay) |

## Deliverables

- `score/<ticket>/perf-baseline.md`: Scenes, Baseline table, Profile, Leak, Load, Worst line.
- `before-<scene>.json`, `after-<scene>.json`, `pairs.json` beside it; the `perf-verdict.py` output pasted.
- The after table in `score/<ticket>/control.md`; the gate test path or its `qa.md` row; fps and heap MB on his page in `qa.md`.

## Check it before you show it

| # | Check | Pass | A FAIL goes back to |
|---|---|---|---|
| 1 | `python3 scripts/perf-verdict.py frames before.json after.json --budget-ms <ms>` | `keep`; the after line prints `pass` | step 6 |
| 2 | `python3 scripts/perf-verdict.py leak pairs.json` | `leak: ok`: 10 pairs, GC before each read, every pair's heap within 10% of pair 1, listeners and nodes equal, heap not climbing | step 6 |
| 3 | Every baseline and after row has count > 0 | the script printed no `FAIL ... count` | step 2 |
| 4 | Test mode allows a test: the gate test run on the old code; else the `qa.md` row | the test fails above the budget and passes after; else the row holds the number | step 10 |
| 5 | His page, his data, his dev server | `qa.md` fps at or under the frame budget of law 2 (8.33 ms at 120 fps); the 10 pairs read on his page print `leak: ok` and `qa.md` holds the heap MB of pair 1 and pair 10 | step 9 |

## Critic loop

A separate read-only judge gets his ask, `perf-baseline.md`, the after table and the diff. Default reject. Axes 1 to
10: measured before changed; budgets as numbers; one change per table; leak proved by pairs; his page checked. It names
the 3 worst problems with file:line and the smallest fix each. Below 8 on an axis: back to step 2, until every axis is 8
or more (`/home/visiond/projects/claude/skills/global/orchestration/references/critic.md`).

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py` prints `ok   performance-expert`.
- [ ] `perf-baseline.md` exists before the first changed line, with counts > 0 and 3 runs per scene.
- [ ] Budgets written as ms, fps, MB or a count; `perf-verdict.py frames` prints `keep` for every kept change.
- [ ] `perf-verdict.py leak` prints `leak: ok` on 10 pairs.
- [ ] Open and switch ms, queries and requests per open in the table.
- [ ] Each met budget has a gate test (backend always, frontend in `add browser tests`), else a `qa.md` row with the number; `qa.md` holds fps and heap on his page.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/measuring.md` scenes, frames, profile, the N opens test, open and switch, server, the JSON shapes.
- `references/checklist.md` 20 items, each a measured yes or no, and how engines do it.
- `references/sources.md` every source cited, [n], [W<n>], [E<n>].
- `scripts/perf-verdict.py` (Python 3.8 or later, standard library): `frames` and `leak` verdicts.
- Skills: orchestration, testing-standard, review, bug-investigation; the project's expert skill.

## Evals

Trigger rows: the performance-expert rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json`;
scores in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-results.md`. Behaviour scenarios, written before the text:

| # | Scenario | RED baseline | GREEN pass rules |
|---|---|---|---|
| P1 | "The editor is slow zoomed out, add a cache to the draw and ship it" | Gotcha 2: hours on drawing speed while the count was the defect | baseline table before code; counts of objects and draw calls named; one change; `perf-verdict.py frames` named |
| P2 | "It gets worse every time I open the app; listener adds and removes balance" | Gotcha 4: balanced pair counts, leak still there | plans 10 pairs with GC before each read; 10% heap and equal listeners as the pass; names a cache bound |
| P3 | "My change took the test scene from 60 to 144 fps, mark it done" | Gotcha 1: an empty scene reports a perfect frame | asks for count > 0 first; 3 runs and the noise check; asks for his page (step 9) |

Results, v1.1.3, claude-sonnet-5-5, 1 run per arm, scored by hand on the pass rules above, P1 with the sentence "The folder you are in is empty; plan the work you would do." added to its prompt: P1 with 4/4, without 1/4; P2 with 3/3, without 0/3 (the 10% heap and equal listeners pass stated); P3 with 3/3, without 0/3.

Results, v1.1.2, claude-sonnet-5-5, same method and the same P1 sentence: P1 with 4/4, without 1/4; P2 with 2/3 (the 10% heap and equal listeners pass not stated), without 0/3; P3 with 3/3, without 0/3.

Results, v1.1.0, claude-sonnet-5-5, 1 run per arm, scored by hand on the pass rules above: P1 with 4/4, without 0/4
(it found an empty folder and asked for the repo); P2 with 3/3, without 0/3 (blamed saved state, no pairs, no GC, no
threshold); P3 with 3/3, without 1/3 (his hardware named; no count check, no noise check). The v1.1.0 run had no empty folder sentence in P1. Method and outputs:
`/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md` section performance-expert.
