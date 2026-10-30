# Standing permissions and branch rules

The default is `~/.claude/protocol.txt` rule 3: local commits on the working branch are free, nothing leaves the
machine without his yes. A standing permission is his yes for exactly the case it names, nothing wider. Newest wins when two
rows clash. Each row carries the date he granted it and what he granted.

## Where the rows live

A project's rows name its repos, branches and deploy targets, so they stay out of this public repo:

| Project | Where |
|---|---|
| a project with a private overlay | `skills/specific/<project>/facts/ship-standing-permissions.md` |
| a project kept on this machine only | `~/.claude/local-skills/<project>/facts/` or its `docs/` folder |
| this skills repo | section `## claude-skills` below |

No file found for the project means no standing permission: every push waits on his yes.

## The shape of a row

| Project | What is pre-authorized | Still needs his yes | Granted |
|---|---|---|---|
| one repo, by name | the exact case: the branch, the remote, the condition (gates green, staging checked) | everything the case does not name | the date and what his message granted, in plain words |

Rules for a row:
- It names one repo. A row worded for a kind of repo ("any dependency", "every frontend") is not a standing permission; a dependency push names the dependency repo and the consumer it serves.
- It names its condition: the push gate stamp (`scripts/push-gate.sh` lets a commit out only when `scripts/pre-deploy.sh` stamped it), staging checked, or the gates green locally.
- Branch rules that are not permissions (merge order, which branch is staging, who pushes a protected branch) sit in the same file under the row, marked as such: each push they describe still waits on his yes.
- A row with no typed message of his behind it is flagged and asked about, never followed silently.

## The 6 steps of a "cherry-pick to X"

When he says "cherry-pick to X" for a commit that landed on `staging`:
- `git checkout <feature-branch>`
- `git cherry-pick <commit-sha>`
- `git push origin <feature-branch>`
- `git checkout staging`
- `git merge --no-ff <feature-branch>`
- `git push origin staging`

The feature branch keeps the history for the MR, staging gets the merge commit. Without those words the two pushes and the merge wait for his yes (`references/git-workflow.md` Pipeline step 5).

Branch rule that is not a permission: never commit on `staging` or `master` unless the project's row says so; `git branch --show-current` runs before every commit.

## claude-skills

| Project | What is pre-authorized | Still needs his yes | Granted |
|---|---|---|---|
| claude-skills (/home/visiond/projects/claude, origin github.com/v1siond/claude-skills) | push of its branch to origin, after the secrets grep over the pushed paths prints only placeholders | force push, history rewrite, a public release | 10-28: he granted pushes of the skills repo with no confirmation from him |
