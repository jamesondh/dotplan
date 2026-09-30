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

There is no STATE.md or ROADMAP.md. State comes from git; open work lives in the tracker or a root `TODO.md`.

## Before non-trivial work

1. Read the README and `AGENTS.md`.
2. `git status`, `git log -n 20`.
3. For each file you'll touch: `git log -- <path>`. Open (`git show`) any commit that did something similar before;
   it's the template, and its body lists what it had to change together.
4. Search history for the concepts involved: `git log -S<symbol>`, `git log --grep=<word>`.
5. If the change is hard to reverse, long, or needs measuring, read or start `docs/<topic>/` first.

## While working

- Run the checks in `AGENTS.md` for every path you touched. After a merge, rebase or conflict resolution, run them
  again.
- Keep every fixed bug's reproduction as a test, script or fixture.
- Hard-to-reverse work: ask for review from a model of a different lineage (a different lab's model is best, a fresh
  session of the same model the minimum).

## Committing

```
<Area>: <what changed> (<the trap or symptom, if any>)

<What was wrong, and how it showed.> <What you did.> Ruled out: <alternative, and why>.

Ran: <commands, with numbers>. Not tested: <what, and why it matters>.
```

Skip the body only when the diff explains itself. No trailers are required; `Assisted-by: <agent>:<model>` is
fine for provenance.

## When something broke that nobody noticed

In the same commit as the fix: add the rule to `AGENTS.md` under Rules, with its reason, and add a check (a test or
a script under `tools/` or `scripts/`) if one can be written. Add the check to the table for the paths it covers.

## Setting up a repo

Copy `templates/AGENTS.md` to the repo root (or run `init.sh`), write `CLAUDE.md` as `@AGENTS.md`, then fill in
the map, the rules already known, and the checks already run. Keep the fixed part short; the rules take the room they need.

## Migrating from v1 (`.planning/`)

Cut history and status, never rules. Promote every rule from `STATE.md`, phase specs and the old instruction file
into `AGENTS.md` (grouped by subsystem, a line or two each, verified against the code); mine session logs or notes
for corrections that never reached the repo; move in-progress hard-to-reverse design into `docs/<topic>/` and
reference material into the README; leave finished phase specs in `.planning/phases/` as a frozen archive (code cites
them); delete `STATE.md`, `ROADMAP.md`, `_deferred/` and `.planning/templates/`; put open work in the tracker or a
root `TODO.md` of open items only; replace `AGENT.md`/the old snippet with `AGENTS.md` plus `CLAUDE.md` = `@AGENTS.md`.
One commit. Check first that nothing (including other repos) reads `.planning/` automatically.
