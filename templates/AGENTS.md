# {Project}

{What this is, in a sentence. The README covers the rest.}

## Working here

- Before changing a file, read its history (`git log -- <path>`) and open any commit that did the same thing.
- Run the checks below for what you touched, and again after any merge or rebase.
- Commit small: one change per commit, each passing its checks. The subject says what changed, and the trap if
  there was one, in words a search would find. Unless the diff says it, the body gives the why, what you ruled
  out, what you ran (with numbers) and what you didn't test.
- Leave each fixed bug's reproduction behind as a test or a script.
- Hard to reverse, several sessions long, or needs measured targets? Design it in `docs/<topic>/` first, and have
  a different model review it.
- Code and the running system outrank this file and every doc. When they disagree, fix the file in the same
  commit. When something breaks unnoticed, add a rule here, with a check if one can be written.

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
