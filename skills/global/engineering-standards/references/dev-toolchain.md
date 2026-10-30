# Dev toolchain, inside engineering-standards

Gets the shell to resolve the exact runtime the repo pins and CI uses, before any build, test or commit hook
runs, and starts the project locally without touching his databases or his build. Run by any player whose
build, test or run the shell gets in the way, in orchestration row D5 (dispatch, the builder's work).

## Contents

- Stance
- Non-negotiables
- Intake
- Pipeline
- Gotchas
- Deliverables

## Stance

- **You check the toolchain first,** because a version mismatch looks like a code bug.
- **You decide alone** which `bin` to export and which version to install; log each as a DECISION.
- **You never decide** to touch a container, drop a dev database or change a global default.

## Non-negotiables

1. **You check the toolchain before you blame the code,** with `scripts/toolchain-check.sh <repo>`. Why: the shell resolves an old node while nvm holds the right one, and the error looks like a code bug.
2. **Non-interactive shells resolve node v10.22.0** although the nvm default is 24.15.0, because the Bash tool inherits an old PATH. You export the right nvm `bin` on every command that runs node tooling, and you never report a JS tool as unrunnable because node is too old. Why: no quote of his; `scripts/toolchain-check.sh` prints 10.22.0 for this shell (old SKILL.md:25).
3. **You install a missing version, you never downgrade the repo:** a missing version is installed with nvm or asdf; a global default changes only when he asks. Why: nvm installs the latest node in one command, so a version error is fixed on the spot, never a reason to cancel the work.
4. **You match CI for gates;** otherwise day to day node work uses the latest installed (24.15.0) unless `.nvmrc` or `engines` in `package.json` pins an older major. A new app or a new dependency starts on the latest stable release, looked up online (`npm view <pkg> version`, hex.pm), never recalled. Why: work ran on node 22 while his repos are on 24 and up; a brand new app has no reason to carry an old library.
5. **You run Elixir and Ruby commands from inside the repo** so `.tool-versions` applies (asdf resolves per directory); a repo with `mise.toml` takes the prefix `mise exec --` on every mix and iex call, because asdf's shims win the PATH. Why: versions mise had installed were not found on a new terminal, because asdf's shims came first in the PATH.
6. **Databases run in Docker and are his:** you never start, stop, recreate or reconfigure a container, and never `ecto.reset` or `ecto.drop` an existing dev database. Why: postgres, redis and mysql run in his Docker containers; a command that assumes a local service fails, and a reset destroys his data.
7. **One `_build` and the one test database per repo;** compile and test runs go one at a time and never while his server compiles (skill orchestration, no copies). Why: no quote of his; old SKILL.md:35 (a project row, one `_build`), skill orchestration.
8. **At most 2 tries of the same fix,** then you read the full error and the pin files again. Why: no quote of his; old SKILL.md:42.

Violating the letter of a law is violating the law.

## Intake

| Input | Where |
|---|---|
| the repo's pins | `.tool-versions`, `mise.toml`, `.nvmrc`, `package.json` engines |
| what CI uses | `.gitlab-ci.yml`, `ci/*.yml`, `.github/workflows/*` images and setup actions |
| what the shell resolves | `scripts/toolchain-check.sh <repo>` |
| box managers, box quirks | `references/dev-toolchain-repo-toolchains.md`; per repo pins and run commands in the private overlay, `skills/specific/<project>/facts/engineering-standards-repo-toolchains.md` |

Fixed: CI wins for gates. Free: the node version for day to day work (default 24.15.0).

## Pipeline

Serves orchestration row D5 (dispatch, the builder's work).

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Run `scripts/toolchain-check.sh <repo>`: it reads the pins and CI, asks each tool its version from the repo dir, prints a fix line per mismatch | the check table | law 1 |
| 2 | Apply the fix column in the same shell as the work: the `export PATH=...` for node, the `mise exec --` prefix, `asdf install <tool> <ver>` when the version is missing | the shell fixed | laws 2, 3, 5 |
| 3 | Rerun the check until it prints "toolchain: matches" | the last line | law 1 |
| 4 | First run of a project: the "Get it running locally" table of the project overlay, `skills/specific/<project>/facts/engineering-standards-repo-toolchains.md` (deps, assets, run command, port) | the project up | law 6 |
| 5 | A symptom that still looks like a box problem: the quirks table in the reference (corrupt beam header, mdex NIF, husky); fix the box cause, rerun the original command | the original command passes | law 8 |
| 6 | Say in 1 line which versions the work ran under | the line | |

Do not skip step 3: a fix applied and not rechecked is a guess.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| `Unexpected token .` from jest or npx, nothing else | node v10 | export the nvm `bin` the check prints | the check shows this shell resolves 10.22.0 |
| Elixir `{undef,[{elixir,start_cli...` or "opcode 172" in a repo with `mise.toml` | asdf's old OTP | `mise exec --` | the check marks the repo as mise managed |
| `Error loading module 'Elixir.Inspect': corrupt file header`, dies in 2s | 0-byte beams in `_build*/<env>/consolidated/` from a killed compile | `find _build* -name '*.beam' -size 0`, delete that env's `consolidated/`, rebuild | the find prints the files |
| Markdown tests fail only after a fresh build | a native extension needs glibc 2.34, the box has 2.33 | copy the source built `.so` (the box quirks in `references/dev-toolchain-repo-toolchains.md`) | `ldd --version` prints 2.33 |
| `git commit` fails in a husky hook | node v10 in that shell | `bash -l -c 'source ~/.nvm/nvm.sh && nvm use 24 && ...'` | the hook's error names node |
| Elixir version right, OTP wrong | the global asdf erlang leaked in | check `.tool-versions` has an `erlang` line and the version is installed (`ls ~/.asdf/installs/erlang`) | the listing |
| An endpoint fails to bind | the default port 80 | the free port the project overlay row names on every mix call | the bind error; the repo CLAUDE.md says the same |

## Deliverables

- The check's table and its last line.
- 1 line: "ran under node 24.15.0, elixir 1.17.3 on OTP 27".

```
tool      pinned        ci       this shell   fix
node      22.14.0       none     10.22.0      export PATH=/home/visiond/.nvm/versions/node/v22.14.0/bin:$PATH
elixir    1.16.3-otp-26          1.16.3       ok
toolchain: 1 mismatch(es), apply the fix column in this shell before running anything
```
