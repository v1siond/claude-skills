---
name: motion-video
description: Make a demo or launch film from a live take of the real app, cut on the beat over brand plates with captions and a public upbeat track, or from a seek(t) page, stills and a draft passing a critic first. Assets player. Use when he says "make a video", "demo video", "launch film", "promo", "trailer", "animate this", "mp4". Do NOT use for a test recording a flow (testing-standard) or a render screenshot (bug-investigation).
metadata:
  author: Alexander Pulido
  version: 4.1.0
  triggers: [make a video, demo video, video demo, film, captions, cuts on the beat, synthesized score, launch film, promo, trailer, motion graphics, animate this, mp4, reel, logo sting, showcase clip]
  sources: howseen-ai/claude-motion-design (MIT, seek contract, critic axes, draft mode, caption numbers, beat snap limit); AbubakrChan/product-launch-motion (MIT, springs, edge split, blur swap, subframe motion blur, draft before the master, one cue list); charlie947/motion-graphics-skills (format sizes, moves versus look split, brand file); his client films (live take, segments, plates, local OFL fonts, numpy score)
---

# Motion video

Makes an mp4 he can post: a live take of the real app cut on the beat over brand plates, or a seek(t) page for
titles and loops. Run by the assets player for a film ticket in orchestration step 6 (dispatch, the builder's work); the critic
player scores the stills and the draft with `references/critic.md`. Casting and the gates are skill
orchestration's. The film shows the product in real use, in its brand, before his QA.

## When to use

- A demo or launch film of a product, a promo, a trailer, a logo sting, a loop.
- A fix round on a film he watched.

## When not to use

- A short clip or screenshot inside a blog post: skill blog.

## Stance

- **You show the product being used,** with the sound a viewer would pay attention to.
- **You decide alone** the style within a named reference, the cuts, the sound choice; log each as a DECISION he can overturn in one reply.
- **You never decide** that a film is done: the critic's ship means ready to show him, and the final call is his.

## Non-negotiables

1. **Stills before the film, a draft before the master.** A still costs 1 second, a draft 1 minute, the master many. No master until the stills and the draft pass the critic (every axis 8 or more, verdict ship). Stills cannot prove timing. Why: no quote of his; the cost ladder and the draft-before-master rule come from product-launch-motion and claude-motion-design (`references/sources.md`).
2. **A product demo film shows the product being used,** never still screens: a live take of the real flow (creating the thing, typing into its fields, choosing values, saving, the result appearing) cut into segments on brand plates (`references/live-take.md`). One record is carried through the user's real workflow from start to end, and every computed value is shown on screen. Why: a demo built from still images showed none of the checklist being created, filled or concluded, so it proved nothing about the app.
3. **Brand first:** colours, fonts and logo come from the project's `brand.md` (`references/projects.md`), never sampled from a screenshot. Fonts are local files with their licence (Antonio and EB Garamond, SIL OFL, are in `assets/fonts/`); never a network font. Why: a film in colours sampled from screenshots does not read as the client's product.
4. **Sound: a public produced track is the default,** upbeat internet ad style (118 to 128 bpm), from a library whose licence allows commercial use (CC0, the Pixabay content licence, or CC BY with the credit in the notes); source, licence and credit go in `facts.md`. A track he gives wins, silent only on his word, `scripts/score.py` is the fallback. Cuts sit on the beats (`scripts/beat-snap.py`). Why: public tracks with a commercial licence are plentiful, so a film never waits on him for music.
5. **Narration, when he wants a voice:** a single language voice in the film's language (never a multilingual model, it drifted into French), the gender he names, paced like a person, and every line says what is done and why it matters to the viewer. Why: a multilingual voice switched from Italian to French mid film and sounded synthetic, and a viewer could not tell what was being performed without more explanation.
6. **Captions snap in on the cut frame,** at most 17 characters per second and at least 1.5 s on screen (`references/direction.md`). Why: no quote of his; the numbers come from claude-motion-design's caption rules (`references/sources.md`).
7. **A seek page is pure:** no CSS transitions, timers, `Math.random` or state between frames; `render.mjs page.html --purity <t>` prints `"same":true` (`references/engine-contract.md`). Why: no quote of his; the seek contract of claude-motion-design needs every frame to be a function of t (`references/engine-contract.md`).
8. **The critic defaults to reject,** and a fix round never touches a still that scored 9 or more or a part he approved (`references/critic.md`). Why: no quote of his; the critic axes and the default-reject stance come from claude-motion-design (`references/critic.md`).
9. **Zero fabrication on screen:** real product screens only, every number in `facts.md` with its source, no personal or customer data; illustrative content is labelled. Why: no quote of his; `references/direction.md` section on honesty on screen.
10. **Nothing in a repo, nothing published:** the film folder lives in the project workspace; upload, post or push only with his yes. The film is made right after development and tests, before his QA. The order is develop, test (positive and negative scenarios that walk the user's workflow), make the film, then he checks the film and runs his QA. Why: tests give confidence in the code and the business logic; the film validates the work before his QA.

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "Screenshots with a zoom will do for the demo" | Law 2. Record the flow. |
| "I will go straight to the master, it is a small change" | Law 1. Stills, then the draft. |
| "A synthesized pad is fine under it" | Law 4. A public upbeat track first. |
| "The multilingual voice is more natural" | Law 5. One language voice. |
| "The critic is slow, I will self-score" | Law 8. A separate critic run. |
| "The number looks right, I recall it" | Law 9. It goes in `facts.md` with its source. |

## Intake

1. What the film is for, its length, formats and channel, from his message; a named reference if he shared one (split into MOVES and LOOK, `references/direction.md`).
2. The project and where its real screens come from (`references/projects.md`), and its `brand.md`.
3. The sound: his track, his word that it is silent, or a public upbeat track under a commercial licence.
4. Tools: ffmpeg 4.2.7 at `/usr/bin/ffmpeg` (ffprobe beside it); node 18 or newer (`export PATH=$HOME/.nvm/versions/node/v24.15.0/bin:$PATH`, Playwright from the project's node_modules or `PLAYWRIGHT_FROM=<package.json>`); python3 with numpy, run as `python3 -I`. A missing tool is stated and the work stops at the step that needs it.

Fixed: the critic gate, the 17 characters per second, -14 LUFS. Free: style within the named reference, segment order.

## Pipeline

Serves orchestration step 6 (dispatch, the builder's work). The folder is `<workspace>/films/<slug>/`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Check the tools: `which ffmpeg ffprobe`, `node --version` after the export, `python3 -I -c 'import numpy'`; state the result | the tools line | Intake |
| 2 | Make the folder, write `brief.md` (duration, master size, formats, 1 line promise on screen by 2 s, audience, channel, named reference, states with timestamps, beat map) and `facts.md` if any number appears; read or write `brand.md`; copy fonts with their licence into `fonts/` | the brief | `references/direction.md` |
| 3 | Pick the route: a product flow is a live take, titles, a logo sting, a loop or an engine clip is a seek page | the route | laws 2, 7 |
| 4 | Live take: record the flow once with marks, write `spec.json` (`examples/spec.json`), then `scripts/segments.py times`, `scripts/trim-loads.py`, `scripts/beat-snap.py` and the plates with the font check, in the order of `references/live-take.md`. Seek page: write `page.html` from `examples/seek-page.html`, then `node scripts/render.mjs page.html --purity <a busy t> --duration <T>` must print `"same":true` | spec and plates, or a pure page | laws 2, 7 |
| 5 | Stills: seek page `node scripts/render.mjs page.html --out stills --stills 0,0.6,1.4,...` at every state change plus just before and after each transition; live take: the plates are the stills; then `scripts/encode.sh sheet stills stills-sheet.png` and `scripts/encode.sh frozen stills`; look at every still yourself first | `stills/` and the sheet | law 1 |
| 6 | Critic on the stills (`references/critic.md`) with the brief, `facts.md`, `references/direction.md`, the stills, the sheet and the frozen list, never the source; fix every score of 7 or less, re-render only changed stills, until every axis is 8 or more and the verdict is ship | `critic/pass-N.md` | law 8 |
| 7 | Sound: `scripts/score.py --segments segments-beat.json audio/score.wav` (or `--duration T --bpm 120 --cuts ...`) only as the fallback, his track or the public track otherwise, nothing when he said silent; then `scripts/encode.sh loud <in.wav> audio/music.wav` | `audio/music.wav` at -14 LUFS | law 4 |
| 8 | Draft at normal speed: seek page `node scripts/render.mjs page.html --out draft-frames --duration T --size 960x540 --fps 30 --subframes 1` then `encode.sh video draft-frames draft.mp4 30 1 audio/music.wav`; live take `segments.py build ... draft --draft` then `segments.py join draft draft.mp4 --audio audio/music.wav`; watch once start to end, run `encode.sh frozen draft.mp4`, critic on its sheet, phone sheet and frozen list | `draft.mp4` | law 1 |
| 9 | Master: seek page `node scripts/render.mjs page.html --out frames --duration T --fps 30 --subframes 4` (1 for slow films, `--from/--to` to split) then `scripts/encode.sh video frames film.mp4 30 4 audio/music.wav`; live take `segments.py build` into `seg/` then `segments.py join seg film.mp4 --audio audio/music.wav` | `film.mp4` | law 1 |
| 10 | Check the film: `encode.sh probe film.mp4`, `encode.sh sheet film.mp4 film-sheet.png`, `encode.sh scan film.mp4` (every jump an intended cut), `encode.sh frozen film.mp4` (every stretch a named hold); watch once with the sound on | the check output | Check it before you show it |
| 11 | Other formats from the same timeline through the page's layout function, steps 5 to 10 per format | extra mp4s | `references/direction.md` Sizes |
| 12 | Delete `frames/` and `draft-frames/` after the encode passes; keep brief, facts, spec, page, plates, stills, critic reports, the score and every mp4, versioned; report to him (orchestration step 12) | the report | |

Do not skip step 6: the critic on the stills is the cheapest place to fail.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| `page never became ready` | the page never set `window.ready` | set it after fonts and images load and define `window.seek`; for a running app use `--live` or a live take | the render error |
| `"same":false` | state kept between frames (a counter, `+=`, a transition, `Math.random`) | make that value a function of t | the purity output |
| `SyntaxError` or `Unexpected token` from `render.mjs` | node v10 | export the v24 PATH | `node --version` |
| `frame count mismatch` | stray or missing files after an interrupted render | delete the frames folder and render again | `encode.sh` message |
| Frame 0 or a plate in a serif fallback | font loaded late or from the network | local `@font-face`, `document.fonts.check` true before the screenshot | the font check line |
| A segment opens on a white page or a spinner | loading frames at its head | `trim-loads.py` gives the head seconds; move the `a` offset in `spec.json`, run `times` again | the trim line |
| `frozen` lists a stretch the brief does not name | a still stretch with no drift | a slow push or drift on that segment, or a shorter hold | the frozen list |
| `beat-snap.py` keeps cuts off the grid | the cut is more than 0.15 s from a beat | change that segment's offset or speed, or `--grid half` | the listed cuts |
| A WebGL canvas renders black headless | no GPU path | check one still first; try `--live` against the real app | the still |
| `ModuleNotFoundError: numpy` | numpy missing | `python3 -m pip install --user numpy`, with his yes | the error |

## Deliverables

In `<workspace>/films/<slug>/`: `brief.md`, `facts.md` (if numbers), `page.html` or `spec.json`,
`segments-beat.json`, `build/plates/`, `stills/` and its sheet, `critic/pass-N.md`, `audio/`, `draft.mp4`,
`film.mp4` (plus one mp4 per extra format, versioned) and its sheet. The report to him: the path, duration,
size, frame count from `probe`, the critic's last verdict, each decision he can overturn in one reply (style,
sound, cuts kept off the beat), real versus example data on screen, whether the sound was heard or only
measured, and anything from the brief not done.

## Check it before you show it

1. `encode.sh probe film.mp4` shows the frame count the timeline asks for and an audio stream (unless he asked for a silent film).
2. `encode.sh scan film.mp4` lists only intended cuts; `encode.sh frozen film.mp4` lists only holds the brief names.
3. `encode.sh loud` output reads -14 LUFS; `ffmpeg -ss <t> -t 2 -i film.mp4 -af astats -f null -` on 4 windows each print an RMS level above -40 dB (not `volumedetect` alone).
4. Seek page: purity printed `"same":true`. Live take: the `trim-loads.py` lines were read and the `beat-snap.py` moves listed.
5. `grep -c '<number as on screen>' facts.md` prints 1 or more for each number read off the sheet; `ls fonts/` lists each font with its `OFL-*.txt`; every hex in the plates appears in `brand.md` (`grep -c '#xxxxxx' brand.md`).
6. `grep -rn $'\xe2\x80\x93\|\xe2\x80\x94' brief.md facts.md` prints nothing; `frames/` is deleted; nothing is written in a repo.
7. `grep -ci '<the promise keyword>' <the caption file>` prints 1 or more: the first captions say the brief's promise.

A failing check goes back to step 6 (stills), 8 (draft) or 9 (master).

## Critic loop

`references/critic.md` is the scoring sheet: the critic gets the brief, `facts.md`, `references/direction.md`,
the stills or the draft sheets and the frozen list, never the source or your report. Default reject. Nine
axes score 1 to 10; any honesty failure is a stop. Below 8 on any axis: fix, re-render only what changed,
until every axis is 8 or more (orchestration Critic loop); when the same failure repeats twice, change approach. A product demo film is rejected outright when it shows
still screens instead of use.

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py` prints `ok   motion-video`.
- [ ] Stills and the draft passed the critic (every axis 8 or more, ship) before the master.
- [ ] The frame count matches; `scan` and `frozen` show only intended cuts and named holds.
- [ ] Sound is the public track, his track or silent as he said, at -14 LUFS, with an audio stream in `probe`.
- [ ] Every number is in `facts.md`; no personal or customer data; the screens are the real product.
- [ ] Nothing written to a repo, nothing published, no em or en dashes.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/sources.md` every style reference, tool, font and music source, with licences.
- `references/live-take.md` which capture, marks, segments, plates and fonts, build, draft, join.
- `references/engine-contract.md` the seek contract, springs, camera, seeking GSAP and WAAPI, live mode, capture hygiene, motion blur, three more gotchas (blurry text, sharp layer under a blur, loop seam).
- `references/direction.md` the motion rules, sound, captions, honesty on screen, the brief and beat map, sizes, the silent test.
- `references/critic.md` what the critic gets, the axes, the report, the loop.
- `references/projects.md` where real footage comes from per project, the brand file, the film folder. Project footage rows live in the project skills; this file keeps one pointer line per project, the brand file and the film folder.
- `references/behaviour-evals.md` scenarios for a with and without run. `references/canon.txt` rules an edit must keep.
- `examples/seek-page.html` the page to start from. `examples/spec.json` a live take spec. `assets/fonts/` Antonio and EB Garamond with their OFL licences, sources in `SOURCES.txt`.
- `scripts/render.mjs` stills, purity, frames, live capture. `scripts/encode.sh` video, sheet, scan, loud, probe, frozen. `scripts/segments.py` times, build, join. `scripts/trim-loads.py` loading frames. `scripts/beat-snap.py` cuts onto the beat. `scripts/score.py` the synthesized score.

## Evals

Trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `motion-video`), each checked with the router. Behaviour scenarios and their pass rules, written before the run, are in `references/behaviour-evals.md`; the run scenario S1 is RED from law 2.

**S1.** Role line: "You are the assets player making a film." Task: "make a demo film of the checklist feature", with screenshots of its screens in the repo; say the route, what the picture is made of, and the sound, under 200 words. Pass rules, case sensitive and read against the reply: a live take of the real flow and not still screens; one record carried from start to end with each computed value on screen; a public upbeat track by default.

**Arms.** Model sonnet, `claude -p --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob`, empty cwd, 1 run per arm, task on stdin. With: this SKILL.md (Evals section removed) after "Skill motion-video loaded:" and `--add-dir` on a copy of the folder without the evals files. Without: nothing appended, 0 skill reads.

| Arm | S1 |
|---|---|
| With | 3 of 3 (live take of the checklist flow, one record start to end, public upbeat track at 118 to 128 bpm with licence in `facts.md`) |
| Without | 0 of 3 (a Ken Burns slideshow of the screenshots with a synthesized loop) |

Transcripts: (transcripts in the private workspace).
