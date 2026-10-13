#!/usr/bin/env bash
# Link every skill in skills/ and vendor/ into one or more skills folders.
#   ./install.sh                     -> ~/.agents/skills (Copilot in VS Code, Cursor, Codex)
#   ./install.sh ~/.claude/skills    -> any other folder(s) you name
#   ./install.sh --copy <dir>...     -> copy instead of symlink (Windows without symlinks,
#                                       or a repo's .github/skills to share with a team)
# Anything already in a target folder that this repo did not put there is left alone.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
copy=0; [ "${1:-}" = "--copy" ] && { copy=1; shift; }
[ $# -eq 0 ] && set -- "$HOME/.agents/skills"

for dest in "$@"; do
  mkdir -p "$dest"
  n=0
  for s in "$ROOT"/skills/*/ "$ROOT"/vendor/*/; do
    s=${s%/}; target="$dest/$(basename "$s")"
    if [ -L "$target" ]; then
      case $(readlink "$target") in "$ROOT"/*) rm "$target" ;; *) echo "skip $target (links elsewhere)"; continue ;; esac
    elif [ -e "$target" ]; then
      [ -f "$target/.heroloop" ] || { echo "skip $target (not installed by heroloop)"; continue; }
      rm -rf "$target"
    fi
    if [ $copy = 1 ]; then cp -R "$s" "$target" && touch "$target/.heroloop"; else ln -s "$s" "$target"; fi
    n=$((n + 1))
  done
  # Drop links to skills that no longer exist in this repo.
  for l in "$dest"/*; do
    [ -L "$l" ] && [ ! -e "$l" ] && case $(readlink "$l") in "$ROOT"/*) rm "$l" ;; esac
  done
  echo "installed $n skills into $dest"
done
