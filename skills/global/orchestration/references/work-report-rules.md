# Report rules that came from game-engine

General rules first written in the retired skill game-engine-report. They hold in every project.

## Updates at a checkpoint, no percent and no ETA

- A standup only at a checkpoint and a full report when work stops (`references/work-report.md` laws 1 to 3). A blocker on one ticket means move to the next, and the standup says what blocks.
- Retired by the 10-26 report redesign: the progress update at every collect with a percent and the estimated time left (set 10-21).

## Only the batch he drives, in his names

- Only the batch he is driving. A leftover from older work (a saved patch, a parked ticket) never rides in the batch; it goes to the handoff.
- One ticket per line with its full name, written "number: plain name"; the ticket file ID (A1, M2) stays in the file and never appears in the report (`references/work-report.md` law 8).
- Why: spec task numbers beside his ticket names made the list unreadable.

## A design question comes with a rendered visual

- A design question comes with a rendered visual or not at all. He cannot judge what he cannot see.
- A decision that is his is a question card (`references/work-report.md` law 4): what the thing is in plain terms and how it looks today, why it matters, what visibly changes under each option and its cost, the recommendation.
- Why: a "my call" line with no context leaves him nothing to answer from.

## A doc he reads never goes on Artifacts without his yes

- A doc he must read never goes on Artifacts or any outside service without his yes. Where a spec, plan or note lives (the workspace or the repo) is `references/memory-and-handoff.md` law 1 and `references/memory-and-handoff-where-things-go.md`; this page does not decide it.
- Why: a doc published to Artifacts without his yes exposed his product pipeline.

## A diagram is mermaid

- A diagram in a report or a doc he reads is a mermaid block that parses under mermaid-cli (skill writing, `references/write-spec.md` law 6) with its rendered SVG path beside it for the preview, never ASCII art.

## Leave out the tickets he called DONE

- Rows he already validated (DONE) are left out of every list. When he asks for the full ticket list (under `## Following`), it holds every open row of the record, each status checked in the code; never only the batch at the bottom.
- Why: validated tickets in a list hide the open ones.

## Plain words, checked against what he sees

- What he will see ("flat-roof buildings now have a boxy roof"), not function names, file paths or codes. Technical detail goes in the handoff.
- Check the report line by line against his sentences and against what he can see in the app. A thing that exists only in the test database is not built.
- Why: function names, paths and codes made the reports confusing to him.
