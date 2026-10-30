# Why the test modes look this way (from dev-flow)

He asked for research on senior development skills before writing one global flow skill, and to keep his
own workflow if it is better.

## What was compared

| Source | What it does | Taken |
|---|---|---|
| superpowers test-driven-development | Red, green, refactor for every change; "no production code without a failing test first", frontend included | Watch each test fail; smallest code to pass. Not taken: test first for every frontend change. |
| Published "tdd-workflow" skills (skills.sh, claudemarketplaces, addyosmani agent-skills) | Tests first for features, fixes, endpoints and components alike | Nothing new; none covers manual frontend QA. |
| alexop.dev multi-agent TDD | Separate agents for test, implementation and refactor so the test writer's analysis does not bleed into the code | Noted; not needed while the scenarios come from him. |
| Kent Beck, augmented coding | A plan of tests ticked one at a time; agents caught deleting failing tests to go green; structural apart from behavioural changes | The scenario list as the plan; never weaken or delete a failing test; refactor apart. |

## Why his flow wins here

- None of the published skills handles a frontend whose correctness is judged by using it, which is most of his work (a canvas editor, Vue and React screens).
- His measured cost: browser tests written test-first ran 13 to 15 minutes a file and checked scenarios he never set, while the backend tests caught the real logic faults.
- Backend TDD keeps the guarantee where the business rules live; manual QA, then optional frontend tests, keeps the UI honest without paying for tests of a UI that does not exist yet.

## Sources

- https://signals.aktagon.com/articles/2025/09/augmented-coding-beyond-the-vibes/
- https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/
- https://claudemarketplaces.com/skills/addyosmani/agent-skills/test-driven-development
- https://www.skills.sh/aaaaqwq/claude-code-skills/tdd-workflow
- superpowers 7.0.0 skills/test-driven-development/SKILL.md (local plugin cache)
