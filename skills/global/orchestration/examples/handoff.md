# Handoff shape

File: `$CLAUDE_WORKSPACE/<project>/<YYYY-MM-DD>-handoff.md`, updated
after every status change. It serves a session with no Score; with a Score, `ORCHESTRA.md` is the record and
holds the same headings in its Log. The newest file wins over older handoffs.

```markdown
# Handoff <date>, shop admin fixes and home proposals

## Where we are
Record: ORCHESTRA.md in the shop workspace. Tickets 1, 2 built, 3 and 4 in progress.
Branch fix/admin-batch-1015 in shop, 3 commits, unpushed.

## His words this session
- "I can't access feed engine on admin side, 500 error"
- "I vote to keep the agent specific notifications"

## Done and proven
- 1. Feed engine 500: replica read path did an UPDATE. Test red on old code, green now.

## He validated
- (nothing yet this session)

## Left
- 4. F&G alert count, expected 32 for Dane, getting 33.

## Uncommitted
- apps/shop/lib/shop/data/feed_parser/acord.ex (alert grouping, half done)

## Next step
Group F&G alerts by (agent, agency, carrier) in acord.ex, rerun the notifications test file.
```

Reconcile before trusting an older one: `git log --since=<handoff date>`, `git status`, and his prompts
since then (`/home/visiond/projects/claude/skills/global/session-start/references/recover-thread.md`).
