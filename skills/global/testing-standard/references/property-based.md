# Property-based tests

Open this when the code under test has an algebraic shape: a pair that undoes each other, a
normaliser, a generator with rules every output must keep, a sort, a rotation, a bake that should be
idempotent.

Adapted from Trail of Bits, property-based-testing skill
(https://github.com/trailofbits/skills/tree/main/plugins/property-based-testing), licensed
CC-BY-SA-4.0. This file is an adaptation and is shared under CC-BY-SA-4.0.

## Which property to assert

| Property | Shape | Typical use here |
|---|---|---|
| Roundtrip | `decode(encode(x)) == x` | serialising a map or grid, import then export |
| Inverse | `f(g(x)) == x` | rotate then rotate back |
| Idempotence | `f(f(x)) == f(x)` | normalisers, a re-bake, a re-seed, an upsert |
| Invariant | holds before and after | every generated map has its exits reachable; every row keeps its agency |
| Oracle | `new(x) == old(x)` | a refactor or an optimisation against the old function |
| Easy to verify | cheap check of an expensive result | `sorted?(sort(x))`, a path is connected |
| Identity | `f(x, e) == x` | merging settings with an empty map |

Strength, weakest to strongest: no crash, type kept, invariant, idempotence, roundtrip or oracle.
Assert the strongest one the code supports. Code with no such shape gets example tests, and saying so
is a valid answer.

## The two ways a property asserts nothing

- **Tautology:** the assertion recomputes the implementation (`assert add(a, b) == a + b`). A bug both
  share cannot fail it. Pick a property that constrains the result without recomputing it.
- **Vacuity:** a filter that discards most inputs (the run reports fewer cases than `max_runs`), or
  contradicts itself, runs zero real cases and passes. Build valid inputs in the generator instead of filtering them.

Same family as the degenerate oracle (skill `review`): prove the property can fail by breaking
the code once and watching it go red.

## Elixir, StreamData

```elixir
use ExUnitProperties

property "rotating four times is the identity" do
  check all grid <- grid_generator(), max_runs: 200 do
    assert grid |> rotate() |> rotate() |> rotate() |> rotate() == grid
  end
end
```

`scripts/detect-test-stack.sh <repo>` lists `stream_data` under "elixir test deps" when the repo has it.
When it is absent, adding it is his decision: offer it once with the exact property you would write, and
take the answer.

## TypeScript, fast-check

```ts
import fc from 'fast-check'

fc.assert(
  fc.property(fc.array(fc.integer()), (xs) => {
    const once = normalise(xs)
    return deepEqual(normalise(once), once)
  }),
)
```

Pure logic only. A page or component gets no fast-check or jsdom test; the batch test mode decides
whether it gets a browser test (`test-modes.md`).

## When a property fails

The library shrinks to the smallest counterexample. Before fixing code, decide whether the property
is wrong (it claimed more than the spec does) or the code is. Turn the shrunk case into a plain
example test so it stays as a regression.
