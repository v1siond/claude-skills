# Patterns he wants, with code

Open this when writing control flow, error results, structure or comments. Elixir first, TypeScript second.

## Contents

- Guard clauses: Elixir has no early return, so use separate clauses
- Dispatch map instead of an if or case chain over a value
- Guards in TypeScript
- Never collapse "none" and "failed"
- SOLID and structure
- One owner per fact
- Comments
- The optimal version first


## Guard clauses: Elixir has no early return, so use separate clauses

Law 1 points here. Nesting goes 1 level deep at most. In Elixir the guard is a
second function clause with `when` or a pattern in the head; a chain of steps that can fail is a `with`.

Before, nested branches (fails law 1):

```elixir
def price(policy) do
  if policy.active do
    if policy.premium > 0 do
      policy.premium * rate(policy)
    else
      0
    end
  else
    0
  end
end
```

After, the deciding value in the head:

```elixir
def price(%{active: false}), do: 0
def price(%{premium: premium}) when premium <= 0, do: 0
def price(%{premium: premium} = policy), do: premium * rate(policy)
```

A happy path through several steps that can fail uses `with`, no `else` unless an error must be
reshaped:

```elixir
with {:ok, file} <- fetch(path),
     {:ok, rows} <- parse(file),
     :ok <- validate(rows) do
  insert(rows)
end
```

When the deciding value is computed, pipe it into a private multi-clause function that matches
on it: `policy |> status() |> handle_status(policy)`.

## Dispatch map instead of an if or case chain over a value

```elixir
@handlers %{"csv" => CsvParser, "xml" => XmlParser, "txt" => FlatParser}

def parser_for(ext), do: Map.fetch(@handlers, ext)
```

A new format is one new entry in the map.

```ts
const handlers: Record<Tool, (e: PointerEvent) => void> = { paint, erase, select }
handlers[tool]?.(event)
```

## Guards in TypeScript

```ts
function save(map: GameMap | null): Result {
  if (!map) return { error: 'no map' }
  if (!map.tiles.length) return { error: 'empty map' }
  return persist(map)
}
```

## Never collapse "none" and "failed"

`nil` for both "there is no record" and "the lookup broke" hides failures. Return
`:none | {:ok, value} | {:error, reason}` and match all three at the caller.

## SOLID and structure

Law 3 points here. Each line is a rule a reviewer can point at in the diff.

- **SRP:** one reason to change per unit. A unit that decides and performs, or fetches and formats, is split.
- **OCP:** extend by adding, never by editing a working chain: a new dispatch entry or a new clause (law 2).
- **LSP:** an implementation of a behaviour or interface is substitutable for every other one: the same
  inputs accepted, the same result shapes returned, no error shape the caller does not match.
- **ISP:** narrow interfaces. A caller depends only on the functions it calls; a behaviour whose callbacks
  some implementers leave as stubs is split.
- **DIP:** depend on abstractions and inject dependencies. The logic receives the client (an Elixir behaviour
  with the module passed in or read from config, a TypeScript function argument); it never calls a concrete
  HTTP or storage client from inside.
- **Composition over inheritance:** build behaviour from small functions and modules passed together.
- **Small pure functions, side effects at the edges:** the logic takes data and returns data; the Repo call,
  the HTTP call and the file write sit in the caller.
- **Immutability by default:** 0 shared mutable state, 0 module level mutable globals.
- **Extract loop bodies into named helpers.** Private helpers are named for what they compute
  (`overdue_days/1`, `visible_tiles/2`).
- **Names reveal intent,** 0 obscure abbreviations. A scale or an option set uses the standard names a developer already knows (sizes `xs`, `s`, `m`, `l`, `xl`, `xxl`), never an invented one (ankle, knee, waist).
- **DRY, but duplication beats the wrong abstraction:** two things are never coupled only to dedupe them.
- **The latest stable idioms** of the language version the repo pins.
- **Errors** are tagged tuples, or thrown typed errors where the language throws (a TypeScript error class
  per failure), handled at the edge (law 7).

## One owner per fact

A number, label or limit lives in one place, in the backend (a column or a module attribute), and
everything else reads it. A frontend constant for a value the backend owns is a second owner; it
drifts. Where the backend is the database, the value changes by migration. A port, host or API URL is read
from an env var, in the frontend too; a new backend takes a port other than the framework default (Phoenix 4000).

## Comments

Explain the code's why in technical terms. Never quote his prompts, never his name, never "as
requested". A comment that claims a property the code does not have (thread safe, idempotent,
sorted) is a bug; delete the comment or make it true.

## The optimal version first

A loop that does redundant work usually computes something vaguer than intended. Write the version
that does the work once (index the lookup, preload the association, batch the query) on the first
pass; there is no "tidy later". A ternary for one expression is allowed; an `else` block is the smell.
