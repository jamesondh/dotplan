#!/usr/bin/env bash
# dotplan init — scaffold .planning/ in your project
# Usage: curl -fsSL https://raw.githubusercontent.com/jamesondh/dotplan/main/init.sh | bash

set -e

if [ -d ".planning" ]; then
  echo "dotplan: .planning/ already exists. Nothing to do."
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "dotplan: warning — not inside a git repository. Proceeding anyway."
fi

echo "dotplan: creating .planning/ structure..."

mkdir -p .planning/phases
mkdir -p .planning/_deferred
mkdir -p .planning/templates
touch .planning/phases/.gitkeep
touch .planning/_deferred/.gitkeep

# SPEC.md template
cat > .planning/templates/SPEC.md << 'TEMPLATE'
# Phase N: {Name}

## Goal
<!-- What this phase accomplishes and WHY — the design decision, not just the task -->

## Risk
<!-- Low / Medium / High. Note migrations, auth changes, external APIs, infra. "Low" if straightforward. -->
<!-- Why this phase needs a spec: {what makes it irreversible — schema migration, auth architecture, external API contract, etc.} -->

## Surface Area
<!-- Which parts of the codebase this phase touches. Coordination metadata for multi-human/multi-agent work. -->
<!-- Primarily: src/api/appeals/ -->
<!-- Touches: src/shared/types.ts, src/db/schema.ts -->

## Tasks

### Task 1: {Description}
**Files:** <!-- src/foo.ts (new), src/bar.ts (modify) -->
**Docs to update:** <!-- README.md, CHANGELOG.md, etc. "None" if genuinely nothing. -->
**Steps:**
- <!-- Step-by-step implementation notes -->
**Verify:** <!-- Command to verify: npm test, go test ./..., etc. -->
**Done when:** <!-- Concrete completion condition -->

### Task 2: {Description}
**Files:**
**Docs to update:**
**Steps:**
-
**Verify:**
**Done when:**

---

## Postmortem
<!-- Filled in AFTER implementation. The delta between plan and reality. -->
<!-- This section turns the spec from a planning artifact into an audit artifact. -->

### Deviations
<!-- - Deviated from spec on X because Y -->
<!-- - Added Z which wasn't in the original spec -->
<!-- - Tasks 3 and 4 ended up being one task -->

### Actual Surface Area
<!-- Auto-generated or manually noted — what files actually changed vs. what was planned -->

### Lessons
<!-- Anything worth carrying forward to future phases -->
TEMPLATE

# ROADMAP.md
cat > .planning/ROADMAP.md << 'TEMPLATE'
# Roadmap

## In Progress
- [ ] **Phase 1: Initial setup**

## Planned
<!-- Add planned phases here -->

## Deferred
<!-- Parked ideas: Phase N: description (see `_deferred/name.md`) -->
TEMPLATE

# STATE.md
cat > .planning/STATE.md << 'TEMPLATE'
# State

<!-- Active working context. Keep under 150 lines. -->
<!-- Keep only current work, blockers, and a brief recent-completed summary. -->

## Current Phase
Phase 1: Initial setup — not started

## Blockers
None

## Next Steps
- Add planning workflow instructions to agent instruction file (CLAUDE.md, AGENTS.md, .cursorrules, etc.)
- Plan initial phases in ROADMAP.md
- Write first phase spec in phases/01-{name}/SPEC.md
TEMPLATE

# .gitattributes
if [ -f ".gitattributes" ]; then
  if ! grep -Fq '.planning/** linguist-generated' .gitattributes 2>/dev/null; then
    echo "" >> .gitattributes
    echo "# dotplan: hide planning files from PR diffs and language stats" >> .gitattributes
    echo ".planning/** linguist-generated" >> .gitattributes
    echo "dotplan: appended to existing .gitattributes"
  fi
else
  cat > .gitattributes << 'TEMPLATE'
# dotplan: hide planning files from PR diffs and language stats
.planning/** linguist-generated
TEMPLATE
  echo "dotplan: created .gitattributes"
fi

echo ""
echo "dotplan: initialized .planning/ with:"
echo "  ROADMAP.md        — ordered phases with status"
echo "  STATE.md          — active context (start here each session)"
echo "  phases/           — per-phase specs"
echo "  templates/SPEC.md — spec template (copy when creating new phases)"
echo "  _deferred/        — parked ideas"
echo ""
echo "Next:"
echo "  1. Add planning workflow instructions to your agent file (CLAUDE.md, AGENTS.md, .cursorrules, etc.)"
echo "     See: https://github.com/jamesondh/dotplan/blob/main/templates/AGENT-INSTRUCTIONS.md"
echo "  2. Plan your first phase in ROADMAP.md"
