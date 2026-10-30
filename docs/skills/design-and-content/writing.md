# writing

| | |
|---|---|
| Type | design and content |
| Scope | global (every repo) |
| Source | [`skills/global/writing/SKILL.md`](../../../skills/global/writing/SKILL.md), version 2.1.2 |
| Run by | every player whose output he reads or signs |

## What it is for

Turns what he asks to be written into text he can sign without a rewrite: his voice for anything he sends, a
doc a stranger can use, a spec a client recognises and a builder codes from, a CV score a recruiter and a
buyer would both agree with (SKILL.md line 13).

## When to use it, and when not

Use it for text under his name (docs, MR and PR text, release notes, Slack and email drafts, management docs,
replies to review comments), "it sounds AI", docs that explain a system, runbooks, product and feature specs,
and critic passes over CV, portfolio or services copy (lines 16 to 21).

Do not use it for a hook refusing an edit for no approved spec (orchestration law 4), the end-of-work report
(orchestration owns its shape), commit rules (ship), a blog post (blog), checking code against a spec (review),
the architecture (engineering-standards `plan.md`) or a UI audit (ui) (lines 23 to 27).

## Who runs it and its place in orchestration

Any player: step 2 for the spec, step 6 for docs, and every report and commit body. The skill map gives it to
the researcher and to "spec or plan", "docs" and "CV" rows
([`skill-map.md`](../../../skills/global/orchestration/references/skill-map.md)).

## Pipeline, short: one row per kind of text (lines 71 to 76)

| Kind | Output | Reference |
|---|---|---|
| Text he signs or sends | the text, `check-text.sh` clean | `references/his-voice-writing.md` |
| A doc that explains a system, a runbook, an MR doc | the doc, its rendered pictures and render script | `references/write-docs.md` |
| A product or feature spec | `specs/<date>-<slug>/spec.md` and `proposta/` | `references/write-spec.md` |
| A CV, portfolio or services critic pass | the audit, verdict first | `references/cv-content-review.md` |

## Scripts

- `scripts/check-text.sh <file>` (and `--strict`): fails on an em or en dash, distancing phrases or Claude attribution; warns on antithesis and AI filler words (a fail under `--strict`).

## Key laws (lines 37 to 44)

1. No em dash and no en dash, anywhere, ever.
2. No antithesis. 3. Answer first. 4. Plain names, no codes.
5. Every fact, range, number and requirement comes from a source read whole.
6. No attribution of any kind anywhere he signs.
7. Never distance from the code. 8. Nothing is published or sent without his yes.

## Handoffs

- A spec feeds the goldfish lenses at orchestration step 2 and `plan.md` (engineering-standards).
- A blog post: blog. A commit message: ship's voice rules.

## Best practices, from its Gotchas (lines 80 to 93)

- "It sounds AI": run `check-text.sh --strict`, rewrite each hit, vary sentence length, cut the punchlines.
- Write in first person plural, the reader addressed directly.
- A management doc comes Italian first, then Spanish and English.
- A spec holds what the user does and sees; the data model goes in `plan.md`, process notes in `ORCHESTRA.md`.
- Every screen of a spec gets a mockup rendered to PNG and opened.
- A runbook is steps only, one set per environment.
- A runbook, MR or PR text is a .md file in the workspace, never a docs connector doc.
- An MR doc: each step says its goal, one command and what you see.

## Red flags (lines 50 to 61)

"One dash reads better here", "It is a tradeoff, not a flaw", "A short intro first", "I skimmed the docs",
"I will add the data model so the spec is complete", "I will describe the picture in words".

## Evals

Trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
scenarios S1 to S3 scored against [`references/writing-evals.md`](../../../skills/global/writing/references/writing-evals.md)
(Evals, lines 138 to 147).
