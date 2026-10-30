# Recovering the previous thread

Open when he says "continue", "where were we", "recover the last session", or after a compaction.

## Order of trust

1. His words (prompts). Durable copy: `<workspace>/PROMPT-LOG.md` where it exists, then the dated handoffs.
2. The spec or plan for the work.
3. The handoff (can lag the last session).
4. The code itself (`git show <sha>:path` against the old version, not just the diffstat).

Git log, the newest file and the compaction summary are artifacts. They say what changed, not what he asked.
When sources disagree, the disagreement is where the real stop point is. Spec plus his accumulated words win.

## His prompts from the session JSONLs

Session files live in `~/.claude/projects/<encoded cwd>/*.jsonl`, newest by mtime. They rot, so read them
while they exist. Read every session the work spans, from the date the ticket or branch started, never only the
last one: set `<YYYY-MM-DD>` to that start date and widen `head -3` until the oldest file read predates it. Pull only the human turns, never whole transcripts (they overflow):

```bash
D=~/.claude/projects/<encoded cwd>
ls -t $D/*.jsonl | head -5
jq -rc 'select(.type=="user" and (.message.content|type)=="string" and .timestamp>="<YYYY-MM-DD>")
        | "\(.timestamp[0:16]) \(.message.content[0:400])"' $(ls -t $D/*.jsonl | head -3)
```

Content can also be an array of blocks; for those use `.message.content[]? | select(.type=="text") | .text`.
Skip lines that are tool results or start with `<task-notification>`.

## The verdict

End the recovery with one of:
- Ready for his review: what he will see and where.
- Must continue: the concrete gap, with the evidence (file:line, failing test, missing doc section).

Never a single-source "looks done, go validate".
