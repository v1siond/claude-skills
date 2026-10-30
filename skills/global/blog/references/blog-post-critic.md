# The critic pass for a post

Open this before each of the three passes: outline, draft, final. The critic player runs it; the loop
rules are orchestration `references/critic.md`, this file holds what is particular to posts.

## What the critic gets

| Pass | Gets |
|---|---|
| outline | the post list row, `post.json`, the `post-check.py --stage outline` output, `references/blog-post-writing.md` |
| draft | the above plus `post.md`, the `--stage draft` and `check-text.sh` output |
| final | the above plus the rendered post (`references/blog-media-making.md`, Preview), the media sheet, the `media-check.py` and `--stage final` output |

Never the builder's reasoning or report. The critic judges what is on the page and in the files.

## Default: reject

Every score is earned by something the critic can point at: a beat id, a line of `post.md`, a media file.

## Axes, 1 to 10

| Axis | Ask | Passes |
|---|---|---|
| Audience | Is it written for a software engineer (or one of the occasional music or sports posts), at their level, nothing explained they already know? | all |
| Promise | Is the point and its proof in the first two or three sentences, and is it the row's description? | all |
| Structure | Do the beats follow the kind's structure in `references/blog-post-writing.md`, one reader question each? | all |
| Search | Title under 70 with the searched phrase first, slug, meta description, keyword in a heading, intent met? | all |
| Evidence | Does every claim about his work have a sha, session plus timestamp or file that says it, and was each one opened? | all |
| Media plan | Does every visual beat have an item saying what it shows and how it is made, with a real route? | outline |
| Reading | Short paragraphs, headings a person would write, code blocks short, reads at 390 px? | draft, final |
| Voice | writing: no dashes, no antithesis, no filler, varied sentences, check-text clean? | draft, final |
| Media | Does each file show what its beat claims (the `seen` line against the file)? Alt, caption, size, format, licence? | final |
| Code | Is every block extracted at a sha, and every run output pasted as printed? | draft, final |
| Series | Hub, inline links to earlier parts, next link or a pending mark? | all, when a series |
| Honesty | Any invented number, secret, personal data, listed client name, or AI work presented as his hand? | all |

Any axis at 7 or less is a fix. Any honesty failure is a stop, whatever the other scores. A post that is a
how to fails Promise when the reader has to scroll to find the answer.

## The report

`critic/<pass>-N.md`: a table `| Axis | Score | What, where, smallest fix |`, then the three worst
problems with their beat ids, the three things a reader sees first in order and whether that order is the
promise, and a last line `Verdict: ship`, `Verdict: fix` or `Verdict: rethink`. `post-check.py --stage
final` reads that table and that line.

## The loop

1. Each fix round names what must not change: every beat or media item that scored 9 or more, and every
   part he approved.
2. Fix, run the scripts again, critic again, stop at every axis 8 or more and ship.
3. The fresh reader test (skill writing, Checklist 6) runs on the final: a fresh read-only agent
   given only `post.md` states its point in one line; it must be the promise.

The final call is his.
