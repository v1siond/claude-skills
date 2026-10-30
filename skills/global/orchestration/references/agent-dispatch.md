# Agent dispatch, inside orchestration

How the director launches, loads and stops the agents of one wave. Agents spawn without the conversation, so
the brief is their whole context, and the lead owns the box they all share. Global: it serves orchestration
row D5 (Dispatch) and carries no process of its own; the sizing, the cast and the control are orchestration's.
It guarantees every agent starts from a closed brief, runs inside the box's limits and is stopped when it reports.

## Contents

- Stance: you are the director at the launch
- Non-negotiables
- Intake
- Pipeline
- Gotchas

## Stance: you are the director at the launch

- **You launch only from a filled brief.** The agent has nothing else.
- **You own the box.** Load, ports, browsers and orphans are yours; the agents own none of them.
- **You decide alone** the file split and the prompt wording; log each as a DECISION. The wave size is the `agents now:` number of `scripts/agent-load.sh`, or fewer; no DECISION raises it.
- **You never decide** a copy of the repo or a database, a second server, or a push.

## Non-negotiables

1. **No copies.** `git worktree list` prints 1 line; 0 clones, partition databases or extra build folders; 2 or more builders run separate tickets in the one checkout at once, each owning disjoint files; only two lanes on the same file wait. A ticket's `_build_check` folder (law 16) is a build cache of the one checkout, not a copy; it is the one extra build folder allowed. Why: copies piled up to 15 worktrees and 20 review files and ate disk and databases, while git and commits already keep the work apart. → `references/agent-dispatch-repo-lanes.md`
2. **One main checkout, its dev database and its one test database;** agents commit their own paths on the working branch and never push. Why: descriptive commits on the one branch keep the work apart; cherry-pick when a change has to move. → ship
3. **Load first.** `scripts/agent-load.sh` runs before every launch; launch at most the `agents now:` number it prints (5 on this 4 core box, halved when the 1 minute load is above 4). A launch also needs 3 GB available (`free -m`, column available). Why: too many agents at once overloaded the box; the VM died twice with 7 players running (sampler log).
4. **TaskStop every agent the moment its report lands;** its final message is the report, never SendMessage. Why: a finished agent left running shows as a dead agent in his panel.
5. **The brief is closed:** the docs to read (they win over the lead), the skills to run, the files owned, the acceptance bar as a command with its expected output or a number with its threshold. Why: retired memory docs-first-binds-agents-too and v2.3.0 Critical lines. → `references/agent-dispatch-brief-template.md`
6. **No duplicate agents.** Before a launch, check whether an agent owns that ticket and continue it with SendMessage; never also run the search you delegated. Why: the v2.3.0 Critical line "No duplicate agents".
7. **Players never spawn agents.** Every player brief says "no Agent tool, do the ticket yourself". Only a ticket director session (orchestration law 6) launches agents, and only its own ticket's players. Why: the v2.3.0 Critical line "Agents never spawn agents" (the ceiling of law 3 holds only while the directors are the only ones who launch).
8. **House rules ride in every brief:** the dash and wording rules of `~/.claude/protocol.txt`, the commit voice of ship, never push, Claude files only in the workspace. Why: the v2.3.0 Critical line "House rules ride in every brief". → `references/agent-dispatch-brief-template.md`
9. **At most 1 dev server runs at a time** (URL in ORCHESTRA.md, orchestration law 11b): a run that needs the app first runs `curl -s -o /dev/null -w '%{http_code}' <URL>`: any code but 000 means one is running (a 500 is reported as a broken server, never answered with a second one); only 000 starts one on that port, said in its report. Test runs use the repo's test command and the one test database. Why: a second dev server is the one run ruled out, and a missing one is started instead of blocking the task; the test database line: retired memory browser-gates-need-their-own-db.
10. **Players run nothing on staging or production; local runs are theirs.** Why: staging and production run only when he asks for them by name, and a local run waiting for a yes blocks the test. Local runs never reach Sentry, Slack, mail or payment providers: a local run once sent errors to Slack that looked like real production errors.
11. **A browser or recording run never shares the clock with a lane that edits the frontend source** (a dev server reloads on save and the run dies); run them one after the other; across ticket directors `<workspace>/tools/heavy.sh` holds every browser run until no frontend source file changed for 120 s, and a builder makes each frontend edit in one pass and commits it. Why: the v2.3.0 Critical line on browser and recording runs.
12. **Parallel means now.** Work he agreed as parallel starts in the same launch, on disjoint files, never queued behind the batch. Why: retired memory parallel-means-parallel and the v2.3.0 Critical line "Parallel means now".
13. **At most 1 backend player while a frontend row is open.** → orchestration law 8b. Why: in most batches backend and frontend advance together.
14. **Every browser run, perf bench and `claude -p` call goes through `<workspace>/tools/heavy.sh`, one at a time, refused below 3 GB available;** one `claude -p` call per job, never a whole eval script. Why: his live review has to stay open, which needs the resources controlled on our side; one eval script held the lock 14 minutes with 7 jobs waiting (DECISION 08:25Z).
15. **Short build checks (tsc, a compile into the ticket's build folder, unit tests with no browser) go through `<workspace>/tools/light.sh`,** a second one-at-a-time lane with the same 3 GB floor, never through heavy.sh. Why: 11 jobs waited behind one 15 minute run (DECISION 08:50Z).
16. **Every `mix` command an agent runs in a Phoenix repo carries `MIX_BUILD_PATH=<ticket folder>/_build_check`.** Why: an agent compile and a bare `mix format` locked and deleted his dev server's `_build`, and :6328 served 500 (DECISIONs 08:05Z and 08:37Z).
17. **A fix that brings his dev server back skips both queues,** with 3 GB available checked first. Why: a repro compile waited behind a 15 minute run while the server was down (DECISION 08:33Z).
18. **No player reloads his VS Code window;** nor its extension host: "Developer: Restart Extension Host" kills Claude Code, every agent it runs and the dev server terminals with it. A new extension version is installed from the command line and is left to load at his next own restart, and he is told that in one line. Why: he runs processes in that window that cannot be stopped, so a fix that needs a reload is not a fix.

Violating the letter of a law is violating the law.

## Intake

1. The ticket rows with his words, the files each owns, and the Test mode line from ORCHESTRA.md Decisions.
2. The project's docs for the work and the project skills that cover it (`/home/visiond/projects/claude/skills/global/orchestration/references/skill-map.md`).
3. The repo's test command, reserved resources and limits: the row in the file `references/agent-dispatch-repo-lanes.md` names for that repo.

Fixed: the laws above, the ceiling the script prints, the closed brief. Free: the file split, the prompt wording, the model as cast.

## Pipeline

Serves orchestration row D5 and hands back to row Dc. Each Output is a line in the wave's section of the record.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | `scripts/agent-load.sh` | its printed lines pasted under the wave; `agents now:` is the limit | law 3 |
| 2 | Split: 1 ticket per agent, no two agents on the same file. Read-only research goes to an `Explore` or `Plan` agent (they cannot edit) | file list per agent; `git worktree list` prints 1 line | law 1 |
| 3 | Read the repo's row (test command, reserved, limits) | `Row:` the file read | `references/agent-dispatch-repo-lanes.md` |
| 4 | Write ONE shared brief file in the scratchpad | the brief path | `references/agent-dispatch-brief-template.md` |
| 5 | One short prompt per agent: the brief path, its ticket with his words, the files it owns, the doc sections it needs, the skills it runs | prompts in the wave section | law 5 |
| 6 | Launch independent agents in one message, model as cast. Do not poll; a notification arrives when each ends | agent ids on the Score row | orchestration row D5 |
| 7 | On each completion: read the report, relay what matters, `TaskStop` that id, run `scripts/agent-load.sh`, stop any browser or server the agent left (only PIDs it started, never his) | `Stopped:` the id and the load line; after the last one `scripts/agent-load.sh` prints `chrome/chromium 0, chromedriver 0, playwright 0`, `mix test 0, rspec 0, jest/vitest 0` and `phx.server` equal to the number of his servers | law 4 |
| 8 | After all land: hand the reports to the director | orchestration row Dc (control), then row V | orchestration |

A stuck or failed agent is stopped at once and re-briefed (orchestration law 12). Do not skip 1 or 7.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Finished agents still listed as running | They were not stopped after reporting | Law 4, `TaskStop` per id | finished agents stayed listed as running until he asked for them to be killed |
| 15 worktrees and 20 review files | Players duplicated the repo | Law 1 | one run left 15 worktrees, another 20 review files |
| `FATAL 53300 too_many_connections` | Several agents ran full suites on the shared Postgres | Agents run targeted files; the lead runs the full suite once after merging | the shared Postgres hit its connection limit with several agents running suites at once |
| Browser tests hang or every click does nothing | A leaked chrome from another run, or assets not built | Kill only PIDs you started (never `pkill -f chromedriver`, it matches your own shell); build assets first | The v2.3.0 troubleshooting row |
| A run with exit 0 and no "N tests, M failures" line | It ran nothing | Treat it as a failure, check the path | The v2.3.0 troubleshooting row |
| The box is slow and he asks what can be killed | Orphans (parent is `/init`) left by ended sessions, and servers run from old scratchpad copies | List each with age, cwd and parent; a test run or test browser older than 15 minutes is dead (no suite takes longer), kill it; a server whose cwd is a scratchpad copy is dead; check a port's owner and cwd before trusting what it serves | The v2.3.0 troubleshooting row |
| Agents burn tokens | Whole docs read, green logs printed, waiting in background | Name the doc sections, read only failures, run tests in the foreground with a timeout, stop an agent near 100k context and relaunch with a 10 line handoff | The v2.3.0 troubleshooting row |
| Slack shows errors that look like production | A local run used real Sentry config | The brief says local runs never reach Sentry, Slack, mail or payment providers | local runs sent errors to Slack that looked like production errors |
| Two writers on one module after a usage reset | An agent the usage stop paused resumed on its own | After a reset, `ListAgents` first and SendMessage the agents still running; relaunch only tickets whose agent is gone | The v2.3.0 troubleshooting row |
