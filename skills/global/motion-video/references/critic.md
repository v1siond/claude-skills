# The critic pass

Open this after every stills render, after the draft, and before the master render. It is the scoring
sheet for a film; the critic player runs it (casting in skill orchestration, which also holds the generic
critic loop). This file keeps what is particular to films.

## What the critic gets

- The brief and the beat map (`brief.md`), `facts.md` if numbers are shown, and `references/direction.md`.
- The stills folder (one still per state change, plus the frame just before and just after each transition)
  and a contact sheet (`encode.sh sheet stills sheet.png`), and the `encode.sh frozen stills` list.
- For a draft or a finished render: its contact sheet, a phone sheet at 360 px wide
  (`encode.sh sheet film.mp4 phone.png 6 360`), the `encode.sh scan` jump list and the `encode.sh frozen`
  list, and the cut list if the film has sound.
- Never the page source, the spec or the builder's report. The critic judges what is on screen.

## Default: reject

The critic starts from "not ready" and has to be convinced. A score is earned by something visible in a
named still or at a named second, never by intent.

## Score each still, 1 to 10

| Axis | Ask |
|---|---|
| Brief | Does this still say what the beat map says it says, at this time? |
| Hook | Is the promise on screen by 2 s (film level, scored once)? |
| Reading | Is the one takeaway readable at phone width in 1.5 s? Titles on one line? Safe margins kept? Captions within the rules in `direction.md`? |
| Frame | Does the subject fill the frame? Any empty or dead area? |
| Motion | Before/after pair: did one thing move? Morph or cut? Is anything frozen that should drift? |
| Variety | Does something new arrive every 2 to 4 s (film level)? A run of the same shot size and the same move fails. |
| Craft | Alignment, spacing, one accent colour, no clipping, no blurry text, no stray pixels at edges |
| Sound | When there is sound: does every cut and swell land on the beat of the cut list, and does the picture still carry the message muted? |
| Honesty | Is every number in `facts.md`? Is every screen the real product? Any personal or customer data? |

Any axis at 7 or less is a fix. Any honesty failure is a stop, whatever the other scores.

## The report

For each still: file name and the scores, and for every score of 7 or less one line naming WHAT is wrong,
WHERE in the frame or at which second, and the smallest change that fixes it. Then the three worst
problems of the film with their timestamps, the three things the eye lands on first in the contact sheet
in order, and whether that order matches the brief. End with one verdict: ship, fix, or rethink.

## The loop

1. Each fix round names what must not change: every still that scored 9 or more, and every part he
   already approved. Those are not touched.
2. Fix, re-render only the stills that changed, critic again, stop when every axis is 8 or more and the
   verdict is ship.
3. Then the draft at normal speed (SKILL.md step 8) and a critic pass on it, because timing, frozen beats
   and rhythm only exist between the stills. Then the master, then its contact sheet, scan and frozen list.
4. A new version replaces the previous one only when a side by side look finds it better; the previous mp4
   stays until he picks.

The final call is his. The critic's ship means "ready to show him", never "done".

## Product demo films

Reject outright, whatever the other scores, when the film shows a product flow as still screens instead of
recorded use (fields typed, values chosen, saves, results appearing), when it skips a step of the flow the
brief or `projects.md` names for that product, or when captions, titles and backgrounds are not the
product's brand colors.
