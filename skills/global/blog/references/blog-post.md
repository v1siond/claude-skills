# Blog post, inside blog

Builds a post he signs, end to end, from a post list row: `post.json` as the one cue list, the draft, the
media and three critic passes. Run by the assets player for a post ticket in orchestration row D5 (dispatch, the builder's work); the
critic player scores each stage with `references/blog-post-critic.md`. Casting and the gates are skill orchestration's.
Media is made by `references/blog-media.md`, films by skill motion-video, and the words follow skill writing.

## Stance

- **You write his account with evidence,** for a software engineer, and you say plainly where agents did the work.
- **You decide alone** the title, slug, keyword, beat order and media routes; log each as a DECISION he can overturn in one reply.
- **You never decide** to publish, to name a listed client, or to state a result the evidence does not hold.

## Non-negotiables

1. **The reader is a software engineer.** Every post is engineering, with an occasional music or sports post to show his life outside work; a topic that is neither is out, and a row marked `Status: dropped` is skipped. Why: a list of topics drifted into drums, martial arts and concerts; the readers he writes for are software engineers, and a music or sports post only shows his life outside work.
2. **Cheap before expensive:** the outline and media list pass the critic before any prose, the draft passes before media is rendered, the final passes before he sees it; a script check runs before every critic pass. No final until the critic says ship. Why: no quote of his; the same cheap-before-expensive loop as skill motion-video (stills before the film).
3. **`post.json` is the one cue list:** beats in order, each with its heading, its 1 claim, its evidence and the media ids it needs, then the media list. `post.md` follows it; a change to the post changes `post.json` first. Shape: `examples/post.json`. Why: no quote of his; skill motion-video's brief as one cue list (`sources` in the frontmatter).
4. **Every claim about his work carries a sha, a session id plus timestamp, or a file path.** No invented numbers or results; a claim with nothing behind it is cut or flagged "needs his stories". Say plainly where agents did the work (`references/blog-post-writing.md`, Trust). Why: no quote of his; `references/blog-post-writing.md` section Trust.
5. **Media is made, never a placeholder:** every item is produced and opened by `references/blog-media.md` (screenshots, clips, diagrams, code blocks) or skill motion-video (films). An item that cannot be made is removed from the beat and the beat rewritten, never shipped as "image here". Why: a post with images, videos or code blocks is only finished when the agent writing it also makes them.
6. **Code is extracted, never typed:** a code block comes from a path at a sha through `scripts/code-extract.py`; a snippet that claims to run is run and its output pasted as printed. Why: no quote of his; `references/blog-media.md` law 3, the one owner of code blocks.
7. **His voice:** the point in the first 2 or 3 sentences, plain words, no dashes, no antithesis, `check-text.sh` clean (skill writing). Why: no quote of his; skill writing sets the voice of anything he signs.
8. **Never a key, token, password, email address, customer or end user name, or customer data,** in text or in any frame; the client names the project's deny list holds stay out (`references/blog-post-projects.md`). Why: those projects no longer exist and the client is one he does not want named.
9. **Nothing published:** the post lives in the workspace; posting, uploading, a push to a blog repo or a submission to Hacker News waits for his yes. Why: no quote of his; `references/blog-post-projects.md` section Publishing, "Nothing is posted until he says where and yes".

Violating the letter of a law is violating the law.

## Intake

1. The post list row (`references/blog-post-projects.md` points to where each project keeps it): title, description, kind, series and part, intent and keyword cluster with its trends finding, references, media needed.
2. The evidence the row names: commits (`git show <sha>`), session files at the timestamp, workspace files.
3. The traffic evidence: the project's trends file, section "What this means for a post".

Fixed: the 12 critic axes, the three passes. Free: title wording, beat order within the kind's structure.

## Pipeline

Serves orchestration row D5 (dispatch, the builder's work). The folder is `<workspace>/blog/posts/<slug>/`.

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Read the row and open every reference it names (`git show --stat <sha>` per commit, the session prompt at its timestamp, each file); write one `- ` line per reference in `evidence.md` saying what it proves; mark any that does not exist or does not say what the row claims `MISSING` | `evidence.md` | law 4 |
| 2 | Make the folder with `media/` and `critic/`; the slug is the keyword phrase in kebab case | the folder | `references/blog-post-writing.md` Search |
| 3 | Write `post.json` from `examples/post.json`: title, slug, meta description, keyword, intent, kind, series, the promise, beats with claim and evidence, the media list with each route (`blog/references/blog-media-making.md`), the links | `post.json` | law 3 |
| 4 | `python3 -I scripts/post-check.py <folder> --stage outline --deny <names>`; fix every FAIL | `ok` | law 2 |
| 5 | Critic on the outline (`references/blog-post-critic.md`): it gets `post.json` and the row, never your reasoning; fix every score of 7 or less, check again, until ship | `critic/outline-N.md` | law 2 |
| 6 | Write the draft `post.md` from the beats in order, media by their final `media/<file>` path with alt text and caption, code blocks from `code-extract.py`; run `post-check.py --stage draft`, then `check-text.sh post.md` | `post.md` | laws 6, 7 |
| 7 | Critic on the draft; fix and check again until ship; the text is now frozen except for what the media changes | `critic/draft-N.md` | law 2 |
| 8 | Make the media with `references/blog-media.md` (and motion-video for a film), each file opened and its `seen` line written; run `media-check.py <folder>` | `media/` | law 5 |
| 9 | Final: media in place, `post-check.py --stage final` and `media-check.py`, then the critic's final pass with the rendered post (`blog/references/blog-media-making.md`, Preview) and the media sheet; fix until every axis is 8 or more and the verdict is ship | `critic/final-N.md` | law 2 |
| 10 | Hand the folder to the player's report (orchestration row D7): folder, title, keyword and slug, the critic's last verdict, each decision he can overturn in one reply (title, keyword, a cut beat, a media choice), the flags, anything from the row not done | the report section | law 9 |

Do not skip step 5: the outline pass is the cheapest fix in the whole pipeline.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| A beat has no evidence | the claim came from memory | find the sha, session or file, cut the claim, or flag it "needs his stories" | `post-check.py` evidence line |
| The post reads like a changelog | beats follow the commits | beats follow the reader's question (`references/blog-post-writing.md`, Structure per kind) | the critic's Structure axis |
| `post-check.py` fails on the keyword | the title leads with the project name | the searched phrase first in the title, the project name after | the check's FAIL line |
| The critic and he disagree | the critic judges the page, he judges the post | his word wins; the critic's ship means ready to show him | law 9 |
| A client name slipped into a frame | the capture showed live data | `--deny` the listed names; hide before capture (`references/blog-media.md`) | `post-check.py --deny` output |
| The draft passes and the media shifts the text | the media was made after a frozen text | change `post.json` first, then the text | step 7 |
