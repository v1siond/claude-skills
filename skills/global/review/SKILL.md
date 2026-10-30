---
name: review
description: "Reviews code, a diff or a branch through 5 lenses: correctness, performance, security, the tests themselves and the spec, every finding with its failing input, file:line, severity and fix. Run by the reviewer. Use when he says \"review this\", \"review the diff\", \"is this secure\", \"n+1\", \"are these tests any good\", \"does it match\". Do NOT use for writing the code a review asks for (engineering-standards)."
metadata:
  author: Alexander Pulido
  version: 2.2.0
  triggers: ["review this", "code review", "review the diff", "review my branch", "review the pr", "review the mr", "look over this", "anything wrong with this", "senior review", "check this code", "look over my", "performance review", "review for performance", "why is this slow", "is this efficient", "n+1", "too many queries", "slow query", "query is slow", "missing index", "optimize this", "optimise this", "review for perf", "it's slow", "security review", "review for security", "is this secure", "check for injection", "sql injection", "injection", "xss", "auth review", "can someone access this", "leaking data", "exposed secrets", "pentest", "owasp", "vulnerab*", "secure", "access other users", "review the tests", "review tests", "are these tests any good", "is this test real", "false positive", "the tests are green but it's broken", "test quality", "would this test fail", "audit the tests", "tests are green", "are these tests testing anything", "would they even fail", "does it follow the spec", "check against the spec", "spec compliance", "is everything in the spec done", "what's missing from the spec", "compare the code to the prd", "gap analysis", "what i asked", "does it match", "to the spec", "did you build what i asked", "every requirement"]
  sources: Trail of Bits spec-to-code-compliance (CC-BY-SA-4.0) for references/spec-compliance-verdicts.md; the five retired skills review-code, review-performance, review-security, review-tests, spec-compliance
---

# Review

Turns what he names (a file, diff, branch, commit, MR, test suite or spec) into a ranked list of findings he can act on without a question, through 5 lenses: code, performance, security, tests, spec. Run by the reviewer player on the merged diff at orchestration row Dc; each finding goes back as a ticket (step 11).

## When to use

- He names code, a diff, a branch, an MR, tests or a spec to review, or asks if something is slow, secure, real or done.
- A ticket's merged diff reaches the reviewer (orchestration row Dc).

## When not to use

- Writing the code a finding asks for: engineering-standards. Writing the tests: testing-standard.
- Feedback he received on his own change: superpowers:receiving-code-review.
- A UI or accessibility audit of a built screen: ui.

## Stance

- **You report, you do not edit.** Each finding becomes a ticket for a builder (`role-cards.md` Reviewer: "Never: edits code").
- **You decide alone** the severity, the order inside one severity and which lenses a request needs; log each as a DECISION line.
- **You never decide** whether a finding is worth fixing; he and the director do.

## Non-negotiables

1. **A finding names the input, attack, cost or requirement that fails; 0 findings is a valid review, said in one line.** Why: a padded review buries the one real defect among style notes, and he spends reading time on lines that need no change.
2. **Each finding has file:line, type or class, severity Critical, High, Medium or Low by consequence, and the fix as code in the file's language.** Why: a finding missing its file:line, its type (bug, security, performance, style, maintainability), its severity or its fix code comes back as a question before anyone can act on it. → each lens reference, Deliverables
3. **A finding is verified before it is reported:** the caller, the guard upstream, the test and the migration are read, and a finding the code already handles goes to a `Dropped:` line. Why: no quote of his; the Gotchas rows on retracted and "missing validation" findings.
4. **The code is ours: a finding never says it came from someone else or from before.** State what is wrong and what fixes it. Why: anything that fails in the reviewed tree is treated as caused by our changes; a finding that points the blame elsewhere gets skipped, and the failure lands in his own test on staging.
5. **The reviewer changes no code.** The one exception is review-tests: a one-line mutation proves a suspect and is restored in the same step. Why: no quote of his; `role-cards.md` Reviewer, "Never: edits code".

Each lens also has laws of its own in its reference (tests: mutate in the main checkout, never a copy; performance: `EXPLAIN ANALYZE` on the test database only; security: a live secret is never printed; spec: six verdicts). Read that reference whole before the pass.

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "Consider adding more comments" / "great use of pattern matching" | Law 1. No failure named; drop it. |
| "That was already there" | Law 4. State the defect and the fix. |
| "It looks like it could fail" | Law 3. Open the caller; if the guard is upstream, drop it. |
| "This might be slow" / "I'll add a cache" | Count rows, queries, calls (performance law 1); find the precise computation first (law 2). |
| "`EXPLAIN ANALYZE` on dev is quicker" | Performance law 3. Test database, or `EXPLAIN` alone. |
| "No validation in the controller" | Security law 2. Read the changeset first. |
| "I will paste the key so he sees it" | Security law 6. Mask it, say rotate. |
| "It reads fine, it must work" | Tests law 2. Break the line and run it. |
| "The expected value matches" | Tests law 3. Check whether a fallback gives the same value. |
| "The function name says it does this" | Spec law 1. Read the body and find the test or run. |
| "I'll fix it while I am here" | Law 5. Report it; a builder gets the ticket. |

