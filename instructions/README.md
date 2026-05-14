# instructions/

**Scoped instructions** — directives that apply automatically whenever an agent is operating on matching files. Instructions are not invoked explicitly; they are picked up by file glob.

## File convention

```
instructions/<name>.instructions.md
```

- `<name>` is `kebab-case` and reflects the scope (e.g., `general`, `typescript`, `python-tests`, `terraform`).

## Frontmatter schema

```yaml
---
applyTo: <glob>                 # required; file glob this instruction applies to (e.g. "**", "**/*.ts", "src/**/*.py")
description: <one-line summary> # optional but recommended
---
```

The `applyTo` field uses the same glob syntax as VS Code / GitHub Copilot custom instructions. Use `"**"` for repo-wide instructions.

## Body

Write the body as durable guidance that should always be true while editing matching files. Keep it concise and rule-shaped ("Always…", "Never…", "Prefer X over Y").

Avoid:
- Methodology that belongs in an agent
- Parameterized templates that belong in a prompt
- Procedures that belong in a skill

See `_templates/TEMPLATE.instructions.md` for a fillable starter and `general.instructions.md` for a complete example.

## Adding a new instruction

1. Copy `_templates/TEMPLATE.instructions.md` to `instructions/<your-name>.instructions.md`.
2. Set `applyTo` to the narrowest correct glob.
3. Write rules as imperative bullets.
4. See `../docs/CONTRIBUTING.md` for the contribution checklist.
