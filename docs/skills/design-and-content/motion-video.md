# motion-video

| | |
|---|---|
| Type | design and content |
| Scope | global (every repo) |
| Source | [`skills/global/motion-video/SKILL.md`](../../../skills/global/motion-video/SKILL.md), version 4.0.2 |
| Run by | the assets player; the critic player scores stills and draft |

## What it is for

Makes an mp4 he can post: a live take of the real app cut on the beat over brand plates, or a seek(t) page for
titles and loops (SKILL.md lines 13 to 17). Casting and the gates are orchestration's.

## When to use it, and when not

Use it for a demo or launch film, a promo, a trailer, a logo sting, a loop, and a fix round on a film he
watched (lines 19 to 22). Do not use it for a short clip or screenshot inside a blog post (blog) (lines 24 to 26).

## Who runs it and its place in orchestration

The assets player at step 6; the critic with `references/critic.md` on the stills and the draft. The router
also matches "film", "captions", "segments" and "cuts on the beat" by hand rows
([`skill-router.py`](../../../harness/hooks/skill-router.py), `HAND`).

## Pipeline, short (lines 69 to 86)

1. Check the tools (ffmpeg, ffprobe, node, numpy).
2. Folder, `brief.md` (duration, size, promise on screen by 2 s, beat map) and `facts.md`.
3. Pick the route: a product flow is a live take; titles, a sting, a loop or an engine clip is a seek page.
4. Live take: record the flow once with marks, `spec.json`, `segments.py times`, `trim-loads.py`, `beat-snap.py`, plates.
5. Stills at every state change. 6. Critic on the stills; fix every score of 7 or less.
7. Sound: a public track or his; `score.py` only as the fallback.
8. Draft at normal speed. 9. Master. 10. Check the film (`encode.sh probe`, `sheet`, `scan`, `frozen`).
11. Other formats from the same timeline. 12. Delete frame folders, keep the sources, report.

## Scripts

- `scripts/render.mjs`: captures frames of a page with Playwright (stills or a full run).
- `scripts/encode.sh`: ffmpeg steps (video, probe, sheet, scan, frozen); refuses to overwrite.
- `scripts/segments.py`: cuts a live take into segments by its marks, lays each on its plate, joins them.
- `scripts/trim-loads.py`: measures loading or blank frames at the head and tail of each segment.
- `scripts/beat-snap.py`: snaps every cut to the nearest beat and writes the cut list.
- `scripts/score.py`: synthesizes a score from the cut list, the fallback when no track is used.

## Key laws (lines 36 to 45)

1. Stills before the film, a draft before the master. 2. A product demo shows the product being used.
3. Brand first. 4. Sound: a public produced track is the default. 5. Narration only when he wants a voice.
6. Captions snap in on the cut frame. 7. A seek page is pure. 8. The critic defaults to reject.
9. Zero fabrication on screen. 10. Nothing in a repo, nothing published.

## Handoffs

- A clip inside a post comes from blog's row 3.
- The report: orchestration step 12.

## Best practices, from its Gotchas (lines 90 to 103)

- Set `window.ready` after fonts and images load and define `window.seek`.
- Make every animated value a function of t; state kept between frames breaks the render.
- Export the node v24 PATH before `render.mjs`.
- Delete the frames folder after an interrupted render.
- Use a local `@font-face` and check `document.fonts.check` before the screenshot.
- `trim-loads.py` gives the head seconds to cut a white page or spinner.
- Check one still first when a WebGL canvas renders black headless.

## Red flags (lines 49 to 58)

"Screenshots with a zoom will do for the demo", "I will go straight to the master", "A synthesized pad is fine",
"The critic is slow, I will self-score", "The number looks right, I recall it".

## Evals

Trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
scenario S1 with and without the skill (Evals, lines 159 to 172), more in
[`references/behaviour-evals.md`](../../../skills/global/motion-video/references/behaviour-evals.md).
