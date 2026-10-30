# Toolchains per repo

Read from each repo's pin files and CI, and from this box. Version managers on the box:
asdf v0.8.0-rc1 (activated in `~/.bashrc`, resolves `.tool-versions` per directory), nvm (default alias
24.15.0), mise 2026.4.27 (activated in `~/.bashrc` AFTER asdf, but asdf's shims still win for Elixir).
Installed node under nvm: 10.22.0, 16.13.2, 18.17.0, 20.20.2, 22.9.0, 22.14.0, 22.21.1, 24.15.0.
The global asdf Elixir is 1.19.3 on OTP 26.

The pins, first-time setup and run commands of each repo live in the private overlay,
`skills/specific/<project>/facts/engineering-standards-repo-toolchains.md`. Read the repo's own pin files
(`.tool-versions`, `mise.toml`, `.nvmrc`) and CI image first; the overlay row only records what they miss.

## Get it running locally

Postgres, Redis, MySQL and Mongo already run in Docker on this box (`projects-postgre-1` on 5432, a
replica on 5434, redis 6379, mysql 3306, mongo 27017). Do not start, stop or reconfigure them;
they are his.

On an EXISTING dev database never run `ecto.reset` or `ecto.drop`. Migrations and setup on local databases:
skill ship.

## Box quirks that look like code bugs

| Symptom | Real cause | Fix |
|---|---|---|
| jest prints only `Unexpected token .` | node v10 from the inherited PATH | `export PATH=$HOME/.nvm/versions/node/v24.15.0/bin:$PATH` |
| "eslint can't load, Node too old" | same | switch with nvm, never report the tool as unrunnable |
| `undef elixir start_cli` or "compiled for a later version of the run-time system" in a repo pinned by `mise.toml` | asdf shim (old OTP) instead of mise | `mise exec --` prefix |
| `Error loading module 'Elixir.Inspect': corrupt file header`, suite dies in 2s | 0-byte `.beam` files in `_build/<env>/consolidated/` after a killed compile | `find _build* -name '*.beam' -size 0`, delete that env's `consolidated/` |
| forum markdown renders escaped, `<img>` tests fail after a fresh build | mdex precompiled NIF needs glibc 2.34, box has 2.33 | copy the locally built `.so` over it |
| husky pre-commit fails in a node repo | node v10 in the commit shell | `bash -l -c 'source ~/.nvm/nvm.sh && nvm use 24 && cd <repo> && git commit ...'` |
| a Phoenix endpoint fails to bind | `runtime.exs` reads PORT and the default is a privileged port | set `PORT` (the repo's overlay row names the value) |
| `mix deps.update <git_dep>` does not move the pin | git dep lock | `rm -rf deps/<git_dep> && mix deps.unlock <git_dep> && mix deps.get` |
