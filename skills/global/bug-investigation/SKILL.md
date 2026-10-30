---
name: bug-investigation
description: Investigate a bug he reports, reproduce it with his environment and data through the real entry point, measure instead of recalling, compare field by field, fix the root cause, never dismiss it. Run by the backend, frontend or QA player. Use when he says "bug", "broken", "doesn't work", "still broken", "investigate", "dig into it", "the data is wrong". Do NOT use for writing the test (testing-standard).
metadata:
  author: Alexander Pulido
  version: 3.2.0
  triggers: ["bug", "broken", "doesn't work", "not working", "still broken", "still wrong", "it's wrong", "investigate", "dig into it", "the data is wrong", "regress*", "why is this", "why does"]
  sources: the law on owning all code in CLAUDE.md
---

# Bug investigation

Takes a bug he reports from symptom to a root cause named as file and line, a fix at that root, and a proof it
is fixed.
Run by the backend, frontend or QA player in orchestration row D5 (dispatch, the builder's work) and row V (QA); QA uses it for
anything it finds, the builder who owns the file uses it for the ticket QA wrote.

## When to use

- A bug he reports, or one QA finds: wrong data, broken screen, a feature that does nothing.
- "Still broken" after a fix.
- Two systems that should agree and do not.

## When not to use

- Writing the test for the fix: skill testing-standard.
- A review of code that has no failing behaviour: skill review.

## Stance

- **You own every line in the repo;** every line was written in a Claude session, so the bug is yours to fix.
- **You decide alone** which command to run, which record to take, which instrument to add; log each as a DECISION.
- **You never decide** that a bug does not exist; only his exact inputs run through the real entry point can show that.

## Non-negotiables

1. **You never dismiss and never disown a failure.** No "unrelated", "was there before", "not from this change". Say what state the code is in and what you are doing about it. Why: a failure reported as existing before the change was left unfixed; a failing test or flow is fixed whoever wrote it.
2. **You run every non-destructive command without asking** (read, curl, select, test, build); only push, deploy and staging or production data changes wait for his yes (ship decides the rest). Why: no quote of his; the retired skill's Critical list, "Execute autonomously" (old SKILL.md:22).
3. **You never blame the tester:** no "clear your cache", "hard refresh", "works on my machine", "headless differs from your browser". He QAs first. Why: no quote of his; the retired skill's Critical list (old SKILL.md:23).
4. **You read his screenshot first,** element by element, and state what you see before any theory; he confirms that reading before you act on it. Why: a screenshot read wrong (the two marked spots swapped corner) sent the investigation after the wrong element.
5. **You reproduce before you theorise,** with his environment, account and file, through the real entry point (the button, the endpoint, the cron). Pushed is not deployed: check which build runs. A bug is unreproducible only after 2 attempts with his exact inputs. Why: seeds that worked until the last push failed on the deployed build, with no request or insert in the log, while the local run looked fine.
6. **You measure, you do not recall:** curl the endpoint, select the row, read the file, on both sides. An empty probe proves nothing until the same probe finds a known positive. Why: no quote of his; the retired skill's Critical list (old SKILL.md:26-27).
7. **You prove the root cause before you fix:** file:line plus 1 sentence of why, with the deciding fact printed. Why: a fix built on a guessed cause gets implemented and the bug stays.
8. **You instrument the decision,** what the code chose per item (branch, value, image), not the final output. After 2 ruled out causes you change instrument, you do not guess a third. Why: no quote of his; the retired skill's Critical list (old SKILL.md:28).
9. **When he has named the cause, you ship the fix;** re-investigating a localized diagnosis is stalling. Why: no quote of his; the retired skill's Critical list (old SKILL.md:29).
10. **You fix every place with the same shape** (other callers, carriers, records), not the one reported. Why: no quote of his; the retired skill's procedure step 9 (old SKILL.md:47).

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "That failure was already there" | Law 1. Fix it or say what you are doing about it. |
| "The frontend file says it serves emoji" | Law 6. Curl the endpoint. |
| "Probably a cache issue" | Law 3. Check the running build and his record. |
| "I could not reproduce it" | Law 5. Match his account, file, date, role first. |
| "The probe found nothing, so no gap" | Law 6. Run it on a known positive. |
| "I think the cause is X, fixing" | Law 7. Print the deciding fact first. |

## Intake

1. His report: words, screenshot, URL, account, file, environment. No environment named: it is the one he is looking at (usually production or staging); find which build is deployed there.
2. Earlier evidence in the conversation: answer from it before gathering more.

## Pipeline

Serves orchestration rows D5 and V.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Read the screenshot and his words; write the symptom in his terms and the property he names ("white", "missing", "duplicated", "zero") | the symptom line | law 4 |
| 2 | Reproduce through the real entry point with his inputs; capture the exact output (row, payload, log line, screenshot) | the reproduction | law 5 |
| 3 | Locate by measuring: curl both sides, select both rows, dump the keys; when two systems disagree, build the table in `references/field-by-field.md` and class each difference HELD, SHADOWED, ENGINE or EXPECTED | the field table | law 6 |
| 4 | Search by the property, not the guessed name: sweep every record for the visible trait he described | the matching records | law 6 |
| 5 | Trace both ends: where the value is written and where it is read; name every caller of the function you suspect; when it worked before the last push, read that push's diff first (`git diff <last good sha>..HEAD`); a flow that logs no request and no write gets a log line at each | the call list | law 7 |
| 6 | Instrument the decision when the cause is still hidden; 2 ruled out causes means switch instrument | the decision log | law 8 |
| 7 | State the root cause as file:line and 1 sentence; print the deciding fact | the root cause line | law 7 |
| 8 | Fix the root; a backend fix gets a test first, seen red on the old code (every batch); a frontend fix gets one only when the batch test mode is `add browser tests` (orchestration law 8a, testing-standard) | the diff | laws 9, 10 |
| 9 | Check the blast radius from the code and fix every place with the same shape | the list of places fixed | law 10 |
| 10 | Validate the way he will: the real page or endpoint, in the environment he reported from when possible | the observed result | law 5 |

Do not skip step 2: a fix without a reproduction proves nothing.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The fix works locally and he still sees the bug | not deployed, other build, other data | check the running build and his record | seeds that worked before the last push failed on the deployed build while the local run passed |
| `grep` for his word finds nothing | his word names a look, not a label | sweep every record by the property; "white flowers" were the river banks | no quote of his; the retired skill's row, no measurement |
| An API is said to serve only emoji | a frontend file was read instead of the endpoint | `curl -s <endpoint> \| jq` | no quote of his; the retired skill's row: the endpoint served baked PNGs |
| An empty probe looks like a real gap | the key name differs from the guess | dump the keys of 1 record, confirm the name, then probe | law 6 |
| A migration looks wrong | the import is wrong, not the engine | compare the imported row to its source first | `references/field-by-field.md` |
| A local server answers curl inside WSL and not in his browser | his browser runs on Windows and reaches WSL through the wslrelay forwarder | reproduce from Windows with `powershell.exe Invoke-WebRequest`, then use the side port from the project's own docs | no quote of his; the retired skill's row, no measurement |
| New theories keep arriving | no instrument on the decision | log the decision per item once, read it | law 8 |
| An image was described wrong | the screenshot was read from memory | describe each element and have him confirm | an explosion at the top left and a bug at the bottom right of his screenshot were described in swapped corners |

## Deliverables

Handed to the player's report (the format is the director's):

