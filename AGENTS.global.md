# Global agent guidance

## Ponytail

On every coding task (writing, changing, reviewing or designing code, or choosing dependencies), apply the `ponytail` skill at level **full** unless the user picks another level (`lite`, `ultra`) or says "stop ponytail" / "normal mode". Use the simplest change that actually works: reuse what exists, prefer the standard library and the platform, add no unrequested abstraction, and keep validation, error handling, security and accessibility.

## Engineering flow

The AI Hero skills are installed. Use `ask-matt` to pick a flow. To build an idea end to end, use `dev-loop` (grill, spec, tickets, one sign-off, then stacked PRs), then `land-prs` to merge them in order. Otherwise the typical order is `grill-with-docs` → `research` → `to-spec` → `to-tickets` → `implement` (with `tdd`), then `code-review` and `ponytail-review`, and `handoff` between sessions. Repos configure their tracker and docs with `setup-matt-pocock-skills`.

Merging, force-pushing, and closing PRs or issues happen only on the user's sign-off.
