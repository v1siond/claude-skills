# Where each project keeps its frameworks

Open this when `scripts/find-frameworks.sh` finds nothing obvious, or to know the standing doc for a kind of
work. The script is the live check, this table is the map; where they differ, the script wins and you fix the row.
Project rows live in the project skills or the private overlay (`skills/specific/<project>/facts/orchestration-framework-indexes.md`); this file keeps the rows every repo shares.


| Project | Where the index or governing doc is |
|---|---|
| Any PR or MR review | `$CLAUDE_WORKSPACE/_global/PR-REVIEW-FRAMEWORK.md`; skill `review` carries it |
| Every other repo | repo `docs/`, README. None found: write one (SKILL.md, Pipeline row D4) |
