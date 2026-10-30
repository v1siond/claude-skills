# testing-standard

| | |
|---|---|
| Type | engineering |
| Scope | global (every repo) |
| Source | [`skills/global/testing-standard/SKILL.md`](../../../skills/global/testing-standard/SKILL.md), version 3.2.0 |
| Run by | the backend, frontend and QA players; enforced by the director at orchestration step 7 |

## What it is for

Which tests a batch gets and how each one is written so it can fail, in any repo. Backend logic is test driven
in every batch; the test mode sets how the frontend is tested, and a frontend test is written only when the mode
asks for it (SKILL.md lines 14 to 17).

## When to use it, and when not

Use it for a build ticket that changes backend logic or a screen, when he asks for tests, a test mode,
scenarios or fewer tests, and when QA needs a test to reproduce a bug in a mode that allows it (lines 19 to 23).

Do not use it to review existing tests (review), for a repo's commands and ports (the project's own docs), or
to investigate a bug before any test (bug-investigation) (lines 25 to 29).

## Who runs it and its place in orchestration

Builders at step 6, QA at step 9. The test mode is a Decision in `ORCHESTRA.md` set per batch from his words
(orchestration law 8a); step 4 copies it into every brief. The mode applies to the frontend only.

## Backend TDD and the frontend modes

- Every batch: backend logic is test driven, seen red, then green; a data migration's test is written first (laws 2 and 4).
- `default`: the frontend is built and wired, passes format, compile, typecheck and lint, gets 0 tests of any kind and is checked by QA in the browser (law 3).
- `add browser tests`: default plus browser tests, only on his ask, after the UI works (law 5).

Why: TDD fits backend logic; on the frontend, test driven work with Playwright slows development, so the
frontend is checked by QA unless he asks for browser tests.

## Pipeline, short (lines 85 to 94)

1. Read the mode: `Test mode: <mode> (<Decision id>)`.
2. Name the runners with `scripts/detect-test-stack.sh <repo>`.
3. Scenario list, Given / When / Then, each with its source.
4. Write the tests the mode asks for, named after the behaviour.
5. Red: each new test against the code before the change.
6. Green, then revert each half of the fix in turn (`Mutation:` line).
7. Browser test only per laws 5, 13a and 13b.
8. Gates: own test files, then format, lint, compile with warnings as errors.

## Scripts

- `scripts/detect-test-stack.sh <repo>`: the unit runner, browser runner and gate commands of a repo.
- `scripts/check-report.sh <report> [ORCHESTRA.md] [batch]`: check 1 of the skill on a player's report.

## Key laws (lines 40 to 53)

1. The test mode is read first. 2. Backend logic tests seen red first, in every batch. 3. `default`: 0 frontend tests.
4. A data migration's test is written first and seen red. 5. Browser tests only on his ask.
7. A new test is seen red before it counts. 8. Assert existence, never a value a fallback can produce.
10. Tests never touch the dev database and read no ambient env.
11. No new Jest, Vitest with jsdom or React Testing Library for a page or component.
12. A failing test is never weakened, skipped or deleted to go green.

## Handoffs

- Bugs: bug-investigation finds the cause, the bug becomes the test scenario when the mode wants one.
- Review of tests for false positives: review, tests lens.

## Best practices, from its Gotchas (lines 98 to 110)

- Keep test first to backend logic; on frontend and engine work it left players looping.
- Assert the thing exists through its own lookup; a fallback once returned the very value the test asserted.
- Run an oracle 2 times on unchanged code before trusting a difference.
- A seeder run with `MIX_ENV=test mix run` commits rows outside the sandbox; reset the test database.
- Grep a literal label across source and tests before renaming it.
- Re-capture only the missing fields of a fixture.
- After a POST, assert `get_change/2` is non-nil: `cast/3` drops keys it does not permit.

## Red flags (lines 59 to 70)

"A browser test to be safe", "It's a small tweak, no test needed", "This batch is frontend-only mode, so backend
tests can wait", "It's green, so the code works", "19 failures, the code regressed".

## Evals

15 trigger queries and scenarios T1 to T3 in
[`references/evals.md`](../../../skills/global/testing-standard/references/evals.md) (Evals, lines 172 to 180).
