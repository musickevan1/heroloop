---
name: dev-loop
description: Take an idea, or an existing spec, through grilling, spec and tickets to a signed-off ticket brief, then implement the tickets in dependency order as stacked pull requests. Use for `/dev-loop <idea>`, `/dev-loop <spec>`, or when the user wants an idea built end to end.
argument-hint: "<idea> | <spec issue or path>"
---

# dev-loop

Terms (spec, ticket, ticket brief, sign-off, stack, parked ticket, gate): [GLOSSARY.md](GLOSSARY.md). The user is present: the loop stops at one checkpoint, the ticket brief, and changes nothing outside this repo's branches and pull requests. Merging belongs to `/land-prs`.

## 1. Setup check

- `docs/agents/issue-tracker.md` exists. Otherwise run `/setup-matt-pocock-skills` first; every later step reads tickets through it.
- `gh auth status` succeeds (pull requests are opened with `gh`).
- Note the default branch: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.

## 2. Plan (`/dev-loop <idea>` only)

1. `/grill-with-docs` on the idea until the user says it is settled.
2. `/to-spec` publishes the spec; `/to-tickets`, with the spec issue as its source, creates its tickets with their blocking edges.

`/dev-loop <spec>` skips this step and reads the spec's existing tickets.

## 3. Ticket brief

Read only: no branch, commit or tracker write until sign-off. Read every ticket of the spec (the spec issue's sub-issues on GitHub, or the files in the spec's folder with a local tracker) and show one table, in the order they will be worked (blockers before what they block, then lowest number):

| Ticket | Title | Blocked by | Base branch | Status |
|---|---|---|---|---|

- **Base branch**: the default branch, or a blocker's branch when that blocker has an open, unmerged PR (the ticket is **stacked** on it).
- **Status**: `ready`; `done` (closed, or `gh pr list --state all --head ticket/<n>-<slug>` finds an open or merged PR; a PR body saying `Closes #<n>` counts too); `waits on #<n>` (a blocker has no PR yet and is not in this pass, or two or more blockers are unmerged); `needs a human` (labelled with the tracker's `ready-for-human` label).

Under the table, state:

- **Gate**: the command that proves a ticket works, found in `AGENTS.md`, the README, or the package scripts (run each gate command separately and require each to succeed). Ask when none is clear.
- **Branches**: `ticket/<n>-<slug>`. When that branch already exists, show it here and ask: reuse it, or start fresh as `ticket/<n>-<slug>-2`.
- **What sign-off allows**: creating those branches, committing, pushing them, and opening one draft PR per ticket. Never merging, force-pushing, or touching other branches.

## 4. Sign-off

Ask the user to sign off, edit, or reject. Make the edits they ask for (ticket text, blocking edges, dropped tickets), then show the brief again. Reject ends the skill with nothing changed.

## 5. Ticket loop

The working tree must be clean (`git status --porcelain` prints nothing); otherwise ask the user to commit or stash first. Then, for each `ready` ticket in brief order:

1. **Branch**: `git fetch origin`, then `git switch -c ticket/<n>-<slug> --no-track <base>`, where `<base>` is `origin/<default branch>`, or the blocker's local `ticket/...` branch when stacked.
2. **Implement** this one ticket with `/implement` (`/tdd`, then `/code-review`, fixing what it finds), then `/ponytail-review` on the diff, applying its cuts. When your tool can hand work to a subagent with a fresh context, give it the ticket and these instructions; otherwise work inline.
3. **Gate**: the gate command exits 0 and the branch has changes beyond its base. On failure, make one focused fix attempt with the failure output in view, then run the gate again.
4. **Ship** (gate green): commit any remaining changes (`/implement` already commits) as `<ticket title> (#<n>)`, `git push origin ticket/<n>-<slug>`, write a PR body following `/pr` to a temp file ending with `Closes #<n>` (or a link to the ticket when the tracker is not GitHub Issues), then `gh pr create --draft --head ticket/<n>-<slug> --base <base branch name> --title "<ticket title>" --body-file <file>`.
5. **Park** (gate still red after the fix attempt): commit the work, push, and open the same draft PR with the gate's last 20 lines of output and the reason at the top of its body. Label the ticket with the tracker's `ready-for-human` label. Its dependents wait until a later pass.

A ticket is finished when it has a PR. When the conversation grows long between tickets, run `/handoff`; `/dev-loop <spec>` in a fresh session picks up from the brief, since tickets with PRs show as `done`.

## 6. Pass summary

When no `ready` ticket is left, report:

- PRs opened, in stack order, with links.
- Parked tickets and why.
- Tickets still waiting, and on what.
- **Next**: `/land-prs` when PRs opened; otherwise the parked tickets that block the waiting ones.

Offer `/retro` on the pass.
