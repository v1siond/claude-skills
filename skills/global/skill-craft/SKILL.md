---
name: skill-craft
description: Writes and changes the skills under /home/visiond/projects/claude/skills, invoked first, before the material or the skill to change is opened and even when the material is missing. Run by the director. Use when he says "skill", "make this a skill", "turn this into a skill", "add this to the skill", "did not trigger", "triggered the wrong one", "audit the skills". Do NOT use for the work a skill describes (that skill) or notes and handoffs (orchestration).
metadata:
  author: Alexander Pulido
  version: 5.0.0
  triggers: ["skill", "make this a skill", "add this to the skill", "turn this into a skill", "did not trigger", "didn't trigger", "didnt trigger", "triggered the wrong one", "audit the skills", "which skills", "skill router", "trigger test"]
  sources: the skill framework in references/skill-framework.md, built from the Chan, Charlie and Howseen motion skill repos; Anthropic, The Complete Guide to Building Skills for Claude (PDF) and its best practices page; the MindStudio skills post; dev.to ddialar on creating skills; skill-creator plugin
---

# Claude skills

Writes, changes, audits and lists the skills under `/home/visiond/projects/claude/skills`, so every recurring
job has one skill that the router prints on his words, that a critic can fail line by line, and that serves a
step of orchestration. Run by the director. His feedback reaches a skill only as the instruction it implies,
written as a step, a law or a check.

## When to use

- A skill is created, changed, folded, deleted or audited, in any scope.
- He corrects how a job was done: the correction goes into the step of the owning skill.
- A skill did not trigger, or the wrong one did.

## When not to use

- Doing the job a skill describes: run that skill.
- A handoff note or where-we-left-off: orchestration.
- An instruction for the current work only ("for now", "this session", "until I say stop"): it goes in that work's score or brief.

## Stance

- **You write a process, never a suggestion.** Every section of a skill is a check a critic can fail.
- **You point at the doc, never copy it.** Docs evolve; the skill carries the steps, rules and traps the doc lacks and names the doc section for the rest.
- **You turn feedback into instructions.** Read his correction for what the work must do differently and write that as a step, a law or a check in plain descriptive words; his frustration, typos and the incident story stay out. His domain nouns stay exact, his intent is never reinterpreted.
- **You decide alone, and log as DECISION in ORCHESTRA.md:** the wording, the split between SKILL.md and references/, the trigger phrases taken from his messages.
- **You never decide alone:** what is global (his call, ORCHESTRA.md D1 in `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/ORCHESTRA.md`), or deleting and merging a skill (his yes on the list).

## Non-negotiables

