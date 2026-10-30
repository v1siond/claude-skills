# Blog media, inside blog

Makes every media item a post's `post.json` lists, as a web ready file or a block in `post.md`, opened,
described and checked. Run by the assets player inside a blog ticket, in orchestration row D5 (dispatch, the builder's work).
The post structure, voice and critic are `references/blog-post.md`; films are skill motion-video's.

## Stance

- **You make every item from the real thing** and open it before you describe it.
- **You decide alone** the route per item, the crop, the format within the size budget; log each as a DECISION.
- **You never decide** to drop a media item the beat needs; change the beat and its `post.json` entry instead, with the director's word.

## Non-negotiables

1. **Real screens only.** Screenshots and clips come from the running app through Playwright on demo data; a mockup is never passed off as the product, and an illustrative image is captioned "Example". Why: a demo built from still images showed none of the app in use.
2. **Every file is made by its route and opened,** never a placeholder: produced by a command in `references/blog-media-making.md`, then opened with Read and described in `seen` before you compare it with the beat's claim. Why: a post with images, videos or code blocks is only finished when the agent writing it also makes them.
3. **Code comes from the real code:** `scripts/code-extract.py` prints the lines at a sha with their source line; nothing is typed from memory. A snippet that claims to run is run with `scripts/run-snippet.sh` and its output pasted as printed. Why: no quote of his; the retired skill's Critical list, "Code from the real code" (old SKILL.md:29-31).
4. **Diagrams are code:** SVG written by hand and rendered to PNG by `media.mjs svg`, the `.svg` kept as the source. Mermaid runs only with `mmdc -p references/blog-media-mmdc-puppeteer.json` (no sandbox, the Playwright headless shell); without it the render hangs. The site never loads Mermaid; it shows the files. Why: no quote of his; the retired skill's Critical list (old SKILL.md:32-35), the render hangs without the config.
5. **Films are motion-video's:** a clip with cuts, captions or music is a film; you call skill motion-video and never copy its steps. Why: no quote of his; the retired skill's Critical list (old SKILL.md:36-37), one owner for the cut, the captions and the music.
6. **Web formats and sizes** come from `references/blog-media-web-media.md`: WebP for screens, SVG plus PNG for diagrams, MP4 plus WebM with a poster for clips (never a gif on the web), 1200x630 for the cover. Why: no quote of his; `references/blog-media-web-media.md` (web.dev gif to video guide, Meta link share image guide).
7. **Every font, track, icon or image not made by him carries its licence file and a `licence` line;** fonts are local files, never a network font. Why: no quote of his; the retired skill's Critical list (old SKILL.md:40-41).
8. **No key, token, email, customer or end user name in any frame:** hide or crop it before the capture, never blur after. Why: no quote of his; the retired skill's Critical list (old SKILL.md:42-43).
9. **The box is shared:** you check for a running browser before every Playwright run, take 1 capture session per post, and run at most 1 dev server: the one the ticket names when it answers, one started on its port only when none answers (`references/blog-media-making.md`, Before any browser run). Why: two dev servers at once overload the shared box, and a task blocked for want of a server when none runs is lost time (the retired skill's Critical list, old SKILL.md:44-45).

Violating the letter of a law is violating the law.

## Intake

1. The post folder and its `post.json` media list: per item id, beat, kind, what it shows, route, file, alt, caption, format, and for code the `repo@sha:path#La-Lb` source.
2. Where the real app runs for this project (the project's own docs).
3. The repo for code blocks, at the sha the post names.

Fixed: formats, sizes and the 1200x630 cover. Free: crop and the capture order.

## Pipeline

Serves orchestration row D5 (dispatch, the builder's work).

| # | Step | Output | Reference |
|---|---|---|---|
| 1 | Check the tools: `which ffmpeg cwebp`, `node --version` after the PATH export, `python3 -I -c 'import PIL'`, `which mmdc` (Mermaid only); state the result | the tools line | `references/blog-media-making.md` |
| 2 | Group the items by route (`shot`, `clip`, `film`, `svg`, `code`, `output`, `image`) and write `media/shots.json` for every screenshot so the browser opens once | `media/shots.json` | law 9 |
| 3 | Screens and clips: check no browser runs, `node scripts/media.mjs shots media/shots.json`, `media.mjs clip` per clip; find each clip's start by eye with `scripts/web.sh strip` (printed step times drift under load); convert with `scripts/web.sh webp` and `scripts/web.sh clip` | `media/*.webp`, mp4, webm, posters | laws 1, 6 |
| 4 | Code and output: `python3 -I scripts/code-extract.py ...` per code item, pasted into `post.md`; `scripts/run-snippet.sh` per output item | blocks in `post.md` | law 3 |
| 5 | Diagrams: write `media/src/<name>.svg` (or `<name>.mmd`, then `mmdc -p references/blog-media-mmdc-puppeteer.json -i media/src/<name>.mmd -o media/src/<name>.svg`), then `node scripts/media.mjs svg ... --width 1600`; code blocks in `post.md` are fenced with their language so the site's Prism colours them | svg and png | law 4 |
| 6 | Films: skill motion-video, then link its mp4 and poster into `media/` | linked film | law 5 |
| 7 | Open every file with Read (images, posters, 2 frames of each clip), write `seen`, compare with `shows` and the beat's claim; a file that does not show the claim is made again or the beat changes | `seen` lines | law 2 |
| 8 | `scripts/web.sh sheet media media-sheet.png`, then `python3 -I scripts/media-check.py <post-folder>`; fix every FAIL | `ok` | |
| 9 | Preview for the critic's final pass: `node scripts/media.mjs preview <post-folder> preview-390.png` | `preview-390.png` | |

Do not skip step 7: a file nobody opened is a guess.

## Gotchas

| Symptom | Cause | Fix | Proof |
|---|---|---|---|
| The screenshot shows a spinner or a blank panel | the capture ran before the data arrived | `--wait-for` the element that proves the data arrived, or a `click` step that opens it | the opened PNG |
| `media-check.py` says a code block differs | it was retyped or trimmed by hand | paste the `code-extract.py` output again; narrow the range to shorten it | the check's FAIL line |
| A WebP is over budget | full page capture | crop with `--selector`, lower `--size`, or quality 75 in `web.sh webp` | the check's weight line |
| Text in the SVG renders in a serif fallback | a font family sharp cannot resolve | a generic family or a local `@font-face`; sharp has no network | the rendered PNG |
| `Cannot find module 'playwright'` | the node PATH is not exported | export the node PATH, or set `PLAYWRIGHT_FROM` | the error text |
| A clip opens on a white frame | the page was not loaded at the start offset | load a real page first, then `web.sh clip` with a start offset past it | the poster |
| The step times of a clip disagree with the video | wall clock drifts under load (29.6 s by the clock was 24.3 s of video) | find the start by eye with `web.sh strip` | the strip image |
| A mermaid render hangs | no sandbox config | `-p references/blog-media-mmdc-puppeteer.json` | the process never exits without it |
