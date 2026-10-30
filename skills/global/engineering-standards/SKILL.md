---
name: engineering-standards
description: Code written to his senior bar while it is written, in any repo, guard clauses as function clauses with no else block, dispatch maps, SOLID, one owner per fact, reuse first, the optimal version first, explicit errors, no dead code, comments that explain code, Tailwind first, the repo gates at exit 0, and the frontend rules in references/frontend.md. Run by every builder; enforced by the director at orchestration row Dc. Use when he says "clean code", "guard clauses", "no nested ifs", "SOLID principles", "ui development", "frontend code", "write it properly". Do NOT use for reviewing a diff (review) or writing tests (testing-standard).
metadata:
  author: Alexander Pulido
  version: 3.2.0
  triggers: ["clean code", "guard clause*", "no nested ifs", "nested if", "solid principles", "refactor", "credo", "coding standards", "write it properly", "this is messy", "ui development", "frontend code", "architect*", "component tree", "how will components be built", "avoid duplication", "duplicated code", "duplicated logic", "business logic", "business code", "state machine", "user flow*", "sequence diagram", "owning context", "not up to standard", "the spec has no architecture", "node version", "wrong node", "nvm", "asdf", "mise", "tool-versions", "unexpected token", "eslint can't load", "corrupt file header", "set up the project", "get it running locally", "run the dev server", "won't compile", "install deps"]
  sources: the PR review framework in the private workspace, section 2; retired memories guard-clauses-in-elixir, comments-explain-code-not-prompts, always-write-the-optimal-version, feedback_coding_standards, feedback_styling_tailwind, prefer-tailwind-not-inline-css, feedback_reuse_dont_rebuild, a-value-invented-in-react-has-no-control, backend-data-not-at-module-scope; a project memory on the admin file upload
---

# Engineering standards

The bar every line of code meets the first time he reads it, in any repo: flat control flow, one owner per
fact, reuse before rebuilding, the repo's gates at exit 0. Global: the backend, frontend and architect players
write to it, and the director rejects a diff below it at orchestration row Dc (law 7).

## When to use

- Any code a player writes or refactors, backend or frontend, in every project.
- The architect shaping contracts and the component tree (`references/frontend.md`).

## When not to use

- Reviewing a diff someone already wrote: review.
- Writing or running tests: testing-standard.
- How a screen looks and which control fits a choice: ui.

## Stance

- **You write the final version now.** There is no "tidy later" pass.
- **The repo's standards doc wins** over this skill where they differ; you read it before the first line.
- **You decide alone** names, helper splits and where a dispatch map goes; log each as a DECISION in your report.
- **You never decide** to mute a gate, add a field he did not ask for, or keep a frontend copy of a backend value.

## Non-negotiables

