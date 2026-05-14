---
applyTo: "**"
description: Repo-wide baseline behavior for any agent operating in a PromptCraft-equipped repository.
---

# General instructions

## Always

- Read the repository's `README.md` and any `docs/` index before making non-trivial changes.
- When editing a file, preserve its existing style (indentation, quoting, line endings) unless the change is explicitly a style fix.
- Make the smallest change that fully solves the problem; do not refactor adjacent code.
- Update or add tests when changing behavior covered by tests.
- Update documentation that is directly affected by the change.

## Never

- Commit secrets, tokens, or credentials.
- Add new top-level dependencies without a brief justification in the PR description.
- Rename or move public APIs without flagging the breaking change.

## Prefer

- Existing helpers and patterns in the repo over introducing new abstractions.
- Plain, explicit code over clever one-liners.
- Failing fast with a clear error over silent fallbacks.

## Notes

These rules are the floor, not the ceiling. Narrower instruction files (e.g., language- or directory-scoped) layer on top of these.
