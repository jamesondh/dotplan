# Agent Workflow Instructions

Add this to your project instruction file (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, etc.) alongside project context and conventions.

## Project Management

- For non-trivial work, start by reading `.planning/STATE.md` and `.planning/ROADMAP.md`.
- For simple tasks (1-2 files, low risk), implement directly without planning ceremony.
- For medium/high-risk work, copy `.planning/templates/SPEC.md` to `.planning/phases/NN-{name}/SPEC.md` and fill it in before coding. Include a `Surface Area` section listing which parts of the codebase the phase touches.
- Follow the template structure — every task must include `Files`, `Docs to update`, `Verify`, and `Done when`.
- After implementation, run verification. For medium/complex work, if no review was performed, ask: "Would you like me to review this with a subagent?"
- At phase wrap-up: fill in the spec's `Postmortem` section (deviations from plan, actual surface area, lessons), update `STATE.md` with a brief completion summary, then update `ROADMAP.md`.
- Keep `STATE.md` under 150 lines and commit `.planning/` updates with code changes.
- If `STATE.md` exceeds 150 lines, suggest the user compact it.
