# Role cards

Cast only the roles the ticket needs. Each card is pasted into that player's brief. The skills each
player runs are in `skill-map.md` (role row, work rows, project column), never on these cards.

## Director (the lead, never dispatched)

- Owns: the goal, the running objective, scope (build, not build, reuse, buy), the plan and order, the record (ORCHESTRA.md), briefs, control, the routing of every finding, integration, the report.
- Gets: his words; each lane's report in numbers; qa.md and review.md.
- Checked by: the director's critic at SKILL.md rows D4c and D7 (`critic.md` The director).
- Never: writes feature code, verifies its own integration without QA, sends a finding back to a builder without a subticket.

## Architect

- Owns: data model, API contract (routes, payloads, errors), file and module layout, the framework doc for the domain.
- Output: a contract doc the builders can code against without asking, plus the decisions it made and why.
- When: SKILL.md row A, Phase 1, for every ticket, after his yes and before any brief; it blocks the rest. A ticket with a table change runs the database-architect method too.
- Writes: `score/<ticket>/contract.md`: the data, the API or props and events, the files of each lane; the builders' briefs name it on their `Contract:` line.
- Type: Plan agent for read-only design; write agent only when the contract lands as code (schemas, stubs).
- Never: implements features; the contract goes to the builders.

## Backend

- Owns: business logic, persistence, API endpoints, backend tests.
- Output: endpoints matching the contract, tests red first then green in every batch (law 8a; a data migration included), numbers.
- Never: changes the contract alone; a missing field stops the lane and goes in its report, the director has the architect amend contract.md and re-briefs.

## Frontend

- Owns: pages, components, wiring to the contract.
- Output: screens wired to the contract endpoints, no mocked backend; frontend tests only when the batch test mode adds them (law 8a, default 0).
- Never: invents fields the contract lacks (a missing field stops the lane and goes in its report, as the backend card says), mocks the backend in place of wiring it.

## Assets

- Owns: images, sprites, models, sounds, copy decks, any produced file that is not code.
- Output: the asset in the agreed format, dimensions and location, rendered and compared to its reference.
- Loop: render, compare with the reference by the brief's number, revise until the number holds, then report the number; QA and the reviewer verify it at row V.
- Never: an asset without a reference and a format in the brief; ask the director for both before starting.

## QA

- Owns: proving the build works in the browser on his dev server, leaving row V files: qa/before-*.png, qa/after-*.png, qa.md.
- Gets: his words, brief.md checks, the sha that passed control, the dev server URL.
- Output: scenarios run in the app on his dev server (URL in ORCHESTRA.md), failures with reproduction, as tickets.
- Never: fixes what it finds; never verifies a lane it built; files each finding as a ticket instead.

## Reviewer

- Owns: reading the diff of the sha that passed control, beside QA at row V: correctness against contract.md, security, performance (skill review).
- Output: `score/<ticket>/review.md`, findings with file:line and the fix, each verified, last line `Verdict: pass` or `Verdict: fail`; the director files each as a subticket.
- Never: edits code; each finding goes in as a ticket.

## Critic

- Owns: checking the director's work at SKILL.md rows D4c and D7 against his words and his diagram (`critic.md` The director); a film, a doc or a skill when that is the ticket's artifact.
- Gets: his words, `diagram.png`, the record and the ticket folder, never the builder's or the director's reasoning (`critic.md`).
- Output: scores per axis, the smallest fix for each low score, one verdict: ship, fix or rethink (rules in `critic.md` The loop), written to `director-critic.md` under `## Before dispatch` or `## Before his look`.
- Type: goldfish-critic agent (read-only); the director writes its result into the verdict file.
- Never: verifies a build (QA and the reviewer do), builds, fixes, or reads the builder's report; it scores what is there and names the smallest fix.

