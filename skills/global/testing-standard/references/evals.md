# testing-standard evals

## Contents

- Trigger queries
- Behaviour scenarios
- Results

## Trigger queries

Rows in the style of skill-craft `references/trigger-queries.json`; the JSON copy waiting for the central file is
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-b-trigger-rows.json`.

| # | Query | cwd | Should trigger |
|---|---|---|---|
| 1 | add tests for the payout calculator and cover it | api | yes |
| 2 | write the tests red first for the new export | api | yes |
| 3 | tdd the backend for the region generator | game | yes |
| 4 | test first, then build the quota endpoint | api | yes |
| 5 | define the scenarios for the invite flow | app | yes |
| 6 | we're writing too many tests, just build it | game | yes |
| 7 | no frontend tests for this batch, manual qa only | app | yes |
| 8 | add a property test for rotate four times | game | yes |
| 9 | unit and e2e for the login page | app | yes |
| 10 | are these tests any good | api | no (review) |
| 11 | the wallaby suite hangs, chrome leaked | api | no (the project's own docs) |
| 12 | review my branch | api | no (review) |
| 13 | the river looks off near the bridge | game | no (the project's own docs) |
| 14 | why does the agents tab show the producer code | api | no (bug-investigation) |
| 15 | write the release notes for 2.4 | app | no (writing) |


## Behaviour scenarios

Run per skill-craft `references/behaviour-evals.md`: one run with the skill, one without, the same prompt, both
scored on the same assertions.

How each run is made (2026-10-25, loop 4c, the director's DECISION after 4b: a behaviour eval measures
following once the skill is loaded; loading is the trigger test's job): `claude -p "<prompt>" --model sonnet
--restricted --disable-slash-commands --tools Read,Grep,Glob --output-format stream-json --verbose
--no-session-persistence --add-dir <repo> --strict-mcp-config --mcp-config '{"mcpServers":{}}'
--append-system-prompt-file <sp file>`, cwd an empty folder, 3 runs per arm per scenario. Without: the sp file is
the role line only. With: the same role line, then the line "Skill testing-standard loaded:" and the copy's SKILL.md
text, the way the Skill tool loads it, plus `--add-dir <copy of this skill folder>` so the references are
reachable; no order to read or follow it. Role lines, the same in both arms: T1 and T2 "You are the director.", T3 "You are the backend builder.". The copy is the shipped
text of the version in each Results table minus `references/evals.md` and minus the SKILL.md Evals section; `diff -r` against the shipped
folder shows only those two (`skillcopy.diff`). Script, prompts and transcripts:
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-b/scratch/`
(`run-clean5.sh`, `sp/`, `prompts/`; loop 4c: `superseded/loop4c/all5.sh` and `superseded/loop4c/<id>-<arm>-<n>.jsonl` and `.cmd`). `summ2.py` proves per run:
the `.cmd` file holds the sp file's sha256 and size, and the first request's prompt tokens are about 5,000 to
5,900 higher in each with run than in its without twin, the size of the skill text; each init event lists 0 MCP
tools; each without run shows 0 reads under `/skills/` and 0 memory reads. The five user mods (agents-live,
token-guard, cc-plugin-agents-md, cc-plugin-telemetry, cc-plugin-plugin-authoring) still load in both arms;
`--restricted` does not drop them. Every prompt opens "Read-only: edit nothing, run nothing. Repo: <repo>." A
run passes when it meets every assertion of its scenario.

### T1. A batch with no Decision
Repo ~/projects/api (its workspace has no ORCHESTRA.md test rule). Prompt: "Add an
admin setting for the maximum photos per profile: the backend stores it, the admin page shows a number field.
This batch has no Decision line on tests in ORCHESTRA.md. Plan the tests you would write, stop before code."
RED (10-21 05:47): players wrote browser tests first and looped on them with no feature to try.
Assertions:
1. States `Test mode: default (no Decision)`.
2. A backend test seen red before the logic.
3. 0 frontend, component, page or browser tests planned.

### T2. A default batch with a backend row
Repo ~/projects/game. Prompt: "ORCHESTRA.md Decisions for this batch: D7 Test mode batch 4: default. Plan the
tests for a new day length setting: the backend validates and stores it (1 to 48 hours), the editor shows a
slider. Stop before code."
RED (10-30): a batch mode was read as a switch for backend TDD, and backend tests were left out of a batch
whose mode only set the frontend.
Assertions:
1. States `Test mode: default (D7)`.
2. Plans backend tests for the day length rule (in range, out of range, absent), each seen red before the logic.
3. Plans 0 frontend tests of any kind for the slider; the slider is checked by QA in the browser.

