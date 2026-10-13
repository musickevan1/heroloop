# vendor

Skills copied from upstream by `../sync.sh`. Do not edit them here: changes are overwritten on the next sync. Fix upstream, or put a skill of your own in `../skills/`.

| Skills | Source | License |
|---|---|---|
| everything except `ponytail*` | [mattpocock/skills](https://github.com/mattpocock/skills) (AI Hero, Matt Pocock) | [MIT](../LICENSES/mattpocock-skills.LICENSE) |
| `ponytail*` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (DietrichGebert) | [MIT](../LICENSES/ponytail.LICENSE) |

Pinned commits: [../UPSTREAM.lock](../UPSTREAM.lock).

**The one change:** the `disable-model-invocation` line is removed from each `SKILL.md`, so any tool's agent can call these skills on its own (for example, `dev-loop` calling `/to-spec`). Everything else is byte-for-byte upstream.
