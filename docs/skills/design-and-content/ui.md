# ui

| | |
|---|---|
| Type | design and content |
| Scope | global (every repo) |
| Source | [`skills/global/ui/SKILL.md`](../../../skills/global/ui/SKILL.md), version 2.0.2 |
| Run by | the frontend, QA and assets players |

## What it is for

Four kinds of screen work: design a screen before it is built (ui-craft), judge a built screen for UI and UX
(ui-design-review), audit it for WCAG 2.2 AAA (wcag-aaa-audit), and show him design options as rendered pages,
then port the pick (design-proposals) (SKILL.md line 13).

## When to use it, and when not

Use it when a page, panel or control is built or changed, or he says the UI is not intuitive, looks like test
UI or is the bare minimum; when he wants a built screen judged; when he should choose between directions
(lines 16 to 20).

Do not use it for the code of the screen (engineering-standards), for whether a ticket gets tests
(testing-standard), or for a code review (review) (lines 22 to 26).

## Who runs it and its place in orchestration

| Row | Step | Output |
|---|---|---|
| Design a section | builder's lane after step 6 | `score/<ticket>/ui-craft.md` |
| UI and UX review | step 9 | `score/<ticket>/ui-design-review/report.md` |
| WCAG 2.2 AAA audit | step 9 | `score/<ticket>/wcag-aaa-audit/report.md` |
| Design options, then the port | steps 2 and 12, port after 6 | 3 or more `a-<idea>.html` pages, `dials.md`, `shots/` |

Source: Pipeline, lines 71 to 78. The router sends "ui review" and "design review" prompts here
([`skill-router.py`](../../../harness/hooks/skill-router.py), `review_skill`).

## Scripts

- `scripts/contrast.py <fg> <bg> ...`: WCAG contrast ratio per colour pair with AA and AAA verdicts.
- `scripts/serve-proposals.sh <dir>`: serves a folder of HTML proposals on a random high port, reachable from Windows and the LAN.

## Key laws (lines 36 to 41)

1. Contrast is AAA on every app and site.
2. He judges what he can see: render it, send URLs.
3. The screen is judged as an end user, against the repo's control kit.
4. No "test the backend" UI.
5. An audit changes no code; each finding goes back as a ticket (orchestration step 11).
6. Nothing is published outside the machine.

## Handoffs

- The code of the chosen design: engineering-standards with `references/frontend.md`.
- Findings: orchestration step 11 as new tickets.

## Best practices, from its Gotchas (lines 82 to 94)

- "Test UI" or "bare minimum" means start again from the user's job, steps 1 to 3 of the craft reference.
- Every list of things by kind gets a filter by kind.
- A window that holds only one more button should hold the contents itself.
- axe at 0 violations is not conformance; fill the manual rows or mark them not tested.
- Measure contrast on the rendered pixels; opacity and gradients fool the CSS check.
- Three proposals with one layout and three palettes are one proposal.
- Port by copying the approved markup, then adapting.

## Red flags (lines 47 to 58)

"One checkbox per field covers it", "The CSS colour is dark enough", "axe found 0 violations", "I will fix the
contrast while I am here", "I will describe the options and ask", "Same layout, three palettes".

## Evals

24 trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
behaviour runs in `references/ui-craft-evals.md`, `ui-design-review-evals.md`, `wcag-aaa-audit-evals.md`,
`design-proposals-evals.md` (Evals, lines 139 to 142).
