# Comparing two systems field by field

Open this when the bug is "A shows X, B shows Y": a migration source and target, a carrier file and the row it
produced, the served API and the frontend, prod and staging, the old function and the new.

## The method

1. Pick ONE record that shows the bug. Get its id on both sides (an external id, policy number, tile label, map id). One concrete record beats a statistic.
2. Dump both sides in full, from the source of truth, not from memory or a frontend file:
   - database: a read-only `SELECT` of every column of that row and its joined rows;
   - API: `curl -s <endpoint> | jq` of the served payload;
   - file: the raw element from the carrier file (where the project has feed maps, its own docs name them: read the map first, it names the element and its target column, cite the section).
3. Line the two dumps up as a table, one row per field: field, side A, side B, same or different. Every field, not the ones you suspect. The bug is often in the field nobody looked at.
4. For each difference, find the code that writes that field on side B. Name the file and line.
5. Classify each difference:
   - HELD: the data is there on A and B dropped it (mapper, cast without the key, `select` missing it).
   - SHADOWED: B has it, but something downstream overrides it (a frontend constant, a fallback, a default).
   - ENGINE: both sides hold it and the code that uses it is wrong.
   - EXPECTED: the difference is by design; cite where that design is written.
6. Fix the first HELD or SHADOWED field, not the symptom at the end of the chain.

## Template

| Field | A (source) | B (target) | Same? | Writer of B (file:line) | Class |
|---|---|---|---|---|---|
| premium | 1200.00 | 0 | no | `<file>:<line>` where the cast drops `:premium` | HELD |
