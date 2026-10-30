# Style gates per stack

Open this at Intake and pipeline step 7 to know which gates exit 0 before "done". The repo's own CI and docs
win; this is the map. Repo specific notes (credo flags, env, standards doc paths) live in the project skill for
that repo (SKILLS.md).

| Stack | Gates | Notes |
|---|---|---|
| Elixir (all Phoenix apps) | `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix credo --strict` | Credo findings count like failing tests, even where a CI job passes `--mute-exit-status`. A credo nesting or complexity finding is fixed with clauses or a dispatch map, never a raised limit. |
| TypeScript and React | `npx tsc --noEmit`, `npm run lint`, prettier check | Tailwind first; ITCSS for the rest; no inline styles. Node version from `.nvmrc` via nvm. |
| Vue and Quasar | `npm run lint` | Same Tailwind and no inline style rule. |
| Ruby on Rails | `bundle exec rubocop` | rubocop-rspec when the Gemfile has it; follow the repo's own guidelines doc (see below). |
| Python | PEP 8, type hints on public functions, `ruff` or `black` when the repo has them | Run any script reading downloaded data with `python3 -I`. |
| Helm and Kubernetes | `helm lint`, `helm template` renders | No secrets in values files. |

## Repo standards docs

The repo's own doc wins over this skill where they differ; read it at Intake. Look for `docs/CODING-STANDARDS.md`,
`guidelines.md` or the style section of the repo `CLAUDE.md`. The paths per repo live in the private overlay,
`skills/specific/<project>/facts/engineering-standards-stacks.md`.
