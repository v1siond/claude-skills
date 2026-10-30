# Rubric

## Nielsen's 10, scored 0 to 4

Per heuristic: 4 excellent (nothing to fix), 3 good (minor issues), 2 acceptable (several issues, a person
copes), 1 poor (a key task suffers), 0 failing (a key task fails). `n/a` only with a one line reason.

1. Visibility of system status: the person always knows what mode, what is selected, what just happened.
2. Match with the real world: their words, not codes, column names or engine terms.
3. User control and freedom: undo, cancel, Esc, a way back from every state.
4. Consistency and standards: one control per kind of choice, one name per function, platform conventions.
5. Error prevention: defaults that work, constraints on input, no destructive one-click without undo.
6. Recognition over recall: options visible, current values shown, nothing to remember between screens.
7. Flexibility and efficiency: shortcuts and batch actions for experts, without hurting newcomers.
8. Aesthetic and minimalist design: nothing on screen that does not help the task.
9. Help users recognise, diagnose and recover from errors: what happened, why, how to fix, in plain words.
10. Help and documentation: hints and tooltips where needed, findable, in the task's words.

Total bands (all ten scored, out of 40): 36 to 40 excellent, 28 to 35 good, 20 to 27 acceptable, 12 to 19
poor, under 12 critical. With `n/a` rows use the percent: 90, 70, 50, 30.

## Cognitive load checklist (8)

Single focus per region; chunks of 4 or fewer; related things grouped; a clear hierarchy; one decision at a
time; 4 or fewer choices at a decision point (or a picker); nothing to hold in memory between steps;
progressive disclosure (advanced folded). 0 to 1 failures low, 2 to 3 moderate, 4 or more high.

## Personas (pick two that fit the scope)

- Power user in a long session: wants keys, batch edits, no confirmations.
- First-timer: needs clear labels, obvious next step, hints.
- Keyboard-only user: every action by keys, visible focus, sensible order.
- Stress tester: odd input, reload mid-edit, back button, huge maps, empty data.
- Small screen user (only where the app supports one): reachable actions, sheets that keep their tabs.

## Severity

- P0: blocks a key task. Fix now.
- P1: major difficulty or likely mistake. Fix before he ships.
- P2: annoyance with a workaround. Next pass.
- P3: polish.

Source: Impeccable `reference/critique.md` (pbakaus/impeccable, Apache 2.0), adapted; Nielsen Norman Group.
