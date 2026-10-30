# Behaviour evals

## Contents
- When to run
- How to run one
- orchestration (O1, O2, scenarios 1 to 3, O3)
- ui (U1)
- skill-craft (C1, C2, C3)
- performance-expert (P1, P2, P3)
- database-architect (D1, D2, D3)

A trigger test proves a skill loads; a behaviour eval proves the skill changes what the agent does. Every skill
lists 3 or more scenarios in its own Evals section (skill-framework.md row 14). This file holds the run steps
and the results tables for orchestration, ui, skill-craft, performance-expert and database-architect. motion-video keeps its scenarios in its own folder
(`motion-video/references/behaviour-evals.md` when it has one).

## When to run

After a major version bump (x.0.0) of one of these skills. One fresh read-only agent per scenario with the
skill and one without; record which assertions each met in the table under the scenario. A change is kept
only when the with arm's total over its 3 runs is more than the without arm's total, and at least the last
recorded with arm total on the same method; a new method or a reworded assertion starts a new baseline row.

## How to run one

1. Run both arms with the clean method (director DECISION): `claude -p "<prompt>" --model sonnet --restricted
   --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from one
   folder for both arms: empty, or holding the copies the scenario names (never a file of the skill under test), the same role line `--append-system-prompt "You are the director."` in both. The with arm adds `--add-dir`
   on a copy of the skill folder with every eval row that carries the scenario prompt removed, and its system prompt is
   the role line, then `Skill <name> loaded:` and the copy's whole SKILL.md, with no order to follow it (director
   DECISION: a behaviour eval measures following once loaded). Runners: `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c/scratch/run-clean2.sh` (orchestration) and
   `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/run-clean-a6.sh` (skill-craft; it saves each arm's system text as `<id>-<arm>.sys.txt`, and the with
   arm passes when that file ends with the copy's SKILL.md).
   Before scoring, `grep -c '<copy folder of the skill under test>' <without>.jsonl` prints 0 (0 reads of the skill
   under test; the shared folder is the same environment in both arms, so the gap measures the skill).
2. The prompt, the folder and the role line are the same in both arms; only `--add-dir` and the loaded SKILL.md text differ.
3. Read its final message and mark each assertion met or missed. A claim the message makes without the
   artifact (a command, a file, a sketch) is missed.

## orchestration

### O1. A small bug
cwd: the folder of the clean method (step 1), holding a copy of the app files the scenario reads (the agents
tab code and its feed fixtures). Prompt: "Fix this bug: the agents tab shows the
producer code instead of the agent name for agents with a name. Plan the work, write the briefs you would
send, stop before dispatch."

Assertions:
1. Sizes the ticket and names the players cast (at least one build player and a QA player).
2. Each brief names the skills the player runs, taken from `references/skill-map.md`.
3. Each brief carries a check written as a command with its expected output, or a number with a threshold.
4. Names a real fixture or feed file to reproduce with before any fix.
5. Says nothing is pushed without his yes.

### O2. A new screen
cwd: the folder of the clean method (step 1), holding a copy of the game editor sources and `docs/EDITOR-UI.md`.
Prompt: "Add a settings panel to the editor for the
day and night cycle. Plan it and write the briefs, stop before dispatch."

Assertions:
1. The frontend brief lists ui, engineering-standards and the project UI skill.
2. The audit skills (ui) go to QA or the reviewer, never the builder.
3. The critic scores the briefs before the wave (medium or large ticket).
4. A value the panel shows is served by the backend, never a frontend constant.

| Run | Skill version | O1 with | O1 without | O2 with | O2 without |
|---|---|---|---|---|---|

### Scenarios 1 to 3 (orchestration SKILL.md Evals)
Prompts and pass rules: orchestration SKILL.md Evals 1 to 3. Named method (step 1 pastes the skill; this one only names it): `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c/scratch/run-clean2.sh:13` gives the with arm
the role line plus "Skill orchestration is at $O/SKILL.md with references in $O/references. Read SKILL.md whole before answering and follow it." and `--add-dir` to the skill (`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c-report.md:122`); scenario 2 adds
`--add-dir` to the game repo on both arms (0 skill files there). cwd
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c/scratch/clean` (empty). Transcripts (in the private workspace); the
`*-addgameengine` runs are discarded (the without arm read a stale orchestration copy). The 3 without
transcripts hold 0 reads of a skill file (`grep -c` 0 for `skills/global/orchestration`, `claude/skills`,
the project skills folder). Full write-up: `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c-behaviour-runs.md` Loop 6.

