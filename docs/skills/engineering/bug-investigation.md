# bug-investigation

| | |
|---|---|
| Type | engineering |
| Scope | global (every repo) |
| Source | [`skills/global/bug-investigation/SKILL.md`](../../../skills/global/bug-investigation/SKILL.md), version 3.0.2 |
| Run by | the backend, frontend or QA player |

## What it is for

Takes a bug he reports from symptom to a root cause named as file and line, a fix at that root, and a proof it
is fixed (SKILL.md lines 13 to 14).

## When to use it, and when not

Use it for a bug he reports or QA finds (wrong data, broken screen, a feature that does nothing), "still
broken" after a fix, and two systems that should agree and do not (lines 18 to 22).

Do not use it to write the test for the fix (testing-standard) or to review code with no failing behaviour
(review) (lines 24 to 27).

## Who runs it and its place in orchestration

The builder at step 6 for a bug ticket, QA at step 9 for anything it finds (lines 15 to 16). The skill map row
"bug" adds it to the cast ([`skill-map.md`](../../../skills/global/orchestration/references/skill-map.md)).

## Pipeline, short (lines 70 to 81)

1. Read the screenshot and his words; write the symptom in his terms.
2. Reproduce through the real entry point with his inputs.
3. Locate by measuring: curl both sides, select both rows; when two systems disagree, build the table of `references/field-by-field.md`.
4. Search by the property he saw, not a guessed name.
5. Trace both ends: where the value is written and read; name every caller.
6. Instrument the decision when the cause is still hidden.
7. State the root cause as file:line and one sentence; print the deciding fact.
8. Fix the root; the bug is the test scenario when the mode wants a test.
9. Fix every place with the same shape.
10. Validate the way he will: the real page or endpoint, in his environment.

## Scripts

None; `references/field-by-field.md` holds the comparison table.

## Key laws (lines 37 to 46)

1. Never dismiss and never disown a failure. 2. Run every non-destructive command without asking.
3. Never blame the tester. 4. Read his screenshot first. 5. Reproduce before theorising.
6. Measure, do not recall. 7. Prove the root cause before the fix. 8. Instrument the decision.
9. When he has named the cause, ship the fix. 10. Fix every place with the same shape.

## Handoffs

- The test for the fix: testing-standard, in the batch's mode.
- A push of the fix: ship.

## Best practices, from its Gotchas (lines 85 to 96)

- When he still sees the bug after a local fix, check the running build and his record.
- His word names a look, not a label: "white flowers" were the river banks. Sweep by the property.
- Curl the endpoint; reading a frontend file is not reading the API.
- Dump the keys of one record before trusting an empty probe.
- From WSL, reproduce a browser issue from Windows with `powershell.exe Invoke-WebRequest`.
- Two ruled out causes means a new instrument: log the decision per item once.
- Describe each element of a screenshot and have him confirm.

## Red flags (lines 50 to 59)

"That failure was already there", "Probably a cache issue", "I could not reproduce it", "The probe found
nothing, so no gap", "I think the cause is X, fixing".

## Evals

Trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
scenarios B1 to B3 in the Evals section (lines 142 to 150), prompts in `scenarios.py`.
