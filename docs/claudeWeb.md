# Claude on the web

There is no folder for Claude on the web because it has no file-based configuration and no
hooks. It is set up through the UI (profile preferences, project instructions, memory), so
the content has to be pasted in by hand.

## What transfers from `claude-code/`

- `commandments.md`: usable almost as-is as a preferences or project-instructions block.
- The communication, working-style and code-quality sections of `CLAUDE.md`.

## What does not transfer

- The `UserPromptSubmit` hook and anything relying on hooks or path-scoped `rules/`.
- Rules about running typecheck, lint and tests, and Git hook setup, unless the session
  actually has a code execution environment attached to your repo.
- `~/.claude/...` paths.

If web-specific text is ever written, put it in this file or promote it to a `claude-web/`
folder once it is substantial.
