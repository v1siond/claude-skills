# Spec template (headings in the project's language; a project skill may name its own, see its references)

A spec says WHAT we build, for whom, and what the user puts in and gets out. It never says HOW the code
does it: no tables, fields or types, no backend functions or callables, no component trees, no file
paths, no code identifiers. That is the plan (`plan.md` beside the spec, skill engineering-standards),
which is not part of the spec.

```
# <Feature name>
Date, version, author, status in one line (Draft for review | Approved | Built).

## Index                          (only when more than 6 sections)

## 1. Summary
3 to 5 sentences. First: the client's goal. Then what we build and the result they get.

## 2. Problem and goals
The client's request in their words (quoted, their language). Goals as measurable lines.

## 3. Requirements
Numbered R1, R2 ... each one sentence of what the product must do, with its source in brackets
(the client's line, his decision with date, or the doc section it comes from).

## 4. Scope
**In scope**: one line per deliverable.
**Out of scope**: one line each, what this release does not do.

## 5. Users and permissions
Table: action | role as the app names it on screen ... with qualifiers ("only their own", "in the project").

## 6. Flow overview
One mermaid flowchart of the user's journey across the features: screens and choices, never backend steps.

## 7. Features
### 7.N <Name>
Purpose (one line). Who. When (what the user does to start it).
Visual proposal: the mockup PNG of the screen (rendered from the HTML proposal in `proposta/`), and the
demo screenshot when the screen exists today, each with one line saying what it shows.
Expected input: table, field as labelled on screen, what the user enters or picks, rules (numbers).
Expected output: what the user sees or receives, with the exact UI label or message.
Errors: table, case, message shown, what happens.
Scenarios: numbered, Given / When / Then, the rule applies and the rule does not apply.
Diagram only when it helps the reader: a user flow, or the states the user sees (stateDiagram-v2).

## 8. Edge cases
Table: case, expected behaviour, as the user experiences it.

## 9. Decisions
Table: decision, reason in one line, date. Only decisions already taken.

## 10. Delivery
Milestones in order with dates when known: what reaches the demo first and what the real side.

## 11. Open questions
[OPEN QUESTION] each with the context needed to answer it and who answers.
```
