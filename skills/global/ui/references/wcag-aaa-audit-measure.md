# Measuring on the render (Playwright)

Run against the sandbox server. Write the probes in the audit folder, never in the repo.

## axe

```js
import AxeBuilder from '@axe-core/playwright'
const r = await new AxeBuilder({ page })
  .withTags(['wcag2a','wcag2aa','wcag2aaa','wcag21a','wcag21aa','wcag22aa','best-practice']).analyze()
```

Record `r.violations` (id, impact, nodes[].target) and `r.incomplete` (to check by hand).

## Text contrast (1.4.3, 1.4.6)

For each visible text node: take the computed colour, then the background from a screenshot clip of its box
(sample the pixels around the glyphs, not the CSS background: opacity, gradients and canvas lie). Ratio with
the WCAG relative luminance formula. 7 to 1 normal, 4.5 to 1 large (18.66 px bold or 24 px). Light and dark
themes both. A working example is an `e2e/support/contrast.ts` that does both.

## Target size (2.5.5, 2.5.8)

`el.getBoundingClientRect()` of every button, link (not inline), input and `[role]` control, plus any
`::before` hit area (an invisible hit area rule). Under 44 by 44 is a 2.5.5 fail; under 24 with less
than 24 px spacing fails 2.5.8 too.

## Focus appearance (2.4.13), not obscured (2.4.11, 2.4.12)

For each focusable element: screenshot its box plus 4 px unfocused, press Tab to focus it (keyboard, so
`:focus-visible` applies), screenshot again. Changed pixels must cover at least the area of a 2 px perimeter
of the element, and the changed pixels must reach 3 to 1 against their unfocused colour. Then check
`document.elementFromPoint` at the element's corners and centre returns the element (nothing sticky on top).

## Reflow, zoom, spacing (1.4.10, 1.4.4, 1.4.12)

Viewport 320 by 256: `document.documentElement.scrollWidth <= innerWidth` outside allowed two-dimensional
content. Zoom 200 percent: same, and no clipped text (`scrollWidth > clientWidth` on text boxes). Inject
`* { line-height:1.5 !important; letter-spacing:.12em !important; word-spacing:.16em !important } p { margin-bottom:2em !important }`
and look for clipped or overlapping text.

## Motion (2.3.3)

`page.emulateMedia({ reducedMotion: 'reduce' })`, then compare two screenshots 500 ms apart after an
interaction: anything still moving that is not essential is a fail.
