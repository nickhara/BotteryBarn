# skills/

**Skill packages** — self-contained, reusable procedures an agent (or a human) can follow. Skills follow the Anthropic skill-package layout: each skill is a directory with a `SKILL.md` entry point and optional bundled resources.

## Directory convention

```text
skills/<skill-name>/
├── SKILL.md            # required: frontmatter + procedure
├── scripts/            # optional: executable helpers the skill invokes
├── resources/          # optional: data files, templates the procedure consumes
└── references/         # optional: longer-form docs / examples the agent may read on demand
```

- `<skill-name>` is `kebab-case` and must match the `name` field in `SKILL.md` frontmatter.

## `SKILL.md` frontmatter schema

```yaml
---
name: <kebab-case-id>           # required; matches the directory name
description: |                  # required; what the skill does and when to use it. Keep it action-oriented.
  Use this skill to ...
# version: 1.0.0                # optional
# inputs:                       # optional; expected inputs the agent should gather first
#   - name: repo_path
#     description: Absolute path to the repository to analyze
# outputs:                      # optional; what the skill produces
#   - name: onboarding_doc
#     description: Markdown summary of the repo
---
```

## `SKILL.md` body

The body is the **procedure**: a numbered or sectioned set of steps the agent (or user) should execute. Reference any bundled `scripts/`, `resources/`, or `references/` with **relative paths** (`./scripts/foo.ps1`).

Treat the body as a runbook, not a chat prompt — assume the reader will follow it step-by-step.

See `_templates/example-skill/SKILL.md` for a fillable starter and `repo-onboarding/SKILL.md` for a complete example.

## Adding a new skill

1. Copy `_templates/example-skill/` to `skills/<your-name>/`.
2. Edit `SKILL.md` (frontmatter + procedure).
3. Add any helper scripts or data under `scripts/` / `resources/` / `references/`.
4. If an agent should auto-load this skill, list it under `skills:` in that agent's frontmatter.
5. See `../docs/CONTRIBUTING.md` for the contribution checklist.
