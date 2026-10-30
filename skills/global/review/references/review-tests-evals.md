# Evals for review

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `review`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | these tests are green but the feature is broken on screen, are they real? | yes | ~/projects/game |
| T2 | review the tests in test/orders, would they even fail? | yes | ~/projects/shop |
| T3 | write a test for the volcano lava reaching the foot | no | ~/projects/game |
| T4 | audit the tests in test/game, which ones are false positives? | yes | ~/projects/game |
| T5 | the suite is green but staging broke, are these tests testing anything? | yes | ~/projects/shop |
| T6 | add tests for the new import endpoint, red first | no | ~/projects/shop |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill review loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: the expected value equals what the fallback returns (degenerate oracle, Gotchas row 4)

Role line: "You are the reviewer."

Task given to both arms:

~~~
Review these tests. Report what you find.

lib/world/ground.ex
```
 8 def ground_at(map, x, y) do
 9   case Map.get(map.cells, {x, y}) do
10     nil -> "grass"
11     cell -> cell.ground
12   end
13 end
```
test/world/ground_test.exs
```
 5 test "ground at a grass cell is grass" do
 6   map = %{cells: %{{1, 1} => %{ground: "grass"}}}
 7   assert Ground.ground_at(map, 1, 1) == "grass"
 8 end
 9
10 test "ground at a missing cell is grass" do
11   assert Ground.ground_at(%{cells: %{}}, 3, 3) == "grass"
12 end
```
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: It says the test at line 5 (or 7) cannot fail when the lookup is broken: it stays green because the fallback returns the same value.
2. A2: It gives a proof step: break one named line, run the test (`mix test ... :line`), record red or green, and restore with `git checkout -- <file>`.
3. A3: The fix uses a value that differs from the fallback (water, sand, any non-grass ground) or asserts the cell exists.
4. A4: A line of its own reads `tests reviewed: N, proven able to fail: M, could not: K` with no extra words.

### S2 jest page test (written, not run) RED from: A page tested in Jest (law 5, 09-22)

Task: A Jest test of a React page with a stubbed `localStorage.setItem`; batch test mode `default`.

Pass rules:

1. It is a finding; the fix is delete (0 frontend tests) in mode `default`; the stub is named as a no-op.

### S3 zero tests ran (written, not run) RED from: The runner reports 0 tests (Gotchas row 6)

Task: A run log that ends `0 tests, 0 failures`.

Pass rules:

1. It is a finding with the path or tree cause; it is not read as green.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 3 |
| A2 | 3 | 0 |
| A3 | 3 | 3 |
| A4 | 3 | 0 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 6, without arm 0.

First run (before the edit): with 0 of 3, without 0 of 3. The with arm lacked the exact mutation, run and restore commands when it could not run, and put words after the tally line. Law 2 and the Deliverables now say both; pass rule 4 was reworded after that run from "the last non-empty line" to "a line of its own" because the skill puts the next-step sentence after the tally. The table is the second run; first-run transcripts are in `transcripts/review-tests-run1/`.
