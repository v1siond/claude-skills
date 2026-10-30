# Pre-deploy protocol, inside ship

One table that says, for the tree that is about to ship, whether every gate CI runs is green, so a push
never turns red in the pipeline. The QA player runs it on the integrated tree, before the result is shown
to him and before any push (orchestration). It carries no test mode or approval step of its own.

## Stance: you are QA, the one who says READY or not

- **You decide alone** the gate list (from the repo's CI file), the order and the fix of a red gate.
- **You never decide** a push, tag, deploy, seed or migration: the script refuses them and ship owns them.
- **You never decide** that a red gate is acceptable; the verdict is NOT READY until it is green or its exact cause is named and he accepts it.

## Non-negotiables

1. **The full gate, every time:** format, credo `--strict`, compile `--force --warnings-as-errors`, JS lint, typecheck, the whole test suite and e2e; a subset or "the tests I touched" is not the protocol. Why: format, lint, credo, compile warnings and the full suite are the list he set before any push; a push follows only when all are green. The project's own docs may name a fast-check exception (one project's staging); everything else gets the full gate.
2. **The exact tree that ships is the tree tested:** rerun after any edit, rebase or merge; the script prints the branch, sha and dirty count it tested. Why: a partial run was reported as the protocol, and the tree that shipped was not the tree tested.
3. **The summary line decides, not the exit code:** `mix test` can exit 0 after a compile error in one umbrella app and a jest run can exit 0 with zero suites; the script parses the counts. Why: the old Critical line of this skill.
4. **A suite is never piped through `| tail` or `| head`;** it hides the count and the exit status. Logs go to a file and the file is read. Why: the old Critical line of this skill.
5. **CI's env and toolchain are matched:** `MIX_ENV=test` where CI sets it, the node version CI uses (never the v10 a bare shell resolves), local secrets stripped with `--clean-env` when a test reads them. Why: a push gated with a local env and toolchain failed CI on the compile step.
6. **His standard beats a loose CI:** strict credo even where CI mutes it, and warnings are errors everywhere. Why: his gate list (full suite, credo, mix format, no compile warnings) is stricter than some CI files, and his list is the one that counts.
7. **The script never pushes, tags, deploys, seeds or migrates;** a gate matching its FORBIDDEN pattern is REFUSED. Why: a push ran at the end of a gate run that he had not asked for.
8. **A red gate is fixed, all of it:** read its log, fix it or name the exact cause; "flaky" and "not from this change" are not causes. Why: every failing test is fixed before a push to staging, the ones this change touched and the ones it did not.
9. **A suite past 600 s is reported SLOW and the hang is found,** never "wait longer"; a gate reruns at most twice, then it is investigated. Why: retries never made the suite reliable; a CI that needs reruns to go green hides a real failure.

Violating the letter of a law is violating the law.

## Intake

| Input | Where it comes from |
|---|---|
| repo | the cwd, or the path he names (the main checkout) |
| the gates | the profile in `/home/visiond/projects/claude/skills/global/ship/scripts/pre-deploy.sh` for the repo, from its CI file; each repo's row is in the project's own docs (index: `references/pre-deploy-protocol-repo-gates.md`) |
| toolchain | `.tool-versions`, `mise.toml`, `.nvmrc`, the CI image; skill engineering-standards when it does not resolve |
| deps | already installed; `--install` adds `npm ci`, `yarn`, `mix deps.get` gates |

A dev server: when the work needs one and none is running (`lsof -i :<port>` prints nothing), start it and do not block the task on him; when one is running, use it and never start a second.

Fixed: the gate list per repo and the verdict words. Free: the order of fixes.

