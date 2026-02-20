# Agent Instructions — dotplan

Add the following to your project's agent instruction file
(`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, etc.)
alongside your existing project description, stack, and conventions:

---

## Project Management

This project uses [dotplan](https://github.com/jamesondh/dotplan) for structured development.

### Session Start
For non-trivial tasks, read `.planning/STATE.md` and `.planning/ROADMAP.md` to understand current project state. For simple changes (1-2 files, clear fix), just do it — no ceremony needed.

### Workflow
- Assess task complexity first:
  - **Simple** (1-2 files, no risk): just do it, no spec or `.planning/` updates needed
  - **Medium** (3-5 files, single phase): write a spec, implement, review. Update STATE.md but skip SUMMARY and STATE-archive
  - **Complex** (multi-phase, architectural decisions, high-risk): full workflow — spec each phase, review the spec, implement, review the implementation, SUMMARY, compact STATE → archive, full wrap-up checklist
- For Medium and Complex: write a phase spec in `.planning/phases/NN-{name}/SPEC.md` before implementing
- Every task spec includes a "Docs to update" field — treat doc updates as part of the task, not optional
- After implementation, review changes (ideally with a different model/perspective than what implemented)

### State Management
- Update `.planning/STATE.md` as work progresses
- Keep STATE.md under 150 lines — it's active context, not a history log
- At phase wrap-up: move completed content to STATE-archive.md, update ROADMAP.md, write SUMMARY.md
- Commit `.planning/` changes to git

### Phase Wrap-up Checklist
- [ ] Push all commits
- [ ] Write phase SUMMARY.md
- [ ] Compact STATE.md (move completed → STATE-archive.md)
- [ ] Update ROADMAP.md
- [ ] Doc check — were all "Docs to update" items addressed?
- [ ] Commit .planning/ changes
