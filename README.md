# Claude skills: a generic workflow for Claude Code

This repo is the set of skills, agents and hooks I use to work with
[Claude Code](https://docs.claude.com/en/docs/claude-code/overview) on every project I own. It turns a session into
a small team with one process: a director that sizes each task, briefs players and checks their work, a set of
skills that say how each kind of job is done, and a harness that keeps those rules in front of the model on every
prompt. Nothing in it is tied to one codebase; the facts of each project live in a private overlay you write
yourself (see [Adapting it](#adapting-it)).

You can install all of it, or copy one skill into your own `~/.claude/skills` and use it alone.

## Contents

- [What a skill is](#what-a-skill-is)
- [How a task runs: orchestration](#how-a-task-runs-orchestration)
- [The elephant and the goldfish](#the-elephant-and-the-goldfish)
- [Critics and corrections](#critics-and-corrections)
- [The 14 skills](#the-14-skills)
- [Agents, harness and standards](#agents-harness-and-standards)
- [Install](#install)
- [Adapting it](#adapting-it)
- [Repo layout and further reading](#repo-layout-and-further-reading)
- [License](#license)

## What a skill is

A Claude Code skill is a folder with a `SKILL.md` file: YAML frontmatter (a name and a description that says when
to use it) and a body of instructions, plus any `references/`, `scripts/` and `examples/` it links. Claude Code
reads the descriptions of every installed skill and loads a skill's body when a request matches it. The official
docs: [Agent Skills in Claude Code](https://docs.claude.com/en/docs/claude-code/skills).

Every skill here follows the same 14 section shape (when to use, when not to, stance, non-negotiables, red flags,
intake, pipeline, gotchas, deliverables, checks, critic loop, definition of done, references, evals), so a reviewer
can fail any line of it. The skills speak of "he" and "his words": that is the owner of the setup, the person
typing the prompts. Feedback that shaped a skill is not kept as quotes: each correction is
turned into the step, law or check it asks for, written as a plain instruction.

## How a task runs: orchestration

Every bug, feature or batch goes through one skill, [`orchestration`](skills/global/orchestration/SKILL.md). The
main session is the **director**. It never writes the code itself; it casts **players** (subagents) and holds the
record of the work in an `ORCHESTRA.md` file in a workspace folder outside the repo.

| Step | What happens |
|---|---|
| 0 | Log the request word for word and add it to the current batch |
| 1 | Understand: read the docs, the skills and the code of the area |
| 2 | Spec and plan, then fresh reviewers read them (the goldfish below); stop for the owner's yes |
| 3 | Size the work and cast only the roles it needs (architect, backend, frontend, QA, reviewer, critic, assets) |
| 4 | Write one brief per ticket: his words, the files it owns, the skills to load, the check to pass |
| 5 | A critic reads the briefs and rejects any below the bar |
| 6 | Dispatch the players, in parallel lanes when the files do not overlap |
| 7 | Control each report, requirement by requirement, and the diff against the standards |
| 8 | Integrate the lanes and test every seam where two of them meet |
| 9 | QA in the browser on the owner's dev server, before and after |
| 10 | A critic judges the result against his words |
| 11 | Every finding goes back to step 4 as a new ticket, until QA and the critic pass |
| 12 | Present: the owner looks at it, and the report is written in a fixed shape |

The other skills are what a player runs for its kind of work inside one of these steps; none of them carries a
workflow of its own.

## The elephant and the goldfish

The director is the **elephant**: it keeps the whole context, the record and the owner's words across a long
session. Each **goldfish** is a fresh, read-only subagent that knows only the files in its brief. Because a
goldfish has none of the director's assumptions, it catches what the director stopped seeing: a claim about the
code that is false, a step a builder cannot start, a requirement the plan never covers. The comprehension goldfish
never gets the owner's words at all; if it cannot restate the goal from the spec alone, the spec is unclear.

The five goldfish live in [`agents/`](agents) and run at the end of step 2 and again at step 10. The flow is drawn
in [docs/diagrams.md](docs/diagrams.md) and wired in [docs/harness.md](docs/harness.md).

## Critics and corrections

Every skill ends in a **critic loop**: a separate read-only agent gets the work and the request, never the
author's notes, and rejects by default. It scores each axis from 1 to 10 and names the 3 worst problems with
file:line and the smallest fix. Anything below 8 goes back to the step that wrote it.

When the owner corrects how a job was done, the fix lands as one line in the step of the skill that owns that job
(run through `skill-craft`), never in a memory file or a new hook. That way the answer is given once and every
later session reads it from the same place.

## The 14 skills

All in [`skills/global/`](skills/global). "Fires on" lists a few of the phrases the router matches; the full list
is in each skill's frontmatter.

| Skill | What it does | Fires on | Run by |
|---|---|---|---|
| [session-start](skills/global/session-start/SKILL.md) | Detects the project from the folder, loads its workspace notes, starts time tracking, prints a ready summary | the first message, after a compaction, "where were we" | the director |
| [orchestration](skills/global/orchestration/SKILL.md) | The 13 steps above, the record, the briefs and every report | "fix this bug", "ticket", "new batch", "standup" | the director |
| [skill-craft](skills/global/skill-craft/SKILL.md) | Writes, changes, lints and audits skills; lands each correction in its owning skill | "make this a skill", "add this to the skill", "did not trigger" | the director |
| [engineering-standards](skills/global/engineering-standards/SKILL.md) | Code to a senior bar while it is written: guard clauses, dispatch maps, SOLID, reuse first, the repo's gates at exit 0 | "clean code", "guard clauses", "write it properly" | every builder |
| [testing-standard](skills/global/testing-standard/SKILL.md) | Tests in the batch's test mode: backend TDD seen red, both paths, real fixtures, mocks only at boundaries | "add tests", "tdd", "manual qa" | backend, frontend and QA players |
| [review](skills/global/review/SKILL.md) | Reviews a diff through 5 lenses (correctness, performance, security, tests, spec), each finding with its failing input and fix | "review this", "is this secure", "n+1" | the reviewer |
| [bug-investigation](skills/global/bug-investigation/SKILL.md) | Reproduces a bug through the real entry point with real data, measures, fixes the root cause | "bug", "broken", "the data is wrong" | backend, frontend or QA player |
| [research](skills/global/research/SKILL.md) | Looks a question up from primary sources before designing, one citation per claim | "research", "look it up", "don't guess" | the architect or any player |
| [ship](skills/global/ship/SKILL.md) | Commits in the owner's voice, the full gate before a push, releases and tags, data migrations | "is it ready to push", "cut a release", "backfill" | the director, builders and QA |
| [infra-gitops](skills/global/infra-gitops/SKILL.md) | Kubernetes apps run by ArgoCD from git: kustomize or Helm, image updater, ExternalSecrets, OpenTofu | "argocd", "external secret", "add a new app to the cluster" | the director and the backend player |
| [ui](skills/global/ui/SKILL.md) | Designs a screen as rendered options before it is built; audits a built one for usability and AAA accessibility | "show me options", "is it accessible" | frontend, QA and assets players |
| [writing](skills/global/writing/SKILL.md) | Text the owner signs, in his voice: MR text, docs, specs, CV copy; a checker bans em dashes and antithesis | "write the docs", "it sounds AI" | every player whose output he reads |
| [blog](skills/global/blog/SKILL.md) | A blog post from a list row to a finished folder: draft, three critic passes, screenshots and diagrams | "write the post", "cover image" | the assets player |
| [motion-video](skills/global/motion-video/SKILL.md) | A demo or launch film cut from a live take of the app, with captions and music | "demo video", "launch film" | the assets player |

## Agents, harness and standards

- [`agents/goldfish-comprehension.md`](agents/goldfish-comprehension.md): restates the goal and today's system from the spec alone.
- [`agents/goldfish-codebase.md`](agents/goldfish-codebase.md): checks every claim about the code against the code.
- [`agents/goldfish-critic.md`](agents/goldfish-critic.md): finds what is missing, contradictory, or more than the ask needs.
- [`agents/goldfish-readiness.md`](agents/goldfish-readiness.md): go or no-go, can a builder start each task with no decision left.
- [`agents/goldfish-concept.md`](agents/goldfish-concept.md): checks a visual spec or result against its approved concept art.
- [`harness/protocol.txt`](harness/protocol.txt): the few rules no skill can hold, printed at session start and on every prompt.
- [`harness/hooks/skill-router.py`](harness/hooks/skill-router.py): prints one `SKILL CHECK:` line naming the skills a prompt matches.
- [`harness/hooks/post-compact.py`](harness/hooks/post-compact.py): after a compaction, points the session at the files to resume from.
- [`harness/usage-guard.sh`](harness/usage-guard.sh) and [`harness/usage-statusline.sh`](harness/usage-statusline.sh): a status line with usage, and a guard that stops tools at a usage limit.
- [`harness/stop-report-format.sh`](harness/stop-report-format.sh) with [`report-format.md`](harness/report-format.md): refuses a final report that is out of shape.
- [`skills/global/ship/scripts/push-gate.sh`](skills/global/ship/scripts/push-gate.sh): blocks a `git push` until the full gate has passed on that exact tree.
- [`harness/mods/`](harness/mods): two optional plugin mods, a live agents panel and a token guard.
- [`harness/CLAUDE.md`](harness/CLAUDE.md) and [`harness/settings.example.json`](harness/settings.example.json): the instructions file and the settings, with placeholders.
- [`standards/howseen/`](standards/howseen): a model skill the critic scores skill wording against, with its own license.

## Install

You need Claude Code, `bash`, `python3` with `pyyaml` (`pip install pyyaml`), `git` and `jq`.

```bash
git clone https://github.com/v1siond/claude-skills.git ~/projects/claude
cd ~/projects/claude
harness/install.sh --dry-run   # print each action, change nothing
harness/install.sh             # do it
```

What it does:

- Links every skill folder (the overlay's too, when present) into `~/.claude/skills/` and every agent into `~/.claude/agents/`. A name that already exists there is skipped, never replaced.
- Copies the hooks, `protocol.txt`, the report check, the usage scripts and the mods into `~/.claude/`. A file that differs is saved first as `<file>.bak.<time>`.
- Never writes `~/.claude/settings.json` or any `CLAUDE.md`. It prints a todo instead: merge [`harness/settings.example.json`](harness/settings.example.json) into your settings and fill each `<placeholder>`, and copy what you want from [`harness/CLAUDE.md`](harness/CLAUDE.md) into your own instructions file.

Two environment variables matter:

- `PROJECTS_DIR`: the folder that holds your projects (default: the folder above this repo). The installer only names it in its todo line.
- `CLAUDE_WORKSPACE`: the folder where the director keeps its records, plans and reports, outside every repo (default `~/.claude-workspace`). Set it in the `env` block of `settings.json`; open sessions see it after a restart.

The settings example turns on three plugins the skills call (superpowers, frontend-design, code-review). Anything
else is your choice.

The builder gate (`skills/global/orchestration/scripts/builder-gate.sh`) runs a repo's own `bin/standards` script
only when that repo's path is a line in `~/.claude/builder-gate-trusted` (or the file `BUILDER_GATE_TRUSTED`
names). An untrusted repo's scripts never run.

To try one skill alone, skip the installer and link that folder:

```bash
ln -s ~/projects/claude/skills/global/review ~/.claude/skills/review
```

To uninstall, remove the links the installer made (`find ~/.claude/skills ~/.claude/agents -maxdepth 1 -type l
-lname "$HOME/projects/claude/*" -delete`), delete the copied hooks, scripts and mods from `~/.claude`, and rename any
`<file>.bak.<time>` back to restore what was there before.

## Adapting it

The public skills hold the process and nothing about any one codebase. Your project facts go in two places that
never reach this repo:

- **The private overlay**, `skills/specific/` (gitignored here, best kept as its own private git repo). It holds project skills (`specific/<project>/<name>/SKILL.md`, facts only: paths, commands, gotchas), and `profiles/<project>.sh` files that the scripts source: `PROJECT_ROWS` for session-start (which folder is which project), `PROFILE_ROWS` for the pre-deploy gate (which gates a repo runs), and `RELEASE_ROWS` for the release preflight (tag scheme and version file). It can also hold `trigger-queries.json` for its own router tests. Point `CLAUDE_PRIVATE_SKILLS` at it if it lives elsewhere.
- **The local folder**, `~/.claude/local-skills/`, for anything that must stay on one machine. Its `profiles/*.sh` are sourced after the overlay's. A `public-terms.txt` there (one literal per line) makes `skill-craft/scripts/lint-skills.py` fail any public line that names one of those terms, so a client or project name cannot leak into the public tree.

Each script falls back to generic behaviour when no profile matches.

## Repo layout and further reading

| Path | What |
|---|---|
| [`skills/global/`](skills/global) | the 14 skills |
| [`agents/`](agents) | the 5 goldfish reviewers |
| [`harness/`](harness) | protocol, hooks, status line, mods, settings example, installer |
| [`docs/`](docs/README.md) | a page per skill, best practices, the harness, diagrams |
| [`standards/howseen/`](standards/howseen) | the model skill for wording |

- [docs/README.md](docs/README.md): every skill with its page.
- [docs/best-practices.md](docs/best-practices.md): how to use the setup, each rule with its source.
- [docs/harness.md](docs/harness.md): what fires when.
- [docs/diagrams.md](docs/diagrams.md): how the skills interact and how orchestration lays out.
- `skills/SKILLS.md`: the full catalogue with every trigger phrase, generated locally by `python3 skills/global/skill-craft/scripts/catalog.py`.
- [Live Review](https://github.com/v1siond/live-review): a VS Code extension for reviewing an agent's work as it lands, in its own repo.

## License

The repo root has no license file yet, so default copyright applies; ask before reusing. `standards/howseen/`
carries its own [LICENSE](standards/howseen/LICENSE).
