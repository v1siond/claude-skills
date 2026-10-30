# Direction: the motion rules

Open this while writing the brief and the beat map, and again during every critic pass.

## Honesty on screen (never relaxed)

- Real product only. Screens come from the real app (Playwright captures of the running app, see
  `projects.md`), never invented UI. A feature the code does not have is never shown.
- Real numbers carry their source on screen or in `facts.md` (every number, its source, its date). No
  `facts.md`, no numbers on screen. Anything illustrative is labelled "Example data" or "Illustration".
- No real customer data and no personal data on screen. Insurance apps hold policyholder data: use a
  seeded demo account or anonymised rows only.
- Captions stay true: no "made in 10 minutes", no "one shot" after iterations.
- Copy in his voice: no em or en dashes, plain words.

## The rules (a critic checks each one)

1. **One shape, never cut.** States are the same element morphing size, radius and colour while its content
   swaps with a short blur. Transitions are morphs, camera moves, or a zoom into an element that becomes the
   next scene. A hard cut needs a reason written in the beat map.
2. **One thing moves at a time,** unless one control drives a continuous transform.
3. **Springs, a tiny overshoot at most.** Damping 0.72 or more. No bounce easing, no linear motion.
4. **Nothing frozen except the final hold.** Keep a micro settle or drift alive, end cards included. The next
   shot enters already moving in the exit's direction.
5. **The camera fills the frame** with each state. An empty frame is a bug. Pull back to reveal scale.
6. **A cursor drives changes with real clicks and drags** when the film shows UI: press scale, a short
   ripple, drags computed from the cursor position, springing back on release.
7. **Readable.** One takeaway per scene, every element finished and readable for 1.5 s or more, type big
   enough at phone width, titles on one line, safe margins about 110 px at 16:9 and 80 px at 9:16.
8. **One accent colour.** Banned: rainbow gradients, particle bursts, glows on chrome, emoji, lorem ipsum,
   gratuitous 3D flips, template looks.
9. **Loops:** the last frame is the first frame, position AND velocity (cursor included), or it stutters.
10. **Sound.** Muted first: the picture carries the message. Music is a public upbeat ad track under a licence that
    allows commercial use (CC0, Pixabay, CC BY with credit) by default, source and licence in `facts.md`; a
    track he gives wins, none when he says silent, and `scripts/score.py` is the fallback. Cuts land on the score's beats (`scripts/beat-snap.py`),
    so picture and music read one cut list. Loudness two-pass to -14 LUFS (`encode.sh loud`).
11. **Fonts are local files** with their licence beside them (`live-take.md`, Plates and fonts), checked with
    `document.fonts.check` before the first capture. Never a network font.

## The brief (write it before any code)

Duration, master size, delivery formats from the SAME timeline, subject and a one line promise, audience,
channel, a NAMED reference style ("Linear launch", "Apple bumper", never "premium modern"), then the states
with timestamps (hook: the promise on screen by 2 s, shape becomes screen one, transforms to screen two, proof with a real
number, logo and URL). Then the beat map: every scene on a beat, the big moment on the music's drop if there
is music, nothing still for more than 1 s.

A shared reference splits in two: the MOVES (pace, transitions, the one idea) and the LOOK (hex colours,
fonts). Take the grammar, never the content or logos.

## Captions

- A caption snaps in on its segment's cut frame and leaves on the next cut: no fade, no blur, no type-on.
- At most 17 characters per second of its time on screen, and at least 1.5 s on screen (rule 7).
- One caption per segment. It names the feature, or the article of law, the segment shows, in his voice
  (skill writing).
- Pop captions of 1 to 3 words over a seek page follow the same reading rules; a word lights on its own
  start frame.

## Sizes

| Use | Size |
|---|---|
| Landscape master, YouTube, homepage | 1920x1080 |
| LinkedIn feed | 1080x1350 (4:5) |
| Square | 1080x1080 or 1440x1440 |
| Reels, Shorts, TikTok | 1080x1920 (9:16), text inside the centre 1080x1080 |

Write scenes against a layout function and render each format from the same timeline; reframe, never crop.

## Silent test

Run it as a fresh read-only agent given only the film's contact sheet and phone sheet, never the brief. It
writes the message in one sentence. If that sentence is not the brief's promise, the film fails the Brief
axis. Muted, and then with him: if he hesitates, too much moves.
