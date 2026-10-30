# Trigger results

Latest scores from `scripts/trigger-test.py`, run on the named rows of `trigger-queries.json` only.

## Contents
- Latest scores
- Router
- skill-craft
- performance-expert
- orchestration
- database-architect

| Skill or group | Latest score |
|---|---|
| ui | 3/3 (100%) |
| ui | 1/3 in the harness, router 3/3 |
| engineering-standards | 1/3 in the harness, router 3/3 |
| ui, engineering-standards, ui, engineering-standards, orchestration, dev-flow, writing, skill-craft, review, research, ui (35 rows, new descriptions) | 29/35 (82%): 24/35 with a 5 call cap, where session-start used every call; the 11 misses rerun with a 12 call cap, 5 passed |
| blog (6 rows, --jobs 1) | earlier 6/6 (100%), router 6/6, run file not kept; rerun (transcripts in the private workspace), model claude-opus-5-5: 4/6 (67%), both near misses pass, "write the blog post for P24 ..." and "make the images for the post on autotiles ..." got session-start only |
| motion-video (builder 2, 3 rows) | 2/3 before, 1/3 after (a project memory pulled the session); rerun by builder 2 after the memory moved into the skill |
| skill-craft (15 rows: 11 should, 4 near miss, --jobs 2) | 15/15 (100%) and 14/15 (93%) on v4.0.4 (the 464 character description), the same on v4.0.2, after 11/15 (73%) and 12/15 (80%) on v4.0.1; router 15/15 on every version. Run history below |
| orchestration 7.2.0 (3 new rows: 2 should, 1 near miss, --jobs 3) | 3/3 (100%), model claude-opus-5-5, after 1/3 twice on the old first sentence (the session read work-report.md by hand without loading the skill, Gotcha 11; fixed by naming the report job in the first sentence); router 3/3: both should rows print orchestration, the near miss prints the project expert, writing and ship. A sample of 6 older orchestration rows scored 1/6 on both the old and the new description |

The 6 rows still missing all get the right line from the router (see below); the session answered or asked
for the material instead of loading the skill: "look over my branch" (review), two dev-flow rows, one
engineering-standards row, "humanize this" with no text, "look it up" with no subject.

## Router

Measured by piping each prompt with its cwd into `~/.claude/hooks/skill-router.py`, free and instant.

| Set | Old hand table | Router built from frontmatter |
|---|---|---|
| Every row of trigger-queries.json (333) | 229/333 | 314/333; the misses are 18 near-miss rows where the router also lists a second skill, and one should row |
| The AUDIT C4 misfires plus controls (44 prompts) | 12/44 | 44/44 |

- writing (new): 3/3 (100%), 2 should rows and 1 near miss (the CV content edit). Router printed it on both should rows and not on the near miss. Run file (transcripts in the private workspace), model claude-opus-5-5 (the same run as the blog rows): 3/3.

## skill-craft