## Intake

Target X, resolved to concrete code by the table in `references/review-code.md` Intake (path, `git diff`, branch, commit, `gh pr diff`, `glab mr diff`); nothing named: the working tree diff, said in the report. The spec lens also needs the spec file and his later corrections. Fixed: the finding shape. Free: the order of the passes.

## Pipeline

Serves orchestration row Dc. Each Output is a section of the lens file `<workspace>/score/<ticket>/review-<lens>.md` (no ticket: the reply).

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Code review: a file, diff, branch, commit or MR, "review this", "senior review" | `review-code.md`: `Reviewed:`, `Standards:`, `Candidates:`, `Dropped:`, findings most severe first | `references/review-code.md`, `references/review-code-what-counts.md` |
| 2 | Performance: a query, loop or render path, "why is this slow", "n+1", "missing index" | `review-performance.md`: `Hot paths:`, `Cost:` as a number, `Dropped:`, findings | `references/review-performance.md`, `references/review-performance-patterns.md` |
| 3 | Security: an endpoint, MR or config, "is this secure", "injection", "owasp" | `review-security.md`: `Entry points:`, `Checked:` per class, `Audit:`, findings | `references/review-security.md`, `references/review-security-checklist.md` |
| 4 | Tests: green tests next to a live defect, "are these tests any good", "false positive" | `review-tests.md`: `Claims:`, `Suspects:`, `Proof:` per suspect, the line `tests reviewed: N, proven able to fail: M, could not: K` | `references/review-tests.md`, `references/review-tests-false-positive-patterns.md` |
| 5 | Spec: "does it match", "what's missing from the spec", "every requirement" | `spec-compliance.md`: `R<n>` rows, `Refuted:`, `Reverse:` | `references/spec-compliance.md`, `references/spec-compliance-verdicts.md` |

A request that names 2 or more lenses runs each in its own file. A review he asks for over the whole branch reads the full branch diff from its fork point (Intake `my branch`). When he asks to loop, each round of fixes is reviewed again as a new diff until a round ends with 0 findings. Findings are posted as PR or MR comments on their file:line (`gh pr review`, `glab mr note`) only when he asks for comments. Do not skip the `Dropped:` pass (lenses 1 to 3), the `Proof:` run (lens 4) or the refutation and reverse passes (lens 5).

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The review is long and mostly Low | Style nits counted as findings | Keep a Low only when its Why names the line a reader misreads | the retired review-code troubleshooting, no measurement |
| He says a finding is wrong | It was not traced to a caller | Retract it in the first sentence, re-verify the others the same way | the retired review-code troubleshooting, no measurement |
| Findings are all micro | No hot path identified | Start from what runs per request or per frame | the retired review-performance troubleshooting, no measurement |
| The index suggestion already exists | The migration was not read | Grep `create index` for the table first | the retired review-performance troubleshooting, no measurement |
| Many "missing validation" findings | The input is validated in the changeset, not the controller | Read the changeset before reporting | the retired review-security troubleshooting, no measurement |
| Staging breaks on a GraphQL failure after "all pass" | Tests never exercised the schema | Drive the real caller and assert the behaviour | a change shipped with every test green while its GraphQL schema was never updated; the first query on staging failed |
| A fallback value passes the test | Expected value equals what the fallback returns | Assert the row, tile or call exists first | testing-standard Gotchas, the `groundAt` fallback |
| A full CRUD was asked and only create shipped | The requirement was read as "events" and the edit path never searched | One requirement per verb and per resource, each with its own pass | full CRUD for every resource was marked done; the first edit tried on the next day had no edit option |
| The spec contradicts what he asked later | He corrected it in conversation | His later words win; mark the requirement amended | the retired spec-compliance troubleshooting, no measurement |

## Deliverables

- One file per lens in `<workspace>/score/<ticket>/` (no ticket: the reply): `review-code.md`, `review-performance.md`, `review-security.md`, `review-tests.md`, `spec-compliance.md`.
- Findings as `### n. <title>` blocks with the lines `File:`, the type or class, `Severity:` and `Fix:`; filled examples and the severity scale per lens sit in each reference under Deliverables.
- The last line of a lens file: files reviewed and the count of findings per severity (tests lens: the `tests reviewed:` line; spec lens: the reply `<met>/<total> met. Worst gaps:` and up to 5 lines).

## Check it before you show it

Run the lens's lines on its file; every count pair must be equal and every `prints 0` must print 0.

