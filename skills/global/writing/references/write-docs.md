# Write docs, inside writing

Writes the doc a reader who did not build the system uses to understand it, set its values on purpose and
reproduce each example. Run by the player whose brief includes a doc, in orchestration row D5 (dispatch, the builder's work).

## Stance

- **You write for a reader who did not build it,** and the code is the source, never your memory.
- **You decide alone** the Diataxis kinds, the order of sections and which examples to render; log each as a DECISION.
- **You never decide** what a value means or its range; the code and the served rows say.

## Non-negotiables

1. **The first 3 sentences say what the thing is and does,** in plain words; each section opens with its own point. Why: a guide is followed step by step; it has to be easy to follow, compact and built from the current documentation. → `references/write-docs-diataxis.md`
2. **One Diataxis kind per section** (explanation, how-to, reference); a doc holds 2 or 3 kinds, each in its own section. Why: no quote of his; `references/write-docs-diataxis.md`, an explanation never holds step lists.
3. **Every variable gets the same 5 facts:** meaning, unit, range and default, what raising does, what lowering does. Why: a doc of the noise and default methods has to explain each variable (octaves, blocks and the rest) for a reader to set them on purpose. → `references/write-docs-diataxis.md`
4. **A variable that interacts with another names the pair** and the formula line that causes it. Why: a value read alone misleads when sin and perlin change what it does.
5. **Every behaviour that has a look gets a picture rendered by the real code,** values printed beside it, script kept with the repo's render scripts. Why: the reader needs examples that generate specific waves or map formations, and a hand drawn picture is invented.
6. **An example is a recipe:** the goal, the values to type, the picture, 1 line on why those values give that shape. Why: no quote of his; the retired skill's Critical list (old SKILL.md:34-35).
7. **Ranges and defaults are read from the served row or the code,** never typed from memory. Why: no quote of his; the retired skill's Critical list, "never typed from memory" (old SKILL.md:28-30).
8. **The body uses the labels the UI shows;** code names appear only in the last section, "How this was worked out", with code locations, the render script and dated outside sources. Why: no quote of his; the retired skill's Critical list (old SKILL.md:36-39).
9. **A runbook is one set of steps for every environment;** where a value differs, the step names both (**staging:** / **production:**). Why: a runbook split into local to staging and staging to production doubled the steps; production repeats the staging steps.
10. **A runbook reads "do this, set this, run this";** 0 history, 0 design notes. Why: a runbook full of history and design notes hid the few steps that mattered; it is a simple MR like doc.
11. **A release or MR doc is written for a reviewer, an infra dev or a QA tester who has none of our context.** Shape: the MR template (what and why, the changes, how to set it up, how to test). Setup is a tutorial: what you need before you start, then numbered steps where each step says its goal in one plain sentence, gives one command or action, and says what you see when it worked; every term, script and value is named the first time it appears. Setup is written once, for testing (or for localhost when the same steps run on testing), and production is one closing section, "Repeat on production", listing only the values that differ. QA is a list of scenarios, each one a table row: who, what they do, the expected result, with the refused case as its own row. Follow git workflow (MR) guidelines and tutorial fundamentals. Why: an MR doc written as if every reader had our context left reviewers, infra devs and QA asking why each step exists.
12. **Every runbook has 4 sections in this order, like a PR:** `## Description of changes`, `## What was implemented`, `## Setup` (env keys, then the commands to run, each with what you see when it worked), `## QA steps per ticket` (each ticket a bold line with its number and name, then numbered steps with what to expect; a ticket that needs no steps is the bold line and `-> validate <the file, doc or page>`). `scripts/check-runbook.sh <runbook>` prints `runbook: ok`. This format is enforced in every runbook. Why: one PR shape lets a reader find the description, the setup and the QA of any runbook in the same place.

Violating the letter of a law is violating the law.

## Intake

1. His ask for the doc and who reads it (him, a level designer, a player).
2. The code and served data the doc explains: read them whole.
3. The repo's writing guide and render tooling (game-engine: the project's own docs).

Fixed: the 5 facts per variable, answer first. Free: section order, how many examples, picture size.

## Pipeline

Serves orchestration row D5 (dispatch, the builder's work). Each Output is a file in the repo.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | List the reader's questions from his ask: what is it, what does each value do, how do they combine, how do I get shape X | the question list at the top of the player's report | law 1 |
| 2 | Read the code and the served rows for every variable: name, label, unit, range, default; note each interaction in the formula | variable table draft | laws 3, 4, 7 |
| 3 | Outline: answer first; one explanation section per question; the reference table; the how-to recipes; "How this was worked out"; 2 to 6 top sections | outline in the report | law 2 |
| 4 | Write a render script that imports the app's own functions and writes the pictures, plus a strip per variable (same map at 3 or 4 values of that one variable, others fixed); run it; open every picture with Read; drop any example that does not show what it claims | render script, `images/*.png` | law 5 |
| 5 | Write the doc: each picture has a caption with its values; each table at most 8 rows | the doc | laws 1, 6, 8 |
| 6 | Check every number and name against the code or the API, then the text check | check output | the Docs line of SKILL.md Check |
| 7 | Link it where readers look (the docs index, the doc it extends); fix any doc it makes stale | index diff | |

Do not skip step 4: a picture the script did not make is a defect.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The doc reads like the code | written from the functions outward | start from the reader's questions (step 1) and the UI labels | rewrite rule in the retired skill, no measurement |
| A picture does not match what the app makes | the script reimplemented the formula | import the app's own functions | the retired skill's "Critical" list (old SKILL.md:31-33), no measurement |
| A range in the doc differs from the panel | typed from memory | read the served row | the retired skill's "Critical" list (old SKILL.md:28-30), no measurement |
| A runbook with 40000 useless things | history and design notes kept in it | steps only (law 10) | a runbook kept history and design notes no step needed |
| One runbook per hop (local to staging, staging to production) | each hop treated as its own doc | one set of steps with both values named (law 9) | a runbook was written once per hop, doubling the steps |
