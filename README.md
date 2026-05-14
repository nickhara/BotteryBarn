# PromptCraft

PromptCraft is an engineering toolkit for designing reliable AI-powered workflows. It provides reusable prompt patterns, templates, and agent-driven solutions for real-world scenarios such as code generation, system design, debugging, and build system modernization — treating prompts as structured, composable artifacts in modern software development.

## The agency model

PromptCraft is organized around the **agency model**: **agents** are the primary primitive, and every other resource type — **skills**, **tools**, **prompts**, **instructions** — exists to be composed by an agent. See [`docs/AGENCY-MODEL.md`](docs/AGENCY-MODEL.md) for the rationale and decision tree.

## Repository structure

```
PromptCraft/
├── agents/         # Agent definitions (persona + methodology + output format)
│   └── _templates/ # Starter files to copy when adding a new agent
├── skills/         # Skill packages (multi-step procedures, Anthropic-style)
│   └── _templates/
├── tools/          # Tool catalog (MCP servers, CLIs, functions, APIs)
│   └── _templates/
├── prompts/        # Reusable, parameterized prompts
│   └── _templates/
├── instructions/   # Scoped behavioral rules (apply by file glob)
│   └── _templates/
├── docs/           # Documentation
└── scripts/        # PowerShell installer
```

Each top-level resource folder ships with its own `README.md`, a `_templates/` directory, and at least one seed example. Full conventions and frontmatter schemas live in [`docs/STRUCTURE.md`](docs/STRUCTURE.md).

## Quickstart

Install PromptCraft into another repository on the same machine by symlinking the resource folders:

```powershell
# Requires PowerShell 7+.
# On Windows: enable Developer Mode or run from an elevated shell.
cd <path-to-PromptCraft>
./scripts/Install-PromptCraft.ps1 -TargetPath <path-to-target-repo>
```

This creates directory symlinks at `<target>/agents`, `<target>/skills`, `<target>/tools`, `<target>/prompts`, and `<target>/instructions` pointing at this repo. Updates to PromptCraft are then visible in every consuming repo without re-running the installer.

For full usage — options, troubleshooting, and ecosystem-specific overlays (`.github/...`, `.claude/...`) — see [`docs/USAGE.md`](docs/USAGE.md).

## Contributing

See [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for how to add a new agent, skill, tool, prompt, or instruction.
