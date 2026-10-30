# skill-craft

| | |
|---|---|
| Type | process |
| Scope | global (every repo) |
| Source | [`skills/global/skill-craft/SKILL.md`](../../../skills/global/skill-craft/SKILL.md), version 4.0.12 |
| Run by | the director |

## What it is for

Writes, changes, audits and lists the skills under `skills/`, so every recurring job has one skill that the
router prints on his words, that a critic can fail line by line, and that serves a step of orchestration
(SKILL.md lines 13 to 16). It is also where every correction of his goes (CLAUDE.md rule 3).

## When to use it, and when not

Use it when a skill is created, changed, folded, deleted or audited; when he corrects how a job was done;
when a skill did not trigger or the wrong one did (lines 18 to 22).

Do not use it to do the job a skill describes, for a handoff note (orchestration), or for an instruction that
holds for the current work only, which goes in that work's score or brief (lines 24 to 28).

## Who runs it and its place in orchestration

The director. When the ticket's work is a skill, the orchestration critic scores it against W1 to W19 of
`references/skill-framework.md` and the Howseen model in
[`standards/howseen/motion-design-SKILL.md`](../../../standards/howseen/motion-design-SKILL.md)
(orchestration Critic loop).

## Pipeline, short (lines 79 to 93)

1. Find the owner, or create `<scope>/<name>/SKILL.md`, symlink it, add its skill-map row.
2. His feedback turned into the instruction it implies, one line per item, each placed in the step it corrects.
3. Evals first: trigger rows and behaviour scenarios (for a correction, 2 should rows and 1 near miss).
4. Write SKILL.md in the 14 sections; bump `metadata.version`. 4b: a correction is one line in the skipped step, only when no step already says it.
5. Wording pass W1 to W19.
6. Lint all skills with `python3 scripts/lint-skills.py`, no folder argument.
7. `check-text.sh` on every file written. 8. Router on every new row. 9. Trigger test, 90% or more.
10. Behaviour scenarios after a major bump. 11. Regenerate the catalogue with `scripts/catalog.py`.
12. Fold or delete only on his yes, moving every trigger phrase into the survivor.

## Scripts

- `scripts/lint-skills.py`: the framework lint (sections, length, W rules, dead paths, trigger collisions).
- `scripts/trigger-test.py`: runs the trigger rows of `references/trigger-queries.json`.
- `scripts/catalog.py`: writes `skills/SKILLS.md` (generated locally, not committed).
- `scripts/check-entry.sh`, `scripts/bump-check.sh`: the catalogue entry and the version bump. The lint `quote` check fails a skill holding a pasted quote of his or a prompts file.

## Key laws (lines 40 to 49)

1. Every SKILL.md has the 14 framework sections in order and 80 to 200 lines.
2. Feedback is turned into a descriptive instruction in the step it corrects, never pasted as a quote.
3. Every line passes W1 to W19.
4. Orchestration is the only workflow.
5. `global/<name>` when it applies in every repo, `specific/<project>/<name>` when it holds one repo's facts.
6. A project skill holds only facts. 7. One owner per job.
8. A correction fixes the step that was skipped in the owning skill.
9. A rule a script can check lives in a script under `scripts/`.
10. A skill is shown only after lint prints `ok`, the router prints it on its rows, and its trigger score is 90% or more.

## Handoffs

- From any skill: a correction of his lands here, then in the owning skill's step.
- To the router: `metadata.triggers`, `metadata.root` and `metadata.always` in the frontmatter are what [`harness/hooks/skill-router.py`](../../../harness/hooks/skill-router.py) reads.

## Best practices, from its Gotchas (lines 97 to 111)

- When folding a skill, move every trigger phrase into the survivor and rerun the router on its rows.
- A frontmatter YAML error is usually an unquoted `: ` in the description; rephrase with a comma.
- A project skill firing in another project means `metadata.root` is missing or wrong.
- A skill that never triggers: check the symlink, then the router output, then his literal phrase.
- The router prints it but the session ignores it: the description's first sentence must name the job and his phrase.
- A memory file can steal a skill's rows; move the memory into the skill.

## Red flags (lines 53 to 62)

"I will add a hook for this rule", "The trigger test passed, so the skill works", "The skill is folded, its
trigger phrases can go", "He means roughly this, I'll word it better".

## Evals

Trigger rows in [`references/trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json),
results in `references/trigger-results.md`; scenarios C1 to C3 in
[`references/behaviour-evals.md`](../../../skills/global/skill-craft/references/behaviour-evals.md) (Evals, lines 172 to 181).
