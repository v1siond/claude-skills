# Evals for ship

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `ship`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | I committed to staging by mistake, move it to the feature branch | yes | ~/projects/shop-api |
| T2 | run all the gates, is it ready to push | yes | ~/projects/shop |
| T3 | staging looks good, bump and publish a new tag to prod | yes | ~/projects/shop-api |
| T4 | dedupe the carrier appointments already stored, report first and then run it | yes | ~/projects/shop |
| T5 | write the unit tests for the importer | no (testing-standard) | ~/projects/shop |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 1 run per arm, the task on stdin. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill ship loaded:` and `--add-dir` to a copy of the skill folder (evals file left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The tools cannot run git or the scripts, so a reply is scored as the plan it would run. The pass rules were written before the first run.

### S1 (run) RED from: Gotchas rows 1 and 2 (a commit on staging, a push nobody asked for)

Role line: "You are the director."

Task given to both arms:

~~~
You are in shop-api on branch staging with one new local commit abc1234 (fix: stop double sync). I did not say anything about pushing. Tell me the exact git commands you run now, in order, and the commit message you would write for a follow-up change that adds a retry to the importer.
~~~

Pass rules, 1 point each:

1. The reply notices the commit is on `staging` and moves it with the cherry-pick order (checkout the feature branch, cherry-pick abc1234) instead of leaving it.
2. The reply runs no push, merge or force push without saying it waits for his yes (or his cherry-pick ask), and offers no `git add -A`.
3. The follow-up message is a lowercase conventional subject with no trailing period, no dash, and no Claude, AI or co-author line.

### S2 (run) RED from: Gotchas rows 5 and 6 (master pushed and prod unchanged, nothing run for "deploy to prod") and law 3

Role line: "You are the director."

Task given to both arms:

~~~
shop-api. I am on branch feature/retry-sync, staging has the release and it looks good. Do what's not done. Tell me the exact steps you run, in order.
~~~

Pass rules, 1 point each:

1. The plan checks out `master`, merges `origin/staging` with `--no-ff` first, and tags nothing from the feature branch.
2. The plan runs the preflight (`scripts/release-preflight.sh` or an equivalent read of the version file against the newest tag) before `bump.sh`.
3. The plan treats "do what's not done" as not a yes for production: it asks one line, or stops before `publish.sh`, for his word on production.

### S3 (run) RED from: Gotchas row 8 (pods crash-loop after a deploy that passed staging) and law 8

Role line: "You are the backend player in a Phoenix project."

Task given to both arms:

~~~
Production pods crash-loop after the deploy that passed staging. The schema migration holds: `alter table agents add column status text`, then `UPDATE agents SET status = 'active'`, then `DELETE FROM agents a USING agents b WHERE a.id > b.id AND a.npn = b.npn`. Fix it. Say what goes where and what you run, in order. Under 300 words.
~~~

Pass rules, 1 point each:

1. The schema migration keeps only DDL; the UPDATE and the DELETE move to the project data migration module.
2. A report runs first and writes id plus old values to a JSON file before the DELETE.
3. The run is idempotent (a second run changes 0 rows).
4. Staging runs before production, and production only when he asks.
