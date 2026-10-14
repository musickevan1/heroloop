# heroloop setup (for agents)

You are an AI coding agent installing heroloop for the user on this machine. Work through the steps in order; each ends on a check. Run commands yourself, explain each one in a line before you run it, and stop to ask before anything listed under **Ask first**.

**Ask first**: installing software, overwriting or deleting any file you did not create in this setup, and running commands the user must do interactively (they run those themselves).

## 1. Know your environment

Note, before changing anything:

- **OS and shell**: Windows (PowerShell) or macOS / Linux / WSL (bash or zsh).
- **Which tool you are running in**: GitHub Copilot in VS Code, Cursor, Codex, or Claude Code. Ask if you cannot tell. The user may use several; set up each one they name.
- **Home folder**: `$HOME` in both shells. Below, `~` means it; in PowerShell write `$HOME\...` instead, since `git` and other programs there do not expand `~`.

Done when you can state all three.

## 2. Prerequisites

- `git --version` works. If it is missing, **ask first**, then install it (Windows `winget install --id Git.Git -e`, macOS `xcode-select --install`, Linux the package manager).
- `gh --version` works. If missing, **ask first**, then install it (Windows `winget install --id GitHub.cli -e`, macOS `brew install gh`, Linux see https://cli.github.com).
- `gh auth status` succeeds. If not, ask the user to run `gh auth login` themselves (it is interactive), and wait until they say it is done.

Done when all three commands succeed. On Windows, a freshly installed tool may need a new terminal before it is found.

## 3. Get heroloop

- `~/heroloop` does not exist: `git clone https://github.com/musickevan1/heroloop ~/heroloop`.
- It exists and is a clone of that repo (`git -C ~/heroloop remote get-url origin`; PowerShell: `git -C $HOME\heroloop remote get-url origin`): `git -C ~/heroloop pull --ff-only` (PowerShell: `git -C $HOME\heroloop pull --ff-only`).
- It exists and is something else: ask the user where to clone instead, and use that path wherever this file says `~/heroloop`.

Done when `~/heroloop/install.sh` and `~/heroloop/install.ps1` exist.

## 4. Install the skills

**Existing copies first.** The user may already have AI Hero or Ponytail. List the skill folders in each place the user's tools read (`~/.agents/skills`, `~/.copilot/skills`, `~/.claude/skills`, `~/.cursor/skills`, `~/.codex/skills`), and for Claude Code also `claude plugin list`. A folder is an existing copy when its name matches a folder in `~/heroloop/vendor/`, or it is a Ponytail or AI Hero plugin, and it is not a link into `~/heroloop`. If you find any, tell the user where, and ask which they want:

- **Let heroloop manage them** (recommended: one copy, updated by `git pull`): **ask first**, then remove those copies (for a plugin, `claude plugin uninstall <name>`) and install.
- **Keep theirs**: install as is. In `~/.agents/skills` the installer skips names that already exist and `dev-loop` uses their copies; copies in the other folders stay, so tools that read several folders list those skills twice.

Then install:

- Windows: `powershell -ExecutionPolicy Bypass -File $HOME\heroloop\install.ps1`
- macOS / Linux / WSL: `~/heroloop/install.sh`

This links every skill into `~/.agents/skills`, which Copilot (VS Code), Cursor and Codex read. If the user uses **Claude Code**, also run it with that folder: `install.ps1 $HOME\.claude\skills` or `install.sh ~/.claude/skills`. Only for Claude Code users: Copilot and Cursor read that folder too and would show every skill twice.

Report any `skip ...` lines to the user: a skill of that name already exists and was left alone.

Done when `~/.agents/skills/dev-loop/SKILL.md` and `~/.agents/skills/land-prs/SKILL.md` can be read.

## 5. Install the always-on guidance

`~/heroloop/AGENTS.global.md` must reach every chat. Use the heroloop block: the file's full contents between two marker lines:

```text
<!-- heroloop:start -->
...contents of AGENTS.global.md...
<!-- heroloop:end -->
```

To write the block into an existing file: if the markers are already there, replace what is between them; otherwise append the block at the end. Leave the rest of the file untouched. A new file gets just the block.

For each tool the user uses:

- **Codex**: write the block into `~/.codex/AGENTS.md`.
- **Claude Code**: write the block into `~/.claude/CLAUDE.md`.
- **GitHub Copilot (VS Code)**: write the block into `~/.claude/CLAUDE.md` (the same file as Claude Code; reuse the block if it is there) and turn on the VS Code setting `chat.useClaudeMdFile`, which makes VS Code read that file for personal instructions in every chat. This route is documented but not yet confirmed on a real VS Code: ask the user to open a new agent chat and check that it follows the Ponytail guidance, and say so if it does not.
- **Cursor**: User Rules live in Cursor's settings, not in a file. Copy `AGENTS.global.md` to the clipboard (Windows `Get-Content $HOME\heroloop\AGENTS.global.md -Raw | Set-Clipboard`, macOS `pbcopy < ~/heroloop/AGENTS.global.md`) and ask the user to paste it into Settings → Rules → *User Rules*. Wait for them to confirm.

Done when every tool the user named has the guidance, confirmed by reading the file back or by the user.

## 6. Verify and hand over

Tell the user:

1. What you installed, and where (the clone, the skills folder(s), each guidance location).
2. To reload the editor (VS Code / Cursor: *Developer: Reload Window*), then type `/` in agent chat: `dev-loop`, `land-prs` and the AI Hero and Ponytail skills should be listed.
3. How to use it in a repo, in a new chat after the reload:
   - `/setup-matt-pocock-skills` once per repo, to choose where tickets live.
   - `/dev-loop <idea>` to plan and build; `/land-prs` to merge.
4. How to update later: `git -C ~/heroloop pull` (PowerShell: `git -C $HOME\heroloop pull`), re-running the installer only when skills were added or removed.

Done when the user has this summary.
