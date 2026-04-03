---
name: dotplan
description: Use this skill for any non-trivial coding project that spans multiple sessions or phases. dotplan provides structured project memory via a `.planning/` directory convention — spec before code, compact state between sessions, separate implementation from review. Activate when starting a new multi-phase project, continuing work across sessions, or when the user mentions dotplan, `.planning/`, STATE.md, or ROADMAP.md.
---

# dotplan — Project Memory for AI Agents

dotplan is a `.planning/` directory convention and workflow for maintaining continuity across agent sessions. It's git-native, agent-agnostic, and zero-install — just markdown files that travel with the repo.

The core problem: AI agents are stateless. Every new session starts from zero. dotplan solves this with structured state files and workflow conventions.

## Setup

If a project doesn't have a `.planning/` directory yet and needs one (non-trivial, multi-phase work), create it:

```
.planning/
  ROADMAP.md          # ordered phases with status
  STATE.md            # active context — what's happening now
  phases/             # per-phase specs
  templates/SPEC.md   # spec template — copy when creating new phases
  _deferred/          # parked ideas not on the roadmap yet
```

Create `.planning/ROADMAP.md`:

```markdown
# Roadmap

## In Progress
- [ ] **Phase 1: {Name}**

## Planned
- [ ] Phase 2: {Name}

## Deferred
```

Create `.planning/STATE.md`:

```markdown
# Project State

## Active Work
{What's currently in progress}

## Blockers
None

## Next Steps
{What comes after current work}
```

Add to `.gitattributes` (create if needed):

```
.planning/** linguist-generated
```

Then add workflow instructions to the project's agent instruction file (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, etc.) — see the Workflow Instructions section below.

## Workflow Instructions

Add this to the project's agent instruction file alongside existing project context:

### Project Management

- For non-trivial work, start by reading `.planning/STATE.md` and `.planning/ROADMAP.md`.
- For small, low-risk, easily reversible tasks, implement directly without planning ceremony.
- Assess **reversibility** before starting: can this be reverted with git, or would it need a migration?
  - **Low reversibility** (schema changes, auth, external APIs, data models): write a SPEC before coding. Copy `.planning/templates/SPEC.md` to `.planning/phases/NN-{name}/SPEC.md`.
  - **High reversibility** (UI, config, refactors, dependency swaps): just do it — no spec needed. Commit history and STATE.md carry the record.
- Follow the template structure — every SPEC task must include `Files`, `Docs to update`, `Verify`, and `Done when`.
- After implementation, run verification. For low-reversibility work, review with a different model/session.
- At phase wrap-up: fill in the SPEC's `Postmortem` section, update `STATE.md` with a brief completion summary, then update `ROADMAP.md`.
- Keep `STATE.md` under 150 lines and commit `.planning/` updates with code changes.
- If `STATE.md` exceeds 150 lines, suggest compacting it.

## Assessment: Scope and Reversibility

Assess two axes before starting. Not every task needs the full workflow.

**Reversibility** is the deciding factor for ceremony. Low reversibility = creates state that's expensive to migrate away from (schema changes, auth architecture, external API contracts). High reversibility = can revert cleanly (`git revert` is a viable escape hatch).

| | Low reversibility | High reversibility |
|---|---|---|
| **Small scope** (1-2 files) | **Spec required** despite small size | **Just do it** — no planning needed |
| **Large scope** (3+ files, multi-phase) | **Full spec + review** | **Just do it** — commit history + STATE.md carry the record |

When in doubt: "If this turns out wrong, can I revert it with git, or do I need a migration?"

## Phase Spec Template

Write to `.planning/phases/NN-{name}/SPEC.md` before implementing low-reversibility work:

```markdown
# Phase N: {Name}

## Goal
{What this phase accomplishes and WHY — the design decision, not just the task}

## Risk
{Low / Medium / High. Note migrations, auth changes, external APIs, infra.}

## Surface Area
{Which parts of the codebase this phase touches — coordination metadata}
Primarily: src/api/foo/
Touches: src/shared/types.ts

## Tasks

### Task 1: {Description}
**Files:** src/foo.ts (new), src/bar.ts (modify)
**Docs to update:** README.md, CHANGELOG.md — or "None"
**Steps:**
- Step-by-step implementation notes
**Verify:** npm test, go test ./..., etc.
**Done when:** {Concrete completion condition}

---

## Postmortem
### Deviations
- {Filled in after implementation — what diverged from the plan and why}
### Actual Surface Area
- {What files actually changed vs. what was planned}
### Lessons
- {Anything worth carrying forward}
```

The **"Docs to update"** field is intentional — documentation is part of the task, not an afterthought.

The **Surface Area** section helps multiple humans/agents working in parallel spot potential conflicts before they become merge nightmares.

The **Postmortem** section is filled in at phase wrap-up. It turns the spec from a planning artifact into a decision record — what you intended vs. what actually happened.

## The Workflow Loop

**Per phase (low reversibility):**
1. **Spec** — Copy `templates/SPEC.md` to `phases/NN-{name}/SPEC.md` and fill it in.
2. **Implement** — Work through tasks. Update STATE.md as you go.
3. **Review** — Review with a different model or session than implementation. The implementer is blind to their own choices.
4. **Wrap up** — Follow the checklist below.

**Per phase (high reversibility):**
1. **Implement** — Do the work. No upfront spec needed.
2. **Review** — Still recommended for large scope, optional for small.
3. **Wrap up** — Update STATE.md and ROADMAP.md as usual.

### Phase Wrap-up Checklist

- Push all commits
- Fill in the **Postmortem** section in the phase's SPEC.md (deviations, actual surface area, lessons)
- Update `STATE.md` with brief completion summary (key changes, verification, issues, follow-ups)
- Compact STATE.md — keep only active context + brief recent-completed summary
- Update `ROADMAP.md` — mark phase complete, confirm next
- Doc check — did all docs listed in task specs get updated?
- Commit `.planning/` changes
- Review upcoming phases — revise if this phase revealed new complexity

## STATE.md Rules

STATE.md is the bridge between sessions. Keep it focused.

**Keep under 150 lines.** This is a hard constraint.

**Include:**
- Current phase and task-level status
- Last completed phase (brief summary, 5-10 lines)
- Active decisions that affect upcoming work
- Blockers
- Key metrics (test count, build status, whatever matters)

**Exclude:**
- Full history of every past phase
- Verbose logs
- Design rationale that doesn't affect current work (that belongs in the agent instruction file)

## Session Recovery

When picking up a project cold:
1. Read the agent instruction file for stable project context (what, why, stack, conventions)
2. Read `ROADMAP.md` for the big picture
3. Read `STATE.md` for active context
4. If more history is needed, read prior phase `SPEC.md` files

## Key Principles

- **Spec before code for irreversible decisions** — catches issues early, creates a record of intent vs. result. High-reversibility work doesn't need a spec.
- **Separate implementation and review** — use different models or sessions; this is the highest-ROI practice
- **State has a size budget** — 150 lines max prevents unbounded context growth
- **Documentation is part of the task** — specs list which docs to update; the agent treats this as required
- **Deferred work has a home** — `_deferred/` prevents scope creep while preserving good ideas
- **Convention over tooling** — no CLI, no install, just markdown files any agent can read
