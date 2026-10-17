# agent-rules-and-guidelines

My personal rules, guidelines and hooks for AI coding agents, kept in one place so I can
move to a new machine quickly and share them as inspiration.

The main ecosystem is **Claude Code**. Other tools (GitHub Copilot, ...) will be added as
they become relevant.

## Repository layout

```
claude-code/                  mirrors ~/.claude/ plus extras
  CLAUDE.md                   core principles, stack-neutral (-> ~/.claude/CLAUDE.md)
  commandments.md             "10 Commandments" reminder (-> ~/.claude/commandments.md)
  rules/                      path-scoped rules, loaded by file type
    react-typescript.md       React + TypeScript + Vite + Vitest conventions and tooling
    python.md                 stub, to be defined
  hooks/
    commandments.mjs          UserPromptSubmit hook, re-injects the commandments every 10th message
  settings.hooks.snippet.json hook registration to merge into ~/.claude/settings.json
  templates/
    repoCLAUDE.template.md    starter for a per-repo CLAUDE.md with overrides
copilot/                      placeholder, GitHub Copilot instructions will live here
docs/                         notes on how the rules apply to other tools
```

## Design in short

- **Core file stays stack-neutral.** `CLAUDE.md` holds working principles (autonomy, git,
  dependencies, TDD, reporting). It stays under ~200 lines because Claude follows shorter files
  more reliably.
- **Stack rules load lazily.** Files in `rules/` use `paths:` frontmatter, so React/TypeScript
  rules load only when matching files are touched and Python rules do not clutter a React repo.
- **Repos override defaults.** A repo-level `CLAUDE.md` (see the template) is more specific and
  wins, for example `TDD: off` for a tiny app or enabling barrel exports.
- **Commandments keep the agent on track.** A hook re-injects a condensed ten-point reminder
  every 10th message of a session.

## Quick migration (Claude Code, new machine)

Requires Node (for the hook). Run from the repo root:

```sh
mkdir -p ~/.claude/rules ~/.claude/hooks
cp claude-code/CLAUDE.md ~/.claude/CLAUDE.md
cp claude-code/commandments.md ~/.claude/commandments.md
cp claude-code/rules/*.md ~/.claude/rules/
cp claude-code/hooks/commandments.mjs ~/.claude/hooks/commandments.mjs
```

Then register the hook: merge `claude-code/settings.hooks.snippet.json` into
`~/.claude/settings.json`. If a `hooks` key already exists, add the `UserPromptSubmit` entry to
it instead of replacing the file. Check it works with `COMMANDMENTS_EVERY=1 claude`, where the
reminder should appear on every message.

For a new project, copy `claude-code/templates/repoCLAUDE.template.md` to the project's
`CLAUDE.md` and fill in only what differs from the defaults.

If you already have your own `~/.claude/CLAUDE.md`, merge instead of overwriting. Files in
`~/.claude/` are concatenated with project files, so avoid contradicting instructions.

## Using this as inspiration

Take what fits and delete the rest. The opinions here are mine: npm, Vitest, Conventional
Commits, camelCase files, named exports only, TDD by default, and an agent that never commits
unless asked. Adjust the rule files to your own taste.

## Other tools

- **Claude on the web** has no config files or hooks. It is set up through the UI (preferences,
  project instructions), so there is no folder for it. See [docs/claudeWeb.md](docs/claudeWeb.md).
- **GitHub Copilot**: see [copilot/README.md](copilot/README.md).

## License

GPL-3.0, see [LICENSE](LICENSE).
