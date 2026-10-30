# Review tests, inside review

For every test in what he named, answers one question with a yes or no: would it fail if the code were broken the
way it claims to guard against? Each "no" is a finding with the fix. Run by the reviewer player on the merged diff,
at orchestration row Dc; each finding goes back as a ticket (step 11).

## Stance

- **You report, you do not edit tests.** The one change you make is a one-line mutation to prove a suspicion, and you restore it in the same step.
- **You decide alone** which tests are suspects and which line to break.
- **You never decide** to break a line in a file with uncommitted changes (laws 2 and 7).

## Non-negotiables

1. **Every test is judged by one question: would it fail if the code it guards were broken?** Why: a test must assert the actual code and flows; a false positive or a placeholder test reports green on broken code. → `references/review-tests-false-positive-patterns.md`
2. **A suspicion is proven by breaking the guarded line in the main checkout, never a copy or a worktree,** and only when `git status --porcelain -- <file>` prints nothing; run the test, record red or green, restore with `git checkout -- <file>`. Why: proving suspects in copies once left 15 worktrees behind in his repo.
3. **A gate that cannot fail is decoration.** The expected value must not be what a fallback manufactures: assert the thing exists, then its value. Why: a suite passed while the GraphQL schema was never updated, and the failure showed up on staging instead.
4. **Each behaviour has a positive and a negative path.** Why: a suite with only the happy path never checks that the code returns an error when it should.
5. **A page or component tested in Jest or jsdom is a finding, and the fix follows the batch test mode** (testing-standard, ORCHESTRA.md Decisions; the mode sets the frontend only): `default` deletes it (0 frontend tests), `add browser tests` replaces it with a browser test that drives the page and reads the saved row. A backend logic change with no test seen red is a finding in every mode. Why: he does not want Jest tests in his repos, whether browser tests are wanted changes per batch, and backend logic is test driven in every batch.
6. **A stub that turns the checked side effect into a no-op is a finding.** Why: no quote of his; `references/review-tests-false-positive-patterns.md`, row "No-op stub".
7. **When a suspect cannot be run** (uncommitted work in its file, no runner), write the exact mutation, the run command and the restore command, and count that test under "could not". Why: no quote of his; the old skill's troubleshooting line on a tree with uncommitted work.

Violating the letter of a law is violating the law.

## Intake

1. Target X resolved as in `review` (Intake table: path, diff, branch, commit, PR, MR).
2. The code each test claims to cover.
3. The setup files: `test_helper.exs`, `jest.setup.*`, `playwright.config.*`, fixtures; any fixture captured from a live payload (they drift).
4. The batch test mode from ORCHESTRA.md Decisions (law 5).

Fixed: the finding shape and the proof line. Free: the order tests are judged in.

## Pipeline

Serves orchestration row Dc. Each Output is a section of `review-tests.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Resolve X; read the test mode | `Reviewed:` and `Mode:` lines | Intake |
| 2 | For each test, one line on the defect it claims to catch | `Claims:` table, test and claimed defect | law 1 |
| 3 | Walk the patterns over each claim | `Suspects:` test and pattern | `references/review-tests-false-positive-patterns.md` |
| 4 | Prove each suspect: break the guarded line, run only that test (`mix test path:line`, `npx playwright test -g`), record red or green, restore | `Proof:` command, result, restore command | law 2 |
| 5 | Check coverage: positive and negative path per behaviour, the error branch, the empty input, the actual method called and the template it renders (not a stub of either); the layer (backend logic in `mix test`, UI through a browser) | `Coverage:` gaps | laws 4, 5 |
| 6 | Write the findings with fixes | finding blocks, ending with the line `tests reviewed: N, proven able to fail: M, could not: K` | Deliverables |

Do not skip 4.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Staging breaks on a GraphQL failure after "all pass" | Tests never exercised the schema | Drive the real caller and assert the behaviour | a change shipped with every test green while its GraphQL schema was never updated; the first query on staging failed |
| Breaking the code is risky on his tree | Uncommitted work sits in the file | Skip that file and report it unproven; otherwise mutate one line, run, `git checkout -- <file>`; never a worktree or copy | the skill's own troubleshooting, no measurement |
| Tests are slow to run one by one | The whole suite is run per suspect | Run only the file and line (`mix test path:line`, `npx playwright test -g`) | the skill's own troubleshooting, no measurement |
| A fallback value passes the test | Expected value equals what the fallback returns | Assert the row, tile or call exists first | testing-standard Gotchas, the `groundAt` fallback |
| A renamed label leaves the test green | The exact string now matches fewer things | Grep src and tests for the old string, count, rerun the full suite | testing-standard Gotchas |
| The runner reports 0 tests | Wrong path or wrong tree | Read the count line | the skill's own pattern table, no measurement |

## Deliverables

`<workspace>/score/<ticket>/review-tests.md` (no ticket: the reply), the sections above, then one block per finding:

```
### 1. "an unknown cell reads as ground" cannot fail on a wrong lookup
- File: <test file>:<line>
- Type: false positive (degenerate oracle)
- Severity: High
- Before: `assert World.ground_at(grid, 99, 99) == "grass"   # ground_at returns "grass" for any cell it cannot find`
- Proof: <source file>:<line> broken (the lookup returns the fallback for every cell); `<run command for that one test>` <red or green>; restored with `git checkout -- <source file>`
- Fix:
  assert {:ok, cell} = Map.fetch(grid.cells, {3, 4})    # the cell exists
  assert cell.ground == "stone"                         # a value the fallback never returns
```

The example is a shape, not a run: the `Before:` line is an inline degenerate oracle with no real path (`ground_at` is not a real function), and every `<...>` in Proof is filled from your own run, with the result you saw. A finding whose Proof you did not run goes under "could not" (law 7).

Severity: **Critical** the test guards a reported bug and cannot fail. **High** a main path test that cannot fail.
**Medium** a missing negative path or a drifting fixture. **Low** naming or structure that hides intent. The findings
end with the line `tests reviewed: N, proven able to fail: M, could not: K` and nothing else on it; the next-step sentence follows it.
