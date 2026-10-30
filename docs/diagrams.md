# Diagrams

How the skills hand work to each other, and the layouts a ticket takes through orchestration. Every diagram is
Mermaid; GitHub and most Markdown viewers render it. Step numbers are the orchestration Pipeline steps
([`skills/global/orchestration/SKILL.md`](../skills/global/orchestration/SKILL.md), lines 101 to 117).

## Contents

Skill interaction examples:
1. [A bug ticket](#1-a-bug-ticket)
2. [A UI feature](#2-a-ui-feature)
3. [A game feature with a project expert](#3-a-game-feature-with-a-project-expert)
4. [A skill correction](#4-a-skill-correction)
5. [A blog post](#5-a-blog-post)
6. [A release](#6-a-release)

Harness layouts:
7. [Director with parallel builder lanes on one checkout](#7-director-with-parallel-builder-lanes-on-one-checkout)
8. [Sequential fix waves: the C38 example](#8-sequential-fix-waves-the-c38-example)
9. [The spec stage: four goldfish and his STOP](#9-the-spec-stage-four-goldfish-and-his-stop)
10. [The hook flow of one prompt](#10-the-hook-flow-of-one-prompt)

## 1. A bug ticket

```mermaid
flowchart LR
    U["He reports a bug"] --> SS["session-start<br/>first message only"]
    SS --> O0["orchestration 0 to 1<br/>log his words, understand.md"]
    O0 --> O3["3 to 5<br/>size: small, no spec<br/>brief, critic-brief"]
    O3 --> B["builder runs bug-investigation<br/>reproduce, measure, root cause file:line"]
    B --> T["testing-standard<br/>the bug is the scenario<br/>when the mode wants a test"]
    T --> E["engineering-standards<br/>check-diff.sh, gates"]
    E --> C7["7 control.md"]
    C7 --> Q["9 QA player<br/>testing-standard + bug-investigation<br/>before and after shots"]
    Q --> C10["10 critic-result"]
    C10 --> S["ship<br/>commit by path, push waits for his yes"]
```

A bug sized small at step 3 has no spec of its own, so it skips the goldfish; its brief still goes through the
step 5 critic (`references/critic.md` Goldfish, Size). The builder runs bug-investigation inside step 6, and QA
runs it again on anything it finds at step 9 (bug-investigation lines 15 to 16).

## 2. A UI feature

```mermaid
flowchart TD
    W["His ask: a new screen"] --> S2["orchestration 2<br/>writing: spec with a mockup per screen"]
    S2 --> P["ui design-proposals<br/>3 or more rendered pages, serve-proposals.sh"]
    P --> PICK{"He picks one"}
    PICK --> PL["engineering-standards<br/>plan.md, frontend.md"]
    PL --> G["goldfish lenses, then his STOP"]
    G --> F["frontend player<br/>ui-craft.md, port the pick<br/>engineering-standards, Tailwind first"]
    F --> C7["7 control"]
    C7 --> Q9["9 QA in the browser<br/>ui-design-review + wcag-aaa-audit"]
    Q9 --> R["reviewer: review, code lens"]
    R --> C10["10 critic: his words, controls,<br/>1920x1080, contrast"]
```

The ui skill serves three different steps: options at step 2, the build after step 6, and the reviews at step 9
(ui Pipeline, lines 71 to 78). In the default test mode the frontend gets 0 tests; the browser QA is the proof
(testing-standard law 3, orchestration law 9).

## 3. A game feature with a project expert

```mermaid
flowchart TD
    A["His ask in the game repo"] --> R["router: project expert skill always listed<br/>project concept designer on design words"]
    R --> CD["project concept designer<br/>board.md, story.md, layout and look sheets"]
    CD -- "every 'the app cannot' line" --> NE["project expert skill<br/>file:line, reuse, where it lands"]
    NE --> SPEC["orchestration 2: spec and plan.md"]
    SPEC --> GF["goldfish: comprehension, critic,<br/>codebase with the expert rubric,<br/>readiness, concept with the designer rubric"]
    GF --> STOP{"His yes"}
    STOP --> BUILD["builders: engineering-standards<br/>+ project expert skill"]
    STOP --> PLAY["designer's player builds the game<br/>in the app: generate, then edit by hand"]
    PLAY -- "code gap" --> BUILD
    BUILD --> C7["7 control + expert coverage.sh 0 missing"]
    C7 --> Q9["9 QA: play it in the browser"]
    Q9 --> G10["10 critic + goldfish codebase and concept"]
```

Every ticket in a repo with an expert skill loads it; any ticket a player sees or plays also gets the concept
designer (orchestration skill map). Both skills sit in the private overlay, `skills/specific/<project>/`. A gap the designer's player hits goes to an expert player as a row,
then the designer's player walks the game again (concept designer law 2).

## 4. A skill correction

```mermaid
flowchart LR
    C["He corrects how a job was done"] --> SC["skill-craft<br/>find the owning skill"]
    SC --> P["his feedback turned into steps"]
    P --> EV["evals first: 2 should rows,<br/>1 near miss row"]
    EV --> G{"grep: does a step<br/>already say it?"}
    G -- "yes" --> RUN["run that step; no new rule"]
    G -- "no" --> L["one line in the skipped step<br/>bump metadata.version"]
    L --> CHK["lint-skills.py, check-text.sh,<br/>router, trigger-test.py 90%"]
    CHK --> CAT["catalog.py regenerates SKILLS.md"]
    CAT --> CR["orchestration critic: W1 to W19<br/>+ Howseen model"]
```

A correction never becomes a memory file, a hook or a CLAUDE.md line (CLAUDE.md rule 3). The skill-craft steps
are 2 to 11 of its Pipeline (lines 79 to 93); the critic axes for a skill are in
`orchestration/references/critic.md` lines 27 to 40.

## 5. A blog post

```mermaid
flowchart TD
    ROW["A row of the post list"] --> RS["research<br/>topic facts, sources"]
    ROW --> BL["blog, assets player<br/>evidence.md, post.json"]
    RS --> BL
    BL --> OC["critic: outline"]
    OC --> DR["draft in his voice<br/>writing laws"]
    DR --> DC["critic: draft"]
    DC --> M["media: code-extract.py, media.mjs,<br/>web.sh, media-check.py"]
    M -- "a beat needs a film" --> MV["motion-video<br/>live take, stills, draft, master"]
    MV --> F
    M --> F["critic: final, post-check.py"]
    F --> REP["orchestration 12: the folder<br/>for him; nothing published"]
```

The blog skill runs inside step 6 with three critic passes of its own and the orchestration critic at step 10
(blog Pipeline). Topic picking is research's; a film in a beat is motion-video's; the voice is writing's
(skill map row "blog post").

## 6. A release

```mermaid
flowchart LR
    D["Batch done, his verdict"] --> PD["ship: pre-deploy.sh<br/>every gate on a clean tree"]
    PD --> ST["stamp ~/.claude/push-gate/repo@sha"]
    ST --> Y{"His yes to push"}
    Y --> PUSH["git push: push-gate.sh<br/>checks the stamp"]
    PUSH --> STG["staging"]
    STG --> Y2{"His word for production"}
    Y2 --> REL["release-preflight.sh, bump,<br/>tag, publish"]
    REL -. "infra repos" .-> IG["infra-gitops: render, diff,<br/>sync on his yes, read back"]
```

Two separate yeses: the push, and production after staging (ship laws 1 and 3). The push gate hook only proves
the gates ran on that exact commit; it never stands in for his yes.

## 7. Director with parallel builder lanes on one checkout

```mermaid
flowchart TD
    DIR["Director<br/>ORCHESTRA.md, briefs, control"] --> LOAD["agent-load.sh<br/>agents now: n"]
    LOAD --> L1["Lane A: backend<br/>owns lib/... paths"]
    LOAD --> L2["Lane B: frontend<br/>owns assets/... paths"]
    LOAD --> L3["Lane C: assets<br/>owns its own files"]
    subgraph CO["One main checkout, one test database"]
        L1
        L2
        L3
    end
    L1 -- "report, commit own paths" --> C7["Director: control.md per lane"]
    L2 --> C7
    L3 --> C7
    C7 --> INT["8 integrate.md<br/>one command per seam"]
    INT --> QA["QA player: 9 in the browser<br/>on his dev server"]
    QA --> CRIT["Critic: 10 critic-result.md"]
    CRIT -- "axis 7 or less, FAIL rows" --> DIR
    C7 -. "TaskStop each id" .-> DIR
```

Two or more builders work separate tickets in the same checkout at once, each owning disjoint files; only the
same file or the same check run waits, and `git worktree list` prints 1 line (orchestration law 15,
`references/agent-dispatch.md` laws 1 to 4). QA, reviewer and critic are always other players (law 10).

## 8. Sequential fix waves: the C38 example

The real ticket folder is `$CLAUDE_WORKSPACE/<project>/score/C38/`: a wardrobe and a lens for a game's worlds.

```mermaid
flowchart TD
    B["brief.md + critic-brief-build.md"] --> LB["lane B wardrobe<br/>brief-build-b.md"]
    B --> LC["lane C lens<br/>brief-build-c.md"]
    LB --> CB["control-lane-b.md PASS<br/>commit 74967654"]
    LC --> CC["control-lane-c.md PASS<br/>commit 0764000e"]
    CB --> I["integrate.md<br/>3 of 3 seams PASS"]
    CC --> I
    I --> QB["brief-qa.md<br/>critic r1, r2 reject, r3 ship"]
    QB --> Q1["QA round 1: qa/ shots, qa.md"]
    Q1 --> FB["fix wave B, C<br/>brief-fix-b, brief-fix-c<br/>critic-brief-fix r1 to r4"]
    FB --> CFB["control-fix-b, control-fix-c<br/>commit by path"]
    CFB --> Q2["fix C2 and QA round 2<br/>brief-qa-r2, its critic r1 to r3"]
    Q2 --> FD["fix wave D<br/>control-fix-d"]
    FD --> Q3["QA round 3, brief-qa-r3"]
    Q3 --> CR["critic-result-r2 on the result<br/>axes at 6 and 7: back to step 4"]
    CR --> FE["fix wave E1, E2 in parallel<br/>control-fix-e1: 34 rows, PASS"]
    FE --> Q4["QA round 4, brief-qa-r4"]
    Q4 --> FF["fix wave F, control-fix-f<br/>then F2, recapture the world previews"]
    FF --> Q5["QA round 5, next"]
    Q5 --> BC{"built-check.sh<br/>prints BUILT?"}
    BC -- "no" --> FF
```

Each wave is the same loop: a fix brief, its critic rounds until every axis is 8 or more, dispatch, a
`control-fix-<lane>.md` with one verdict per requirement and the gates, a commit by path, then a fresh QA round
with its own critic-checked brief. Evidence for each control sits in `fix-check/<lane>/`. The row turns BUILT
only when `built-check.sh` passes on the final `qa/` folder (orchestration step 11 and the BUILT check).

## 9. The spec stage: four goldfish and his STOP

```mermaid
flowchart TD
    U["understand.md"] --> S["Director writes the spec<br/>(writing) and plan.md<br/>(engineering-standards)"]
    S --> SEND["One message, all lenses"]
    SEND --> G1["goldfish-comprehension<br/>the spec only"]
    SEND --> G2["goldfish-critic<br/>spec, plan, his words"]
    SEND --> G3["goldfish-codebase<br/>plan, repo, expert rubric"]
    SEND --> G4["goldfish-readiness<br/>plan only"]
    G1 --> M["goldfish.md<br/>findings merged, file:line"]
    G2 --> M
    G3 --> M
    G4 --> M
    M --> R{"Each row:<br/>FIX, CONTEST,<br/>ESCALATE, DECLINE"}
    R -- "FIX" --> S
    R -- "0 Blocker or Major open" --> STOP{"STOP: his yes<br/>on spec and plan"}
    R -- "ESCALATE" --> STOP
    STOP --> NEXT["Step 3: size and cast"]
```

The director is the elephant who holds the context; each goldfish is a fresh read-only agent that knows only
the files in its brief (`references/critic.md` Goldfish, lines 50 to 75). Comprehension never gets his words,
which is the test; concept runs only for a game ticket a player sees or plays. Rows already in his approved
order do not wait at the STOP (orchestration Pipeline).

## 10. The hook flow of one prompt

```mermaid
sequenceDiagram
    participant He as He types a prompt
    participant CC as Claude Code
    participant P as protocol.txt
    participant R as skill-router.py
    participant M as Model
    participant G as usage-guard.sh
    participant PG as push-gate.sh
    participant S as stop-report-format.sh
    He->>CC: prompt
    CC->>P: UserPromptSubmit: cat
    P-->>M: the rules, every prompt
    CC->>R: UserPromptSubmit
    R-->>M: SKILL CHECK: line
    loop each tool call
        M->>G: PreToolUse
        G-->>M: allow, warn, or HARD STOP
        M->>PG: PreToolUse, Bash only
        PG-->>M: block a git push with no stamp
    end
    M->>S: Stop
    S-->>M: exit 2 if the report is out of shape
    Note over CC,M: After a compaction, SessionStart compact runs post-compact.py:<br/>protocol, orchestration SKILL.md, the Score, the handoff tail
```

The protocol arrives twice per session start (SessionStart and the first UserPromptSubmit) and then on every
prompt, so it is always in recent context. The guards run on every tool call, the subagents' included; the Stop
check runs only when the repo has changed files ([`harness.md`](harness.md)).
