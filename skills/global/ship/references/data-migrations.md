# Data migrations, inside ship

Changes rows only through a data migration he can read before it writes, that is safe to run twice, that ran
on staging first, and whose result was read back from the database. Run by the backend player in
orchestration row D5 (dispatch, the builder's work) for row changes, and by the architect for schema shape; the director hands the
staging and production runs to him.

## Stance

- **You split every change in two:** DDL in a schema migration, every row touch in a data migration.
- **You decide alone** the module name, the batch size and the report columns; log each as a DECISION.
- **You never decide** to run on staging or production; that is his request, and where the project says production is his, he runs it.

## Non-negotiables

1. **A migration that changes rows is a defect.** Every UPDATE, DELETE, INSERT, `Repo.*`, `update_all` or backfill in `priv/repo/migrations` or `db/migrate` moves to the data migration module. A migration adds or removes tables and adds, removes or changes fields, nothing else. Why: a row change in a migration runs on every boot and slows the start until the deploy times out.
2. **You use the project's existing mechanism:** `ls` its data migration folder and copy the newest module. Never a cron sweep, a boot hook, a rake task or raw psql steps. Why: a backfill written into a migration skipped the project's data migration module and its rules.
3. **You report before you run:** a read only `report/0` or dry run (`dry_run: true` by default in Rails projects) shows what would change, then `run/0`, idempotent: a second run changes 0 rows. Why: the retired skill's Critical list, "Report before run" (old SKILL.md:30-31).
4. **Nothing runs on a server before the deploy:** develop, deploy, run the data migration, read back. Data migrations live in a data migration folder of the data layer and are run by hand after the server starts. Why: a data step tied to boot slows the app start and makes it time out.
5. **Local runs are part of the work;** any migration, data migration, setup or seed the work needs on the local dev and test databases just runs. Staging and production run only when he asks, staging first. Where the project's own docs say production is his, you hand him paste ready commands in order and check the result after; never a console or rpc write on production yourself. Why: a data migration was written and then neither run in the console nor handed over as a command, so it never ran.
6. **You never seed a live environment** (staging, production): a reseed wipes data that later migrations added. Why: the retired skill's Critical list (old SKILL.md:39).
7. **A rename is DDL, its data is not:** `rename column` and `rename table` go in the migration (Postgres renames in place, 0 rows rewritten); a changed enum or type value in rows, a backfill or a copy goes in a data migration. Code that reads the old name changes in the same commit. Why: the retired skill's Critical list (old SKILL.md:40).
8. **Schema migrations are fast DDL:** a project that migrates before the endpoint boots crash-loops on a slow one while staging passes. Why: a big data change in a migration timed out the deploy.
9. **You never type a migration version by hand:** use `mix ecto.gen.migration` or `bin/rails g migration`, then check the version is free in every tree that shares the database. Why: a new file carried an old timestamp; after adding one, check that the latest migrations' timestamps are in order.
10. **You read it back:** editing a migration is not changing the database. Run it and SELECT the field before saying done. You say "data migration" for the module, every time; "migration" means the schema file. Why: the retired skill's Critical list (old SKILL.md:45-47).

Violating the letter of a law is violating the law.

## Intake

| Input | Where |
|---|---|
| the project's mechanism and runner | the project's own docs; facts per project in `references/data-migrations-per-project.md` |
| precedent module | newest file in the project's data migration folder |
| which rows, how many | a read only SELECT on dev or the replica |
| who runs it on the server | the project's own docs; where they say production is his, he runs it |

Values used as ids (codes such as carrier appointment codes) are compared lowercase, `6762N` equals `6762n`: the code lowercases them on write and a data migration lowercases the rows already stored.

Fixed: DDL in migrations, rows in data migrations, report before run. Free: batch size, module name.

## Pipeline

Serves orchestration row D5 (dispatch, the builder's work).

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Split the change: DDL in a generated schema migration (fast, no row change), every row touch in a data migration | the two files | laws 1, 7, 9 |
| 2 | Write the data migration from the newest precedent: moduledoc with the exact run command, a read only report or dry run, an idempotent run that returns counts | the module | laws 2, 3 |
| 3 | Test first: before step 2's `run/0` body, in every batch (a data migration is backend, test driven whatever the test mode: orchestration law 8a, testing-standard law 4), write the test the way the project does: rows before, run, rows after, run again, nothing changed (a fact of the craft, old SKILL.md:62-65); see it red, then write the migration and see it green | the test, its red line and its green line | law 3 |
| 4 | Run `scripts/find-data-in-migrations.sh <repo>` until it prints ok: no row change in a changed migration, no reused version | the script output | laws 1, 9 |
| 5 | Ship through skill ship and the release (skill ship); the schema migration runs with the deploy | the deploy | law 4 |
| 6 | Staging, when he asks: run the report, then the run (or hand him the commands), then SELECT the counts and compare with the report | the counts | laws 5, 10 |
| 7 | Production only on his yes, same three steps; report the counts | the counts | law 5 |

Do not skip step 4: it is the only step that finds the row change someone hid in a migration.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| A data migration cleared values he authored and they could not be restored | no copy before the run | the report writes id plus old values of the affected rows to a JSON file in the project workspace before a delete or clear; a restore reads it back | the retired skill's incident, no measurement |
| "Migrations already up" and the new index does not exist | version reused across repos that share `schema_migrations` | new version; check `pg_indexes` or `information_schema` after | the run reports no error and creates nothing |
| Production pods crash-loop after a deploy that passed staging | a slow migration on boot | move the work into a data migration; the schema migration keeps only DDL | Seen: a data backfill in a migration made the deploy time out |
| A unique index fails to build in production | duplicate rows | fix the cause of the duplicates in the code, write the data migration that cleans them, then create the index; size them first with read only queries in the production console, handed to him or run on his yes (law 5) | Seen: duplicate rows in production blocked a unique index |
| Rows doubled after a re-parse or rerun | a key derivation changed without rewriting old rows | a transition data migration, before and after counts | the count difference |
| The scan flags `on_delete:` or a trigger body | the pattern is broad | read the hit; a trigger or foreign key clause is DDL and fine, say so in the report | `scripts/find-data-in-migrations.sh` output |
| A reverted batch left versions in `schema_migrations` | reverting code does not remove the rows or tables it made | generate versions with the framework generator | `select version from schema_migrations` |
| A seed changed live data | `mix run` with a seeder commits to whatever database the environment points at | never seed outside local (law 6) | a reseed wipes later migrated data |
