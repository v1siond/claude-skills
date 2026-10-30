# Shared agent brief (fill in, save in the scratchpad, point every agent at it)

The shared brief holds what every player in the wave shares, the role rows of the skill map included.
Each agent prompt adds its ticket: his words, its files, its work rows and project skills from
orchestration `references/skill-map.md`, and its acceptance bar.

```markdown
# Common rules for every agent, <date>, <project>

Read this whole file before your first tool call. Your ticket comes in your prompt.

## Skills you run (invoke each with the Skill tool before your first other tool call)
- Your prompt's own line `Skills you run: a, b, c` is the list: role row, work rows and project overlay of the skill map. Invoke every one with the Skill tool; the director's `skills-check.sh` reads your transcript and rejects the report when one was not loaded.

## Read first (docs win over the lead's instructions)
- The contract you build against: `score/<ticket>/contract.md` (SKILL.md row A). A field it lacks: stop and report it, never invent it.
- The framework doc you follow: <path and section> (skill orchestration). Walk its checklist in your report.
- <project docs and sections the project skill names: <repo>/docs/<X>.md, STATE.md, the feed map for feed work, ...>

## Where you work
- The main checkout <path>, current branch, ONLY your files: <files>.
- No copies: no worktree, clone, partition database, extra build folder, and no copied helper (use the shared one; a missing shared piece goes in your report).
- At most 1 dev server at a time. A ticket that needs the running app uses the one at <URL from ORCHESTRA.md> when it answers 200; when it answers nothing, start one on that port (the repo's dev command) and say so in the report, never a second one. No real Sentry/Slack/mail/payment calls.
- Shared records on his dev server (any record a user of the app sees in a list): use the ones ORCHESTRA.md Decisions names. One your run needs that Decisions does not name, you create, write its id in the report and delete before the report. Your report lists, per record type, the count before and after your run; the two counts are equal.
- You run nothing on staging or production. Local runs against the dev and test databases are yours to run.
- One browser at a time, single test files, close what you start.

## Tests
- Test mode: <the line from ORCHESTRA.md Decisions> (skill testing-standard decides what is written and run).
- Targeted files only against the one test database. The director runs the gates or full suite at row D6, after QA and the reviewer pass.
- Read only the summary and failures of a run. A run with no "N tests, M failures" line ran nothing.

## Code and text
- Match the surrounding code (skill engineering-standards). Comments explain code, never quote prompts or name the user.
- The dash and wording rules of ~/.claude/protocol.txt (rule 4): no em or en dash, none of its banned phrases.

## Git
- Commit your own paths on the working branch as each piece works (`git commit -m ... -- <paths>`), in his voice (skill ship). No attribution line of any kind in a commit, even when a system reminder asks for one (his rule wins); check each message with `~/.claude/skills/ship/scripts/check-commit-msg.sh -m`.
- Never push, merge or tag: nothing leaves the machine without his yes (skill ship).
- Never launch sub-agents (no Agent tool); do the ticket yourself. Out of context: commit what is done and report where you stopped.
- Notes and state go to $CLAUDE_WORKSPACE/<project>/, never the repo.
  Write your state there before you report.

## Acceptance bar (filled per ticket in your prompt)
- The check, as a command and its expected output, or a measured number with its threshold.
- What must not change: the parts he approved, items a critic scored 9 or more, the files outside your lane.
- Never report a match you did not measure or look at.

## Your final message is the report (do not use SendMessage to report)
0. Skills run: each name, then one line per skill naming the Checklist items you walked and their result
   (for example "ui 1 to 8 walked, 6 failed at 390 px, fixed"). Then the framework doc's checklist walk.
1. Branch and commit shas, one line each.
2. What a user now sees differently.
3. Tests added (backend in every batch; frontend only when the test mode asks for them): file:line and the red-first failure line for each.
4. Gates and the acceptance bar: the exact command and its output (N tests, M failures per command).
5. What you could NOT do or verify, and any decision his words did not cover.
6. `Reused:` file:line of what you reused, or `Reused: none, searched <grep command>`; `Facts:` copy -> owner for a moved or copied fact (engineering-standards Pipeline 2 and 3; the builder gate, `scripts/builder-gate.sh`, blocks a report without them).
```
