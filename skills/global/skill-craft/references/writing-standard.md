# The standard for a good skill: findings

Research player. Read only; this is the one file written.

The ask: judge a skill against the Howseen motion-design SKILL.md, Anthropic's "The Complete Guide to Building
Skills for Claude" (https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) and the
MindStudio post (https://www.mindstudio.ai/blog/claude-skills-best-practices-update), on format and on wording: how
specific each instruction is for its context, when a number or formula beats prose, and how readable it is to the model.

## Contents
- Sources and how each was read
- A. Structure rules our framework lacks or contradicts
- B. Wording (the core of his ask)
- C. Writing for the model: the checklist a critic can fail
- D. Orchestration SKILL.md scored against C: the 5 worst lines
- E. Conflicts between the sources and his standing rules

## Sources and how each was read

| Key | Source | Read |
|---|---|---|
| H | Howseen `skill/motion-design/SKILL.md`, 175 lines, local copy at `/home/visiond/projects/claude/standards/howseen/motion-design-SKILL.md` (the SKILL.md and its LICENSE) | Whole. GitHub main is the same commit (3d90d34); raw file diffed identical, so no newer version. Also read whole: `scripts/remake/BRIEF_TEMPLATE.md`, README.md, every short script, the docstrings and headers of `render_template.py` and `core.js`. The skill has no `references/` or rules folder; the files it links are the scripts. Cited as H:line. |
| G | Anthropic, "The Complete Guide to Building Skills for Claude", 33 pages, https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf | Every page via pdftotext (reading order and layout). Cited as G p.N (printed page number). |
| MS | MindStudio, "Claude Skills Are Outdated: How to Update Them to Anthropic's New Rules", https://www.mindstudio.ai/blog/claude-skills-best-practices-update | Whole article (curl, tags stripped; product ads skipped). Secondary source: it summarises Anthropic's platform page, so I also read that page. |
| BP | Anthropic, "Skill authoring best practices", platform.claude.com, https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | The sections MS summarises, plus its checklist. Used to verify MS quotes against the primary source. |
| F | Our framework `/home/visiond/projects/claude/skills/global/skill-craft/references/skill-framework.md` (the brief's path under `global/` does not exist; this is the real one) | Whole. Cited as F:line. |
| O | `/home/visiond/projects/claude/skills/global/orchestration/SKILL.md` | Whole, plus `references/critic.md`. Cited as O:line. |

---

## A. Structure rules our framework lacks or contradicts

| # | Rule | Source and exact quote | The old framework (F) |
|---|---|---|---|
| A1 | "claude" in a skill name is reserved | G p.11: "Skills with "claude" or "anthropic" in name (reserved)". BP: name "Cannot contain reserved words: "anthropic", "claude"" | Contradicted by our own skill `skill-craft`. Needs his decision (E5). |
| A2 | name is kebab-case and matches the folder | G p.10: "Should match folder name"; "kebab-case only" | F silent. |
| A3 | description limits and voice | G p.10: "Under 1024 characters", "No XML tags (< or >)". BP: "**Always write in third person**." G p.11: "[What it does] + [When to use it] + [Key capabilities]" | F template has what, player, when, not; no limit, no voice rule. Audit: `scripts/lint-skills.py` FAILs a description over 1024 characters or holding < or >. "Use when he says" is third person, so it passes. |
| A4 | Reference files over 100 lines open with a contents list | BP: "For reference files longer than 100 lines, include a table of contents at the top." MS: "Reference files over 100 lines need a contents list (an index of headings) at the top, or Claude may only skim the beginning and miss anything further down." | F silent. Six failed when audited (lint W16 now lists every one): orchestration `references/prompts.md` (146), motion-video `references/live-take.md` (105), a project skill's `quality-checklist.md` (105) and `bundle-and-tools.md` (101). |
| A5 | References one level deep from SKILL.md | BP: "**Keep references one level deep from `SKILL.md`**." MS: "Flatten anything nested more than one level." | F silent (F:28 only says "load only what the current step needs"). |
| A6 | Length | BP: "Keep the `SKILL.md` body under 500 lines for optimal performance." G p.27: "Keep SKILL.md under 5,000 words" | F:40 "80 to 200 lines" is stricter, so compatible. One project skill's SKILL.md is 210 lines, over our own cap. |
| A7 | Every script step names its install | MS: "Does every script-based step include its own install or setup instructions, rather than assuming the environment is already configured?" BP: "Required packages listed in instructions and verified as available" | F silent. H does it in its README ("Python deps: `pip install playwright imageio-ffmpeg numpy pillow`"), not in SKILL.md, so H fails this too. |
| A8 | Scripts solve, constants are justified | BP: "handle error conditions rather than deferring to Claude"; "No "voodoo constants" (all values justified)" | F:36 says a script beats prose; nothing on how the script is written. H's `render_template.py` shows the shape: `SHUTTER = 0.5  # fraction of the frame interval the subframes cover (0.5 = 180 deg film look, 1.0 = smeary)`. |
| A9 | A checklist copied into the reply, with a step that sends work back | BP: "provide a checklist that Claude can copy into its response and check off as it progresses." MS: "if citations are incomplete, return to an earlier step rather than marking the checklist complete." | F:27 Definition of done is checked at the end, never copied in and ticked as work runs. O:100 does have a send-back ("Findings back to step 4"). |
| A10 | Degrees of freedom chosen per step | BP: "Match the level of specificity to the task's fragility and variability." MS: "Are degrees of freedom applied per step, not uniformly across the whole skill?" | F:10 "A skill is a process to follow exactly." covers the whole skill with one level. See E3. |
| A11 | Trigger tests with a number | G p.9: "Skill triggers on 90% of relevant queries ... Run 10-20 test queries that should trigger your skill." G p.15: should trigger and "Should NOT trigger" lists | F:29 Evals hold behaviour scenarios only; trigger tests live only in skill-craft (`trigger-queries.json`); the framework section list omits them. |
| A12 | Evals: three, with a baseline, on every model | BP: "Build three scenarios that test these gaps."; "Tested with Haiku, Sonnet, and Opus". MS: "Anthropic recommends documenting the intended model in the skill's YAML front matter." G p.16 baseline compares "back-and-forth messages", "failed API calls", "tokens consumed" | F:29 has RED baseline and GREEN, no count, no model, no token or tool call measure. |
| A13 | Build the eval before the text | BP: "**Create evaluations BEFORE writing extensive documentation.**" G p.15: "iterate on a single challenging task until Claude succeeds, then extract the winning approach into a skill." | F silent on order. |
| A14 | Time-bound facts kept out of the instructions | BP: "Don't include information that will become outdated" and an "Old patterns" section | F silent. H fails it: H:63 "21st.dev `search_logo` currently returns nothing", H:67 "(checked 28/09/2026)". |
| A15 | A debug question for triggering | G p.25: "Ask Claude: "When would you use the [skill name] skill?" Claude will quote the description back." | Not in F or skill-craft. |
| A16 | H's "start from the library" section | H:14: "**Read `howseen-video/INDEX.md` first**: every film we made, its final file and what to reuse. Copy the closest folder instead of starting from zero." | F has "worked example" (F:28) but no index of finished outputs to copy from. |
| A17 | H's prompt library | H:115: "**Prompt library** (adapt, never paste raw for a client)" followed by the exact prompts | F has `references/prompts.md` (his prompts as spec) but no library of tested prompts to reuse. |
| A18 | H's effort per task size | H:107: "**Effort**: medium for small fixes, xhigh for a new film, max when the first 3 seconds carry a launch." | F silent; orchestration casts models (O:80) but sets no effort by size. |

No README inside any skill folder (G p.10: "Don't include README.md inside your skill folder"): checked, none found.

---

## B. Wording

### B1. What a Howseen line looks like

H writes in fragments and uses `=` and `→` as grammar. Subject, rule, number, reason:
- H:34: "**Springs** = closed-form step response `step(tau, f, z)`; a value with many targets = sum of one spring per change. ... Linear motion = cheap, never."
- H:35: "**Camera** = one transform on a container, keys `[t, zoom, x, y]`, eased segments, **zoom interpolated in log space**, never zoom in/out back-to-back."
- H:113: "ONE accent colour; **one thing moves at a time** (unless a slider drives a continuous transform)"

Count: 114 of H's 175 lines hold a digit. 0 lines use MUST, IMPORTANT, CRITICAL, ALWAYS or NEVER in capitals. "never" appears 27 times in lower case.

### B2. Degree of freedom, set per context

The sources agree that freedom is chosen per step by what a mistake costs:
- BP: "**Narrow bridge with cliffs on both sides:** There's only one safe way forward. Provide specific guardrails and exact instructions (low freedom)." and "**Open field with no hazards:** Many paths lead to success. Give general direction and trust Claude to find the best route (high freedom)."
- MS: "If Claude doing it slightly differently wouldn't matter, give it more freedom. If a different approach could cause real damage, lock it down, usually by turning that step into an actual script rather than more detailed prose."
- BP low freedom example: "Run exactly this script: ... Do not modify the command or add additional flags."

How H does it in practice:
- Low freedom where frames can break: H:50 the full encode string, "`scale=in_range=pc:out_range=tv:out_color_matrix=bt709,format=yuv420p`, ... libx264 crf 16, AAC 256k, `+faststart`." H:93 to 96 are four exact ffmpeg commands.
- High freedom where taste decides: H:58 "Minimal sound design for "premium/Apple" films: a handful of soft hits, remove anything that feels loud or out of place."
- A stated default when the input is missing: H:27 "Otherwise pick sensible defaults and say so."
- Freedom closed by who asks: H:11 "Suno/Envato/Higgsfield only if Raphaël asks and has credits."

### B3. Specific per context

H never states one rule for all cases when the case changes the answer. It branches on a measured property:
- Film length: H:48 "**Films > 25 s: always render in 3 parallel chunks**"
- Platform: H:85 "LinkedIn video: 4:5 1080×1350; X: 16:9 or 1:1, ≤ 2:20"
- Motion speed: H:140 "still → 1 sample, ≤ 20 px → 4, above → `ceil(px/5)` up to 64."
- Task size: H:107 effort by fix, new film, launch.
- Size of element: H:145 "reveals may shift ≤ 0.15 s (small entrances ≤ 0.10 s)"

G p.24 shows the same shape: "Large files (>10MB): Use cloud storage MCP".

### B4. Why-clauses

H's reason is the consequence that was seen, in under 10 words, in brackets or after a colon. It tells the model what breaks, so the model can judge a case the rule did not foresee:
- H:17 "with a continuous per-pixel formula (hue thresholds blotch JPEG blocks)"
- H:45 "(6-8 for fast moves, 4 = ghosting)", "(1.0 = smeary)", "(**always before the master**: judge rhythm, not sharpness)"
- H:46 "(headless WebGL otherwise renders black)"
- H:74 "Avoid Spline/Unicorn embeds on the site (kills the Lighthouse 100)."
- H:144 "(X/Slack/Discord ignore the cover)"
- H:78 the gotcha with its mechanism: "An easing solved by bisection returns ~1e-9 at x=0: `if (e > 0)` guards fire early (a whole dive disc appeared 2 s early). Return exact 0/1 at the ends."

BP on numbers with no reason: "If you don't know the right value, how will Claude determine it?" Bad: "`TIMEOUT = 47  # Why 47?`".

### B5. Naming instead of describing

The strongest single rule for his ask, H:112: "**a named reference style** ("Linear launch", "Stripe docs", "Apple bumper", never "premium modern")". An adjective is banned and a named, checkable thing replaces it.

Other names in H that replace description:
- Easings by name: H:34 "`io` (cubic in-out), `out`, `in`, `o5`, `expo`".
- Spring presets by name and number: H:104 "snappy UI 320/30, default containers/camera 170/26, heavy type/logos 120/24, playful mascots 180/12."
- Sounds by catalogue id: H:56 "click 1125, key 2568, soft tick 1117, ...".
- A rule set by its owner: H:54 "Leo's framework".
- Each reference implementation by file: H:39 "`frame/frame.html` (liquid glass via canvas displacement, goo, 6-blade iris, ...)".
- PRNG by name: H:101 "use a seeded PRNG (mulberry32)".

G p.26 for tool names: "Tool names are case-sensitive".

### B6. Examples next to rules

- BP: "Examples convey the desired style and level of detail to Claude more clearly than descriptions alone." BP checklist: "Examples are concrete, not abstract".
- H gives the example inside the rule: H:36 "**Shared elements** for every handoff (the bubble carries its words into the flood, the button carries its label into the page)." H:21 "real data is sourced on screen (e.g. "12 logged-out ChatGPT answers · 25 Sep 2026")".
- H:114 gives a pass and a fail example of one test: "if they summarise it in one sentence ("the button became a player"), it works; if they hesitate, too much moves."
- H:116 to 121 hold the full prompts to reuse, quoted.

### B7. Positive and negative phrasing

H almost always pairs the "never" with the thing to do, in the same line:
- H:40 "`visibility:inherit` (not `visible`)"
- H:55 "**Find the drop by energy**, never trust an auto grid: per-bar low/full band energy, then 20-50 ms windows around the jump."
- H:83 "Measure text with canvas (`measureText`) not DOM rects when a camera scale is applied."
- H:102 "Take the grammar, never the content or logos."
- H:64 "**port the idea to seek(t)**, never run them live."

BP says the same about options: "**Good example: Provide a default** (with escape hatch)". Bad: ""You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or...""

### B8. Emphasis and capitals

- H puts capitals on one load-bearing word only: H:113 "ONE accent colour", H:45 "position (last vs frame 0) AND velocity", H:112 "from the SAME timeline", H:173 "every title on ONE line", BRIEF_TEMPLATE:16 "Write ONLY shots/<G>.js". Bold marks the rule inside a line (230 bold markers in 175 lines).
- G p.26 recommends louder: "Put critical instructions at the top", "Use ## Important or ## Critical headers", "Repeat key points if needed".
- MS warns the other way for newer models: "Older or smaller models sometimes needed heavy-handed formatting, numbered steps, and emphasis like capitalized "IMPORTANT" flags to avoid skipping steps. Newer, higher-end reasoning models can behave the opposite way: being too prescriptive can actively hurt output quality". BP: "Claude Opus (powerful reasoning): Does the Skill avoid over-explaining?"
- The sources disagree; see E1 for how his rules settle it.

### B9. One term per thing

- BP: "Choose one term and use it throughout the Skill" and "Consistency helps Claude parse and follow instructions." Bad: "Mix "extract," "pull," "get," "retrieve"".
- H keeps one word per concept (seek(t), beat map, stills, pops, drop) and defines each once. Its own slip: "subframes" and "samples" both name the same thing (H:45, H:140).
- Ours: 52 files under `/home/visiond/projects/claude/skills` name skill `dev-flow`, which does not exist. O:3 sends the test question to testing-standard, O:26 to dev-flow.

### B10. When a number, formula or table replaces a word, and when prose wins

The rule the sources support: **anything a check can measure is written as a number, a formula or a named thing; prose is kept for taste, stance and the order of work, and then it carries a test a reader can pass or fail.** G p.26: "Code is deterministic; language interpretation isn't." G p.13 bad: "Validate the data before proceeding." BP: "Match the level of specificity to the task's fragility and variability."

Every place in H (and the files it links) where a number, formula or named value stands where a word would be:

| H line | The word it replaces (implied) | What H writes |
|---|---|---|
| 15 | "loud enough" | "two-pass −14 LUFS / TP −1.3"; "deviceScaleFactor 2 = 4K" |
| 17 | "settle smoothly" | "never key settles in 3-frame steps (per-frame law, fastest step first), exits geometric ×1.5" |
| 17 | "remove the off colours" | "a continuous per-pixel formula (hue thresholds blotch JPEG blocks)" |
| 18 | "crop out the watermark" | "crop centre 76 % to drop the watermark" |
| 28 | "keep it moving" | "Nothing still for > 1 s." |
| 29 | "a few previews" | "**4 stills**" |
| 34 | "smooth motion" | "closed-form step response `step(tau, f, z)`"; named easings `io`, `out`, `in`, `o5`, `expo`; "Linear motion = cheap, never." |
| 35 | "natural zoom", "a little punch" | "**zoom interpolated in log space**"; "Beat punches: `+0.012` per beat, `+0.03` per bar after the drop, exp decay." |
| 37 | "staggered text" | "translateY 105% inside overflow:hidden", "word-by-word stagger (55 ms)" |
| 38 | "fills the screen quickly" | "must **clear the farthest corner** (`hypot` to the 4 corners ×1.05) in ~0.3-0.35 s" |
| 41 | "warm off-white", "brand colours" | "`#f5f5f2`/`#f7f7f5` or ink `#0b0b0c`; Howseen sky `#38bdf8`, ..."; font file paths; "(wdth 62-125)" |
| 44 | "the right size" | "1920×1080, 1080×1350 for LinkedIn 4:5, 1440×1440 square" |
| 45 | "a quick draft" | "30 fps, 1 capture/frame, 960×540, crf 23 veryfast" |
| 45 | "nice motion blur" | "6-8 for fast moves, 4 = ghosting", "`SHUTTER = 0.5` of the frame (180° film shutter; 1.0 = smeary), 60 fps" |
| 45 | "glitches" | "frame-diff spikes > 3× neighbours" |
| 45 | "seamless loop" | "seam check in **position (last vs frame 0) AND velocity (motion into vs out of frame 0)**" |
| 46 | "wait for it to settle" | "**wait 2 `requestAnimationFrame` after every `seek(t)`**" |
| 48 | "Raphaël expects fast turnarounds" (the prose is kept, then turned into a rule) | "**Films > 25 s: always render in 3 parallel chunks** ... ~20 min for 55 s instead of ~55 min sequential." |
| 49 | "long renders" | "~1-1.5 min of wall time per second of film at 8 subframes" |
| 50 | "high quality export" | "libx264 crf 16, AAC 256k, `+faststart`", bt709 TV range |
| 54 | "the drop" | exact drop times to the ms, e.g. "drop **14.769 s**" |
| 54 | mood words: "regal", "smooth", "elite", "hype" | "Leo's framework: 60-80 BPM regal, 90-110 smooth, 115-123 elite/sophisticated, > 125 hype." This is the literal case his ask names: "smooth" becomes 90-110 BPM. |
| 55 | "line the song up" | "20-50 ms windows around the jump. Start the song at `drop_in_song - drop_in_film`." |
| 56 | "a click sound" | Mixkit ids: "click 1125, key 2568, ..." |
| 57 | "on time", "not too loud" | "**Place every SFX by its measured peak** (argmax of \|s\|), gain 0.04-0.3"; "music ducked ~9 dB under the voice" |
| 61 | "good resolution", "clean cutout" | "`&w=2600&q=85&fm=jpg`"; "trim 5 px" |
| 78 | "starts at zero" | "returns ~1e-9 at x=0 ... Return exact 0/1 at the ends." |
| 79 | "eye opening reveal" | "scaleY 0.014 → 1", "overlay the solid line for the first 12 %"; "subframes 4/12" |
| 85 | "short enough for X" | "≤ 2:20" |
| 88 | "done" | checklist: "0 unexplained pops", "−14 LUFS", "TV-range BT.709" |
| 93 to 96 | "look at the film" | four ffmpeg commands: "fps=2,scale=270:-1,tile=6x5", "12 frames around a fast move", "fps=1,scale=360:-1,tile=5x3" |
| 98 | "good enough" | "**score 1-10**", "hook in the first 2 s", "readability at 360 px", "something new every 2-4 s", "the 3 worst problems with timestamps", "**Repeat until every score is 8+.**" |
| 101 | "consistent" | "never `Math.random`; use a seeded PRNG (mulberry32). Rendering the same second twice must give identical frames." |
| 102 | "study the reference" | "extract a frame every 0.5 s" |
| 104 | "snappy", "heavy", "playful" | "(stiffness k, damping d): snappy UI 320/30, default containers/camera 170/26, heavy type/logos 120/24, playful mascots 180/12." |
| 105 | "all formats" | "9:16, 1:1, 16:9 and 4:5 from the same timeline" |
| 106 | "a click", "a pop", "a whoosh" | "click = short decaying sine, pop = rising sine, thump = falling sine, whoosh = windowed noise" |
| 110 | "the harness matters most" | ""The prompt is 10 %, the harness is 90 %."" |
| 112 | "premium modern" | "a named reference style"; states "with timestamps (hook type 0-2.5 → ...)"; "6 beats" |
| 113 | "not bouncy", "readable on a phone" | "springs with damping ratio ≥ 0.72, tiny overshoot, never cartoon bounce"; "text inside the centre 1080×1080" |
| 118 | "a UI morph" | "8-12 UI states", "~120 BPM" |
| 120 | "LinkedIn loop easing" | "5-9 s loop", "`cubic-bezier(.6,0,.2,1)` and `cubic-bezier(.2,.8,.2,1)`" |
| 122 | "keep improving" | "2-4 rounds", "a frame at every beat and 0.3 s after", "fix only ≤ 7, don't touch shots at 9+" |
| 131 to 132 | "Cheap, bouncy" (symptom in his words) | "Bounce easing → springs, damping ≥ 0.72" |
| 140 | "enough blur samples" | "still → 1 sample, ≤ 20 px → 4, above → `ceil(px/5)` up to 64" |
| 141 | "sharp text", "blur the big moves" | "blur only the 1-3 slam moves; never blur ... any move < one element width per frame. **Supersample 2×**" |
| 142 | "clean cut" | "zoom keeps the sign of d(scale)/dt across the cut; seam blur ... (≈ 10 px text, 18-20 px full frame)" |
| 143 | "flash", "loops cleanly" | "frame n differs from both neighbours while n-1 ≈ n+1"; "seek(0) vs seek(T), T-1f, T-1.75f; cycles must be integer `cyc(t, n)`" |
| 145 | "on the music" | "intensity = 0.45·onset + 0.25·contrast + 0.20·rms + 0.10·bass; reveals may shift ≤ 0.15 s (small entrances ≤ 0.10 s)" |
| 146 | "readable captions" | "pop 1-3 words or karaoke 3-7, ≥ 0.7 s on screen, ≤ 17 chars/s, no 1-3 frame gaps" |
| 147 | "scrub" | "←/→ ±0.5 s (Shift = 1 frame)" |
| 148 | "enough face time" | "full-frame cutaways 3-10 s with ≥ 2 s of face between" |
| 151 | "medium / heavy density" | "≈ 33 s: medium = 3 clips, heavy = 4-5" |
| 160 | "a few cuts" | "expect only ~10-15 hard cuts", "6-frame contact sheets" |
| 162 | "close tempo" | "stretched ≤8%", "-14 LUFS", "~25 min per agent" |
| 169 | "pace", "readable" | "problem ... (3-5 s)", "Each step 2-7 s. Every element finishes animating and stays readable ≥ 1.5 s." |
| 173 | "safe margins" | "Safe margins 110 px (16:9) / 80 px (9:16); every title on ONE line." |
| 174 | "thorough" | ""motion bible" (30-40 checkable rules)", "5 competing concepts", "7 critics", "≥ 3 rounds" |
| BRIEF_TEMPLATE:6 | "match the reference" | "Target: position/size error ≤1-2% of frame, cuts 0 frames off." |
| BRIEF_TEMPLATE:21 | "check a few frames" | "(first/last, keyframes, 2 frames into every transition, ≤15 per call)" |
| remake_qa.py | "old brand colour" | `m = (r > 180) & (r - g > 60) & (r - b > 60) & (g > 60)` and `if m.sum() > 150` |

Where H keeps prose, and why it works there:
- Taste, with a removal rule: H:58 "remove anything that feels loud or out of place".
- A stance for the critic: H:98 "Be a harsh motion director, not a proud author."
- A human test that still has a pass and a fail: H:114 the silent one-sentence test.
- Banned things named as nouns, no number needed: H:113 "banned: rainbow gradients, particles, glowing chrome, emoji, lorem ipsum, gratuitous 3D flips".
- Order of work: H:26 to 30, numbered, one verb each.
- Honesty rules where the object is a sentence: H:22 "no "made in 10 minutes" if it wasn't".

### B11. How a check is made deterministic

1. Run a script that prints the verdict. G p.26: "For critical validations, consider bundling a script that performs the checks programmatically rather than relying on language instructions." H:45 `pops`, `loop`; H:143 flash detector "built into `pops`".
2. State the input, the command and the pass value. G p.13 good: "Run `python scripts/validate.py --input {filename}` to check data format." with the common failures listed: "Invalid date formats (use YYYY-MM-DD)".
3. Same input, same output. H:101 "Rendering the same second twice must give identical frames."
4. A separate judge with a numeric bar. H:143 "**Judge ≠ builder**: run the critique as a separate read-only sub-agent, and have a fresh agent restate the message from the frames alone (if it can't, the film fails)."
5. A stop rule. H:98 "**Repeat until every score is 8+.**"; G p.23 "Know when to stop iterating".
6. A send-back. BP: "If verification fails, return to Step 2."

### B12. How ambiguity is removed

- Replace "properly" with the list of conditions. G p.26 Bad: "Make sure to validate things properly". Good: "CRITICAL: Before calling create_project, verify: - Project name is non-empty - At least one team member assigned - Start date is not in the past".
- Replace an adjective with a named reference (H:112).
- One default, one escape hatch (BP, B7).
- One term per thing (B9).
- Say what "the input" is when it is missing (H:27 "Otherwise pick sensible defaults and say so.").
- Put the symptom in the user's words next to its fix (H:126 to 135 "Diagnostic when it's ugly", e.g. "Cheap, bouncy | Bounce easing → springs, damping ≥ 0.72").

---

## C. Writing for the model: the checklist a critic can fail

Each test is run on a SKILL.md and its references. Text inside his quotes is exempt from C1, C9 and C13 (his words are copied).

| # | Test (fails if...) | Traced to |
|---|---|---|
| C1 | **No bare quality word.** Any of good, clean, proper, careful, fast, smooth, nice, real, closed, measurable, solid, robust, simple in an instruction without, in the same line, a number with a unit, a backticked file or command, or a named reference. | H:112 "never "premium modern""; G p.26 bad "Make sure to validate things properly"; F:34 "Never "good", "clean" or "careful"." |
| C2 | **Every threshold has a unit and a direction.** A bare number, or a number with no ≥, ≤, >, < or "or more", fails. | H:146 "≥ 0.7 s on screen, ≤ 17 chars/s"; H:113 "damping ratio ≥ 0.72" |
| C3 | **Every check names how it runs and what passes.** Each check, verify, control or QA step must hold a command or file and a pass value. | G p.13 good "Run `python scripts/validate.py --input {filename}`" vs bad "Validate the data before proceeding."; H:45 "> 3× neighbours" |
| C4 | **A countable check is a script.** A check that counts, greps, diffs or compares files but is written as prose fails. | G p.26 "Code is deterministic; language interpretation isn't."; F:36 |
| C5 | **Freedom matches the cost of a mistake, per step.** A step that deletes, migrates, pushes or spends is prose; or a judgment step is forced into one fixed procedure with no stated reason. | BP "Match the level of specificity to the task's fragility and variability."; MS "Are degrees of freedom applied per step" |
| C6 | **Every number and every non-obvious rule has its reason.** The reason is the consequence seen (what breaks), or a source. | H:45 "(4 = ghosting)"; H:17 "(hue thresholds blotch JPEG blocks)"; BP "No "voodoo constants" (all values justified)" |
| C7 | **One term per thing.** Units of work (ticket, row, batch, wave, lane, score) each defined once and never swapped; every skill named exists in SKILLS.md. | BP "Choose one term and use it throughout the Skill" |
| C8 | **Every "never" says what to do instead,** in the same line. | H:55 "never trust an auto grid: per-bar low/full band energy"; BP "Provide a default (with escape hatch)" |
| C9 | **No added shouting.** Outside his quotes, no IMPORTANT, CRITICAL, MUST or all-caps sentence; capitals allowed on one load-bearing word or a status token (BUILT, DONE, STOP, DECISION, RED, GREEN). | H: 0 such lines, "ONE accent colour"; MS "being too prescriptive can actively hurt output quality" |
| C10 | **A rule about the shape of an output points to a filled example** (input and output, or before and after). | BP "Examples convey the desired style and level of detail to Claude more clearly than descriptions alone."; H:36, H:114 |
| C11 | **Prose rules carry a pass and a fail.** A taste or judgment rule must say how a reader tells pass from fail. | H:114 "if they summarise it in one sentence ..., it works; if they hesitate, too much moves." |
| C12 | **A condition has a number.** "When large", "if needed", "for small fixes" without a size, count or time fails. | H:48 "Films > 25 s"; G p.24 "Large files (>10MB)" |
| C13 | **One rule per numbered item.** A law or step with more than two independent rules (count the clauses joined by ";" or ":") fails. | G p.26 "Instructions too verbose ... Keep instructions concise"; BP "Concise is key" |
| C14 | **Every loop has a stop and a send-back.** Repeat, iterate or fix-and-check without a numeric bar and a "back to step N" fails. | H:98 "**Repeat until every score is 8+.**"; G p.23 "Know when to stop iterating"; MS "return to an earlier step" |
| C15 | **Every path and skill name resolves.** A link to a file or skill that does not exist fails; a reference reached only through another reference fails. | BP "**Keep references one level deep from `SKILL.md`**"; G p.13 "Reference bundled resources clearly" |
| C16 | **Reference files over 100 lines open with `## Contents`.** | BP "For reference files longer than 100 lines, include a table of contents at the top." |
| C17 | **A choice has a default first.** Two or more options listed with no default fails. | H:27 "Otherwise pick sensible defaults and say so."; BP bad "You can use pypdf, or pdfplumber, or PyMuPDF" |
| C18 | **Description passes lint:** what + when (his phrases) + Do NOT use for (sibling), third person, ≤ 1024 characters, no < or >, name kebab-case and equal to the folder, no "claude" or "anthropic". | G p.10 to 11; BP "Always write in third person" |
| C19 | **Evals exist and are numbered:** 10 to 20 trigger queries with should and should-not; 3 or more behaviour scenarios with a RED baseline; the model each ran on recorded. | G p.9 "Run 10-20 test queries"; BP "At least three evaluations created", "Tested with Haiku, Sonnet, and Opus" |

---

## D. Orchestration SKILL.md scored against C

Score: passes C9 (no added shouting; capitals only in his quotes and status tokens), C17, C18. Strong on files per step (O:86 to 102) and on gotchas with proof (O:108 to 117). Weak on numbers: two lines in 161 carry a threshold (O:94 "every axis 8 or more", O:135), against 114 of 175 in H.

The 5 worst lines:

**1. O:128 to 129** (fails C1, C3, C12)
> "Open his server and use the change as he will, in every view it ships in. Put each of his sentences next to what is on the screen. Fix what fails, check again, and only then show him."

"his server", "as he will" and "every view" are not named; no file is left; no pass value. Rewrite:
> Before the report, fill `score/<ticket>/qa/qa.md`, one row per sentence of his: the sentence quoted | the URL on his dev server (from ORCHESTRA.md) | `qa/after-<n>.png` at 1440 px and at 390 px | PASS or FAIL. Show him only when every row is PASS. A FAIL row goes back to step 4 as a ticket.

(1440 px and 390 px are already the page axes in `references/critic.md` line 22.)

**2. O:93** (fails C1, C10, C15)
> "Brief each ticket closed: his words, the reference, inputs, files owned, skills (always engineering-standards and testing-standard), the batch's test mode, measurable check"

"closed" and "measurable" are defined only in `references/critic.md` line 20, so the line depends on a second file to mean anything. Rewrite:
> Brief each ticket with these fields, none empty: his words quoted; the reference file; inputs; files owned (paths); skills (engineering-standards, testing-standard, plus the cast's); the test mode from ORCHESTRA.md Decisions; the check, as a command with its expected output or a number with a threshold. Filled example: `references/score-template.md`.

(The pointer to a filled brief needs a filled brief added to the template.)

**3. O:26, also O:156 and `references/critic.md` line 21** (fails C7, C15)
> "The dispatch mechanics of one wave: agent-dispatch. The test order inside one build ticket: dev-flow."

Skill `dev-flow` does not exist (no folder; 52 files still name it). O:3 sends the same job to testing-standard, and law 8 (O:44) now sets the test mode. Rewrite:
> The dispatch mechanics of one wave: agent-dispatch. Whether a ticket gets tests: law 8. How to write a test: testing-standard.

**4. O:97** (fails C1, C3, C15)
> "| 8 | Integrate: merge, seams checked against the contract | ORCHESTRA.md Log line | |"

"seams" and "the contract" are not defined in this file, the Reference cell is empty, and a Log line cannot fail. Rewrite:
> | 8 | Integrate: merge each lane's branch; for every pair of lanes that meet, run the request or test that crosses them against the architect's contract doc (path in ORCHESTRA.md) | `score/<ticket>/integrate.md`: per seam, the command, its output, PASS or FAIL | `references/role-cards.md` architect |

**5. O:160 to 161** (fails C15, C19)
> "Behaviour scenarios in `/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md (old path, quoted as it stood; now global/skill-craft)`, each with its RED baseline (the incident in Gotchas) and the GREEN run."

The path does not exist; the file is under `global/skill-craft/`. No count, no model. Rewrite:
> Three or more behaviour scenarios in `/home/visiond/projects/claude/skills/global/skill-craft/references/behaviour-evals.md`, each with its RED baseline (a row of Gotchas) and its GREEN run, with the model each ran on. Canon lines in `references/canon.txt`.

Next in line after the 5:
- O:30 "**You know the app.**" states a condition with no check (C1). Step 1's `understand.md` is the check; the stance line can point to it.
- O:44 law 8 holds five rules in one item (default mode, his overrides, build first, no player only on tests, never two on backend) (C13). Split into 8a test mode and 8b casting.
- O:37 "for every request" against O:25 "A pure question ...: answer it (no score)". Law 1 needs "every request that changes code, data, docs or assets" (the words of O:20).
- O:45 "the way he will" (C1); step 9 already names the files, the law can point to them.
- O:124 "The report in the project's shape." (C1, C10): name the skill (orchestration) and its file.

---

## E. Conflicts between the sources and his standing rules

His words win in every case below. Where the conflict is between his own rules, it is named for him to settle.

**E1. Capitals and emphasis.** G p.26 says "Use ## Important or ## Critical headers" and "Repeat key points if needed". MS says capitalized "IMPORTANT" flags can "actively hurt output quality" on newer models. His prompts are often in capitals. Settled by the framework rule "Feedback becomes an instruction, never a quote": his capitals and typos never reach a skill, and our own instruction text adds no IMPORTANT, CRITICAL or MUST (C9).

**E2. Dates.** BP: "Don't include information that will become outdated". Settled: a law's Why is a plain sentence with no date, and a Gotchas Proof is what was measured or observed, with no date (skill-framework.md rows 4 and 8, CLAUDE.md rule 3).

**E3. Freedom.** BP: "**Default assumption:** Claude is already very smart". MS: "If a higher-end model performs worse with the skill than without it, start cutting instructions". He wants the process followed exactly, every time (F:10 "A skill is a process to follow exactly."). That wins: the pipeline steps are low freedom. High freedom applies only to what O:79 to 80 already lists as Free ("how the work is split, which player, which model, the wording of briefs").

**E4. Concise versus complete.** BP "Concise is key" and G p.26 "Keep instructions concise". Settled by turning his feedback into instructions instead of quotes: the instruction is shorter than the quote and says what to do, and his ask is never weakened to save tokens.

**E5. Reserved name.** G p.11 and BP forbid "claude" in a skill name; our skill is `skill-craft`. The sources are about the upload surface (Claude.ai, API); Claude Code loads it: the router prints it on its should rows (`references/trigger-results.md`). Named for his decision; no change made.

**E6. Dashes.** His rule (protocol rule 4): "No em or en dashes, anywhere." H uses them (an em dash in the headings H:158 and H:167, an en dash in the frame ranges at H:15 and H:160, em dashes in BRIEF_TEMPLATE lines 1 and 6) while its own H:24 says "No em/en dashes in any copy we write". G uses " - " as a dash in prose. His rule wins: nothing taken from a source keeps a dash. Where a source quote holds one, quote a shorter part that has none; never alter a quote. This file follows that.

**E7. Where H is not the standard.** H is his chosen standard for wording, but four of its habits break the other two sources and should not be copied: time-bound lines (H:63 "currently returns nothing", H:67 "checked 28/09/2026"; BP "Avoid time-sensitive information"); absolute personal paths (H:9 "`~/Desktop/Howseen AI/howseen-video/`"); no install line next to its scripts (MS); no contents list although 175 lines dense (A4 applies to SKILL.md by spirit, BP sets it for references). Its section numbers (00, 0, 9b, 9c, 9d) also break C7.

**E8. MS is secondary.** MS is a vendor post (it carries ads for its own product) and opens "Anthropic quietly changed how Claude skills should be built." Every MS claim used here was checked against BP, Anthropic's own page. One wording differs: MS says "roughly the first 100 lines"; BP says Claude "might use commands such as `head -100` to preview content". The rule (contents list over 100 lines) is the same.
