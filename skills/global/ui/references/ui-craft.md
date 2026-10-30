# UI craft, inside ui

Builds a screen that reads as part of the product: the right control for each choice, grouped and ordered the way
the work flows, labelled in his words, showing its current state at a glance, simple to scan, and no control that
exists only because the backend has a field. Run by the frontend player for every page, panel or control it builds,
in the builder's lane after orchestration row D5 (dispatch), with engineering-standards for the code.

## Stance

- **You design before you code,** and you build the whole frontend part of the ticket.
- **You decide alone** the control for each choice, the grouping and the copy.
- **You never decide** a visual element the kit lacks; it becomes a kit row first, then you use it (law 2).

## Non-negotiables

1. **No "test the backend" UI.** A field per column, a vertical list of checkboxes with line breaks, raw keys, a bare select for two options is scaffolding. Why: the minimum that covers a feature leaves a screen that only exercises the backend; every frontend part is tailored to the design and is usable, clean, intuitive, organized and simple. → `references/ui-craft-controls.md`
2. **The repo's control kit and classes win.** Read its UI doc before choosing any control; no kit in the repo: use `references/ui-craft-controls.md` and write the kit into the repo's UI doc. Why: no quote of his; the old skill's kit line.
3. **Design before code, two sketches:** ASCII wireframes of two layouts for the section, each scored against the checklist; build the better one. If either is what you would make for any app, revise it. Why: a layout listed and grouped by the data shape put the options a user plays with first (art style, generate) at the bottom of the sidebar.
4. **One scroll per window.** A long pick list or picture grid that belongs to a row opens in the repo's movable window. Why: a list scrolling inside a scrolling panel on the tileset mappings screen was unusable.
5. **State at a glance:** a collapsed or summary line says what is set; a changed value can go back (reset); defaults are obvious. Why: a preset named meadow or meadow + river tells a new user nothing until a hint or summary line says what it sets.
6. **His words on screen, never codes:** labels are the player word, sentence case, no trailing colon, verbs for actions, 3 words or fewer. Why: no quote of his; the old skill's labels line.
7. **The quality floor is measured, and the repo's kit wins where it sets its own numbers.** The floor's items are checklist line 6. Why: no quote of his; the old skill's quality floor.
8. **Contrast is AAA on every app and site:** 7 to 1 for text, 3 to 1 for non-text, measured on the render with ui (its measure.md reference). Why: he set AAA as the compliance level for every app and site.

Violating the letter of a law is violating the law.

## Intake

1. The ticket and his words; what the user is trying to do in that section, in one sentence.
2. The project's brand file, read first when it exists: `$CLAUDE_WORKSPACE/<project>/brand.md` (colours as hex with their source, fonts, logos, never rules).
3. The repo's UI doc and control kit, and the neighbouring sections of the same panel (match them).
4. The served data the section shows (its ranges, labels, hints come from the backend, never invented).

Fixed: the checklist. Free: the layout and the copy.

## Pipeline

Serves the builder's lane after orchestration row D5 (dispatch). Each Output goes in the ticket folder `<workspace>/score/<ticket>/`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Write the section's job in one sentence and the order the user decides things in | `Job:` line | law 1 |
| 2 | For each choice, name its kind (one of few, one of many, on/off, several of few, ranged number, count, ordered list) and take the control from the kit | `Controls:` table | `references/ui-craft-controls.md` |
| 3 | Sketch two layouts in ASCII; score each against the checklist; keep the better and note why | `Sketches:` with the chosen one marked | law 3 |
| 4 | Build with the repo's classes and components; values, ranges, labels and hints come from served data (a missing range or label is a backend column, built in the same ticket) | the section | law 2 |
| 5 | Write the copy: labels, the one line hint under a choice that says what the lit option does, a summary line, empty and error states | copy in the section | law 6 |
| 6 | Typecheck and lint; read the component once more against the checklist and fix what fails; whether to click through or test it follows the batch test mode (testing-standard) | one `- [x] (n)` line per checklist line, and one `Contrast: <ratio> text <pair>` or `Contrast-nontext: <ratio> <pair>` line per pair, measured on the render | laws 7, 8 |
| 7 | Record what the section now looks like, one plain sentence per control | the report lines | Deliverables |

Do not skip 3.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| He calls it "test UI" or "bare minimum" | One control per field, no grouping, no state line | Steps 1 to 3 again, from the user's job | a layers section built as a vertical list of checkboxes with line breaks was rejected as UI made to test the backend |
| A value has no sensible slider range | The range is not served | Add min and max to the row that owns the value, in the same ticket | the skill's own troubleshooting, no measurement |
| Tabbing through the panel shows no ring | The kit has no focus style | One `:focus-visible` rule for every kit control; inside a clipped box use a negative offset | the skill's own troubleshooting, no measurement |
| The section looks unlike its neighbours | New classes | Use the kit's classes | the skill's own troubleshooting, no measurement |
| A list cannot be filtered by its kind | The list was built as a flat dump | A filter by kind on every list of things by kind | the tileset mappings list had no filter by tile type |
| A button opens a window that holds one more button | The first window had nothing of its own | Put the contents in the first window | options in the right sidebar opened a window whose only content was a button to a second window |

## Checklist

Step 6 writes one `- [x] (n) <what was checked>` line per checklist line below, answered yes or the fix made.

Checklist: (1) every control is the kit's control for its kind, no checkbox list, no bare select for 2 to 4; (2) grouped
and ordered the way the work flows, every list of things by kind has a filter by that kind, no window only opens another window; (3) current state readable without clicking, reset where values are tuned;
(4) labels in his words, every control has a tooltip, a disabled one says why; (5) values, ranges and hints served; (6) quality floor: keyboard reachable, visible focus, labels clickable, no colour-only state, no horizontal scroll at the panel's narrowest width, empty and error states written, body text at the repo's base size or larger, 44 px targets, one primary action per section; (7) matches the neighbouring sections; (8) nothing exists only to exercise the backend.
