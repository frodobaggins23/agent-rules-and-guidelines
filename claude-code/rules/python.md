---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
---

# Python rules (STUB: not yet defined)

This file shows the pattern: a stack-specific rule file that loads automatically when Python
files are touched. The decisions below are NOT made yet. Do not invent conventions.

## When working in a Python repo
- Ask me about preferences before scaffolding: package/env manager, formatter, linter, type
  checker, test framework, project layout, Python version.
- Follow the universal principles in `~/.claude/CLAUDE.md` (plan first for non-trivial work,
  Conventional Commits, never commit unless asked, ask before adding dependencies, English
  code and commits, short final report).

## To fill in (decide together, then replace this section)
- Tooling (candidates to discuss: uv, ruff, pytest, mypy or pyright, pre-commit)
- Naming: Python convention is snake_case for files/functions, PascalCase for classes
- Folder structure by functionality (same philosophy as the React rules)
- Git hooks equivalent: commit-msg (conventional commits), pre-commit (lint + types),
  pre-push (tests)
- Python version pinning
