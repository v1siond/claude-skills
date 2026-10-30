# Evals for writing

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `writing`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not. The router miss that put this skill on a hook refusing an edit for "no approved spec" is row T1.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | the hook keeps refusing my edit saying no approved spec, sort it out and continue | no (orchestration) | ~/projects/<app> |
| T2 | humanize this, it sounds AI | yes | ~/projects/<app> |
| T3 | redo the spec for module control, it has useless stuff and no diagrams | yes | ~/projects/<app> |
| T4 | review my cv like a recruiter, are the services misleading | yes | ~/projects/<app> |
| T5 | does the code follow the spec for module control? | no (review) | ~/projects/<app> |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 1 run per arm, the task on stdin. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill writing loaded:` and `--add-dir` to a copy of the skill folder (evals file left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules were written before the first run. `[DASH]` in a task is replaced by the real em dash character when the task is sent, so this file stays free of dashes.

### S1 (run) RED from: Gotchas row 1 (antithesis density) and law 1 (dashes)

Role line: "You are the director."

Task given to both arms:

~~~
Humanize this paragraph for the MR description, keep every fact: This change is not just a bug fix [DASH] it is a rework of how the import counts sheet frames, rather than a patch on the symptom. The count was wrong on 3 of 12 sheets because the loop stopped at the first empty frame. It isn't a performance change, it is a correctness change. All 12 sheets now report 48 frames.
~~~

Pass rules, 1 point each:

1. The text has 0 em dashes and 0 en dashes.
2. The text has 0 antithesis forms ("not just", "rather than", "isn't X, it is Y", "not X but Y", "more than a patch").
3. The text keeps the facts: 3 of 12 sheets, the loop stopping at the first empty frame, and 48 frames on all 12 sheets.

### S2 (run) RED from: Gotchas rows 4 to 6 (process notes, the code side, no visual proposal)

Role line: "You are the architect player."

Task given to both arms:

~~~
The spec draft for 'client portal' has these sections: Goal, Data model with tables, Elixir function list, Process notes copied from the planning chat, Scenarios. He says: 'it's a bunch of useless stuff, too technical, and it's missing visual proposal'. Say what you do with each section and what the spec ends up containing. Under 250 words.
~~~

Pass rules, 1 point each:

1. The data model and the functions move to plan.md.
2. The process notes move to ORCHESTRA.md.
3. A visual proposal is added, a mockup per screen rendered and opened (a diagram alone does not pass).

### S3 (run) RED from: Gotchas row 9 and CV review law 3 (a service with proof, an invented number)

Role line: "You are the QA player reviewing CV content in the CV site repo."

Task given to both arms:

~~~
A CV service reads: 'Elixir backends: feeds 40% faster, led 12 engineers'. Another service 'AI consulting' has only 'his words' behind it, no repo or job. He told you earlier he never gave you either number. What do you do with each? Under 200 words.
~~~

Pass rules, 1 point each:

1. The answer does not keep or invent the numbers and lists them under needs his input.
2. AI consulting is merged into a service with evidence or put under needs his input.
3. A service carries a description plus use cases beside it, no proof.
