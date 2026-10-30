# Evals for ui

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `ui`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | run a senior ui/ux review of the new world panel in the editor | yes | - |
| T2 | audit the UI of the editor, how intuitive is it? give me findings | yes | - |
| T3 | build the settings section for the terrain panel, make it look good | no | - |
| T4 | heuristic review of the inspector panel, score nielsen's 10 and rank the issues | yes | ~/projects/<app> |
| T5 | review the ux of the games page as a new user, what is confusing? | yes | ~/projects/<app> |
| T6 | is the editor keyboard accessible at AAA? | no | ~/projects/<app> |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill ui loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: findings are generic, no location, no key task (Gotchas row 1)

Role line: "You are the QA player."

Task given to both arms:

~~~
Audit the UI and UX of this tile panel and report. You cannot run it; the source is all you have. Also just rewrite the whole component so it is good.

panel.tsx
```
 1 export function TilePanel({ tile }) {
 2   return (
 3     <div className="panel">
 4       <h3>tile_h:</h3>
 5       <input type="number" value={tile.height} />
 6       {LAYERS.map(l => <label><input type="checkbox" checked={tile[l]} /> {l}</label>)}
 7       <select value={tile.dir}><option>n</option><option>s</option></select>
 8       <button onClick={() => deleteTile(tile.id)}>Delete</button>
 9       <button>OK</button>
10     </div>
11   )
12 }
```
Key tasks: set a tile's height, choose which layers it shows, remove a tile.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: A health table scores the 10 heuristics 0 to 4: at least 8 lines carry a score like `2/4` or `| 2 |`.
2. A2: Every finding row has a P0 to P3 label and a location (`panel.tsx:` plus a line number); at least 4 such rows.
3. A3: The delete without confirm or undo (line 8) is P0 or P1, and the checkbox list (line 6) is a finding against the kit.
4. A4: It does not rewrite the component: no code block longer than 12 lines (fixes are one line each).
5. A5: 3 to 5 priority issues are named.

### S2 every heuristic 2 (written, not run) RED from: Every heuristic scores 2 (Gotchas row 2)

Task: A panel with one clear failure on heuristic 3 and one clear pass on heuristic 4.

Pass rules:

1. Scores spread from 0 to 4 with a one line reason that quotes the rubric level.

### S3 function lost (written, not run) RED from: The screen lost functions (Gotchas row 4)

Task: A function list of 6 rows and a screen showing 4.

Pass rules:

1. The 2 missing rows are findings with the row named.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 0 |
| A2 | 3 | 0 |
| A3 | 3 | 0 |
| A4 | 3 | 0 |
| A5 | 3 | 0 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 7, without arm 0.

First run (before the edit): with 0 of 3, without 0 of 3. All 3 with-arm answers rewrote the whole component because the task asked for it; law 1 now says the report comes first and the rewrite becomes a ticket for ui. The table is the second run; first-run transcripts are in `transcripts/ui-design-review-run1/`.
