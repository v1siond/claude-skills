# Git workflow, inside ship

Every change lands on the right branch in his voice, and leaves the machine only when he said so or a
standing permission covers it. Builders commit their own paths; the director pushes and merges on his yes.
It carries no ticket workflow of its own: the pushes and merges it describes are steps of orchestration.

## Stance: you are the player committing, the director pushing

- **You decide alone** the commit boundaries, the message, the branch check, the feature branch name and the local half of moving a commit off `staging`; the pushes of the cherry-pick wait for his ask.
- **You never decide** a push, a merge into a shared branch or a tag. His yes does, or a standing permission in `references/git-workflow-standing-permissions.md` that names the exact case.
- **You never decide** that a rule of one project holds in another: overrides live in that file, one section per project.

## Non-negotiables

1. **Local commits by path are free; nothing leaves the machine without his yes.** A standing permission lives in `references/git-workflow-standing-permissions.md`, one section per project, and covers exactly the case it names. Why: pushes went out with commits he had not asked to push, onto branches others deploy from. → Pipeline step 4
2. **Feature branches by default:** `git branch --show-current` runs before every commit, and `staging` and `master` take no direct commit unless `references/git-workflow-standing-permissions.md` says so for that project. Why: commits landed on `staging` more than once when the branch was not read first. → Gotchas row 1
3. **The gate runs on the exact tree before any push** (`references/pre-deploy-protocol.md`); a push "to test it" is allowed only where a standing permission says so. Why: pushes made before rubocop and the full suite were green broke the tests on the shared branch.
4. **No attribution line of any kind, and no Claude file in the repo:** the harness reminder that asks for one loses to CLAUDE.md. Why: commits and repos carry his name only, and Claude lines and files kept appearing because the harness reminder asks for them. → `references/git-workflow-commit-voice.md`
5. **Commit and MR text is in his voice,** and `/home/visiond/projects/claude/skills/global/ship/scripts/check-commit-msg.sh` exits 0 on it. Why: text under his name that reads as AI written (a `--` between clauses, stock phrases) is text he has to rewrite.
6. **A shared branch (`staging`, `master`, `main`, `testing`) is never force pushed;** `--force-with-lease` is for your own feature branch only. Why: a force push of `testing` overwrote the remote; merging `testing` into the local `testing` first, then merging on top, keeps both histories.
7. **No half pushes:** every commit a change needs goes up together, and a consumer never points at a dependency commit that is not pushed. Why: the "no half pushes" row of one project in the v2.1.2 standing permissions.
8. **In a shared tree you commit by path and never `git add -A` blind:** `git status` is read first. Why: the v2.1.2 troubleshooting row on a commit that took another lane's lines.
9. **Plans, notes, `CLAUDE.md` and `.claude/` never go into a repo** (where they live: orchestration law 1). Why: Claude data belongs outside the repo, in the folder above it; a tracked context file ships it to every clone.

Violating the letter of a law is violating the law.

## Intake

1. The branch and the state: `git branch --show-current`, `git status --short`, `git log --oneline -5`.
2. The project's rules: its section of `references/git-workflow-standing-permissions.md` (standing permissions, overrides, merge order).
3. The feature branch name: the one he named, the existing branch for the ticket, or one you name from the commit subject (`fix/<slug>`), logged as a DECISION; never wait on a name.
4. The message rules: `references/git-workflow-commit-voice.md`.

Fixed: the checks and the standing permission lookup. Free: the commit boundaries and the wording of the subject.

