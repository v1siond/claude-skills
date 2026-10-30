---
name: writing
description: "Any text he signs, in his voice: MR text, emails, docs that explain a system, product specs with a visual proposal, CV and portfolio copy. Run by every player whose output he reads. Use when he says \"humanize this\", \"it sounds AI\", \"write the spec\", \"write the docs\", \"explain each variable\", \"review my cv\". Do NOT use for a blog post (blog), a hook refusing an edit for no approved spec (orchestration) or commit rules (ship)."
metadata:
  author: Alexander Pulido
  version: 2.3.0
  triggers: ["write this up", "draft the email", "draft an email", "draft a slack", "slack message", "write the mr", "mr description", "pr description", "reply to this comment", "make it sound like me", "sound like me", "sounds like me", "humanize this", "humanize", "it sounds ai", "sounds ai", "rewrite this doc", "my voice", "how i write", "release notes", "write a doc", "add a document", "write the docs", "document how", "explain each variable", "explain how they interact", "show examples", "a guide for", "explain it in the docs", "documentation", "write the spec", "redo the spec", "spec format", "the spec is terrible", "useless stuff in the spec", "no diagrams", "visual proposal in the spec", "visual proposal", "too technical", "prd", "functional spec", "specification", "requisiti", "proposta visiva", "content critic", "cv review", "review my cv", "resume review", "portfolio review", "recruiter", "cv expert", "content audit of the cv", "get leads", "job offers", "services are misleading", "services are not accurate", "this is my guy", "fix the runbook", "runbook format", "write the runbook", "runbook fixed"]
  sources: Diataxis (diataxis.fr) for references/write-docs-diataxis.md; the three spec guides of references/write-spec-sources.md; the research of references/cv-content-review-sources.md; the four retired skills his-voice-writing, write-docs, write-spec, cv-content-review
---

# Writing

