# Making each kind of media

Open this when a media item's route is chosen (`post.json` field `route`) and again while making it. Every
command writes into the post folder, never into a repo. Node scripts need
`export PATH=$HOME/.nvm/versions/node/v24.15.0/bin:$PATH`; Playwright and sharp resolve from the project's
node_modules (the project skill names it), or `PLAYWRIGHT_FROM=<package.json>`.

## Before any browser run

The box is shared. Run `pgrep -x chrome-headless-shell || pgrep -x chromium` first; if a browser is running,
wait 30 seconds and look again. Capture from the dev server the ticket names (the project's own docs); start one
on its port only when none answers, never a second one. One capture session per post when the box is loaded: list
every shot first, then take them in one run with `media.mjs shots`.

## Screenshot (route `shot`)

- `node scripts/media.mjs shot <url> media/src/<name>.png --size 1440x900 [--selector css] [--hide css,css]
  [--wait-for css] [--scale 2]`. `--selector` crops to one element; `--hide` removes chrome that is not the
  subject (cookie banners, toasts). It waits for fonts and network idle and prints the size it wrote.
- Several shots in one browser: `node scripts/media.mjs shots shots.json`, a list of
  `{"url", "out", "size"?, "selector"?, "hide"?, "click"?, "wait"?}`.
- Then `scripts/web.sh webp media/src/<name>.png media/<name>.webp`.
- Real screens only, on demo data. No personal or customer data in the frame (motion-video
  `references/projects.md` for which data is safe per project).

## Short clip (route `clip`)

- A few seconds of one interaction, a loop that would otherwise be a gif: `node scripts/media.mjs clip <url>
  media/src/<name>.webm --size 1280x720 --seconds 6 [--steps steps.json]`, where steps are
  `{"click": css}`, `{"hover": css}`, `{"scroll": px}`, `{"wait": ms}`, `{"type": [css, text]}` run in order
  at a viewer's pace. It records with Playwright `recordVideo` and prints the take length.
- The step times it prints are wall clock and drift from the video under load (a take measured 29.6 s
  by the clock was 24.3 s of video). Find the start by eye: `scripts/web.sh strip media/src/<name>.webm
  strip.png <about the last step minus 2> 6` and open the strip.
- Then `scripts/web.sh clip media/src/<name>.webm media/<name> <start> <length>`: writes `<name>.mp4`,
  `<name>.webm` and `<name>-poster.webp` (the middle frame), no audio, and refuses existing outputs.
- Hide dev only chrome (the Next.js dev indicator `nextjs-portal`, cookie banners, hints) with `--hide`.
- Open the poster and two frames (`web.sh frames media/<name>.mp4 media/src/<name>-f 3`) to check it.

## Film (route `film`)

Anything with cuts, captions, music or more than one flow is a film: run skill motion-video with the beat's
claim as its promise, in the project's films folder, and link the result into `media/`. This skill never
copies its steps.

## Diagram (route `svg`)

- Write the diagram as SVG by hand in `media/src/<name>.svg`: a `viewBox`, text in a local font or a
  generic family (`system-ui, sans-serif` and `ui-monospace, monospace`), no external references.
- Neutral palette until the project has a brand file: ink `#1f2328`, paper `#ffffff`, line `#57606a`,
  one accent `#0969da`, a soft fill `#ddf4ff`. Contrast of text on its fill at least 7:1.
- One idea per diagram, at most about 9 boxes, labels that are the words the post uses, arrows that say
  what flows.
- Render: `node scripts/media.mjs svg media/src/<name>.svg media/<name>.png --width 1600` (sharp, no
  browser), keep the `.svg` beside it in `media/`.
- Mermaid for flow and sequence diagrams: `mmdc` is installed (11.4.2) and runs only with
  `-p references/blog-media-mmdc-puppeteer.json`; keep the `.mmd` beside the SVG it makes.

## Code block (route `code`)

- `python3 -I scripts/code-extract.py <repo> <sha> <path> <start> <end> [--lang ts]` prints the source
  line and the fenced block; paste both into `post.md` as printed. The source in `post.json` is
  `<repo>@<sha>:<path>#L<start>-L<end>`.
- Quote the sha the beat is about. When the screens are today's app and the code changed since, say so in
  the beat (what changed, with its sha) or quote at HEAD.
- A comment with an em or en dash inside the range: narrow the range around it (the code stays verbatim,
  and `post-check.py` warns).
- Keep blocks short: the 10 to 40 lines that carry the idea. Cut with a narrower range, never by editing
  the lines. A line you must drop in the middle is two blocks.
- `media-check.py` extracts the range again and fails when the block in `post.md` differs.

## Output of a run (route `output`)

A snippet that claims to run is run: `scripts/run-snippet.sh <workdir> -- <command...>` prints the command,
then the output exactly as it printed and the exit code, and writes nothing. Paste it under a line starting
"Output" in a `text` block. Never a long running or writing command (no database, no network, no deploy).

## Image (route `image`)

His photo, a baked tile PNG, a render from the repo: copy it into `media/src/`, convert with `web.sh webp`,
and name its origin (path at sha, or "his photo, given on <date>") in the caption. Anything from someone
else needs its licence (`references/blog-media-web-media.md`, Licences).

## Check what you made

1. Open every file with Read: the PNG or poster, two frames of a clip. Write in the item's `seen` field
   what the file shows, in your words, before reading its `shows` line again; then compare the two.
2. `scripts/web.sh sheet media media-sheet.png` builds a contact sheet of every image and poster for the
   critic.
3. `python3 -I scripts/media-check.py <post-folder>` checks existence, format, dimensions, weight, alt,
   caption, licence, `seen`, and every code block against its sha.

## Preview

`node scripts/media.mjs preview <post-folder> preview-390.png --size 390x844` renders `post.md` (headings,
paragraphs, lists, images, video, code) as a plain page at phone width, full length, for the critic's final
pass. One browser run; skip it and say so when the box is loaded.
