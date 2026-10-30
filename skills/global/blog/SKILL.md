---
name: blog
description: "A blog post from a post list row to a folder he can read: post.json, the draft, three critic passes, and the screenshots, clips, diagrams and code blocks it needs. Use when he says \"blog post\", \"write the post\", \"next post\", \"images for the post\", \"alt text\", \"cover image\". Do NOT use for other text he signs (writing), a film with cuts and music (motion-video) or picking topics (research)."
metadata:
  author: Alexander Pulido
  version: 2.1.0
  triggers: ["blog post", "blog posts", "write the post", "write a post", "next post", "write an article", "post outline", "blog series", "series part", "post.json", "the blog", "images for the post", "post media", "media for the post", "diagram for the post", "screenshots for the post", "code block from the repo", "code blocks for the post", "alt text", "cover image", "og image"]
  sources: the two retired skills blog-post and blog-media
---

# Blog

Builds the posts he signs: one cue list (`post.json`), the draft, three critic passes, and every screenshot, clip, diagram and code block the beats need, made from the real thing and opened. Run by the assets player for a post ticket, inside orchestration row D5, with the critic at step 10; it carries no ticket workflow of its own.

## When to use

- A post from a row of the post list: outline, draft, media, final; a series part; a rewrite after the critic.
- The images, clips, diagrams, code blocks, run output or cover of a post; `media-check.py` or `post-check.py` fails on a post folder.

## When not to use

- Text he signs that is not a post (an email, a doc, a spec, a CV): writing. The voice laws of a post are writing's.
- A film with cuts, captions or music, and a live take of the app: motion-video.
- Picking topics, trends or outside facts: research.

## Stance

- **You write his account with evidence,** for a software engineer, and say plainly where agents did the work.
- **You decide alone** the title, slug, keyword, beat order, media routes, crops and formats within the size budget; log each as a DECISION he can overturn in one reply.
- **You never decide** to publish, to name a listed client, to state a result the evidence does not hold, or to drop a media item a beat needs (change the beat and `post.json` with the director's word).

## Non-negotiables

1. **The reader is a software engineer.** Every post is engineering, with an occasional music or sports post; a topic that is neither is out, and a row marked `Status: dropped` is skipped. Why: a list of topics drifted into drums, martial arts and concerts; the readers he writes for are software engineers, and a music or sports post only shows his life outside work.
2. **Cheap before expensive:** the outline and media list pass the critic before any prose, the draft passes before media is rendered, the final passes before he sees it; a script check runs before every critic pass. Why: no quote of his; the stills-before-the-film loop of motion-video.
3. **`post.json` is the one cue list:** beats in order, each with its heading, 1 claim, its evidence and its media ids, then the media list; `post.md` follows it and a change to the post changes `post.json` first. Why: no quote of his; the brief of motion-video as one cue list.
4. **Every claim about his work carries a sha, a session id plus timestamp, or a file path.** A claim with nothing behind it is cut or flagged "needs his stories". Why: no quote of his; `references/blog-post-writing.md`, section Trust.
5. **Media is made, never a placeholder:** each item is produced by its route, opened with Read and described in `seen` before it is compared with the beat; an item that cannot be made leaves the beat, which is rewritten, never shipped as "image here". Why: a post with images, videos or code blocks is only finished when the agent writing it also makes them.
6. **Screens and clips are the real running app on demo data;** a mockup is never passed off as the product and an illustration is captioned "Example". Why: a demo built from still images showed none of the app in use.
7. **Code is extracted, never typed:** a block comes from a path at a sha through `scripts/code-extract.py`; a snippet that claims to run is run with `scripts/run-snippet.sh` and its output pasted as printed. Why: no quote of his; the old Critical list of blog-media, "Code from the real code".
8. **His voice:** the point in the first 2 or 3 sentences, plain words, no dashes, no antithesis, `check-text.sh` clean (skill writing). Why: no quote of his; writing sets the voice of anything he signs.
9. **No key, token, password, email, customer or end user name, or customer data,** in text or in any frame; the client names the project's deny list holds stay out; hide before the capture, never blur after. Why: those projects no longer exist and the client is one he does not want named.
10. **Nothing published:** the post lives in the workspace; posting, uploading, a push to a blog repo or a submission waits for his yes. Why: no quote of his; `references/blog-post-projects.md`, section Publishing.

Each kind also has laws of its own in its reference (post: the critic and the series; media: diagrams as code, films, formats, licences, the shared box). Read that reference whole before the first command.

Violating the letter of a law is violating the law.

## Red flags

| Thought | What it actually means |
|---|---|
| "The outline is clear, straight to the draft" | Law 2. The outline critic costs a minute, a rewritten draft an hour. |
| "I remember how that commit went" | Law 4. Open `git show <sha>`. |
| "I will add the screenshot later" / "The diagram is simple, text will do" | Law 5. Make it now or change the beat. |
| "A mockup looks the same" | Law 6. The running app, on demo data. |
| "I will retype the snippet, it is short" | Law 7. `code-extract.py`. |
| "I will blur the email afterwards" | Law 9. Hide it before the capture. |
| "The critic said ship, so I post it" | Law 10. Ship means ready to show him. |

## Intake

The post list row (title, description, kind, series and part, intent and keyword cluster, references, media needed) and where the project keeps it (`references/blog-post-projects.md`); the evidence the row names (commits, session files at the timestamp, workspace files); the project's trends file; where the real app runs (the project's own docs); the repo at the sha the post names. Fixed: the 12 critic axes, the three passes, the formats and the 1200x630 cover. Free: title wording, beat order within the kind, the crop and the capture order.

