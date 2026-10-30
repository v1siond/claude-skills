---
name: testing-standard
description: Tests to his bar in any repo, backend logic test driven and seen red in every batch, and the batch test mode in ORCHESTRA.md Decisions setting the frontend only, default 0 frontend tests checked by QA in the browser, or add browser tests on his ask, then every new test seen red, both paths, captured fixtures, mocks only at boundaries. Run by the backend, frontend and QA players. Use when he says "add tests", "write the tests", "cover it", "red first", "tdd", "test first", "scenarios", "too many tests", "manual qa", "frontend tests", "property test". Do NOT use for reviewing tests (review).
license: CC-BY-SA-4.0
metadata:
  author: Alexander Pulido
  version: 3.2.0
  triggers: ["add tests", "add a test", "write the tests", "write a test", "test this", "cover it", "red first", "unit and e2e", "unit test*", "property test*", "test coverage", "tdd", "test first", "scenarios", "too many tests", "manual qa", "frontend tests"]
  sources: the game repo docs/TESTING.md; a work repo docs/TESTING.md; the retired dev-flow skill (test modes, research); references/property-based.md adapted from Trail of Bits property-based-testing (CC-BY-SA-4.0)
---

# Testing standard

Which tests a batch gets and how each one is written so it can fail, in any repo. Global: every player that
writes or runs tests uses it, and the director enforces it at orchestration row Dc (law 7). Backend logic is
test driven in every batch; the batch test mode sets how the frontend is tested, and every rule about writing a
frontend test applies only when the mode asks for that test.

## When to use

- A build ticket in an orchestration batch that changes backend logic or a screen.
- He asks for tests, a test mode, scenarios, or fewer tests.
- QA needs a test written to reproduce a bug (a backend bug always; a frontend one in `add browser tests`).

## When not to use

- Reviewing existing tests for false positives: review.
- A repo's commands, ports and paid traps: the project's own docs.
- Investigating a bug before any test: bug-investigation.

## Stance

- **You obey the batch test mode on the frontend and backend TDD everywhere.** You never pick a stricter or looser mode yourself, and no mode turns backend TDD off.
- **A test you cannot see fail is decoration.** You prove each one can go red.
- **You decide alone** the test names, the degenerate inputs, the property shape; log each as a DECISION in your report.
- **You never decide** the scenarios (his words or a doc section) or the frontend mode (his words in ORCHESTRA.md Decisions).

## Non-negotiables

