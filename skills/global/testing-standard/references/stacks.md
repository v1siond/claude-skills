# Test runners per stack

Open this at pipeline step 2 to name the unit runner, the browser runner and the gates. The live check is
`scripts/detect-test-stack.sh <repo>`; the repo's own `docs/TESTING.md` and CI file win over this table.
Repo commands, ports and traps live in the project's own docs (README, CLAUDE.md, `docs/TESTING.md`).

| Stack | Unit layer | Browser layer (only in `add browser tests`) | Gates |
|---|---|---|---|
| Elixir and Phoenix | `mix test` (ExUnit) | Wallaby `FeatureCase` or phoenix_test_playwright, whichever `mix.exs` lists | `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix credo --strict` |
| TypeScript, React, Vue | the runner in `package.json` scripts, plain functions only, and only in `add browser tests` when he names one for the batch; 0 in `default` | Playwright from `package.json` scripts | `npx tsc --noEmit`, `npm run lint` |
| Ruby on Rails | `bundle exec rspec` | the repo's Capybara or Playwright setup | `bundle exec rubocop` |
| Python | `pytest` | none by default | `ruff` or `black` when the repo has them |

The runner, browser layer and gate per repo live in the private overlay,
`skills/specific/<project>/facts/testing-standard-stacks.md`.

Facts that hold across his repos:
- Credo findings count like failing tests, even where a CI job passes `--mute-exit-status`.
- In a repo with a Phoenix backend, browser tests are written in Elixir (phoenix_test_playwright or Wallaby), never a separate TypeScript Playwright suite.
- An existing Jest CI gate keeps running; migrating it is his call, asked once (law 11).
- A browser runner cannot share the Ecto sandbox, because it drives a real server; it uses the repo's own
  test database, never the dev database (law 10).
- Node comes from the repo's `.nvmrc` or `.tool-versions` through nvm; the shell default can be too old to parse the test runner.
