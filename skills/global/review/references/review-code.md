# Review code, inside review

Turns a file, diff, branch, commit or MR into a ranked list of defects he can act on without asking a
question, and nothing else. Run by the reviewer player on the merged diff, at orchestration row Dc; each
finding goes back as a ticket (step 11).

## Stance

- **You report, you do not edit.** Each finding becomes a ticket for a builder (`role-cards.md` Reviewer: "Never: edits code").
- **You decide alone** the severity and the order inside one severity; log each as a DECISION line in the review.
- **You never decide** whether a finding is worth fixing; he and the director do.

## Non-negotiables

1. **A finding names the input or state that breaks and what goes wrong; 0 findings is a valid review, said in one line.** Why: a padded review buries the one real defect among style notes. → `references/review-code-what-counts.md`
2. **Each finding has file:line, type, severity and the fix as code.** Why: the type is one of bug, security, performance, style, maintainability; the severity one of Critical, High, Medium, Low; a finding missing any of the four comes back as a question before anyone can act on it. → Deliverables
3. **A finding is verified before it is reported:** the caller, the tests and the upstream guard are read; a finding the code already handles is dropped. Why: no quote of his; the Gotchas row on findings retracted when he questioned them.
4. **The code is ours: a finding never says it came from someone else or from before.** State what is wrong and what fixes it. Why: anything that fails in the reviewed tree is treated as caused by our changes; a finding that points the blame elsewhere gets skipped, and the failure lands in his test on staging.
5. **A style or maintainability finding names the line a reader misreads or the bug it hides,** measured against engineering-standards and the repo's own standards file. Why: no quote of his; `references/review-code-what-counts.md`, a Low with no consequence is padding.

Violating the letter of a law is violating the law.

## Intake

Target X, resolved to concrete code. Fixed: the table below and the finding shape. Free: the order of the passes.

| He says | Read |
|---|---|
| a path (file or folder) | the files themselves |
| "the diff", "my changes" | `git diff` plus `git diff --staged` |
| "my branch" | `git diff $(git merge-base HEAD origin/HEAD 2>/dev/null \|\| git merge-base HEAD main)...HEAD` |
| a commit | `git show <sha>` |
| a GitHub PR | `gh pr diff <n>` and `gh pr view <n>` |
| a GitLab MR | `glab mr diff <n>` |

Nothing named and nothing obvious: review the working tree diff and say that is what was reviewed.

## Pipeline

Serves orchestration row Dc (the reviewer's read of the merged diff). Each Output is a section of `review-code.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Resolve X with the Intake table; read it whole, plus the callers and tests of each changed function | `Reviewed:` the target, the command run, files read | Intake |
| 2 | Read the repo's own standards (`docs/CODING-STANDARDS.md`, `.credo.exs`, the eslint config) | `Standards:` the files read, or "none found" | engineering-standards |
| 3 | One pass per type: bug, security, performance, maintainability, style | `Candidates:` one line each | `references/review-code-what-counts.md` |
| 4 | Verify each candidate (law 3); drop the ones the code handles | `Dropped:` candidate and the guard that handles it | law 3 |
| 5 | Write the replacement lines in the file's language and style | the `Fix:` of each finding | law 2 |
| 6 | Rank by severity, then by how likely the failure is | the findings, most severe first | Deliverables |

Do not skip 4 (a dropped candidate is proof it ran) or 5.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The review is long and mostly Low | Style nits counted as findings | Keep a Low only when its Why names the line a reader misreads (law 5); drop the rest | the skill's own troubleshooting, no measurement |
| He says a finding is wrong | It was not traced to a caller | Retract it plainly, then re-verify the others the same way | the skill's own troubleshooting, no measurement |

## Deliverables

`<workspace>/score/<ticket>/review-code.md` (no ticket: the reply), the sections above, then one block per finding:

```
### 1. A game's owner cannot save a map the game holds
- File: lib/game/world.ex:491
- Type: bug
- Severity: High
- Why: the owner of a game that holds the map, who did not make it, calls save_map/3; get_map/2 answers {:error, :not_found} for him, so nothing is written
- Fix:
  with {:ok, map} <- changeable_map(user, id) do   # the map's owner, the owner of a game that holds it, or an admin
```

The example is a real defect from a game repo: a later commit fixed it, and file:line is where the line stood before that commit (`git -C <repo> show <fix sha>^:lib/game/world.ex`). A finding of yours cites the line in the tree you reviewed.

Severity by consequence: **Critical** data loss, a security hole, a crash on a normal path. **High** a wrong result on
a realistic input. **Medium** wrong on an edge case, or a trap for the next change. **Low** costs reading time
later. The last line: files reviewed and the count of findings per severity.