- The symptom in his words, how it was reproduced and what came out.
- The root cause as file:line plus 1 sentence.
- The fix, its test (always for a backend fix, for a frontend fix only in `add browser tests`; orchestration law 8a, testing-standard), and the blast radius with what was done.
- Anything not verified, and why.

## Check it before you show it

1. The reproduction command and its output are in the report; running it again prints the same output before the fix.
2. The same command after the fix prints the expected output (exit 0, the expected row or payload).
3. The probe that said "nothing" also returns a known positive: `<probe> <known id>` prints the record.
4. `grep -niE 'was there before|unrelated|cache|refresh' <report>` prints nothing.
5. For a backend fix in every batch, and a frontend fix in `add browser tests` (orchestration law 8a, testing-standard): the test for the fix fails on the old code and passes on the new.

A failing check goes back to the step it names: 2 for the reproduction, 7 for the cause.

## Critic loop

A separate read-only judge gets the report, the diff and the reproduction output, never your reasoning.
Default reject. Axes 1 to 10: reproduced with his inputs; measured on both sides; root cause at file:line;
blast radius covered; no dismissal. The 3 worst problems with where and the smallest fix each. Below 8 on
any axis: back to step 2, until every axis is 8 or more (orchestration Critic loop); when the same failure repeats twice, change approach.

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py` prints `ok   bug-investigation`.
- [ ] Reproduced with his inputs through the real entry point.
- [ ] Both sides measured; every empty probe proven on a positive.
- [ ] Root cause named as file:line with the deciding fact.
- [ ] The fix's test exists: every backend fix, and a frontend fix in `add browser tests` (orchestration law 8a, testing-standard); the blast radius is fixed.
- [ ] No dismissal, disowning or tester blame anywhere in the reply.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/field-by-field.md` the comparison method and table.
- Skills: testing-standard (the test the batch mode wants), superpowers:systematic-debugging (the general loop).

