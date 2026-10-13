#!/usr/bin/env bash
# Refresh vendor/ from upstream: AI Hero (mattpocock/skills) and Ponytail.
# Skills are copied unchanged except that `disable-model-invocation` is removed,
# so any tool's agent can chain them (e.g. dev-loop calling /to-spec).
# Review the result with `git diff`, then commit. Needs git and python3.
set -euo pipefail
cd "$(dirname "$0")"

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
git clone -q --depth 1 https://github.com/mattpocock/skills "$tmp/mattpocock"
git clone -q --depth 1 https://github.com/DietrichGebert/ponytail "$tmp/ponytail"

mkdir -p vendor LICENSES && rm -rf vendor/*/  # keeps vendor/README.md
# AI Hero: the stable set listed in its plugin manifest.
python3 - "$tmp/mattpocock" <<'PY'
import json, shutil, sys, pathlib
root = pathlib.Path(sys.argv[1])
for rel in json.load(open(root / ".claude-plugin/plugin.json"))["skills"]:
    src = root / rel
    shutil.copytree(src, pathlib.Path("vendor") / src.name)
PY
for d in "$tmp"/ponytail/skills/*/; do cp -R "${d%/}" vendor/; done
cp "$tmp/mattpocock/LICENSE" LICENSES/mattpocock-skills.LICENSE
cp "$tmp/ponytail/LICENSE" LICENSES/ponytail.LICENSE

grep -rl '^disable-model-invocation:' vendor --include=SKILL.md | xargs -r sed -i.bak '/^disable-model-invocation:/d'
find vendor -name 'SKILL.md.bak' -delete

{ echo "mattpocock/skills $(git -C "$tmp/mattpocock" rev-parse HEAD)"
  echo "DietrichGebert/ponytail $(git -C "$tmp/ponytail" rev-parse HEAD)"; } > UPSTREAM.lock
echo "vendored $(ls vendor | wc -l | tr -d ' ') skills; review with: git diff"
