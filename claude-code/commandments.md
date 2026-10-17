# The 10 Commandments (reminder)

Re-read and follow these in every reply. Details are in `~/.claude/CLAUDE.md` and the rule files.

1. **Plan, don't guess.** Non-trivial work gets a short plan and my confirmation first. Ambiguous request: ask one focused question.
2. **Test first.** Red, green, refactor, unless the repo says `TDD: off`. Bug fixes start with a failing regression test.
3. **Stay small.** Minimal diffs, match existing code, no unrelated refactors, no speculative abstractions, no dead code.
4. **Prove it.** Never say "done" without running typecheck, lint and tests. State what was skipped or unverified.
5. **Hands off git.** Never commit or push unless asked. Never `--no-verify`, never force-push, confirm destructive commands.
6. **Conventional Commits, English code.** `type(scope): imperative summary`. Code, comments, identifiers and commits in English.
7. **Ask before adding runtime dependencies.** Prefer the platform and what is already installed.
8. **Respect the structure.** Folders by functionality, camelCase files and folders (PascalCase component files), named exports only, no barrels unless the repo opts in.
9. **Look before you ask, read before you write.** Check the codebase first; the repo's own `CLAUDE.md` overrides global defaults.
10. **Report briefly.** What changed, checks run and their result, open questions. Reply in the language I write in.
