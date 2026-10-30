# Skill map (role x kind of work x project)

The one place that says which skills a player runs. Every player gets its role row, plus each work row that
matches its ticket, plus the project skills in that row's project column. Nothing else, nothing fewer. The
director writes the result in the Cast of ORCHESTRA.md and as one line `Skills you run: a, b, c` in each prompt itself, a resume prompt too (orchestration
`references/agent-dispatch-brief-template.md`); `scripts/skills-check.sh` fails an agent that did not load each one. A kind of work that recurs gets a new row here, never a per-ticket exception.

## Role rows (always)

| Role | Skills |
|---|---|
| director | orchestration |
| architect | engineering-standards, orchestration (every ticket, SKILL.md row A); database-architect when the ticket adds or changes a table |
| backend | engineering-standards, testing-standard |
| frontend | testing-standard, ui, engineering-standards (with `references/frontend.md`) |
| assets | the work rows below, and the project's own docs |
| qa | testing-standard, bug-investigation, ui on a screen |
| reviewer | review |
| researcher | research, writing (orchestration when the findings become a doc) |
| critic | orchestration `references/critic.md`, plus every skill of the work it scores (the cast's `Skills you run:` lines: ui and the repo expert on a screen) |

## Work rows (add when the ticket has this kind of work)

The project column is the project's own docs (README, CLAUDE.md, `docs/`) unless a project skill is named.
Project skills and their rows (an expert per repo, a concept designer, a course content skill) are not in this
public map: each project keeps them in its private overlay, `skills/specific/<project>/facts/orchestration-skill-map.md`,
read with this map for a ticket in that project.

| Kind of work | Add | Project column |
|---|---|---|
| new or changed screen, panel, form | ui, engineering-standards `references/frontend.md` | |
| he picks between looks, a redesign | ui (frontend-design:frontend-design only where the repo has no kit) | |
| port of an approved mockup | ui `references/design-proposals-porting.md` | |
| backend logic or endpoint | (role row) | |
| schema or data change | ship | the project's own docs for the run on staging or production |
| bug | bug-investigation | |
| performance work (a speed, fps, load, memory or leak ask, or an audit) | performance-expert (review for a diff's queries, bug-investigation for a wrong result) | the project's expert skill, its performance reference |
| tests for a ticket | testing-standard | |
| verify a changed screen (qa) | ui | |
| review a diff (reviewer) | review (auth, input or secrets; queries or loops; changed tests are lenses inside it) | |
| spec or plan | writing, engineering-standards | |
| docs | writing | |
| asset or art | (role row) | |
| course content | (role row) | the project skill for that course, from the overlay |
| video or film | motion-video | |
| blog post (a post list row to a finished post folder) | blog, writing (motion-video when a beat needs a film) | the project's row of blog `references/blog-post-projects.md` |
| CV or portfolio content review (critic or qa) | writing | |
| market or content research (blog topics, trends, a market study) | research | |
| release | ship | the project's own docs |
| infrastructure (a cluster, a manifest, a secret, a new app set up the GitOps way) | infra-gitops | the project facts overlay, `references/project-facts.md` |
| writing, changing, linting and trigger-testing skills (director) | skill-craft | |

## Example

A frontend player on a settings screen of a web app: testing-standard, ui, engineering-standards with
`references/frontend.md` (role and screen rows). The QA player on the same ticket: testing-standard,
bug-investigation, ui.
