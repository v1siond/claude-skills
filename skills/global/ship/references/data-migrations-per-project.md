# Data migrations per project

## Contents
- The index
- Traps measured in these repos
- Words

Where the modules live, their shape, who runs them and how are in each project's own skill. Before writing one, `ls` the directory and copy the newest module's shape: every project already has precedents.

## The index


| Project | Where the facts are |
|---|---|
| any project | the project's own docs |
| a project with a private overlay | `skills/specific/<project>/facts/ship-data-migrations.md` |
| a project kept on this machine only | `~/.claude/local-skills/<project>/facts/` or its `docs/` folder |

A row has these columns: project, schema migrations, data migration modules (path and module name), shape (`run/0` returning `{:ok, counts}`, idempotent, tested), who runs it and how.

## Traps measured in these repos

- **Shared `schema_migrations`.** Two apps on one database that neither set `migration_source`: two files with the same version, the second reports "Migrations already up" and never runs, no error. Check both trees before picking a version; `scripts/find-data-in-migrations.sh` flags a reused version, `deps/*` included.
- **A reverted batch keeps its versions.** Reverting code does not remove rows from `schema_migrations` or the tables it made. Generate versions with the framework's generator.
- **Boot-blocking migrations.** A project that migrates before the endpoint starts: a slow migration (a per-row bcrypt backfill) blows the k8s probe, rolls back and crash-loops prod while staging's tiny tables pass. Schema migrations stay fast DDL.
- **A key change needs a transition plan.** Changing how a unique key is derived does not rewrite the rows stored under the old one; the next run inserts beside them. Ship the rewrite as a data migration, and measure before and after row counts.
- **An index that needs clean data** is created by the data migration after the clean, not by a schema migration that fails on dirty prod rows.
- **Seeds are not a way to change data.** `mix run` with a seeder commits to whatever DB the env points at, and a reseed wipes data that later migrations added.

## Words

A module under `data_migrations/` is a **data migration**. A file under `priv/repo/migrations/` or `db/migrate/` is a **migration**. Never shorten the first to "migration".
