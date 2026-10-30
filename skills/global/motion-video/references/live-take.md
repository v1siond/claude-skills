# The live take route

Open this for a product demo film: one live recording of the real app in use, cut by marks into segments,
each laid on a brand plate with its caption, joined, with a score whose beats carry the cuts. The seek page
route (`engine-contract.md`) stays for titles, logo stings and engine clips. Worked film:
`$CLAUDE_WORKSPACE/<project>/films/demo-dsar-it/` (`capture/record.mjs`,
`build/segtimes.py`, `build/build.py`, `build/plates.mjs`).

## Contents

- Which capture
- The take
- From marks to segments
- Plates and fonts
- Build, draft, join
- Build traps
- Voice-over
- Captions

## Which capture

| Capture | Use it for | Cost |
|---|---|---|
| `recordVideo` on a Playwright context, with the repo's showcase helpers (visible cursor, `humanType`, `moveClick`) | the default for product flows: real network, real typing, one take | real time, frame timing follows the browser |
| `render.mjs <url> --live` (fake clock) | a canvas or game loop that must be stepped exactly, such as a game engine | slow, breaks on real network waits |
| CDP `Page.startScreencast` | only when frame timestamps matter (a take compared frame by frame against another) | frames arrive with their own timestamp each: ack every frame, then resample to a constant 30 fps by timestamp before any cut |

The screencast has no worked film yet: compare one side by side with a `recordVideo` take of the same flow
before a film depends on it.

## The take

- One take of the whole flow on demo data, signed in as the demo user, site chrome that is not the product
  (cookie banners, footers) hidden by an init script.
- The take writes `marks.json` as it goes: `{name, t}` in seconds from the video start, one mark at each
  action the film will cut on (`form:fill`, `form:sent`). A name marked twice keeps the later one.
- Pace the typing and the cursor for a viewer: the take is cut and sped up later, never the other way.
  Visible text goes in through a character by character helper; dates and one digit inputs can be filled.
- `recordVideo` size equals the viewport. Playwright captures at CSS pixel size and pastes it top left
  into a larger canvas, it never scales up, so a bigger frame is an ffmpeg lanczos upscale afterwards.
- The take never opens on a blank white frame: load a real page first. Inside the app, move by clicking
  its own links (a single page app swaps without a white reload flash); `page.goto` only to enter a section.
- Hide what is not the product (cookie banners, error toasts from decorative sections) with an init script.
- Seed the data a shot needs through the app's own storage before the take, and keep it consistent (a minor
  finding gets a low risk score). Confirm the demo screens match the current real UI before recording.
- Locator geometry calls (`boundingBox`, `scrollIntoViewIfNeeded`) are not actions, so `actionTimeout` does
  not bound them and a long test timeout turns one missing locator into a silent half hour. Give every
  geometry helper its own timeout (15 s). A stalled take is found from the per-act mark log, never from
  the wall clock.
- A film's length has a floor set by the work on screen (saves, AI waits). Below it, cut a section, never
  the pacing.

## From marks to segments

1. Write `spec.json` (shape in `examples/spec.json`): film size, fps, bpm, the plate window, and per segment
   the marks it runs between (`a`, `b` with offsets), its speed, and either a `crop` of the take, a slow
   `push` (zoom and pan on the take), or a `hold` (one frame of the take held, where the cursor rests on the
   subject). Title and end cards are `card` segments with a `dur`.
2. `scripts/segments.py times spec.json capture/rec/marks.json segments.json` resolves the marks, prints
   every segment with its from, to and duration, and writes the cut list and the total.
3. `scripts/trim-loads.py segments.json capture/rec/flow.webm` prints, per segment, the seconds of loading
   or blank frames at its head and tail. Read each line against the stills, move the offsets in `spec.json`,
   run `times` again. It measures; it never decides.
4. `scripts/beat-snap.py segments.json segments-beat.json` moves each cut onto the nearest beat (0.5 s at
   120 bpm) when that is 0.15 s away or less, and lists the cuts it kept off the grid. Fix those by hand
   (an offset or a speed) or pass `--grid half`.

## Plates and fonts

- A plate is a still at the film size: the brand background, the window where the take sits, the step
  number and the caption. Title and end cards are plates too. Make them with a small Playwright page per
  project, the way `demo-dsar-it/build/plates.mjs` does, colours from the brand file (`projects.md`).
- Fonts are local files with their licence in the film's `fonts/`: the brand's own, or `assets/fonts/`
  from this skill (Antonio for titles, EB Garamond and its italic for captions, SIL OFL, sources in
  `assets/fonts/SOURCES.txt`). Load them with `@font-face` from `file://`, and before the first screenshot
  check `document.fonts.check('36px "EB Garamond"')` and the title font; print the result per plate. Never a
  network font: a slow fetch draws frame 0 in the fallback font.

## Build, draft, join

1. `scripts/segments.py build segments-beat.json capture/rec/flow.webm build/plates draft --draft` writes a
   fast encode of every segment; `segments.py join draft draft.mp4` joins them. Watch `draft.mp4` once
   start to end for rhythm, and run `scripts/encode.sh frozen draft.mp4`: every stretch it lists must be a
   hold the brief names.
2. The same build into `seg/` without `--draft` is the master. Rebuild one segment by naming its id.
3. `scripts/score.py --segments segments-beat.json audio/score.wav`, then
   `scripts/encode.sh loud audio/score.wav audio/music.wav`.
4. `scripts/segments.py join seg film.mp4 --audio audio/music.wav`, then the checks of SKILL.md step 10.

## Build traps

- Judge a build from a check of the output, never from the log tail. ffmpeg sent to `/dev/null` under
  `set -e` can stop mid-mux and leave the previous film on disk, which looks like success: compare the
  output's mtime with the build start (`encode.sh` and `segments.py join` refuse an existing output).
- Burned subtitles: commas inside `force_style` are filter separators unless escaped, and the filter is
  passed as one argument array element (a font name with a space splits otherwise). libass `FontSize` is in
  ASS units against its `PlayResY`, never video pixels: 44 filled a third of a 4K frame, 16 was right.
- Joining audio pieces: make each a 48 kHz stereo PCM WAV and use the `concat` filter; the concat demuxer
  gave a silent track. On ffmpeg 4.2, `amix` has no `normalize` and `tremolo` needs `f` 0.1 or more.
- Sound is proved heard by `astats` (RMS near -20 dB, flat factor near 0) over several windows and by
  `silencedetect`, never by `volumedetect` alone.

## Voice-over (only when he asks for narration)

- One line per mark, placed at the mark's time, never overlapping the next. Two passes: the first build
  writes each line's duration, the take holds each act at least that long, then record again. Any edit to
  the lines means a new take. No silent gap over 10 s.
- A multilingual neural voice drifts into French or English on cognates and foreign words: keep the
  narration wholly in the UI language, or use a voice made for that one language.
- A music bed under a voice is ducked by `sidechaincompress` keyed on the voice.

## Captions

Rules in `direction.md` (Captions). The caption sits on the plate, so it appears with its segment on the
cut frame and leaves with it: no fade on the plate (`fade_in` and `fade_out` stay 0 unless the brief asks
for a dissolve).
