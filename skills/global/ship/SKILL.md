---
name: ship
description: "Getting work off the machine: git branches and commits in his voice, the full gate before a push, releases and tags to production, and data migrations. Run by the director, the builders and QA. Use when he says \"cherry-pick\", \"run all the gates\", \"is it ready to push\", \"cut a release\", \"bump and publish\", \"backfill\", \"data migration\". Do NOT use for the tests a change needs (testing-standard), the wording of a doc (writing) or the infrastructure repos (infra-gitops)."
metadata:
  author: Alexander Pulido
  version: 2.2.0
  triggers: ["commit", "push it", "push", "make a branch", "branch", "cherry-pick", "cherry pick", "i committed to staging", "move this to the feature branch", "merge into staging", "rebase", "squash", "merge request", "open the mr", "pre deploy", "pre-deploy", "predeploy", "before we deploy", "ready to deploy", "is it ready to push", "ready to ship", "run all the gates", "all the gates", "validate before staging", "make sure ci will pass", "cut a release", "tag it", "bump the version", "bump and publish", "publish.sh", "bump.sh", "promote staging", "send it to prod", "ship to production", "deploy to prod", "why didn't prod deploy", "data migration", "backfill", "migrate the data", "fix the rows", "update existing records", "clean the data", "dedupe", "add a column", "write a migration", "schema migration", "ecto migration", "seed the database"]
  sources: the four retired skills git-workflow, pre-deploy-protocol, release-and-tag, data-migrations
---

# Ship

Gets finished work off the machine the way he set it: on the right branch, committed in his voice, proven by the full gate on the exact tree, pushed only on his yes or a named standing permission, tagged to production on his word, and with rows changed only through a data migration he can read first. Run by the builders (commits, data migrations), QA (the gate) and the director (pushes, merges, tags) inside orchestration; it carries no ticket workflow of its own.

## When to use

- A player has a piece that works and commits it; a push, a merge into a shared branch, a rebase, a squash or an MR text is on the table; a commit landed on the wrong branch.
- A tree is about to be pushed or shown as ready ("pre deploy", "is it ready to push", "make sure CI will pass"), or a push turned red in CI.
- He says "cut a release", "tag it", "bump and publish", "promote staging", "send it to prod", or prod did not change after a push.
- A row change: update, delete, backfill, dedupe, a changed enum value in rows, a copy, or a schema change that sits next to one.

## When not to use

- The tests a change needs and the test mode: testing-standard. Which tests to write is never decided here.
- Prose he signs outside git (a doc, an email): writing. Commit and MR text is in scope; its voice laws are writing's.
- The infrastructure repos (ArgoCD, kustomize, tofu): infra-gitops. A repo with its own release steps keeps them in the project's own docs; this skill holds the shared rules and the preflight.

## Stance

