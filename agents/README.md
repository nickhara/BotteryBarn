# agents/

First-class **agent definitions**. In BotteryBarn's agency model, agents are the primary organizing primitive — every other resource type (skills, tools, prompts, instructions) exists to be composed by an agent.

## File convention

```text
agents/<name>.agent.md
```

- `<name>` is `kebab-case`, unique within this folder, and matches the `name` field in frontmatter.
- One file per agent. Use a short, descriptive name (e.g., `codebase-architecture-guide`, `pr-reviewer`, `release-notes-author`).

## Frontmatter schema

```yaml
---
name: <kebab-case-id>           # required; must match filename
description: |                  # required; when/how to invoke this agent. Multi-line allowed.
  Use this agent when ...
  Trigger phrases include: ...
  Examples: ...
model: <optional model id>      # optional; e.g. claude-opus-4.7, gpt-5.2
tools:                          # optional; tool ids this agent may use (matches tools/<id>.tool.md)
  - <tool-id>
skills:                         # optional; skill ids this agent may load (matches skills/<id>/)
  - <skill-id>
---
```

## Body

The body of the file is the **system prompt** for the agent. Write it in second person ("You are ...") and cover:

1. Role and mission
2. Methodology / steps to follow
3. Output format
4. Behavioral boundaries (what to do, what not to do)
5. Edge cases and clarification triggers

See `_templates/TEMPLATE.agent.md` for a fillable starter and `codebase-architecture-guide.agent.md` for a complete example.

## How agents compose other resources

- **Skills** — reference by id under `skills:`; the agent can invoke the skill's procedure and load its bundled resources.
- **Tools** — reference by id under `tools:`; the agent may call these tools while executing.
- **Prompts** — referenced ad-hoc from within the agent body (e.g., "use the `summarize-pr` prompt when ...").
- **Instructions** — applied automatically by file glob (`applyTo`) regardless of which agent is active; agents do not list them.

## Adding a new agent

1. Copy `_templates/TEMPLATE.agent.md` to `agents/<your-name>.agent.md`.
2. Fill in the frontmatter and body.
3. List any `tools:` / `skills:` it depends on (ensure they exist in `tools/` / `skills/`).
4. See `../docs/CONTRIBUTING.md` for the contribution checklist.
