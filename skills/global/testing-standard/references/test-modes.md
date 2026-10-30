# Test modes

## Contents

- Backend TDD and the two frontend modes
- How the mode is written and read
- In every mode that writes tests
- Inputs each test covers (pipeline step 4)
- Browser test shape (pipeline step 7, `add browser tests` only)
- Default mode, step by step
- When a step fails
- Traps
- Why this shape

How tests run inside one build ticket, from orchestration law 8a, word for word:

Backend logic is test driven (seen red, then green) in every batch; no batch mode turns it off. The batch test mode is set per batch in ORCHESTRA.md Decisions, from his words, and applies to the frontend only: `default` = frontend built and wired with 0 tests of any kind (component, browser or plain function; the director's choice, source in `/home/visiond/projects/claude/skills/global/orchestration/references/sources.md`), checked by QA in the browser; he can set add browser tests. (orchestration law 8a; its `references/sources.md` written as the full path)

Every brief names the mode on a `Test mode:` line. The gates, approvals, cast and report
belong to orchestration.

Backend TDD and the frontend mode are not alternatives: every batch has both. The mode exists because frontend
tests are right for some batches and not for others; frontend test driven work with Playwright slows development
in most.

## Backend TDD and the two frontend modes

Backend, every batch, whatever the mode: TDD, one test per scenario, seen red for the right reason before the
logic is written, then green. A data migration is backend: its test is written first, seen red, then the
migration (`/home/visiond/projects/claude/skills/global/ship/references/data-migrations.md` row 3).

| Frontend mode | When | Frontend |
|---|---|---|
| **Default** (`default`) | No Decision line from him on tests for the batch | Built and wired; format, compile with warnings as errors, typecheck and lint. 0 frontend tests of any kind, plain-function ones included; QA checks it in the browser |
| **Add browser tests** (`add browser tests`) | He asks for one, or names a scenario that needs one | As default, plus browser tests written against the UI that now exists, clicking through and asserting the saved row; a plain-function frontend test only when he names it for the batch |

Why each mode:
- Backend TDD in every batch: TDD fits backend logic. The business rules live there, and the backend tests caught the logic faults; a red test written first is cheap and keeps that guarantee.
- Default: on the frontend, test driven work with Playwright slows development, so the frontend is built, wired and checked by QA in the browser unless he asks for browser tests. The feature is built and handed to his review first.
- Add browser tests: only on his ask, written after the UI works, because frontend test driven work with Playwright slows development.

## How the mode is written and read

The director writes one Decision line per batch; the brief copies it. Filled example:

```
ORCHESTRA.md Decisions:
D4 Test mode batch 2: add browser tests. Source: his message of 10-24 in PROMPT-LOG.md

brief.md:
Test mode: D4 in ORCHESTRA.md Decisions, add browser tests
```

The player's report opens its test section with the same mode: `Test mode: add browser tests (D4)`. No
Decision line for the batch means `Test mode: default (no Decision)`.

## In every batch

- **Scenarios before code.** His words become the list, copied verbatim when he gave them; otherwise drafted from his request, each with its source (his words or a doc section), as plain Given / When / Then lines. Every test maps to one scenario on the list (its negative path counts). A test for a scenario nobody agreed is not written; add the scenario to the list with its source first.
- **A business rule lives in the backend and is tested there.** A rule or calculation a scenario checks goes in the backend.
- **A plain frontend module holds UI logic only,** and is tested only in `add browser tests`, when he names a plain-function test for the batch; such a test calls the plain function, never a component.
- **Never Jest or jsdom for a page or component;** the page is checked by QA in the browser (orchestration row V).
- **Never weaken, skip or delete a failing test to go green.** Fix the code, or bring him the scenario if it is wrong.
- **An end to end feature is built backend and frontend in parallel.** TDD is not sequential: while the backend tests go red and green, the UI is built and wired to the endpoints as they appear. A ticket whose UI was never built and wired is not BUILT.
- **The builder does not click through unless he asks;** it builds and wires every frontend part, typechecks and lints it, and QA clicks through (orchestration row V).
- **Run tests at the end of a step, never per sub-step.** A scenario's test runs when its logic is done. A player runs only its own test files plus the repo's format, lint and compile checks; the full suite runs once, on the merged tree. The full suite never runs while iterating; run the one test file.

## Inputs each test covers (pipeline step 4)

- Positive and negative path per scenario.
- Degenerate inputs: `""`, `nil`/`null`, `[]`, `{}`, absent key, wrong type, duplicate, out of order, already-final state.
- A family of things (every tile, carrier, role, page): one case per member, generated from the real catalog.
- A data migration test puts a row back in the old state, runs the migration, and reads the row; it is written and seen red before the migration.

## Browser test shape (pipeline step 7, `add browser tests` only)

- Open the page, click and type as a person does (law 13a).
- Wait on the visible outcome, never a timer.
- Assert both the screen and the database row the UI wrote; on a canvas, the saved row (law 13b).
- Assert the failure path too: bad input shows the error and saves nothing.

## Default mode, step by step

1. **Red, with the UI started.** For each scenario, write the backend test. Run each new test against today's code and record the failure line. A test that passes before the change is rewritten until it can fail.
2. **Green.** The smallest logic change that passes, one scenario at a time. Run that scenario's test when its logic is done.
3. **Refactor** with the tests green. Structural changes (renames, moves) apart from behaviour changes.
4. **Frontend**, wired to the endpoints as each goes green. Format, compile with warnings as errors, typecheck, lint.
5. **Browser tests only in the `add browser tests` mode,** written after the UI works, against the UI that exists.

Each backend test is recorded red, then green.

## When a step fails

- Read the whole error, fix the cause, rerun that one test.
- The same failure 2 times means change the approach. The changed approach fails too: stop, and report the
  error, the command and both approaches to the director.
- A broken tool (port taken, browser missing) is reported with its exact error and command, never retried in a loop; keep the unit layer result.

## Traps

| Symptom | Cause | Fix |
|---|---|---|
| A scenario cannot be tested in the backend | The logic sits in frontend code | Move the logic to the backend; when the move touches a file outside the brief's owned files, say so in the report and ask |
| Tempted to add a browser test "to be safe" | The old two-layer rule | Not in default mode; only on his ask |
| "It's a small tweak, no test needed" on backend logic | Skipping red | Backend TDD holds at every size and in every mode; write the red test first |
| "This batch is frontend-only mode, so backend tests can wait" | Reading the mode as a backend switch | The mode sets the frontend only; backend TDD holds in every batch |
| A backend test passes before any code | It asserts a default or something already true | Assert the specific new state |
| A long test run on every edit | Testing sub-steps | Run only the finished scenario's test |

## Why this shape

His measured cost: browser tests written test first ran 13 to 15 minutes a file and checked scenarios he
never set, while the backend tests caught the logic faults. Backend TDD keeps the guarantee where the business
rules live; QA in the browser, then optional frontend tests, keeps the UI honest without paying for tests of a
UI that does not exist yet. What was compared: `test-modes-research.md`.
