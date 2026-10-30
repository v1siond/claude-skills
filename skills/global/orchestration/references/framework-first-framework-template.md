# Framework template

Open this when writing a framework that does not exist yet. The shape follows the existing ones in
`docs/` in a game repo (WATER.md, TESTING.md, OBJECT-CONSTRUCTION.md): answer first, rules numbered, sources
named, a checklist that is a gate. Write it in his voice (plain words, no codes, no em or en dashes).

```markdown
# <Context name>

<Two or three sentences: what this settles and when to open it.>

## Sources

1. <Title>, <author or vendor>, <URL>, read <YYYY-MM-DD>. <One line on why it is trusted: official docs, engine source, the author's own talk.>
2. <Video title>, <URL>, transcript <WS path>, facts at [00:03:12], [00:07:40].
3. <His correction, written as the instruction it implies: what the work does differently from now on>.

## The fundamentals

<What real products or engines do, each claim ending in its source number: "Godot stores collision
shapes on the node, not on a grid [1]".>

## The rules

1. <Rule.> Why: <the measured defect or the source>. [n]
2. ...

## Traps already paid for

- <Symptom>: <cause>, <fix>.

## The checklist

Walk it item by item before reporting a change it covers, and state the evidence for each.

1. <Checkable item.>
2. For a FAMILY of things: does the evidence cover EVERY member?
3. Which items could you NOT verify? Say which.

## Not covered here

<Neighbouring contexts and the doc that owns each.>
```

After writing it, add its row to the project's index (FRAMEWORKS.md "What exists"), and remove it from
"What is missing" if it was listed there.
