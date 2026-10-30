# Example: a shop app batch, the full report when work stops

Built from `BATCH__2026-10-15__admin-and-proposals.md`, in the shape of `references/work-report.md` law 3.
Ticket 6 is left out (he closed it as not a bug); tickets 1 and 2 are left out once he has validated them on
staging. No question card: the one candidate (owner roll-up emails) is already answered in the batch doc, he
ruled it out. The shas, server and steps below are placeholders to show the shape; a real report copies git
and the record.

```
## What changed
- 3: Home proposals. /home-proposals shows six templates behind one dropdown; before, six separate pages.
- 4: Notifications reach only the agent they are for. Dane gets 33 F&G alerts, expected 32.

## Commits
- <sha> proposals: six templates behind one dropdown (staging branch, pushed)
- <sha> notifications: send each alert to its own agent (staging branch, local)

## How to QA
Setup: staging, no migration, no new env vars, no seeds.
1. Home proposals: open /home-proposals, pick each of the six templates in the dropdown, expect each to render its own form.
2. Notifications: log in as Dane, open the alerts list, expect 32 F&G alerts (33 today, see Not done).

## Not done
- 4: the F&G count is off by one for Dane; the cause is in the alert grouping, fix under way.
- 7: Mobile layout. Blocked on the hpax rebuild; the rest went on.

## Following
BATCH__2026-10-15__admin-and-proposals.md and the record. Batch: 1 of 3 done.
```

For a pure analysis turn (no files changed), law 12 applies: the findings go into a workspace file first,
and the reply names it under `## What changed`, for example
`$CLAUDE_WORKSPACE/shop/analysis-agents-list.md`: the agents list
runs one query per agent row, the fix is a preload in the list function.
