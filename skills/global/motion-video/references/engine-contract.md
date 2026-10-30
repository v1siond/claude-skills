# The seek(t) engine contract

Open this when writing or fixing the film page. The example to copy is `examples/seek-page.html`.

## The contract

- One HTML file per film. Everything on screen is computed inside `window.seek = (t) => {...}` (it may be
  async) from `t` alone. No CSS transitions, no `setTimeout`, no `setInterval`, no state carried from the
  previous frame, no `Math.random` (a seeded PRNG such as mulberry32 instead).
- Declare every constant before the first `seek()`. Set `window.ready = true` only after
  `document.fonts.ready` and every image has loaded.
- The only clock allowed is the preview loop (Space plays, arrows step a frame), and it calls the same
  `seek(t)`. Skip it when the URL has `?render=1` (render.mjs adds it to local files).
- Proof the page is pure: `render.mjs <page> --purity <t>` seeks t, jumps elsewhere, seeks t again and
  compares the two captures byte for byte. It must print `"same":true`.
- `z-index` on every layer. `visibility: inherit` (not `visible`) on children of a hidden parent.
- Never `will-change` on anything the camera scales: text renders blurry.

## Motion building blocks

- **Springs.** Closed-form damped step response `step(tau, w, z)` (in the example). A value with several
  targets is the sum of one spring per change. Damping `z` 0.72 to 0.9 for a tiny overshoot, 1.0 for camera
  and text. A target that must ARRIVE at time T is issued about 0.3 s early (depends on `w`).
- **Edges on different springs.** A stretching indicator (tab underline, toggle knob, pill) moves its
  leading edge on a stiff spring and its trailing edge on a soft one; width is right minus left.
- **Content swap with blur.** Text inside a morphing container gets its own window: enter on a spring with
  opacity, `blur((1 - e) * 10px)` and a small rise; exit short and EARLY, or old and new text overlap.
- **Masked text rise.** `translateY(105%)` inside `overflow: hidden`, word by word, about 55 ms stagger.
- **Camera.** One transform on a world container, `translate(cx, cy) scale(z) translate(-x, -y)`, with zoom
  interpolated in LOG space (`Math.exp` of a spring on `Math.log(z)`). Never zoom in and straight back out.
- **Floods** (a circle that becomes the next scene) must clear the farthest corner: radius is the `hypot` to
  the four corners times 1.05.
- **Easing solved by bisection** returns about 1e-9 at x = 0; return exact 0 and 1 at the ends or a guard
  like `if (e > 0)` fires early.

## Seeking third-party animation

- GSAP: `tl.pause(); tl.totalTime(t + 0.001, true); tl.totalTime(t, true)` (it skips a redraw asked for the
  same time twice).
- Web Animations and CSS animations: `document.getAnimations().forEach(a => { a.pause(); a.currentTime = t * 1000 })`.
- anime.js `anim.seek(t * 1000)` with `autoplay: false`; Lottie `goToAndStop(t * 1000)`.
- Video inside the film: pre-extract its frames with ffmpeg and show frame `floor(t * fps)` as an image;
  waiting on `seeked` flakes.
- Anything that only animates in real time (live React motion, Spline, embedded players) cannot be seeked.
  Port the idea into `seek(t)`, or capture it with `--live`.

## Live mode (a page with no seek, such as the running engine)

For a product flow the default is a `recordVideo` take cut into segments (`live-take.md`); live mode is for a
loop that must be stepped exactly.

`render.mjs <url> --live` installs Playwright's fake clock paused at 0 before the page loads, then moves page
time only with `clock.runFor`, so Date, timers, `performance.now` and `requestAnimationFrame` advance exactly
one frame step per capture. Time only goes forward (no `--purity`, stills are sorted). Measured on a test
canvas: two runs put the moving square within 1 px of each other and antialiasing differs, so live runs are
close, not byte identical. Use it for real product footage; build the titles, camera and transitions in a seek page that
shows those captured frames as images.

## Capture hygiene (render.mjs does these)

Waits for `window.ready`, `document.fonts.ready`, pauses `document.getAnimations()`, kills transitions,
waits two `requestAnimationFrame` after each `seek(t)` before the screenshot, and launches Chromium with
`--font-render-hinting=none --force-color-profile=srgb --disable-threaded-animation --disable-checker-imaging`.
Headless WebGL may draw black; check a still before a full render.

## Motion blur

`--subframes N` captures N times per frame inside a shutter (`--shutter 0.5` is the 180 degree film shutter;
1.0 smears), and `encode.sh video ... <fps> <N>` averages them with `tmix`. 1 for still or slow films, 4 for
normal UI motion, 6 to 8 for fast whips. Never blur text meant to be read. Never blur across a hard cut.

## More gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| Blurry text in the film | `will-change` on a scaled layer or blur on read text | remove them; try `--scale 2` for stills | the still |
| A cut looks like a sharp layer under a blurred one | only the incoming scene is blurred | blur and fade the outgoing scene over the same window | the pair of stills |
| The loop stutters at the seam | last frame differs from the first in position or velocity | make both equal | the seam frames |
