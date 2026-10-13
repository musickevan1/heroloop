# heroloop

A plain, tool-agnostic dev workflow for AI coding agents: **AI Hero** skills for planning and building, **Ponytail** for keeping the code minimal, and two small skills that tie them into a loop, from idea to merged pull requests.

Everything is a Markdown `SKILL.md` in the open [Agent Skills](https://agentskills.io) format, so it works the same in **GitHub Copilot** (VS Code), **Cursor**, **Codex** and **Claude Code**. There is no plugin, no server, and no hidden automation: each step is written out in a file you can read.

## The loop

| Step | Who | Skill |
|---|---|---|
| 1. Grill the idea until it is settled | you + agent | `/grill-with-docs` |
| 2. Write the spec, split it into tickets | agent | `/to-spec`, `/to-tickets` |
| 3. **Checkpoint: ticket brief** | you sign off | `/dev-loop` |
| 4. Implement each ticket test-first, review it, open a draft PR (stacked on its blocker) | agent | `/dev-loop` → `/implement`, `/tdd`, `/code-review`, `/ponytail-review`, `/pr` |
| 5. **Checkpoint: merge plan** | you sign off | `/land-prs` |
| 6. Merges unblock more tickets: back to 4 | | `/dev-loop <spec>` |

`/dev-loop <idea>` runs steps 1 to 4 in one session; `/dev-loop <spec>` starts at the brief. The agent never merges, force-pushes or closes anything without your sign-off. Terms are in [skills/dev-loop/GLOSSARY.md](skills/dev-loop/GLOSSARY.md).

## What's in here

```
skills/      this repo's own skills: dev-loop, land-prs
vendor/      upstream skills, copied unchanged (refreshed by sync.sh)
AGENTS.global.md   always-on guidance to paste into your tool (see below)
install.ps1  link the skills into your tool's skills folder (Windows)
install.sh   the same, for macOS / Linux / WSL
sync.sh      maintainers: refresh vendor/ from upstream
```

`vendor/` holds other people's work, credited below; see [vendor/README.md](vendor/README.md) for what was changed.

## Install

Needs `git`, and the [GitHub CLI](https://cli.github.com) (`gh auth login`) for the PR steps.

**Windows** (PowerShell):

```powershell
git clone https://github.com/<you>/heroloop $HOME\heroloop
& $HOME\heroloop\install.ps1
```

**macOS / Linux**:

```sh
git clone https://github.com/<you>/heroloop ~/heroloop
~/heroloop/install.sh
```

This links every skill into `~/.agents/skills`, which Copilot in VS Code, Cursor and Codex all read. For Claude Code add its folder: `install.ps1 ~\.claude\skills` / `install.sh ~/.claude/skills` (Copilot and Cursor also read that folder, so skip it if you don't use Claude Code, or you'll see each skill twice). Existing skills with the same name are never overwritten; the script reports them as skipped.

To share with a team instead, copy the skills into a repo: `install.ps1 -Copy .github\skills` / `install.sh --copy .github/skills`.

### Always-on guidance

Skills load on demand; the Ponytail default and the flow overview need to be in every chat. Paste [AGENTS.global.md](AGENTS.global.md) into:

- **Copilot (VS Code)**: Command Palette → *Chat: New Instructions File* → *User*; paste it below a front matter of `applyTo: "**"`.
- **Cursor**: Settings → Rules → *User Rules*.
- **Codex**: `~/.codex/AGENTS.md`. **Claude Code**: `~/.claude/CLAUDE.md`.

## Use

In a repo, open agent chat and type `/` to see the skills.

1. Once per repo: `/setup-matt-pocock-skills` picks where tickets live (GitHub Issues, GitLab, local Markdown files, or something like Jira you describe) and writes it to `docs/agents/`.
2. `/dev-loop add CSV export to the reports page`
3. When the PRs are up: `/land-prs` (`/land-prs all` for every repo).

Not sure which skill fits? `/ask-matt`.

## Update

```sh
git -C ~/heroloop pull
```

Links follow the repo, so there is nothing to reinstall unless skills were added or removed (re-run the install script; it also removes links to deleted skills). Copied installs need the install script re-run.

Maintainers refresh upstream with `./sync.sh` (Git Bash works on Windows), review `git diff`, and commit.

## Notes

- Claude Code's built-in `/code-review` takes precedence over the AI Hero skill of the same name there; other tools use the AI Hero one.
- The ticket loop runs inside your chat session, one ticket at a time. If your tool can hand a ticket to a subagent, `dev-loop` says to, which keeps each ticket in a fresh context. Cloud agents that open PRs from issues (like Copilot's coding agent) fit too: `/land-prs` works the same on their PRs.

## Credits

Most of the skills here are not mine. They are copied unchanged from:

- **AI Hero** by Matt Pocock: [mattpocock/skills](https://github.com/mattpocock/skills), MIT ([license](LICENSES/mattpocock-skills.LICENSE)). The grilling, spec, ticket, TDD, review and domain-modeling skills.
- **Ponytail** by Dietrich Gebert: [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail), MIT ([license](LICENSES/ponytail.LICENSE)). The `ponytail*` skills.

The exact upstream commits are in [UPSTREAM.lock](UPSTREAM.lock). The skill format is the open [Agent Skills](https://agentskills.io) standard. This repo's own files (`skills/`, scripts, docs) are MIT, see [LICENSE](LICENSE).