### T3. A cap test that already passes
Repo ~/projects/api. Prompt: "ORCHESTRA.md Decisions for this batch: test mode default.
Write the backend test that ProfileImageReview refuses a photo past the cap
(lib/app/accounts/profile_image_review.ex). Show the test."
RED (law 7, Gotchas 09-12): a new test against code that already holds the rule passes on its first run and
proves nothing. Verified in the without arm before scoring: it wrote two tests and gave no step that sees either
fail. Two premises tried first did not reproduce RED and were dropped (`runs/t3-candidates/`): the itemCatalog
prompt with the fallback unnamed (without wrote the twin anyway) and an editor_settings PUT (without read the row
back).
Assertions:
1. States how each new test is seen red (pre-fix code, or a reverted or mutated line).
2. Names the code line whose change turns the test red.
3. A refusal test has a positive twin (an allowed case under the cap).

### Results

Skill loaded (loop 4c, the GREEN record; the T2 columns here and below score the retired T2):

| Date | Skill version | Model | Runs per arm | T1 with | T1 without | T2 with | T2 without | T3 with | T3 without |
|---|---|---|---|---|---|---|---|---|---|
| 2026-10-25 | 3.0.5 | claude-sonnet-5-5 | 3 | 3 of 3 pass | 0 of 3 pass | 3 of 3 pass | 1 of 3 pass | 3 of 3 pass | 0 of 3 pass |

Assertions met per run (with; without): T1 3, 3, 3; 0, 0, 0. T2 3, 3, 3; 3, 2, 2. T3 3, 3, 3; 0, 0, 0.

Check 1 on these results: the 3.0.5 `grep -c '^Test mode:'` printed 0 on all 6 T1 and T2 with runs (they wrote
`**Test mode: ...**` or `` `Test mode: ...` ``). Loop 5 (3.0.6) `scripts/check-report.sh` prints `test mode: 1` on
those 6 and 0 on the other 12 runs. Loop 6 (3.0.7) adds the Decision: against a no-Decision ORCHESTRA.md for T1
and T3 and a Decision line for the retired T2 (`scratch/plant6/`), it prints `match: yes` on the same 6
and `match: no` on the other 12; the T3 with runs show the test and write no mode line. Plants in
`scratch/plant6/` and the critic's `tn1`, `tn2`, `tp1`: a quoted brief line (`> Test mode: default`) is skipped,
so `tn2` passes, and a mode that differs from the batch Decision exits 1.

- T1 with: `Test mode: default (no Decision)`, each backend test red first (a stub so it fails on an assertion,
  not a compile error), and 0 tests for the admin LiveView, left to QA. Without: no mode line, no red step, and
  LiveView tests for the admin page in all 3.
- T2 (retired 10-30, a batch that dropped all tests): all 6 runs planned 0 test files and kept gates, critic and
  hand QA. The new T2 above replaces it and has not been run yet.
- T3 with: each run gives the mutation that turns the test red (`check_cap/3`, `:672`, `slots_remaining > 0`)
  and points to or writes an allowed twin. Without: a test, or the existing `:51` one, with no red step, no code
  line, and no allowed case.

Skill available, not loaded (loop 4b, the discoverability measure: both arms "You are the director.", the with
arm only adding `--add-dir <copy>`, no pointer):

| Date | Skill version | Model | Runs per arm | T1 with | T1 without | T2 with | T2 without | T3 with | T3 without |
|---|---|---|---|---|---|---|---|---|---|
| 2026-10-25 | 3.0.5 | claude-sonnet-5-5 | 3 | 3 of 3 pass | 0 of 3 pass | 3 of 3 pass | 1 of 3 pass | 0 of 3 pass | 0 of 3 pass |

The with arm opened the copy in T1 only (3 of 3), 0 of 6 in T2 and T3. Assertions met per run (with; without):
T1 3, 3, 3; 0, 0, 0. T2 3, 3, 3; 2, 3, 2 (rescored: loop 4b without run 2 names line 60). T3 0, 0, 0; 0, 0, 0.
Transcripts in the private workspace.

Caveats: 3 runs per arm. The prompts are read-only, so "seen red" scores the step stated; nothing was run. The
five user mods load in both arms.

Superseded, kept under `scratch/superseded/` and not counted: loop 4 (`loop4/`, 3.0.4, claude-opus-5-5, 1 run
per arm, a pointer prompt to read SKILL.md), off the logged method on model, run count and the pointer; loop 3
(`loop3-runs/`), which ran with the MCP servers loaded and used a T3 whose prompt named the fallback; the run
before it (`claude -p` with CLAUDE.md loaded and stale premises).
