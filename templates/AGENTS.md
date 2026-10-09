# {Project}

{What this is, in a sentence. The README covers the rest.}

## Working here

- Do what was asked, the simplest way that meets it. Experiments, new tooling and paid runs nobody asked for are
  proposals: say what they cost and what decision their result would change, and wait.
- When you're repeating something the project has done before, reversing an earlier decision, or changing code
  whose purpose isn't clear, look at its history (`git log -- <path>`, `git log -S<symbol>`, `git blame`) and
  open the commits that explain it.
- The checks below are the minimum for what you touched. Run them again after any merge, rebase or conflict
  resolution.
- Commit small: one change per commit, each passing its checks. The subject says what changed, and the trap if
  there was one, in words a search would find. Unless the diff says it, the body gives the why, what you ruled
  out, what you ran (with numbers) and what you didn't test.
- Leave each fixed bug's reproduction behind as a test or a script.
- A step that's hard to reverse (schema, auth, money, external API) or several sessions long: design it in
  `docs/<topic>/` first. Judge each step, not the project: copying history into a new repo is reversible even when
  the project moves money. Measure with the checks below or existing tools before writing new ones. Have a fresh
  session review the work (the design first, when that could save rework), from a different model family when one
  at least as capable is available, and ask it what to cut or do more simply, not only what's missing.
- If the work grows well past what you first expected, stop and tell the user: what you expected, where it is now,
  and a smaller way to finish.
- Code and the running system outrank this file and every doc. When they disagree, fix the file in the same
  commit. When the project's code breaks unnoticed, add a rule here, with a check if one can be written; tooling
  built for one task doesn't get rules. Delete rules whose code is gone.

## Map

- `{path}`: {what lives there}

## Rules

{Everything a change could break without anyone noticing, a line or two each, grouped by subsystem.}

- **{Rule}.** {Why, and the commit that taught it.} Check: `{command}` | manual: {what to look at} | none.

## Checks

| When you touch | Run |
|---|---|
| anything | `{test and typecheck, and how to run them without touching production}` |
| `{path}` | `{check}` |
| `{path}` | `{check}` (fails at HEAD since {commit}: {why}) |