1. **No `else` block; guards first, happy path last.** Why: nested for loops and if/else blocks read as poor code to him; a guard clause or a second function clause covers nearly every case, so an `else` block is almost never needed. → `references/patterns.md` (nesting depth, the Elixir clause, `with`)
2. **A value that picks behaviour picks it through a dispatch map or function heads;** a new member is a new entry, never an edited chain. Why: the Open-Closed Principle of SOLID (Robert C. Martin), "Entities should remain open for extension but closed for modification"; an edited chain breaks the members that already worked. → `references/patterns.md`
3. **One reason to change per unit (SRP);** a unit that both decides and performs, or fetches and formats, is split. Why: every change follows the repo's code standard and SOLID; a unit with two reasons to change breaks when either one moves. → `references/patterns.md` SOLID and structure (DIP, ISP, LSP, composition, pure functions, names)
4. **Reuse before rebuilding:** grep the verb and the noun of the job first (`upload`, `photo`), as well as the screen's name; a hit sends the work into the flow and the screen the grep found, and a new resource, route, field or migration needs that search, with 0 hits, on the plan's `Reused:` line. Why: a second profile route was added beside the existing one, and a set of new parts was built where moving the existing confirmation step earlier in the flow was the whole job.
5. **One owner per fact:** a limit, label or setting lives in one place, usually the backend; the frontend reads it as `references/frontend.md` says. A task that edits a frontend copy of such a fact writes it on the `Facts:` line with its backend owner; the move is made in the same change when the brief owns the backend file, else the report asks for it. Why: a value hardcoded in the frontend that the backend should own has no admin control and drifts from the backend copy. → `references/frontend.md`
6. **The optimal version on the first pass:** each element touched once, no N+1 (preload, index, batch). Why: the first version is the one that stays; a ring loop that rescanned its growing set every ring had to be rewritten as one directed walk.
7. **Explicit errors:** `:none | {:ok, x} | {:error, r}`, matched at the caller; never `nil` for both "none" and "failed", never a silent rescue. Why: no quote of his; the old global carried it ("Explicit errors. No silent rescue."). → `references/patterns.md`
8. **No dead code:** 0 commented-out code, 0 unused exports, 0 options nobody asked for; `scripts/check-diff.sh` prints `commented-out code: 0`, and the compile with warnings as errors exits 0 (unused functions, variables and imports). An unused export, the inner lines of a multi-line block comment, a commented-out attribute or call with no brackets (`# @impl true`, `# render json: payload`), a prompt comment that opens with a capital (`# User asked for this cap to be 3`), an `else` in a `.mts` file and a limit raised in a lint config (`max_nesting` in `.credo.exs`) pass both, so they are the self-read's job (Pipeline step 6). Why: no quote of his; the old skill carried it ("no dead code, no commented-out code, no unused exports, no speculative options").
9. **Comments explain the code's why;** 0 added lines with his name or a quoted prompt (`scripts/check-diff.sh`). Why: comments carry what the code does, how it works and the context it needs; 666 lines across 247 files carried his name and his prompts instead.
10. **Tailwind first, ITCSS files for the rest, 0 inline `style` attributes;** a `style` that only sets a CSS variable for a dynamic value is the one exception, the strictly necessary case. Why: Tailwind classes are preferred; inline styles spread through `EventBuy.tsx` where a class on the element did the same job.
11. **The repo's gates exit 0, each finding fixed, never muted;** a disable comment only with his yes in the thread. Why: no quote of his; the old global carried it ("Credo or lint findings are fixed, not muted", "never add a disable comment without his yes"). → `references/stacks.md`
12. **Frontend code follows `references/frontend.md`.** Why: before any UI work, the frontend holds no hardcoded value the backend should own, so admin and game management screens can edit it. → `references/frontend.md`
13. **The toolchain is checked before the code is blamed:** `scripts/toolchain-check.sh <repo>` prints `toolchain: matches` in the shell doing the work, and node tooling runs with the nvm `bin` exported, because non-interactive shells resolve node v10.22.0. Why: the shell resolves an old node while nvm holds the right one, and the error looks like a code bug. → `references/dev-toolchain.md`
14. **Databases and containers are his:** 0 containers started, stopped or recreated, and no `ecto.reset` or `ecto.drop` on an existing dev database. Why: postgres, redis and mysql run in his Docker containers, so a command that assumes a local service fails and a reset destroys his data. → `references/dev-toolchain.md`

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "Elixir has no early return, so `else` is fine here" | Law 1. A second clause with `when`, the value piped in. |
| "Working now, tidy later" | Law 6. The wasteful loop was also the wrong shape (09-14). |
| "I'll keep the comment and note who asked" | Law 9. Keep the technical why, drop the attribution. |
| "A const in the frontend is quicker" | Law 5. It has no control he can edit (roofReveal.ts). |
| "He only asked to change the number" | Law 5. Name the copy and its backend owner on the `Facts:` line. |
| "This needs a new resource, route and field" | Law 4. Search for the flow that already does it. |
| "No admin screen edits this, so I'll add one" | Law 4. Grep the job; the flow and screen it finds take the work. |
| "Credo is noisy, mute it" | Law 11. Credo counts like a failing test. |
| "One inline style for this panel" | Law 10. A Tailwind class on the element you touch. |

## Intake

1. The brief: his words, the files owned, the contract from the architect.
2. The repo's standards doc (find it with `/home/visiond/projects/claude/skills/global/orchestration/references/framework-first.md` and `/home/visiond/projects/claude/skills/global/orchestration/scripts/find-frameworks.sh <repo>`) and 2 to 3 neighbouring files of the area.
3. The repo's gates: `references/stacks.md` and the project skill for that repo (SKILLS.md).

Fixed: his words, the contract, the repo doc, the laws. Free: names, helper splits, dispatch map shape.

## Pipeline

