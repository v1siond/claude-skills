# Porting an approved proposal into the app

Open this once he has picked a proposal. Proposals are prototypes; the port is production code and
follows every standard (skill `engineering-standards`).

## Steps

1. Save the approved HTML verbatim in the repo, `docs/design/<date>-<name>.html`, with its assets.
   It is the contract: the port is compared against it, not against memory.
2. Extract tokens first: colours, type scale, spacing, radii, shadows. Put them where the repo keeps
   tokens (Tailwind config, CSS custom properties in the ITCSS settings layer). No hex in components.
3. Copy, then adapt. Lift the approved markup and styles as they are, then convert to the repo's
   components and Tailwind classes. Rewriting from scratch loses details he approved.
4. Keep content and labels plain; the theme dresses the presentation, never renames things.
5. Cover every state the mockup implies: empty, loading, error, long text, mobile width. With Figma,
   the target is state coverage, not pixel match.
6. Render the port at the same widths as the proposal, screenshot both, and compare them side by side
   region by region. List each difference and fix it or explain it.
7. Contrast: run `scripts/contrast.py` on every text and background pair the port uses. AAA on
   every app and site: 7 to 1 for text, 3 to 1 for non-text.
8. Tests: as skill `testing-standard` says for the ticket's test mode. The proposal pages got none.

## Small changes

A small visual change he describes precisely (a colour, a spacing, a label) goes straight into the app
with a screenshot before and after. No proposal round.
