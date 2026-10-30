# Sources

## His concept, 2026-10-19

Agents work as an orchestra: one agent is the director and the others each do one kind of work. The director
sets the order of development and may cast several agents for frontend and backend, one for architecture, one
for QA and one for assets when needed; each agent runs the skill or the set of skills for its work.

He approved the flow diagram (director, architect first, parallel build lanes, QA and review, findings
back to build, integrate, his look) the same day and asked for this skill to be written from it.

## Video: https://www.youtube.com/watch?v=LxNMmxTcgcc

"Blizzard Won't Give Us Warcraft 4?! So I Built It Myself". Transcript:
`$CLAUDE_WORKSPACE/claude-skills/orchestration/transcript.txt`.

Taken from it:
- Opus as orchestrator: "keeps track of the bigger picture, breaks work into tasks, and coordinates how the pieces fit together". Smaller model for "clearly defined features ... a change with a concrete result that we can expect". Became: director never plays, model per role.
- "a unit task needs a visual reference, dimensions, export requirements, and a way to check the result. Make me an orc leaves too many decisions unresolved." Became: every brief is closed.
- State "lets work continue across sessions without losing track of which version we are building". Became: ORCHESTRA.md.
- "more important than to decide what to do is most of the time what not to do", free Poly Haven assets instead of modelling every rock. Became: Reuse and Post batch in scope.
- Asset loop: the agent renders, compares with the concept, revises. Became: the assets role card loop.
- "Every addition touches something else. So, we build, test, inspect, and revise." and "I still have to play and test the game myself." Became: integration is the director's job, his look is the last gate.

## Wider web research

Not done yet. Next pass: Anthropic's multi-agent research system write-up and orchestrator-worker
patterns; bank findings here with sources.

## Law 3 placement

The default place of a new row (after the last row of the current batch, approved rows in their relative
order, another place only on his word) is a DECISION the director logged; his quotes do not set it:
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/ORCHESTRA.md:57`.
He can overturn it in one reply.

## Law 8a default: 0 frontend tests of any kind

The default test mode writes 0 frontend tests of any kind, plain-function ones included; backend logic is
test driven in every batch, whatever the mode. A business rule lives in the backend and is tested there; a plain frontend module holds UI logic only and gets a test only
when the batch mode adds frontend tests. This is a DECISION the director logged from his words in SKILL.md law 8a:
`$CLAUDE_WORKSPACE/claude-skills/skills-reset-2026-10-24/ORCHESTRA.md:59`.
He can overturn it in one reply.

## The demo and film skill (motion-video)

The orchestration was built from his diagram and from motion-video, the film skill that works well. Taken
from it: the read-only critic that scores the work against his words before the next step, with a default
of reject (`critic.md`), references gathered before building, and real tools for each player (Playwright,
CDP screencast, ffmpeg, numpy and scipy) instead of guesses.
