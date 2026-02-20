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
touch .planning/phases/.gitkeep
touch .planning/_deferred/.gitkeep

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
<!-- Move completed phases to STATE-archive.md at wrap-up. -->

## Current Phase
Phase 1: Initial setup — not started

## Blockers
None

## Next Steps
- Add dotplan instructions to agent instruction file (CLAUDE.md, .cursorrules, etc.)
- Plan initial phases in ROADMAP.md
- Write first phase spec in phases/01-{name}/SPEC.md
TEMPLATE

# STATE-archive.md
cat > .planning/STATE-archive.md << 'TEMPLATE'
# State Archive

<!-- Append-only. Completed phase summaries go here during phase wrap-up. -->
<!-- Read on demand, not every session. -->
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
echo "  STATE-archive.md  — completed phase history"
echo "  phases/           — per-phase specs and summaries"
echo "  _deferred/        — parked ideas"
echo ""
echo "Next:"
echo "  1. Add dotplan instructions to your agent file (CLAUDE.md, .cursorrules, etc.)"
echo "     See: https://github.com/jamesondh/dotplan/blob/main/templates/AGENT-INSTRUCTIONS.md"
echo "  2. Plan your first phase in ROADMAP.md"
