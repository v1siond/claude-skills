# Which control for which choice

| Kind of choice | Control | Notes |
|---|---|---|
| one of 2 to 4 (a mode, a formula, Flat or Formulas) | segmented toggle | one always lit, immediate effect, a one line hint under it |
| on or off | segmented toggle Off / On, or a single switch | never a lone checkbox in a game editor kit that forbids them |
| several of few, independent (layers) | a row of toggle chips, lit when on, in their real order | a summary line of what is on; an All / reset link |
| a filter over a list | a list of selectable items, never pills | pills run out of space as the options grow |
| one of many (a served list) | a picker with search, pictures when the thing has one | |
| a number with a range | slider with a number box | range served by the backend |
| a whole number count | number box with minus and plus | |
| an ordered set of points (a curve) | a small graph with the points editable, the list beside or folded | the shape is what the user reads |
| a group of settings | a section that folds in place, its value shown beside its name when closed | own reset |

Sources:
- Unity Editor Design System, UX checklist: https://unityeditordesignsystem.unity.com/foundations/ux-checklist
  (labels without colons, tooltips on every control, disabled explains why, works at 275px, left aligned).
- learnui.design, Selection Controls UX checklist: https://learnui.design/extras/selection-controls-ux-checklist.html
  (2 options checkbox or toggle, 3 to 5 segmented, many: typeahead, multiple: checkbox list or chips).
- Vercel, Web Interface Guidelines: https://vercel.com/design/guidelines (focus-visible, clickable labels,
  one hit target per checkbox and label, empty states, specific button labels, no colour-only state).
- Anthropic, frontend-design skill: https://github.com/anthropics/skills (plan tokens and two ASCII wireframes,
  critique the plan for generic choices, a quality floor, every word earns its place).