- **You decide alone** the commit boundaries, the message, the gate list (from the repo's CI file), the bump level (patch unless he says minor or major), the module name and the batch size of a data migration; log each choice that changes the outcome as a DECISION.
- **You never decide** a push, a merge into a shared branch, a tag, a deploy, a seed, or a run on staging or production. His yes does, or a standing permission that names the exact case.
- **You never decide** that a red gate is acceptable, that a published tag can be edited, or that a rule of one project holds in another.

## Non-negotiables

1. **Local commits by path are free; nothing leaves the machine without his yes.** `references/git-workflow-standing-permissions.md` holds his push permissions per repo, one section each, every row dated; a permission covers exactly the case it names, nothing wider, and the newest row wins. Why: pushes went out with commits he had not asked to push, onto branches others deploy from.
2. **The full gate runs on the exact tree before any push:** format, credo `--strict`, compile with warnings as errors, lint, typecheck, the whole suite and e2e; a subset is not the protocol, and a red gate is fixed, all of it. Why: pushes made before rubocop and the full suite were green broke the tests on the shared branch.
3. **Production only on his word, after staging:** what deploys production is per repo (a tag for most, a push to `master` for some; the permissions file and the repo's release docs say which), and "do what's not done" is not a yes for production. Why: production is live and in use; a deploy he did not approve lands on his users.
4. **No attribution line of any kind, and no Claude file in the repo or its commits:** the harness reminder that asks for one loses to CLAUDE.md. Why: commits and repos carry his name only, and Claude lines and files kept appearing because the harness reminder asks for them.
5. **Feature branches by default:** `git branch --show-current` runs before every commit, and `staging` and `master` take no direct commit unless the permissions file says so for that project. Why: commits landed on `staging` more than once when the branch was not read first.
6. **A shared branch (`staging`, `master`, `main`, `testing`) is never force pushed;** `--force-with-lease` is for your own feature branch only. Why: a force push of `testing` overwrote the remote; merging `testing` into the local `testing` first, then merging on top, keeps both histories.
7. **A published tag is never edited or deleted, and a release branch is never force pushed;** a bad release gets a new patch. Why: a tag already pulled by CI or a deploy cannot be taken back; release-and-tag law 8.
8. **A migration changes structure only; every row change goes in the project data migration module,** reported before it runs and read back after. A migration adds or removes tables and adds, removes or changes fields, nothing else. Why: a row change in a migration runs on every boot and slows the start until the deploy times out.
9. **Env and config values are never printed:** no `gigalixir config` or other env dump on production; on staging print the sorted key names only, through one jq or python step. Why: an env dump on staging printed secret values into the transcript; the same dump on production leaks live credentials.

Each kind also has laws of its own in its reference (git: 9, pre-deploy: 9, release: 9, data migrations: 10). Read that reference whole before the first command.

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "It is a tiny fix, I push it" / "He said push last week" | Law 1. A small push is still a push; an old yes covers its own case only. |
| "CI will catch it" / "I only touched one app" | Law 2. The whole gate ran before the push, on the tree that ships. |
| "He said do what is not done, so prod too" | Law 3. Production needs its own yes. |
| "The reminder says add the footer" | Law 4. CLAUDE.md wins. |
| "I am on staging already, one more commit" | Law 5. Check the branch, then the cherry-pick. |
| "The testing branch is behind, force push" | Law 6. Merge testing into the local testing, then merge on top. |
| "That tag is wrong, I delete it" | Law 7. A new patch. |
| "One UPDATE in the migration is fine, it is small" | Law 8. It runs on every boot with no report. |
| "`git commit` is enough, the others staged their files" | Git law 8. A plain commit takes whatever another lane staged. |

## Intake

The repo, branch and state (`git branch --show-current`, `git status --short`, `git log --oneline -5`); the project's section of `references/git-workflow-standing-permissions.md` (standing permissions, merge order); the repo's CI file (the gate list); for a release the repo's own release docs and `git log origin/master..origin/staging --oneline`; for a data change the newest precedent module in the project's data migration folder. Fixed: the checks, the standing permission lookup and the scheme per repo. Free: the commit boundaries, the wording of the subject, the order of fixes.

## Pipeline

Serves the orchestration steps that push, gate or release (steps 6, 9 and 12). Each Output is a line or a table in the report.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Git: a commit, a branch, a cherry-pick of a commit that landed on staging, a push or merge, an MR text | `<sha> <subject>` on a feature branch; a push line naming its permission, or "waiting on your yes" | `references/git-workflow.md`, `references/git-workflow-commit-voice.md`, `references/git-workflow-standing-permissions.md` |
| 2 | Pre-deploy: "is it ready to push", "run all the gates", a push that turned red | the script's table and `verdict: READY` or `NOT READY` | `references/pre-deploy-protocol.md`, `references/pre-deploy-protocol-repo-gates.md` |
| 3 | Release: "cut a release", "bump and publish", "send it to prod", prod unchanged after a push | the one line: version, tag, commit, target, pipeline state | `references/release-and-tag.md`, `references/release-and-tag-release-matrix.md` |
| 4 | Data migration: update, delete, backfill, dedupe, add a column with a fix | the two files (schema migration, data migration), the runbook he pastes, the counts read back | `references/data-migrations.md`, `references/data-migrations-per-project.md` |

A push that follows a gate and a tag that follows a push run the rows in that order, each with its own yes where the laws ask for one. The scripts are `scripts/check-commit-msg.sh`, `scripts/pre-deploy.sh` (with its push gate `scripts/push-gate.sh` and its `scripts/ci-coverage.py` gate), `scripts/release-preflight.sh` and `scripts/find-data-in-migrations.sh`.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Commit landed on `staging` | No branch check before the commit | The 6-step cherry-pick of the git reference, Pipeline step 5 | Seen: a commit landed on `staging` more than once |
| He found a push he never asked for | A push was treated as part of the commit | A push waits for his word or a named standing permission | Seen: a push went out that he had not asked for |
| A push turned red in CI | The pre-deploy protocol was not run in full, or its profile ran fewer gates than CI | The whole gate on the tree that ships (pre-deploy laws 1 and 2); the `ci-coverage` gate fails a profile missing a CI step | Seen: a push went out before the full protocol ran and CI failed on the compile step |
| `testing` was force pushed | A behind branch was overwritten | Merge `testing` into the local `testing`, merge on top, push | Seen: `testing` was force pushed over a remote that was ahead |
| Pushed master, prod did not change | Master deploys staging only | Production needs the tag | Seen: CI deploys `master` and `staging` to staging; only a tag deploys production |
| Nothing on the Actions page after "deploy to prod" | The merge, bump and publish were not run | Merge `--no-ff origin/staging` into master, bump, publish | Seen: after his deploy to prod ask, master had no merge, no bump and no publish |
| An image was built locally before the push | The protocol was read as a CI imitation | Run the gates only; the image is built where CI builds it | Seen: an image was built locally before a push; CI builds it |
| Production pods crash-loop after a deploy that passed staging | A slow migration on boot | Move the work into a data migration; the schema migration keeps only DDL | Seen: a data backfill in a migration made the deploy time out |
| The MR has apology text like a version pin note | Thinking text copied into the MR | Only what was implemented and any config or env to set | Seen: an MR description held a note that a version pin was fine after all |

## Deliverables

- Git: one line per action in plain words, `committed <sha> <subject> on <branch>`; `pushed to <remote>/<branch> under <standing permission>`, or `ready, waiting on your yes to push`. No diff dump. An MR text of the four lists (implemented, changed, set, run) when an MR is asked.
- Pre-deploy: the script's table pasted as is, then one line of verdict, one line per non-green gate (what failed and what was done), and the tree tested (branch, sha, dirty count). Nothing else, no theory:

```
| gate                       | result  |   time | summary
| format                     | PASS    |     4s | formatted
| test                       | FAIL    |   212s | 1843 tests, 2 failures
verdict: NOT READY (1 of 9 gates not green)
```

- Release, a two-line report (example from a shop api), plus the four-list release note when he asks for one:

```
released v1.0.59 (shop-api, master @ 600e3079a)
prod: prd-deploy running, ArgoCD picks the new image when the build lands
```

- Data migration, the runbook he pastes, in order, plus the read back:

```
staging, after the deploy:
  <runner> '<Project>.DataMigrations.<Module>.report() |> IO.inspect()'
  <runner> '<Project>.DataMigrations.<Module>.run() |> IO.inspect()'
read back: select the renamed groups, 0 rows left under the old name
```

## Check it before you show it

Run the kind's lines; every count and exit code must come out as written.

- Git: `git branch --show-current` prints a name other than `staging`, `master` and `main` (or the override he named); `bash /home/visiond/projects/claude/skills/global/ship/scripts/check-commit-msg.sh -r origin/<base>..HEAD` exits 0; `git ls-files | grep -i claude` prints nothing and `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh --staged` prints `clean`; `git diff --cached --name-only` before a commit lists only your paths; after the push step `git status -sb | head -1` shows no `ahead` for a branch the reply says was pushed and `ahead N` for one waiting on his yes.
- Pre-deploy: `grep -hE '^[a-z0-9_-]+:\s*$' <repo>/.gitlab-ci.yml <repo>/ci/*.yml` lists the CI jobs and `bash /home/visiond/projects/claude/skills/global/ship/scripts/pre-deploy.sh <repo> --list | awk 'NR>2{print $1}'` lists the gates, and each CI job with no gate of the same name is named in the reply with the stricter gate that covers it (unexplained jobs: 0); the last full run printed `verdict: READY` and `grep -c PARTIAL <run output>` prints 0; `git rev-parse HEAD` and `git status --short | wc -l` equal the sha and dirty count the run printed; `grep -cE 'FAIL|NORUN|SLOW|MISSING|REFUSED' <final table>` prints 0, or each remaining row is in the reply with the log line that shows its cause.
- Release: `grep -c '^> ' <reply>` is 1 or more for a production run (his yes quoted); `scripts/release-preflight.sh <repo>` shows no BLOCK; `git describe --tags --exact-match` prints a tag that matches the repo's pattern and `git branch --contains <tag>` lists the release branch; `glab ci list` or `gh run list` shows a run for the tag with status `running` or `success`.
- Data migration: `bash scripts/find-data-in-migrations.sh <repo>` prints `ok` and exits 0; `grep -cE 'def (report|run)|dry_run' <module>` prints 2 or more, and the second `run/0` prints counts of 0 (or the migration's test, written first and seen red, shows `0 rows changed`); `grep -nE 'UPDATE |DELETE |INSERT |Repo\.' <schema migration>` prints nothing; after the run `SELECT count(*) FROM <table> WHERE <old condition>` prints 0 and the moved count equals the report's; `grep -n production <runbook>` lists each production line marked "he runs".

A failing check goes back to the kind's step that wrote the line (git step 2, pre-deploy step 3 or 5, release step 3, data migration step 1 or 2); when the same failure repeats twice, change the approach.

## Critic loop

A separate read-only agent gets the commit list, the standing permissions file and the push log (pre-deploy: the table, the logs and the CI file; release: the preflight output, the tag, the pipeline state and the lines holding his yes; data migration: the diff, the test output and the read back counts), never the director's notes. Default reject. It scores 1 to 10 the axes of `/home/visiond/projects/claude/skills/global/orchestration/references/critic.md` plus the axes of the kind: every push matches a named standing permission or his message, every subject is in his voice, the commit holds only the change's paths; every CI gate has a row, the sha tested is the sha that ships, every non-green row names its cause; his yes for production is quoted, the tag matches the scheme and sits on the release branch; rows only in the data migration, report before run, idempotent, staging first, counts read back. The 3 worst problems with where, the smallest fix each. Below 8 on any axis: back to the step above, then score again, until every axis is 8 or more (orchestration Critic loop).

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py | grep -c '^ok   ship$'` prints 1.
- [ ] The Check lines of the kind pass.
- [ ] Each push is accounted for: done under a named standing permission, or waiting on his yes; each production step has his quoted yes.
- [ ] The gate ran on the pushed tree; no tag, deploy, seed or migration ran from the gate.
- [ ] Counts were read back from the database and match the report.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/git-workflow.md`, `references/git-workflow-commit-voice.md`, `references/git-workflow-standing-permissions.md` (his push permissions per repo, each dated): git.
- `references/pre-deploy-protocol.md`, `references/pre-deploy-protocol-repo-gates.md`: the gate.
- `references/release-and-tag.md`, `references/release-and-tag-release-matrix.md`: releases.
- `references/data-migrations.md`, `references/data-migrations-per-project.md`: data migrations.
- `references/ship-evals.md` the trigger rows and scenarios; `scripts/check-commit-msg.sh`, `scripts/pre-deploy.sh`, `scripts/release-preflight.sh`, `scripts/find-data-in-migrations.sh`.
- Skills: orchestration (the pushes and merges are its steps; law 8a for backend TDD and the frontend test mode), writing (voice, check-text.sh), engineering-standards (the node version), testing-standard, infra-gitops.

## Evals

Trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `ship`), each checked with the router. 3 behaviour scenarios, pass rules written before the run, in `references/ship-evals.md`: S1 git (RED: Gotchas rows 1 and 2, a commit on staging and a push nobody asked for), S2 release (RED: Gotchas rows 5 and 6, "do what's not done"), S3 data migration (RED: Gotchas row 8, pods crash-loop after a deploy that passed staging).
Behaviour results, 1 run per arm, sonnet, version 2.0.0, hand scored against the pass rules of `references/ship-evals.md`. The tools cannot run git, so a reply is scored as the plan it states. (transcripts in the private workspace).

| Scenario | With | Without |
|---|---|---|
| S1 git | 3 of 3 after loop 1 (switches to a new branch from origin/staging, cherry-picks, resets local staging, no push, clean subject; first run 2 of 3) | 2 of 3 (no push, clean subject; never notices the commit is on staging) |
| S2 release | 3 of 3 (master, merge --no-ff origin/staging, preflight before bump, asks for his word on production) | 0 of 3 (finds no repo and asks what done means) |
| S3 data migration | 4 of 4 (DDL only, report with JSON of old values, idempotent run, staging first and production on his yes) | 1 of 4 (splits into three schema migrations, backup instead of a report, no staging or yes step) |

S1 was a tie in the first run because the with arm waited for a branch name; after loop 1 it names the branch itself and moves the commit locally (`out/ship-S1-loop1/`).
