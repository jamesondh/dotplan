---
name: dotplan
description: Use this skill when working in a repository that follows dotplan (an AGENTS.md with a map, rules and checks by path) or when setting one up. dotplan v2 keeps project memory in three places — AGENTS.md for invariants and the checks that enforce them, commit messages for the reasoning behind changes, and docs/<topic>/ for hard-to-reverse or multi-session work. Activate when starting non-trivial work in an unfamiliar repo, when writing commit messages, when a bug slipped through unnoticed, or when the user mentions dotplan, AGENTS.md rules, or migrating from `.planning/`.
---

# dotplan v2

Project memory without a planning directory. Three places, each where the next agent will look:

1. **`AGENTS.md`**: a map of the repo (20-40 lines), rules that are easy to break without noticing (each with its
   reason and a check), and a table of which checks to run for which paths. `CLAUDE.md` is a stub: `@AGENTS.md`.
2. **Commit messages**: the subject names what changed and the trap, in searchable words; the body says what was
   wrong, what was done and ruled out, what was run (with numbers) and what wasn't tested.
3. **`docs/<topic>/`**: only for work that's hard to reverse, spans sessions, or needs measured targets. Today,
   design (with the rules every step keeps), passes with acceptance numbers, and a status table.

There is no STATE.md or ROADMAP.md. State comes from git; open work lives wherever the project keeps it.

## Before non-trivial work

1. Read the README and `AGENTS.md`.
2. `git status`, `git log -n 20`.
3. When the change repeats something done before (another endpoint, another map), reverses an earlier decision,
   or touches code whose purpose isn't clear, look at its history: `git log -- <path>`, `git log -S<symbol>`,
   `git log --grep=<word>`, `git blame`. Open (`git show`) the commit that did the same thing last time; it's the
   template, and its body lists what it had to change together.
4. Skip the archaeology for typos, mechanical renames and new, self-contained files.
5. If the change is hard to reverse, long, or needs measuring, read or start `docs/<topic>/` first.

## While working

- Run the checks in `AGENTS.md` for every path you touched; they're the minimum. After a merge, rebase or
  conflict resolution, run them again.
- Keep every fixed bug's reproduction as a test, script or fixture.
- Hard-to-reverse work: have a fresh session review it, from a different model family when one at least as capable
  is available.

## Committing

```
<Area>: <what changed> (<the trap or symptom, if any>)

<What was wrong, and how it showed.> <What you did.> Ruled out: <alternative, and why>.

Ran: <commands, with numbers>. Not tested: <what, and why it matters>.
```

Skip the body only when the diff explains itself. No trailers are required.

## When something broke that nobody noticed

In the same commit as the fix: add the rule to `AGENTS.md` under Rules, with its reason, and add a check (a test or
a script under `tools/` or `scripts/`) if one can be written. Add the check to the table for the paths it covers.

## Setting up a repo

Copy `templates/AGENTS.md` to the repo root (or run `init.sh`), write `CLAUDE.md` as `@AGENTS.md`, then fill in
the map, the rules already known, and the checks already run. Keep the fixed part short; the rules take the room
they need. Prefer the root file for rules: as of October 2026, nested `AGENTS.md` files load only in some harnesses
and modes (Claude Code in bypass-permissions mode never loaded them in testing).

## Migrating from v1 (`.planning/`)

Cut history and status, never rules. Do it in one commit, after checking that nothing (including scripts in other
repos) reads `.planning/` automatically.

1. Promote every rule from `STATE.md`, the phase specs and their postmortems, and the old instruction file into
   `AGENTS.md`: a line or two each, grouped by subsystem, with its reason and a check. Verify every path, command
   and number against the code; old instruction files are often stale.
2. Mine session logs or notes for corrections that never reached the repo ("no, that's wrong", "you forgot",
   reverts). Those are rules too.
3. Move in-progress design work on hard-to-reverse subsystems into `docs/<topic>/`. Move reference material that
   isn't a rule (setup, tool usage, build variants) into the README.
4. Leave finished phase specs in `.planning/phases/` as a frozen archive (code comments cite them), with a one-line
   `.planning/README.md` that says so.
5. Delete `STATE.md`, `ROADMAP.md`, `_deferred/` and `.planning/templates/`, and fix anything that points at them.
   Open work goes wherever the project keeps it.
6. Replace the old instruction file with `AGENTS.md` plus a `CLAUDE.md` of `@AGENTS.md`. Remove any `AGENT.md`
   (singular): some harnesses load it alongside `AGENTS.md`.
