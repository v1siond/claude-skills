# Design proposals, inside ui

He picks a design by looking at it. Every design question reaches him as pages he can open, and the one he picks
reaches the app exactly as approved. The frontend or assets player runs it when a ticket needs him to pick between
designs: the pick is the ticket's question to him (orchestration row D3 STOP, step 12), and the port is build work in
the builder's lane after step 6 (dispatch). "Improve the UI" means visual work, not an architecture refactor.

## Stance

- **You render and serve; you do not ask him to judge what he cannot see.**
- **You decide alone** the ideas, the dials and the port.
- **You never decide** to publish a page outside the machine (law 3).

## Non-negotiables

1. **Render, do not describe.** No design plan sent for review, no "which do you prefer, A or B" in prose; plans stay in the workspace and he gets URLs. Why: a plan or a prose comparison gives him nothing to see or approve.
2. **At least 3 proposals that differ on at least 4 dials** (`references/design-proposals-dials.md`: navigation, density, hierarchy, grid, type, colour, depth, imagery, motion, voice), on structure as well as surface; a proposal that keeps another's navigation, section order and density is a variant and does not count. Why: proposals that differ only on surface give him no real advantage to pick between.
3. **Serve locally, publish nowhere.** A random port between 8700 and 9700, bound to 127.0.0.1 (`SERVE_BIND=0.0.0.0` only when he asks for the LAN URL), stopped by itself after 2 hours, with the localhost URL; never Artifacts, Vercel or any external host without his yes. Why: a page pushed to Artifacts without his yes can leak his product pipeline.
4. **Open every proposal yourself at 1440 and 390 px width before sending the URLs,** with body text at 16 px or more. Why: proposals with small text had to be zoomed to 133 percent to be read.
5. **Contrast is AAA and reported:** 7 to 1 for text, 3 to 1 for non-text, the lowest ratio per proposal in the reply. Why: proposals sent without a contrast check missed the AAA level he set.
6. **The approved mockup is a contract.** It is saved verbatim, the port copies its markup and then adapts, and every difference is listed and fixed, never eyeballed away. Why: an approved design was once built as something else; the port copies the approved screen exactly, section by section, then the backend is built for it.
7. **A round is for a new screen or a big change;** a tweak edits the app (and the approved HTML when one exists). Proposals are prototypes with no tests, checkers or screenshot sweeps; the port is tested and compared. Why: no quote of his; the old skill line on prototypes.
8. **Theme the presentation, not the content, and keep it clear:** labels and copy stay plain and accurate; a visual change must add impact without costing clarity. Why: one round lacked impact and the next traded clarity for visual changes that added nothing; both were sent back.

Violating the letter of a law is violating the law.

## Intake

1. What the page is for, who uses it, and any reference images or links he shared (record them with orchestration; a reference is saved, not remembered).
2. The current page, if one exists: screenshot it; it sits beside each proposal.
3. The project's brand file, read first: `$CLAUDE_WORKSPACE/<project>/brand.md` (colours as hex with their source file and line, never sampled from a screenshot; fonts and their files; logo paths; five never rules; ASK ME where the repo does not say). None yet: write it from the repo tokens in this round.

Fixed: the dials and the reply shape. Free: the ideas.

## Pipeline

Serves orchestration rows D3 and D7 (the pick); the port runs in the builder's lane after step 6 (dispatch).

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Read the project's design docs (orchestration) and the current page; save his references into the workspace; per reference write two lines in the design folder: TAKE (structure, rhythm, the one idea) and LEAVE (its content, logos, copy, and its colours unless he said so) | `TAKE` and `LEAVE` lines | Intake |
| 2 | Write the proposals as self-contained HTML in `$CLAUDE_WORKSPACE/<project>/designs/<date>-<topic>/`, named `a-<idea>.html`, `b-<idea>.html`, `c-<idea>.html`, each with real content from the app, responsive, a top note naming its idea in one line; the index lists them in order of work as `<number or letter> - <Title>`; write `<dir>/dials.md` with one line per pair, `a-b: <dial>, <dial>, <dial>, <dial>` (the differing dials, names from `references/design-proposals-dials.md`) | the files, `dials.md` | law 2 |
| 2b | A feature added to a page that already exists works through the page's own elements (its controls, its hint, its menus, its scene, its footer): no new section, strip, rail, band or overlay over content and no content moved, unless he asks for one; each top note names the existing element it uses | the element named in each top note | Gotchas |
| 3 | For a redesign, add `current.png` and show it beside each proposal (two columns on desktop, stacked on phone) | `current.png` | Intake |
| 4 | Open each page at 1440 and 390 widths (a Playwright screenshot, saved as `<dir>/shots/<proposal>-1440.png` and `<proposal>-390.png`); fix anything broken | the screenshots | law 4 |
| 5 | Run `scripts/contrast.py <fg> <bg> ...` on each proposal's text and background pairs | lowest ratio per proposal | law 5 |
| 6 | Run `scripts/serve-proposals.sh <dir>`; it writes an index if missing and prints the URLs and PID | URLs, PID | law 3 |
| 7 | Send the reply in the Deliverables shape; leave the server running for his review | the reply | Deliverables |
| 8 | When he picks one, follow `references/design-proposals-porting.md`; when he asks for changes, edit the files on the same server and URLs | the port | law 6 |
| 9 | When the round is over: `kill <pid>` | server stopped | |

Do not skip 4 or 5. No free port after the script's 20 tries, or the server dies: read `<dir>/.server.log`, fix the cause once, then report the exact error.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| He cannot open the localhost URL from Windows | The server stopped, or WSL2 localhost forwarding is off | Check the server is up (`.server.log`); on WSL2 Windows reaches a 127.0.0.1 listener through localhost forwarding, so the bind stays 127.0.0.1; `SERVE_BIND=0.0.0.0` only when he asks for the LAN URL | the skill's own troubleshooting, no measurement |
| The three proposals look alike | One layout with three palettes | Run the two-proposal test in `references/design-proposals-dials.md` and rework the weaker one | three proposals were rejected because none had a real advantage over the others |
| The port drifts from the mockup | Rewritten instead of copied | Copy the approved markup, then adapt | an approved proposal was built as something other than the approved design |
| The proposal index is in the wrong order | Files named without the order of work | `<number or letter> - <Title>` | the proposal index listed the pages out of the order of work |
| He rejects every proposal as invasive | Each added a section, strip or rail that broke the page flow | Step 2b: use the page's own elements, move no content | three proposals that each added a left rail, an in-page section or a top strip were all rejected as breaking the page flow |
| The redesign looks more animated but reads worse | Visual change without a clarity check | Compare section by section with the previous version for clarity before sending | a redesign traded clarity for visual changes that added nothing |

## Deliverables

The reply, plus the files in the design folder:

```
Three proposals, open: http://localhost:<port>/
a. <idea>, <one line on what it changes>. Contrast <lowest ratio>, AAA pass
b. ...
c. ...
Server pid <pid>, stays up until you pick.
```