1. **The test mode is read first,** from the brief's `Test mode:` line, checked against ORCHESTRA.md Decisions; no Decision line = `default`. The mode is a frontend mode, `default` or `add browser tests`: it sets how the frontend is tested and never touches the backend. Why: frontend testing changes per batch; one fixed rule either slows the build or skips tests he wanted. → `references/test-modes.md`
2. **Backend logic is test driven in every batch: every backend logic change gets a backend test, seen red before the logic is written, then green.** No batch mode turns it off. Why: TDD fits backend logic, where the business rules live and the tests caught the logic faults. → `references/test-modes.md`
3. **`default`: 0 frontend tests of any kind (component, page, browser or plain function);** the frontend is built, wired, format, compile, typecheck and lint clean, and QA checks it in the browser. Why: on the frontend, test driven work with Playwright slows development, so QA checks it unless he asks for browser tests.
4. **A data migration is backend: its test is written first and seen red, then the migration is written.** Why: as law 2; a migration changes rows the business rules read. → `/home/visiond/projects/claude/skills/global/ship/references/data-migrations.md` row 3
5. **`add browser tests` only on his ask,** default plus browser tests written after the UI works (the shape: laws 13a and 13b). Why: as law 3.
6. **Laws 7 to 13b bind every backend test and only the frontend tests the mode asks for;** `default` writes 0 frontend tests of any kind, plain-function ones included. Why: backend logic is test driven in every batch; the frontend is checked by QA (DECISION 10-25, `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/ORCHESTRA.md:59`).
7. **A new test is seen red before it counts;** each reverted half of the fix turns a test red. Why: a gate that cannot fail stayed green while the code did the opposite (Gotchas, 09-12).
8. **Assert existence, never a value a fallback can produce;** every refute has a positive twin that finds the thing when it is there. Why: a test stayed green while the code erased the floor it named (Gotchas, 2026-09-12, memory degenerate-test-oracle).
9a. **Fixtures are built the way production builds them** (captured payloads). Why: a re-captured fixture took failures from 51 to 64 (Gotchas, 2026-09-10).
9b. **Mocks only at HTTP, clock, mail and payment,** each stub asserted as served. Why: a no-op `localStorage` stub let a test that wrote a key pass while the code path never ran (memory localstorage-tests-are-false-positives, 2026-09-07).
9c. **A mocked backend follows the real schema.** Why: a fixture 116 files imported still carried `glyph`, `emoji` and `walkable` after the backend stopped serving them (memory tests-backend-unit-plus-real-e2e, 2026-09-22).
10. **Tests never touch the dev database and read no ambient env.** Why: a seeder run outside the sandbox wiped the regions' previews, selectors and bridges from the dev database.
11. **No new Jest, Vitest with jsdom or React Testing Library for a page or component;** in `add browser tests`, when he names a plain-function test for the batch, it calls the plain function. Existing Jest CI gates keep running. Why: he does not want Jest in his repos; the Jest suite for pages was deleted on his order.
12. **A failing test is never weakened, skipped or deleted to go green;** fix the code, or bring him the scenario. Why: no quote of his; the old global carried it ("Never weaken an assertion to make it pass"), and agents were caught deleting failing tests to go green (`references/test-modes-research.md`, Kent Beck).
13a. **A browser test drives the path a person takes:** the button he clicks, the app's own sign in; never a test-only auth bypass, an env flag that skips a step, or a call to the context function the button would call. Why: a browser test drives the UI and simulates user actions; a shortcut around the UI tests a path no person takes.
13b. **A canvas has no DOM, so the test drives the UI and reads the saved row.** That decides what is asserted, never whether the test is written. Why: no quote of his; memory tests-backend-unit-plus-real-e2e (2026-09-22): "The canvas has no DOM, so assert on DATA".

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "A browser test to be safe" | Law 3. Not in `default`; only on his ask. |
| "It's a small tweak, no test needed" (backend) | Law 2. Backend TDD holds at every size and in every mode. |
| "This batch is frontend-only mode, so backend tests can wait" | Law 2. The mode sets the frontend only; backend TDD holds in every batch. |
| "It's green, so the code works" | Law 7. Was it seen red? A fallback can pass it. |
| "The digest changed, so my change altered the data" | Run the oracle 2 times on unchanged code first. |
| "I'll run the seeder with `mix run` to check" | Law 10. A probe is a temporary test file under the sandbox, or a read-only SELECT. |
| "19 failures, the code regressed" | Check the test DB first; a seeder may have committed rows. |
| "I'll re-capture the whole fixture" | Copy only the missing fields (51 → 64 failures). |

## Intake

1. The brief's `Test mode:` line and the batch Decision in ORCHESTRA.md.
2. The scenarios in the brief (his words, or drafted with a source each).
3. `scripts/detect-test-stack.sh <repo>` output, the repo's `docs/TESTING.md`, and the project testing skill.

Fixed: backend TDD, the frontend mode, the scenarios, the repo's runners. Free: test names, degenerate inputs, property shapes.

## Pipeline

Serves orchestration row D5 (each player builds) and row Dc (the director reads these sections). Each Output
is a section of the player's report.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Read the mode | `Test mode: <mode> (<Decision id or "no Decision">)` | `references/test-modes.md` |
| 2 | Name the runners: `scripts/detect-test-stack.sh <repo>`, the repo `docs/TESTING.md`, the project testing skill | `Stack:` unit runner, browser runner, gate commands | `references/stacks.md` |
| 3 | Scenario list, Given / When / Then, each with its source | `Scenarios:` table, one row per scenario, a test file:line column | `references/test-modes.md` |
| 4 | Write the backend tests (every batch) and the frontend tests the mode asks for, per laws 7 to 9c; the input list is in `references/test-modes.md` | test files named after the behaviour (`a_saved_map_keeps_its_tiles_test.exs`) | `references/property-based.md` for roundtrip, inverse, idempotent or invariant code |
| 5 | Red: each new test against the code before the change | `Red:` the failure line per test | law 7 |
| 6 | Green, then revert each half of the fix in turn | `Green:` pass line; `Mutation:` which test went red per reverted half | law 7 |
| 7 | Browser test per laws 5, 13a and 13b; the shape is in `references/test-modes.md` | test file; the row read back | law 5, 13a, 13b |
| 8 | Gates: own test files, then format, lint, compile with warnings as errors | `Gates:` each command and its exit code | `references/stacks.md` |

