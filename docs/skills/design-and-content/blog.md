# blog

| | |
|---|---|
| Type | design and content |
| Scope | global (every repo) |
| Source | [`skills/global/blog/SKILL.md`](../../../skills/global/blog/SKILL.md), version 2.0.0 |
| Run by | the assets player for a post ticket |

## What it is for

Builds the posts he signs: one cue list (`post.json`), the draft, three critic passes, and every screenshot,
clip, diagram and code block the beats need, made from the real thing and opened (SKILL.md line 13).

## When to use it, and when not

Use it for a post from a row of the post list (outline, draft, media, final, a series part, a rewrite after the
critic), and for a post's images, clips, diagrams, code blocks, run output or cover, or when `media-check.py` or
`post-check.py` fails (lines 16 to 19).

Do not use it for other text he signs (writing, which also owns the voice laws of a post), a film with cuts,
captions or music (motion-video), or picking topics (research) (lines 21 to 25).

## Who runs it and its place in orchestration

The assets player inside step 6, with the critic at step 10; it carries no ticket workflow of its own. The
folder is `<workspace>/blog/posts/<slug>/`. The skill map row "blog post" adds writing, and motion-video when a
beat needs a film ([`skill-map.md`](../../../skills/global/orchestration/references/skill-map.md)).

## Pipeline, short (lines 66 to 74)

1. A post: read the row and every reference into `evidence.md`, write `post.json`, check, critic the outline, write the draft, critic it, media, final, hand the folder to the report. Outputs `post.md`, `critic/outline-N.md`, `critic/draft-N.md`, `critic/final-N.md`.
2. Its media: group items by route, make each, open each, write `seen`, build the sheet and the 390 px preview.
3. A film inside a post: motion-video with the beat's claim as its promise.

## Scripts

- `scripts/post-check.py <folder> --stage outline|draft|final [--deny names]`: checks a post folder before the critic sees it.
- `scripts/media-check.py <folder>`: checks every media item against `post.json` and the web rules.
- `scripts/code-extract.py <repo> <sha> <path> <start> <end>`: prints file lines at a commit as a source line plus a fenced block.
- `scripts/media.mjs`: makes post media with Playwright and sharp (`shot`, `shots`).
- `scripts/web.sh`: web encodes (`webp`, `strip` and more); refuses to overwrite.
- `scripts/run-snippet.sh <workdir> -- <command>`: runs a snippet the post claims runs and prints its output.

## Key laws (lines 35 to 44)

1. The reader is a software engineer. 2. Cheap before expensive.
3. `post.json` is the one cue list.
4. Every claim about his work carries a sha, a session id plus timestamp, or a file path.
5. Media is made, never a placeholder. 6. Screens and clips are the real running app on demo data.
7. Code is extracted, never typed. 8. His voice.
9. No key, token, password, email, customer or end user name, or customer data.
10. Nothing published.

## Handoffs

- Voice laws: writing. A film beat: motion-video. Topic picking: research.

## Best practices, from its Gotchas (lines 78 to 90)

- A beat with no evidence: find the sha, session or file, cut the claim, or flag "needs his stories".
- Beats follow the reader's question, not the commits.
- The title leads with the searched phrase, the project name after.
- `--deny` client names and hide them before the capture.
- `--wait-for` the element that proves the data arrived.
- Paste the `code-extract.py` output again when a code block differs.
- Crop WebP with `--selector` or lower the size when over budget.
- A mermaid render that hangs needs `-p references/blog-media-mmdc-puppeteer.json`.

## Red flags (lines 50 to 60)

"The outline is clear, straight to the draft", "I remember how that commit went", "I will add the screenshot
later", "I will retype the snippet", "I will blur the email afterwards", "The critic said ship, so I post it".

## Evals

Trigger rows in [`trigger-queries.json`](../../../skills/global/skill-craft/references/trigger-queries.json);
scenarios B1 to B3 scored against [`references/blog-evals.md`](../../../skills/global/blog/references/blog-evals.md)
(Evals, lines 136 to 145).
