# review

| | |
|---|---|
| Type | engineering |
| Scope | global (every repo) |
| Source | [`skills/global/review/SKILL.md`](../../../skills/global/review/SKILL.md), version 2.0.0 |
| Run by | the reviewer player |

## What it is for

Turns what he names (a file, diff, branch, commit, MR, test suite or spec) into a ranked list of findings he
can act on without a question, through 5 lenses: code, performance, security, tests, spec (SKILL.md line 13).

## When to use it, and when not

Use it when he names code, a diff, a branch, an MR, tests or a spec to review, or asks if something is slow,
secure, real or done; and when a ticket's merged diff reaches the reviewer at orchestration step 7 (lines 16 to 19).

Do not use it to write the code a finding asks for (engineering-standards) or the tests (testing-standard), for
feedback he received on his own change (superpowers:receiving-code-review), or for a UI audit (ui) (lines 21 to 25).

## Who runs it and its place in orchestration

The reviewer, on the merged diff at step 7; each finding goes back as a ticket at step 11. The router sends a
prompt that says "review" here unless it names a skill (skill-craft) or a screen (ui)
([`harness/hooks/skill-router.py`](../../../harness/hooks/skill-router.py), `review_skill`).

## Pipeline, short: one row per lens (lines 65 to 75)

| Lens | Asked as | Output |
|---|---|---|
| Code | "review this", "senior review" | `review-code.md`: Reviewed, Standards, Candidates, Dropped, findings |
| Performance | "why is this slow", "n+1" | `review-performance.md`: Hot paths, Cost as a number |
| Security | "is this secure", "injection" | `review-security.md`: Entry points, Checked per class |
| Tests | "are these tests any good" | `review-tests.md`: Claims, Suspects, Proof per suspect |
| Spec | "does it match", "every requirement" | `spec-compliance.md`: R rows, Refuted, Reverse |

Each lens has its own reference, prompts and evals file under `references/`.

## Scripts

None; the lenses run on reading and on commands named in each reference.

## Key laws (lines 35 to 39)

1. A finding names the input, attack, cost or requirement that fails; 0 findings is a valid review.
2. Each finding has file:line, type, severity by consequence, and the fix as code.
3. A finding is verified before it is reported.
4. The code is ours: a finding never says it came from someone else or from before.
5. The reviewer changes no code.

## Handoffs

- Findings become tickets at orchestration step 11, built by a player running engineering-standards.
- A finding with a failing behaviour may need bug-investigation.

## Best practices, from its Gotchas (lines 79 to 91)

- Keep a Low only when its Why names the line a reader misreads.
- Trace a finding to its caller before reporting; retract a wrong one in the first sentence.
- Start performance from what runs per request or per frame.
- Grep `create index` for the table before suggesting one.
- Read the changeset before reporting missing validation.
- Drive the real caller; tests that never touched the GraphQL schema passed while staging broke.
- One requirement per verb and per resource: a CRUD ask once shipped only create.
- His later words win over the spec; mark the requirement amended.

## Red flags (lines 45 to 56)

"Consider adding more comments", "That was already there", "It looks like it could fail", "I'll add a cache",
"`EXPLAIN ANALYZE` on dev is quicker", "I will paste the key so he sees it", "It reads fine, it must work".

## Evals

28 trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
behaviour runs per lens in `references/*-evals.md`, method in
[`references/review-code-evals.md`](../../../skills/global/review/references/review-code-evals.md) (Evals, lines 137 to 140).
