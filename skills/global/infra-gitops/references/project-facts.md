# Project facts, a private overlay

The contexts, cloud project and subscription ids, repo paths, app lists, state buckets, tunnel hosts, release rows and CLAUDE.md corrections of each project live outside this public repo:

- `skills/specific/<project>/facts/` in the private skills repo, for a project kept there.
- `~/.claude/local-skills/<project>/facts/` for a project kept on this machine only.

Each holds the same files:

- `layout.md` the repo trees, the updater style and the secret path per cluster, and the corrections to each repo's CLAUDE.md.
- `access-and-commands.md` the kube context names, the dev shell per repo, the tunnel commands.
- `pre-deploy-gates.md` and `release-matrix.md` the project rows ship reads.

When neither folder exists (a reader of the public repo), keep the same files for your own projects in a private place and point this file at it.
