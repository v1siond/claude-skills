# What counts as a finding

A finding names a failure. Padding names a preference.

## Real

- `material` from the query string goes into `String.to_atom/1`. `?material=asdf` mints a new
  atom per request and atoms are never collected. Security, High. Fix: a whitelist map.

  ```elixir
  @materials %{"stone" => :stone, "wood" => :wood}
  material = Map.get(@materials, params["material"])
  ```

- A catalog read at module scope (`const TILES = catalog()`) runs before the API answers, so it freezes
  the EMPTY catalog and a brute deals 8 damage instead of 18. Bug, High. Fix: read it in a function at
  call time.
- `cast(attrs, [:name])` while the form sends `:height`: the height is silently dropped. Bug, High. Fix:
  permit the key.

## Padding (drop it)

- "Consider adding more comments." No failure named.
- "This function could be split." Only a finding when its size hides a real bug or blocks a change he
  asked for.
- "Great use of pattern matching!" Praise is not a finding.
- Re-describing what the code does.

## Severity, by consequence

| Severity | Consequence |
|---|---|
| Critical | data loss, a security hole, a crash on a normal path, a migration that cannot be rolled back |
| High | wrong result on a realistic input |
| Medium | wrong only on an edge case, or a trap the next change will fall into |
| Low | costs real time to read or change later |