## Pipeline

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Say which repo, branch and sha are being gated; if he asked for "staging" or "master", check out nothing yourself, gate what is there and say so | the three facts | law 2 |
| 2 | Preview the gates: `bash /home/visiond/projects/claude/skills/global/ship/scripts/pre-deploy.sh <repo> --list`; the `ci-coverage` gate (`scripts/ci-coverage.py`, added for every repo with a CI file) fails when a CI test or lint step, its flags or its env (`REQUIRE_HEIC=true`, `--warnings-as-errors`, a browser suite after a build step) has no gate, or a job runs on a floating `*-latest` runner; a gap is fixed in the profile or the CI file, never skipped | the gate list, `ci-coverage: ok` in its log | law 1 |
| 3 | Run the whole protocol, in the background for anything with a test suite: `bash /home/visiond/projects/claude/skills/global/ship/scripts/pre-deploy.sh <repo>` (add `--clean-env` when a test reads local secrets, `--install` after a lockfile change); it records a log per gate and prints the table | the table | laws 3, 4, 5 |
| 3b | The push gate: a full run (no `--only` or `--skip`) on a clean tree that prints `verdict: READY` also prints `stamped:`; `scripts/push-gate.sh`, a PreToolUse hook on Bash, blocks every `git push` whose commit has no stamp and prints the command to run. The gates per language are the profiles of `scripts/pre-deploy.sh`: Elixir format, credo --strict, compile with warnings as errors and the full suite; Ruby rubocop and its suite; JavaScript lint, typecheck, tests and build. A repo with no linter of a language lists the gap in the report, never skips the gate | `push-gate.sh --check <repo>` prints `push gate: open` | `scripts/push-gate.sh`, `scripts/pre-deploy.sh` profiles |
| 4 | For every row that is not PASS, open its log (the path is on the logs line) and fix the cause: FAIL = the gate failed, NORUN = a suite never reported, SLOW = over 600 s, MISSING = the tool or node version is not installed, REFUSED = a forbidden command | the fixes | laws 8, 9 |
| 5 | Rerun only the fixed gates with `--only a,b`, then rerun the FULL protocol once at the end; a partial run prints PARTIAL and is never the verdict | the verdict run | law 2 |
| 6 | Report as in the Pre-deploy line of SKILL.md Deliverables; never push from this skill | the table and verdict | law 7 |

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| A push turned red in CI | The pre-deploy protocol was not run in full | Laws 1 and 2 | Seen: a push went out before the full protocol ran and CI failed on the compile step |
| READY and stamped, then CI red and the deploy job never ran | The profile listed fewer gates than CI (no browser suite, no CI env, a floating runner OS under a pinned browser tool) | The `ci-coverage` gate, step 2 | Seen: GitHub Actions went red after a stamped push whose profile ran fewer gates than CI, lint among them |
| `SyntaxError: Unexpected token .` in a node gate | The shell resolved node v10 | The script prepends the CI node version; if it says MISSING, `nvm install <ver>` (engineering-standards) | the v2.1.0 troubleshooting row |
| Lint FAIL with `command not found` (exit 127) | `node_modules` not installed | Rerun with `--install`, or `npm ci` in that directory | the v2.1.0 troubleshooting row |
| Test NORUN in an umbrella | One app did not compile, so it printed no "Finished in" | Open the log, search `CompileError`; run from the umbrella root, never `apps/<app>` | the v2.1.0 troubleshooting row |
| Credo PASS here, the MR shows issues | A different credo config in the CI image | Compare `.credo.exs` on the branch with the one CI checked out | the v2.1.0 troubleshooting row |
| An image was built locally before the push | The protocol was read as a CI imitation | Run the gates only; the image is built where CI builds it | Seen: an image was built locally before a push; CI builds it |
| A CI-style parallel run was added | The protocol was padded | When the suite is green and lint and compile are clean, that is the verdict | Seen: a CI style parallel run was added after a green suite with clean lint and compile |
| A gate passes in CI and fails here, or the reverse | Local env differs from CI (a port, a clean env, a build step) | The trap is in that repo's row of the project's own docs | the v2.1.0 troubleshooting row |
| His :3000 answers 500 on every page | A second next process wrote `.next` in the checkout his dev server uses | The build gate builds from `git archive HEAD` in a temp dir; never `next build` or `next dev` in that checkout | Seen: a second next process in his checkout broke his running dev server |
