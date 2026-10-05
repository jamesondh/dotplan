<p align="center">
  <img src="dotplan.svg" alt="dotplan v2: one AGENTS.md, no ceremony" width="100%">
</p>

# dotplan

dotplan is a short `AGENTS.md` template and a small set of habits for repos where coding agents work. It has three
parts:

1. **`AGENTS.md`**: a map of the repo, the rules that are easy to break, and the checks that find the breaks.
2. **Commit messages** that record why each change was made.
3. **Design docs** in `docs/<topic>/`, only for changes that are hard to reverse, long, or need measured targets.

There is nothing to install and no planning directory to maintain.

## Why so little

dotplan v1 (early 2026) was a `.planning/` directory with a roadmap, a state file, and a spec for each phase of
work. The agents of that time often lost track of a project between sessions, and the files gave them a summary to
start from.

Current agents do not need that summary. They read `git log` and the code, and they find the state of a project in
seconds. Their result is often more accurate than a summary from the end of the last session. The v1 files also
became longer with time and needed regular cleanup. With Opus 5.5, the v1 process made the work slower, not faster.

An agent that starts a new session still needs three things: where the code is, what breaks without a visible
error, and why the code is the way it is. `AGENTS.md` gives the first two. The git history gives the third. v2 asks
you to write those two well, and nothing more. v1 is on the [`v1` branch](https://github.com/jamesondh/dotplan/tree/v1).

## 1. `AGENTS.md`: map, rules, checks

Put one file at the repo root. The agent reads all of it at the start of each session. Most agent tools read
`AGENTS.md` directly. Claude Code 2.1.277 and later reads it when there is no `CLAUDE.md`. For earlier versions and
SDK harnesses, add a `CLAUDE.md` that contains only `@AGENTS.md`.

The file has four sections ([template](templates/AGENTS.md)):

- **Working here:** six rules for how to work. They are the same in every repo.
- **Map:** where the important code is, one line for each item, 20 to 40 lines in total. Include each
  `docs/<topic>/` folder. Explanation goes in the README.
- **Rules:** things that a change can break without a visible error. Give each rule its reason and a check. The most
  useful rules involve more than one file. Example: "Each new table needs a line in the backup manifest, or backups
  do not include it." No single file tells you that.
- **Checks:** a table of the minimum checks to run for each path. Agents run the checks that the file lists. They
  often miss checks that are only in old commits.

A check is one of three types: a command, `manual: <what a person examines>`, or `none` if no script can find the
problem. If a check already fails at HEAD, write the commit that broke it. If a check can touch production (for
example, a test suite that reads `DATABASE_URL`), write how to run it safely.

**Length.** Keep the fixed sections short. The rules can use the space they need, at one or two lines each, under
subheadings. A few hundred lines of rules is acceptable. History and status do not go in this file. Codex reads a
maximum of 32 KiB of instruction files by default (`project_doc_max_bytes`), which is approximately 400 lines.

**Evidence.** In tests on three repos, agents found 85% of the known traps with the file and 72% without it. Without
the file, they also used about 25% more tool calls and 20% more tokens.

**Keep all rules in the root file.** Do not put rules in nested `AGENTS.md` files. Most important rules involve
more than one directory, and tools load nested files only in some conditions. Claude Code loads a nested file when
the agent opens a file in that directory with its Read tool, and never when a root `CLAUDE.md` exists. Codex loads
only the files between the repo root and the directory where it starts. In tests, recall of rules in nested files
fell from 98% to 76% when the agent read files through the shell. If the file becomes too long, move reference
material out. Do not move rules out.

**Add rules from failures.** When something breaks and nobody sees it, add a rule. Add a check if you can write one.
A script is better than a paragraph, because an agent cannot misread a script.

## 2. Commits: the reason for each change

Agents already read the history. In tests, new agents ran `git log -- <path>` and `git log -S`, and opened the last
commit that did the same task. Nobody told them to do this. Thus the history is the memory of the project, and the
commit messages set its quality.

- **The subject is the index.** Name what changed, and the trap if there was one. Use the words that a later search
  will use. Example: one commit fixed a conflict between two branches that both increased the protocol version.
  Its subject named only the two features, and no agent that searched for the problem found it. "Protocol version:
  two branches both bumped to 7; take a number past both on merge" is easy to find.
- **Commit small.** Make one change in each commit, and make each commit pass its checks. A small commit can name
  its trap exactly, and it is easy to find, revert and bisect.
- **The body gives the reason.** Write what was wrong, what you did, and what you rejected and why. Then write what
  you ran (with numbers) and what you did not test. If the diff makes the reason clear, you can omit the body.
- **Keep the reproduction of each fixed bug** as a test, a script or a fixture. In the body, write how to run it.

Example:

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

Trailers are not necessary, because agents read prose well. For provenance, `Assisted-by: <agent>:<model>` is
becoming the standard.

## 3. `docs/<topic>/`: only for hard changes

Write a design doc only when a change:

- is hard to reverse (a schema, a protocol, auth, money),
- continues for more than one session, or
- needs measured targets.

For all other changes, the commits are the record.

Name the folder by topic, and keep it current while the work continues. A design doc has four parts:

- **Today:** how it works now, with file references and a measured baseline.
- **Design:** the target, and the rules that each step must obey.
- **Passes:** the steps, each with acceptance numbers and the command that measures them.
- **Status:** a table at the top of the folder's index. This is the only status that dotplan keeps, and it is for
  one topic.

Get a review of hard-to-reverse work from a new session that did not write it. A different model family can help
if it is at least as capable as the author. In [one controlled study](https://arxiv.org/abs/2607.21656), review
between two frontier models helped in one direction and made the result worse in the other.

## The loop

1. **Orient:** read the README and `AGENTS.md`, then run `git status` and `git log -n 20`. Look further back
   (`git log -- <paths>`, `-S`, `blame`) when the change repeats, reverses or depends on earlier work.
2. **Size the work:** most work goes directly to code. If the change is hard to reverse, long, or needs
   measurement, start or update `docs/<topic>/`.
3. **Work, then run the checks** for each path you changed.
4. **Integrate:** after a merge, rebase or conflict resolution, run the checks again.
5. **Commit** with a subject that a search can find and a body that gives the reason.
6. **Promote:** if something broke and nobody saw it, add a rule and its check to `AGENTS.md` in the same commit as
   the fix.

## Open work

Git shows what is done and what changed. Git cannot show what is next, what is on hold, or what waits for a person.
Put those items in your issue tracker. If you do not have a tracker, keep a `TODO.md` at the root with open items
only, one line each. Delete each line when its item is done. If `TODO.md` needs a cleanup pass, it has become a
state file again.

## No opinion on

Merge, rebase or squash. Branches or direct commits to main. Issue trackers. Commit trailers. Which models.
One caveat: if you squash-merge, the squashed commit is the only history that remains. Its message must give the
reasons for the full branch.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/jamesondh/dotplan/main/init.sh | bash
```

The script creates `AGENTS.md` from the [template](templates/AGENTS.md) if it does not exist, and a `CLAUDE.md`
that imports it. Then write the map, the rules you know, and the checks you run. You can also copy the template
manually. The script does nothing more.

## From v1

Cut history and status, but do not cut rules. Move each rule from `STATE.md`, the phase specs and the old
instruction file into `AGENTS.md`, and verify it against the code. In tests, migrations that moved rules into
`AGENTS.md` increased recall (74% → 84%). Migrations that removed rules to make the file shorter decreased it
(88% → 81%). Move in-progress design work into `docs/<topic>/`. Keep finished phase specs in `.planning/phases/` as a
frozen archive, because code comments often refer to them. Then delete `STATE.md`, `ROADMAP.md`, `_deferred/` and
`.planning/templates/`. [SKILL.md](SKILL.md#migrating-from-v1-planning) has all the steps.

## Measuring it

To test an instruction file, freeze a snapshot of the repo. Write five or six requests of the type you really make.
For each request, write a key: the traps that a careful engineer who knows the project would mention, and where
each trap is written (instruction file, README, docs, code or history). Give each request to a new agent. Ask it
what it would look out for and what it would run, but not to write code. Grade the answers against the key, and
compare instruction files on the same snapshot.

Look at recall for each layer, not only the total. Recall of traps in the instruction file should be almost 100%,
so the useful numbers are for the README, the code and the history. To measure what the commit messages carry,
remove the commit bodies from the snapshot. The decrease in recall is what the bodies carried.

## Related work

- [Lore](https://arxiv.org/abs/2603.15566) (2026) turns commit messages into decision records with git trailers
  (`Constraint`, `Rejected`, `Directive`, `Not-tested`...) and a query CLI. dotplan agrees that commits are the
  correct place for this, but asks for prose, not a schema.
- [`Assisted-by:`](https://allthingsopen.org/articles/open-source-ai-contributions-assisted-by-git-trailer-standard)
  records which agent and model helped with a commit. The Linux kernel, Fedora and LLVM recommend it. It is about
  provenance, which is a different problem from memory.
- [Entire](https://entire.io) keeps the transcript of each agent session with its commits.
  [git-ai](https://github.com/git-ai-project/git-ai) and Cursor's [Agent Trace](https://github.com/cursor/agent-trace)
  connect code to the conversations that wrote it. These tools keep everything. dotplan keeps what the next agent
  needs.

## Principles

- **Checks over prose.** An agent cannot misread a rule that it can run.
- **Derive state; do not cache it.** If git can tell you something, do not also keep it in a file.
- **The code and the running system are the truth.** Instruction files and docs are claims. When they disagree with
  the code, fix them in the same commit.
- **Put knowledge where agents look for it:** rules that are always true in `AGENTS.md`, the reason for a change in
  its commit, and the design of a hard subsystem in `docs/`.
- **Match the process to the reversibility.** Most changes need a good commit and nothing more.