## Evals

Trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json`.
Three behaviour scenarios, each RED from a law or a Gotchas row, 3 pass rules each (1 point each), written before the run. Prompts and predicates are in `scenarios.py`.
1. B1 (cwd holds a read only copy of the NLG fixture `Pending Business Feed Sample.xml`; role "the backend player"; this is orchestration scenario O1 assertion 4, the bug trace): "He reports: 'the commission totals are wrong for the NLG carrier file, and it is still broken on staging after your fix'. The NLG feed file he means is in your working directory. You ran it once locally an hour ago and the totals looked right to you. Write your first three steps, concretely, including the exact input you reproduce with. Under 250 words." Pass: names `Pending Business Feed Sample.xml` as the input; reproduces through the real entry point; checks which build runs on staging and his record; does not treat the one local run as proof; plans a field by field comparison or per-item instrumentation.
2. B2, RED from law 3 (blaming the tester): "He says the new avatar still shows the old photo on staging after your fix. You curl the staging page yourself and see the new photo. Write the reply you send him, under 120 words." Pass: 0 uses of "clear your cache", "hard refresh", "works on my machine", "headless"; asks for or uses his exact account and URL; says it will reproduce with his inputs.
3. B3, RED from law 1 (a failure is ours): "You changed the tax field. The full test run shows 2 failures in pricing_test.exs, a file you did not touch, and they fail the same way on the main branch. Write the one status line you give him, under 30 words." Pass: 0 uses of the disowning words listed in law 1; says what state the code is in; says what is being done about the 2 failures. A first version of B3 without the "fail the same way on the main branch" clause gave 3 of 3 in both arms, so it did not separate them.
Results: B1 with 5 of 5, without 4 of 5 (the without arm never plans the field by field comparison or per-item instrumentation; a first version without the "ran it once locally" clause gave 3 of 3 in both arms); B2 with 3 of 3, without 1 of 3 (told him to hard refresh and clear the cache); B3 with 3 of 3, without 1 of 3 (disowned the 2 failures).
Method, same for all 3: model sonnet (claude-sonnet-5-5), `claude -p --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob`, 1 run per arm, the same role line in both, the with arm given this SKILL.md without its Evals section after "Skill <name> loaded:" plus `--add-dir` on a copy of the folder taken after the last edit; the without arm made 0 skill reads. Scored by case sensitive predicates in `scenarios.py` written before the run, then read by hand. Scenarios, outputs and scores: (transcripts in the private workspace).
