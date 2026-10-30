# Frontmatter, layout and the router

The facts behind Pipeline steps 1, 4, 8 and 9 of skill-craft. The shape of the body is
`skill-framework.md`; this file holds the frontmatter, where a skill lives and how the router finds it.

## Where a skill lives

| Scope | Folder | Holds |
|---|---|---|
| global | `/home/visiond/projects/claude/skills/global/<name>` | The skills that apply in every repo: blog, bug-investigation, engineering-standards, infra-gitops, motion-video, orchestration, performance-expert, research, review, session-start, ship, skill-craft, testing-standard, ui, writing (15). |
| project | `/home/visiond/projects/claude/skills/specific/<project>/<name>` | One project's facts: paths, commands, names, its own gotchas. Never a workflow. They live in the private overlay (its own repo), never in this one. |

Claude Code reads skills only from `~/.claude/skills/<name>`, flat, so the symlink is what makes a skill exist:
`ln -s /home/visiond/projects/claude/skills/<scope>/<name> ~/.claude/skills/<name>`. Pass: `ls -la ~/.claude/skills/<name>` prints `-> /home/visiond/projects/claude/skills/<scope>/<name>`.

A global skill holds no project rows, overrides or configs. A project's rows move into that project's skill under
`specific/<project>/`, in a references file, and the global names the project skill.

## The description

Shape, 1024 characters or fewer (the hard cap, Anthropic guide p.10; a tighter length: needs a number),
third person, no `<` `>`, no `: ` sequence (an unquoted `: ` breaks the YAML). The router reads only `metadata.triggers`,
so the description holds what, when and Do NOT, never an inventory of the skill's contents:

`<What it does, the project named first for a project skill>. Run by the <player>. Use when he says "a", "b", ... (his phrases; a count: needs a number). Do NOT use for X (sibling), Y (sibling).`

Filled example (this skill's description, 464 characters):

`Writes and changes the skills under /home/visiond/projects/claude/skills, invoked first, before the material or the skill to change is opened and even when the material is missing. Run by the director. Use when he says "skill", "make this a skill", "turn this into a skill", "add this to the skill", "did not trigger", "triggered the wrong one", "audit the skills". Do NOT use for the work a skill describes (that skill) or notes and handoffs (orchestration).`

Every Do NOT sibling is a skill that exists; a plugin skill keeps its `plugin:name` and is listed in
`PLUGIN_SKILLS` in `scripts/lint-skills.py`.

## metadata

- `metadata.triggers`: a flow list of lowercase phrases he types; a trailing `*` marks a stem (`mockup*`). Every phrase quoted in the description is in the list (lint `triggers`).
- One phrase belongs to one skill per scope (globals among globals, a project's skills per root). A phrase two skills claim on purpose goes in `SHARED` in `scripts/lint-skills.py`.
- `metadata.root`: a project skill's repo folder or a list of them; the router offers it only under that cwd. Missing root on a project skill = lint FAIL.
- `metadata.always: true`: the router lists the project skill on every prompt under its root, matched or not (the repo's expert). Only with `root`; on a global it is a lint FAIL.
- `metadata.version`: semantic, bumped on every change; a rewrite into the framework is a major bump (x.0.0).

## The router

`~/.claude/hooks/skill-router.py` reads every `~/.claude/skills/*/SKILL.md` frontmatter on every prompt and
prints `SKILL CHECK:` with up to 6 matches (`MAX_HITS`), project skills first. A new phrase goes in
`metadata.triggers`, never in the hook. The hook keeps hand regex rows (`HAND`) only where a phrase list
cannot say it: a URL, a ticket code like A1 (case sensitive), a key chord, a negative lookahead.

Check one prompt, free and instant:
`echo '{"prompt":"<his words>","cwd":"<repo folder>"}' | python3 ~/.claude/hooks/skill-router.py`
Pass: the skill is in the printed line for a should row and absent for a near miss row.

Measured: the router built from frontmatter scored 314/333 rows against 229/333 for the old hand table
(`trigger-results.md`).

## The trigger test

`python3 scripts/trigger-test.py references/trigger-queries.json --skill <name> --jobs 2` runs one real
`claude -p` session per row, about 30 s per prompt, with Bash, Edit and Write disabled. Pass: 90% or more of
the rows (Anthropic guide p.9). The run stops after 12 tool calls (`MAX_TOOL_CALLS`), because session-start
uses the first calls of every session: at a 5 call cap the score was 24/35, at 12 the misses rerun and 5 more
passed. A project skill's rows carry `"cwd"` set to its root.

Fix a miss: undertrigger = add his literal phrase to `metadata.triggers` and the description; overtrigger = name
the other skill in each skill's Do NOT line. Pass = the row passes when only the failed rows are rerun; record the
score in `trigger-results.md`.

## Hooks and where rules live

Every lesson, doc rule and correction lives in a skill. The only standing rules outside skills are in
`~/.claude/protocol.txt`. The only hooks are: that protocol, the router, the usage guard, the report Stop hook
(orchestration law 18), and `~/.claude/hooks/post-compact.py` (puts the protocol, the orchestration skill and the live
score back after a compaction). A rule that could be a skill step goes into a skill, never into a new hook,
memory file or CLAUDE.md section.

## Canon lines

A skill whose rules must survive every rewrite keeps `references/canon.txt`, one `label<TAB>regex` per line.
Lint `canon` FAILs when a regex no longer matches the SKILL.md or its references. Example:
`orchestration/references/canon.txt` line `letter of the law	Violating the letter of a law is violating the law`.
