# Repository structure

This document is the authoritative reference for PromptCraft's directory layout, file naming conventions, and frontmatter schemas. New contributors should read this end-to-end before adding content.

## Top level

```
PromptCraft/
├── agents/         # Agent definitions (the agency-model primary primitive)
├── skills/         # Skill packages (Anthropic-style, one directory per skill)
├── tools/          # Tool catalog (MCP servers, CLIs, functions, APIs)
├── prompts/        # Reusable, parameterized prompts
├── instructions/   # Scoped behavioral instructions (apply by file glob)
├── docs/           # Human-facing documentation (this folder)
├── scripts/        # Automation, including the PowerShell installer
└── README.md
```

Each of `agents/`, `skills/`, `tools/`, `prompts/`, and `instructions/` ships with:

- a `README.md` describing the folder's convention,
- a `_templates/` subdirectory with a starter file you can copy,
- and one or more seed examples.

## Why this layout

PromptCraft is **ecosystem-neutral**: the same files can be surfaced under GitHub Copilot's `.github/...` paths, Claude Code's `.claude/...` paths, or no tool-specific surface at all. The top-level folders are the canonical home; tool-specific paths (when needed) are produced by additional symlinks in the consuming repo (see `USAGE.md`).

The layout is also **agency-first** — agents are the organizing primitive. See `AGENCY-MODEL.md` for the rationale.

## File conventions by folder

### `agents/<name>.agent.md`

```yaml
---
name: <kebab-case-id>           # required; must match filename stem
description: |                  # required; when to invoke + trigger phrases + examples
  Use this agent when ...
model: <optional model id>      # optional
tools:                          # optional; ids from tools/
  - <tool-id>
skills:                         # optional; ids from skills/
  - <skill-id>
---
```

Body = the **system prompt** (role, mission, methodology, output format, boundaries, edge cases).

### `skills/<name>/SKILL.md`

```yaml
---
name: <kebab-case-id>           # required; matches directory name
description: |                  # required; what the skill does and when to invoke
  Use this skill to ...
version: <semver>               # optional
inputs:                         # optional
  - name: <param>
    description: <…>
outputs:                        # optional
  - name: <artifact>
    description: <…>
---
```

Body = a **procedure** (numbered runbook steps). Bundle helpers under `./scripts/`, data under `./resources/`, and longer docs under `./references/`. Always reference bundled files with relative paths.

### `tools/<name>.tool.md` (or `tools/<name>/TOOL.md`)

```yaml
---
name: <kebab-case-id>           # required
description: <when to use it>   # required
type: <mcp-server|cli|function|api>   # required
config:                         # shape depends on type
  ...
inputs:                         # optional
  - name: <param>
    description: <…>
    required: true
outputs:                        # optional
  - name: <field>
    description: <…>
---
```

Body = the **operator guide** (when to use, when not to, examples, errors).

### `prompts/<name>.prompt.md`

```yaml
---
description: <one-line summary> # required
arguments:                      # optional
  - name: <arg>
    description: <…>
    required: true
    default: <optional>
model: <optional model id>      # optional
---
```

Body = the **prompt text**. Reference arguments with `{{arg-name}}` (Mustache-style, ecosystem-neutral). Keep prompts single-purpose; methodology belongs in an agent.

### `instructions/<name>.instructions.md`

```yaml
---
applyTo: <glob>                 # required; e.g. "**", "**/*.ts", "src/**/*.py"
description: <one-line summary> # recommended
---
```

Body = durable, rule-shaped guidance ("Always…", "Never…", "Prefer X over Y"). Avoid methodology (→ agent), parameterized templates (→ prompt), and procedures (→ skill).

## Naming rules

- All identifiers are `kebab-case`: lowercase letters, digits, and `-`.
- The `name` field in frontmatter must match the file or directory stem exactly.
- Use short, descriptive names. Prefer `pr-reviewer` over `agent-for-reviewing-pull-requests`.
- Don't suffix names with the resource type (`my-agent.agent.md` is fine, `my-agent-agent.agent.md` is not).

## Templates and seed examples

| Folder         | Template                                | Seed example                                  |
|----------------|------------------------------------------|------------------------------------------------|
| `agents/`      | `_templates/TEMPLATE.agent.md`           | `codebase-architecture-guide.agent.md`         |
| `skills/`      | `_templates/example-skill/SKILL.md`      | `repo-onboarding/SKILL.md`                     |
| `tools/`       | `_templates/TEMPLATE.tool.md`            | `repo-inspector.tool.md`                       |
| `prompts/`     | `_templates/TEMPLATE.prompt.md`          | `summarize-pr.prompt.md`                       |
| `instructions/`| `_templates/TEMPLATE.instructions.md`    | `general.instructions.md`                      |

`_templates/` directories are surfaced through the installer along with everything else — they are harmless when present in a consuming repo and useful as in-context starters.

## What lives where: a quick decision tree

- **"This is a persona with methodology and an output format."** → `agents/`
- **"This is a multi-step procedure the agent (or a human) should follow."** → `skills/`
- **"This is a callable capability with inputs and outputs."** → `tools/`
- **"This is a single-shot, parameterized request."** → `prompts/`
- **"This is a rule that should always apply when editing matching files."** → `instructions/`
