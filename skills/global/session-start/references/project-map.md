# cwd to project and workspace

What `scripts/session-context.sh` encodes. Workspace root: `$CLAUDE_WORKSPACE` (default `~/.claude-workspace`).

## The generic rows

| cwd starts with | Project / workspace folder | Note |
|---|---|---|
| `projects/<x>` or any repo folder `<x>` | `<x>` | not in the table, the script says so |
| `projects` itself | `projects-root` | |

## Where a project's rows live

A project's rows name its repos and folders, so they stay out of this public repo:

| Kind | Where |
|---|---|
| table rows, scope rules and the project rule read in step 3 | `skills/specific/<project>/facts/session-start-project-map.md` |
| the same, for a project kept on this machine only | `~/.claude/local-skills/<project>/facts/` or its `docs/` folder |
| what the script prints for the project | a `PROJECT_ROWS` line and the `scope_`, `note_`, `context_` functions in `skills/specific/profiles/<project>.sh` (or `~/.claude/local-skills/profiles/<project>.sh`) |

A row is `PROJECT_ROWS+=("<cwd glob>|<project id>|<label>")`. The first row whose glob matches the cwd names the
project.

## Scope rule

One workspace can hold two threads (a product and a site, say). The profile's `scope_` function prints `scope:` and the
script lists only that thread's files; the other thread never appears in the summary. The rule that splits them (a
file name part such as `cv`, a subfolder) sits in the project's facts file.

## Project rule loaded in step 3

A project whose work starts from a fixed doc (field maps for a feed, a one page `STATE.md`) names it in its facts file;
step 3 reads that doc first.
