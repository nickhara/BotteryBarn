# prompts/

**Reusable prompts** — parameterized prompt bodies an agent (or a user via a slash command) can invoke. A prompt is a self-contained instruction with optional named arguments. Unlike an agent, a prompt does not own a methodology or persona — it produces a one-shot response.

## File convention

```text
prompts/<name>.prompt.md
```

- `<name>` is `kebab-case` and matches the `description` topic (e.g., `summarize-pr`, `write-conventional-commit`).

## Frontmatter schema

```yaml
---
description: <one-sentence summary of what the prompt does>   # required
arguments:                                                    # optional
  - name: <arg-name>
    description: <what the argument is>
    required: true|false
    default: <optional default value>
# model: <optional model id>
---
```

## Body

Write the prompt body as if speaking directly to the model. Reference arguments with `{{arg-name}}` placeholders (Mustache-style, ecosystem-neutral). Keep prompts short and single-purpose; if you find yourself adding methodology, branching logic, or persona, promote it to an **agent** instead.

See `_templates/TEMPLATE.prompt.md` for a fillable starter and `summarize-pr.prompt.md` for a complete example.

## Adding a new prompt

1. Copy `_templates/TEMPLATE.prompt.md` to `prompts/<your-name>.prompt.md`.
2. Fill in the frontmatter and body.
3. If an agent will invoke the prompt, mention it by name in that agent's body (no frontmatter link is needed).
4. See `../docs/CONTRIBUTING.md` for the contribution checklist.
