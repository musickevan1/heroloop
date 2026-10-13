#!/usr/bin/env bash
# Link every skill in skills/ and vendor/ into one or more skills folders.
#   ./install.sh                     -> ~/.agents/skills (Copilot in VS Code, Cursor, Codex)
#   ./install.sh ~/.claude/skills    -> any other folder(s) you name
#   ./install.sh --copy <dir>...     -> copy instead of symlink (e.g. a repo's .github/skills
#                                       to share with a team)
#   ./install.sh --uninstall [dir...] -> remove what this script installed there
# Anything in a target folder that this repo did not put there is left alone.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
mode='link'
case "${1:-}" in --copy) mode=copy; shift ;; --uninstall) mode=uninstall; shift ;; esac
[ $# -eq 0 ] && set -- "$HOME/.agents/skills"

# Ours: a link into this repo, or a copy carrying the .heroloop marker.
ours() {
  if [ -L "$1" ]; then case $(readlink "$1") in "$ROOT"/*) return 0 ;; *) return 1 ;; esac; fi
  [ -f "$1/.heroloop" ]
}

for dest in "$@"; do
  n=0
  if [ $mode = uninstall ]; then
    for t in "$dest"/*; do
      if ours "$t"; then rm -rf "$t"; n=$((n + 1)); fi  # no trailing slash: a link is removed, never followed
    done
    echo "removed $n skills from $dest"
    continue
  fi
  mkdir -p "$dest"
  for s in "$ROOT"/skills/*/ "$ROOT"/vendor/*/; do
    s=${s%/}; target="$dest/$(basename "$s")"
    if [ -L "$target" ] || [ -e "$target" ]; then
      ours "$target" || { echo "skip $target (not installed by heroloop)"; continue; }
      rm -rf "$target"
    fi
    if [ $mode = copy ]; then cp -R "$s" "$target" && touch "$target/.heroloop"; else ln -s "$s" "$target"; fi
    n=$((n + 1))
  done
  # Drop links to skills that no longer exist in this repo.
  for l in "$dest"/*; do
    if [ -L "$l" ] && [ ! -e "$l" ] && ours "$l"; then rm "$l"; fi
  done
  echo "installed $n skills into $dest"
done