Serves orchestration row D5 (each builder plays) and row Dc (the director reads these lines and the diff).
Each Output is a line in the player's report.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Before the first edit, record `git rev-parse HEAD`; read the repo standards doc and 2 to 3 neighbouring files | `Start:` that sha; `Standards read:` paths | `/home/visiond/projects/claude/skills/global/orchestration/references/framework-first.md` |
| 2 | Reuse search: `grep -rn` the verb and the noun of the job (law 4) | `Reused:` file:line, or `Reused: none, searched <command>`, as the first line of the plan and again in the report | law 4 |
| 3 | Place each fact; a moved or copied fact names the copy and its owner | `Facts:` copy -> owner (column, module attribute, file) | law 5 |
| 4 | Write the code to laws 1, 2, 3 and 7 | the diff | `references/patterns.md`, `references/frontend.md` |
| 5 | `scripts/check-diff.sh <repo> <start sha>` | `check-diff:` total 0, or each kept hit with its reason | laws 1, 8, 9, 10, 11 |
| 6 | Read the diff back with the review lens: a nested branch, a block the diff adds that `grep -rn` also finds elsewhere in the repo, a loop doing work twice | `Self-read:` each finding and its fix | review |
| 7 | Run the repo gates | `Gates:` each command and its exit code | `references/stacks.md` |

A gate that fails 2 times on the same finding after a fix: read the rule's docs, restructure the code, and run
step 7 again. Still failing after the restructure: stop, and put the finding, the rule and the command in the
report for the director. Never add a disable comment without his yes. Do not skip 2, 5 or 7.

Kinds of work the steps route to; each Output is a file or a line of the player's report.

| Trigger | Step | Read | Output |
|---|---|---|---|
| A spec or plan adds a table, an endpoint, a screen or a lifecycle; "how will it be built" | orchestration 2, the architect | `references/software-architecture.md`, `references/software-architecture-evals.md` | `plan.md` with its 7 sections |
| A node, elixir, erlang or ruby version error, or the first local run of a project | orchestration 6, before the first edit | `references/dev-toolchain.md`, `references/dev-toolchain-repo-toolchains.md` | the `scripts/toolchain-check.sh` table and its last line |

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| `if ... do ... else [] end` in `tile_source.ex` | No early return in Elixir read as licence for `else` | Pipe the deciding value into a second clause with `when` | 09-13, his message on the diff |
| 666 lines across 247 files carried his name in comments | Comments opened with his name and a quoted prompt | Keep the technical reason, drop the attribution | 09-13, measured |
| A river crossing blobbed and re-scanned its set every ring | A loop re-iterated the growing set once per ring | One directed walk per cell, stop at the first failing cell | 09-14, his message on the loop |
| A brute did 8 damage instead of 18; `GEAR_CATALOG` rendered an empty bag | Catalogs captured at module scope before the fetch | Read every catalog through a function at render time | 2026-09-08, caught only by a test asserting 18 |
| "I don't see any place to manage or edit it" | 4 `export const` in `engine/render/roofReveal.ts` | Column, serve it, read through a function, then the control | 2026-09-22, retired memory a-value-invented-in-react-has-no-control |
| A parallel upload system (new args, change module, route) built | No search for the existing flow | Reuse the flow and the screens a `grep -rn` of the job finds: the onboarding upload (`photo_grid` and the GCS flow) in the existing `/profile/edit`, where admins manage a user's photos by impersonating, and the existing Event Console (`user_edit_modal`, `demo_sandbox.ex:8758`) | 2026-06-26, a project, memories feedback_reuse_dont_rebuild and project_ashadmin_file_upload |
| Inline styles throughout `app/evento/EventBuy.tsx` | `style={{}}` instead of classes | Tailwind classes on what you touch | 2026-06-24, a site, memory prefer-tailwind-not-inline-css |
| `Unexpected token .` from jest or npx, or `corrupt file header` in `mix test` | node v10 in the shell, or 0-byte beams from a killed compile | Law 13, `scripts/toolchain-check.sh <repo>` and its fix line | `scripts/toolchain-check.sh` prints node 10.22.0 for this shell while the nvm default is 24.15.0 |
| He asks how it will be built or where the architecture is | The plan has a data model and tasks only | The 7 sections of `plan.md`, from step 1 of `references/software-architecture.md` | a spec with no backend or frontend architecture, no duplication plan and no flows was sent back as incomplete |

## Deliverables

- The code on the working branch, inside the files the brief owns.
- In the plan and in the player's report: the `Reused` line, the plan's first line. In the report also: `Start`, `Standards read`, `Facts`, `check-diff`, `Self-read`, `Gates`. Each label starts its own line, as plain text with no bullet, bold or backtick, and its value sits on that line, as in the block below. Filled:

```
Start: 3f2a9c1e (git rev-parse HEAD before the first edit)
Standards read: docs/CODING-STANDARDS.md, lib/app/uploads.ex, lib/app/profiles.ex
Reused: lib/app/uploads.ex:42 photo_grid/2
Facts: max_photos -> settings.max_photos column
check-diff: total: 0
Self-read: lib/app/profiles.ex:88 nested case -> second clause with when
Gates: mix format --check-formatted exit 0; mix compile --warnings-as-errors exit 0; mix credo --strict exit 0
```

