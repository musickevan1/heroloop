---
name: land-prs
description: Get your open pull requests merged in the right order, one signed-off merge plan per repo. Use after a dev-loop pass, or when the user asks to land, merge or clean up their PRs.
argument-hint: "[all]"
---

# land-prs

Terms (merge plan, gate, stack, sign-off, parked ticket): [GLOSSARY.md](../dev-loop/GLOSSARY.md). The user is present. **Read only until sign-off**: steps 1 and 2 run `gh` reads and local `git` reads, and nothing else.

Scope: the user's open PRs in the current repo. `/land-prs all` covers every repo: `gh search prs --author @me --state open --json repository,number`.

## 1. Collect

Per repo (add `-R <owner/repo>` outside the current one):

- `gh pr list --author @me --state open --json number,title,url,headRefName,baseRefName,isDraft,mergeable,reviewDecision,statusCheckRollup,updatedAt,files`
- `gh repo view --json defaultBranchRef,mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed,deleteBranchOnMerge`

## 2. Brief

One section per repo:

1. **Merge plan**: PRs that can merge now: not draft, checks green (or no checks), `reviewDecision` `APPROVED` or empty, `mergeable` `MERGEABLE`, base is the default branch or a PR earlier in the plan. Order: stacks bottom-up (a PR whose base is another PR's head sits above it); PRs that change the same files go smaller or approved first; the rest oldest first. Columns: PR, title, checks, review, stacked on, unblocks.
2. **Blocked**: each other non-draft PR with its reason: conflicts, red checks, review required, changes requested, or stacked on a blocked or draft PR.
3. **Draft or stale**: drafts (parked tickets included) and PRs untouched for 30+ days, each with one suggested action:
   - Conflicting: **rebase**; conflicting and stale: **close**, "stale and conflicting".
   - Red checks: **finish** (keep working, or `/dev-loop` for a ticket PR).
   - Otherwise a draft: **mark ready** (this asks the team for review).
   - Stale, not a draft: **rebase, or close if abandoned**, "no update in N days".
4. **Merge method**: `--merge` when the repo allows merge commits (stacked PRs keep a clean diff); otherwise the allowed one, and say that each PR stacked on a merged one will need a rebase.

Ask which merge plan to sign off first, and which blocked or draft PRs need a decision.

## 3. Sign-off

One repo's merge plan at a time; the user may drop PRs from it. Suggested actions are signed off in bulk or one by one. A PR without sign-off is left exactly as it is.

Carry out signed-off actions: `gh pr ready <n>`, `gh pr close <n> --comment "<reason>"`. Rebase and finish go back to the user as next steps.

## 4. Merge, in plan order

For each PR:

1. **Gate**: `gh pr checks <n> --watch` (the previous merge may have restarted checks). Red: stop the plan.
2. **Base**: a PR stacked on the one just merged must target that PR's base. If GitHub has not retargeted it within a minute, `gh pr edit <n> --base <that base>`.
   - Squash or rebase merges only: rebase it onto the base first. In its checkout, `git fetch origin`, then `git rebase --onto origin/<base> <old head sha of the merged PR>`, re-run the gate locally, and `git push --force-with-lease`. Ask the user before this push, every time.
3. **Conflict**: `mergeable` is `CONFLICTING` (re-query while `UNKNOWN`): stop the plan and offer to resolve it: on the PR's branch, `git fetch origin` and `git merge origin/<base>`, resolve each conflict keeping both sides' intent (ask the user where intent is unclear), run the repo's test command, commit, and push. Once pushed, return to sub-step 1 for this PR.
4. **Merge**: `gh pr merge <n> <method>`. Branch protection decides what is allowed: a refused merge stops the plan, and is reported as it is.

Nothing after a stop is merged. Report what merged, where it stopped, and why.

## 5. After merging

- **Local branches**: `git fetch --prune`, then `git branch -d <head>` for each merged PR's branch (it refuses one with unmerged work; report that one). Branches checked out elsewhere are listed, not deleted.
- **Next tickets**: when a merged PR closed a dev-loop ticket and its spec has tickets left, suggest `/dev-loop <spec>` for the next pass.
