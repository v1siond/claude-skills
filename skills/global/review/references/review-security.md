# Review security, inside review

Lists every exploitable weakness in what he named, each as an attack someone can run, rated, ranked and given
the exact fix. Run by the reviewer player on the merged diff, at orchestration row Dc; each finding goes back
as a ticket (step 11).

## Stance

- **You report, you do not edit.** Each finding becomes a ticket for a builder.
- **You decide alone** the severity within the scale and the order inside one severity; log it as a DECISION line.
- **You never decide** to install an audit tool, rotate a key or touch a shared database.

## Non-negotiables

1. **A finding is an attack:** who sends what (a request, a param, a file) and what they get; with no path from an attacker to the code there is no finding. Why: a theoretical weakness with no attacker path is padding, and it buries the exploitable one. → `references/review-security-checklist.md`
2. **The path is verified before the finding is reported:** the router pipeline, the plug, the policy and the changeset are read; a guard upstream drops the finding. Why: no quote of his; the Gotchas row on "missing validation" findings.
3. **All three classes are walked on every entry point:** injection (SQL, command, XSS), authentication and authorization, sensitive data exposure. Why: a security review he asks for covers these three classes; a class skipped on one entry point is where the hole stays.
4. **Each finding is rated Critical, High, Medium or Low with the exact fix, and the list is ranked by severity.** Why: he reads the list top down and fixes in that order; an unranked list or a vague fix makes him do the triage.
5. **A fix uses the framework's own safe API** (Ecto params and `^` pins, `Phoenix.HTML` escaping, `System.cmd/3` with an argv list), never a shell string. Why: no quote of his; `references/review-security-checklist.md`, the safe-form column.
6. **A live secret is never printed:** name the file and line, show it masked, say rotate it. Why: no quote of his; `references/review-security-checklist.md`, secrets row.
7. **An audit tool that is missing is reported, never installed without his yes;** list the risky dependency versions by hand. Why: no quote of his; the old skill's troubleshooting section and orchestration law 14 (nothing leaves or changes the machine without his yes).

Violating the letter of a law is violating the law.

## Intake

1. Target X as in review (Intake table: path, diff, branch, commit, `gh pr diff`, `glab mr diff`).
2. The router and its pipelines, auth plugs, the policy or context functions that check ownership.
3. `config/runtime.exs` and any `.env*` file in the diff.

Fixed: the three classes and the scale. Free: the order of entry points.

## Pipeline

Serves orchestration row Dc. Each Output is a section of `review-security.md`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Resolve X and read the Intake files | `Reviewed:` target, files read | Intake |
| 2 | Map the entry points X touches: routes, LiveView events, controllers, jobs, CLI tasks, webhooks | `Entry points:` list with file:line | law 3 |
| 3 | Walk `references/review-security-checklist.md` on each: injection (SQL `fragment` with interpolation, raw `Repo.query` strings; command `System.cmd` through `sh -c`, `:os.cmd`; XSS `raw/1`, `dangerouslySetInnerHTML`, `v-html`; `String.to_atom` on input; path and template), authN and authZ (IDOR, mass assignment, 403 against 404, CSRF, webhook signature), exposure (secrets, PII in logs, full structs as JSON), and also (unsafe `binary_to_term`, SSRF, open redirect, weak crypto) | `Checked:` entry points by class | `references/review-security-checklist.md` |
| 4 | Dependency audit: `mix hex.audit`, `mix deps.audit` if installed, `npm audit --omit=dev` | `Audit:` each command and its output, or "missing, listed by hand" | law 7 |
| 5 | Verify each candidate upstream (law 2) | `Dropped:` candidate and the guard | law 2 |
| 6 | Write the exact fix; rank Critical first, then by how easy the attack is | the finding blocks | laws 4, 5 |

Do not skip 3 for any entry point or 5.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Many "missing validation" findings | The input is validated in the changeset, not the controller | Read the changeset before reporting | the skill's own troubleshooting, no measurement |
| A dependency audit command is missing | The tool is not installed | Say so in the report; list the risky versions by hand | the skill's own troubleshooting, no measurement |

## Deliverables

`<workspace>/score/<ticket>/review-security.md` (no ticket: the reply), sections above, then one block per finding:

```
### 1. Any signed-in user rewrites another user's art style
- File: lib/game_web/controllers/tileset_controller.ex:71
- Class: authorization (IDOR)
- Severity: High
- Attack: a signed-in user sends PUT /api/tilesets/<other id> with a tileset body; the action loads the row with Catalog.get_tileset!(id) and Catalog.update_tileset/2 never compares the row's owner with the session user, so the row is rewritten, built-in styles included
- Fix:
  Catalog.update_tileset(conn.assigns.current_user, id, tileset_params)   # owner or admin; {:error, :not_found} for anyone else
```

The example is a real defect from a game repo: a later commit fixed it, and file:line is where the unguarded call stood before that commit. Your finding names the route and the guard you read in the tree you reviewed.

Severity: **Critical** unauthenticated access to data or code execution. **High** an authenticated user reaches
another user's data or escalates. **Medium** needs an unlikely precondition, or leaks metadata. **Low** defence in
depth. The last line: files reviewed, counts per severity, any secret to rotate.
