# engineering-standards evals

## Contents

- Trigger queries
- Behaviour scenarios
- Results

## Trigger queries

Rows in the style of skill-craft `references/trigger-queries.json`; the JSON copy waiting for the central file is
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-b-trigger-rows.json`.

| # | Query | cwd | Should trigger |
|---|---|---|---|
| 1 | no nested ifs, use guard clauses, write it properly | api | yes |
| 2 | clean code and SOLID principles for this module | api | yes |
| 3 | refactor the parser, this is messy | api | yes |
| 4 | credo is complaining about nesting in the importer | api | yes |
| 5 | follow the coding standards on the new resolver | api | yes |
| 6 | ui development for the settings panel, frontend code only | app | yes |
| 7 | guard clause this function, no else | api | yes |
| 8 | write it properly this time, one owner for the limit | app | yes |
| 9 | review my branch | api | no (review) |
| 10 | is this endpoint secure | api | no (review) |
| 11 | add tests for the payout calculator | api | no (testing-standard) |
| 12 | show me three options for the dashboard | app | no (ui) |
| 13 | why is the export slow | api | no (review) |
| 14 | write the MR description | api | no (writing) |
| 15 | draw the component tree for the editor | game | no (engineering-standards) |


## Behaviour scenarios

Run per skill-craft `references/behaviour-evals.md`: one run with the skill, one without, the same prompt, both
scored on the same assertions.

How each run is made (2026-10-25, loop 4c, the director's DECISION after 4b: a behaviour eval measures
following once the skill is loaded; loading is the trigger test's job): `claude -p "<prompt>" --model sonnet
--restricted --disable-slash-commands --tools Read,Grep,Glob --output-format stream-json --verbose
--no-session-persistence --add-dir <repo> --strict-mcp-config --mcp-config '{"mcpServers":{}}'
--append-system-prompt-file <sp file>`, cwd an empty folder, 3 runs per arm per scenario. Without: the sp file is
the role line only. With: the same role line, then the line "Skill engineering-standards loaded:" and the copy's SKILL.md
text, the way the Skill tool loads it, plus `--add-dir <copy of this skill folder>` so the references are
reachable; no order to read or follow it. Role lines, the same in both arms: E1 "You are the backend builder.", E2 "You are the frontend builder.", E3 "You are the director.". The copy is the shipped
text of the version in each Results table minus `references/evals.md` and minus the SKILL.md Evals section; `diff -r` against the shipped
folder shows only those two (`skillcopy.diff`). Script, prompts and transcripts are in the private workspace
(`run-clean5.sh`, `sp/`, `prompts/`; loop 4c: `superseded/loop4c/all5.sh` and `superseded/loop4c/<id>-<arm>-<n>.jsonl` and `.cmd`; loop 4d: `all6.sh` and `superseded/loop4d/`; loop 5: `superseded/loop5/all7.sh` and `superseded/loop5/`; loop 6: `all8.sh` and `runs/<id>-<arm>-<n>.jsonl` and `.cmd`). `summ2.py` proves per run:
the `.cmd` file holds the sp file's sha256 and size, and the first request's prompt tokens are about 5,000 to
5,900 higher in each with run than in its without twin, the size of the skill text; each init event lists 0 MCP
tools; each without run shows 0 reads under `/skills/` and 0 memory reads. The five user mods (agents-live,
token-guard, cc-plugin-agents-md, cc-plugin-telemetry, cc-plugin-plugin-authoring) still load in both arms;
`--restricted` does not drop them. Every prompt opens "Read-only: edit nothing, run nothing. Repo: <repo>." A
run passes when it meets every assertion of its scenario.

### E1. An Elixir branch
Repo ~/projects/game. Prompt: "Write an Elixir function for
lib/game/catalog/tile_source.ex that returns [] when no tile has a colour setting, otherwise returns {label,
colour} for each tile that has one. Show the code and the check you would run before reporting it done."
RED (09-13): `if ... do ... else [] end` in `tile_source.ex`.
Assertions:
1. 0 `else` blocks.
2. 0 `if`, `case` or `cond` whose branch returns `[]`.
3. Names `scripts/check-diff.sh` with `total: 0` as a check.

### E2. A frontend value
Repo ~/projects/game. Prompt: "Raise the ruin minimum site size from 6 to 8 cells
(RUIN_MIN_SITE in assets/game/engine/stageGenerator.ts). Show the change."
RED: `export const RUIN_MIN_SITE = 6` at `assets/game/engine/stageGenerator.ts:2143`, a frontend copy of a
generator setting, the same shape as the roofReveal.ts constants (Gotchas, saved 09-24).
Assertions (loop 4, from law 5 as it stands: one owner per fact, the move in the same change only when the brief
owns the backend file, else the report asks):
1. Names the const as a frontend copy and names where the backend serves it or would serve it: an existing
   file, column or served key, or the served `terrain` template next to `ruinPatch`. A bare "the backend" scores
   0 (loop 5 wording; all 12 E2 runs rescored on it).
2. Moves it, or asks for the move.
3. Changes nothing outside the files the brief names unless it asks first.

### E3. An upload feature
Repo ~/projects/api. Prompt: "Add photo upload to the admin profile edit. Plan it, no
code."
RED (2026-06-26): a parallel upload system was built instead of the onboarding flow.
Assertions:
1. A search of the code comes before the plan.
2. A `Reused:` line with file:line.
3. No parallel upload system, in law 4's words: fails on a new resource, route, LiveView, field or migration for
   the same job; passes work placed in the flow and the screen the grep found, a handler body moved into the
   shared upload module included, his 06-26 fix, reuse the onboarding upload flow (loop 6 wording).

### Results

Skill loaded (loop 6, the GREEN record for E3: skill 3.0.8, `Reused:` asked as the plan's first line, assertion 3
in law 4's words as written above, the 4c method from a rebuilt copy, all 6 runs in one wave):

| Date | Skill version | Model | Runs per arm | E3 with | E3 without |
|---|---|---|---|---|---|
| 2026-10-25 | 3.0.8 | claude-sonnet-5-5 | 3 | 3 of 3 pass | 0 of 3 pass |

Assertions met per run (with; without): E3 3, 3, 3; 2, 1, 1.

- Every with run reads the code first and opens on a `Reused:` line with file:line; `scripts/check-report.sh`
  prints `reused: 1` on all 3 and 0 on all 3 without runs.
- Assertion 3, with: run 1 links the Event Console `user_edit_modal` to the existing impersonation into
  `/profile/edit`; runs 2 and 3 add the upload to the modal on the shared `PhotoUpload` functions and move the
  dashboard save sequence into `PhotoUpload`. No run adds a route, LiveView, resource, field or migration. Run 2
  adds an `upload_name` argument to `consume_photos`, so the loop 4d wording ("new args") would fail it.
- Without: run 1 plans into `user_edit_modal` on the shared functions (assertion 3 passes) but writes no
  `Reused:` line and copies the accept list and the 3-photo cap into its `allow_upload`; runs 2 and 3 plan a new
  admin LiveView on a new `live` route.
- Rescore of the 4c, 4d and loop 5 E3 runs on this assertion 3: no score changes. 4c with run 3 and loop 5 with
  runs 1 and 3, read before as a judgement, are plain passes now.
- Transcripts in the private workspace.

Skill loaded (loop 5, the GREEN record for E3: skill 3.0.7, law 4 "grep the job" and the Gotcha naming the
existing screens, assertions 1 to 3 as written, the 4c method, all 6 runs in one wave):

| Date | Skill version | Model | Runs per arm | E3 with | E3 without |
|---|---|---|---|---|---|
| 2026-10-25 | 3.0.7 | claude-sonnet-5-5 | 3 | 1 of 3 pass | 0 of 3 pass |

Assertions met per run (with; without): E3 3, 2, 2; 1, 1, 1.

- All 3 with runs grep the job (`upload`, `photo_grid`, `user_edit_modal`, `impersonat`), find `/profile/edit` and
  the Event Console `user_edit_modal` (`demo_sandbox.ex:8758`), and plan into them with no new route or LiveView,
  so assertion 3 passes in all 3. Runs 1 and 3 add the upload to the modal on the shared `PhotoUpload`
  functions, moving the dashboard handler body into a shared module; run 2 links the modal to the existing
  impersonation into `/profile/edit`. Assertion 2: only run 1 writes a `Reused:` line with file:line
  (`scripts/check-report.sh` prints `reused: 1`); run 2 names the files in a sentence, run 3 writes none.
- All 3 without runs plan a new `AdminLive.UserEdit` on a new `live` route: assertion 3 fails.
- Transcripts in the private workspace.

Skill loaded (loop 4d, the GREEN record for E2 and E3: skill 3.0.6 with check rows 4 and 5, E3 assertion 3 in
law 4's words, the 4c method, all 12 runs in one wave):

| Date | Skill version | Model | Runs per arm | E2 with | E2 without | E3 with | E3 without |
|---|---|---|---|---|---|---|---|
| 2026-10-25 | 3.0.6 | claude-sonnet-5-5 | 3 | 2 of 3 pass | 0 of 3 pass | 0 of 3 pass | 0 of 3 pass |

Assertions met per run (with; without): E2 3, 2, 3; 1, 1, 1. E3 2, 1, 1; 1, 1, 1.

- E2: with runs 1 and 3 name `RUIN_MIN_SITE` as a frontend copy next to the served `terrain.ruinPatch` and offer
  the move; run 2 says it should have "one backend owner" and names no place, so assertion 1 fails (loop 5
  wording gives the same scores). No run, either
  arm, writes a `Facts:` line; check 5 asks for one on this change.
- E3: every run, both arms, plans a new admin LiveView on a new `live` route, so assertion 3 fails in all 6. The
  runs say no admin profile edit screen exists; the repo has one, the Event Console `user_edit_modal`
  (`demo_sandbox.ex:8758`), and admins edit photos by impersonating into `/profile/edit` (memory
  project_ashadmin_file_upload). The runs grepped the screen name in place of the job. Assertion 2: only with run 1 lists file:line under a
  `**Reused:**` heading; run 2 writes the grep with no file:line, run 3 writes none.
- The 3.0.6 checks 4 and 5 grepped plain line starts and printed 0 on all 12. Loop 5 replaced them with
  `scripts/check-report.sh` (bullets, bold and backticks stripped, the labelled line and the lines under it): on
  every 4c and 4d run it prints `reused:` above 0 on exactly the two runs that wrote a `Reused:` label with
  file:line (4c E3-with-3: 1, 4d E3-with-1: 8), and 0 on the planted negatives. (transcripts in the private workspace).

Skill loaded (loop 4c, 3.0.5; E3 rescored in loop 4d on the new assertion 3):

| Date | Skill version | Model | Runs per arm | E1 with | E1 without | E2 with | E2 without | E3 with | E3 without |
|---|---|---|---|---|---|---|---|---|---|
| 2026-10-25 | 3.0.5 | claude-sonnet-5-5 | 3 | 3 of 3 pass | 0 of 3 pass | 3 of 3 pass | 0 of 3 pass | 1 of 3 pass | 0 of 3 pass |

Assertions met per run (with; without): E1 3, 3, 3; 2, 2, 2. E2 3, 3, 3; 1, 1, 1. E3 1, 1, 3; 1, 1, 1 (before
the rescore 1, 1, 2; 1, 2, 2: 3 of 6 E3 runs change).

- E1: all 6 runs write the code with no branch; only the with runs name `check-diff.sh` with `total: 0`. That
  lead is self-referential: the assertion asks for a script only this skill ships.
- E2: each with run names `RUIN_MIN_SITE` as a frontend copy of a value the backend should own, next to the
  `ruinPatch` served with the template (loop 5 wording gives the same scores), keeps to the one file, and offers the move. Without changes 6 to 8 and names no owner. No
  with run writes the `Facts:` line law 5 asks for (not an assertion; flagged in the report).
- E3, rescored on the new assertion 3: with run 3 adds the upload to the existing `user_edit_modal` in
  `event_index.ex`, no new route or LiveView, and extends the shared `PhotoUpload` with `consume_photos/2`; scored
  a pass, read as extending the shared module (a judgement; strictly "new args" would fail
  it). With runs 1 and 2 and all 3 without runs add a new admin LiveView on a new `live` route: fail. Assertion 2:
  with runs 1 and 2 write no `Reused:` line with file:line (SKILL.md Pipeline step 2 and Deliverables).
  (transcripts in the private workspace).

Skill available, not loaded (loop 4b, the discoverability measure: both arms "You are the director.", the with
arm only adding `--add-dir <copy>`, no pointer):

| Date | Skill version | Model | Runs per arm | E1 with | E1 without | E2 with | E2 without | E3 with | E3 without |
|---|---|---|---|---|---|---|---|---|---|
| 2026-10-25 | 3.0.5 | claude-sonnet-5-5 | 3 | 0 of 3 pass | 0 of 3 pass | 0 of 3 pass | 0 of 3 pass | 0 of 3 pass | 0 of 3 pass |

The with arm opened the copy in 0 of 9 runs. Assertions met per run (with; without): E1 2, 2, 2; 2, 2, 2. E2 1,
1, 1; 1, 1, 1. E3 1, 2, 1; 1, 1, 1. (transcripts in the private workspace).

Caveats: 3 runs per arm. The prompts are read-only, so no run could execute `check-diff.sh` or a gate. The five
user mods load in both arms.

Superseded, kept under `scratch/superseded/` and not counted: loop 4 (`loop4/`, 3.0.4, claude-opus-5-5, 1 run
per arm, a pointer prompt to read SKILL.md), off the logged method on model, run count and the pointer; loop 3
(`loop3-runs/`), which ran with the MCP servers loaded and scored E2 on assertions fitted to a law 5 sentence
since withdrawn; the run before it (`claude -p` with CLAUDE.md, a project MEMORY.md and stale premises loaded).