- Code: `grep -c '^### ' review-code.md`, `grep -cE '^- File: [^ ]+:[0-9]+' review-code.md` and `grep -c '^- Fix:' review-code.md` print 3 equal counts (0 findings: all 0 and one line says so); `grep -ciE 'pre-?exist|n[o]t mine|already there|consider ' review-code.md` prints 0.
- Performance: `grep -c '^### ' review-performance.md`, `grep -cE '^- Cost: .*[0-9].*(measured|estimated)' review-performance.md` and `grep -c '^- Proof:' review-performance.md` print 3 equal counts; `grep -iE 'EXPLAIN ANALYZE' review-performance.md | grep -vci 'test database'` prints 0.
- Security: `grep -c '^### ' review-security.md`, `grep -c '^- Attack:' review-security.md` and `grep -c '^- Fix:' review-security.md` print 3 equal counts; `grep -nE 'AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|sk_live_[0-9a-zA-Z]+|eyJ[A-Za-z0-9_-]{20,}\.' review-security.md` prints nothing.
- Tests: `grep -c '^### ' review-tests.md` equals `grep -c '^- Proof:' review-tests.md`; `grep -c '^tests reviewed:' review-tests.md` prints 1; `git status --porcelain` prints the same lines as before the first mutation.
- Spec: `grep -c '^R[0-9]' spec-compliance.md` equals the requirements extracted; `grep -c '^  refutation:' spec-compliance.md` equals the rows whose verdict is not `implemented`; `grep -c '^  verdict: absent' spec-compliance.md` is at most `grep -c '^  searched:' spec-compliance.md`.
- All: `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>` prints no FAIL line.

A failing check goes back to the lens's step that wrote the line (code, performance and tests: step 4 of its reference; security: step 6; spec: step 3); when the same failure repeats twice, change the approach. Show it when every row passes.

## Critic loop

A separate read-only judge gets his ask, the target and the lens file, never the reviewer's reasoning. Default reject. It scores 1 to 10: findings are real (each names its failing input, attack, cost or requirement); verified (a `Dropped:` or `Refuted:` line exists and the caller was opened); fixes are code that fits the file; severity matches the consequence table of the lens; no padding; the lens's own axes (tests: every finding proven by a run; security: all 3 classes per entry point). It names the 3 worst problems with file:line and the smallest fix each. Below 8 on any axis: back to the lens's step above, score again, until every axis is 8 or more (orchestration Critic loop).

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py` prints `ok   review`.
- [ ] Each lens file passes its Check rows (equal counts, 0 where a row says 0).
- [ ] Every finding has file:line, type, severity, why and fix code; every candidate dropped has its `Dropped:` line.
- [ ] 0 files in the reviewed code changed by this review (tests lens: `git status --porcelain` unchanged).
- [ ] check-text prints no FAIL.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/review-code.md`, `references/review-code-what-counts.md`, `references/review-code-evals.md`: code lens.
- `references/review-performance.md`, `references/review-performance-patterns.md`, `references/review-performance-evals.md`: performance lens.
- `references/review-security.md`, `references/review-security-checklist.md`, `references/review-security-evals.md`: security lens.
- `references/review-tests.md`, `references/review-tests-false-positive-patterns.md`, `references/review-tests-evals.md`: tests lens.
- `references/spec-compliance.md`, `references/spec-compliance-verdicts.md`, `references/spec-compliance-evals.md`: spec lens (CC-BY-SA-4.0, Trail of Bits).
- Skills: orchestration (step 7 and 11), engineering-standards (the bar a finding is measured against), testing-standard (the test mode), writing (check-text.sh).

## Evals

28 trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `review`), each checked with the router. 3 behaviour scenarios, each RED from a law or Gotchas row, pass rules written before the run, in the evals files: E1 code, `references/review-code-evals.md` S1 (RED: `String.to_atom/1` on a param, padding); E2 security, `references/review-security-evals.md` S1 (RED: law 6, a live secret printed); E3 tests, `references/review-tests-evals.md` S1 (RED: the degenerate oracle).
Run 2026-10-25 on the merged SKILL.md (2.0.0) and claude-sonnet-5-5, 1 run per arm, the method of `references/review-code-evals.md` (SKILL.md text appended after `Skill review loaded:`, `--add-dir` to a copy, same role line, the reviewer, 0 skill reads without), answers read by hand against the pass rules: E1 with 4 of 4 rules, without 2 of 4 (A3: finding 3 has no code block; A4: a test-coverage comment is padding); E2 with 4 of 4, without 3 of 4 (A4: names "line 11", not `config/runtime.exs:11`); E3 with 4 of 4, without 2 of 4 (A2: no proof step; A4: no `tests reviewed:` line). Runs passing every rule: with 3 of 3, without 0 of 3. Transcripts: (transcripts in the private workspace).
