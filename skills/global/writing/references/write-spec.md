# Write spec, inside writing

Writes the spec a reader understands in 5 minutes from its summary and diagrams, the client recognises as
their problem, and a builder codes from without asking. Run by the architect or director in orchestration
step 2 (spec and plan), before his yes and before the briefs of step 4. The technical design is the architect's `plan.md`
(skill engineering-standards), beside the spec and not part of it.

## Stance

- **You write for the client and the builder,** in the product's words.
- **You decide alone** the section content within the template, the number of diagrams and the mockup layout; log each as a DECISION.
- **You never decide** scope, an exclusion or a business rule; those are his or the client's.

## Non-negotiables

1. **A spec is the high level WHAT, never the code side:** description, requirements, scenarios, expected input and output, visual proposal. 0 tables, fields, backend functions, callables, architecture diagrams, component trees, file paths or code identifiers. Why: a spec that held the full breakdown of the code side was too technical for the client and duplicated `plan.md`.
2. **Every screen has a visual proposal:** an HTML mockup per screen in `proposta/` next to the spec, built with the app's real look (skill ui for the mockups, ui for the controls), rendered to PNG and embedded in the feature, plus the demo screenshot when the screen exists. Every PNG is opened before it is linked. A project whose skill says its built app is the visual proposal links opened screenshots of it instead (the project's own docs say which). Why: a text-only spec left the client unable to see what gets built.
3. **Every source is read whole before writing:** the client's documents, every repo doc the feature touches (`docs/` guides, access control, architecture), the old specs and the demo screens, each to the last line. Every requirement names its source. Why: a spec written from a partial read of the client's docs had to be redone.
4. **The spec follows `references/write-spec-template.md`, section by section, in that order.** No section invented, none skipped; a section with nothing to say says "None". Why: a spec with its own invented structure read as unclear and was redone from a real spec format.
5. **Process notes never enter a spec:** no read list, coverage table, "his words" dump, skills followed, lanes, waves, task order, gates, review rounds, decision history, file:line citations, agent findings or "status: built on branch X". They live in the workspace score (ORCHESTRA.md) or the plan. Why: process notes buried the requirements of the first spec.
6. **Diagrams are mermaid, never ASCII art, and show the user's view:** 1 flow of the whole journey, 1 user flow per feature with more than 2 steps, 1 state diagram for what the user sees change state. No ER, no sequence through backend functions. Each block parses under mermaid-cli. Why: a spec with no diagrams left the client reading every line to see the flow.
7. **The summary's first sentence is the client's goal;** the problem section quotes the client in their language. His instructions are decisions in the Decisions table, one line each. Why: no quote of his; the retired skill's Critical list, "Lead with the client" (old SKILL.md:52-54).
8. **Behaviours, not wishes:** per feature, who, trigger, inputs, what the system does, what the user sees, every error and its message. The actor is named in every sentence, rules are affirmative, and "large", "fast", "many" become a number. Each business rule has 2 examples (applies, does not apply). Why: no quote of his; the retired skill's Critical list (old SKILL.md:55-57), from the mindstudio spec guide in `references/write-spec-sources.md`.
9. **Scope lists what is NOT built in this release,** 1 line each. Why: no quote of his; the retired skill's Critical list (old SKILL.md:58), from the zoom proposal guide in `references/write-spec-sources.md`.
10. **Length is what a builder needs:** about 4 to 10 pages per feature area; a longer spec is split by feature area, each self contained, under a 1 page index spec. Why: no quote of his; the retired skill's Critical list (old SKILL.md:61-62).

Violating the letter of a law is violating the law.

## Intake

1. The client's request and documents, his decisions, the demo or app screens that show the feature.
2. The current spec or notes, for content only, never their structure.
3. The project language and UI labels (the project's own docs name them); voice per skill writing.

Fixed: the template order, mermaid, the visual proposal. Free: the feature split, the number of mockups per screen.

## Pipeline

Serves orchestration row D3 (spec and plan). Output goes to the project workspace `specs/<date>-<slug>/spec.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Collect the facts: the client's documents, every doc the feature touches, his decisions, what exists today, checked against the frontend and backend features and routes (route, screen, callable, real side and demo); a demo screenshot per existing screen. The check lands in the spec itself (its "today" text and a code appendix), never in a separate validation file; a change to a feature that exists is written as an enhancement of it, never as a replacement | the facts, each with its source, inside the spec | law 3 |
| 2 | Build the visual proposal: 1 HTML mockup per screen in `proposta/`, render each to PNG, open each; render again after every HTML edit | `proposta/*.html`, `proposta/*.png` | law 2 |
| 3 | Copy `references/write-spec-template.md`; fill the summary last, after the features | the spec draft | laws 4, 7 |
| 4 | Draw the diagrams in mermaid; run `npx -y @mermaid-js/mermaid-cli -i <block>.mmd -o <out>.svg` per block (node 22); fix every parse error | blocks that parse | law 6 |
| 5 | Walk the Spec line of SKILL.md Check; run writing's `check-text.sh` on the file | check output | |
| 6 | Hand him the path; nothing is published or sent without his yes | the path in the report | |

Do not skip step 2: a spec without its pictures is the defect he named twice.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| He says the spec is unclear or full of useless stuff | process notes and transcripts in the spec | move them to ORCHESTRA.md, rebuild from the template | the first spec held process notes and read as unclear |
| "Too technical", "that's not part of a spec" | data model, functions or architecture in the spec | move them to `plan.md`; keep what the user does and sees | the second spec held the full breakdown of the code side |
| "It's missing visual proposal" | text only | step 2 | the spec had no mockup of any screen |
| "There are no diagrams" | ASCII sketches in code blocks | mermaid, validated | the spec had ASCII sketches and no diagram |
| A builder asks what happens when X fails | happy path only | the feature's Errors rows and the Edge cases table | the template's Errors rows and section 8, Edge cases |
| He asks what a new mechanism in the spec is | the spec invented one next to what the app does | find how the app does it today, describe the change against that | the sources rule, no measurement |
| A PNG shows an old screen | HTML edited, PNG not rendered again | `find proposta -newer <png> -name '*.html'` prints nothing | step 2 |
| `playwright screenshot` hangs | WSL has no GPU | launch Chromium with `--disable-gpu` from a Playwright script | the retired skill's WSL note, no measurement |