| Run | Skill version | Model | S1 with | S1 without | S2 with | S2 without | S3 with | S3 without |
|---|---|---|---|---|---|---|---|---|
| lane C loop 6, named method (`run-clean2.sh`), transcripts `lane-c/scratch/runs6` | 7.0.5 | claude-sonnet-5-5 | PASS (refuses BUILT, cites law 9 and the `qa/before-*.png`, `qa/after-*.png` check) | FAIL (marks the rows built once it finds the file) | PASS (requirement 1 keeps "Z-WIDTH / Depth") | FAIL (splits it into Z-width and depth) | PASS (new row in the current batch after its last row) | FAIL ("put it in the next wave") |
| row 165, clean method (`score/165-orchestration-audit/evals/run.sh`, sonnet, cwd the app repo), evals 1 and 5 of SKILL.md | 8.0.0 | claude-sonnet-5-5 | S1 PASS (refuses BUILT: row V files, both director-critic sections, his look on the row) | S1 FAIL (would flip the rows to built) | eval 5 round 1 not scored: the prompt asked for a filter the repo already has, both arms stopped at D1 (`runs-r1`), prompt reworded to fuzzy matching | eval 5 round 2 with 3/4: scope.md Build/Not build/Reuse and a Buy line naming its queries (fuse.js, levenshtein) but marked not run (no web tool); contract.md before brief.md; Skills you run lines with ui, engineering-standards and the repo expert, names left to resolve from skill-map.md; plan order A, D4, D4c, D5, Dc, V, D6 and no result critic, but QA and reviewer not named as players | eval 5 round 2 without 0/4: no scope, no contract, no skills line, a pg_trgm migration on the shared database | n/a | n/a |

With beats without on all 3.

