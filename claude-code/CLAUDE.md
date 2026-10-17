# Personal projects: core principles

Stack-neutral defaults for all my personal repositories (tiny apps and complex ones).
Stack-specific rules live in `~/.claude/rules/` and load automatically by file type
(`react-typescript.md`, `python.md`). A repo-level `CLAUDE.md` is more specific and wins
over anything here; if two instructions conflict, follow the repo file and mention the conflict.

## The 10 Commandments
- A condensed version of the most important rules lives in `~/.claude/commandments.md`.
- A `UserPromptSubmit` hook re-injects it every 10th message of a session. When it appears,
  re-read it and follow it for the rest of the session. It summarizes this file and never
  overrides a repo-level `CLAUDE.md`.

## Communication
- Reply in the language I write in (Czech or English).
- Code, comments, identifiers, commit messages and docs are always in English.
- Final report is short: what changed, which checks ran (typecheck / lint / tests) and their
  result, open questions. No step-by-step recap. Say plainly what was skipped or unverified.

## How to work
- Small, clear task: just do it.
- Non-trivial work (multi-file, architectural, new pattern, new dependency): give a short plan
  and wait for my confirmation before implementing.
- Ambiguous request: ask. Do not guess. Ask one focused question at a time.
- If the answer can be found in the codebase, look there instead of asking.
- Read surrounding code first and match its existing style and patterns.
- Keep diffs minimal. No unrelated refactors, no speculative abstractions, no dead or
  commented-out code.
- Never claim something works unless you ran the check. "Done" means typecheck, lint and tests
  pass (or you state which could not be run and why).

## Stack detection
- Infer the stack from the files (`package.json` with react, `pyproject.toml`, ...).
- Empty or ambiguous repo: ask which stack before scaffolding anything.
- When scaffolding in a repo where no matching source files exist yet, read the relevant file
  in `~/.claude/rules/` first (path-scoped rules only load once matching files are touched).
- Unknown stack with no rule file: ask me for preferences instead of inventing conventions.

## Git
- Never commit or push unless I ask. Prepare the changes and propose a commit message.
- Never bypass hooks (`--no-verify`), never force-push, never rewrite shared history, and
  confirm before any destructive command (reset --hard, clean -fd, branch deletion).
- Commit messages follow Conventional Commits: `type(scope): imperative summary`.
  Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
  Subject max ~72 chars, no trailing period. Breaking change: `!` or `BREAKING CHANGE:` footer.
- One logical change per commit.

## Dependencies
- Ask before adding any runtime dependency. Prefer the platform and existing dependencies.
- Dev tooling from my agreed stack (see rule files) needs no approval.
- Always commit the lockfile. Avoid unmaintained or tiny single-purpose packages.

## Testing and TDD
- Default workflow is test-driven development, red / green / refactor, wherever it is
  practical:
  1. Red: write a failing test for the next small behavior and run it to confirm it fails
     for the right reason.
  2. Green: write the simplest code that makes it pass. Run the tests.
  3. Refactor: clean up code and tests while everything stays green. Run the tests again.
- Work in small increments, one behavior per cycle. Do not write implementation ahead of a
  failing test.
- Bug fixes start with a failing regression test that reproduces the bug.
- TDD applies to logic (utilities, hooks, services, state, API handlers). It is not required
  for trivial presentational components, styling, or throwaway spikes. Say so briefly when
  skipping it for a part of the work.
- Opt-out: a repo (e.g. a very small app) disables TDD with a line such as
  `TDD: off` in its own `CLAUDE.md`. Then write tests after the code, or skip them for
  trivial pieces, as that file says. Without such a line, TDD is on.
- Unit-test logic even when TDD is off. Trivial presentational components do not need tests.
- Tests are fast, deterministic and independent. No real network or clock in unit tests.
- In the plan for non-trivial work, list the first tests (the red steps) before implementing.

## Code quality
- Readable over clever. Small functions, descriptive names, early returns.
- Comments explain why, not what.
- Handle errors explicitly. Never swallow them silently.
- Validate input at system boundaries (user input, network, files).
- No secrets in code or commits. Use environment variables; keep `.env` gitignored and
  provide `.env.example`.
- Organize code by functionality. Naming conventions per language are in the rule files.

## Project hygiene
- Every repo has a README with: purpose, setup, scripts/commands, and how to run tests.
- Pin the runtime version (e.g. `.nvmrc`) so setups are reproducible.
- Keep config files minimal and standard. Prefer tool defaults unless a rule says otherwise.
