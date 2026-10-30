# Documentation

One page per skill, the best practices for using them, the harness around them, and diagrams of how they work
together. The catalogue of every skill with its triggers, `skills/SKILLS.md`, is generated locally by
`skills/global/skill-craft/scripts/catalog.py`; this folder explains, the catalogue lists.

- [best-practices.md](best-practices.md): the rules for using the setup, each with its source.
- [harness.md](harness.md): every hook, the status line, the mods and the agents, and when each fires.
- [diagrams.md](diagrams.md): 6 skill interaction examples and 4 harness layouts, in Mermaid.
- Each skill page below has its own "Best practices" section, taken from that skill's Gotchas.

## How skills are categorized

Two views of the same 14 skills.

- **By type**: what kind of work the skill does. Process skills run the work itself; engineering skills are the
  code bar; design and content skills make what people look at or read; infrastructure and project experts hold
  one system's facts.
- **By project**: where the skill applies. The rule is skill-craft law 5
  ([`skill-craft/SKILL.md`](../skills/global/skill-craft/SKILL.md) line 44): a skill lives in `global/<name>` when it
  applies in every repo, in `specific/<project>/<name>` when it holds one repo's facts. A project skill carries
  `metadata.root`, and the router lists it only in a cwd under that root
  ([`harness/hooks/skill-router.py`](../harness/hooks/skill-router.py), `in_scope`).

## By type

| Type | Skill | Scope | What it does |
|---|---|---|---|
| Process | [orchestration](skills/process/orchestration.md) | global | the only workflow: director, players, steps 0 to 12, the reports |
| Process | [session-start](skills/process/session-start.md) | global | opens every session: project, context, timer, summary |
| Process | [skill-craft](skills/process/skill-craft.md) | global | writes, fixes and audits skills; where every correction goes |
| Engineering | [engineering-standards](skills/engineering/engineering-standards.md) | global | the code bar every builder writes to |
| Engineering | [testing-standard](skills/engineering/testing-standard.md) | global | test modes and how a test is written so it can fail |
| Engineering | [review](skills/engineering/review.md) | global | 5 lenses: code, performance, security, tests, spec |
| Engineering | [bug-investigation](skills/engineering/bug-investigation.md) | global | symptom to root cause file:line, fix, proof |
| Engineering | [ship](skills/engineering/ship.md) | global | commits, the gate, push, release, data migrations |
| Engineering | [infra-gitops](skills/engineering/infra-gitops.md) | global | ArgoCD clusters: diagnose, change, set up a new app the GitOps way |
| Design and content | [ui](skills/design-and-content/ui.md) | global | screen design, UI review, AAA audit, rendered options |
| Design and content | [writing](skills/design-and-content/writing.md) | global | his voice, docs, specs, CV copy |
| Design and content | [blog](skills/design-and-content/blog.md) | global | a post folder with its media and three critic passes |
| Design and content | [motion-video](skills/design-and-content/motion-video.md) | global | demo and launch films |
| Design and content | [research](skills/design-and-content/research.md) | global | sourced facts before a design or an answer |

## Project skills

Project skills (one repo's facts: paths, commands, names, its own gotchas) live in `skills/specific/<project>/`, in a private repo of their own; they are never published here.

Project folders and their workspaces: [`session-start/references/project-map.md`](../skills/global/session-start/references/project-map.md).
Which skills each role runs: [`orchestration/references/skill-map.md`](../skills/global/orchestration/references/skill-map.md).

## Agents

The five goldfish reviewers in [`agents/`](../agents) are documented in [harness.md](harness.md#agents) and
drawn in [diagrams.md](diagrams.md#9-the-spec-stage-five-goldfish-and-his-stop).
