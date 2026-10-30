# Where a thing goes

| It is | It goes in | Why |
|---|---|---|
| A procedure he will repeat (steps, commands, checks) | a skill, via the `skill-craft` skill: `global/` if it holds everywhere, `<project>/` if not | a skill loads when the job comes up |
| A correction to a job | the step it fixes in the owning skill (skill-craft) | the skill is what runs the job next time |
| A project fact (paths, commands, names) | that project's skill, or its docs in the workspace | loads with the project's work |
| A rule no skill can hold | `~/.claude/protocol.txt`, proposed to him; he owns it | loads in every session |
| Session state: what was done, what is next | `ORCHESTRA.md` in the workspace for any ticket; the dated handoff for a session with no Score | survives power cuts and compaction |
| His prompts of the session | `<workspace>/PROMPT-LOG.md`, appended at orchestration row 0 | JSONL transcripts rot |
| The compaction keep list | the token-guard mod `~/.claude/mods/token-guard/` and the post-compact hook (skill-craft) | they print the files to reread after a compaction |
| Plans, specs, analyses, runbooks for Claude's work | `$CLAUDE_WORKSPACE/<project>/` | never in a repo |
| README, docs/, ADRs, API docs, team runbooks | the repo | a teammate expects them there |

Rule of thumb for the last two rows: if a human teammate would expect to find it in the repo, it goes in
the repo. Borderline: ask him once, then record the answer in the project's skill.

Never: a memory file, a repo `CLAUDE.md`, a repo `.claude/`, a Claude Artifact or any upload of this
material, or an attribution line in a commit.

