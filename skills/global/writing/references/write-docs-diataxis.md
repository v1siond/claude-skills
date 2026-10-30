# Diataxis, the four kinds (diataxis.fr, Daniele Procida)

| Kind | Serves | Holds | Never holds |
|---|---|---|---|
| Tutorial | learning, by doing | one guided path from nothing to a result, every step works | choices, theory |
| How-to | a goal the reader already has | a recipe: the goal, the steps or values, the result | teaching from scratch |
| Reference | looking something up | every variable, setting, endpoint, dry, complete, same shape per entry | opinions, stories |
| Explanation | understanding | how and why it works, what interacts with what, trade offs | step lists |

Tell them apart by the reader's question: "teach me" (tutorial), "how do I get X" (how-to), "what is the
value of Y" (reference), "why does it behave like this" (explanation).

For a system with tunable values (a formula, a generator), the useful set is: explanation first, then the
reference table, then how-to recipes with pictures.

## The five facts per variable (reference table row)

| Fact | Filled example (octaves of a noise layer) |
|---|---|
| Meaning in the reader's words | how many layers of detail are stacked on the terrain |
| Unit | layers (a whole number) |
| Range and default | 1 to 8, default 3 (read from the served row, never typed from memory) |
| Raising it | the hills get finer bumps; 8 is rough ground |
| Lowering it | the hills smooth out; 1 is a plain wave |
