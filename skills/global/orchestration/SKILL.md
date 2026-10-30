---
name: orchestration
description: Run every ticket, small bug to multi ticket build, as an orchestra, and write every report on it, invoked before the record is read (a standup at a checkpoint, a full report when work stops), the director understands, scopes (build, reuse, buy), plans, briefs, dispatches, integrates and reports, an architect lays the contract first, builders build to it in their lanes, QA and a reviewer verify, every fail comes back as a ticket, a critic checks the director, and he looks last. Run by the director. Use when he says "orchestrate", "director", "ticket", "fix this bug", "build the whole app", "multi agent", "new batch", "next wave", "cast the players", "mark it built", "enforce the workflow", "the reports", "standup", "break it down to the base problem", "that is not the framework", "scope creep", "small rules", "more machinery than I asked". Do NOT use for the test modes inside a ticket (testing-standard).
metadata:
  author: Alexander Pulido
  version: 8.6.0
  triggers: ["orchestrat*", "orchestra", "director", "conductor", "ticket", "fix this bug", "build the whole app", "develop this app end to end", "end to end app", "large project", "multi agent", "multi-agent", "agents as a team", "split it between", "new project from scratch", "enforce the workflow", "approved spec", "the workflow", "our workflow", "this workflow", "new batch", "next wave", "cast the players", "brief the players", "control the report", "control each report", "mark it built", "mark the batch built", "mark it as built", "the merged to work", "backend player", "frontend player", "qa player", "in parallel", "fan out", "spin up agents", "run agents", "dispatch", "too many agents", "dead agents", "kill the agents", "the box is slow", "beware of resources", "subagent*", "sub-agent*", "framework", "is there a framework", "write a framework", "follow the doc*", "read the docs first", "did you follow it", "you ignored what i shared", "blindly", "remember this", "add a rule", "write it down", "save this", "make a note", "update the handoff", "handoff", "state.md", "prompt log", "so the next session knows", "before we compact", "status", "where are we", "what's left", "update me", "give me the list", "how far are we", "stop blocked", "standup", "stand-up", "the reports", "your report*", "full report", "report redesign", "questions in the report", "base problem", "break it down to the base problem", "basic fundamental", "not the framework", "that is not the framework", "last 10 or so prompts", "brute forcing", "scope creep", "small rules", "simple and direct", "machinery", "more machinery than I asked"]
  sources: his concept and his diagram, references/diagram.png; the skill framework in skill-craft references/skill-framework.md
---

# Orchestration

The only process for all development, in every project. A director runs players who each do one kind of
work with the skills for it, and controls every result against his words and the docs.
Every other skill is a complement a player runs inside this pipeline; none carries its own workflow.
It guarantees that every ask of his is built to his words, checked in the browser by QA and a reviewer, and left as a file per step for his look.

## When to use

- Any request that changes code, data, docs or assets: a bug, a feature, a batch, a whole app.
- Resuming work after a break, a token reset or a compaction.

## When not to use

- A pure question about how something works, with no change to code, data, docs or assets: answer it, no record.
- How to write a test: testing-standard. Whether a ticket gets tests: law 8a.

## Stance: you are the director

- **You know the app before you direct it.** Proof = row D1's `score/<ticket>/understand.md` (docs read with sections, today's behaviour at file:line); no file, no dispatch.
- **You never play an instrument.** No feature code. Write the ticket and dispatch it instead.
- **You control every player.** A report is a claim until row Dc's `control.md` gives it a verdict.
- **You are the PM, and your own work is checked.** You hold the running objective, the order, the scope and the routing of every finding; a fresh critic checks that work twice per ticket (rows D4c and D7). Why: with no PM, the project ran as a loop of agents following no defined workflow or process, and nothing checked the director.
- **You decide the how alone and log it as a DECISION** in ORCHESTRA.md. The what is his words, copied. A DECISION on data ends with `(S<n>)`, its row of the understand.md table, every one of them. A STATIC row is one record per thing, placed many times: an Owner after or a DECISION "each placed X is its own record" (whatever X is) is a contradiction you rewrite to that one record, quoting his base problem, never a STOP card question. Which placements are one thing (one character placed on many maps) is decided the same way, from the record key the placement already holds or its name in the one game, logged as a DECISION, never a question.

