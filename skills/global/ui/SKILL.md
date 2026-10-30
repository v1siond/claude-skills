---
name: ui
description: "Designs a screen before it is built, shows him options as rendered proposals, and audits a built screen for usability and AAA accessibility. Run by the frontend, QA and assets players. Use when he says \"not intuitive\", \"make it usable\", \"ui review\", \"is it accessible\", \"show me options\", \"port the mockup\". Do NOT use for the code of the screen (engineering-standards)."
metadata:
  author: Alexander Pulido
  version: 2.1.0
  triggers: ["ui", "ux", "ui design", "ui development", "design this screen", "the ui", "frontend", "front end", "intuitive", "not intuitive", "make it usable", "usable", "clean it up", "looks bad", "looks ugly", "list of checkboxes", "checkbox*", "bare minimum", "test ui", "panel", "layout", "screen", "ui review", "ux review", "ui/ux review", "ui/ux audit", "ux audit", "ui audit", "audit the ui", "design review", "design critique", "heuristic review", "review the panel", "review the screen", "review the ui", "how is the ux", "how intuitive is it", "run a few audits of the ui", "wcag", "wacg", "aaa", "accessibility", "accessible", "a11y", "accessibility audit", "a11y audit", "is it accessible", "contrast check", "keyboard only", "screen reader", "show me options", "mockup*", "mock-up*", "proposals", "design options", "give me designs", "how would it look", "make it look better", "improve the ui", "port the mockup", "i can't see it", "redesign", "landing page", "three different looks", "different look*", "i picked", "port it"]
  sources: WCAG 2.2 and WCAG-EM; Nielsen's 10 heuristics; the interface rules of Vercel's guidelines (references/ui-design-review-code-rules.md); the four retired skills ui-craft, ui-design-review, wcag-aaa-audit, design-proposals
---

# UI

Four kinds of screen work: design a screen before it is built (ui-craft), judge a built screen for UI and UX (ui-design-review), audit it for WCAG 2.2 AAA (wcag-aaa-audit), and show him design options as rendered pages, then port the pick (design-proposals). Run by the frontend player (design, port), the QA or reviewer player (audits, orchestration row V) and the assets player (proposals).
The outcome: he picks every new design from rendered pages, every built screen uses the kit's control for each choice, and every audit row carries a measured or manual piece of evidence.

## When to use

- A page, panel or control is being built or changed, or he says the UI is not intuitive, looks like test UI or is the bare minimum.
- A built screen, flow or app he wants judged for UI, UX or accessibility.
- A new screen or a big visual change where he should choose between directions, or he picked a proposal.

## When not to use

- The code of the screen (classes, components, typecheck): engineering-standards.
- Whether a ticket gets tests and click-through: testing-standard.
- A code review of a diff: review.

## Stance

- **You design before you code, and you audit without fixing:** the builder builds, the auditor files tickets.
- **You decide alone** the control for each choice, the grouping, the copy, the viewports, the sample, the ideas and the dials; log each as a DECISION line.
- **You never decide** a visual element the kit lacks (it becomes a kit row first), that a manual criterion passes without a manual check, or to publish a page outside the machine.

## Non-negotiables

1. **Contrast is AAA on every app and site:** 7 to 1 for text, 3 to 1 for non-text, measured on the render, never read from the CSS. Why: a ratio read from the CSS misses opacity, gradients and canvas text, and he set AAA as the compliance level for every app and site. → `references/wcag-aaa-audit-measure.md`
2. **He judges what he can see:** proposals are rendered pages with URLs, audits run on screenshots of the running app on sandbox data (never a dev database); a description or a source read alone is not a result. Why: a described proposal leaves him nothing to see or approve, and a code and visual check misses how the screen behaves in use; a review is a usability test that uses every function to improve the UI and the UX. → `references/design-proposals.md`, `references/ui-design-review.md`
3. **The screen is judged as an end user, against the repo's control kit:** the kit's control for each kind of choice wins, and a control that is not the kit's control for its kind is a finding even when it works. Why: a screen listed and grouped by the data shape puts the controls a new user reaches for first at the bottom. → `references/ui-craft-controls.md`
4. **No "test the backend" UI:** a field per column, a vertical list of checkboxes, raw keys or a bare select for 2 options is scaffolding. Why: the minimum that covers a feature leaves a screen that only exercises the backend; every frontend part is tailored to the design, usable, organized and simple. → `references/ui-craft.md`
5. **An audit changes no code; each finding goes back as a ticket (orchestration row F).** Why: he asks for audits of the UI as a separate pass from the build; a fix made inside an audit has no ticket and no review. → `references/wcag-aaa-audit.md`, `references/ui-design-review.md`
6. **Nothing is published outside the machine:** proposals are served on a random port between 8700 and 9700, never Artifacts, Vercel or another host. Why: a page pushed to an external host without his yes can leak his product pipeline. → `references/design-proposals.md`