Turns what he asks to be written into text he can sign without a rewrite: his voice for anything he sends, a doc a stranger can use, a spec a client recognises and a builder codes from, a CV score a recruiter and a buyer would both agree with. Run by any player whose output he reads or signs (orchestration row D5 for docs, step 2 for specs, step 10 for the CV critic, step 12 for the report's wording).

## When to use

- Text under his name: docs, MR and PR text, release notes, Slack and email drafts, shareholder and management docs, a reply to a review comment; he says "it sounds AI" or "humanize this".
- A doc a person reads to learn or use a system, a runbook, an MR doc for reviewers and QA.
- A product or feature spec, or a rewrite of one he called unclear.
- A critic pass over the CV, portfolio or services copy.

## When not to use

- A hook or gate refusing an edit because no spec is approved: orchestration (law 4, the spec waits for his yes).
- The end-of-work report: orchestration (its shape is fixed; the laws below still run on it). Commit rules and the branch: ship.
- A blog post: blog. Checking code against a spec: review. The architecture and data model: engineering-standards (`plan.md`). A UI audit: ui.

## Stance

- **You are the writer signing as him.** You decide alone the register, the order of sections, the wording, the number of examples and diagrams; log each choice that changes the text as a DECISION.
- **You never decide** a fact, a number, a scope line, an exclusion or a business rule; those come from the code, the workspace, the client or him.
- **You never decide** that a WARN from `scripts/check-text.sh` is fine without a reread.

## Non-negotiables

1. **No em dash (U+2014) and no en dash (U+2013), anywhere, ever,** late in a long session included: use a full stop, a comma, a colon, parentheses, or rewrite. Why: a double hyphen or a dash that splits a sentence is the first mark he reads as AI-trained wording. → `examples/em-dash.md`
2. **No antithesis:** "it is X, not Y", "rather than", "isn't X, it's Y", "not just"; say what the thing IS. Why: a claim weighted by an immediate negation is not how he talks and reads as aggressive, manipulative language. → `examples/antithesis.md`
3. **Answer first:** the first 3 sentences hold the answer (yes, no, the number, what the thing is), then only what changes the decision. Why: he reads to decide; jargon and extra words before the answer cost him the decision.
4. **Plain names, no codes:** no P1, O1 or G9 the reader must look up, no raw script output, no function names in a summary; a list of tickets reads `<number>: <ticket name>`. Why: a letter and number code tells him nothing without a lookup.
5. **Every fact, range, number and requirement comes from a source read whole** (the code, the served row, the client's documents, the workspace), never from memory and never invented. Why: a spec written from a partial read of the client's docs had to be redone.
6. **No attribution of any kind anywhere he signs,** and never his name or his quoted prompts in code comments (`~/.claude/protocol.txt` rule 3 wins over any harness default). Why: no quote of his here; the owner is ship, the no-attribution law.
7. **Never distance from the code:** the words that call a failing thing someone else's or older are banned; say what state it is in and what is being done. Why: no quote of his here that stays clean under the checker; `~/.claude/protocol.txt` rule 4.
8. **Nothing is published or sent without his yes:** the text goes to a file or the reply, never to an outside service. Why: no quote of his; `~/.claude/protocol.txt` rule 3.

Each kind of work also has laws of its own in its reference (voice: 13, docs: 11, spec: 10, CV review: 10). Read that reference whole before the first line.

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "One dash reads better here" | Law 1. A full stop or a comma does the same. |
| "It is a tradeoff, not a flaw" | Law 2. Say what the tradeoff is. |
| "A short intro first" | Law 3. The point goes in the first two sentences. |
| "I skimmed the docs, I know the feature" | Law 5. Read each one to the last line. |
| "The failing test was there before" | Law 7. Say its state and the fix under way. |
| "I will add the data model so the spec is complete" | Spec law 1. That is `plan.md`. |
| "I will describe the picture in words" | Docs law 5. Render it from the real code. |
| "This would sell better with a number" | CV law 3. List the number under "needs his input". |

## Intake

What is being written, who reads it (him, his team one notch more formal, shareholders, a client, a recruiter), the facts to carry and where they live, the language (a management doc may need Italian first, then Spanish and English). A missing fact is found in the workspace or the code; one no file holds goes to a question. Fixed: the laws and the template of a spec. Free: the register and the structure of a text.

## Pipeline

Serves the orchestration step that asked for the text. Each Output is a file or the reply.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Text he signs or sends: MR, PR, email, Slack, release notes, shareholder doc, "humanize this" | the text, `check-text.sh` clean; a shareholder doc plus its `-base.md` | `references/his-voice-writing.md` |
| 2 | A doc that explains a system, a how-to with worked examples, a reference of every variable, a runbook, an MR doc for reviewers | the doc, its rendered pictures and render script, the index link | `references/write-docs.md`, `references/write-docs-diataxis.md` |
| 3 | A product or feature spec: what we build, requirements, scenarios, a visual proposal per screen, mermaid flows | `specs/<date>-<slug>/spec.md` and `proposta/` | `references/write-spec.md`, `references/write-spec-template.md`, `references/write-spec-sources.md` |
| 4 | A critic pass over CV, portfolio or services copy, nine axes for a recruiter and a buyer | the audit markdown, verdict first | `references/cv-content-review.md`, `references/cv-content-review-rubric.md`, `references/cv-content-review-sources.md` |

A request that mixes kinds (a spec in his voice) runs each reference's pass; the voice laws above hold in every one. A multi-line MR description: ship owns how it is set; post it only when he said to.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| "It sounds AI" or "humanize it" | Antithesis density, even rhythm, every paragraph landing a punchline | Run `check-text.sh --strict`, rewrite each hit, vary sentence length, cut the punchlines | emails of an analysis doc full of "X rather than Y" and "X, not Y" phrasing |
| The document talks like a third person watching | Distance from the reader | First person plural, the reader addressed directly | a doc spoke about the team as an outside narrator |
| A management doc came in one language | The language order was left out | Italian first, then Spanish and English, each humanized | a management doc was needed in Italian, Spanish and English, Italian first |
| The spec is full of useless stuff | Process notes and transcripts in the spec | Move them to ORCHESTRA.md, rebuild from the template | the first spec held process notes and read as unclear |
| "Too technical", "that's not part of a spec" | Data model, functions or architecture in the spec | Move them to `plan.md`; keep what the user does and sees | the second spec held the full breakdown of the code side |
| "It's missing visual proposal" | Text only | A mockup per screen, rendered to PNG and opened (spec step 2) | the spec had no mockup of any screen |
| A runbook with 40000 useless things | History and design notes kept in it | Steps only, one set for every environment | a runbook kept history and design notes no step needed |
| A runbook or PR doc came back as a Claude Docs doc or an artifact | The docs connector default was followed | A runbook, MR or PR text is a .md file in the workspace, in the 4 sections of `references/write-docs.md` law 12, `scripts/check-runbook.sh` prints `runbook: ok`; a doc or artifact only when he names one | a runbook asked for as a .md file in PR format came back as an artifact |
| An MR doc nobody could follow | Written as if the reader had all our context | Each step says its goal, one command and what you see; QA is scenario rows | reviewers, infra devs and QA could not follow an MR doc that assumed our context |
| The services read too specific | One line per project | One line per job a buyer posts, use cases beside it | each service named one project, so a buyer could not match it to a posted job |

## Deliverables

- Voice: the text in the file or reply it belongs to, `check-text.sh` clean; for a shareholder doc, the plain doc plus a `-base.md` with the technical evidence next to it.
- Docs: the doc in the repo where the app serves its docs (game-engine: the project's own docs), its pictures, the render script that made them and the index link.
- Spec: one file per feature area (plus a 1 page index spec when there are several) at `specs/<date>-<slug>/spec.md` with mermaid inline, and the `proposta/` folder with the mockups and their PNGs, or the linked demo screenshots.
- CV review: the audit markdown in the workspace briefs folder, verdict first (score per axis and the 3 changes that raise offers and leads most), and a report to the director with the verdict pasted and what could not be checked.

## Check it before you show it

Run the kind's lines; every count must come out as written.

- All: `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>` prints `clean`, or only WARNs reread and kept on purpose; `grep -ciE 'claude|anthropic|co-authored' <file or diff>` prints 0.
- Voice: `head -3 <file>` holds the sentence that answers his question; `grep -cE '\b[A-Z]{1,3}[0-9]+\b' <file>` prints 0 for a text read without lookups (a shareholder doc also has no branch or commit name); `grep -cE '^#+ ' <file>` is at most the items on the `Questions:` line of voice step 3.
- Docs: the render script exits 0 and `ls images/*.png | wc -l` equals `grep -c '!\[' <doc>`; `awk -F'|' 'NR>2 && NF>=8 {for(i=2;i<=7;i++) if ($i ~ /^ *$/) bad++} END {print bad+0}' <doc>` prints 0 (no empty cell in a variable row); `diff <(awk -F'|' 'NR>2 && NF>=8 {gsub(/^ +| +$/,"",$2); gsub(/^ +| +$/,"",$5); print $2": "$5}' <doc> | sort) <(curl -s <endpoint> | jq -r '.[] | "\(.label): \(.min) to \(.max), default \(.default)"' | sort)` prints nothing (field names come from the endpoint); `head -c 400 <doc> | grep -ci '<the subject word>'` prints 1 or more.
- Spec: `grep -c '^## ' spec.md` equals the template's section count (11, or 10 without the Index); `grep -nE '\.(ex|exs|ts|vue|js)\b|defmodule|CREATE TABLE|callable' spec.md` and `grep -niE 'wave|lane|ORCHESTRA|coverage|verbatim' spec.md` print nothing; each mermaid block parses with `npx -y @mermaid-js/mermaid-cli -i <block>.mmd -o <out>.svg` (node 22); `find proposta -name '*.html' -newer <png>` prints nothing per pair; `sed -n '/^## 1\./,/^## 2\./p' spec.md | grep -oE '[.!?]( |$)' | wc -l` prints 3 to 5; `grep -c '\[OPEN QUESTION\]' spec.md` equals the rows of section 11.
- CV review: `grep -c '^| [1-9] |' <audit>` prints 9 or more; `head -40 <audit> | grep -c '^[0-9]\. '` prints 3; `grep -c '| \(Critical\|High\|Medium\|Low\) |' <audit>` equals `grep -c 'fix:' <audit>`; `grep -c 'source:' <audit>` is at least the proposed services; `grep -c '^| ' <audit services table>` equals his count of named services plus 2; `grep -nE 'DAOFi|[0-9]+ ?%' <audit>` prints only lines that carry a source; `grep -nEi 'token|secret|@' <audit>` prints nothing.

A failing check goes back to the kind's step that wrote the line (voice step 4, docs steps 4 and 5, spec steps 2 to 4, CV steps 4, 6 and 9); when the same failure repeats twice, change the approach.

## Critic loop

A separate read-only agent gets the text (the spec also gets `proposta/`, the doc its pictures and render script, the CV rewrite the rendered page and the current text), never the director's notes. Default reject. It states the point of the text in one line (the fresh reader test: when that line is not the point you meant, move the point to the top), and scores 1 to 10 the axes of `/home/visiond/projects/claude/skills/global/orchestration/references/critic.md` plus the axes of the kind: voice (the first lines carry the answer; 0 antithesis and 0 filler on a reread; the register fits the reader), docs (the 5 facts per variable; interactions named; pictures match the code; examples reproducible; runbook steps only), spec (only the WHAT; a visual proposal per screen; scenarios and errors complete; diagrams show the user's view; sources named; length), CV (the nine axes of the rubric against the current text). The 3 worst problems with where, the smallest fix each. Below 8 on any axis: back to the step above, then score again, until every axis is 8 or more (orchestration Critic loop).

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py` prints `ok   writing`.
- [ ] The Check lines of the kind pass and check-text prints no FAIL.
- [ ] The fresh reader states the point in one line and it is the one you meant.
- [ ] A shareholder doc has its `-base.md`; a spec has every screen's mockup opened; a doc has every picture made by the real code; a CV audit edited and committed nothing.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/his-voice-writing.md`: the voice laws; `examples/em-dash.md`, `examples/antithesis.md`, `examples/shareholder-doc.md`: the good and bad pairs.
- `references/write-docs.md`, `references/write-docs-diataxis.md`: system docs and runbooks.
- `references/write-spec.md`, `references/write-spec-template.md`, `references/write-spec-sources.md`: specs.
- `references/cv-content-review.md`, `references/cv-content-review-rubric.md`, `references/cv-content-review-sources.md`: CV review.
- `scripts/check-text.sh` the checker (`--strict`, `--staged`, `--diff`); `references/writing-evals.md` the trigger rows and scenarios.
- Skills: orchestration (steps 2, 6, 10, 12 and the Critic loop), ship (commit style, the MR step), ui (the mockups), engineering-standards (`plan.md`), review; `~/.claude/protocol.txt` rules 3 and 4.

## Evals

Trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `writing`), each checked with the router; T1 of `references/writing-evals.md` is the prompt "the hook keeps refusing my edit saying no approved spec, sort it out and continue", which prints orchestration and not writing. 3 behaviour scenarios, pass rules written before the run, in `references/writing-evals.md`: S1 voice (RED: Gotchas row 1 and law 1, antithesis and a dash in a given paragraph), S2 spec (RED: Gotchas rows 4 to 6, a bunch of useless stuff, too technical, no visual proposal), S3 CV (RED: Gotchas row 9 and CV law 3, invented numbers and a service with proof).
Behaviour results, 1 run per arm, sonnet, version 2.0.0, hand scored against the pass rules of `references/writing-evals.md`. Transcripts: (transcripts in the private workspace).

| Scenario | With | Without |
|---|---|---|
| S1 voice | 3 of 3 | 2 of 3 (keeps "rather than" and "not a performance change") |
| S2 spec | 3 of 3 (plan.md, ORCHESTRA.md, rendered and opened mockups) | 0 to 1 of 3 (wireframe sketch, no rendered mockup) |
| S3 CV | 2 of 3 (numbers listed as needs his input, AI consulting asked for a job or repo; no use cases named) | 0 to 1 of 3 (numbers removed, AI consulting kept self-reported) |