Lane C loop 8, loaded method (step 1 of How to run one): runner `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c/scratch/run-clean3.sh`, the with arm's skill copy
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c/scratch/orch-copy-707` (SKILL.md 7.0.7 minus its 3 eval prompt rows), 3 runs per arm, transcripts and each arm's
system text in `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-c/scratch/runs8` (`s<n>r<run>-<arm>.jsonl`, `.sys.txt`). Every init line: claude-sonnet-5-5, 0 MCP
servers, tools Glob, Grep, Read. Every with `.sys.txt` is the role line, `Skill orchestration loaded:` and the
copy's whole SKILL.md; every without `.sys.txt` is the role line alone. The 9 without transcripts hold 0 tool
calls naming `orchestration`, `orch-copy`, `claude/skills` or `.claude/skills`, and 0 naming `memory`,
`MEMORY` or `.claude/projects`. With arm reads of `~/.claude/skills/orchestration` were refused (outside the
allowed folders).

| Run | Skill version | Model | S1 with | S1 without | S2 with | S2 without | S3 with | S3 without |
|---|---|---|---|---|---|---|---|---|
| lane C loop 8, loaded method (`run-clean3.sh`), 3 runs per arm, `runs8` | 7.0.7 | claude-sonnet-5-5 | PASS 3/3 (refuses BUILT, names `built-check.sh` and the step 9 files) | FAIL 3/3 (would set the batch to built once it finds the file) | PASS 3/3 (every requirement line keeps "Z-WIDTH / Depth", 0 splits) | FAIL 3/3 ("Z-WIDTH (`depth`)" and asks if it is 2-D; "Z-width/depth" twice) | PASS 3/3 (new row after the batch's last row, order unchanged, names `law3-check.sh`) | FAIL 3/3 (next wave, or no placement until a plan is given; 1 run would reorder queued items) |

With beats without 9 to 0 on each scenario. O1 and O2 are not in this runner (they need copies of the app
and editor files); not run this loop.

### O3. Step 1 on a row's understand.md (orchestration SKILL.md Evals 4)
Clean method, loaded (step 1 of How to run one): sonnet, `--restricted`, tools Read, Grep, Glob, 0 MCP servers; the with arm's
system text is the role line, `Skill orchestration loaded:` and the copy's SKILL.md minus its Evals; the copy's prompts.md drops
the 10-29 06:25 section (his answer to the question under test). cwd holds the round 3 understand.md of a real row (its STATIC row
"who a character is" with owner after "each placed villager is its own unit") and his answers on file. Runner and transcripts in
the private workspace, row 160 score folder `evals/orch` (`run.sh`; `run5.sh` puts only the `claude -p` line under the heavy lock).
Assertions: A1 0 STOP card questions on a STATIC row; A2 that row rewritten to one record placed many times, quoting his base
problem and the card answer; A3 every DECISION on a table fact ends with its S row (test mode and Debt lines exempt).

| Run | Skill version | Model | With | Without |
|---|---|---|---|---|
| runs1, 3 per arm | 7.5.4 draft, before the Gotchas row | claude-sonnet-5-5 | not scored (superseded the same hour) | 0/9 (r1 asks on the groups row S8, r2 on the hero, r3 on the hero and the creatures) |
| runs2, 3 per arm | 7.5.4 with the Gotchas row | claude-sonnet-5-5 | 6/9 (A1 3/3, A2 0/3: "each placed villager becomes its own unit", A3 3/3) | 1/9 (r1 meets A1; A2 0/3, A3 0/3) |
| runs, 3 per arm | 7.5.4, step 1 row names "each placed ... its own" | claude-sonnet-5-5 | 3/9 (A1 3/3, A2 0/3, A3 0/3: each run leaves a data DECISION with no S row) | 0/9 (every run asks about the hero or the creatures, the question he called stupid) |
| runs4, with arm only (the without arm does not read the skill) | 7.5.4, the Stance DECISION bullet carries `(S<n>)` and the one record rule | claude-sonnet-5-5 | 7/9 (A1 2/3: run 2 asks how the placements of one character merge, a question on S7; A2 3/3; A3 2/3: run 3 DECISION 157-14 cites S19, a row that does not exist) | see runs1, runs2, runs |
| runs5, with arm only | 7.5.5 body (the Stance bullet gains "which placements are one thing ... never a question"; the step 1 row cut to 446 characters) | claude-sonnet-5-5 | 8/9 (A1 3/3: each card holds only Q6, the Railway run; A2 3/3; A3 2/3: run 1 ends each data DECISION with the row by name, "(S: groups)", not `(S<n>)`, and says the table has no S numbers yet; read by name every row it names exists, which would make 9/9) | see runs1, runs2, runs |

Without over the 9 finals of runs1, runs2 and runs: 1/27. The without transcripts hold 0 reads of the copy. The with arm
never opened `understand-method.md` (0 reads in 12 runs), so only the SKILL.md body acts. `scripts/understand-check.sh` on
the same understand.md prints 4 FAIL (1a no `Problem:`, 1f contradiction S7, 1c `Cause:` names no S row, 1e a Debt item
names no row; the fixture predates the method).

## ui

### U1. A settings section
cwd: the folder of the clean method (step 1), holding a copy of the game's `docs/EDITOR-UI.md` and the editor
components. Prompt: "Design the controls for a fog section: on or
off, density from 0 to 1, colour, and one of three fog kinds. Show me what you would build, no code."

Assertions:
1. Reads the repo's control kit (`docs/EDITOR-UI.md`) before choosing controls.
2. Two ASCII sketches, one chosen with the reason.
3. A segmented toggle for the three kinds, slider plus box for density, no checkbox list.
4. Labels three words or fewer in sentence case, a hint line, a summary line for the folded section.
5. Contrast and target size numbers named (7 to 1, 44 px).

| Run | Skill version | U1 with | U1 without |
|---|---|---|---|

## skill-craft

### C1. A correction from him
cwd: the folder of the clean method (step 1), holding a copy of `SKILLS.md` with the `### skill-craft` entry cut
and a copy of the tiles folder. Prompt: "add this to the skill: a tile colour setting only moves hue,
never luminance. Plan the change, stop before editing."

RED baseline: 95 lessons were written as memory files instead of skills (backup in the private workspace).

Assertions:
1. Names tiles as the owner and the file:line of the step that lacks the rule.
2. The plan puts the rule in a step of the owning skill, and 0 plan lines add a hook, memory file or CLAUDE.md line.
3. Plans lint `ok`, the router line and a version bump.

### C2. Fold one skill into another
cwd: the C1 folder of the clean method (step 1), the same in both arms. Prompt: "fold skill X into skill Y and delete X. Plan it, stop before
editing."

RED baseline: wave 1 folded dev-flow into testing-standard and left its trigger phrases behind; rows 163
and 164 of `trigger-queries.json` then missed at the router.

Assertions:
1. Moves every `metadata.triggers` phrase of X into Y.
2. Retargets every trigger row and every line naming X (lint W15 lists them).
3. Runs the router on the moved rows before calling it done.

