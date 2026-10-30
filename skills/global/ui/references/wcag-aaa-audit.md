# WCAG 2.2 AAA audit, inside ui

Produces a conformance report for the scope at Level AAA: every one of the 86 WCAG 2.2 success criteria carries a
verdict (pass, fail, not applicable, not tested) with its evidence, every fail has `file:line`, severity and a fix,
and the report says plainly which criteria a machine checked and which a person must still check. Run by the QA or
reviewer player on a built screen, at orchestration row V (verify); "run a few audits of the UI" runs this skill
and its sibling ui in one verify wave. Each fail goes back as a ticket (step 11).

## Stance

- **You audit; you change no code** unless he asks.
- **You decide alone** the sample, the viewports and the severity of each fail.
- **You never decide** that a manual criterion passes without a manual check (law 2).

## Non-negotiables

1. **AAA on every app and site, all 86 criteria, A and AA included.** The table in `references/wcag-aaa-audit-criteria.md` is the checklist; no criterion is skipped silently. Why: he set AAA as the compliance level for every app and site, and AAA includes A and AA. → `references/wcag-aaa-audit-criteria.md`
2. **A scanner is not an audit.** axe covers a fraction (its AAA rules are few: `color-contrast-enhanced`, `identical-links-same-purpose`, `meta-refresh-no-exceptions`). Each criterion's method column says auto, measure or manual; a manual one with no manual check is "not tested", never "pass". Why: no quote of his; `references/wcag-aaa-audit-criteria.md`, method column.
3. **Measure the render, not the CSS** for contrast, target size and focus appearance (`references/wcag-aaa-audit-measure.md`). Text drawn on a canvas is measured from pixels. Why: no quote of his; Gotchas row 2 (contrast passes in CSS, fails on screen).
4. **A canvas is one widget to scanners;** everything inside it is checked by hand: keyboard ways to do every action done on the canvas, a text equivalent for what is selected, single pointer alternatives to drags. Why: no quote of his; `references/wcag-aaa-audit-criteria.md`, the canvas rows.
5. **Audit, not fix:** inside a ticket each fail becomes a ticket on the score; fixes are built with ui. Severity: critical (a person cannot do the task), serious (very hard), moderate (harder), minor; the director maps them to the ticket's scale. Why: he asks for audits of the UI as a separate pass from the build; a fix made inside an audit has no ticket and no review.
6. **Real screens on sandbox data,** never the dev database; the report goes in the project workspace, never in the repo. Why: no quote of his; the old skill line on real screens.

Violating the letter of a law is violating the law.

## Intake

1. Scope (screens, flows, states) and the supported viewports. Missing: the whole app at its viewports.
2. The repo's UI doc, component kit and key table.
3. A running sandbox server; Playwright and `@axe-core/playwright` from the repo or a scratch folder.

Fixed: the 86 criteria and the report table. Free: the sample beyond the minimum.

## Pipeline

Serves orchestration row V and follows WCAG-EM. Each Output is a section of `report.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Scope: the screens, the states (empty, filled, error, modal, selection) and the viewports | `Scope:` | Intake |
| 2 | Explore: key tasks, components (from the kit), technologies (canvas, live regions, media, timers, auth) | `Explore:` | Intake |
| 3 | Sample: one page per region and state plus every distinct component, and a random 2 more | `Sample:` | Intake |
| 4a | axe with tags `wcag2a wcag2aa wcag2aaa wcag21a wcag21aa wcag22aa best-practice`; map each node to the component source (`file:line`) | axe results | law 2 |
| 4b | Measurements: text contrast 7 to 1 (4.5 large) light and dark, non-text 3 to 1, target size 44 px, focus appearance, reflow at 320 px, text spacing, 200 percent zoom | measured numbers, one line each: `Contrast: <ratio> <pair> <theme>`, `Target: <px> <control>`, `Focus: <ratio> <control>` | `references/wcag-aaa-audit-measure.md` |
| 4c | Keyboard pass: tab through everything, every action without a pointer (2.1.3 has no exception), no trap, visible focus never covered, character key shortcuts can be turned off or remapped | keyboard notes | law 4 |
| 4d | Screen reader pass: names, roles, states of every kit control, live status messages, headings | reader notes | law 2 |
| 4e | Manual criteria left in the table (timing, motion, flashes, language, help, errors, authentication); a large sample is split across players by the director | manual notes | `references/wcag-aaa-audit-criteria.md` |
| 5 | Report: the table of all 86, fails first, then the summary | `report.md` | Deliverables |

Do not skip 4b or 4c.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| axe says 0 violations and the report says pass | Auto coverage taken for conformance | Fill the manual rows or mark them not tested | the skill's own troubleshooting, no measurement |
| Contrast passes in CSS, fails on screen | Opacity, gradients, text over a canvas | Measure pixels (`references/wcag-aaa-audit-measure.md`) | the skill's own troubleshooting, no measurement |
| A fail cannot be traced to code | The axe selector points at generated markup | Find the component by its accessible name or class with grep in the source | the skill's own troubleshooting, no measurement |
