# Best practices

How to use the skills and the harness well, as the files set it. Every rule names its source: a line of
[`harness/protocol.txt`](../harness/protocol.txt), a rule of [`harness/CLAUDE.md`](../harness/CLAUDE.md), or a law,
step or section of a SKILL.md or reference. When a source and this page disagree, the source wins; fix this page.

Short forms: `orch` = [`skills/global/orchestration/SKILL.md`](../skills/global/orchestration/SKILL.md), `refs/` =
its `references/` folder.

## Contents

- [Open the session](#open-the-session)
- [SKILL CHECK on every task](#skill-check-on-every-task)
- [Run every change through orchestration](#run-every-change-through-orchestration)
- [Briefs and critic loops](#briefs-and-critic-loops)
- [Control every report](#control-every-report)
- [QA in the browser](#qa-in-the-browser)
- [Reports](#reports)
- [Corrections go into the owning skill](#corrections-go-into-the-owning-skill)
- [Commits by path, in his voice](#commits-by-path-in-his-voice)
- [Nothing leaves the machine without his yes](#nothing-leaves-the-machine-without-his-yes)
- [Agents, load and the browser](#agents-load-and-the-browser)
- [Workspace files stay outside repos](#workspace-files-stay-outside-repos)
- [Writing rules that apply everywhere](#writing-rules-that-apply-everywhere)

## Open the session

- Run skill session-start on the first message, before anything else. Source: CLAUDE.md rule 1.
- The first reply holds the summary and the answer to his request; the greeting is never on line 1. Source: session-start laws 1 and 7.
- The project comes from `scripts/session-context.sh`, never a guess; the last session is never rebuilt from git log or a compaction summary. Source: session-start laws 2 and 3.
- After a compaction, the post-compact hook prints the protocol, the orchestration skill, the Score and the handoff tail; read the whole files next. Source: `harness/hooks/post-compact.py`; orch Gotchas row "After a compaction".

## SKILL CHECK on every task

- Before any work, ask which skill covers it. The router prints `SKILL CHECK:` with candidates; with none, read the name list at the top of `skills/SKILLS.md` (generated locally) and only the fitting section. Source: protocol.txt rule 0b (lines 6 to 9); CLAUDE.md rule 2.
- Invoke the skill and work by its steps; no skill fits means say so in one line and write one with skill-craft. Source: protocol.txt line 8 to 9.
- Development work always runs under orchestration; the other skills are complements a player runs. Source: protocol.txt rule 0 (lines 3 to 5); CLAUDE.md rule 0.
- Cast the players' skills from [`refs/skill-map.md`](../skills/global/orchestration/references/skill-map.md). Source: the router's orchestration line (`skill-router.py`, `line`); orch step 3.

## Run every change through orchestration

- Every request that changes code, data, docs or assets runs the pipeline, every step, in order. Source: orch law 1.
- Step 0: log his words verbatim in `PROMPT-LOG.md`; every ask joins the current batch after its last row, the approved order never changes. Source: orch step 0, laws 2 and 3; `scripts/law3-check.sh`.
- Step 1: read the docs, skills and code of the area into `understand.md`; name the doc in the reply ("Following <DOC>.md"). Source: orch step 1, law 17.
- Step 2: a spec and a plan before any build; then the goldfish lenses read them fresh, every finding resolved as FIX, CONTEST, ESCALATE or DECLINE. STOP for his yes on new work. Source: orch step 2, law 4; `refs/critic.md` Goldfish (lines 50 to 75).
- Step 3: count the rows and lanes; cast only the roles those rows need. While a frontend row is open, at most 1 backend player. Source: orch step 3, law 8b.
- Steps 4 and 5: brief, then critic on the brief (next section).
- Step 6: dispatch (Agents, below).
- Step 7: control every report (below).
- Step 8: integrate; run each seam between lanes against the architect's contract. Source: orch step 8.
- Step 9: QA in the browser (below).
- Step 10: critic on the result against his words. Step 11: every finding back to step 4 as a ticket until 0 FAIL rows and every axis 8 or more. Source: orch steps 10 and 11.
- Step 12: present on his dev server with the report; STOP, DONE is his. Source: orch step 12, law 14.
- Every step leaves a file; a step with no file did not happen. Source: orch law 13.
- One objective at a time, finished. Source: orch law 6.

## Briefs and critic loops

- A brief has every field filled: his words quoted, the reference file, inputs, files owned, skills (engineering-standards, testing-standard plus the cast's), the test mode, and the check as a command with its expected output or a number with a threshold. Source: orch step 4; `refs/agent-dispatch-brief-template.md`.
- House rules ride in every brief: dashes and wording, commit voice, never push, Claude files only in the workspace, no Agent tool. Source: `refs/agent-dispatch.md` laws 7 and 8.
- The critic is a separate read-only agent. It gets his words, the brief and the artifact, never the builder's report, and starts from reject. Source: `refs/critic.md` lines 3 to 14; orch Critic loop.
- Each axis is scored 1 to 10; any axis at 7 or less is a fix; repeat until every axis is 8 or more; an item at 9 or more is not touched again. Source: `refs/critic.md` The loop (lines 42 to 48).
- A skill as the artifact is scored against W1 to W19 and the Howseen model. Source: orch Critic loop; `refs/critic.md` lines 27 to 40.

## Control every report

- A report is a claim until `control.md` gives each requirement a verdict against his words and the docs, and the diff against engineering-standards and testing-standard. Source: orch Stance, step 7, law 7.
- Reject anything not asked, contradicting the docs, or below standard. Source: orch law 5, step 7.
- On a repo with an expert skill, a row passes control only when the expert's references cover the commit and its coverage script prints 0 missing. Source: orch step 7; a project expert skill's Pipeline row R.
- Builders never verify themselves. Source: orch law 10.
- A player on a wrong workflow is stopped now and re-briefed. Source: orch law 12.

## QA in the browser

- QA uses the real app on his dev server and leaves `qa/before-<n>.png`, `qa/after-<n>.png` and `qa.md`; a critic pass or a green suite is only input. Source: orch law 9, step 9.
- `qa.md` has one row per sentence of his per view the change ships in, each citing a numbered after shot at 1920x1080; show him only when every row is PASS. Source: orch Check it before you show it.
- A row is BUILT only when `scripts/built-check.sh <workspace> <ticket>` prints `BUILT`. Source: orch Pipeline, the BUILT check.
- No player starts a dev server; the running app is his. Source: `refs/agent-dispatch.md` law 9; orch law 11b.

## Reports

- Report only at a checkpoint: a standup of 3 to 6 lines while work goes on, a full report from `## What changed` to `## Following` when work stops. The Stop hook checks part of the shape. Source: orch law 18; `refs/work-report.md` laws 1 to 3; `harness/report-format.md`.
- A question is a card the turn it comes up (What it is, Why it matters, Options, My recommendation), asked once ever. Source: `refs/work-report.md` laws 4 and 6; orch law 11a.
- Tickets are written "number: plain name", in his approved order. Source: `refs/work-report.md` laws 8 and 11.

## Corrections go into the owning skill

- A correction fixes the step that was skipped in the owning skill, in plain generic words, with no story and no date; never into a memory file, a new hook or CLAUDE.md. Source: CLAUDE.md rule 3; skill-craft law 8.
- Run it through skill-craft: his feedback turned into the instruction it implies, 2 should rows and 1 near miss row, one line in the skipped step only when no step already says it, lint, router, trigger test. Source: skill-craft Pipeline steps 2 to 9, 4b.
- His answer to a question goes into the owning skill the same turn. Source: `refs/work-report.md` law 7.
- An instruction for the current work only goes in that work's score or brief, not a skill. Source: skill-craft When not to use.

## Commits by path, in his voice

- Local commits on the working branch are free: by path, his voice, no Co-Authored-By, no Claude mention. Source: protocol.txt rule 3 (line 13); ship laws 1 and 4.
- Agents commit their own paths on the working branch and never push. Source: `refs/agent-dispatch.md` law 2.
- Check the branch before every commit; feature branches by default. Source: ship law 5; ship Gotchas row "Commit landed on staging".
- `scripts/check-commit-msg.sh` checks a message against his voice rules. Source: ship scripts.

## Nothing leaves the machine without his yes

- Push, merge to master or staging, publish (Artifacts included) and deploy wait for his yes; a standing permission in ship counts only for the case it names. Source: protocol.txt rule 3 (lines 13 to 17); orch law 14; ship law 1.
- The full gate runs on the exact tree before any push; the push gate hook blocks a push without the stamp `pre-deploy.sh` writes. Source: ship law 2; `push-gate.sh`.
- Production only on his word, after staging. Source: ship law 3.
- Migrations, data migrations and seeds run on staging or production only when he asks; locally they just run. Source: protocol.txt lines 16 to 17; orch law 11b.
- Infrastructure applies, pushes and syncs need his yes in that message. Source: infra-gitops law 2.

## Agents, load and the browser

- One main checkout, one test database: `git worktree list` prints 1 line; parallel builders own disjoint files. Source: orch law 15; `refs/agent-dispatch.md` law 1.
- Run `scripts/agent-load.sh` before a launch and launch at most the number it prints. Source: `refs/agent-dispatch.md` law 3.
- TaskStop every agent the moment its report lands; no duplicate agents; agents never spawn agents. Source: `refs/agent-dispatch.md` laws 4, 6 and 7.
- One browser at a time, single test files, close what you start. Source: `refs/agent-dispatch-brief-template.md` line 25; a project expert skill's `references/testing.md`.

## Workspace files stay outside repos

- Plans, notes, handoffs and time entries live in `.claude-workspace/<project>/`, never in a repo or an auto-memory file. Source: protocol.txt rule 5 (lines 20 to 22); orch law 16.
- Real docs a teammate reads (README, `docs/`) go in the repo. Source: orch law 16; `refs/memory-and-handoff.md` law 2.
- No memory file is written. Source: `refs/memory-and-handoff.md` law 3.

## Writing rules that apply everywhere

- No em or en dashes, anywhere. Source: protocol.txt rule 4 (line 18); writing law 1; checked by `writing/scripts/check-text.sh` and the Stop hook.
- Answer first, plain words. Source: protocol.txt rule 2; writing law 3.
- All code in his repos is ours: say what state it is in and what is being done. Source: protocol.txt lines 18 to 19; writing law 7; review law 4.
- Do what he asked as he worded it; a new request replaces the old design. Source: protocol.txt rule 1 (lines 10 to 11); orch law 2.
