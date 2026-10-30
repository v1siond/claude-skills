# The skill framework

Every skill in this set is built in this shape. It is taken from the three motion skill repos he pointed
at (Chan's product-launch-motion with its legacy skill, Howseen's motion-design, Charlie's
motion-graphics-skills). Those skills work because they are not suggestions: they carry a purpose line,
numbered laws, the thoughts that mean a law is being broken, a pipeline whose steps
leave files, the gotchas that cost hours, the exact deliverables, and a done list that checks the
delivered thing. Where those repos carried the author's words as the spec, this set carries the
instruction his feedback implies: a quote of his is turned into the step it asks for, never pasted.

A skill is a process to follow exactly. If a step is in the skill, it runs, every time, in order.

## Contents
- The sections, in this order
- Rules for writing the sections
- Writing for the model
- The empty template

## The sections, in this order

| # | Section | What it holds | From |
|---|---|---|---|
| 1 | Title and purpose | One paragraph: what this skill makes, for whom, and the outcome it guarantees. | Chan |
| 2 | When to use, when not | Two short lists. The "not" list names the sibling skill to use instead. | Chan legacy |
| 3 | Stance | The role the player takes, in 3 to 6 bold lines. What it decides alone (log it as a DECISION), what it never decides. | Chan |
| 4 | Non-negotiables | Numbered laws. Each: the rule in bold, then why in one plain sentence (what goes wrong without the rule, or what was measured), then `→` the reference that holds the detail. Ends with: "Violating the letter of a law is violating the law." | Chan, Chan legacy, Howseen 0 |
| 5 | Red flags | Table: Thought \| What it actually means. Each row is a thought that came before a real failure, and the law it breaks. | Chan legacy |
| 6 | Intake | "Ask for N things, then wait", or the exact list of inputs and where each comes from. Fixed vs free: what never changes, what the player decides. | Charlie, Howseen 9b |
| 7 | Pipeline | Table: # \| Step \| Output \| Reference. Every step leaves a file (or a named section in a file), so a skipped step is visible. STOP rows say who must answer before the next step. "Do not skip" names the steps that are never optional. | Chan legacy, Howseen 1 |
| 8 | Gotchas | Table: Symptom \| Cause \| Fix \| Proof. Every row happened for real; Proof is what was measured or observed, in plain words; no dates, no quotes. | Chan, Howseen 6 |
| 9 | Deliverables | The exact files, their names and where they go. Nothing is delivered that is not on this list. | Chan Output |
| 10 | Check it before you show it | How the DELIVERED thing is verified (the page, the file, the build), not the source. Numbers with thresholds. Fix what fails, check again, only then show him. | Charlie, Chan verify |
| 11 | Critic loop | A separate read-only judge, never the builder. Default reject. Axes scored 1 to 10, the 3 worst problems with where, the smallest fix each. Repeat until every axis is 8 or more. | Howseen 8, 9c, 11 |
| 12 | Definition of done | Checkbox list. The first box: `python3 scripts/lint-skills.py` prints `ok   <name>`. The last box: "You have written down what you would fix next." Then: "Anything less, say so plainly." | Chan legacy, Howseen 7 |
| 13 | References | Reference map (load only what the current step needs), scripts, templates, worked example. | Chan legacy |
| 14 | Evals | 10 to 20 trigger queries (should and should not); 3 or more behaviour scenarios with a RED baseline (what happened without the skill), the GREEN result and the model each ran on. Canon lines in `references/canon.txt`. | Chan legacy, skill-craft |

## Rules for writing the sections

