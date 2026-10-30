# Measuring: the protocol, the leak test, load and switch timing, the server

The steps behind Pipeline steps 1 to 6 and 9. Numbers in brackets are `sources.md` rows. The project's own probes
(the frame counter, the phase split, the draw op count) are named in the project expert's performance reference;
this file says what to record with them.

## Contents

- Scenes
- Frame numbers
- CPU profile
- The N opens leak test
- Load and switch timing
- Server side
- The baseline table, filled example
- JSON for scripts/perf-verdict.py

## Scenes

- Fixed data: a seed or a copied record, a size, the mode (editor, play, the page), the view. Two runs of one scene
  draw the same objects; an unseeded scene compares two different worlds.
- The worst view sets the budget: fully zoomed out on a tile map, the longest list on a page. Zoomed out, a cull
  removes nothing, so the count is at its peak.
- Each switch he names is its own scene: a view setting on and off, a panel open and closed.
- Assert the content first: objects on screen > 0 and the count written down. An empty canvas reports a perfect
  frame (Gotcha 1).

## Frame numbers

- 300 frames or more per run (2.5 s at 120 fps), 3 runs, the median of the run medians, plus p95. Lighthouse CI
  keeps 3 runs and needs `aggregationMethod: "median"` set, its default is "optimistic" [W42].
- Frame budget: 1000 / target fps, so 8.33 ms at 120 fps and 16.67 ms at 60 fps. At 60 fps "all of your work needs to
  be completed inside 10 milliseconds" [W40]; the rest is the browser's.
- A frame ms is the interval between the app's own `requestAnimationFrame` callbacks; on a display capped at H Hz it
  cannot go under 1000 / H.
- Counts beside the ms: objects drawn, draw calls a frame, cache misses a frame. On canvas 2D every `drawImage` is a
  call [14][15]. Batching took one tile map from 573,440 draw calls at about 10 fps to 36 at more than 130 fps [3].
- A machine that rasterises in software (SwiftShader, headless): counts are facts, ms are directions only.
- Long tasks: "Any task that takes longer than 50 milliseconds is a long task" [W2]; long animation frames over
  50 ms through `PerformanceObserver` with `{ type: 'long-animation-frame', buffered: true }` [W16].
- Frame Rendering Stats in DevTools gives fps, dropped frames and "GPU memory usage" in MB [33].

## CPU profile

- The worst scene, one recording, the top 10 functions by self time, each with file:line.
- Never plan from `(program)`: on a GPU bound frame it hides the cost; read Frame Rendering Stats and `about:gpu`.
- Allocation: the Allocation Timeline shows new objects still alive as blue bars [24]. V8 collects the young
  generation with the Scavenger, "most objects die young" [23]; chase per frame allocation only when the timeline
  shows a steady stream.

## The N opens leak test

A leak is "a bug in the page causes the page to progressively use more and more memory over time" [24].

1. Playwright opens a DevTools protocol session: `const cdp = await page.context().newCDPSession(page)` [32];
   `await cdp.send('Performance.enable')` [31].
2. Warm up: open screen A, open B, back to A (first decodes and caches settle).
3. N = 10 pairs: open B, wait for the loading gate and 3 frames, open A, wait the same. 10 pairs: proposed, needs a
   number (no source states a count; a leak of one item per open shows as 10 items). 3 frames: proposed, needs a
   number (the frames after the gate are where first bakes and first caches land).
4. After each pair: `await cdp.send('HeapProfiler.collectGarbage')`, then `await cdp.send('Performance.getMetrics')`
   [31]; keep `JSHeapUsedSize`, `Nodes`, `JSEventListeners`. Every 5 pairs a heap snapshot counts
   `HTMLCanvasElement` and lists retainers ("The Retainers section ... shows objects that point to the object
   selected" [25]). Every 5 pairs: proposed, needs a number (2 snapshots inside 10 pairs show whether the canvas
   count still climbs; "Taking a snapshot always starts with garbage collection" [25], so each one adds a GC).
