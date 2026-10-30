# False positive patterns

Each one is a way a test stays green while the code is broken.

| Pattern | How to spot it | Fix |
|---|---|---|
| Degenerate oracle | the expected value is what a `??`, `||` or default produces anyway | assert the thing exists (the row, the tile, the call), then its value |
| Silent skip | assertions inside `if`, `for` or `Enum.each` over a list that can be empty | assert the list is non-empty first, or assert the count |
| Self-built inputs | the test constructs the options the real caller sends | drive the real caller (the page, the controller), or capture its real payload |
| Mocked subject | the mock replaces the module under test, or returns exactly what is asserted | mock only the boundary (HTTP, clock), never the subject |
| No-op stub | setup stubs a side effect to nothing (`localStorage.setItem`) then the test asserts it happened | drive `getItem` and assert `removeItem`, or test in a real browser |
| Narrowing on rename | a label renamed, the test's exact string now matches fewer things and still passes | grep src AND tests for the old string, count, rerun the full suite |
| Drifting fixture | a JSON captured from a live API, never refreshed | top it up field by field from live, assert the fields the code reads exist |
| Wrong layer | UI behaviour tested in Jest or jsdom | by batch test mode: `default` deletes it (0 frontend tests); `add browser tests` replaces it with a browser test of the page, then read the saved row from the test DB |
| Tagged away | `@tag :skip`, `:awaiting_phase`, `.skip`, `xit` on the one test that guards the bug | run it with the tag included and report its real result |
| Green without running | the runner found 0 tests (wrong path, wrong tree) | check the count line; an empty grep from the wrong tree looks like no test |
| Property asserts nothing | a property recomputes the answer with the code under test (`f(x) == f(x)`, an oracle that calls the subject), or a `filter`, `when` guard or branch discards almost every generated input so `check all` passes on zero real cases | use an independent oracle or a structural fact (roundtrip, invariant); generate valid inputs directly instead of filtering; assert the precondition held (count the cases that reached the assertion); break the rule on purpose and watch it go red |

The "Property asserts nothing" row (tautology and vacuity) is adapted from the Trail of Bits
property-based-testing skill, CC-BY-SA-4.0.
