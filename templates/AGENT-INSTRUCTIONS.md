# Agent Workflow Instructions

Add this to your project instruction file (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, etc.) alongside project context and conventions.

## Project Management

- For non-trivial work, start by reading `.planning/STATE.md` and `.planning/ROADMAP.md`.
- Assess **reversibility** before starting: can this be reverted with git, or would it need a migration?
  - **Low reversibility** (schema changes, auth, external APIs, data models): write a SPEC before coding. Copy `.planning/templates/SPEC.md` to `.planning/phases/NN-{name}/SPEC.md`.
  - **High reversibility** (UI, config, refactors, dependency swaps): just do it — no spec needed. Commit history and STATE.md carry the record.
- Follow the template structure — every SPEC task must include `Files`, `Docs to update`, `Verify`, and `Done when`.
- After implementation, run verification. For low-reversibility work, review with a different model/session.
- At phase wrap-up: fill in the SPEC's `Postmortem` section, update `STATE.md` with a brief completion summary, then update `ROADMAP.md`.
- Keep `STATE.md` under 150 lines and commit `.planning/` updates with code changes.
- If `STATE.md` exceeds 150 lines, suggest the user compact it.
