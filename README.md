# dotplan

A convention for repositories that AI agents work in. It has three parts: an instruction file of rules paired with
the checks that enforce them, commit messages that carry the reasoning, and design docs for the few changes that
earn one. There's nothing to install and no planning directory to maintain.

> **v2 draft.** dotplan v1 was a `.planning/` directory (ROADMAP, STATE, per-phase specs). v2 removes it. See
> [What changed](#what-changed-from-v1) for why and [Migrating](#migrating-from-v1) for how.

## The idea in one paragraph

An agent that starts cold needs three things: where things are, what breaks without anyone noticing, and why the
code looks the way it does. The first two belong in one file that's loaded every session, and the second is
worth most when each rule comes with a command that checks it. The third already has a home that every tool can
read, that stays current without upkeep, and that can be searched by file: the git history. dotplan v2 asks you to
write those well and nothing else.

## The convention

### 1. `AGENTS.md`: a map, the rules, and the checks

One file at the repo root, read in full every session. `AGENTS.md` has the broadest native
support across tools. For Claude Code, make `CLAUDE.md` a one-line stub that imports it (`@AGENTS.md`), so the two
never drift apart.

It holds:

- **Working here:** the convention itself, six bullets ([template](templates/AGENTS.md)).
- **A map:** where the important parts of the code live, one line each, 20 to 40 lines in all, including any
  `docs/<topic>/` folders. It's for finding your way; explanation belongs in the README.
- **Rules:** invariants that are easy to break without noticing. Give each one its reason and a way to check it.
  The rules most worth writing down span several files: "every new table needs a line in the backup manifest, or
  it's silently left out of backups" is something no single file tells you.
- **Checks by path:** a table of what to run when you touch what. An agent runs the checks it's told about and
  misses the ones it would only find by reading old commits.

**How long?** The fixed part is short; the rules take the room they need. Agents used what was in the file and
missed much of what was only in older planning files, so a rule is cheaper here than anywhere else. Keep each rule to
a line or two, group them under subheadings, and put explanation in the README or `docs/`. A few hundred lines of
rules is fine; a few hundred lines of history or status isn't.

**Checks come in three kinds:** a command, `manual: <what a person looks at>` for things only a human can judge,
and `none` for rules no script can catch. A check that already fails at HEAD is listed with the commit that broke it.
A check that could touch production (a test suite that reads `DATABASE_URL`, say) must say how to run it safely.

The file grows one way: **when something breaks without anyone noticing, add a rule, and a check if one can be
written.** A rule enforced by a script is worth more than a paragraph explaining it, and a script is the part an
agent can't misread.

### 2. Commits: the why, where the next agent will look

Agents already read history. In testing, fresh agents given a real repo and a task ran `git log -- <path>`,
searched with `-S`, and opened the commit that did the same thing last time, without being asked. So the history is the project's memory,
and its quality depends on how the commits were written.

- **The subject is the index.** Name what changed and, if there was one, the trap, in the words a later search
  would use. In testing, one commit fixed a collision between two branches that had each bumped the protocol
  version, under a subject that named only the two features; every agent that needed the lesson searched straight
  past it. "Protocol version: two branches both bumped to 7; take a number past both on merge" would have been
  found.
- **Commit small.** One change per commit, each passing its checks. A small commit gets a subject that can name its
  trap exactly, it shows up cleanly in `git log -- <path>`, and it can be reverted or bisected alone. A day of work
  in one commit leaves the next agent a diff to reverse-engineer.
- **The body carries the why**, unless the diff makes it obvious: what was wrong, what you did, what you ruled out
  and why, what you ran (numbers, not "tests pass"), and what you didn't test.
- **Leave every fixed bug's reproduction behind** as a test, a script or a fixture, and say in the body how to run
  it.

A good one:

```
Sessions: renew the token before the clock-skew window, not at expiry (random logouts)

Servers whose clocks ran up to 40 s fast rejected tokens the client still thought
valid, so a user mid-request was logged out about once a day. Tokens now renew
when 90% of their life is gone. Ruled out: widening the server's skew tolerance,
which would also widen the window for a stolen token.

Ran: the auth suite (212 pass) and scripts/skew.sh, which runs a client against
servers 0-60 s fast: 0 rejections in 1,000 (was 37). Not tested: renewals during
a deploy, while both signing keys are live.
```

No trailers or structured fields are required. Agents read prose well, and a trailer nothing ever queries is
formatting. If you want provenance, `Assisted-by: <agent>:<model>` is the emerging convention.

### 3. `docs/<topic>/`: only past the threshold

Write a design doc when a change is **hard to reverse** (a schema, a protocol, auth, money), **spans more than one
session**, or **needs measured targets**. Anything else is recorded by its commits.

A design doc is named by topic and kept current as the work goes on, unlike a phase spec, which is archived once
done. The pattern that works:

- **Today:** how it works now, with file references and a measured baseline.
- **Design:** the target, and the rules every step must keep.
- **Passes:** the work in steps, each with acceptance numbers and the command that measures them.
- **Status:** a table at the top of the folder's index. This is the only "state" dotplan asks you to keep, and it's
  scoped to one topic.

Have hard-to-reverse work reviewed by a model from a different lineage than the one that wrote it. A reviewer that
shares the author's blind spots doesn't find them; a different lab's model finds the most, and a fresh session of
the same model is the minimum.

## The loop

1. **Orient:** the README, `AGENTS.md`, `git status`, `git log -n 20`, then `git log -- <paths>` for what you'll
   touch.
2. **Decide the size:** most work goes straight to code. If it's hard to reverse, long, or needs measuring, start or
   update a `docs/<topic>/`.
3. **Work, then run the checks** for the paths you touched.
4. **Integrate:** after any merge, rebase or conflict resolution, run those checks again.
5. **Commit** with a subject someone could search for and a body that says why.
6. **Promote:** if something broke that nobody noticed, add the rule and its check to `AGENTS.md` in the same commit
   as the fix.

## No opinion on

Merge, rebase or squash. Branches or committing straight to main. Issue trackers, roadmaps, task lists. Commit
trailers. Which models. dotplan works the same whichever you choose. One caveat: if you squash-merge, the squashed
commit is the only history left, so its message has to carry the reasoning of the whole branch.

## What changed from v1

v1 existed because agents were stateless and couldn't be trusted to reconstruct where a project stood. It kept a
precomputed summary in `.planning/STATE.md` and `ROADMAP.md`. Models can now rebuild that picture from git in
seconds, more accurately than a summary written at the end of the last session. The summaries became caches of git
with an invalidation problem. They bloated, needed their own compaction passes (one project's STATE went from 425
lines to 116, its ROADMAP from 498 to 110), and were a tax on every session.

| v1 | v2 |
|---|---|
| `.planning/STATE.md` | Derived: `git status`, `git log`, the open branches |
| `.planning/ROADMAP.md` | Your issue tracker, or a `TODO.md` of open items |
| `phases/NN-name/SPEC.md` for low-reversibility work | `docs/<topic>/`, named by topic and kept current (old specs stay, frozen) |
| The SPEC's postmortem | The commit bodies |
| `_deferred/` | The tracker or `TODO.md` |
| Agent instructions snippet | `AGENTS.md`: map, rules, checks by path |
| Reversibility decides whether to spec | Unchanged |
| Review with a different model | Unchanged, and a different lineage |

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/jamesondh/dotplan/main/init.sh | bash
```

This creates `AGENTS.md` from the [template](templates/AGENTS.md) if there isn't one, and a `CLAUDE.md` stub that
imports it. Then fill in the map, the rules you already know, and the checks you already run. Or copy the template
by hand; that's all the script does.

## Migrating from v1

The migration decides whether v2 helps. In testing on three v1 repos, agents found about 90% of the traps written
in the instruction file and noticeably fewer of those left in `STATE.md` or phase specs. Where the migration moved
buried rules into `AGENTS.md`, recall went up (74% → 84%). Where it trimmed rules to keep the file short, it went
down (88% → 81%). So **cut history and status, never rules.**

1. **Promote every rule.** Go through `STATE.md`, the phase specs and their postmortems, and the old instruction
   file. Anything a future change could break goes into `AGENTS.md` under Rules, with its reason and a check. This
   includes rules that only apply to one subsystem: group them under subheadings. Leave out what happened and when.
   Verify every path, command and number against the code as you go; old instruction files are often stale.
2. **Mine what never made it into the repo.** If you have agent session logs or notes, search them for corrections
   ("no, that's wrong", "you forgot", reverts). Each of the three test repos had 8 to 11 real traps recorded nowhere
   in the repo. Those are rules too.
3. **Move in-progress design work** on a hard-to-reverse subsystem into `docs/<topic>/`. Reference material that isn't
   a rule (setup, tool usage, build variants) goes in the README; create one if there isn't one.
4. **Freeze the finished phase specs where they are.** Code comments usually cite them by path, and in older repos
   they often hold the only record of why, because the commits have empty bodies. Leave `.planning/phases/` in place,
   add a one-line `.planning/README.md` saying it's a frozen archive, and don't add to it.
5. **Delete `STATE.md`, `ROADMAP.md`, `_deferred/` and `.planning/templates/`.** Open work goes where intent lives
   (next section). Fix anything that points at the deleted files, including scripts in other repos.
6. **Replace the instruction file** with `AGENTS.md` and a `CLAUDE.md` of `@AGENTS.md`. Remove any `AGENT.md`
   (singular): some harnesses load it alongside `AGENTS.md`.

The migration itself is one commit; it's the exception to "commit small." Anything that reads `.planning/`
automatically (a sync script, a dashboard) needs pointing elsewhere first.

### Where open work goes

State that git can derive (what's done, what changed, where things stand) doesn't get a file. Intent can't be
derived: what's next, what's parked, what's waiting on a person. Put it in your issue tracker. With no tracker, keep a
`TODO.md` at the root: open items only, one line each, deleted when done. If it ever needs a compaction pass, it has
turned back into `STATE.md`.

## Measuring it

There are no benchmarks for this, but a cheap test tells you most of what you need. Freeze a snapshot of the repo.
Write five or six requests of the kind you'd really make, and for each, a key of the traps a careful engineer who
knew the project would raise, noting where each lives (instruction file, README, docs, code, history). Ask fresh
agents, one request each, what they'd watch out for and what they'd run, without writing code. Grade the answers
against the key, and compare instruction files over the same snapshot.

Recall by layer matters more than the total. Traps written in the instruction file should be close to 100%, so the
interesting numbers are for the README, the code and the history. A useful ablation is the same snapshot with the
commit bodies stripped: whatever recall falls is what the commit messages were carrying.

## Related work

- [Lore](https://arxiv.org/abs/2603.15566) (2026) turns commit messages into decision records with nine git
  trailers (`Constraint`, `Rejected`, `Directive`, `Not-tested`...) and a query CLI. dotplan agrees that commits
  are the place for this, and asks for prose rather than a schema.
- [`Assisted-by:`](https://allthingsopen.org/articles/open-source-ai-contributions-assisted-by-git-trailer-standard),
  used by the Linux kernel, Fedora, LLVM and QEMU, records which agent and model helped. It covers provenance, a
  separate question from memory.
- [Entire](https://entire.io) saves each agent session's transcript alongside its commits, and
  [git-ai](https://github.com/git-ai-project/git-ai) and Cursor's
  [Agent Trace](https://github.com/cursor/agent-trace) attribute code to the conversations that wrote it. They keep
  everything; dotplan keeps what the next agent needs.

## Principles

- **Checks over prose.** A rule an agent can run is a rule it can't misread.
- **Derive state; don't cache it.** Anything git can tell you shouldn't also live in a file.
- **The code and the running system outrank every file.** Instruction files and docs are claims; when they disagree
  with what's there, fix them in the same commit.
- **Put knowledge where it's looked for:** always-true rules in the instruction file, the why of a change in its
  commit, the design of a hard subsystem next to it in `docs/`.
- **Match the process to the reversibility.** Most changes need a good commit and nothing more.
