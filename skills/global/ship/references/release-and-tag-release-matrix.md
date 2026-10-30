# Release matrix, the index

Scripts, version file, tag scheme, triggers, targets and the exact flows per repo. Each repo's row lives in that repo's own docs; the rows of the retired project skills are in the
history backup bundle of the skills repo (private workspace, `claude-skills/history-backup-2026-10-30`) (`skills/specific/*/*/references/release-and-tag-release-matrix.md`). When a row and the repo files disagree, the
files win: fix the row and its `RELEASE_ROWS` line (the profile file the script sources) in the same turn.

Every `publish.sh` tags and pushes whatever branch is checked out (`git symbolic-ref --short HEAD`). Every `bump.sh` and `publish.sh`
asks Y/n; non-interactive runs pipe it (`echo Y |` or `yes |`), and only after his yes.

| Repo | Where the row lives |
|---|---|
| any repo | the repo's own docs (CI file, `bump.sh`, `publish.sh`, release docs) |
| a project with a private overlay | `skills/specific/<project>/facts/ship-release-matrix.md`; the script rows in `skills/specific/profiles/<project>.sh` |
| a project kept on this machine only | `~/.claude/local-skills/<project>/facts/`; the script rows in `~/.claude/local-skills/profiles/<project>.sh` |
