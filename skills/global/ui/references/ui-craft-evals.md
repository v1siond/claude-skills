# Evals for ui

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `ui`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | ui design for the agents tab, design this screen | yes | ~/projects/<app> |
| T2 | the settings list of checkboxes is not intuitive, make it usable | yes | ~/projects/<app> |
| T3 | audit the UI of the settings page | no | ~/projects/<app> |
| T4 | design the layers section of the inspector, a vertical list of checkboxes is not good ux | yes | ~/projects/<app> |
| T5 | make the importer screen usable, it's the bare minimum right now | yes | ~/projects/<app> |
| T6 | give me three mockups of the importer to pick from | no | ~/projects/<app> |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill ui loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: a vertical list of checkboxes, the test the backend UI (Gotchas row 1, 10-17)

Role line: "You are the frontend player."

Task given to both arms:

~~~
Add a Layers section to the editor inspector. The user chooses which of 8 layers show on the map: ground, water, decor, units, paths, collision, grid, fog. The backend already stores one boolean per layer. Give me the design you would build and the copy, ready to build.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: The chosen design is not a vertical list of checkboxes: no `type="checkbox"` and no sentence recommending checkboxes as the chosen control.
2. A2: Two layouts are sketched in ASCII (at least 2 fenced blocks) and one is marked as chosen.
3. A3: It uses toggle chips or a segmented control, a summary line of what is on, and a reset or All link.
4. A4: It names the contrast numbers 7 to 1 for text and 3 to 1 for non-text, and 44 px targets.

### S2 nested scroll (written, not run) RED from: A list cannot be filtered and scrolls inside a panel (Gotchas row 5, 10-17)

Task: A tileset picker with 400 tiles inside a side panel.

Pass rules:

1. It opens in the movable window with one scroll and a filter by kind.

### S3 window opens window (written, not run) RED from: A button opens a window that holds one more button (Gotchas row 6, 09-11)

Task: A character section whose modal contains only `Replace tile`.

Pass rules:

1. It puts the contents in the first window and removes the extra step.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 2 |
| A2 | 3 | 0 |
| A3 | 3 | 3 |
| A4 | 3 | 0 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 6, without arm 0.