### C3. Rewrite a skill in the framework
cwd: the C1 folder of the clean method (step 1), the same in both arms, and `--add-dir /home/visiond/projects/claude/skills/global/research`
in both arms (read only tools). Prompt: "rewrite the research skill in the framework. Plan the sections, stop before writing."

RED baseline: before the reset every skill was written in T-I-P-O with red flags as troubleshooting rows, no
Non-negotiables and no Deliverables (his message, audit `global.md` row skill-craft).

Assertions:
1. Lists the 14 sections in order, and a step that turns his feedback into instructions comes before any section text.
2. Every planned law carries a plain reason (what goes wrong without it, or what was measured); 0 pasted quotes of his,
   0 dates. (Assertions 1 and 2 changed at 5.0.0, when quoting him was replaced by writing the instruction; rows above
   5.0.0 were scored by the old text.)
3. Plans `scripts/lint-skills.py` with `ok` for the skill, and 10 to 20 trigger rows.

| Run | Skill version | Model | C1 with | C1 without | C2 with | C2 without | C3 with | C3 without |
|---|---|---|---|---|---|---|---|---|
| superseded, no transcripts kept | 4.0.1 | claude-opus-5-5 (`claude -p`, Bash, Edit and Write disabled; not clean: the without arm could read the skill) | 3/3 | 1/3 (2) | 3/3 | 2/3 (1, 2; plans the trigger test, never the router) | 2/3 (1, 3; law 1 has a reason, the other laws neither quote nor reason) | 1/3 (1; no lint) |
| clean | 4.0.2 | claude-sonnet-5-5 | 2/3 (2, 3; names tiles from the trigger rows but not the step skipped, since SKILLS.md is out of reach) | 1/3 (2; asks where the skill is) | 3/3 | 0/3 (asks for names and paths) | 3/3 | 0/3 (asks for the files) |
| superseded (the role line only named the skill), shared folder, C1 only, 3 runs per arm | 4.0.4 | claude-sonnet-5-5 | 3/3, 2/3, 2/3 (run 1 names tiles from the SKILLS.md copy and step 5 as the place; runs 2 and 3 miss 1: they grep the live path of Intake 2, refused, and never look in the working folder) | 1/3, 1/3, 1/3 (2 only; finds tiles by Glob, names no skipped step, plans no lint or router) | | | | |
| loaded, shared folder, no research folder, C3 scored by the old assertion text, 3 runs per arm | 4.0.4 | claude-sonnet-5-5 | 2/3, 2/3, 3/3 (all plan the rule in a step of tiles and lint, router, bump; only run 3 reads the SKILLS.md copy before naming the owner) | 1/3, 1/3, 1/3 (2 only; owner found by Glob, no step named as skipped, no lint or router) | 3/3, 3/3, 3/3 | 1/3, 1/3, 1/3 (1 only; merges the trigger phrases, retargets no trigger row, no router) | 2/3, 3/3, 2/3 (run 1 never plans prompts.md first; run 3's laws carry quotes but no dates) | 0/3, 0/3, 0/3 (takes the tiles T-I-P-O layout as the framework, no quotes, no lint) |
| loaded, shared folder, 3 runs per arm, C1 assertion 1 reworded (same transcripts as the row above, rescored) | 4.0.4 | claude-sonnet-5-5 | 3/3, 2/3, 3/3 (run 2 names no file:line: it reads no tiles file) | 2/3, 2/3, 2/3 (all name `tiles/SKILL.md:53`; none plans lint or the router) | | | | |
| loaded, shared folder, no research folder, old assertion text with the pass rules written after the runs, C3 only, 3 runs per arm | 4.0.5 | claude-sonnet-5-5 | | | | | 3/3, 3/3, 1/3 (run 3 plans the evals before `prompts.md` and no lint) | 0/3, 0/3, 0/3 (takes the tiles T-I-P-O layout as the framework, no quotes, no lint) |
| loaded, shared folder, research folder in both arms, assertions fixed before the run, C3 only, 3 runs per arm | 4.0.7 | claude-sonnet-5-5 | | | | | 2/3, 2/3, 2/3 (all list the 14 sections in order with `prompts.md` first and mark the laws as waiting for his words; none plans `scripts/lint-skills.py` with `ok`: run 1 says "then lint", runs 2 and 3 name no lint) | 0/3, 0/3, 0/3 (all take the T-I-P-O or step table layout as the framework, no laws with quotes, no lint, no trigger rows) |
| loaded, shared folder, research folder in both arms, assertions as written in C3 above, step 4 Output names the lint, C3 only, 3 runs per arm | 4.0.8 | claude-sonnet-5-5 | | | | | 2/3, 2/3, 1/3 (assertion 1 fails in run 3: no step puts prompts.md before section text; assertion 2 passes in all 3; assertion 3 fails in all 3: run 1 says "lint" in its order of work, runs 2 and 3 name no lint) | 0/3, 0/3, 0/3 (all take the T-I-P-O or step table layout as the framework, no quotes, no lint, no trigger rows) |
| loaded, shared folder, research folder in both arms, assertions as written in C3 above, lint named in the Pipeline step 6 Step column, the Definition of done and the framework template row 12, C3 only, 3 runs per arm | 4.0.9 | claude-sonnet-5-5 | | | | | 2/3, 3/3, 0/3 (3/3 on assertion 3 if the lint is accepted without the script name). Assertion 1 fails in run 1: it starts at step 3 and puts no step for `prompts.md` first; assertion 2 passes in all 3; assertion 3 fails in all 3 as written: runs 1 to 3 plan lint `ok   research` in the Definition of done and 10 to 20 trigger rows, none names `scripts/lint-skills.py` | 0/3, 0/3, 0/3 (all take the tiles or step table layout as the framework, no quotes, no lint) |

Clean run (loop 4): method above, cwd `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/clean` (empty), with arm `--add-dir`
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/cs-copy/claude-skills` (this section's scenarios and the 2 trigger rows carrying the C1 and C3
prompts removed). Prompts exactly as in C1, C2 and C3 above. Transcripts
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/runs4/c<n>-<with|without>.jsonl`. The 3 without transcripts: 0 Read calls; every Glob printed
"No files found" or was refused outside the working folder. With beats without on all 3. In both arms no file
outside the working folders could be read, so C1 assertion 1 (the owner from SKILLS.md) cannot fully pass.

C1 rerun (loop 5, director DECISION): both arms run from `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/c1env`, which holds a copy of
`SKILLS.md` with the `### skill-craft` entry cut and a copy of the tiles skill folder. The with arm adds `--add-dir`
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/cs-copy5/claude-skills` (4.0.4; this section's scenarios, the C1 Evals row and the trigger row
"add to the tiles skill that a colour setting only moves hue" removed; `grep -rl 'moves hue'` prints nothing). Runner
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/run-clean-a5.sh`, transcripts (in the private workspace). All 6 inits: `claude-sonnet-5-5`,
tools Glob, Grep, Read, `mcp_servers []`, result `success`. `grep -c 'cs-copy5'` prints 0 on all 3 without
transcripts. Every call into `/home/visiond/projects/claude/skills` was refused as outside the working folders.
With 7 of 9 assertions, without 3 of 9. Superseded by the loaded run below.

Loaded run (loop 5, director DECISION after lane B 4b: the with arm opened its skill in 3 of 18 runs when only
named): C1 to C3 from the same `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/c1env` in both arms, role line "You are the director." in both. The with
arm's system text is the role line, `Skill skill-craft loaded:` and the whole SKILL.md of
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/cs-copy6/claude-skills` (4.0.4; this section's scenarios, the C1 to C3 Evals rows and the 2 trigger rows
carrying the C1 and C3 prompts removed; `grep -rlE 'moves hue|rewrite the research skill|fold skill X'` prints nothing),
plus `--add-dir` to that copy. Runner `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/run-clean-a6.sh`; transcripts and system texts
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/runs6/c<n>r<run>-<with|without>.{jsonl,sys.txt}`. Proof per run: all 18 inits `claude-sonnet-5-5`, tools
Glob, Grep, Read, `mcp_servers []`, result `success`; the 9 with `.sys.txt` files start with the role line and end with
the copy's SKILL.md (17553 bytes each); the 9 without `.sys.txt` files hold only the role line; `grep -c 'cs-copy6'`
prints 0 on the 9 without transcripts. Every call into `/home/visiond/projects/claude/skills` was refused.
Assertions met: with 23 of 27, without 6 of 27. With beats without on all 3.

C3 rerun (loop 6): the loaded method above, cwd `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/c1env` in both arms, with arm copy `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop6/cs-copy7/claude-skills` (4.0.5; this section's scenarios, the C1 to C3 Evals rows and the 2 trigger rows carrying the C1 and C3 prompts removed; `grep -rli 'rewrite the research skill'` on it prints nothing). Runner `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/run-clean-a7.sh`, transcripts (in the private workspace). All 6 inits: `claude-sonnet-5-5`, tools Glob, Grep, Read, `mcp_servers []`, result `success`; each with arm's `.sys.txt` ends with the copy's SKILL.md; `grep -c 'cs-copy7'` prints 0 on the 3 without transcripts. Scored with two pass rules written after the runs (assertion 1: the 14 sections in order and `references/prompts.md` read or filled first; assertion 2: each planned law is to carry his dated quote), which are now in the assertion text: with 7 of 9, without 0 of 9. Superseded by the research folder baseline below.

C3 baseline (loop 7): the loaded method above, assertions 1 to 3 as written in C3 before the run, cwd `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/c1env` in both arms, `--add-dir /home/visiond/projects/claude/skills/global/research` in both arms, with arm copy `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop7/cs-copy8/claude-skills` (4.0.7; this section's scenarios, the C1 to C3 Evals rows and the 2 trigger rows carrying the C1 and C3 prompts removed; `grep -rli 'rewrite the research skill'` on it prints nothing). Runner `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/run-clean-a8.sh`, transcripts and system texts (in the private workspace), final messages in `.result.txt` beside them. All 6 inits: `claude-sonnet-5-5`, tools Glob, Grep, Read, `mcp_servers []`, result `success`; each with arm's `.sys.txt` ends with the copy's SKILL.md; `grep -c 'cs-copy8'` prints 0 on the 3 without transcripts; every run made 3 or 4 tool calls into the research folder. With 6 of 9, without 0 of 9: with beats without. Assertion 3 fails in all 3 with runs, so step 6 (lint) does not reach the plan; that is the next fix.

C3 baseline (loop 8): same method and assertion text as loop 7, after SKILL.md step 4 Output was changed to name `python3 scripts/lint-skills.py` printing `ok   <name>`. cwd `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop5/c1env` in both arms, `--add-dir /home/visiond/projects/claude/skills/global/research` in both arms, arm copy `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop8/cs-copy9/claude-skills` (4.0.8; this section's scenarios, the C1 to C3 Evals rows and the 2 trigger rows carrying the C1 and C3 prompts removed; `grep -rli 'rewrite the research skill'` on it prints nothing). Runner `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop8/run-clean-a9.sh`, transcripts, system texts and final messages (in the private workspace). All 6 inits: `claude-sonnet-5-5`, tools Glob, Grep, Read, `mcp_servers []`, result `success`; each with arm's `.sys.txt` ends with the copy's SKILL.md; `grep -c 'cs-copy9'` prints 0 on the 3 without transcripts. With 5 of 9, without 0 of 9: with beats without. Assertion 3 still fails in all 3 with runs: naming the lint in the step 4 Output did not put `lint-skills.py` with `ok` into any plan, so the step 4 edit is not shown to work; the next fix is a RED to find which step the plan reads (run 1 does name "lint" in its order of work).

C3 baseline (loop 9): same method and assertion text as loop 8. Rerun 1 (4.0.9: the Pipeline step 6 Step column names `python3 scripts/lint-skills.py`, the Definition of done opens with the lint box) used arm copy `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop9/cs-copy10/claude-skills`, runner `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop9/run-clean-a10.sh`, transcripts (in the private workspace): assertion 3 failed in all 3 with runs (`lint-skills` count 0 in the 3 final messages); the plans describe the new skill's 14 sections and then say which Pipeline steps they start with, and do not list the later steps. Rerun 2 (the row above): the framework template row 12 (`references/skill-framework.md`, the table the plans copy their section 12 from) now says the first box is `python3 scripts/lint-skills.py` printing `ok   <name>`; arm copy `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop9/cs-copy11/claude-skills` (the 4.0.9 skill with C1 to C3 sections and Evals rows removed; `grep -rli 'rewrite the research skill'` prints nothing), runner `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/w2a/lane-a/scratch/loop9/run-clean-a11.sh`, transcripts and final messages (in the private workspace), cwd and research folder as in loop 8. All 6 inits claude-sonnet-5-5, tools Glob, Grep, Read, `mcp_servers []`, result `success`; `grep -c cs-copy11` is 0 on the 3 without transcripts. With 5 of 9 as written (8 of 9 with the lint accepted by name), without 0 of 9. The plans now carry the lint with `ok` and the skill name in section 12; they abbreviate the script path. The 2 rerun limit is used; the wording of assertion 3 is unchanged.

The project skills keep their behaviour results in the private overlay, `skills/specific/<project>/facts/`.

## performance-expert

### P1 to P3
Prompts and pass rules: performance-expert SKILL.md Evals. Loaded method (How to run one, step 1): role line "You are
the builder player." in both arms; the with arm adds `Skill performance-expert loaded:` and the copy's SKILL.md cut
before its Evals section, plus `--add-dir` on that copy; cwd an empty folder for both. 1 run per arm. Every init line:
claude-sonnet-5-5, 0 MCP servers, tools Glob, Grep, Read. `grep -c` of the copy folder in the 3 without transcripts
prints 0. Runner, prompts, transcripts and system texts: the session scratchpad `beh/` folder (`run.sh`,
`prompts.json`, `P<n>-<arm>.jsonl`, `.sys.txt`, `.txt`).

| Run | Skill version | Model | P1 with | P1 without | P2 with | P2 without | P3 with | P3 without |
|---|---|---|---|---|---|---|---|---|
| 1, loaded method, 1 run per arm | 1.1.0 | claude-sonnet-5-5 | 4/4 (baseline of counts, median and p95 before code; one change; `perf-verdict.py frames` keep) | 0/4 (found the empty folder and asked for the repo, no plan) | 3/3 (10 pairs with GC, 10% heap and equal listeners, uncapped caches named) | 0/3 (blamed saved state across launches; "several times", no GC, no threshold) | 3/3 (count above 0, 3 runs and the verdict, his page and dev server) | 1/3 (his hardware; no count check, average over reruns with no noise rule) |
| 2, loaded method, 1 run per arm, P1 prompt adds "The folder you are in is empty; plan the work you would do." | 1.1.2 | claude-sonnet-5-5 | 4/4 (baseline before code, objects and draw calls, one change, `perf-verdict.py frames` named) | 1/4 (measure first; draw calls per frame only, no table, adds the cache with bounds and a scaled layer in one go) | 2/3 (10 pairs with GC; the 10% heap and equal listeners pass not stated; cache bound only as a listed cause) | 0/3 | 3/3 | 0/3 |
| 3, as run 2 | 1.1.3 | claude-sonnet-5-5 | 4/4 | 1/4 (frame time and draw calls per frame, no objects stored or drawn, no one-change rule) | 3/3 (10 pairs with GC, `leak: ok` only with heap within 10% of pair 1, listeners and nodes equal, heap not climbing) | 0/3 (listener causes, no threshold) | 3/3 | 0/3 |

With beats without on all 3 in every run. In run 1 P1's without arm made no plan (it found the empty folder and asked for the repo), so P1 separated less than its score said. Runs 2 and 3 state the folder is empty in the P1 prompt: the without arm plans (1/4 in both) and P1 separates 4/4 against 1/4. P2 rule 2 (the 10% heap and equal listeners pass) was missed by the with arm in run 2 and met in run 3; 1 run per arm, no variance judged.


## database-architect

Scenarios D1 to D3 of `/home/visiond/projects/claude/skills/global/database-architect/SKILL.md` Evals, run by the clean method above.

| # | Prompt and folder | Assertions |
|---|---|---|
| D1 | "Given I want to build a game where one character, a merchant, appears in many levels and is the same character everywhere (the same look and the same stats), but stands in a different place and does different things in each level, analyze the following database schema and its seed data: d1b/schema.sql and d1b/seed.sql"; `level_characters` copies sprite, animations and stats per level, and the seed copies already differ (sprite v2 in level 2, `max_hp` 55 and no walk animation in level 3) | 1 a row per fact marked static or dynamic with its owner, before the first finding (law 3); 2 names the 3 drifted values and holds the merge until one value is chosen; 3 every finding has table.column evidence, a severity, a fix and a migration (law 4) |
| D2 | "I am building a small online shop: customers browse products, place orders with several items, and later see their past orders with the price they paid. Analyze the following database schema: d2/schema.sql" | 1 the domain or static and dynamic split before any finding; 2 every finding names an entity of the context; 3 0 findings past the context |
| D3 | "In my shop every order is paid by exactly one payer, and deleting an order deletes its payer. Analyze the following database schema and the Ecto schemas: d3b/schema.sql and d3b/order.ex"; the database has no foreign key, a plain index and no cascade, while Ecto has `foreign_key_constraint`, `unique_constraint` and `on_delete: :delete_all` | 1 names all 3 Ecto claims the database lacks; 2 every finding has evidence, a severity, a fix and a migration (law 4); 3 the duplicate and orphan data step runs before the unique index and the foreign key |

| Run | Skill version | Model | D1 with | D1 without | D2 with | D2 without | D3 with | D3 without |
|---|---|---|---|---|---|---|---|---|
| 1, clean method, 1 run per arm, runner and transcripts in the private workspace, row 160 score folder `evals/` | 1.0.1 | claude-sonnet-5-5 | 3/3 (6 copied columns as table.column, `characters` plus a placement row, backfill by name then drop the copies) | 2/3 (the split and the new table; the migration only offered, "I can write this up") | 3/3 (domain and split tables first, every finding on an entity, currency and statuses under Open questions) | 1/3 (no domain step; adds an `active` flag, currency, shipping, tax and `updated_at` his context never asked for) | 3/3 | 3/3 (unique index, `has_one` vs the plain index, the migration with the duplicate check) |
| 2, clean method, 3 runs per arm, D1 and D3 as above (run 1 used a seedless D1 and a D3 with a foreign key), runner and transcripts in the private workspace, row 160 score folder `evals/runs2` | 1.0.2 (Checks 3 and 4 as commands) | claude-sonnet-5-5 | 9/9 | 3/9 (drift named 3/3; 0/3 a static or dynamic row per fact; 0/3 a severity or migration per finding) | 9/9 (domain and split first, currency and statuses under Open questions) | 3/9 (0/3 domain step; 3/3 an `active` flag, currency, shipping or `created_at` proposed) | 9/9 | 6/9 (3 claims and the data step 3/3; 0/3 a severity per finding) |
| 3, clean method, D1 with arm only, 3 runs, one `claude -p` per heavy lock, rules written before the run, row 160 score folder `evals/runs6` | 1.0.5 (Checks 2 to 5 in `scripts/check-findings.sh`, Stance DECISION `(S<n>)`) | claude-sonnet-5-5 | 6/9 (assertion 1 3/3; 2 3/3; 3 0/3: run 1 findings 2 and 5 cite `level_characters(level_id)` and `seed.sql:1-2`, run 2 finding 2 cites only the table `level_characters`, none a `table.column`; run 3 finding 6 gives "None" as its migration, a miss because the rules do not count it; first reported 7/9) | not run | not run | not run | not run | not run |
| 4, as run 3, row 160 score folder `evals/runs7`, the same RULES.md | 1.0.6 (law 4: the Evidence cell names the `table.column` it lands in; Check 3 prints `NO COLUMN n`) | claude-sonnet-5-5 | 7/9 (assertion 1 3/3; 2 3/3; 3 1/3: every Evidence cell names a `table.column`; runs 1 and 2 each give "None now." as the migration of a kept debt finding, a miss) | not run | not run | not run | not run | not run |

Run 1: with 9/9, without 6/9; the 3 without transcripts hold 0 reads of the skill copy. D2 separates most (the domain step and the context bound); D3 does not separate, and D1 only on the migration, so a D1 schema whose copies already differ is the next run.

Run 2: with 27/27, without 12/27; the 9 without transcripts hold 0 reads of the skill copy. D1 and D3 now separate on laws 3 and 4 (the without arm finds the problems but writes no per fact split and no severity or migration per finding); D2 on the domain step and the context bound. D1 assertion 1 is strict: the without arm lists identity and placement columns, which a looser reading counts as a split (then 6/9).

Run 3: D1 with 6/9 against 9/9 in run 2. The Evidence misses are each a finding outside the copied columns (the seed sequence, the missing character reference) whose Evidence cell holds no `table.column`. The runs cannot execute `check-findings.sh` (read only tools, the skill folder outside the allowed paths), and its Check 3 tests the backticked columns a cell holds and passes a cell that holds none. The Stance `(S<n>)` clause does not act on D1: 3 DECISION lines in 3 runs (all in run 2), 0 of them with `(S<n>)`; the no-ticket case has no numbered table to cite.

Run 4: D1 with 7/9. The Evidence misses are gone (0 of 20 findings without a `table.column`); the 2 misses left are a kept debt finding whose Migration cell says "None now.", which the rules do not count as a migration. Open at the checkpoint.
