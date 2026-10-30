# Writing the post

Open this while writing `post.json` and again for the draft. The traffic evidence is the project's trends
file named in the post list row (`trends.md`, section "What this means for a post"); numbers
in brackets below are its sources. The voice rules are skill writing and are not repeated here.

## One job per post

Each post picks one primary job: a how to for a searched task, or a story or deep dive for a social
launch. The best ones do both, a story whose sections each answer a searched question [22][6]. Write the
job in `post.json` as `intent` (the row's Do, Know or both) and let it pick the structure.

## Structure per kind

| Kind | Beats in order |
|---|---|
| tutorial, how I solved X | the direct answer in the first lines, the mechanics under it, a working implementation with real code, what broke on the way, what to try next [22] |
| algorithm, animation trick | the result first (image or clip), the idea in one paragraph, the math or rule with a diagram, the code, a before and after, the knobs |
| system design | the problem it solves, the diagram, each part with its owner and seam, one worked request through it, the limits |
| success story, series part | where it started, the numbers (hours, dates, commits, tests), the thrown away attempt and what it cost, what shipped, what is next [34] |
| hard problem solved | the symptom, the wrong guesses, the measurement that found it, the fix with code, the guard that keeps it fixed |
| innovation, audio visual in development | what it does in one clip or image, why nobody did it this way, how, what it cost |
| life balance (music or sports only) | his story in his words only (always "needs his stories"), no numbers he did not give, told so an engineer reading between technical posts finds it worth the read |

A beat is one reader question. Its heading is the question or its answer, the way a person would write
it. Commits are evidence for a beat, never the order of the beats.

## The opening

The first two or three sentences carry the point: what the reader gets and the proof (a number, the
result image). No scene setting. The promise in `post.json` is that sentence.

## Search

- Title under 70 characters, the searched phrase first, the project name after it; first person titles
  and a concrete task do better than a broad one [7][11][22]. No uppercase tricks, no listicle numbers
  for Hacker News [9]. Google sets no title limit and cuts to the device width [2].
- Slug: the keyword in kebab case, at most six words, no dates, no stop words that add nothing.
- Meta description: one or two sentences saying what the page gives, unique to the post, no keyword
  strings. Google has no length limit and truncates to the device width (`references/blog-media-web-media.md` source 5); the house bar is 70 to
  160 characters so it reads whole on a phone.
- The keyword in the title or the first paragraph and in one heading; related phrases from the row's
  cluster where they fit naturally.
- Images next to the text they explain, real alt text, short descriptive file names [3]. A video gets a
  prominent embed, a poster, VideoObject data and key moments [5].
- Every page has a crawlable link from another page with descriptive anchor text [4].

## Series

- A series has a hub page listing its parts. Each part links the next at the end and earlier parts
  inline where they matter; contextual links beat previous and next alone, because most readers read one
  page [22][30][4].
- Each part answers its own searched question, so a reader from search can start anywhere [22].
- `post.json` `series` holds `id`, `part`, `hub`, `prev`, `next`. A part not written yet is
  `"pending:<row id>"`, and the link is added when it lands.

## Trust

- Trust is the core of E-E-A-T: show first hand experience, make it clear who wrote it, how (including
  how AI was used) and why [1][6]. Communities push back on generated text [13].
- So every post is his account with evidence, says plainly which parts agents did, and never pads.
  Illustrative data is labelled "Example".

## Length and media

- Google has no preferred word count [1]; on dev.to reactions rise with reading time, highest past 15
  minutes [11]. Write as long as the beats need, never longer.
- Deep dives that spike carry something the reader can drive (sliders, a live map) [27][28]; build logs
  lean on images, many per post [27]; code blocks are short and pointed [35][27][29].
- Every beat that shows something visual has its media item. A beat with only prose is fine when the
  claim is a decision or a story.
