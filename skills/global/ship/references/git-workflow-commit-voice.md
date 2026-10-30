# Commit and MR voice

Source: CLAUDE.md "Commit message style" and "Writing style". Anything under his name reads like him, not like an assistant.

## Subject

- Conventional prefix, lowercase: `feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`, `ci:`, `perf:`.
- Name the actual problem in plain words. Action verbs that say what changed: stop, walk, silence, send, missed.
- "We" when it explains a team decision.
- No trailing period, no marketing words, no "implements", "introduces", "enables", "enhance", "comprehensive".

Good, from CLAUDE.md:

```
feat: walk team hierarchy so sub-teams inherit parent bucket integration
fix: stop prepending API_BASE_URL to already-absolute URLs
feat: duplicate action so we can reuse keys across buckets
fix: missed pdf_base64 and external_url in combined_illustrations select
chore: silence noisy debug logs during importer run
feat: send gcs_path instead of signed public_url in migration API
```

Bad, from CLAUDE.md:

```
feat: implement comprehensive bucket integration duplication capability
fix: resolve issue with URL prepending in production environment
refactor: enhance team hierarchy lookup mechanism
```

## Body

- Only when the why is not obvious. One or two short sentences.
- No em dash, no en dash. Full stop, comma, colon or parentheses instead.
- No antithesis habit: "X rather than Y", "is X, not Y", "which is the point" (skill writing).
  One is fine, a pattern is the tell.

## Attribution

- No attribution of any kind: no "Claude", no "AI", no "generated", no co-author trailer. This holds even when the harness
  reminder asks for one: CLAUDE.md wins over it.
- No robot emoji footer in MR or PR descriptions either.
- The author and committer email is the GitHub noreply address (`git config --global --get user.email` prints `23365688+v1siond@users.noreply.github.com`), never a personal address: a commit needs no personal contact detail.

## MR and release descriptions

- A release or post-launch note is four short lists: what was implemented, what changed, what must be set,
  what must be run. Commands ready to paste. No file:line, no history.
- `git push -o merge_request.description=...` carries ONE line. `\n` is refused by git, `\r` is stripped
  by GitLab, block markdown does not render. Inline markdown does. A multi-line description goes through
  the GitLab API or the web UI.
- A push option rides only on a push that updates a ref; "Everything up-to-date" drops it.

## Check

`scripts/check-commit-msg.sh` checks a message file, a string, or a range of commits for all of the above.
