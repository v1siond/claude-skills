# How a report is written

The doc the Stop hook names. The law is orchestration law 18; the full rules, filled examples and checks are in
`~/.claude/skills/orchestration/references/work-report.md`. The hook
(`stop-report-format.sh`, its checks in `report-format-check.py`) reads the last message of a turn that changed
files and refuses to let the turn end when it breaks a shape below.

A report is a short functional standup, written only at a checkpoint or when work is about to stop.

## When

Only at a checkpoint: a row finishes a step (QA, a commit, a critic), something blocks, or work is about to
stop. Never on a timer, never at each collect, never twice with nothing new.

## A standup, while work goes on

3 to 6 lines, no heading, no table. The first line starts `Working on:` (bold or not, it is a standup).

```
Working on: <part> of <number: ticket>
Needs before done: <what>
Then: <the next row>
Waiting on you: <short title> (asked <MM-DD HH:MM>), <short title> (asked <MM-DD HH:MM>)
Batch: <n> of <m> done
```

`Waiting on you` is one line shared by every open question, only if any: each question named by a short title
with the date and time it was first asked, for example `Waiting on you: the bell quest (asked 10-26 18:52),
heart pieces (asked 10-26 18:52)`. `<n> of <m>` counts the director's rows only. No percent, no time estimate.

## A full report, when the batch finishes or work stops

Shaped like a PR, these headings in this order:

```
## What changed        per ticket touched, what he will see
## Commits             sha, subject, branch, pushed or local
## How to QA           setup first (server and port, migrations, env vars, seeds), then per ticket: open X, do Y, expect Z, the before and after shot paths
## Not done            and known issues
## Questions for you   a card per open question, only if any
## Following           the spec or doc and the record; the batch in one line; the full ticket list only when he asks
```

## A question is a card, asked once

```
### <the question in plain words>
What it is: plain words, a picture or path when it is about looks
Why it matters: what it blocks, which row waits
Options: what he would see change under each, and its cost
My recommendation: the option and why
```

After the turn it comes up, it is a short title on the one `Waiting on you` line of each standup; the full report repeats the card
of each question still open. A question he already answered (docs, skills, the record, his earlier prompts) is
never asked.

## What the hook checks

- A heading is matched only as a heading line, a line holding nothing but the heading; a heading named inside a
  sentence is not one.
- A standup (first line `Working on:`, bold or not) has 3 to 6 lines and at most one line starting
  `Waiting on you:`.
- A full report (a heading line `## What changed`) has a heading line `## How to QA`, and each `### ` card under
  the heading line `## Questions for you` carries `Why it matters` and `My recommendation`; a Questions section
  holding only `None.` passes, and leaving the section out is the shape.
- Fenced code blocks are skipped by the shape checks: an example of a report inside a fence is not a report.
- Any message: no em dash and no en dash, fenced code blocks included.
- A message in neither shape passes: an answer is not an update.
- The hook stays quiet on a turn that changed no files, and blocks the same change set once.

## Retired

By his 10-26 words: the old three-heading report with a completion percent (10-14) and the percent with the
estimated time left on every update (10-21). Kept: his status words Pending, Develop, QA, Ready for review for
the ticket list under `## Following`, and "number: plain name" in the order he approved.

## The rules that hold everywhere, report or not

- No em dash, no en dash. Anywhere. Full stop, comma or colon instead.
- Never his name or his prompts inside code comments.
- Never "done" for anything visual without his verdict.
