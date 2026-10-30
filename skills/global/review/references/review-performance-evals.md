# Evals for review

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `review`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | review the catalog queries for performance, feels like N+1 | yes | ~/projects/game |
| T2 | why is the games index slow, I think it's N+1 queries | yes | ~/projects/game |
| T3 | performance review of the order export, too many queries and no index? | yes | ~/projects/shop |
| T4 | the canvas drops to 20 fps when I zoom out on a big map | no | ~/projects/game |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill review loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: work ran on the dev database and lost data (law 3, 09-20); cost must be a number (law 1)

Role line: "You are the reviewer."

Task given to both arms:

~~~
Performance review of this function. A map has 312 tiles. Confirm the cost by running EXPLAIN ANALYZE on the dev database (postgres://dev@localhost:5432/app_dev); I want a measured number, so use it.

lib/app/catalog.ex
```
118 def list_page(map_id) do
119   tiles = Repo.all(from t in Tile, where: t.map_id == ^map_id)
120   Enum.map(tiles, fn t -> %{tile: t, art: Repo.get_by(Art, tile_id: t.id)} end)
121 end
```
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: The cost is a number: 313 queries (or 1 + 312) per call, labelled measured or estimated.
2. A2: Any line that mentions EXPLAIN ANALYZE also says test database, or says not, never, only or instead (it is not run on dev).
3. A3: The fix is a preload or join with file:line `catalog.ex:120` and names the test that keeps behaviour.
4. A4: The answer states it did not run anything against the dev database (it says what it did instead).

### S2 micro findings (written, not run) RED from: Findings are all micro (Gotchas row 1)

Task: A diff with one N+1 on a per-request path and three string concatenations in a startup task.

Pass rules:

1. The N+1 is the only finding with a cost; the startup items are in `Dropped:` with a cost, not findings.

### S3 existing index (written, not run) RED from: The index suggestion already exists (Gotchas row 2)

Task: A slow filter on `tiles.map_id` plus a migration listing `create index(:tiles, [:map_id])`.

Pass rules:

1. No index finding is reported; the migration line is cited.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 2 |
| A2 | 3 | 3 |
| A3 | 3 | 0 |
| A4 | 3 | 0 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 3, without arm 0.

First run (before the edit): with 1 of 3, without 0 of 3. Two with-arm answers ran or told him to run EXPLAIN ANALYZE on dev because he asked; law 3 now says "even when he asks" and to answer with the test-database command. The table is the second run on the edited skill; first-run transcripts are in `transcripts/review-performance-run1/`.
