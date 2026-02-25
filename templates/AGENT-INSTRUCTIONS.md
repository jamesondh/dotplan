# Agent Workflow Instructions

Add this to your project instruction file (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, etc.) alongside project context and conventions.

## Project Management

- For non-trivial work, start by reading `.planning/STATE.md` and `.planning/ROADMAP.md`.
- For simple tasks (1-2 files, low risk), implement directly without planning ceremony.
- For medium/high-risk work, write `.planning/phases/NN-{name}/SPEC.md` before coding.
- In each task spec, include `Files`, `Docs to update`, `Verify`, and `Done when`.
- After implementation, run verification. For medium/complex work, if no review was performed, ask: "Would you like me to review this with a subagent?"
- At phase wrap-up, update `STATE.md` with a brief completion summary (key changes, verification, issues, follow-ups), then update `ROADMAP.md`.
- Keep `STATE.md` under 150 lines and commit `.planning/` updates with code changes.
- If `STATE.md` exceeds 150 lines, suggest the user compact it.
