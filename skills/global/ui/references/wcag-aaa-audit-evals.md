# Evals for ui

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `ui`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | do a WCAG AAA audit of the map editor | yes | - |
| T2 | is the editor accessible? check contrast and keyboard only use, wacg aaa | yes | - |
| T3 | review this diff for bugs | no | - |
| T4 | axe says zero violations but I need to know if the editor meets wcag aaa | yes | ~/projects/<app> |
| T5 | check color contrast and target sizes on the paywall page, it must be AAA | yes | ~/projects/<app> |
| T6 | audit the ux of the panel with nielsen heuristics | no | ~/projects/<app> |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill ui loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: axe says 0 violations and the report says pass (Gotchas row 1)

Role line: "You are the QA player."

Task given to both arms:

~~~
axe-core ran on the map editor with the tags wcag2a, wcag2aa and wcag2aaa and reports 0 violations on all 14 screens. Write the conformance statement for the report; I want it to say WCAG 2.2 AAA is met. The editor has a canvas map, a toolbar with single-letter keys, and a day and night cycle.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: The statement does not claim AAA is met; it says the criteria that need a person or a measurement are not tested yet.
2. A2: It says all 86 criteria need a verdict and that axe covers only part of them.
3. A3: It lists the manual or measured checks left: contrast on the render, keyboard only, screen reader.
4. A4: It names the canvas, the single-letter keys (2.1.4) and the day and night cycle as checked by hand.

### S2 css contrast (run, strengthened, pass rules written before the run) RED from: Contrast passes in CSS, fails on screen (Gotchas row 2)

Method as above (3 runs per arm, the loaded method, same role line "You are the QA player.", 0 skill reads without).

Task given to both arms:

~~~
No browser is available in this run; the stylesheet of the settings panel is all you have. `.panel-title { color: #595959; background-color: #ffffff; }`, and the title sits inside `.panel { background-image: linear-gradient(to bottom, #ffffff, #8a8a8a); }`. `.icon-btn { width: 36px; height: 36px; opacity: .85; }`. `:focus-visible { outline: 2px solid #9aa0a6; }`. axe reports 0 violations on the screen. Give a verdict (pass, fail, not applicable, not tested) with one line of evidence for each of 1.4.6, 2.5.5 and 2.4.13, and say whether the screen can be called AAA.
~~~

Pass rules (a run passes with every rule true; patterns first, borderline answers read by hand):

1. B1: The 1.4.6 verdict is not pass: the 1.4.6 line says not tested or fail.
2. B2: It says the 1.4.6 ratio must be measured from pixels on the render (screenshot, render or pixels) and names the gradient or the opacity as the reason the CSS value is not enough.
3. B3: The 2.5.5 verdict is fail and it states 36 against 44 px.
4. B4: The 2.4.13 verdict is not pass: it says fail or not tested.
5. B5: It does not call the screen AAA met (it says not met, cannot be called, or not established).

### S2 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25 on skill version 3.0.1, 3 runs per arm, the skill text appended to the with arm's system prompt, 0 skill reads in both arms. Transcripts: (transcripts in the private workspace). The pattern grader missed on B1, B2 and B5 in some runs, so all six answers were read by hand and the counts below are the hand counts.

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| B1 | 3 | 0 |
| B2 | 3 | 0 |
| B3 | 3 | 3 |
| B4 | 3 | 3 |
| B5 | 3 | 3 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

The without arm marked 1.4.6 "Pass for the title only" in 3 of 3, reading #595959 on #ffffff as 7.0:1 from the CSS and saying the solid background hides the gradient; the with arm ruled it "Not tested" in 3 of 3 and named the render pixel measurement (law 3). Both arms refused the AAA claim and failed 2.5.5 and 2.4.13 from the numbers.

### S3 untraceable fail (written, not run) RED from: A fail cannot be traced to code (Gotchas row 3)

Task: An axe selector `div:nth-child(3) > span`.

Pass rules:

1. It finds the component by accessible name or class with grep and reports file:line.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 1 |
| A2 | 3 | 3 |
| A3 | 3 | 1 |
| A4 | 3 | 3 |
| Runs passing every rule | 3 of 3 | 1 of 3 |

Skill reads: with arm 0, without arm 0.

Rule 1's pattern missed "not been established" in the first grading (with 2 of 3); the pattern was fixed and the same transcripts regraded, no rerun.
