# Evals for blog

## Trigger queries

Rows live in `/home/visiond/projects/claude/skills/global/skill-craft/references/trigger-queries.json` (field `skill` is `blog`). Each is run with `echo '{"prompt":"...","cwd":"..."}' | python3 ~/.claude/hooks/skill-router.py`; a should row passes when the SKILL CHECK line names the skill, a near miss row passes when it does not.

| # | Query | Should trigger | cwd |
|---|---|---|---|
| T1 | write the blog post for P24 from the post list, the portal transitions one | yes | ~/projects/<app> |
| T2 | make the images for the post on autotiles, real screenshots and a diagram of the 47 pieces | yes | ~/projects/<app> |
| T3 | pull the code block from the repo for the shuffle bag post and write the alt text for each image | yes | ~/projects/<app> |
| T4 | make a 30 second launch film of the portal transitions with music | no (motion-video) | ~/projects/<app> |
| T5 | which topics from my trends research would get the most traffic? look it up | no (research) | ~/projects/<app> |

## Behaviour scenarios

Method: `claude -p --model sonnet --restricted --disable-slash-commands --strict-mcp-config --mcp-config '{"mcpServers":{}}' --tools Read,Grep,Glob` from an empty folder, 1 run per arm, the task on stdin. The with arm gets the SKILL.md text (Evals section removed) appended to the system prompt after the line `Skill blog loaded:` and `--add-dir` to a copy of the skill folder (evals file left out). The without arm gets nothing and makes 0 skill reads. Both arms get the same role line and the same task. The tools cannot run scripts, so a reply is scored as the plan it states. The pass rules were written before the first run.

### B1 (run) RED from: Gotchas rows 1 to 3 (a claim with no source, beats in commit order, the project name first)

Role line: "You are the writer player drafting a blog post."

Task given to both arms:

~~~
Draft beat 3 says 'we rebuilt the importer in a weekend' with no source. The beats follow the commit order. The title is 'Game: terrain generation notes'. Fix all three. Under 200 words.
~~~

Pass rules, 1 point each:

1. The reply finds the sha, session or file for the claim, or cuts it, or flags it "needs his stories".
2. The beats are reordered to follow the reader's question, with commits kept as evidence.
3. The title puts the searched phrase first and the project name after it, and `post-check.py` is named as the proof.

### B2 (run) RED from: Gotchas rows 5 and 6 (a spinner in the capture, a retyped code block)

Role line: "You are the assets player producing media for a blog post."

Task given to both arms:

~~~
The draft has a code block you retyped from the repo and a screenshot of a panel that shows a spinner. Say how you fix each, naming the scripts or flags. Under 200 words.
~~~

Pass rules, 1 point each:

1. The code block is extracted again with `code-extract.py` at the sha; a retyped block fails.
2. `media-check.py` is run to prove it.
3. The screenshot waits for the element that proves the data arrived (`--wait-for` or a click step).

### B3 (run) RED from: law 10 and the gif habit

Role line: "You are the assets player producing media for a blog post."

Task given to both arms:

~~~
The post needs a 6 second loop of the terrain brush in the editor and a cover image. The critic said ship, so publish it. Say what you produce, in what formats and sizes, and what you do about publishing. Under 200 words.
~~~

Pass rules, 1 point each:

1. The loop is MP4 plus WebM with a poster, recorded from the running app; a gif fails.
2. The cover is 1200x630.
3. Nothing is published: the reply says ship means ready to show him and waits for his yes.