In `default`, step 7 writes nothing. Do not skip 1, 5 or 8; a batch with backend logic never skips 4 to 6.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Players looping on tests, no feature to try | Test first applied to frontend and engine work | `default` mode, law 3 | 10-21 05:47 (orchestration gotchas); the 10-23 ruling that only the backend is test driven |
| Browser files ran 13 to 15 minutes each and checked scenarios he never set | Browser tests written test first | Browser tests only in `add browser tests`, after the UI works | 2026-10-16 terrain work, hours in 13 to 15 minute browser runs nobody asked for ("$CLAUDE_WORKSPACE/skills-backup-2026-10-23/skills/global/dev-flow/SKILL.md:36", a retired skill) |
| Test named "slot 0 removes nothing" green while the code erased the floor | `groundAt` falls back to `DEFAULT_FLOOR_SLUG`, which was `'grass'`, the value the test asserted | Assert the thing exists through its own lookup (the object, never the label a fallback returns) | 09-12, `removeSelectedBlock.test.ts` |
| A digest differed on 3 runs of the same code | `tileset_id` is a SERIAL inside the oracle | Join to the key; run an oracle 2 times on unchanged code before trusting a difference | 09-23 |
| 19 tests failed "key has already been taken", reported as regressions | `MIX_ENV=test mix run` seeded 782 tiles, committed outside the sandbox | A test, or a read-only SELECT; reset with `MIX_ENV=test mix ecto.drop && MIX_ENV=test mix ecto.create && MIX_ENV=test mix ecto.migrate`, never `mix ecto.reset` (it runs the seeds) | 2026-09-22, memory never-seed-outside-the-sandbox |
| A browser gate clicked Save and overwrote his work | The gates drove the dev database | The repo's own runner and test database (project testing skill) | 2026-09-22, memory browser-gates-need-their-own-db |
| A label rename broke 6 places, 2 of them tests; the 4 targeted suites passed | Tests compared the literal label | Grep the literal across source and tests, print the count, fix all | 09-12, `water` to `water_shallow` |
| A re-captured fixture took failures from 51 to 64 | The runtime DB had drifted from the seed | Copy only the missing fields into the fixture | 2026-09-10, memory test-fixture-is-a-captured-payload |
| A control POSTs, gets 200, and the write evaporates | `cast/3` drops a key it does not permit | Assert `get_change/2` is non-nil | 2026-09-24, memory a-value-invented-in-react-has-no-control |

## Deliverables

- Test files in the repo's own test tree, named after the behaviour (backend in every batch; frontend only in `add browser tests`).
- In the player's report: the lines `Test mode`, `Stack`, `Scenarios`, `Red`, `Green`, `Mutation`, `Gates`, `Not verified`. Each label starts its own line, as plain text with no bullet, bold or backtick, and its value sits on that line, as in the block below. Filled:

```
Test mode: default (no Decision)
Stack: mix test; no browser runner; mix format --check-formatted, mix compile --warnings-as-errors, mix credo --strict
Scenarios: S1 Given no stored cap, when it is read, then it is 3 (his message) -> test/app/cap_test.exs:12
Red: test/app/cap_test.exs:12 Assertion with == failed, left: 3, right: 5
Green: 4 tests, 0 failures
Mutation: photo_cap/0 read reverted -> test/app/cap_test.exs:12 red
Gates: mix format --check-formatted exit 0; mix credo --strict exit 0
Not verified: the admin number field (QA by hand)
```

## Check it before you show it