## Check it before you show it

1. `scripts/check-diff.sh <repo> <start sha>` prints `total: 0`, or each kept hit is in the report with its reason; a base git cannot resolve exits 2.
2. Each gate in `references/stacks.md` for the stack exits 0 (Elixir: `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix credo --strict`; TypeScript: `npx tsc --noEmit`, `npm run lint`).
3. `git status --porcelain --untracked-files=all` lists only files the brief owns (untracked files included).
4. `scripts/check-report.sh <plan>` and `scripts/check-report.sh <report>` each print `reused:` 1 or more: a file:line reused, or `Reused: none, searched <command>` (law 4).
5. When the change moves or copies a fact, `scripts/check-report.sh <report>` prints `facts:` 1 or more, the copy on the left of `->` and its owner on the right (law 5).

A failing check goes back to pipeline step 4 (checks 4 and 5 to steps 2 and 3); report when checks 1 to 5 pass.

## Critic loop

A separate read-only judge gets his ask, the brief and the diff, never the player's report. Default reject.
It scores 1 to 10 the "a diff" axes of `/home/visiond/projects/claude/skills/global/orchestration/references/critic.md:21`,
plus 4 axes of this skill: control flow (laws 1, 2); ownership and reuse (laws 4, 5); errors and dead code
(laws 7, 8); gates and check-diff at 0. The 3 worst problems with
file:line, the smallest fix each. Below 8 on any axis: back to pipeline step 4, then score again, until every
axis is 8 or more.

## Definition of done

- [ ] 0 `else` blocks added, or each kept one is a `with` that reshapes an error, named in the report.
- [ ] Every value that picks behaviour goes through a dispatch map or function heads.
- [ ] `Reused:` line present (check 4); no new resource, route or field without it.
- [ ] Every new fact has one owner; 0 frontend copies of backend values; a moved or copied fact is on the `Facts:` line (check 5).
- [ ] 0 commented-out code, 0 comments with his name or a prompt, 0 inline styles except a `style` that only sets a CSS variable, 0 muted checks.
- [ ] Every repo gate exits 0.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/patterns.md` guards and nesting, dispatch maps, error shapes, SOLID and structure, comments, with code. Step 4.
- `references/frontend.md` the frontend code rules (frontend player and architect). Step 4.
- `references/stacks.md` gates per stack. Intake item 3 and orchestration row Dc.
- `references/evals.md` trigger queries and behaviour scenarios. `references/canon.txt` lines the lint keeps.
- `scripts/check-report.sh <plan or report>` read only; strips list marks, bold and backticks, then counts, on the label line and the list right under it, a file:line or `none, searched <grep|rg|git grep command>` for `Reused:` and `copy -> owner` (or the arrow sign) with an owner path, module or column for `Facts:` (checks 4 and 5).
- `scripts/check-diff.sh [repo] [start sha]` read only; counts added else blocks, commented-out code, his name or prompts, inline styles, muted checks against the start sha; exit 0 when all are 0, exit 2 on a base git cannot resolve.
- `$CLAUDE_WORKSPACE/_global/PR-REVIEW-FRAMEWORK.md` section 2 (SOLID per principle) and section 4 (bottleneck catalogue).

## Evals

15 trigger queries and 3 behaviour scenarios in `references/evals.md`, numbered, each scenario RED from a
gotcha above: E1 an Elixir branch (RED 09-13 `else` in `tile_source.ex`); E2 a frontend value (RED
`RUIN_MIN_SITE`, a frontend const in the game); E3 an upload feature (RED the parallel upload system). Run
2026-10-25 on claude-sonnet-5-5, 3 runs per arm, the skill loaded in the with arm's system prompt, the same role
line in both (0 MCP tools, 0 skill or memory reads without). On 3.0.5: E1 with 3 of 3 runs pass, without 0 of 3
(the lead is the named `check-diff.sh` only). On 3.0.6: E2 2 of 3 and 0 of 3. On 3.0.8: E3 3 of 3 and
0 of 3; every with run writes a `Reused:` file:line line and plans into the existing `/profile/edit`
flow and `user_edit_modal`; 2 of 3 without runs add a new route, and none writes a `Reused:` line (3.0.7: 1 of 3
and 0 of 3). Available but not
loaded, the with arm opened the skill in 0 of 9 runs. Method, prompts and caveats in `references/evals.md`.
