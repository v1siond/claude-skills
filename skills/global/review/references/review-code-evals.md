# Evals for review

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `review`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | review lib/shop/orders.ex as a senior engineer, only real issues | yes | ~/projects/shop |
| T2 | can you look over my branch before I merge, anything wrong? | yes | ~/projects/shop |
| T3 | do a senior code review of the diff on this branch, findings with file and line | yes | ~/projects/shop |
| T4 | review MR 214, only real issues, don't pad it | yes | ~/projects/shop |
| T5 | does the code match what I asked in the spec? requirement by requirement | no | ~/projects/shop |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill review loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: `references/review-code-what-counts.md`, Real findings, the `String.to_atom/1` row (High)

Role line: "You are the reviewer."

Task given to both arms:

~~~
Review this controller and report your findings.

lib/app_web/controllers/game_controller.ex
```
 1 defmodule AppWeb.GameController do
 2   use AppWeb, :controller
 3   alias App.Games
 4
 5   def index(conn, params) do
 6     dir = String.to_atom(params["sort_direction"] || "asc")
 7     games = Games.list_games(conn.assigns.current_user, order: dir)
 8     render(conn, :index, games: games)
 9   end
10
11   def show(conn, %{"id" => id}) do
12     game = Games.get_game!(id)
13     render(conn, :show, game: game)
14   end
15 end
```
Games.get_game!/1 is `Repo.get!(Game, id)`. Every game row has a user_id.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: The `String.to_atom` finding names an input (a made up `sort_direction` value) and the consequence (an atom per distinct value, never freed).
2. A2: The `get_game!` finding says whose game can be read (any user's, by id).
3. A3: Every finding carries a file:line (a `:6` or `:12` style reference), a severity word (Critical, High, Medium or Low) and a code block; at least 2 code blocks.
4. A4: No padding: no finding about the `alias` line or naming, and 3 findings or fewer.

### S2 retract on challenge (written, not run) RED from: He says a finding is wrong; it was not traced to a caller (Gotchas row 2)

Task: Give the reviewer a diff and a finding that a caller already guards, then say "that finding is wrong".

Pass rules:

1. It retracts the finding plainly in the first sentence.
2. It re-verifies the other findings by naming each one's caller or guard (at least 1 file:line per finding).

### S3 module-scope read (written, not run) RED from: `references/review-code-what-counts.md`, Real findings, the module-scope read row (High)

Task: A diff with `@catalog Catalog.fetch()` at module scope; ask for review.

Pass rules:

1. Finding is High with the input state (the API had not answered) and the fix reads it in a function at call time.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 3 |
| A2 | 3 | 3 |
| A3 | 3 | 1 |
| A4 | 3 | 1 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 5, without arm 0.


