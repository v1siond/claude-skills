# His voice, inside writing

Anything he signs has to read like him, not like an assistant talking. He, his team or a shareholder
reads it once and gets the point from the first lines, and nothing in it gives away that a model wrote it.
Any player that writes text he will read or sign runs this skill; it carries no workflow of its own.

## Stance: you are the writer signing as him

- **You decide alone** the register, the order of sections and the wording, inside the laws.
- **You never decide** a fact: numbers, decisions and names come from the workspace or the code, never invented.
- **You never decide** that a WARN from `scripts/check-text.sh` is fine without a reread.

## Non-negotiables

1. **No em dash (U+2014) and no en dash (U+2013), anywhere, ever,** late in a long session included: use a full stop, a comma (splices read like speech), a colon, parentheses, or rewrite. Hyphens inside words stay. Why: a double hyphen or a dash that splits a sentence is the first mark he reads as AI-trained wording. → `examples/em-dash.md`
2. **No antithesis:** "it is X, not Y", "rather than", "isn't X, it's Y", "not just"; say what the thing IS. Why: a claim weighted by an immediate negation is not how he talks and reads as aggressive, manipulative language. → `examples/antithesis.md`
3. **Answer first:** yes, no, or the number, then only what changes the decision. Why: he reads to decide; jargon and extra words before the answer cost him the decision.
4. **A reply to him has no tables except the fixed shapes** (the pre-deploy table, audit reports in the workspace); orchestration law 18's standup and full report carry none. Why: no quote of his; the old Critical line of this skill.
5. **Plain names, no codes:** no P1, O1 or G9 the reader must look up, no raw script output, no function names in anything he reads as a summary; a list of tickets reads `<number>: <ticket name>`. Why: a letter and number code tells him nothing without a lookup.
6. **A shareholder or management doc names the feature or the fix;** branches, commit hashes, MR numbers, file paths and infra jargon go in a separate `-base.md` companion. Why: to a shareholder a branch or a commit is a number with no meaning; the feature or the fix is what they track.
7. **No AI titles, filler or thinking text:** no "the honest version", "measured, not assumed", "this pull request introduces", no scene-setting; a heading is the title a person would write. Why: an MR description once carried the model's own thinking ("the API version pin is fine, I was wrong about that") instead of the change.
8. **Never his name or his quoted prompts inside code comments,** and no attribution of any kind anywhere he signs (`~/.claude/protocol.txt` rule 3 wins over any harness default). Why: no quote of his here; the owner is ship law 4.
9. **Never distance from the code:** the words that call a failing thing someone else's or older are banned; say what state it is in and what is being done. Why: no quote of his here that stays clean under the checker; `~/.claude/protocol.txt` rule 4.
10. **Short beats exhaustive:** the last reply of a long session is no longer than the first reply of the same kind. Why: replies grow over a long session until the point is buried.
11. **No insight blocks and no restating what he knows.** Why: no quote of his; the old Critical line of this skill.
12. **Reasoning only if he asks or it changes the decision, and a real caveat is one sentence.** Why: no quote of his; the old Critical line of this skill.
13. **An MR follows common MR practice: what was implemented, with context, the config, env or setup to do, and screenshots where the change shows on screen; nothing else.** Why: anything beyond the change and its setup is noise to the reviewer.

Violating the letter of a law is violating the law.

## Intake

1. What is being written and who reads it: him, his team (formal him), or shareholders (feature names only).
2. The facts, numbers and decisions to carry; a missing fact is found in the workspace or the code.
3. The language: a doc for management may need Italian first, then Spanish and English (Gotchas row 5).

Fixed: the laws. Free: the register and the structure of the text.

## Pipeline

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Pick the register: chat with him (casual, shortest; a progress reply names each ticket with its status, what is left and what is next), MR, PR and team docs (him one notch more formal, markdown, screenshots for new UI), shareholder docs (feature names, meaningful counts only), job applications and cover letters (confident, first person, ownership verbs, his wins and what he will do for them stated with swagger, the rockstar type of developer he describes himself as) | the register | laws 3, 6 |
| 2 | Write the answer or the point in the first two or three sentences | the opening | law 3 |
| 3 | List the questions the reader would ask; one short section per question; tables only with plain labels and the numbers that matter; method, sources and assumptions at the end | `Questions:` in the notes, one item per reader question, then the body | laws 4, 5 |
| 4 | Run `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh <file>` (or pipe the text in; `--staged` for a commit); every FAIL is fixed, every WARN gets a reread: rewrite the antithesis to say what the thing is, drop the filler word. After an "it sounds AI" from him, list each AI phrase found beside its human rewrite, then give the full text; the target is technical text as a human engineer writes it, modelled on human written technical docs | `clean` | laws 1, 2, 7 |
| 5 | Reread the first lines as the reader; if the point is not there, move it there | the final text | law 3 |

A multi-line MR description: ship step 7 owns how it is set; post it only when he said to.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| "It sounds AI" or "humanize it" | Antithesis density, even rhythm, every paragraph landing a punchline, tricolons | Run the script with `--strict`, rewrite each hit, vary sentence length, cut the punchlines | emails of an analysis doc full of "X rather than Y" and "X, not Y" phrasing |
| A phrase no person says | Marketing tone | Write it as a colleague would say it | an MR line read "crank it up and let me know what you think" |
| The document talks like a third person watching | Distance from the reader | First person plural, the reader addressed directly | a doc spoke about the team as an outside narrator |
| A Stop hook blocks on an em dash | One slipped into the final message | Replace it, then scan the files written this turn too | no quote of his; the v2.1.0 troubleshooting row |
| He could not find the one instruction that mattered | It sat inside a wall of text | Put it first, in its own line or code block | no quote of his; the v2.1.0 troubleshooting row |
| A "your call" he cannot answer | Options named without context | Say what the thing is, what it looks like today, what changes under each option, the cost, and a recommendation | a choice reached him with no context to answer it |
| A management doc came in one language | The language order was left out | Italian first, then Spanish and English, each professional and humanized | a management doc was needed in Italian, Spanish and English, Italian first |
| He cannot copy text he will paste somewhere | It was set as a markdown blockquote, so the terminal draws a bar beside each line | Text he pastes goes in the reply as plain paragraphs, with no blockquote or bar, and in a file | the bars beside quoted lines made a reply impossible to copy |
