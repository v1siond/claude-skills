# Where the footage comes from, per project

Open this when the film shows a real product. The rule in `direction.md` holds: real screens only, no
personal or customer data.

## Project footage rows live in the private overlay

Each project keeps its footage rows in `skills/specific/<project>/facts/`, never in this repo.


## Anything else

Run the project's own dev server and record the flow live (`live-take.md`, Which capture). Titles, a logo
sting or a loop go in a seek page that shows those captures as images.

## The brand file

`$CLAUDE_WORKSPACE/<project>/brand.md` holds the project's colours as
hex, each with its source file and line (tokens from the repo, never sampled from a screenshot), the fonts
and their files, logo paths, five never rules, and a line to ask him wherever the repo does not say. Read it first.
The first film or design ticket of a project with none writes it.

## Where the work lives

The film folder is `$CLAUDE_WORKSPACE/<project>/films/<slug>/`, never a
repo: `brief.md`, `facts.md`, `page.html` or `capture/` and `build/` (live take), `fonts/`, `stills/`,
`frames/` (deleted after the encode), `critic/`, `audio/`, the mp4s, versioned (`film-v2.mp4`), never overwritten.
