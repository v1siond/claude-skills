# Gates per repo, the index

Read this when a gate fails and you need to know what CI really does, or when a repo is not in
`scripts/pre-deploy.sh` yet. Each repo's row lives in that repo's own docs; the rows of the retired project skills are in the
history backup bundle of the skills repo (private workspace, `claude-skills/history-backup-2026-10-30`) (`skills/specific/*/*/references/pre-deploy-gates.md`). CI files change: when a row and the file disagree, the file wins, then fix
the row and the script profile in the same turn.

"His standard" means the protocol adds it even where CI does not: `mix credo --strict` without
`--mute-exit-status`, and `mix compile --force --warnings-as-errors` everywhere.

| Repo | Where the row lives |
|---|---|
| any repo | the repo's own docs (CI file, `bump.sh`, `publish.sh`, release docs) |
| a project with a private overlay | `skills/specific/<project>/facts/ship-pre-deploy-gates.md`; the script rows in `skills/specific/profiles/<project>.sh` |
| a project kept on this machine only | `~/.claude/local-skills/<project>/facts/`; the script rows in `~/.claude/local-skills/profiles/<project>.sh` |
