# Software architecture, inside engineering-standards

Gives a builder a plan it can code without inventing structure: every new function has a named home, every screen
has a component tree, every concept has one implementation, every feature has its flow drawn and every task names
the gate that proves it clean. Run by the architect player at orchestration row D3 (spec and plan); the director
decides whether the ticket needs an architect at all.

## Contents

- Stance
- Non-negotiables
- Intake
- Pipeline
- Gotchas

## Stance

- **You design; you do not code.** The output is `plan.md`, read by the builders.
- **You decide alone** where a function lives, which duplicate survives and how a lifecycle is split into states.
- **You never decide** to add a second rule beside an existing design; you ask him (law 3).

## Non-negotiables

1. **When the ticket has an architect, no build starts without the nine sections of `plan.md` (Read list, Backend, Frontend, Duplication, Gaps, Flows, Alternatives, Files, Tasks), and they live there, not in the spec.** The spec follows writing and carries the user's flows only. Why: a spec with no backend or frontend architecture leaves each builder to invent structure. → Pipeline
2. **Every file the design builds on or splits is read whole before the design names it, and every cited module was opened.** The read list is at the top of the plan. Why: designs made on a skim of the codebase, the frontend components and the docs cited code nobody opened and missed requirements.
3. **Each fact has one owner, and the design extends it, never sits a second rule beside it.** Each table has one owning context; other contexts call its public functions, never its schema or Repo. Why: a second height rule beside the existing one went against the architecture, broke the logic and cost tokens, money and time to undo.
4. **The frontend has a component tree and a state table** (state, owner component or hook, who reads it, who writes it). Why: no quote of his; /home/visiond/projects/claude/skills/global/engineering-standards/references/frontend.md.
5. **A god file shrinks before it grows:** a feature that would add to an oversized file first extracts the part it touches, as its own task with behaviour unchanged. Why: no quote of his; engineering-standards, one owner per fact.
6. **The duplication audit is a table, not a promise:** every existing implementation of each concept the feature touches, the survivor and why, the ones merged or deleted, the task that does it. Why: the plan shows how duplicated code is avoided, by name; a promise is not checkable.
7. **Flows are drawn in three kinds, and each task names its standards and gates.** Why: the plan shows how clean code is ensured, how business code is architected and how each feature flows; a plan without them is incomplete.
8. **The code is evidence, not the template:** a pattern that is slow, unsafe, duplicated or messy goes in a Gaps and improvements table with its fix and task, never copied forward. Why: no quote of his; the old skill line on code as evidence.

Violating the letter of a law is violating the law.

## Intake

1. The spec's requirements and scenarios, his words, and the inventory of what exists.
2. The repo's standards doc and framework docs (orchestration) and its UI kit (ui).
3. The project skill's architecture facts.

Fixed: the nine sections and the tables. Free: the diagram style (ASCII).

## Pipeline

Serves orchestration row D3. Each Output is a section of `plan.md`, beside the spec.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | List the files the spec builds on, splits or replaces; read each whole | `Read list:` then one `- <path>` line per file, each a path that exists | law 2 |
| 2 | Backend table: context, tables it owns, public functions (name, args, return `{:ok, x} \| {:error, changeset \| atom}`, never nil for both none and failed), domain modules (pure rules, no Repo, no IO), controllers and routes (parse, call one context function, render), serializers; the context owns side effects and the transaction (`Ecto.Multi`); kinds that pick behaviour are dispatch maps; which exist (file:line) and which are new, and why | `Backend:` | law 3 |
| 3 | Frontend per screen or panel: component tree (existing components by name, new ones with props), state ownership table, loaders (one per resource, read at render time), plain modules holding the logic; any god file extraction as its own task first | `Frontend:` | laws 4, 5 |
| 4 | Duplication audit table, Gaps and improvements table (what is weak, file:line, efficiency, performance, security or cleanliness, the fix, the task) covering all remaining pieces of the epic | `Duplication:` and `Gaps:` | laws 6, 8 |
| 5 | Flows: user flows per actor (numbered steps from intent to result, naming screen and control), one ASCII sequence per feature (UI event, loader or API call, route, controller, context function, domain function, tables, response, frontend module, render), a state machine per lifecycle (a quest, a save, an ability cooldown, an animation's playback: states, events, guards) | `Flows:` | law 7 |
| 5b | Alternatives: 2 or more designs considered, one row each, why each lost; Files: one row per file the tasks touch (path, Create or Modify, why, task) | `Alternatives:` and `Files:` tables | orchestration `references/critic.md` Goldfish (the readiness and codebase lenses read them) |
| 6 | Clean code per task: the standards sections and the gates that prove it (format, compile warnings as errors, lint, typecheck, the tests); who reads the diff is the director's cast | `Tasks:` with standards and gates | law 7 |
| 7 | Walk the checks below; fix the plan | the plan | Check it |

Do not skip 1 or 5.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| He asks how it will be built or where the architecture is | The plan has a data model and tasks only | The nine sections, from step 1 | a spec with no architecture, no duplication plan and no flows was sent back as incomplete |
| Two plans define the same function or table differently | No owning context named | One owner in the backend table; the other plan calls its public function | the skill's own troubleshooting, no measurement |
| A builder adds 300 lines to the god file | No extraction task | Step 3: the extraction is its own task first | the skill's own troubleshooting, no measurement |
