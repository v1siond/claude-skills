# Where the tickets live, per project

The `Batch: <n> of <m> done` line and the ticket list under `## Following` copy status and names from the ticket file. Workspace root:
`$CLAUDE_WORKSPACE/`. When two files disagree, the newest wins; say which one you overrode.
A project run through orchestration keeps its Score in `<workspace>/<project>/ORCHESTRA.md` (orchestration law 13).

The per-project rows now live in the project skills:

| Project | Where |
|---|---|
| anything else | the numbered list in his prompt, numbered as he numbered it |

Rules that hold for every row:
- A ticket is BUILT by `references/work-report.md` law 10 (orchestration's `built-check.sh`), never by this file's status.
- Update the file's status in the same turn as the standup or the full report.
