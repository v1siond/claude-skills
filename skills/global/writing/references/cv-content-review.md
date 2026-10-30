# CV content review, inside writing

A senior recruiter and a B2B buyer read his CV site at once and say what each sees in the first seconds,
what proves it, what is missing and what overclaims. Run by the critic or QA player in orchestration row V
(critic on the result) over the rendered pages and the content files; it proposes and never edits.
The site is his presentation card: the audit aims it at more job offers and leads.

## Stance

- **You are the two readers,** a recruiter and a buyer, and you score the lower of the two.
- **You decide alone** the axis scores, the severity of a finding and the smallest fix.
- **You never decide** a fact about his career; a fact no file holds goes to "needs his input".

## Non-negotiables

1. **One page, two readers.** The recruiter decides in about 7 seconds whether to keep reading; the buyer asks "does he do my kind of job, and who says so". You score each axis for both and keep the lower. Why: the themes were written for neither recruiters nor conversion, and he wants the site to bring offers.
2. **Evidence only.** A claim the facts file (its path is in the project's own docs) or a repo census does not hold is a finding, never a rewrite. His LinkedIn text stays word for word; a new sentence is marked "needs his yes". Why: the CV was out of date; his LinkedIn page is the updated overview, and he fills the gaps it leaves.
3. **Proof is a name, a year or his number,** never an invented metric. When he gave no proof numbers, the Y of an XYZ bullet is a named product, company, marketplace listing or launch year. Why: no quote of his; the retired skill's Critical list (old SKILL.md:31-32).
4. **A service carries a description and no proof,** in the buyer's words, broad enough to match the job they post; a service that reads like a job history, or is too specific to match a posted job, scores 4 or less on axis 4. He shows his expertise in calls, so a service needs no proof line. The proof lists live in experience and projects (old SKILL.md:31-35). Why: services with proof lines read like a job history.
5. **The rest are use cases:** each service has its use cases beside it, never inside the description (the audits service lists ProctorU beside it). Why: a service lists its description, and everything else it covers is a use case.
6. **A rewrite is never scored by the run that wrote it.** Proposed services, hero or summary text go to a separate critic run on the rendered page, scored against the current text, before anything ships. Why: a services rewrite shipped without a critic run and read too specific.
7. **Overclaim costs more than underclaim.** A claim a hiring manager can disprove ends the read; you flag overclaims first (Critical or High), then the work he can prove that the page hides. Why: the shipped services were misleading and not accurate enough.
8. **Dropped clients stay out.** A client he named as left off the CV never returns in a proof line, a service source or a stack item; the market experience from that work (crypto, for DAOFi) stays as a domain, without the client's name. Why: those projects no longer exist and the client is one he does not want named.
9. **You read the rendered page as well as the JSON.** What a world or `/cv` shows is the truth; a key nobody renders is Low. Why: no quote of his; the retired skill's Critical list (old SKILL.md:43-44).
10. **Read only, no secrets.** No content change, no commit; never open `.env` or key files, and never copy a token, an email address or a client person's name into the audit. Company and product names are fine. Why: no quote of his; the retired skill's Critical list (old SKILL.md:45-47).

Violating the letter of a law is violating the law.

## Intake

- The content files (`content/cv/*.json`), the facts file, the census and any services brief.
- His ask, and anything he approved before; an approved list changes only with a reason per line.

Fixed: nine axes, ship at 8 on every axis, read only. Free: the order of sections walked.

## Pipeline

Serves orchestration row V (critic on the result). Scratch files go in the scratchpad.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Fetch every page with curl and strip it to text; a screenshot of the first screen at 1440 and 390 only when no other player holds the browser | page texts | law 9 |
| 2 | Read the first screen as each reader and write 2 lines: what a recruiter knows after 7 seconds (who, level, where), what a buyer knows (what he does, for whom, proof) | the reader test | `references/cv-content-review-rubric.md` |
| 3 | Cheap checks first, by script or grep: personal pronouns in bullets, third and first person mixed, more than 6 bullets per job, titles that differ between pages, one fact spelled two ways, es and it strings left in English, dashes | the grep hits | law 2 |
| 4 | Score the nine axes in `references/cv-content-review-rubric.md`, each with the line that earned the score | the score table | laws 1, 7 |
| 5 | Walk each section (hero, summary, services, experience, projects, ventures, skills, side professions, contact, PDF): first seconds per reader, findings with severity, file and key, smallest fix | findings table | laws 7, 9 |
| 6 | Services: list what the evidence holds, grouped the way a buyer scans (build, rescue, AI, domains, platform); each row has title, 1 line in buyer words, use case and source line; every service he names gets in, merged or out with the reason; every shipped service gets keep, rewrite, merge or drop | services table | laws 4, 5, 8 |
| 7 | Rewrites in English only, each string tagged with its source (LinkedIn verbatim, HISTORY line, census line, or "new, needs his yes") | the rewrites | laws 2, 3 |
| 8 | List what needs his input: facts no file holds | the questions | law 2 |
| 9 | Run `check-text.sh` on the audit; fix every FAIL | clean output | |

Do not skip step 2: an audit without the reader test reads as style notes.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The thought "this would sell better with a number" | a metric he never gave | use the named product, listing or year; list the number under "needs his input" | rubric axis 2 |
| A proposed service has only "his words" behind it | no repo or job behind it | merge it into a service with evidence, or put it under "needs his input" | services he named were to be derived from his experience and projects |
| The audit reads as style notes | the reader test was skipped | step 2, before any finding | the reader test lines |
| A proof line names a client he dropped | the census lists it as evidence | the facts file's left off list wins; find another proof or drop the claim | a dropped client came back through the census |
| The services read too specific | one line per project | one line per job a buyer posts | each service named one project, so a buyer could not match it to a posted job |
| A service line carries a proof | the old rule allowed 1 proof | move it to a use case | services were to be descriptions, with use cases beside them |
