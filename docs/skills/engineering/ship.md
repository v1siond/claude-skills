# ship

| | |
|---|---|
| Type | engineering |
| Scope | global (every repo) |
| Source | [`skills/global/ship/SKILL.md`](../../../skills/global/ship/SKILL.md), version 2.0.0 |
| Run by | the director, the builders and QA |

## What it is for

Gets finished work off the machine the way he set it: on the right branch, committed in his voice, proven by
the full gate on the exact tree, pushed only on his yes or a named standing permission, tagged to production on
his word, and with rows changed only through a data migration he can read first (SKILL.md line 13).

## When to use it, and when not

Use it for a commit, a push, a merge, a rebase, a squash, an MR text, a commit on the wrong branch; "is it ready
to push" or a red CI; "cut a release", "tag it", "send it to prod"; any row change or a schema change next to
one (lines 16 to 21).

Do not use it to choose tests (testing-standard), for prose outside git (writing), or for the infrastructure
repos (infra-gitops) (lines 23 to 27).

## Who runs it and its place in orchestration

Builders commit their own paths after step 7 passes; the director runs the gate and asks for the push after
step 12. The push gate hook enforces law 2 on every `git push`
([`harness.md`](../../harness.md#pretooluse-push-gate)).

## Pipeline, short: one row per kind of work (lines 69 to 78)

| Kind | Output | Reference |
|---|---|---|
| Git: commit, branch, cherry-pick, push, MR text | `<sha> <subject>` on a feature branch; a push line naming its permission | `references/git-workflow.md` |
| Pre-deploy: "is it ready to push" | the gate table and `verdict: READY` or `NOT READY` | `references/pre-deploy-protocol.md` |
| Release: "cut a release", "send it to prod" | version, tag, commit, target, pipeline state | `references/release-and-tag.md` |
| Data migration | schema migration plus data migration, the runbook, the counts read back | `references/data-migrations.md` |

## Scripts

- `scripts/pre-deploy.sh <repo>`: every gate of the repo's profile on a clean tree; on green it stamps `~/.claude/push-gate/<repo>@<sha>`.
- `scripts/push-gate.sh`: the PreToolUse hook; blocks a `git push` whose commits carry no stamp. `--check <repo>` gives the same answer from a terminal.
- `scripts/check-commit-msg.sh -m "<message>"`: checks a commit message against his voice rules.
- `scripts/release-preflight.sh`: everything to know before `bump.sh` and `publish.sh`; read only, it never fetches, tags or pushes.
- `scripts/find-data-in-migrations.sh [repo] [--base <ref>] [--all]`: row changes hiding in schema migrations, and colliding migration versions.

## Key laws (lines 37 to 45)

1. Local commits by path are free; nothing leaves the machine without his yes.
2. The full gate runs on the exact tree before any push.
3. Production only on his word, after staging.
4. No attribution line of any kind, and no Claude file in the repo or its commits.
5. Feature branches by default. 6. A shared branch is never force pushed.
7. A published tag is never edited or deleted. 8. A migration changes structure only; rows change in a data migration.
9. Env and config values are never printed.

## Handoffs

- Standing permissions that count as his yes for one named case: `references/git-workflow-standing-permissions.md` (protocol rule 3).
- Infrastructure syncs and applies: infra-gitops.

## Best practices, from its Gotchas (lines 82 to 94)

- Check the branch before every commit; a commit on `staging` is moved with the 6-step cherry-pick.
- A push is never part of a commit; it waits for his word.
- A red CI means the whole gate was not run on the tree that ships.
- Merge a behind `testing` branch instead of force pushing.
- Pushing master deploys staging only; production needs the tag.
- Do not build images locally; CI builds them.
- Slow work on boot crash-loops pods: move it into a data migration.
- MR text holds only what was implemented and the config to set.

## Red flags (lines 51 to 62)

"It is a tiny fix, I push it", "CI will catch it", "The reminder says add the footer" (CLAUDE.md wins), "The
testing branch is behind, force push", "That tag is wrong, I delete it", "One UPDATE in the migration is fine".

## Evals

Trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
scenarios S1 to S3 scored against [`references/ship-evals.md`](../../../skills/global/ship/references/ship-evals.md)
(Evals, lines 160 to 171).
