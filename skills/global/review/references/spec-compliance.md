# Spec compliance, inside review

Gives him a list he can trust of which spec requirements the code meets, which it misses and how badly, where every
verdict was earned by reading the code and every mismatch survived an attempt to disprove it. Run by the reviewer
player on the integrated tree, at orchestration row Dc; each finding goes back as a ticket (step 11). How many
reviewers and who refutes is the director's cast.

## Stance

- **You read and report; you change nothing in the code.**
- **You decide alone** how to split a compound requirement and which verdict the evidence earns.
- **You never decide** that a spec line is stale; his later words decide, and you mark the requirement amended (law 5).

## Non-negotiables

1. **One pass per requirement, one of six verdicts, each with evidence** (`references/spec-compliance-verdicts.md`). A combined skim rests on a promising function name; "absent" carries the full searched record. Why: a requirement for full CRUD was marked done on a skim and the edit action did not exist; each requirement needs its own validation. → `references/spec-compliance-verdicts.md`
2. **Every non-implemented finding gets one attempt to find the code path that satisfies it before it is reported;** the refuted ones are listed with the reason. Why: a feature reported done was built differently from what he asked, and that was found only when he used it.
3. **The reverse direction is checked:** behaviour in the code that no requirement mentions is a finding. Why: a request to reduce the roof rows to 2 came back as a rebuilt building; work he did not request costs money, tokens and time and is thrown away.
4. **Severity is the consequence for the user or the data,** not the size of the fix: Critical, High, Medium, Low as in `references/spec-compliance-verdicts.md`. Why: no quote of his; `references/spec-compliance-verdicts.md`, severity table.
5. **When spec and code disagree, his later words win;** the requirement is marked amended and the spec is reported as needing an update. Why: no quote of his; the old skill line on amended requirements.
6. **Run a requirement only where it is cheap and read-only** (an existing test file, a read-only `curl`); a seed, a migration or a write to a shared database is never run to check one, read the code instead. Why: no quote of his; the old skill line on read-only checks.

Violating the letter of a law is violating the law.

## Intake

1. The spec: the file he names, or the ticket's spec in the workspace. Not named: ask once which document is the spec. An approved visual proposal is a spec: every element on it is a requirement, implemented exactly as drawn and checked as functional (it works when used, not only when looked at).
2. The code: the repo, or the diff range the spec covers (`git log --oneline` since the spec date).
3. His later corrections: the conversation and the prompt log, searched for changes to the spec after it was written.

Fixed: the six verdicts and the row shape. Free: the order requirements are read in.

## Pipeline

Serves orchestration row Dc. Each Output is a section of `spec-compliance.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Read the spec in full; extract requirements as a numbered list, one checkable statement each with spec file and line; split "X and Y" into two | `Requirements:` R1 to Rn | Intake |
| 2 | Pull his later corrections; mark each requirement current, amended or dropped, with the source | `Status:` per R | law 5 |
| 3 | For each requirement in its own pass: search the code from the requirement's own words, read the bodies, follow the calls, find the test, run where law 6 allows | evidence per R | law 1 |
| 4 | Assign a verdict and write the row | `R<n>` rows | `references/spec-compliance-verdicts.md` |
| 5 | Refutation pass on every verdict other than implemented | `Refuted:` list with reasons | law 2 |
| 6 | Reverse pass: list routes, settings, tables, limits and side effects in the touched code, flag those no requirement covers | `Reverse:` findings | law 3 |
| 7 | Rank by severity; write the reply | the counts and worst gaps | law 4 |

Do not skip 5 or 6. A requirement whose verdict flips twice between passes is undecidable or partial: record both readings.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Most verdicts are "implemented" after a quick look | Matching names, not behaviour | Read the bodies and find the test or run for each | the skill's own troubleshooting, no measurement |
| The spec contradicts what he asked for later | He corrected it in conversation | His later words win; mark the requirement amended and say the spec needs updating | the skill's own troubleshooting, no measurement |
| Too many requirements for one context | One reviewer holds the whole spec | Group by area and tell the director, who casts more reviewers (orchestration) | the skill's own troubleshooting, no measurement |
| A full CRUD was asked and only create shipped | The requirement was read as "events" and the edit path was never searched | One requirement per verb and per resource, each with its own pass | full CRUD for every resource was marked done; the first edit tried on the next day had no edit option |

## Deliverables

`<workspace>/score/<ticket>/spec-compliance.md` (no ticket: the reply), with a summary line, the requirement rows, the refuted list and the reverse findings, one row per requirement:

```
R<n> <requirement, quoted or one line> (<spec file>:<line>)
  verdict: <one of six>   severity: <level>
  evidence: <file:line read>, <test or run>
  searched: <every grep and file read, with what each returned> (written at step 3 on every absent row)
  refutation: <what was tried to disprove it, and the result>
```

Reply, answer first: `<met>/<total> met. Worst gaps:` then up to 5 plain lines, then the report path.