## Pipeline

Serves orchestration row D5 (dispatch, the builder's work); the folder is `<workspace>/blog/posts/<slug>/`. Each Output is a file in the folder.

| # | Kind of work | Output | Reference |
|---|---|---|---|
| 1 | A post: read the row and every reference it names into `evidence.md`, write `post.json`, check, critic the outline, write the draft, critic it, media, final, hand the folder to the player's report (orchestration row D7) | `evidence.md`, `post.json`, `post.md`, `critic/outline-N.md`, `critic/draft-N.md`, `critic/final-N.md` | `references/blog-post.md`, `references/blog-post-writing.md`, `references/blog-post-critic.md`, `references/blog-post-projects.md`, `references/blog-post-canon.txt` |
| 2 | Its media: group the items by route, make each, open each, write `seen`, build the sheet and the 390 px preview | `media/`, `media-sheet.png`, `preview-390.png` | `references/blog-media.md`, `references/blog-media-making.md`, `references/blog-media-web-media.md`, `references/blog-media-mmdc-puppeteer.json` |
| 3 | A film inside a post: skill motion-video with the beat's claim as its promise, linked into `media/` | the mp4 and poster | skill motion-video |

Rows 1 and 2 run in that order inside one ticket: `post.json` lists the media, the draft passes, then the media is made. The scripts are `scripts/post-check.py`, `scripts/media-check.py`, `scripts/media.mjs`, `scripts/web.sh`, `scripts/code-extract.py` and `scripts/run-snippet.sh`; the cue list shape is `examples/post.json`.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| A beat has no evidence | The claim came from memory | Find the sha, session or file, cut the claim, or flag "needs his stories" | `post-check.py` evidence line |
| The post reads like a changelog | Beats follow the commits | Beats follow the reader's question (`references/blog-post-writing.md`, Structure per kind) | the critic's Structure axis |
| `post-check.py` fails on the keyword | The title leads with the project name | The searched phrase first, the project name after | the check's FAIL line |
| A client name slipped into a frame | The capture showed live data | `--deny` the listed names; hide before capture | `post-check.py --deny` output |
| The screenshot shows a spinner or a blank panel | The capture ran before the data arrived | `--wait-for` the element that proves it, or a `click` step | the opened PNG |
| `media-check.py` says a code block differs | It was retyped or trimmed by hand | Paste the `code-extract.py` output again, narrow the range | the check's FAIL line |
| A WebP is over budget | Full page capture | Crop with `--selector`, lower `--size`, or quality 75 in `web.sh webp` | the check's weight line |
| A clip opens on a white frame or its step times disagree with the video | The page was not loaded at the start offset; wall clock drifts under load (29.6 s by the clock was 24.3 s of video) | Find the start by eye with `web.sh strip`, load a real page first | the poster and the strip image |
| A mermaid render hangs | No sandbox config | `-p references/blog-media-mmdc-puppeteer.json` | the process never exits without it |

## Deliverables

In `<workspace>/blog/posts/<slug>/`: `post.json`, `post.md`, `evidence.md`; `media/` with every file named in the media list plus its source (`.svg`, `shots.json`, takes, film folder link) and `media/licences/` when anything is not his; `media-sheet.png`, `preview-390.png`; `critic/outline-N.md`, `critic/draft-N.md`, `critic/final-N.md`. Nothing in a repo, nothing published. The report to the director: folder, title, keyword and slug, the critic's last verdict, each decision he can overturn in one reply, the flags, anything from the row not done.

## Check it before you show it

Post, from the post folder:
1. `python3 -I scripts/post-check.py <folder> --stage final` prints `ok`.
2. `bash /home/visiond/projects/claude/skills/global/writing/scripts/check-text.sh post.md` prints no FAIL.
3. `jq '.title|length' post.json` prints 70 or less; `jq -r .title post.json | grep -ci "$(jq -r .keyword post.json)"` prints 1; `grep -lF "$(jq -r .meta_description post.json)" ../*/post.json | wc -l` prints 1 (the description is unique).
4. `grep -c '^- ' evidence.md` equals the number of references in the row, and `grep -c MISSING evidence.md` is the number of missing references named in the report.
5. `head -c 500 post.md | grep -ci '<the promise keyword>'` prints 1 or more.

Media, from the post folder:
6. `python3 -I scripts/media-check.py <folder>` prints `ok` and exits 0; `ls media/` lists as many names as `post.json` lists ids.
7. `grep -c '"seen": ""' post.json` prints 0; `grep -c '"alt": "[^"]\{1,150\}"' post.json` is at least the number of images.
8. `find media -type f \( -name '*.webp' -o -name '*.png' -o -name '*.jpg' \) -size +400000c | wc -l` and `find media -name '*.mp4' -size +4000000c | wc -l` both print 0; a clip is at most 15 s.
9. `grep -ciE '<deny names, the same list as post-check.py --deny>' post.json` prints 0, and `media-sheet.png` was looked at for a key, token or email.

A failing check goes back to the step that made the file: the draft for text, the route for media.

## Critic loop

The critic player runs `references/blog-post-critic.md` at the outline, the draft and the final: 12 axes, default reject, below 8 on any axis goes back to the producing step until every axis is 8 or more (orchestration Critic loop); the same failure twice changes approach, and any honesty failure is a stop. For the media the judge gets `media-sheet.png`, `preview-390.png` and `post.json`, never your reasoning, and scores real screens, each file showing its claim, code equal to the sha, sizes and formats, alt and caption, licences and no personal data.

## Definition of done

- [ ] `python3 /home/visiond/projects/claude/skills/global/skill-craft/scripts/lint-skills.py /home/visiond/projects/claude/skills/global/blog` prints `ok   blog`.
- [ ] `post-check.py --stage final` and `media-check.py` print `ok`.
- [ ] The outline critic said ship before `post.md` existed, the draft critic before media rendered, and the final critic gave every axis 8 or more.
- [ ] Every claim has a sha, session or file; every code block is extracted; every media item is made and opened.
- [ ] No secret, personal data or listed client name; nothing published.
- [ ] You have written down what you would fix next.

Anything less, say so plainly.

## References

- `references/blog-post.md`, `references/blog-post-writing.md`, `references/blog-post-critic.md`, `references/blog-post-projects.md`, `references/blog-post-canon.txt`: the post.
- `references/blog-media.md`, `references/blog-media-making.md`, `references/blog-media-web-media.md`, `references/blog-media-mmdc-puppeteer.json`: the media.
- `references/blog-evals.md` the trigger rows and scenarios; `examples/post.json` the cue list shape.
- Skills: writing (voice, `check-text.sh`), motion-video (films), research (outside facts), orchestration (steps 6, 10, 12 and the Critic loop).

## Evals

Trigger rows in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `blog`), each checked with the router. 3 behaviour scenarios, pass rules written before the run, in `references/blog-evals.md`: B1 post (RED: Gotchas rows 1 to 3, a claim with no source, beats in commit order, the project name first), B2 media (RED: Gotchas rows 5 and 6, a retyped block and a spinner), B3 clip and publish (RED: law 10 and the gif habit).
Behaviour results, 1 run per arm, sonnet, version 2.0.0, hand scored against the pass rules of `references/blog-evals.md`. The tools cannot run scripts and the working folder was empty, so a reply is scored as the plan it states. Transcripts: (transcripts in the private workspace).

| Scenario | With | Without |
|---|---|---|
| B1 post | 2 of 3 (finds the source, cuts it or flags it; reorders to the reader's question; title phrase first; post-check.py not named) | 1 of 3 (asks for the source; would reorder to match the commit order; keeps the title) |
| B2 media | 3 of 3 (code-extract.py at the sha, media-check.py, `--wait-for`) | 1 of 3 (names waitForSelector; no extract script, no media-check.py) |
| B3 clip and publish | 2 of 3 (cover 1200x630, nothing published, ship means ready to show him; the clip is MP4 plus poster with no WebM) | 1 of 3 (MP4 plus WebM but no poster, treats ship as a go-ahead and asks only where to publish) |