1. **Every SKILL.md has the 14 framework sections in order and 80 to 200 lines.** Why: a skill without laws, gotchas and deliverables reads as a suggestion and gets skipped. → `references/skill-framework.md`
2. **Feedback is turned into a descriptive instruction in the step it corrects, never pasted as a quote;** 0 `*"..."*` quotes and 0 `*prompts*.md` files in a skill (lint check `quote`). Why: pasted quotes record the incident, not the behaviour, and a later reader has to guess the instruction behind them. → `references/skill-framework.md` Rules
3. **Every line passes W1 to W19:** a quality word becomes a number with a unit, a command with its pass output, or a named thing. Why: the model follows a number, a command or a named thing; a quality word leaves it to guess. → `references/writing-standard.md` B and C
4. **Orchestration is the only workflow.** A skill's Pipeline holds the steps of its craft inside one orchestration step, with no approval gate, cast, own report or own test order. Why: two workflows in one session give two answers to "what runs next". → orchestration
5. **A skill lives in `global/<name>` when it applies in every repo, in `specific/<project>/<name>` when it holds one repo's facts (16 global skills, `ls /home/visiond/projects/claude/skills/global | wc -l` prints 16).** Why: a skill per repo per job multiplies owners; global skills plus a few repo fact skills keep one owner. → `references/frontmatter-and-router.md`
6. **A project skill holds only facts** (paths, commands, names, its own gotchas) and names the global step it serves; a global holds no project rows, and no public file names a project: a full `python3 scripts/lint-skills.py` run FAILs with file:line on any line of `skills/global`, `agents`, `harness`, `docs`, `standards` or `README.md` holding a term of `~/.claude/local-skills/public-terms.txt`, and a removed term is purged from the git history too, not only the tree. Generic tooling (agents, harness, infra skills) stays public; only project facts go private. Why: the public repo is his generic workflow, and a project fact in it leaks that project. → `references/skill-framework.md` Rules
7. **One owner per job:** a duplicate or a skill contradicting a global is stripped or deleted, on his yes on the list. Why: two owners of one job drift apart and the router picks either. → Pipeline step 12, Gotcha 1
8. **A correction fixes the step that was skipped in the owning skill:** the change lands in that skill's folder, and 0 lines go into a hook, a memory file or CLAUDE.md. Why: an answer he gives once must change the step that runs next time, and only the skill is loaded every time. → Pipeline step 4b, `references/skill-framework.md` Rules
9. **A rule a script can check lives in a script under `scripts/` (`lint-skills.py`, or a check script a Check row runs),** and the skill runs the script instead of describing the check; a script that writes a database, pushes or deploys is never written, that step stays his. Why: a law a script enforces beats a law written in prose (Chan's assemble.mjs, `references/skill-framework.md` Rules); the lint W16 check found the same 6 reference files that `references/writing-standard.md` A4 had listed by hand, plus skill-framework.md, which the hand list missed. → `scripts/lint-skills.py`, Checks 4a to 4c
10. **A skill is shown only after lint prints `ok`, the router prints it on its should rows, and its trigger score is 90% or more.** Why: a skill that does not load, or loads and is not followed, has the cost of a skill and none of the effect. → `references/frontmatter-and-router.md`

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "This rule matters, I will add a hook for it" | Law 8 broken. Write it as a step in the owning skill. |
| "The trigger test passed, so the skill works" | Pipeline step 10 skipped. Triggering proves loading, never following: run the behaviour scenarios. |
| "The skill is folded, its trigger phrases can go" | Gotcha 1. Move every phrase into the surviving skill. |
| "The folder moved, the paths still resolve" | Gotcha 2. Lint W15 lists every dead backticked absolute path; `ls` the rest (Check 3). |
| "T-I-P-O is the shape; red flags are troubleshooting rows" | Law 1 broken. The 14 sections are the shape. |
| "I'll paste what he said so nothing is lost" | Law 2 broken. Write the instruction his words ask for. |
| "He means roughly this, I'll word it better" | Intent reinterpreted. Keep his ask and his domain nouns exact; only the form changes. |

## Intake

Have these from files, never from memory:
1. His feedback for this change, read from the conversation: what was wrong, what he wants done instead.
2. The owning skill: `grep -n "^### " /home/visiond/projects/claude/skills/SKILLS.md`.
3. The skill's files, read whole: SKILL.md, references/, scripts/, examples/; and its audit row if one exists. Copy SKILL.md to `<scratch>/SKILL-intake.md` (Check 4c reads it).
4. Who runs it: `/home/visiond/projects/claude/skills/global/orchestration/references/skill-map.md`.
5. The doc the skill covers, path and section (Check 6 reads it).

Fixed: his intent, the 14 sections, W1 to W19, the layout. Free: wording, file split, trigger phrases from his messages.

## Pipeline

Serves the dispatched work between orchestration row D5 (dispatch) and row Dc (control) when a ticket's work is a skill. One ticket = one skill.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Find the owner; none = create `<scope>/<name>/SKILL.md`, symlink it, add its skill-map row | `ls -la ~/.claude/skills/<name>` resolves | `references/frontmatter-and-router.md` |
| 2 | Turn his feedback into the instruction it implies: one line per item, saying what the work does differently, written in the report | the item list, each with the step it lands in | law 2 |
| 3 | Evals first. A new skill or a rewrite (major bump): 10 to 20 trigger rows and 3 or more behaviour scenarios with a RED from a gotcha. A correction: 2 should rows and 1 near miss row; a project skill's rows carry `"cwd"` set to its root | rows in `references/trigger-queries.json`; Evals section | `references/behaviour-evals.md` |
| 4 | Write SKILL.md in the 14 sections from the template; bump `metadata.version` (major for a rewrite) | SKILL.md, then step 6: `python3 scripts/lint-skills.py` prints `ok   <name>` | `references/skill-framework.md` |
| 4b | A correction: one line in the skipped step, added only when `grep -n '<its key word>' SKILL.md` shows no step already saying it; the line names 0 tickets, files of the incident, sessions or dates | the line, and the grep output | law 8 |
| 5 | Wording pass, line by line W1 to W19; a missing number is listed, never invented | "needs a number" list in the report | `references/writing-standard.md` |
| 6 | Lint all skills with `python3 scripts/lint-skills.py` (no folder argument): collisions are counted only across the folders linted, so a phrase taken from a sibling fires only in a full run | `python3 scripts/lint-skills.py` prints `ok   <name>` and no FAIL line naming it | law 9 |
| 7 | Text check every file written | `check-text.sh <file>` exits 0 | writing |
| 8 | Router on every new row | should rows print the skill, near miss rows do not | `references/frontmatter-and-router.md` |
| 9 | Trigger test the rows | 90% or more, row in `references/trigger-results.md` | `scripts/trigger-test.py` |
| 10 | Behaviour scenarios after a major bump | row in the results table of `references/behaviour-evals.md` | `references/behaviour-evals.md` When to run |
| 11 | Regenerate the catalogue | `python3 scripts/catalog.py` prints `.../SKILLS.md: <n> skills`; `scripts/check-entry.sh <name> <scratch>` prints `entry: ok` | `scripts/catalog.py` |
| 12 | Fold or delete, on his yes: move every `metadata.triggers` phrase into the survivor; set `"skill"` to the survivor on its rows in `references/trigger-queries.json`; point every line naming it at the survivor; add the name to `RETIRED` in `scripts/lint-skills.py`; `rm ~/.claude/skills/<name>`; `rm -r /home/visiond/projects/claude/skills/<scope>/<name>`; router on the moved rows | `python3 scripts/lint-skills.py` prints 0 W15 lines naming it; the router prints the survivor on every moved should row | law 7, Gotcha 1 |

Do not skip 2, 6, 8 or, after a fold, 12. `check-text.sh` is `/home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh`.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| 1. Router misses rows after a skill is folded | The folded skill's trigger phrases were not moved | Move every phrase into the survivor; router on its rows | wave 1 critic: rows 163 and 164 missed after the test-order skill was folded into testing-standard |
| 2. Paths dead after the layout move | Absolute paths kept the old `skills/global/` folder | Lint W15; fix each path | wave 1 critic: check-text.sh path dead in 3 skills |
| 3. 52 files name a deleted skill | A skill deleted with its pointers left | Lint W15 (`RETIRED` in `scripts/lint-skills.py`); point at the survivor | `references/writing-standard.md` B9 (52 when B9 was measured); `grep -rlwE 'dev[-]flow' /home/visiond/projects/claude/skills \| wc -l` prints 49 |
| 4. This skill taught T-I-P-O against the framework | The framework changed, the owning skill did not | Rewrite here first | audit `global.md` row skill-craft |
| 5. Six reference files over 100 lines with no contents list | No check for W16 | Lint W16; add `## Contents` | `references/writing-standard.md` A4 |
| 6. `frontmatter YAML` lint error | An unquoted `: ` in the description | Rephrase with a comma | claude-skills v3 Troubleshooting |
| 7. Trigger rows fail although the router prints the skill | session-start used every tool call under a 5 call cap | Cap 12 in `scripts/trigger-test.py` | `references/trigger-results.md`: 24/35 at 5, 5 more passed at 12 |
| 8. A skill loses its rows to a memory | A project memory pulled the session first | Move the memory into the skill | `references/trigger-results.md`: motion-video 2/3 before, 1/3 after |
| 9. A project skill fires in another project | `metadata.root` missing or wrong | Set it to the repo folder; name the project first in the description | claude-skills v3 Troubleshooting |
| 10. A skill never triggers | Symlink missing, phrase not in `metadata.triggers`, or a sibling's phrase overlaps | In this order: `ls -la ~/.claude/skills/<name>`, the router output, then his literal phrase in triggers and the other skill named in each skill's Do NOT line; pass = the row passes on a `scripts/trigger-test.py references/trigger-queries.json --skill <name>` rerun | claude-skills v3 Troubleshooting |
| 11. The router prints the skill, the session ignores it | The description's first sentence does not say when, or a superpowers process skill fired first | Rewrite the first sentence to name the job and his phrase; pass = the row passes on a `scripts/trigger-test.py references/trigger-queries.json --skill <name>` rerun; a superpowers skill firing too is fine when ours also runs | claude-skills v3 Troubleshooting; `references/trigger-results.md`: 6 rows the router got right and the session answered instead; skill-craft 11/15, then 14/15 and 15/15 once the first sentence said it is invoked before the material is opened |

## Deliverables

- `<scope>/<name>/SKILL.md`, plus any references, scripts and examples it links.
- The symlink `~/.claude/skills/<name>`.
- 10 to 20 rows for a new skill or rewrite, 2 should and 1 near miss for a correction, in `references/trigger-queries.json`; a score row in `references/trigger-results.md`.
- After a major bump: a results row in `references/behaviour-evals.md`.
- `/home/visiond/projects/claude/skills/SKILLS.md` regenerated; a skill-map row for a new skill.

## Check it before you show it

| # | Check | Pass | A FAIL goes back to |
|---|---|---|---|
| 1 | `python3 scripts/lint-skills.py` (all skills, so collisions fire) | `ok   <name>`, no WARN, no FAIL line naming it | step 4, then 6 |
| 2 | `check-text.sh <file>` on every file written | exit 0 | step 5, then 7 |
| 3 | `ls <path>` on every repo-relative path the skill names (lint W15 checks only `/home/` and `~/`) | each prints the path | step 4 |
| 4a | `python3 scripts/lint-skills.py <skill folder> \| grep -c '\[quote\]'` | `0`; each hit names a pasted quote or a prompts file | step 2 |
| 4b | `scripts/check-entry.sh <name> <scratch>` (a fresh catalogue in the scratch folder, its entry diffed with the live SKILLS.md) | `entry: ok`; a stale version or a changed entry prints `FAIL` and the diff | step 11 |
| 4c | `scripts/bump-check.sh <scratch>/SKILL-intake.md SKILL.md` | `bumped`, or `same` when nothing changed; `FAIL: body changed, version not bumped` stops | step 4 |
| 5 | Router on every row; the trigger test shows `got=[...]` per row | router: the skill on every should row and 0 near miss rows; trigger test: 90% or more, and no skill other than session-start and this one in `got=` on a should row | step 4 (triggers, Do NOT line), then 8 |
| 6 | Each doc the skill points at, read beside the skill | the doc section says what the skill says, quoted in the report | step 4 |

Order: 1 to 5 (with 4a to 4c) are scripts and run first; 6 needs a model read and runs last: cheap before expensive.
After a fix, check again from 1.

## Critic loop

A separate read-only agent, never the writer, gets his feedback, the old skill from the backup and the new files.
Default reject. Axes 1 to 10: shape, his intent (every item of his feedback is a step), checkable laws, no process, nothing lost, wording (W1 to W19).
It lists the 3 worst problems with file:line and the smallest fix each. Repeat until every axis is 8 or more:
shape, checkable laws, no process and nothing lost back to step 4, his intent to step 2, wording to step 5. → `/home/visiond/projects/claude/skills/global/orchestration/references/critic.md`

## Definition of done

- [ ] Every item of his feedback is an instruction in the step it corrects; Check 4a prints `0`.
- [ ] `python3 scripts/lint-skills.py` (all skills) prints `ok   <name>`, run before you call the skill done.
- [ ] 14 sections in order, 80 to 200 lines; Check 4b prints `entry: ok`; Check 4c prints `bumped`.
- [ ] No approval gate, cast, own report or own test order; no project row in a global.
- [ ] Every fact of the old skill is in the new folder or its named new home.
- [ ] `check-text.sh` exits 0 on every file written.
- [ ] Router and trigger rows pass (should printed, near miss not; 90% or more); after a major bump, a behaviour results row.
- [ ] Critic: every axis 8 or more.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/skill-framework.md` the 14 sections, the rules, W1 to W19 and the empty template. Read first.
- `references/writing-standard.md` the evidence for W1 to W19 and the 60 Howseen number-for-word swaps.
- `references/frontmatter-and-router.md` layout, description shape with a filled example, metadata, router, trigger test, hooks, canon.
- `references/trigger-queries.json` the shared trigger rows; `references/trigger-results.md` the scores.
- `references/behaviour-evals.md` how to run a behaviour scenario and the results tables.
- `references/sources.md` the guides this set follows.
- `scripts/lint-skills.py` (`pip install pyyaml`): hard checks always FAIL; framework checks WARN under `--sections-warn` (the default until the reset is done); `--counts` prints the tally per check.
- `scripts/trigger-test.py` (needs the `claude` CLI), `scripts/catalog.py` (`pip install pyyaml`).
- `scripts/check-entry.sh`, `scripts/bump-check.sh`: Checks 4b and 4c.
- Skills: orchestration, writing.

## Evals

Trigger rows: the skill-craft rows in `references/trigger-queries.json` (should and near miss).
Behaviour scenarios, run and scored in `references/behaviour-evals.md` section skill-craft:

| # | Scenario | RED baseline | GREEN |
|---|---|---|---|
| C1 | "add this to the skill: ..." correction | 95 lessons written as memory files (backup in the private workspace) | 3/3, 2/3, 3/3 with; 2/3 in each of 3 without (assertion 1 reworded, the 4.0.4 loaded runs rescored, claude-sonnet-5-5) |
| C2 | Fold one skill into another | Gotcha 1: rows 163 and 164 missed | 3/3 in each of 3 with; 1/3 in each of 3 without (skill loaded, shared folder, claude-sonnet-5-5) |
| C3 | Rewrite a skill in the framework | Gotcha 4: T-I-P-O with no laws or deliverables | 2/3, 3/3, 0/3 with; 0/3 in each of 3 without (4.0.9 loaded, shared and research folders, claude-sonnet-5-5; assertion 3 fails as written: all 3 plan lint `ok` but none names the script) |