5. Write the pairs as JSON; `python3 scripts/perf-verdict.py leak pairs.json` prints `leak: ok` when every pair's
   heap is within 10% of pair 1 and listeners and nodes are equal, and the heap does not climb: every second half
   pair above every first half pair FAILs. The 10% is ours; no source states one.
6. On a FAIL: snapshot, open B, back to A, snapshot, view as Comparison [25]; a memlab scenario with `action` open B
   and `back` open A prints the retainer trace (`memlab run --scenario <file>`) [29].

Never read `performance.memory`: deprecated, non standard, Chromium only and "unreliable" [27]; read the heap
through the protocol (step 4). Strict Mode in development runs "one extra development-only setup+cleanup cycle"
[30]: a loop that starts twice in dev is a missing cleanup.

## Load and switch timing

- Marks in the code: `performance.mark` at click, loader gate open, first frame, first frame at full rate;
  `performance.measure(name, start, end)` returns the `duration` [W15].
- Per open: API ms and KB, requests per open (`page.on('request')` counted in the test [W17]).
- Godot's `load()` "blocks your thread, making your game appear unresponsive"; a level switch uses
  `load_threaded_request` and polls progress [34]. Its cache mode reuses resources "from cache if present" [35]:
  decoded pictures stay across screens, per screen state is dropped on the switch.
- `img.decode()` resolves "once the image is decoded" [21]; decode the next screen's pictures before it is shown.
- The switch budget (law 7): open and switch must not grow past the first baseline's ms, logged as a DECISION in
  ORCHESTRA.md; no source gives a number for a map or screen switch. The target ms is the one he sets from the first
  audit's baseline table; until he gives it, the first baseline is the ceiling only and a pass against it is not
  reported as "fast". The open and switch target ms: from his words when he gave one, else the first audit's
  baseline table goes to him as the number to set it from.

## Server side

- Queries per request: a constant per route that does not grow with the rows returned; a count that grows with N
  is N+1. Assert the number in a test. Parallel Ecto preloads run in other processes, so a process dictionary
  counter misses them; count inside a test transaction, where preloads are not parallel [W25].
- `pg_stat_statements` sorted by `total_exec_time`, reset with `pg_stat_statements_reset()` before a run [W31].
- `EXPLAIN (ANALYZE, BUFFERS)` "actually executes the query" [W32]; on an `UPDATE` or `DELETE` wrap it in `BEGIN`
  and `ROLLBACK`, and run it on the test database.
- A foreign key constraint "does not automatically create an index on the referencing columns" [W34]: every key a
  delete or a join uses gets one.
- Cache a read that does not change between opens with an ETag and answer 304 [W21].

## The baseline table, filled example

| Scene | Count | Draw calls | Median ms | p95 ms | fps | Heap pair 1 / 10 MB | Open ms | Queries |
|---|---|---|---|---|---|---|---|---|
| orders list, 5,000 rows, filter off | 5,000 rows | 0 | 6.1 | 7.4 | 164 | 96 / 97 | 410 | 3 |
| same, filter on | 5,000 rows | 0 | 41.0 | 48.3 | 24 | 96 / 131 | 410 | 3 |

The worst row over budget is the second (frame and heap); its cause is named from `checklist.md` before any change.
The numbers here show the shape and were not measured. A project's own scenes and figures live in its expert skill.

## JSON for scripts/perf-verdict.py

- frames: `{"scene": "orders list, filter on", "count": 5000, "runs": [[16.1, 15.9, ...], [...], [...]]}`, one array per
  run of 300 frame ms or more. `python3 scripts/perf-verdict.py frames before.json after.json --budget-ms 8.33`
  prints `keep` when the after median beats the before median by more than the before run spread, else `drop`.
- leak: `[{"heap": 190840832, "listeners": 412, "nodes": 3021, "canvases": 38}, ...]`, one object per pair.