- **Feedback becomes an instruction, never a quote.** His correction is read for what it asks the work to do differently, and that becomes a step, a law or a check written in plain descriptive words. Frustration, swearing, typos and the story of the incident are dropped; the instruction stays. A requirement keeps his domain nouns ("Z-width / depth" stays "Z-width / depth"). Before: `Why, 07-23: *"please read the fucking prompt history"*`. After: `Why: git log shows what changed, not what he asked; the thread comes from his prompts.`
- **A law is something a check can fail.** Never "good", "clean" or "careful". Name the file, the number, the threshold or the thing he sees.
- **A step that leaves no file did not happen.** The Output column names the file or the section.
- **A law enforced by a script beats a law written in prose** (Chan's assemble.mjs). When a deterministic check exists, the step runs it.
- **Gotchas are only real incidents,** with their proof. No invented warnings.
- **A project skill holds only the project's facts** (paths, commands, names, its own gotchas) and says which global skill step it serves. It never carries its own workflow; the workflow is orchestration.
- **A correction from him fixes the step that was skipped.** No new section, no new hook, no story, unless the step truly does not exist.
- 80 to 200 lines in SKILL.md; detail goes in `references/`, one worked example per file in `examples/`.
- No em or en dashes, `check-text.sh` clean.
- Name in kebab-case, equal to the folder. Description in the third person, 1024 characters or fewer, no `<` or `>`.
- References sit one level deep from SKILL.md (SKILL.md links every file it needs). A reference file over 100 lines opens with `## Contents`.
- Every script step names its install line and its pass output. Every constant in a script has a comment with its reason.
- No line that goes stale on its own ("currently", "as of"), and no dates.
- The Definition of done is copied into the player's report and ticked as the work runs; a failed box names the step it goes back to.
- Evals: 10 to 20 trigger queries (should and should not), 3 or more behaviour scenarios with a RED baseline, the model each ran on. The scenarios are written before the skill text.

## Writing for the model

The standard is the Howseen motion-design SKILL.md, Anthropic's "The Complete Guide to Building Skills for
Claude" and its best practices page, with the MindStudio post as a secondary source (his ask). The
evidence, every quote and the 60 Howseen number-for-word swaps: `writing-standard.md`. The Howseen SKILL.md itself (MIT): `/home/visiond/projects/claude/standards/howseen/motion-design-SKILL.md` (kept word for word, outside the skills so its dashes stay as written).

**The rule.** Anything a check can measure is written as a number with a unit and a direction, a formula, a
command with its pass output, or a named thing (a file, a skill, a reference style). Prose is kept for taste,
stance and the order of work, and then it carries a test that passes or fails. Howseen: "smooth" is "90-110
BPM", "snappy" is "spring 320/30", "not bouncy" is "damping ratio ≥ 0.72", "readable" is "≥ 0.7 s on screen,
≤ 17 chars/s". The anti-example: "Validate the data before proceeding" (Anthropic's guide, page 13).

**The line shape.** Subject, rule, number, reason in under 10 words: "Linear motion = cheap, never.",
"subframes 6 to 8 for fast moves (4 = ghosting)". `=` and `→` are allowed as grammar. Bold marks the rule
inside a line. Capitals only on one load-bearing word ("ONE accent colour") or a status token.

**Freedom per step, by what a mistake costs.** A step that deletes, migrates, pushes, spends or checks is
low freedom: an exact command or a script. A step of taste is high freedom with a stated default and a pass
test. The pipeline itself is low freedom: every step runs, in order, every time.

**The tests a critic fails a skill on.**

| # | Fails if |
|---|---|
| W1 | A quality word (good, clean, proper, careful, fast, smooth, nice, real, closed, measurable, solid, robust, simple) stands in an instruction with no number and unit, backticked file or command, or named reference on the same line. |
| W2 | A threshold has no unit or no direction (≥, ≤, >, <, "or more"). |
| W3 | A check, verify, control or QA step has no command or file and no pass value. |
| W4 | A check that counts, greps, diffs or compares is written as prose instead of a script or command. |
| W5 | A step that deletes, migrates, pushes or spends is prose; or a taste step is forced into one fixed procedure with no reason given. |
| W6 | A number or a non-obvious rule has no reason (the consequence seen, or a source). |
| W7 | One thing has two names (ticket, row, batch, wave, lane, score each defined once), or a named skill does not exist in SKILLS.md. |
| W8 | A "never" does not say, on the same line, what to do instead. |
| W9 | Our own text adds IMPORTANT, CRITICAL, MUST or an all-caps sentence. |
| W10 | A rule about the shape of an output has no filled example (input and output, or before and after). |
| W11 | A taste or judgment rule gives no way to tell pass from fail. |
| W12 | A condition ("when large", "if needed", "for small fixes") has no size, count or time. |
| W13 | A numbered law or step holds more than two independent rules. |
| W14 | A loop (repeat, iterate, fix and check) has no numeric stop and no "back to step N". |
| W15 | A path or skill name does not resolve, or a reference is reached only through another reference. |
| W16 | A reference file over 100 lines has no `## Contents`. |
| W17 | Two or more options are listed with no default first. |
| W18 | The description fails the shape: what, when (his phrases), Do NOT (sibling), third person, 1024 characters or fewer, no `<` `>`. |
| W19 | Evals are missing or unnumbered (row 14 above). |

His intent wins over every source, written as an instruction (rule above), and nothing taken from a source
keeps a dash (`writing-standard.md` section E).

## The empty template

```markdown
---
name: <name>
description: <what it does>. Run by the <player>. Use when he says "a", "b", .... Do NOT use for X (sibling).
metadata:
  author: Alexander Pulido
  version: 1.0.0
  triggers: [...]
---

# <Title>

<What it makes, for whom, and the outcome it guarantees.>

## When to use
## When not to use
## Stance
## Non-negotiables
1. **<Law>.** Why: <what goes wrong without it, or what was measured>. → `references/<file>`

Violating the letter of a law is violating the law.

## Red flags
| Thought | What it actually means |
|---|---|

## Intake
## Pipeline
| # | Step | Output | Reference |
|---|---|---|---|

Do not skip <steps>.

## Gotchas
| Symptom | Cause | Fix | Proof |
|---|---|---|---|

## Deliverables
## Check it before you show it
## Critic loop
## Definition of done
- [ ] ...
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References
## Evals
```
