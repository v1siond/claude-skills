# Release and tag, inside ship

Production runs the exact commit staging already proved, under a new tag that matches the repo's scheme and
the CI trigger, cut only after his yes. The director runs it after his look and his yes (orchestration); it
carries no workflow past the tag and the one line that says which version went where.

## Stance: you are the director cutting a tag

- **You decide alone** the bump level (patch unless he says minor or major), the preflight fixes and the order of the repos in a multi-repo release.
- **You never decide** production: his word, in this conversation, after staging.
- **You never decide** to edit or delete a published tag; a bad release gets a new patch.

## Non-negotiables

1. **Production only on his word, after staging:** what deploys production is per repo (a tag for most, a push to `master` for some; the permissions file and the repo's release docs say which), and "do what's not done" is not a yes for production. Why: production is live and in use; a deploy he did not approve lands on his users.
2. **Gates first:** ship on the release tree, except a flow he set that merges the commit staging already proved (the repo's own release docs say which). Why: rubocop and lint are checked green before any push to `main` or `master`, the same as before staging.
3. **`scripts/release-preflight.sh` runs before bump:** version files lag the newest tag and a naive `bump.sh patch` recreates a published tag. Why: the old Critical line of this skill.
4. **Release from the release branch:** every `publish.sh` tags and pushes the CHECKED OUT branch, so `master` (or `main`) is checked out and staging is merged `--no-ff` first; a tag off a feature branch ships unreviewed code. Why: the release is `git merge --no-ff origin/staging` into master, then bump, then publish; a release that skipped the merge shipped nothing.
5. **The real change is committed before bump:** a repo's bump script may run `git add --all` (the preflight blocks a dirty tree), so anything uncommitted lands in "Bump version". Why: the old Critical line of this skill.
6. **The repo's own scripts run as they are, no re-analysis of the process:** `bump.sh` then `publish.sh` (a repo may keep them in a subfolder; the repo's own release docs say where). A repo with no `bump.sh` and `publish.sh` gets them built from another project's pair, so bump and publish work the same in every repo. Why: time went into re-analysing a deploy process that the two scripts already run.
7. **The scheme and the trigger are per repo** (the repo's own release docs hold the tag pattern, the version file and the trigger of each repo; `references/release-and-tag-release-matrix.md` indexes them); ArgoCD image-updater ignores `latest` and picks the newest build, so a redeploy needs a new image tag, never a re-pushed `latest`. Why: in the CI he set, a push to `master` or `staging` deploys staging and a bumped tag deploys production.
8. **A published tag is never edited or deleted and a release branch is never force pushed;** a bad release gets a new patch. Why: the old Critical line of this skill.
9. **Release notes are the four MR lists in his voice,** with no attribution in tag messages or notes. Why: a note holds what was implemented and any config or env step to set, nothing else.

Violating the letter of a law is violating the law.

## Intake

| Input | Where |
|---|---|
| repo and its scheme | the repo's own release docs (index: `references/release-and-tag-release-matrix.md`), `scripts/release-preflight.sh` |
| his go | "deploy to prod", "staging is validated", "bump and publish" in this conversation |
| bump level | patch unless he says minor or major |
| what is in staging | `git log origin/master..origin/staging --oneline` |

Fixed: the scheme per repo. Free: the wording of the one-line report.

## Pipeline

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Confirm what he asked: staging only, or production; production without a clear yes: ask one line, "Is staging validated? Then I tag prod." | the target | law 1 |
| 2 | Get on the release branch with staging merged: `git checkout master` (or `main`), `git pull`, `git merge --no-ff origin/staging` when staging holds the release | the release branch | law 4 |
| 3 | `scripts/release-preflight.sh <repo>`; fix every BLOCK (wrong branch, dirty tree, behind upstream, tag already exists); a WARN for a lagging version file: set the file to the newest tag's number in its own commit, or pass explicit versions to `bump.sh`, then rerun | no BLOCK | law 3 |
| 4 | Run ship on this tree if the repo's flow calls for it | READY | law 2 |
| 5 | With his yes: `echo Y | ./bump.sh patch` (or the subfolder script the repo's release docs name), check the commit it made, then `echo Y | ./publish.sh`; a hook that needs another node runs inside `bash -l` with `nvm use` (engineering-standards) | the tag pushed | laws 5, 6 |
| 6 | Watch the pipeline he can see (GitLab or GitHub) until the production job starts; read its log on red | pipeline state | law 7 |
| 7 | Report: version, tag, commit, what it deployed to, pipeline state | the one line | the Release line of SKILL.md Deliverables |

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| `publish.sh` fails, tag already exists | The version file lagged | `git tag -l`, align the file to the newest tag, bump again | the v2.1.0 troubleshooting row |
| Pushed master, prod did not change | Master deploys staging only | Production needs the tag | Seen: CI deploys `master` and `staging` to staging; only a tag deploys production |
| The tag was created before the tracking script was pushed | `publish.sh` tagged before the push | The pre-push step generates the file, commits and pushes it, then the tag | Seen: on the api, where the tag triggers the deploy, the tag went out before the generated tracking script was pushed |
| Tag pushed, no production run | The tag does not match the pattern the CI listens for | Tag the pattern in the repo's release docs, through `publish.sh` | the v2.1.0 troubleshooting row |
| ArgoCD keeps the old image | Only `latest` moved, which it ignores | A new build with a new sha tag | the v2.1.0 troubleshooting row |
| A hook fails during bump with a node syntax error | An old node in the shell | `nvm use` the repo's version (engineering-standards) | the v2.1.0 troubleshooting row |
| The production job is blocked by a red lint job | A gate failed on the tag's tree | Run the gates, fix, new patch | the v2.1.0 troubleshooting row |
| Nothing on the Actions page after "deploy to prod" | The merge, bump and publish were not run | Merge `--no-ff origin/staging` into master, bump, publish | Seen: after his deploy to prod ask, master had no merge, no bump and no publish |