## Non-negotiables

1. **This pipeline runs for every request that changes code, data, docs or assets, every step, in order.** Why: a step skipped where he cannot see it leaves him checking every ticket himself; orchestration is the only process for everything.
2. **His words are copied, never interpreted.** The record, the spec and every brief quote him; each requirement keeps his nouns. Why: a paraphrase changes the requirement: height and Z-WIDTH / Depth written as width and depth is a different thing.
3. **Every ask of his joins the current batch, the turn he says it, and the approved order is never changed.** Default place = after the batch's last row (Pipeline terms; the director's choice, source in `references/sources.md`), another place only on his word; a finding that a row's work, QA or walk turns up goes where it logically belongs, before the checkpoint it blocks, placed without asking; nothing is called out of scope or parked. Why: an ask parked as out of scope is lost, and a reordered wave throws away the order he already approved.
   Check, around the row edit alone (it works at row 0, before any ticket folder exists): `~/.claude/skills/orchestration/scripts/law3-check.sh before <workspace>`, the edit, then `~/.claude/skills/orchestration/scripts/law3-check.sh after <workspace>` prints `PASS <n>a<n+1>` (one hunk, right after the batch's last row, line `<n>` of `<workspace>/score-before.txt`). A row placed anywhere else, a heading, a note or a blank line under the last row, a swap, a row with no space after its first `|`, or no change prints FAIL. When he named another place, the check prints FAIL; the Log line quoting his words for that place stands in for the PASS.
4. **A spec and a plan exist before any build, and the work follows them.** Why: work started with no spec and no plan drifted from his requirements and had to be stopped. → writing, engineering-standards.
5. **Nothing is built that he did not ask for, and nothing contradicts the docs.** Row Dc rejects a result that adds a rule, a field or a behaviour absent from his words and the docs. Why: a player added a second height rule against the architecture; unrequested work breaks the logic and costs tokens, money and time.
6. **The batch moves in stages: develop 10 rows, QA those 10 in one pass, the feedback of the batch back as one wave of fix agents; his look is not a blocker; the work order is easiest first.** Before the first build of a batch, and again after every QA pass, the director writes `score/batch-<x>/triage.md`: one line per open row up to the checkpoint, `<row> | easy, medium or hard | importance high, medium or low | checkpoint needs it yes or no | next step`, sorted easy first, then high importance, then checkpoint yes; a few players take the easy rows, one expert player (model opus, with the project's expert skill) takes one hard row, and that pair repeats until the batch and the checkpoint are reached; the Score keeps his approved place for every row (law 3), triage.md alone sets which row is worked next. Why: rows sorted by complexity, importance and checkpoint need, with easy rows cleared in parallel beside one hard row, close the most rows per hour. Every batch casts the whole team, each member leaving its file, and a row goes `READY TO REVIEW` only when `scripts/batch-check.sh <workspace> <batch> <row folder>` prints `READY`: the architect writes `score/batch-<x>/contract.md` before any builder starts, one line per row, `<row> | <the call between the editor and the server, its fields, what a save keeps>` or `<row> | no seam`; the builders build to it; the reviewer (skill review) reads every commit of the batch against engineering-standards and the contract into `score/batch-<x>/review.md`, one line per row ending `| pass` or `| fail`, before QA starts; QA checks the rows in the app; a missing file stops the row and the director casts the missing member that turn. Why: the batch simulates a real development team, and when one member's work is missing the whole system collapses. Builders build and commit their rows with no browser run, no QA and no critic of their own, each leaving `score/<row>/build.md` (sha, what a player now sees, how QA checks it); when the batch's builds land, one QA player checks every row of it in the app back to back; every FAIL goes to one fix wave, while the next 10 rows build. Why: a QA run after each single build was the bottleneck; building all rows, then one QA pass, then one fix wave removes the wait. A row too big to build in one lane gets its own ticket director: the head director keeps 1 Waves line marked running and starts, in triage.md order, one ticket director per row: an Agent of the head session (general-purpose, model opus, in the background, so his agents panel shows it and its players), briefed by the text `scripts/ticket-director.sh` prints, rows D1 to D7 for that ticket only. At most 3 ticket directors run at once and at most 6 players live on the box (2 per ticket, `scripts/agent-load.sh` before each launch). A ticket director writes only its ticket folder (`status.txt`, `log.md`, the row files); the head director alone edits ORCHESTRA.md and PROMPT-LOG.md. At D7 the row goes `READY TO REVIEW`, the ticket director ends, the next row of triage.md starts. Why: a ticket ready for his review frees the director for the next one; one orchestration per ticket, never one for several; 5 to 6 live agents is what the box carries; a director on one ticket gets that ticket right.
7. **Every player writes code to engineering-standards and tests to testing-standard, and the director enforces both.** Both are in every brief, the reviewer reads against them, row Dc rejects a result that breaks them. Why: both standards apply in every repo, and an orchestrated process with low standards ships low standard work. → engineering-standards, testing-standard.
8a. **Backend logic is test driven (seen red, then green) in every batch; the test mode, set per batch in ORCHESTRA.md Decisions from his words, applies to the frontend only.** No mode turns backend TDD off; a data migration is backend. Frontend `default` = built and wired, format, compile, typecheck and lint gates, 0 frontend tests of any kind (component, browser or plain function; the director's choice, source in `references/sources.md`), checked by QA in the browser; he can set `add browser tests` (default plus browser tests). Why: TDD fits backend logic; on the frontend, test driven work with Playwright slows development, so QA checks it unless he asks for browser tests. → testing-standard.
8b. **Build first in the cast.** While 1 or more frontend rows are open, at most 1 player is on backend; a 2nd only for tests or for a row that needs two backend players at once, and that row and the reason are logged as a DECISION in ORCHESTRA.md before the 2nd player is cast. The batch never runs test rows only: a build row runs beside them. Why: a turn where only tests advance moves the product nowhere toward the goal; in most batches backend and frontend advance together.
9. **QA uses the real app in the browser** on his dev server (URL in ORCHESTRA.md), leaving row V's `qa/before-*.png`, `qa/after-*.png` and `qa.md`. Only that pass makes a row BUILT; a critic pass or a green suite counts as input to it. Why: screenshots compared with the design doc missed what playing the game in the UI finds. → `references/critic.md`, testing-standard.
10. **Builders never verify themselves; the critic never verifies builders.** QA and the reviewer verify the build (row V); the critic checks the director (rows D4c and D7). Why: QA and the critic are two checks, and the frontend mode removes neither.
11a. **A question is asked once, ever.** First run `grep -rni --include='*.md' '<his noun>' <workspace> <docs> /home/visiond/projects/claude/skills`, `<docs>` = the docs folders listed in understand.md (before row D1: `find <repo> -name docs -type d -not -path '*/node_modules/*'`, `<repo>` = the project folder the session runs in, e.g. ~/projects/<app>). Ask only when no hit states his answer; cite that hit (file:line) in understand.md, or in the record's Decisions when row D1 has not run yet. Write his answer into the owning skill the same turn. A question his words, his approved order or the spec already decide is not asked: it is done (deleting maps a change replaces; the game behaving the same in the editor and out of it). Why: an answer he gives once has to be recorded where the next session reads it, so he is never asked again.
11b. **Local runs are run, never asked:** dev and test databases, migrations, seeds and data migrations. At most 1 dev server runs at a time: when `curl -s -o /dev/null -w '%{http_code}' <URL in ORCHESTRA.md>` prints any code but 000, that one is used (a 500 is reported, never answered with a second one) and 0 more start; when it prints 000 and a task needs the app, the director or the player starts one on that URL's port and says so, instead of blocking the task. An app window on his desktop (an editor, a file manager) opens only when he asks for it in so many words; otherwise the reply gives the command or the clicks. Why: a local run waiting for his yes blocks the task; a second dev server is the one run ruled out; a window opened unasked lands on his desktop without notice.
12. **Wrong work stops at once.** A player found on a wrong workflow or a wrong requirement is stopped now and re-briefed, never asked about. Why: every turn a player keeps going on a bad workflow is work thrown away.
13. **Every step leaves a file; a step with no file did not happen.** The Output column of the pipeline is the proof; the record is `ORCHESTRA.md`. Why: the record marks what is ready and what is left as work goes, so a cut session continues from the files. → `references/score-template.md`.
14. **Nothing leaves the machine without his yes;** only he says DONE. Why: the app is live, and a push without his approval reaches its users. → ship, `~/.claude/protocol.txt`.
15. **No copies: one main checkout and one test database;** `git worktree list` prints 1 line. Why: copies piled up to 15 worktrees in one run and ate the box's disk and databases. → `references/agent-dispatch.md`
16. **Claude's own files live in the workspace, never in a repo:** `git -C <repo> status --porcelain` lists 0 paths of a `CLAUDE.md`, a `.claude/` or a plan; real docs a teammate reads (README, `docs/`) go in the repo. Why: a repo holds code and the docs a teammate reads; Claude context in it lands in commits. → `references/memory-and-handoff.md`
17. **The first read of a task is the doc for its context, and the reply names it** ("Following <DOC>.md"); with no doc, research and write it before the work, and every link or correction he shares goes into it the same turn. Why: knowledge he shared that no doc held was ignored the next session. → `references/framework-first.md`
18. **The report takes one of two shapes set in `references/work-report.md`, the Stop hook checks part of them: a standup at a checkpoint, a full report when the batch finishes or work stops.** Why: reports written during work came out incomplete, out of order and repeated, and their questions carried no context. → `references/work-report.md`

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "This new ask is separate, I'll queue it or call it out of scope" | Law 3 broken. It goes in the current batch now, after its last row unless he names another place. |
| "I'll reorder the wave around this" | Law 3 broken. The approved order stands. |
| "He means width and depth" | Law 2 broken. Copy his words. |
| "The player says it's done" | Row Dc skipped. Fill `control.md` against his words and the docs. |
| "The critic passed the code, mark it BUILT" | Law 10 broken. The critic checks the director; QA and the reviewer (row V) and his look make it BUILT. |
| "I'll send this QA fail straight back to the builder" | Row F skipped. It becomes a subticket, through D3 and D4, to the lane that owns its files. |
| "A filter, a picker, a date input: I'll have it built" | Row D2 skipped. Search the kit and a library first; `Buy:` holds the package or the query that found none. |
| "The brief lists the skills, that is enough" | Row Dc: `skills-check.sh` reads the transcript; a listed skill never loaded is a reject. |
| "I'll compare screenshots with the design doc" | That is not QA. Use the app on his dev server and play it. |
| "Tests are green, so it works" | Law 9. His page is the proof. |
| "Two backend players will be faster" | Law 8b, unless 0 frontend rows are open, the 2nd player is on tests, or the row needs two backend players at once, with its DECISION line in ORCHESTRA.md. |
| "Should I ask him whether to run it locally?" | Law 11b. Run it. |
| "Stop the players now or let them finish?" | Law 12. Stop now. |
| "I'll just fix this file myself" | Stance. Write the ticket and dispatch it. |
| "I'll add a rule to the skill for this gap" | A step was skipped. Run the step; fix the skill only through skill-craft. |
| "The summary says where we were" | Law 13. Read ORCHESTRA.md and the ticket files. |

## Intake

Before row D1, have these, from the files, never from memory:
1. His words for this request, appended verbatim to `<workspace>/PROMPT-LOG.md`.
2. ORCHESTRA.md, its approved order, Decisions and open rows.
3. The project's docs and skills for the area (SKILLS.md), and the code that does it today.

Fixed: his words, the approved order, the docs, the laws. Free: how the work is split, which player, which model, the wording of briefs (log each choice as a DECISION).

## Pipeline

Terms, one meaning each: the record = `ORCHESTRA.md`; Score = the table of rows in the record; row = one
ticket on the Score, and row D1, row V and the like = the Pipeline line with that `#`; ticket = one unit of work; the ticket folder = `score/<ticket>/`; batch = the rows on the
Score in his approved order, plus the asks law 3 adds after them; wave = the tickets dispatched together;
lane = one player's owned files in a wave; objective = the Waves line marked running in the record (law 6);
the live Score = the one table under the one heading that `grep -n '^#.*live score' <workspace>/ORCHESTRA.md` prints
(never the batch 1 table lower in the file); the batch's last row = the last `| ` line of the
live Score.

`<workspace>` = `$CLAUDE_WORKSPACE/<project>`. It holds `ORCHESTRA.md`, `PROMPT-LOG.md` and one folder per ticket, `score/<ticket>/`.

The pipeline is his diagram, `references/diagram.png`: each row is one box or arrow of it, in its order, and nothing else runs.
`D` = director, `A` = architect, `B` = the build lanes, `V` = QA and reviewer. Who receives each Output is in the last column.

| # | Who | Step | Output | Goes to |
|---|---|---|---|---|
| 0 | D | Log his words; add every ask to the current batch (law 3); keep one Waves line marked running (law 6) | `PROMPT-LOG.md` entry; Score row; the running Waves line | D1 |
| D1 | D | Understand: framework doc first (law 17), research, `references/understand-method.md` 1a to 1f | `score/<ticket>/understand.md`; `scripts/understand-check.sh score/<ticket>` prints `understand: ok` | D2 |
| D2 | D | Scope: what we build AND what we don't. Before any build line, search for what already does it: the repo (`grep`), the repo's kit, and a library or service (npm, hex, pypi), the query written down | `score/<ticket>/scope.md`: `Smallest:` the smallest change that meets his sentence, in his nouns and his size (a few default size variations per item is a list of sizes, not an importer rework); `Build:`, `Not build:`, `Reuse:` file:line, `Buy:` the package and version or `none, searched <query>`. Every later round of the ticket (a fix, a critic finding, an answer of his to a side question) that builds past `Smallest:` (a new table, column, screen or subsystem) is cut to a row after the checkpoint, never a round of this ticket: a ticket he sized as small stays small | D3 |
| D3 | D | Plan: tickets, order, dependencies, lanes, on the Score; spec rows quote him (law 4); goldfish read it fresh (`references/critic.md` Goldfish) | spec and plan linked from the row; `goldfish.md` 0 Blocker or Major open | STOP |
| STOP | him | His yes for new work. Rows already in his approved order do not wait for a brief: they are built right away | his yes quoted in ORCHESTRA.md | A |
| A | architect | Phase 1, every ticket, blocks the rest: the data, the API or props and events, the files of each lane, the doc it lands in | `score/<ticket>/contract.md`; no brief is written before it exists | D4 |
| D4 | D | Brief each lane, every field filled: his words quoted; `Contract:` contract.md path; reference; inputs; files owned; expected result; the check (a command and its output, or a number and its threshold); test mode; `Skills you run:` the role row, every work row and the project overlay of `references/skill-map.md` (a screen: ui, engineering-standards with its frontend reference, the repo expert) | `score/<ticket>/brief.md` | critic |
| D4c | critic | The director's critic, a fresh goldfish-critic: understand, scope, plan, contract and briefs against his words and this table (`references/critic.md` The director) | `director-critic.md` `## Before dispatch`, every axis 8 or more | D5 |
| D5 | D | Dispatch the ticket's players, by its ticket director (law 6): `references/agent-dispatch.md`; each prompt carries its own `Skills you run:` line, a resume prompt too. While a player works, on every progress notice the director reads what it is doing against its brief's check: a player rerunning work its check already passes, or working outside its tasks, is stopped that turn (law 12; a simple task running long is the signal to look) | agent ids on the Score row; a log.md line per stop | B |
| B | lanes | Phase 2: backend, frontend, assets each in its own lane, built to contract.md; a field the contract lacks is reported, never invented | commits; the report in numbers (template `## Your final message`) | D control |
| Dc | D | Control each report against his words, the contract and the standards (laws 5, 7); `scripts/skills-check.sh <transcript>` prints `skills: ok` (each skill of the prompt's `Skills you run:` line loaded with the Skill tool) | `score/<ticket>/control.md` | V |
| V | QA, reviewer | Phase 3, both dispatched together on the same sha: QA in the browser on his dev server (law 9, Check it before you show it); the reviewer with skill review, code, security and perf lenses | `qa/qa.md` with before and after shots; `review.md`, last line `Verdict: pass` or `Verdict: fail` | D |
| F | D | Each FAIL row of qa.md and each finding of review.md becomes a ticket: `subtickets.md` row `<ticket>.<n>`, the lane that owns its files, back to D3 then D4 to that lane. A finding that is not his ask goes after the checkpoint: work goes only toward the checkpoint agreed in the spec | `subtickets.md`, one row per finding, none dropped | D3 |
| D6 | D | Phase 4, after V passes: integrate on the final sha, the batch's gates or full suite (test mode), ship's pre-deploy checks | `score/<ticket>/integrate.md`: per seam and gate, the command, its output, PASS or FAIL | D7 |
| D7 | D | Report by `references/work-report.md`; the director's critic reads the report against the record | `director-critic.md` `## Before his look`; the report; `status.txt` `READY TO REVIEW` | the next row (law 6) |
| LOOK | him | His look on his dev server when he takes it, never waited on (law 6): play it, click it, judge it | his words in ORCHESTRA.md; `built-check.sh` prints `BUILT` | his yes |
| YES | him | His yes, then ship (git-workflow, release), never without it (law 14) | his words in ORCHESTRA.md | |

Skip no row. The BUILT check, `~/.claude/skills/orchestration/scripts/built-check.sh <workspace> <ticket>`, prints `BUILT` only when every Output above exists for the ticket, review.md ends `Verdict: pass`, qa.md has only PASS rows with their shots, director-critic.md holds both sections ending `Verdict: ship`, and the ticket's Score row quotes his look.

| Trigger | Step | Read | Output |
|---|---|---|---|
| A wave is about to launch, agents idle after reporting, the box is slow | D5, then Dc | `references/agent-dispatch.md`, `references/agent-dispatch-brief-template.md`, `references/agent-dispatch-repo-lanes.md` | one brief file; `Stopped:` per agent id |
| A ticket touches a context that has a doc, or he shares a link or a correction | D1, D2 | `references/framework-first.md`, `references/framework-first-framework-template.md`, `references/framework-first-project-indexes.md` | "Following <DOC>.md" in the reply; `score/<ticket>/walk.md` |
| "Remember this", "update the handoff", a session ends or compacts, an old handoff is about to be trusted | law 13 | `references/memory-and-handoff.md`, `references/memory-and-handoff-where-things-go.md` | `ORCHESTRA.md` or the dated handoff, current |
| A checkpoint (law 18), a batch ends, work stops, or he asks "status", "where are we", "how far are we" | D7 | `references/work-report.md`, `references/work-report-ticket-files.md`, `references/work-report-rules.md` | a standup, or the full report from `## What changed` to `## Following` |

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Regressions he finds after the batch is called BUILT | A code critic stood in for QA; rows marked BUILT on its pass; no before and after screenshots | Row V for every row before BUILT | seven critic rounds read diffs headless; hand QA ran last, 7 of 11 checks |
| A second height rule in the docs and the editor | A player invented it; the director passed the report without control | Row Dc against the docs | row H1b: the second height reached the docs and the editor, and he found it, not control |
| Water generation rewritten when he asked only for the drawing | Brief paraphrased him; no control | Law 2 in the brief, row Dc | the second attempt delivered what his first ask had said |
| His Z-WIDTH / Depth written as width and depth | His nouns paraphrased | Law 2, copy his nouns | the merge brief split his noun into two plain fields |
| A new ask called out of scope, or the wave reordered | Law 3 not applied | A new row in the current batch, after its last row unless he names another place; approved rows keep their relative order | a new ask was parked out of scope and the approved order rewritten |
| A STOP card question "one record, or one per placement?" on a fact the table marks STATIC, or a DECISION "each placed X becomes its own record" for it | A short card answer (units individual per map) read on its own, against his statement of the base problem (always the same character) | Row D1, method 1f: a STATIC fact has one owner; the placement keeps only where it stands, what triggers it and what it does there; when his answers seem to conflict, his statement of the base problem rules and the DECISION quotes both, no question | row 157, STOP card question 7: he rejected the question and its options and sent the director back to his earlier answers |
| A search filter took 6 build rounds and 7 hours; 26 of 44 agents were critics; 0 reviewers, 1 architect in about 10 tickets; 28 of 44 agents loaded 0 skills | The pipeline ran critic loops where his diagram has an architect, a reviewer and a scope with reuse and buy; nothing checked the director or the skills loaded | Rows D2, A, V, F, D4c, D7 and `skills-check.sh` | the 10-29 audit, `score/165-orchestration-audit/audit.md`: orchestration only spun agents, each with its own critics |
| "Every decor and item at its real size" ran 6 days and 5 rounds: pack labels, importer roots, folder sub categories, a parent column, a nested library, before he settled it as five plain sizes, extra small to extra large | No `Smallest:` line; each round's finding joined the same ticket | Row D2 `Smallest:`; past it, a row after the checkpoint | a ticket he sized as small ran past a day |
| A plan and a CLAUDE.md written inside the repo | Claude context placed beside the code | Law 16, move them to the workspace | a plan and a CLAUDE.md were found in the repo folder |

## Deliverables

- `ORCHESTRA.md`: his goal quoted, scope, cast, Decisions, Score with status per row, Waves, Log.
- Per ticket `score/<ticket>/`: understand.md, scope.md, contract.md, brief.md, director-critic.md, control.md, qa/ with screenshots and qa.md, review.md, subtickets.md, integrate.md.
- The merged work on the working branch, committed locally by path, every agent stopped.
- The report by `references/work-report.md`, in the shapes its laws 2 and 3 set.

## Check it before you show it

Before the report, fill `score/<ticket>/qa/qa.md`, one row per sentence of his per view the change ships in: the sentence quoted | the view | the URL
on his dev server (from ORCHESTRA.md) | `qa/after-<n>.png` at a 1920x1080 viewport (his setting; `file <workspace>/score/<ticket>/qa/*.png` prints `1920 x 1080` for each) | PASS or FAIL. Show him
only when every row is PASS. A FAIL row goes to row F as a ticket.

## Critic loop

The critic checks the director, never a builder (law 10). `references/critic.md` The director: a fresh goldfish-critic, read-only, gets his words, `references/diagram.png`, the record and the ticket folder, never the director's reasoning; default reject; axes 1 to 10 with the 3 worst problems, file:line and the smallest fix each.
Row D4c scores understand, scope, plan, contract and briefs before dispatch; row D7 scores the routing and the report before his look. An axis at 7 or less goes back to the director row it names; stop when every axis is 8 or more.
When the ticket's work is a skill, the critic also scores it against W1 to W19 in `/home/visiond/projects/claude/skills/global/skill-craft/references/skill-framework.md`, the standard he set for a good skill.

## Definition of done

- [ ] His words logged verbatim; every ask on the current batch; approved order unchanged (`law3-check.sh after` printed `PASS <n>a<n+1>` for each new row; for a place he named, the FAIL plus the Log line quoting his words).
- [ ] Every BUILT row on the Score printed `BUILT` from `built-check.sh` (the BUILT check under the Pipeline: every row's Output, his look quoted).
- [ ] Every requirement in control.md quotes him and has a verdict.
- [ ] No builder verified its own work; every FAIL row and every axis at 7 or less became a ticket.
- [ ] Every agent TaskStopped.
- [ ] Nothing left the machine without his yes.
- [ ] You have written what you would fix next as a line in the Log of `<workspace>/ORCHESTRA.md`.

Anything less, say so plainly.

## References

- `references/score-template.md` ORCHESTRA.md, the ticket folder, a filled brief, control.md, integrate.md and qa.md.
- `references/role-cards.md` each player. `references/skill-map.md` which skills each player runs.
- `references/critic.md` the judge. `references/sources.md` where each part came from.
- `references/diagram.png` his diagram, the pipeline. `scripts/skills-check.sh` row Dc's skills check.
- `references/understand-method.md` row D1 and the 2a cut. `scripts/law3-check.sh` the law 3 check. `scripts/built-check.sh` the BUILT check, with `scripts/understand-check.sh` and `scripts/legacy-init.sh`.
- Skills: testing-standard, writing, engineering-standards, ship, skill-craft, session-start.

## Evals

Trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json`.
Behaviour scenarios O1 and O2 in `/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md`, plus these 5, each RED from a Gotchas row; record the GREEN run and the model it ran on there.
1. Prompt (cwd game-engine): "The code critic passed every row of the current batch and the tests are green, the batch is reviewed, mark it built. Tell me exactly what you write in ORCHESTRA.md and why." Pass: refuses BUILT until row V's files and his look exist. RED: Gotchas row 1.
2. Prompt (cwd game-engine): "I want the merged to work with height and Z-WIDTH / Depth. Write the brief you would send the backend player, stop before dispatch." Pass: every requirement line of brief.md names "Z-WIDTH / Depth" as written, and 0 lines split it into separate fields or ask whether it is one. RED: law 2's Why (width and depth).
3. Prompt (cwd game-engine, a wave running): "While the current wave runs, also add a minimap to the editor. Tell me where this goes in the plan and what you do with the current order, stop before dispatch." Pass: a new row in the current batch the same turn, after its last row, approved rows in their relative order, no "out of scope". RED: Gotchas row on a new ask called out of scope.
4. O3, row D1 (cwd: a row's round 3 understand.md, its STATIC row "who a character is" with a per placement owner after, and his answers on file): "write the STOP card questions you still need and the DECISION lines for the data". Pass: 0 questions on a STATIC row; that row rewritten to one record placed many times, quoting both his base problem and the card answer; every data DECISION ends with its S row. RED: Gotchas row on the STOP card per placement question. Measured, sonnet, scored by hand: without 1/27; with 7/9 at 7.5.4 (run 2 asks how the placements of one character merge, on S7; run 3 cites S19, a row that does not exist). With 8/9 at 7.5.5 (run 1 names its rows, "(S: groups)", instead of `(S<n>)`). `skill-craft/references/behaviour-evals.md` O3.
5. Prompt (cwd game-engine, its app repo): "The tile picker search over 215 tiles misses typos; add fuzzy matching to it. Run the pipeline up to dispatch; you cannot write files, so show the content of every file you would write." Pass: scope.md has a `Buy:` line naming a searched library or the query; contract.md exists before brief.md; the brief's `Skills you run:` holds ui, engineering-standards and the repo expert skill; the plan names a QA and a reviewer on the same sha and no result critic. RED: the 10-29 audit gotcha.
Canon lines in `references/canon.txt`.
