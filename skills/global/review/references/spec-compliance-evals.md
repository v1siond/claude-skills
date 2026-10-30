# Evals for review

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `review`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | does it follow the spec? check against the spec | yes | ~/projects/api |
| T2 | what's missing from the spec, gap analysis | yes | ~/projects/api |
| T3 | write the spec for onboarding | no | ~/projects/api |
| T4 | compare the build to the spec and tell me every requirement that is missing | yes | ~/projects/game |
| T5 | did you build what I asked? check each point of my request against the code | yes | ~/projects/shop |
| T6 | review the diff for bugs and style | no | ~/projects/shop |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill review loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: full CRUD asked, only create shipped (Gotchas row 4, 06-23)

Role line: "You are the reviewer."

Task given to both arms:

~~~
Check the code against the spec and report.

spec.md
```
4 R-a: Events, resources and bookings each have full CRUD in the admin (create, read, update, delete).
5 R-b: Deleting a booking asks for confirmation.
```
Evidence you have (from grep, nothing else exists):
```
router.ex:20  resources "/events", EventController, only: [:index, :new, :create, :show]
router.ex:21  resources "/resources", ResourceController
router.ex:22  resources "/bookings", BookingController, only: [:index, :new, :create, :show, :delete]
router.ex:23  get "/admin/export.csv", ExportController, :bookings
booking_controller.ex:40  def delete(conn, %{"id" => id}), do: Bookings.delete!(id); redirect(conn, to: ~p"/bookings")
booking/index.html.heex:12  <.link method="delete" href={~p"/bookings/#{b}"}>Delete</.link>   (no data-confirm)
```
Searches run: grep -rn "edit\|update" event_controller.ex found nothing; grep -rn "confirm" lib/ found nothing.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: R-a is split into one row per resource and verb: at least 5 rows that start with `R` and a number or letter.
2. A2: Events edit, update and delete are `partial` or `absent`, with the searched record (the grep named).
3. A3: Every row that is not `implemented` has a `refutation:` line: count of `refutation:` is 2 or more.
4. A4: The reverse direction: `/admin/export.csv` is reported as behaviour no requirement mentions.
5. A5: R-b (booking delete confirmation) is `absent` or `contradicted`, with `data-confirm` or the template line cited.

### S2 later correction (written, not run) RED from: The spec contradicts what he asked later (Gotchas row 2)

Task: A spec saying 3 roof rows and his later message saying 2.

Pass rules:

1. The requirement is marked amended with his message as the source and the spec is reported as needing an update.

### S3 undecidable (written, not run) RED from: A requirement is too vague to check

Task: A spec line `the editor should feel fast`.

Pass rules:

1. Verdict undecidable with the two readings; it is a finding against the document.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 2 |
| A2 | 3 | 1 |
| A3 | 3 | 0 |
| A4 | 3 | 0 |
| A5 | 3 | 1 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 5, without arm 0.


