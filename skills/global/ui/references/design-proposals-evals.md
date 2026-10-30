# Evals for ui

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `ui`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | show me options for the pricing page, give me designs | yes | ~/projects/<app> |
| T2 | make mockups of the settings screen, how would it look | yes | ~/projects/<app> |
| T3 | run a wcag audit on the settings screen | no | ~/projects/<app> |
| T4 | I want to see three different looks for the homepage before we build anything | yes | ~/projects/<app> |
| T5 | I picked proposal B, port it into the app exactly | yes | ~/projects/<app> |
| T6 | design the settings panel section with the right controls | no | ~/projects/<app> |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill ui loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: proposals that look alike and a description sent instead of pages (Gotchas row 2, 09-01; law 1, 08-28)

Role line: "You are the frontend player."

Task given to both arms:

~~~
Show me options for the shop pricing page. You cannot create files in this session, so write the exact steps you would run, the file names, and the exact reply you would send me when it is done.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: At least 3 rendered proposals as HTML files named like `a-<idea>.html`, `b-<idea>.html`, `c-<idea>.html`; the options are pages he opens, not prose to choose from.
2. A2: Each pair differs on at least 4 named dials (navigation, density, hierarchy, grid, type, colour, depth, imagery, motion, voice): at least 4 distinct dial words appear.
3. A3: It serves on a port from 8700 to 9700 bound to 127.0.0.1 and gives the localhost URL (a LAN URL only when he asks for one).
4. A4: AAA contrast is reported (the lowest ratio per proposal), and nothing is published outside the machine (no Artifacts, Vercel or hosted page recommended).

### S2 index order (written, not run) RED from: The proposal index is in the wrong order (Gotchas row 4, 10-11)

Task: Eight proposals made across a week.

Pass rules:

1. The index lists them in order of work as `<number or letter> - <Title>`.

### S3 port drift (written, not run) RED from: The port drifts from the mockup (Gotchas row 3, 09-02)

Task: He picked proposal B.

Pass rules:

1. It saves the HTML verbatim, copies the markup, then adapts, and lists each difference; it does not rewrite from scratch.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 3 |
| A2 | 3 | 0 |
| A3 | 3 | 0 |
| A4 | 3 | 0 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 15, without arm 0.


