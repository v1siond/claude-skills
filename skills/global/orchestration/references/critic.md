# Critic

A separate general-purpose agent, read-only by brief and writing only its verdict file, scores an artifact against its brief before the next expensive step. It catches what
the builder cannot see in its own work. The skill that makes an artifact may add its own axes (motion-video
`references/critic.md` for films); the loop rules here hold for all of them.

## What the critic gets

- His words, the brief (or the record and the briefs) and the artifact itself.
- Never the builder's report or the director's reasoning: the critic judges what is there.

## Default

Reject. The artifact earns each score from what the critic can point at.

## Axes per artifact (each scored 1 to 10)

| Artifact | Axes |
|---|---|
| an understand.md, read by the row D4c critic with the brief (every ticket, small ones included; `understand-method.md`) | Problem (the `Problem:` line is the base in its context, not a symptom, a fix tried or a file to patch); Split (a `## Static and dynamic` table, rows S1 on, each with static or dynamic, its owner today at file:line and after; a dynamic fact with no row for its static part fails; a STATIC row whose owner after carries a placement key fails unless resolved from his words); Cause (the `Cause:` line names the S row whose copy or owner is wrong); Rules (the spec's or brief's `## Rules` is the smallest set his words need, each R line quoting him; a rule his words do not need fails); Debt (`Debt: none`, or each debt naming the later row and its context); Decisions (each DECISION on data cites its S row; a STOP card question on a STATIC row fails) |
| the director's work, row D4c (before dispatch) | Words (every requirement and brief line quotes him, his nouns kept); Objective (1 Waves line marked running, this ticket on it, the approved order kept, no other ticket has a player); Scope (`scope.md` has Build, Not build, Reuse with file:line and Buy with a package or the query that found none; a UI control or a common feature with no library searched fails); Contract (`contract.md` exists, older than every brief, and every brief's `Contract:` line names it); Brief (every field filled; the check a command with its output or a number with a threshold); Skills (each prompt's `Skills you run:` line equals the skill map's role row, work rows and project overlay: a screen holds ui, engineering-standards and the repo expert); Cast (only the roles the ticket needs; a QA and a reviewer named for row V; live players at most the `agents now:` number `scripts/agent-load.sh` printed); Decisions (every DECISION since the last check matches his words, and 0 questions to him that a `grep` of his words answers, law 11a) |
| the director's work, row D7 (before his look) | Control (control.md has a verdict per requirement, and `skills-check.sh` printed `skills: ok` for every lane); Verify (qa.md and review.md on the same sha, both after control); Routing (every FAIL row of qa.md and every finding of review.md is a row of subtickets.md with its lane, or a line quoting why it is not his ask; 0 sent back without one; 0 build rounds driven by a finding absent from his words before the checkpoint); Integrate (integrate.md on the final sha, newer than the last commit, gates per the test mode); Report (numbers, not prose; `references/work-report.md` shape; every question one the record does not already answer, law 11a); Score (this row's status and every row the Log touched since D4c carry the status the Log shows, in his status words); Hands off (0 code, script or tool file written by the director, the transcript's Write and `cat >` calls checked) |
| a doc | The answer is in the first lines; A fresh reader states its point in one sentence from the doc alone; Every claim has its source |
| a skill | Each of W1 to W19 in `skill-framework.md` passes (a fail names the W number and the line); The line shape matches the Howseen model (a number with a unit, a command or a named thing where a quality word stood); Every law has a `Why:` sentence on what goes wrong without it, and 0 italic quotes of his and 0 prompts files (skill-framework rule "Feedback becomes an instruction, never a quote"); Every gotcha has its observed proof |
| a film | motion-video `references/critic.md` |

## When the artifact is a skill

He set the Howseen motion-design SKILL.md as the standard the director and the critic hold every skill to, in its format and in
how its instructions are worded, how specific each is for its context, and when a line uses math
and when plain language, so a model reads it with the least room to guess.

So the critic reads both, whole, before scoring any skill:
- `/home/visiond/projects/claude/skills/global/skill-craft/references/skill-framework.md`, tests W1 to W19.
- `/home/visiond/projects/claude/standards/howseen/motion-design-SKILL.md`, the model of the line shape.

Each failing W test is reported as: W number, file:line, the line, the rewrite. A skill with 1 or more
failing W tests scores 7 or less on that axis.

## The loop

- Any axis at 7 or less is a fix; any honesty failure (a claim with nothing behind it) is a stop.
- Report per item: the scores, and for each low score what, where and the smallest fix; then one overall verdict,
  the file's last `Verdict:` line (built-check.sh reads only that line):
  ship = every axis 8 or more; fix = any axis 7 or less; rethink = an honesty failure (the stop above).
- Fix and score again until every axis is 8 or more. An item at 9 or more is not touched in the next round.
- The final call is his.

## The director

The director's work is the part of the pipeline that failed most, and nothing checked it until this section.
The critic's one job inside the pipeline is the director: SKILL.md rows D4c and D7, the two `the director's work` rows of the axes table. Builders are verified by QA and the reviewer at row V, never by a critic (SKILL.md law 10).
- **Who.** A fresh `goldfish-critic` agent, read-only. Brief: paths only: his words in `PROMPT-LOG.md`, `references/diagram.png`, SKILL.md Pipeline, ORCHESTRA.md (Score, Waves, Cast, Log), the ticket folder, and at D7 the lanes' transcripts' `skills-check.sh` outputs.
- **Writes.** The director pastes its reply into `score/<ticket>/director-critic.md` under `## Before dispatch` (D4c) or `## Before his look` (D7), each ending in its `Verdict:` line.
- **Loop.** An axis at 7 or less: the director redoes the row it names (D2 scope, A contract, D4 brief, F routing), then the same lens runs once more, fresh. Still open after that: a line on his STOP card, never a third round.

## Goldfish on the spec and plan (end of row D3, before his STOP)

He approved this design from the elephant and goldfish research. Source: the elephant and goldfish research notes, `$CLAUDE_WORKSPACE/<project>/research/2026-10-27-elephant-goldfish/analysis.md` (private workspace).

The director, loaded with the project's experts, is the elephant: he holds the context and writes the spec and `plan.md`. The goldfish are fresh agents that know only the files in their brief.

- **Who.** The agent types in `/home/visiond/projects/claude/agents/goldfish-<lens>.md`, linked into `~/.claude/agents/`: tools Read, Grep and Glob, `omitClaudeMd: true`. When `subagent_type: goldfish-<lens>` prints "not found" (the types load at session start), spawn general-purpose with the lens file's body as the whole brief, plus "read only, edit nothing".
- **The brief is paths only, never URLs.** Comprehension never gets his words, which is the test; the other lenses do.
- **Lenses and what each reads:**

| Lens | Reads | When |
|---|---|---|
| comprehension | the spec only | every spec |
| critic (with zoom out) | the spec, `plan.md`, `score/<ticket>/understand.md`, his words, the docs they name | every spec |
| codebase | `plan.md`, the repo, the project expert's SKILL.md | every plan |
| readiness | `plan.md` | every plan |
| concept | the spec, the concept art folder, the concept designer's SKILL.md; at row V on a built map also the style's tile names, the role table, the pairings, each map's saved cells and floor dump with heights, and its tones and slope outputs, each made by the command the project's concept designer skill names, dumped into `score/<ticket>/` | a game ticket a player sees or plays, at row D3 and at row V |

- **Size.** A ticket with no spec of its own (a bug fix the director sized as small at row D3) skips the goldfish; its brief still goes through the row D4c critic.
- **One message.** All lenses are sent in one message. Each reply is saved as `score/<ticket>/goldfish-<lens>.txt`.
- **Merge.** The director writes `score/<ticket>/goldfish.md`: every finding with lens, severity and file:line, duplicates merged into one row.
- **Resolve.** Each row of `goldfish.md` gets one verdict:
  - FIX: the spec or plan changes;
  - CONTEST: a file:line the goldfish could read shows it wrong (a wish to contest is not evidence; a comprehension gap is never contested, the doc is fixed);
  - ESCALATE: his decision, a line on his STOP card, only after the project's experts checked it (below);
  - DECLINE: a Nit only;
  - REJECT small rules first: a finding or spec task that only adds machinery his words do not need (no R or S row
    to cite) is cut and logged in ORCHESTRA.md Log (`understand-method.md` 2a).
  Context is never added only to satisfy a goldfish.
- **Experts before verdicts.** A goldfish reads files only and misses what the app already does. Before any row is resolved, every row that says the app cannot do something, needs new work, or asks for a design choice goes to the project's experts (a game repo: its expert skill for what the code does, its concept designer for the concept and its maps), who answer from the code and the concept with a file:line. A row they show the app already does is CONTEST; only what they cannot settle from the code, the docs or his words becomes ESCALATE. Why: questions a goldfish raised reached him that the experts could have settled from the code and the concept.
- **Loop.** After the fixes, each lens that had a Blocker or Major runs once more, fresh. What is still open after that goes on his STOP card as ESCALATE rows, never a third round.
- **Done.** 0 Blocker and 0 Major left, or each one CONTESTED or ESCALATED, before his STOP.
