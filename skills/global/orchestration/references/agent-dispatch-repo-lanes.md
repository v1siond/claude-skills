# Lanes per repo

Every repo: the one main checkout on the current branch, its one dev database (his, agents never touch it)
and its one test database. 0 worktrees, clones, partition databases or extra build folders (SKILL.md law 1).
Agents work on disjoint files and commit their own paths on the working branch (they never push); runs that
collide go one at a time. A repo with no overlay row: read its `config/test.exs`, `package.json` scripts,
`Makefile` or CI file for the test command.

The per-repo rows (agent test command, what is reserved, limits) live in the project skills or the private
overlay, because a global holds no project rows: `skills/specific/<project>/facts/orchestration-repo-lanes.md`,
read when the ticket's repo has one.