## Pipeline

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Read the branch and the status; on `staging` or `master` with no override, `git switch <feature>` (create it from the up-to-date base if it does not exist) | the branch | law 2 |
| 2 | Stage only the change's paths; write the message and run `/home/visiond/projects/claude/skills/global/ship/scripts/check-commit-msg.sh -m "<msg>"`; in a shared tree `git add <your paths> && git commit -m "<msg>" -- <your paths>`, after `git diff -- <path>` when another lane may touch the same file | a staged set that is only yours | laws 5, 8 |
| 3 | Commit on the working branch as soon as each piece works, so a rollback loses little work | `<sha> <subject>` | law 1 |
| 4 | Push, merge into a shared branch or tag only with his yes or under a named standing permission; say which covered it, otherwise show the commits and wait | the push line or "waiting on your yes" | laws 1, 3 |
| 5 | Accidental commit on `staging`: the local half runs at once, `git switch -c <feature> origin/staging && git cherry-pick <sha>`, then `git branch -f staging origin/staging` when `git log origin/staging..staging` lists only that commit; the two pushes and the `--no-ff` merge of the 6 steps below wait for his yes unless his message said "cherry-pick to X" | the commit on the feature branch, local staging equal to origin/staging, pushes waiting | law 2 |
| 6 | Merges follow the project's order (its section of `references/git-workflow-standing-permissions.md`); after every merge run `python3 -c "import yaml; d=yaml.safe_load(open('.gitlab-ci.yml')); print(sorted({j['stage'] for j in d.values() if isinstance(j,dict) and 'stage' in j}-set(d.get('stages',[]))))"`, which prints `[]` | the merge pushed under a standing permission, or waiting | `references/git-workflow-standing-permissions.md` |
| 7 | MR text: the four lists (implemented, changed, set, run), written to writing write-docs law 11 for a reader with none of our context: every change, update and config or env step, with the context a reviewer needs and screenshots where the change shows on screen; a screenshot goes in only when the test that took it asserts every expected element is present in the rendered view; a multi-line description goes through the API or the web UI, because a push option carries one line (git refuses a newline in it) | the MR text | `references/git-workflow-commit-voice.md` |
| 8 | Before a range goes up: `/home/visiond/projects/claude/skills/global/ship/scripts/check-commit-msg.sh -r origin/<base>..HEAD`, `git ls-files | grep -i claude` and `git grep -in claude` print nothing | exit 0 | law 4 |

The 6 steps of step 5:
- `git checkout <feature-branch>`
- `git cherry-pick <commit-sha>`
- `git push origin <feature-branch>`
- `git checkout staging`
- `git merge --no-ff <feature-branch>`
- `git push origin staging`

The feature branch keeps the history for the MR, staging gets the merge commit. No worktrees or clones (orchestration).

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Commit landed on `staging` | No branch check before the commit | The 6 steps of Pipeline step 5 | Seen: a commit landed on `staging` more than once |
| He found a push he never asked for | A push was treated as part of the commit | Law 1; a push waits for his word or a named standing permission | Seen: a push went out that he had not asked for |
| Tests and lint red after a push | The push ran before the gates | Law 3, ship on the exact tree | Seen: rubocop and the suite were red on the shared branch after a push |
| `testing` was force pushed | A behind branch was overwritten | Merge `testing` into the local `testing`, merge on top, push | Seen: `testing` was force pushed over a remote that was ahead |
| Claude references in commits or the repo | The harness reminder or a tracked context file | Law 4; scan `git ls-files | grep -i claude` before a PR goes up and never mention the omitted footer in the report | Seen: Claude references reached commits after the harness reminder asked for a footer |
| `git push origin testing` rejected "protected branches" | The push ran as a developer account; `testing` takes pushes from him as maintainer | Check the remote account, never route it through an MR unless he asks | the v2.1.2 troubleshooting row |
| A merge pushed fine but no pipeline appeared | `.gitlab-ci.yml` uses an undeclared stage, a config error creates no pipeline | Declare the stage, push again | the v2.1.2 troubleshooting row |
| The MR description arrived as one long line | A push option carries one line (git refuses a newline, GitLab strips `\r`); a push option rides only on a push that updates a ref ("Everything up-to-date" drops it) | Set it through the GitLab API or the web UI | the v2.1.2 troubleshooting row |
| A commit took another lane's lines in a shared file (labels.json, config.yml) | The lane wrote the file between your diff and your add | Write `git show HEAD:<file>` plus only your lines to a scratch file, `git hash-object -w` it, `git update-index --cacheinfo 100644,<sha>,<file>`, check `git diff --cached --name-only` is only your paths, commit with NO pathspec (`git commit -- <file>` takes the file from disk again), then check `git show HEAD -- <file>` | the v2.1.2 troubleshooting row |
| A commit hook fails with a node syntax error | husky ran under node v10 | `nvm use 24` in that shell (engineering-standards) | the v2.1.2 troubleshooting row |
| The MR has apology text like a version pin note | Thinking text copied into the MR | Only what was implemented and any config or env to set | Seen: an MR description held a note that a version pin was fine after all |
