# Behaviour evals

Scenarios for a run with this skill and one without, each given the same prompt by a fresh read-only agent
after a major version change (the method is in skill skill-craft). A change is kept only when the run
with the skill meets more assertions.

## 1. A product demo film

Prompt: "make a 60 second demo video of the DSAR flow in the shop app, italian captions, with music"

- Checks `which ffmpeg` and node before anything else, and states the result.
- Writes `brief.md` with a named reference style and the promise on screen by 2 s before any capture.
- Chooses a live take with marks (`recordVideo`), never a film of screenshots.
- Reads or writes the project's `brand.md` and uses local fonts with their licence.
- Plans the sound: a track he gives first, else a public upbeat track under a commercial licence (the synthesized score only as the fallback), and snaps the cuts to its beats.
- Renders a draft at normal speed and runs `encode.sh frozen` on it before the master.
- Writes nothing in the app repo and publishes nothing.

## 2. A fix round on a film he watched

Prompt: "the second half of the film drags and the caption at 0:42 goes too fast"

- Asks for, or finds, the second he means and reproduces it by watching the film at that second.
- Names what must not change (the stills at 9 or more, the parts he liked) before editing.
- Checks the 0:42 caption against 17 characters per second and 1.5 s on screen.
- Writes a new versioned mp4 and keeps the previous one until he picks.

## 3. A logo sting

Prompt: "animate our logo into a 4 second loop for the site"

- Uses the seek page route, proves purity with `render.mjs --purity` before the stills.
- Checks the loop seam in position and velocity.
- States the sound choice as a decision he can overturn in one reply (the score is the default; a site loop
  autoplays muted).

## Scenario run for the skill (case sensitive pass rules, 1 run per arm)

### S1 (run) RED from: law 2 (a demo made of still screenshots)

Role line: "You are the assets player making a film."

Task given to both arms:

~~~
He says: "make a demo film of the checklist feature". The repo holds screenshots of the checklist screens. Say the route you take, what the picture is made of, and what sound goes under it. Under 200 words.
~~~

Pass rules, 1 point each, read against the written reply:

1. The picture is a live take of the real flow (a recording of the running app), not still screens.
2. One record is carried from the start to the end of the workflow, with each computed value shown on screen.
3. The sound is a public upbeat track by default (a library with a commercial licence), not a synthesized pad.