Run files: (transcripts in the private workspace)
Model claude-opus-5-5 (trigger-test.py passes no `--model`; the streams' init events name it).
(`*.txt` trigger-test output; runs 11 and 12 in `loop5/all15-v404-<n>.{txt,json}`, `*.json` its `--out`, `*.jsonl` full uncapped `claude -p` streams, `calls.py` lists each tool call).

| Run | Description | Score | Misses |
|---|---|---|---|
| 1, all 15 | v4.0.0: "Build, change, lint ..." | 11/15 (73%) | composition didnt trigger, water did not trigger, turn this into a skill (release), add this to the skill (seed) |
| 2, all 15 | v4.0.1: first sentence says when (did not trigger, become a skill, a rule added) | 12/15 (80%) | tiles, water, release |
| 3, the 2 rows missed twice | v4.0.1 | 1/2 | release |
| 4, uncapped streams | v4.0.1 | water: skill-craft at call 2; release: session ended by itself after 6 calls (8 turns), 0 Skill calls after session-start | |
| 5, 3 uncapped streams per row | v4.0.2a: "invoked first, before the material is read" | release 1/3 (ended by itself at 10 to 11 calls), water 3/3 (skill-craft at call 1 or 2) | |
| 6, 3 uncapped streams | v4.0.2b: "before the material is looked for and even when it is missing" | release 3/3, skill-craft at call 2 | |
| 7, all 15 | v4.0.2b | 13/15 (86%) | tiles, seed |
| 8, 3 uncapped streams per row | v4.0.2b | tiles 2/3 (the miss opened the tiles SKILL.md at call 3 and ended by itself at 5 calls); seed 3/3 | |
| 9, all 15 | v4.0.2: "before the material or the skill to change is opened and even when the material is missing" | 14/15 (93%) | seed |
| 10, all 15 | v4.0.2 | 15/15 (100%) | none |
| 11, all 15 | v4.0.4: 464 characters, 7 phrases, the inventory clause cut, the "invoked first" clause kept | 15/15 (100%) | none |
| 12, all 15 | v4.0.4 | 14/15 (93%) | "which skills does the router print when I say deploy to staging?" (got session-start only) |

Cause, from the streams: never the 12 call cap. Every miss ended on its own at 5 to 11 tool calls, below
`MAX_TOOL_CALLS`. No sibling was invoked either (router 15/15). The session went straight to the material (the release
release checklist, which a fresh session does not have, or the SKILL.md of the skill named in the prompt) and
answered without loading skill-craft. Fix: the description's first sentence says it is invoked first, before the
material or the skill to change is opened, even when the material is missing (Gotcha 11). The cap and detection in
`scripts/trigger-test.py` are unchanged.


## performance-expert

Model claude-opus-5-5 (trigger-test.py passes no `--model`), `--jobs 3`, 2026-10-28. Rows: 14 in
`references/trigger-queries.json` (10 should, 4 near miss) and 3 in the private overlay with `"cwd"` at the project root
(2 should, 1 near miss). Router: 17/17 (the skill on all 12 should rows, on 0 of the 5 near miss rows).

| Run | Description | Score | Misses |
|---|---|---|---|
| 1, all 17 | v1.0.0 | 16/17 (94%) | "the merger must build like our houses, with the less amount possible of cells and tiles, so the game is blazingly fast" (got session-start only) |
| 2, the miss 3 times | v1.0.0 | 0/3 | the same row: session-start only twice, session-start and the project expert once |
| 3, all 17, after critic round 1 | v1.1.0 (description: run by the builder and the QA player) | 16/17 (94%) | the same merge row (got session-start only) |

Cause, read from the got lists: the router printed the project expert and this skill; the session read the row as
merge work for the project expert and never loaded this skill. Left as it is: the row is half a storage merge ask, and
the project expert owns that code. Fix next: a rerun after the project expert's description names this skill for speed.

## orchestration

Model claude-opus-5-5 (trigger-test.py passes no `--model`), `--jobs 3`, 2026-10-29. Rows: the 3 step 1 correction rows
in `references/trigger-queries.json` (2 should, 1 near miss). Router: 3/3 (the skill on both should rows, on 0 near miss rows).

| Run | Description | Score | Misses |
|---|---|---|---|
| 1, all 3 | v7.5.0 | 2/3 (66%) | "fix this bug: the sprites differ between two places, ..." (got bug-investigation only) |
| 2, the miss 2 times | v7.5.0 | 2/2 | none |
| 3, the miss 5 times | v7.5.0 | 5/5 | none |
| 4, all 3 | v7.5.0 | 3/3 | none |

Total 12/13 (92%), at the 90% bar. Run 1 lost the bug row once to bug-investigation; runs 3 and 4 passed it 6/6, so
bug-investigation's Do NOT line was left as it is (the 5 run rule: change it under 4/5).

Step 1 method rows (4 new: 3 should, 1 near miss to database-architect), `--jobs 1` under the workspace heavy.sh lock, claude-opus-5-5:

| Run | Skill version | Result | Misses |
|---|---|---|---|
| 1 | v7.5.4, description before the step 1 phrases | 1/4 | "that is not the framework" to session-start; "base problem first" to none; "more machinery than I asked" to writing |
| 2 | v7.5.4, Use when adds "break it down to the base problem", "that is not the framework", "scope creep", "small rules", "more machinery than I asked" | 4/4 | none |

## database-architect

Model claude-opus-5-5 (trigger-test.py passes no `--model`), `--jobs 3`, 2026-10-29. Rows: 14 in
`references/trigger-queries.json` (10 should, 4 near miss, the near misses to ship, review, engineering-standards and
bug-investigation).

| Run | Description | Score | Misses |
|---|---|---|---|
| 1, all 14 | v1.0.2 | 14/14 (100%) | none |
