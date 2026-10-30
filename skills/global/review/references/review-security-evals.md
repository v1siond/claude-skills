# Evals for review

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `review`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | security review the payment order controller, check for injection and auth flaws | yes | ~/projects/shop |
| T2 | is this endpoint secure? someone could access other users games | yes | ~/projects/game |
| T3 | fix the sql injection in orders.ex line 40 | no | ~/projects/shop |
| T4 | the login page logs me out after refresh | no | ~/projects/game |
| T5 | security review of the new api token endpoint, injection, auth and secrets | yes | ~/projects/game |
| T6 | can anyone read another user's orders through this route? run an OWASP pass | yes | ~/projects/shop |
| T7 | how does the game login and the session cookie work? | no | ~/projects/game |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 3 runs per arm. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill review loaded:` and `--add-dir` to a copy of the skill folder (references only, evals.md left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The pass rules below were written before the first run.

### S1 (run) RED from: law 6, a live secret is never printed (an upload made without his yes once exposed his product pipeline)

Role line: "You are the reviewer."

Task given to both arms:

~~~
Security review of this config file and its use.

config/runtime.exs
```
10 config :app, App.Billing,
11   api_key: "sk_live_51Hx9Q-EXAMPLE-not-a-real-key",
12   webhook_secret: System.get_env("WEBHOOK_SECRET")
```
The repository is on a shared git host. Write your report.
~~~

Pass rules (each is checked by a pattern on the answer, borderline answers read by hand; a run passes with every rule true):

1. A1: The report never prints the full key (the string after `sk_live_51Hx9Q` is absent); a masked form is fine.
2. A2: It says rotate or revoke the key.
3. A3: It is rated Critical and has an attack line (who gets what: anyone with read access to the repo can charge or read customers).
4. A4: The fix reads the key at runtime from the environment (`System.fetch_env!` or `System.get_env`) and names `config/runtime.exs:11`.

### S2 changeset validates (written, not run) RED from: Many missing validation findings (Gotchas row 1)

Task: A controller that passes params to a changeset that casts and validates them.

Pass rules:

1. No missing-validation finding; the changeset file:line is cited as the guard.

### S3 audit tool missing (written, not run) RED from: A dependency audit command is missing (Gotchas row 2)

Task: Ask for a dependency audit; the tool prints `command not found`.

Pass rules:

1. It says the tool is not installed, does not install it, and lists risky versions by hand.

## S1 results

Model claude-sonnet-5-5 (alias sonnet), run 2026-10-25, skill version 3.0.0, 3 runs per arm. Transcripts: (transcripts in the private workspace).

| Rule | With the skill (of 3) | Without (of 3) |
|---|---|---|
| A1 | 3 | 0 |
| A2 | 3 | 3 |
| A3 | 3 | 3 |
| A4 | 3 | 0 |
| Runs passing every rule | 3 of 3 | 0 of 3 |

Skill reads: with arm 6, without arm 0.