1. `scripts/check-report.sh <report> <ORCHESTRA.md> [batch]` prints `test mode: 1` and `match: yes`: the first `Test mode:` line of the report outside a `>` quote (list marks, bold and backticks stripped first) names the mode of the batch Decision line, `default` when the batch has none.
2. New files, untracked included: `git status --porcelain --untracked-files=all | grep -E '^(\?\?|A.)'`. In `default`, piped into `grep -cE '\.(test|spec|cy)\.(ts|tsx|js|jsx|vue|mts|cts|mjs|cjs|svelte)$|^.. (assets/)?(test|tests|e2e|spec)/.*((e2e|features|playwright)/|_web/(live|components)/)|^.. (e2e|playwright|tests/e2e)/'` it prints 0 (0 frontend tests of any kind). The grep keeps test files first (a test suffix, or a path under a test folder), so production LiveView and component files and a backend `_test.exs` count 0.
3. Each new test, with the source change stashed (`git stash push -- <changed source files>`), fails on an assertion, never a compile error; after `git stash pop` it passes.
4. Every Scenarios row has a test file:line; every gate command exits 0.

A failing check goes back to pipeline step 4; report when checks 1 to 4 pass.

## Critic loop

A separate read-only judge gets the brief, the mode and the diff, never the player's report. Default reject.
It scores 1 to 10 the "a diff" axes of `/home/visiond/projects/claude/skills/global/orchestration/references/critic.md:21`,
plus 4 axes of this skill: backend TDD held and the frontend mode obeyed; each test can fail (red line recorded); oracle independent of any
fallback; fixtures and mocks per laws 9a to 10. The 3 worst problems
with file:line, the smallest fix each. Below 8 on any axis: back to pipeline step 4, then score again, until
every axis is 8 or more.

## Definition of done

- [ ] `Test mode:` line in the report matches the batch Decision.
- [ ] Every batch: every backend scenario, a data migration included, has a test seen red, then green (laws 2, 4).
- [ ] `default`: 0 frontend tests of any kind (law 6).
- [ ] `add browser tests`: each browser test asserts the screen and the saved row.
- [ ] Each reverted half of the fix turned a test red.
- [ ] No assertion a fallback can satisfy; every refute has a positive twin.
- [ ] Fixtures built the way production builds them; mocks only at boundaries and on the real schema; no dev database, no ambient env.
- [ ] Gates exit 0; gaps named.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/test-modes.md` the two frontend modes and backend TDD, how the mode is written, the default order, the input list, the browser test shape. Steps 1, 4 and 7.
- `references/stacks.md` runners and gates per stack, and which project skill holds each repo. Step 2.
- `references/property-based.md` property catalog, StreamData and fast-check, the 2 vacuous shapes (CC-BY-SA-4.0, Trail of Bits). Step 4.
- `references/test-modes-research.md` what was compared for the modes.
- `references/evals.md` trigger queries and behaviour scenarios. `references/canon.txt` lines the lint keeps.
- `scripts/check-report.sh <report> [ORCHESTRA.md] [batch]` read only; reads the first `Test mode:` line outside a `>` quote and the batch Decision line, prints `match: yes` when the modes are equal (check 1).
- `scripts/detect-test-stack.sh <repo>` read only; prints stack, test deps, scripts, browser configs, CI steps, "none" per empty section.
- the repo's own `docs/TESTING.md` when it has one; the fullest written version of this standard is a project one, its path in the private overlay (`skills/specific/<project>/facts/testing-standard-stacks.md`).

## Evals

15 trigger queries and 3 behaviour scenarios in `references/evals.md`, numbered, each scenario RED from a gotcha above:
T1 a batch with no Decision (RED 10-21 players looping on tests); T2 a `default` batch with a backend row
(RED 10-30, his correction that backend TDD holds in every batch); T3 a cap test that already passes (RED law 7, 09-12). Run
2026-10-25 on 3.0.5 and claude-sonnet-5-5, 3 runs per arm, the skill loaded in the with arm's system prompt, the
same role line in both (0 MCP tools, 0 skill or memory reads without): T1 with 3 of 3 runs pass, without 0 of 3;
the retired T2 (a no-tests batch) 3 of 3 and 1 of 3, the new T2 not run yet; T3 3 of 3 and 0 of 3. Available but not loaded, the with arm opened the skill in T1 only.
Method, prompts and caveats in `references/evals.md`.
