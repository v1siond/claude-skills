# Review performance, inside review

Finds the places where what he named does work it does not need, ranks them by cost as a number, and gives each
a fix that does less work with the same behaviour. Run by the reviewer player on the merged diff, at
orchestration row Dc; each finding goes back as a ticket (step 11).

## Stance

- **You report, you do not edit.** A fix is shown as code in the finding; a builder gets the ticket.
- **You decide alone** how a cost is measured or estimated; log it as a DECISION line.
- **You never decide** to run a load test or an `EXPLAIN ANALYZE` against a shared database (law 3).

## Non-negotiables

1. **Every cost is a number with a unit,** rows touched, queries per request, calls per frame, or big-O with the real n; it is labelled measured or estimated. Why: "this might be slow" cannot be ranked or checked after the fix; asked to find every N+1 in a codebase, only a count per request or per frame says which one matters. → `references/review-performance-patterns.md`
2. **A repeated loop is the sign of a vaguer computation than intended;** the fix is the precise computation, never a cache stuck on top. Why: every change is held to the most optimal algorithm for its case; a cache over nested loops keeps the wrong algorithm and adds memory and staleness on top.
3. **`EXPLAIN ANALYZE` and load tests run only on the test database,** even when he asks for another one; against a live or shared database (dev, staging, production) only a read-only `EXPLAIN` without ANALYZE, and you answer with the test-database command to run instead. Why: no quote of his; the old skill's Critical line on live or shared databases.
4. **Each fix keeps behaviour identical and names the test that proves it.** Why: no quote of his; the old skill line that a finding without its test is a claim.
5. **The review starts from what runs per request, per loop iteration or per frame;** a finding off those paths is dropped. Why: no quote of his; the Gotchas row on all-micro findings.

Violating the letter of a law is violating the law.

## Intake

1. Target X resolved as in review (Intake table: path, diff, branch, commit, PR, MR).
2. The schema and migrations of every table it queries (indexes).
3. The sizes that matter: rows in production, cells on a map, items per page.

Fixed: the finding shape. Free: the measuring tool (`EXPLAIN ANALYZE` on the test DB, `:timer.tc`, Benchee, the browser performance panel).

## Pipeline

Serves orchestration row Dc. Each Output is a section of `review-performance.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Resolve X; list the sizes | `Reviewed:` and `Sizes:` lines | Intake |
| 2 | Find the hot paths: per-request code, loops over collections, per-frame code, queries | `Hot paths:` file:line list | law 5 |
| 3 | Walk the patterns over each: database (N+1, missing preload, unbounded `Repo.all`, unindexed filter, wide select, count by loading), code (work repeated in a loop, `++` in a reduce, `Enum.at` in a loop, regex per call), frontend (re-render of a large tree per keystroke, unstable effect deps, 10k row lists, finds in loops) | `Candidates:` one line each | `references/review-performance-patterns.md` |
| 4 | Cost each candidate (law 1); measure when cheap, estimate with the real n otherwise | `Cost:` of each | laws 1, 3 |
| 5 | Drop a candidate whose saving is not worth the change, with its cost beside it (the old skill's example: a 2 ms saving on a task that runs once a day) | `Dropped:` candidate and its cost | Gotchas |
| 6 | Write the fix and the test that keeps behaviour | the finding blocks | law 4 |

Do not skip 4 or 6.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Findings are all micro | No hot path identified | Start from what runs per request or per frame | the skill's own troubleshooting, no measurement |
| The index suggestion already exists | The migration was not read | Grep `create index` for the table first | the skill's own troubleshooting, no measurement |

## Deliverables

`<workspace>/score/<ticket>/review-performance.md` (no ticket: the reply), sections above, then one block per finding:

```
### 1. The style list runs one tile query per style
- File: lib/game_web/controllers/tileset_controller.ex:18
- Type: performance (N+1)
- Severity: Medium
- Cost: 1 + N queries per load of the style list, N = styles listed (2 built-in ones in the seeder, plus each imported one); estimated, not run
- Fix:
  tiles = styles |> Enum.map(& &1.id) |> Catalog.list_tiles_for_tilesets()   # one query, grouped by style id
- Proof: test/game_web/controllers/tileset_controller_test.exs "each tileset carries its tiles (with image_url) + compositions" must stay green
```

The example is a real defect from a game repo: a later commit fixed it, and file:line is where the per-style `Catalog.list_tiles_for(ts.key)` call stood before that commit. In your finding the Cost is `measured` only for a run you made; otherwise `estimated`, with N from the table or the fixture you counted.

Severity: **Critical** times out or exhausts memory at real sizes. **High** a delay the user sees on a normal path.
**Medium** wasteful at today's sizes, breaks at the next 10x. **Low** small and local. The last line: files
reviewed and counts per severity.
