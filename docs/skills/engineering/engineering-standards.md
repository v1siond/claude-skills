# engineering-standards

| | |
|---|---|
| Type | engineering |
| Scope | global (every repo) |
| Source | [`skills/global/engineering-standards/SKILL.md`](../../../skills/global/engineering-standards/SKILL.md), version 3.1.0 |
| Run by | every builder (backend, frontend, architect); enforced by the director at orchestration step 7 |

## What it is for

The bar every line of code meets the first time he reads it, in any repo: flat control flow, one owner per
fact, reuse before rebuilding, the repo's gates at exit 0 (SKILL.md lines 13 to 15). Frontend rules live in
`references/frontend.md`; the architecture of a plan in `references/software-architecture.md`.

## When to use it, and when not

Use it for any code a player writes or refactors, backend or frontend, and for the architect shaping contracts
and the component tree (lines 18 to 21).

Do not use it to review a diff someone already wrote (review), to write or run tests (testing-standard), or to
decide how a screen looks (ui) (lines 23 to 27).

## Who runs it and its place in orchestration

Every builder at step 6, the architect at step 2 for `plan.md`. Orchestration law 7 puts it in every brief, the
critic scores against it, and step 7 rejects a diff below it.

## Pipeline, short (lines 82 to 90)

1. Before the first edit, record `git rev-parse HEAD`; read the repo standards doc and 2 to 3 neighbouring files.
2. Reuse search: `grep -rn` the verb and noun of the job; write `Reused:` file:line or `Reused: none, searched <command>`.
3. Place each fact; a copy names its owner (`Facts:` line).
4. Write the code to laws 1, 2, 3 and 7.
5. `scripts/check-diff.sh <repo> <start sha>`: total 0, or each kept hit with its reason.
6. Read the diff back with the review lens (`Self-read:`).
7. Run the repo gates (`Gates:` each command and exit code).

Extra rows: a spec that adds a table, endpoint, screen or lifecycle reads `references/software-architecture.md`;
a node, elixir, erlang or ruby version error reads `references/dev-toolchain.md` (lines 98 to 101).

## Scripts

- `scripts/check-diff.sh <repo> <start sha>`: counts the lines a change adds that break a zero rule (laws 1, 8, 9, 10, 11); read only, untracked files count as added.
- `scripts/check-report.sh <plan or report>`: checks 4 and 5 of the skill on a plan or a player's report.
- `scripts/toolchain-check.sh <repo>`: what the repo pins, what CI uses, what this shell resolves, and the line that fixes it; installs nothing.

## Key laws (lines 38 to 51)

1. No `else` block; guards first, happy path last.
2. A value that picks behaviour picks it through a dispatch map or function heads.
3. One reason to change per unit. 4. Reuse before rebuilding. 5. One owner per fact.
6. The optimal version on the first pass. 7. Explicit errors. 8. No dead code.
9. Comments explain the code's why. 10. Tailwind first, ITCSS for the rest, 0 inline `style`.
11. The repo's gates exit 0, each finding fixed, never muted. 12. Frontend code follows `references/frontend.md`.
13. The toolchain is checked before the code is blamed. 14. Databases and containers are his.

## Handoffs

- Tests: testing-standard. Review of the merged diff: review. Screen design: ui.
- Commits and the push gate: ship.

## Best practices, from its Gotchas (lines 103 to 115)

- In Elixir, pipe the deciding value into a second clause with `when` instead of `if ... else`.
- Keep the technical reason in a comment and drop any attribution to him or a prompt.
- Read catalogs through a function at render time, never captured at module scope before the fetch.
- A tunable value gets a column, is served, read through a function, then gets a control.
- Search for the existing flow before building a parallel one (an upload system was once duplicated).
- `Unexpected token .` or `corrupt file header` means the toolchain: run `toolchain-check.sh`.
- "How will it be built" wants the 7 sections of `plan.md`.

## Red flags (lines 55 to 66)

"Elixir has no early return, so `else` is fine", "Working now, tidy later", "A const in the frontend is
quicker", "This needs a new resource, route and field", "Credo is noisy, mute it".

## Evals

15 trigger queries and scenarios E1 to E3 in
[`references/evals.md`](../../../skills/global/engineering-standards/references/evals.md) (Evals, lines 174 to 185).
