# GitHub Copilot

Placeholder. Nothing is defined here yet.

Planned: adapt the principles in [`../claude-code/CLAUDE.md`](../claude-code/CLAUDE.md) and the
stack rules in [`../claude-code/rules/`](../claude-code/rules/) for Copilot, by hand and only
where they make sense (Copilot has no equivalent of Claude Code hooks).

Where Copilot reads instructions from (verify against the current GitHub docs before relying on
this, as it changes):

- `.github/copilot-instructions.md`: repository-wide instructions
- `.github/instructions/*.instructions.md`: path-scoped instructions using an `applyTo` glob
- `AGENTS.md`: agent instructions that several tools read

When content is added, note which Claude Code file it was adapted from so drift stays visible.
