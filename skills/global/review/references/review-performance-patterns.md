# Performance patterns, with the fix shape

## Ecto and Postgres

| Pattern | Looks like | Fix |
|---|---|---|
| N+1 | `Enum.map(posts, &Repo.preload(&1, :author))` or a `Repo.get` in a loop | `Repo.preload(posts, :author)` once, or a join |
| Unbounded load | `Repo.all(Thing)` on a growing table | paginate, `limit`, or stream with `Repo.stream` in a transaction |
| Unindexed filter | `where: t.label == ^l` with no index on `label` | a migration adding the index, `concurrently: true` on big tables |
| Count by loading | `length(Repo.all(q))` | `Repo.aggregate(q, :count)` |
| Wide select | loading full rows to read one field | `select: t.field` |

Measure on the TEST database: `Repo.explain(:all, query, analyze: true)` inside a test.

## Elixir

| Pattern | Fix |
|---|---|
| `acc ++ [x]` in a reduce (quadratic) | prepend and `Enum.reverse/1` once |
| `Enum.at(list, i)` inside a loop | convert to a map or tuple once, or walk in step |
| Same work inside every iteration | hoist it out |
| `Regex.compile` per call | module attribute `~r//` |
| `MapSet.member?` against a list | build the MapSet once |

## TypeScript and React

| Pattern | Fix |
|---|---|
| Heavy compute in render | `useMemo` with a stable key, or move it out of render |
| A context that changes every render re-renders the tree | split the context, memo the value |
| `useEffect` with an object literal dependency | depend on primitives |
| A 10k row list | virtualize |
| `array.find` in a loop over another array | build a `Map` once |
| A UI state change re-renders the map or canvas because both sit in one top-level layout | give the map its own tree that UI state does not reach; memo at that boundary |
| Every cell of a large map (100 by 100) drawn at full quality, on screen or not | cull outside the camera view; lower the asset detail with camera distance |
| The page gets slower the longer it stays open | a listener, timer, texture or cache never released; count it across N opens and closes (performance-expert leak test) |
