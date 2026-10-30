# Evals for engineering-standards

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `engineering-standards`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | the spec doesnt say how the backend contexts and frontend components will be built, add the architecture and the flows | yes | - |
| T2 | how are we going to avoid duplicated code and keep business logic clean in this plan? I want the component tree and a state machine | yes | - |
| T3 | write the guard clauses for this elixir function, no nested ifs | no | - |
| T4 | the plan needs an architecture section: component tree, state ownership and the flows | yes | ~/projects/game |
| T5 | which context owns this table, and draw the state machine for the quest lifecycle | yes | ~/projects/game |
| T6 | write the controller action with guard clauses and no else | no | ~/projects/game |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill engineering-standards loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: the plan had a data model and tasks only (Gotchas row 1, 10-20)

Role line: "You are the architect."

Task given to both arms:

~~~
Write plan.md for this spec. Do not write code.

spec.md: Players accept a quest from an NPC and see its steps in the HUD; finishing the last step gives a reward. Quests have a lifecycle.

What exists (you cannot open files here; treat the list as what you have read in full):
- lib/game/games.ex (900 lines, owns the games table and also has quest helpers)
- lib/game/quests.ex (new file needed)
- assets/hud/Hud.tsx (1400 lines: layout, inventory, minimap)
- tables: games, npcs; a quests table does not exist.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: plan.md has the sections Read list, Backend, Frontend, Duplication, Gaps, Flows and Tasks: at least 6 of these 7 words appear as headings or labels.
2. A2: A state machine for the quest lifecycle lists states, events and guards.
3. A3: The god file `Hud.tsx` is extracted in its own task before the quest HUD task, and quests.ex owns the quests table (one owning context).
4. A4: Tasks name their standards and gates: `standards` appears at least 3 times and `gates` at least 3 times.

### S2 two owners (written, not run) RED from: Two plans define the same function or table differently (Gotchas row 2)

Task: Two plan drafts that both put the `quests` table in their own context.

Pass rules:

1. It names one owning context for the table and makes the other plan call that context's public function.

### S3 god file (written, not run) RED from: A builder adds 300 lines to the god file (Gotchas row 3)

Task: A feature that adds 300 lines to a 2,000 line component file.

Pass rules:

1. The plan has an extraction task for the part the feature touches, listed before the feature task, with behaviour unchanged.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 0 |
| A2 | 3 | 1 |
| A3 | 3 | 1 |
| A4 | 3 | 0 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 0, without arm 0.


