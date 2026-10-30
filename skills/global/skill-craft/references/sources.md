# Sources this skill set follows

## Anthropic, The Complete Guide to Building Skills for Claude
https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf
Taken: kebab-case folder equal to `name`, exact `SKILL.md`, no README inside; description = what + when +
trigger phrases, under 1024 characters, no angle brackets; progressive disclosure (frontmatter, body,
references/); critical rules at the top; Troubleshooting as symptom, cause, fix; bundle deterministic
scripts; negative triggers against overtriggering; trigger tests with obvious, paraphrased and should-not
queries aiming at 90%; consider packs past 20 to 50 skills.

## dev.to, ddialar, AI foundations and good practices: creating skills
https://dev.to/ddialar/ai-foundations-and-good-practices-creating-skills-59m3 (shared by him)
Taken: a lean SKILL.md with atomized
references/, scripts/ and examples/ (one example per file); run scripts instead of describing them;
explicit error handling with capped retries; no vague language; one bullet style; a check that every
relative path exists (lint-skills.py); a semantic `version` bumped on change; split skills that cover
unrelated goals. The T-I-P-O body it proposed is replaced by the 14 sections of `references/skill-framework.md`. Considered and not taken: `disable-model-invocation` on deploy (he wants deploy to
trigger reliably; every outward step already needs his yes), `allowed-tools` restrictions (the jobs need
the full toolset).

## skill-creator plugin
The `quick_validate.py` frontmatter check and the description-optimization approach (should and
should-not queries, real `claude -p` runs).

## The three motion skill repos (skill-framework.md is built from them)
- https://github.com/AbubakrChan/product-launch-motion
- https://github.com/charlie947/motion-graphics-skills
- https://github.com/howseen-ai/claude-motion-design
The full list he gave, with the tools, fonts and music, is in `motion-video/references/sources.md`.

## The standard for a good skill (his ask)
- https://github.com/howseen-ai/claude-motion-design/blob/main/skill/motion-design/SKILL.md
- https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf
- https://www.mindstudio.ai/blog/claude-skills-best-practices-update