Each kind has laws of its own in its reference (craft: two sketches, one scroll per window, state at a glance; review: P0 to P3 by the user's task, nothing lost; wcag: all 86 criteria, a scanner is not an audit; proposals: 4 dials apart, the approved mockup is a contract). Read that reference whole before the work.

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "One checkbox per field, it covers the feature" | Law 4. Start from the user's job, not the data shape. |
| "The CSS colour is dark enough" | Law 1. Measure the pixels on the render. |
| "axe found 0 violations, so it passes" | Wcag law 2. Fill the manual rows or mark them not tested. |
| "The code looks fine, no need to run it" | Law 2. Open it in a browser and use it. |
| "It works, so the control is fine" | Law 3. Compare it with the kit's control for that choice. |
| "I will just fix this one" / "I will fix the contrast while I am here" | Law 5. Report it; the ticket carries the fix. |
| "I will describe the options and ask" | Law 2. Render them and send URLs. |
| "Same layout, three palettes" | Proposals law 2. That is one proposal. |
| "Artifacts is quicker to share" | Law 6. Serve it locally. |
| "I will rewrite it in the app's components" | Proposals law 6. Copy the approved markup first. |
| "The list scrolls inside the panel" | Craft law 4. It opens in the movable window. |

## Intake

1. Craft: the ticket and his words, the user's job in one sentence, `$CLAUDE_WORKSPACE/<project>/brand.md` when it exists, the repo's UI doc and control kit, and the served data the section shows.
2. Review and wcag: the scope (missing: the whole app, region by region), the repo's UI doc and function list, a running server on sandbox data, the viewports, the key tasks (3 to 6).
3. Proposals: what the page is for, his references, the current page (screenshot it), the brand file (none yet: write it from the repo tokens in this round).

Fixed: the checklists, the 86 criteria, the dials. Free: the layout, the copy, the sample beyond the minimum, the ideas.

## Pipeline

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Design a section, builder's lane after orchestration row D5: job line, controls from the kit, two ASCII sketches scored, build, copy | `<workspace>/score/<ticket>/ui-craft.md`: `Job:`, `Controls:`, `Sketches:`, one `- [x] (n)` line per checklist line, `Contrast:` lines | `references/ui-craft.md`, `references/ui-craft-controls.md` |
| 2 | UI and UX review of a built screen, orchestration row V: screenshots, 10 heuristics 0 to 4, code rules, merge, re-check P0 and P1 | `<workspace>/score/<ticket>/ui-design-review/report.md` with `Rechecked:` | `references/ui-design-review.md`, `references/ui-design-review-rubric.md`, `references/ui-design-review-code-rules.md` |
| 3 | WCAG 2.2 AAA audit, orchestration row V: axe, render measurements, keyboard and screen reader passes, the 86 criteria | `<workspace>/score/<ticket>/wcag-aaa-audit/report.md` | `references/wcag-aaa-audit.md`, `references/wcag-aaa-audit-criteria.md`, `references/wcag-aaa-audit-measure.md` |
| 4 | Design options, a ticket's question to him (orchestration rows D3 and D7), then the port after step 6 | 3 or more `a-<idea>.html` pages, `dials.md`, `shots/`, the reply with URLs and the server pid | `references/design-proposals.md`, `references/design-proposals-dials.md`, `references/design-proposals-porting.md` |

"Run a few audits of the UI" runs rows 2 and 3 in one verify wave. Do not skip the two sketches (row 1), the render measurements and the keyboard pass (row 3), the screenshots and the re-check (row 2), or the 1440 and 390 px screenshots and the contrast run (row 4).

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| He calls it "test UI" or "bare minimum" | One control per field, no grouping, no state line | Steps 1 to 3 of the craft reference again, from the user's job | a layers section built as a vertical list of checkboxes with line breaks was rejected as UI made to test the backend |
| A list cannot be filtered by its kind | The list was built as a flat dump | A filter by kind on every list of things by kind | the tileset mappings list had no filter by tile type |
| A button opens a window that holds one more button | The first window had nothing of its own | Put the contents in the first window | options in the right sidebar opened a window whose only content was a button to a second window |
| The mockup or screen lost functions | Only surface components were read | Check each function-list row on the built screen | a redesign was planned without first using each panel and button, so functions went missing |
| axe says 0 violations and the report says pass | Auto coverage taken for conformance | Fill the manual rows or mark them not tested | the retired wcag-aaa-audit troubleshooting, no measurement |
| Contrast passes in CSS, fails on screen | Opacity, gradients, text over a canvas | Measure pixels (`references/wcag-aaa-audit-measure.md`) | the retired wcag-aaa-audit troubleshooting, no measurement |
| The three proposals look alike | One layout with three palettes | Run the two-proposal test in `references/design-proposals-dials.md` and rework the weaker one | three proposals were rejected because none had a real advantage over the others |
| The port drifts from the mockup | Rewritten instead of copied | Copy the approved markup, then adapt | an approved proposal was built as something other than the approved design |
| The redesign looks more animated but reads worse | Visual change without a clarity check | Compare section by section with the previous version for clarity before sending | a redesign traded clarity for visual changes that added nothing |

## Deliverables

- Craft: the section built to the kit and `ui-craft.md` (job line, two sketches with the chosen one marked, the controls table, the checklist walked).
- Review: `report.md` outside the repo: method line, health table, 3 to 5 priority issues, all findings `| P | Rule | Where | What | Fix |`, what works, personas. Standalone: `<workspace>/audits/<date>-ui-<scope>/`.
- Wcag: `report.md` outside the repo: scope and method, summary and conformance statement, fails `| Severity | SC | Where | What | Fix |`, all 86 rows as `| SC | Level | Verdict | Evidence |`, not tested. Standalone: `<workspace>/audits/<date>-wcag-<scope>/`.
- Proposals: the design folder `$CLAUDE_WORKSPACE/<project>/designs/<date>-<topic>/` and the reply shape in `references/design-proposals.md` Deliverables.

## Check it before you show it

- Craft: `grep -c '^- \[x\]' ui-craft.md` prints 8; `grep -E '^Contrast: [0-9.]+' ui-craft.md | awk '{if ($2+0<7) n++} END{print n+0}'` prints 0 and `grep -cE '^Contrast: [0-9.]+' ui-craft.md` prints 1 or more; `grep -E '^Contrast-nontext: ?[0-9.]+' ui-craft.md | awk -F': *' '{if ($2+0<3) n++} END{print n+0}'` prints 0; the repo's typecheck and lint exit 0.
- Review: `awk -F'|' '/^\| P[0-3]/ {a=$4; b=$6; gsub(/ /,"",a); gsub(/ /,"",b); if (a==""||b=="") n++} END{print n+0}' report.md` prints 0 (no row without a Where or a Fix); `grep '^Rechecked:' report.md | sed 's/^Rechecked://' | tr ';' '\n' | grep -c '[^[:space:]]'` equals `grep -c '^| P[01]' report.md`; `git status --porcelain | wc -l` in the repo prints the number it printed before the screenshots.
- Wcag: `grep -cE '^\| [1-4]\.[0-9]+\.[0-9]+ ' report.md` prints 86; `grep -E '^\| [1-4]\.[0-9]+\.[0-9]+ ' report.md | grep -ciE 'pass.*manual|manual.*pass'` prints 0 unless the evidence names the manual check run; `grep -cE '^(Contrast|Target|Focus): [0-9.]+' report.md` prints 3 or more (6 or more with light and dark); `git status --porcelain` in the repo shows 0 changed files from the audit.
- Proposals: `ls <dir>/[a-c]-*.html | wc -l` prints 3 or more; `awk -F: '/^[a-z]-[a-z]:/ {n=split($2,d,","); if (n<4 || $2 !~ /navigation|density|hierarchy|grid/) bad++} END{print bad+0}' <dir>/dials.md` prints 0; `ls <dir>/shots/*-1440.png | wc -l` and `ls <dir>/shots/*-390.png | wc -l` each print the number of proposals; `python3 scripts/contrast.py <fg> <bg> ...` prints AAA pass on every pair (7 or more for text, 3 or more for non-text); `grep -cE 'localhost:(8[7-9][0-9]{2}|9[0-6][0-9]{2}|9700)/' reply.txt` and `grep -cE 'http://[0-9.]+:(8[7-9][0-9]{2}|9[0-6][0-9]{2}|9700)/' reply.txt` each print 1 or more (the reply saved as `reply.txt`).
- All: `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>` prints no FAIL line.

The craft checklist (8 lines) is in `references/ui-craft.md` under Checklist. A failing check goes back to the step that wrote the line (craft: step 4 of its reference; review: step 4; wcag: step 4a; proposals: step 2); when the same failure repeats twice, change the approach. Show it when every row of your kind passes.

## Critic loop

A separate read-only judge gets his ask, the sketches or screens or proposal screenshots, and the report, never the builder's or auditor's reasoning. Default reject. It scores 1 to 10 the axes of the kind: craft (right control per choice, grouped by flow, state at a glance, his words on screen, contrast and floor measured, not test UI); review (both lenses run, every finding located with a fix, P0 and P1 re-checked on screen, all viewports and states, house heuristics applied); wcag (86 verdicts with evidence, manual rows checked or not tested, render measurements, keyboard and screen reader passes, canvas by hand); proposals (4 dials apart, structure differs, readable at both widths, AAA reported, nothing published, a port matches the saved mockup region by region). It names the 3 worst problems with file:line and the smallest fix each. Below 8 on any axis: back to the step above, score again, until every axis is 8 or more (orchestration Critic loop).

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py` prints `ok   ui`.
- [ ] Every Check row of the kind passes with the numbers above.
- [ ] 0 values, ranges or labels invented in the frontend; two sketches exist (craft).
- [ ] All viewports and states covered, or each gap named; 0 files changed in the repo by an audit.
- [ ] 3 or more proposals rendered, each pair 4 dials apart, contrast reported, 0 pages published, server pid killed when the round ended; a port lists its side-by-side differences (0 unexplained).
- [ ] check-text prints no FAIL.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/ui-craft.md`, `references/ui-craft-controls.md` (the control for each kind of choice), `references/ui-craft-evals.md`.
- `references/ui-design-review.md`, `references/ui-design-review-rubric.md` (Nielsen 10 with 0 to 4 levels, bands, personas, severity), `references/ui-design-review-code-rules.md` (lens B), `references/ui-design-review-evals.md`.
- `references/wcag-aaa-audit.md`, `references/wcag-aaa-audit-criteria.md` (the 86 criteria), `references/wcag-aaa-audit-measure.md` (Playwright measurements), `references/wcag-aaa-audit-evals.md`.
- `references/design-proposals.md`, `references/design-proposals-dials.md`, `references/design-proposals-porting.md`, `references/design-proposals-evals.md`.
- `scripts/contrast.py` WCAG ratios with AA and AAA verdicts; `scripts/serve-proposals.sh <dir>` serves a folder and prints the URLs and the pid.
- Skills: orchestration (the frontend, QA and assets players), engineering-standards (the code), testing-standard (click-through and test mode), frontend-design:frontend-design (visual direction).

## Evals

24 trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `ui`), each checked with the router. 3 behaviour scenarios, each RED from a Gotchas row, pass rules written before the run, in the evals files: E1 `references/ui-craft-evals.md` S1 (RED: a vertical list of checkboxes, 10-17); E2 `references/design-proposals-evals.md` S1 (RED: proposals that look alike and a description sent, 09-01); E3 `references/wcag-aaa-audit-evals.md` S2 (RED: contrast passes in CSS, fails on screen).
Run 2026-10-25 on the merged SKILL.md (2.0.0) and claude-sonnet-5-5, 1 run per arm, the method of `references/ui-craft-evals.md` (SKILL.md text appended after `Skill ui loaded:`, `--add-dir` to a copy, same role line, 0 skill reads without), answers read by hand against the pass rules: E1 with 4 of 4 rules, without 1 of 4; E2 with 4 of 4, without 0 of 4 (files named option-a-tiers.html, port 8000, no dials, no contrast); E3 with 5 of 5 (B2 borderline: it names the gradient only as a reason other text may fail), without 3 of 5 (B1 and B2: it passes 1.4.6 from the CSS). Runs passing every rule: with 3 of 3, without 0 of 3. Transcripts: `$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/score/merge/G2/scratch/out/ui-E1/`, `ui-E2/`, `ui-E3/`.
