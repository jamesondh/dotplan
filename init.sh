#!/usr/bin/env bash
# dotplan init: add an AGENTS.md (map, rules, checks) and a CLAUDE.md that imports it.
# Usage: curl -fsSL https://raw.githubusercontent.com/jamesondh/dotplan/main/init.sh | bash

set -e

TEMPLATE_URL="https://raw.githubusercontent.com/jamesondh/dotplan/main/templates/AGENTS.md"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "dotplan: warning: not inside a git repository. dotplan keeps its memory in git history."
fi

if [ -f AGENTS.md ]; then
  echo "dotplan: AGENTS.md already exists. Add the \"Working here\" section from $TEMPLATE_URL by hand."
else
  if [ -f "$0" ] && [ -f "$(dirname "$0")/templates/AGENTS.md" ]; then   # run from a checkout, not piped
    cp "$(dirname "$0")/templates/AGENTS.md" AGENTS.md
  else
    curl -fsSL "$TEMPLATE_URL" -o AGENTS.md
  fi
  echo "dotplan: created AGENTS.md. Fill in the map, the rules you know, and the checks you run."
fi

if [ -f CLAUDE.md ]; then
  if ! grep -q "@AGENTS.md" CLAUDE.md; then
    echo "dotplan: CLAUDE.md exists and doesn't import AGENTS.md. Consider replacing it with the single line @AGENTS.md"
    echo "         (after moving its contents into AGENTS.md), so the two never drift apart."
  fi
else
  echo "@AGENTS.md" > CLAUDE.md
  echo "dotplan: created CLAUDE.md (imports AGENTS.md for Claude Code)."
fi

if [ -d .planning ]; then
  echo "dotplan: found a v1 .planning/ directory. See \"From v1\" in the README."
fi
