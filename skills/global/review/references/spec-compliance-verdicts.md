# Verdicts, evidence and severity

Adapted from Trail of Bits, spec-to-code-compliance skill
(https://github.com/trailofbits/skills/tree/main/plugins/spec-to-code-compliance), licensed
CC-BY-SA-4.0. This file is an adaptation and is shared under CC-BY-SA-4.0.

## The six verdicts

| Verdict | Means | Evidence it needs |
|---|---|---|
| implemented | The code does what the requirement says, in every case it names. | The lines that do it, and a test or a run that shows it. |
| partial | Some cases are met, others not. Usually the most serious: it looks done. | The cases met, the cases missed, the lines for each. |
| contradicted | The code does something the requirement forbids, or the opposite. | The requirement text beside the contradicting lines. |
| stronger than spec | The code enforces more than asked (a limit, a check). An undocumented constraint. | The extra rule and where it lives. |
| absent | Nothing implements it. | The searched record: every grep, every file read, and what each returned. A verdict of absent without the record is not a verdict. |
| undecidable | The requirement is too vague to check. A finding against the doc, not the code. | The ambiguous words and the two readings. |

A verdict resting on a promising function name is not a verdict. Read the body, follow the calls,
and where possible run it.

## The reverse direction

After the requirements pass, list behaviour the code has that no requirement mentions: endpoints,
settings, limits, side effects. Each is either missing from the spec or should not exist.

## Refutation

Every finding that is not "implemented" gets one honest attempt to disprove it before it is
reported: look for the code path that does satisfy it, a config that turns it on, a test that proves
it. Done by a different agent than the one that produced the finding when sub-agents are in use.
Findings that survive are reported; the ones refuted are listed as refuted with the reason.

## Severity, by consequence

- Critical: data lost or corrupted, money wrong, access granted that should not be, a law of the spec broken.
- High: a user-visible feature does not do what the spec promises.
- Medium: an edge case or a family member missed.
- Low: naming, wording, a doc that is behind the code.

Severity follows what happens to the user or the data, not how big the diff to fix it is.

## Report row

```
R<n> <requirement, quoted or one line> (<spec file>:<line>)
  verdict: <one of six>   severity: <level>
  evidence: <file:line read>, <test or run>
  searched: <every grep and file read, with what each returned> (on every absent row)
  refutation: <what was tried to disprove it, and the result>
```
