# The dash doing the work, and the fix

From CLAUDE.md, a PR review comment.

Bad, a dash splices the sentence (shown here with the dash replaced by `[DASH]` so this file stays clean):

> `sort_field` is safe now, agreed. `sort_direction` isn't. The base-field branch still pipes into
> `sort(params)`, so the direction goes into `String.to_atom/1` raw off the query string [DASH]
> `?sort_field=reason&sort_direction=asdf` mints a fresh atom per request, and atoms are never collected.

Good, same content, a full stop instead:

> `sort_field` is safe now, agreed. `sort_direction` isn't. The base-field branch still pipes into
> `sort(params)`, so the direction goes into `String.to_atom/1` raw off the query string.
> `?sort_field=reason&sort_direction=asdf` mints a fresh atom per request, and atoms are never collected.

Preference order for the replacement: full stop, comma, colon, parentheses, rewrite.
