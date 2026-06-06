# tools/

**Tool definitions** — callable capabilities an agent may invoke. A tool entry describes *what* the tool is, *how* to configure it, and *when* an agent should call it. The actual runtime (MCP server, CLI, function) lives wherever it lives; this folder is the catalog.

## File convention

Two layouts are supported:

- **Single-file tool** — `tools/<name>.tool.md` when the tool is a thin pointer to an external command or MCP server.
- **Bundled tool** — `tools/<name>/TOOL.md` plus sibling files (`server.json`, `scripts/`, etc.) when the tool ships code or configuration alongside.

In both cases `<name>` is `kebab-case` and matches the `name` field in frontmatter.

## Frontmatter schema

```yaml
---
name: <kebab-case-id>           # required
description: |                  # required; what the tool does and when an agent should call it
  Use this tool to ...
type: <mcp-server|cli|function|api>   # required
# Configuration block — shape depends on `type`.
config:
  # mcp-server example
  # command: npx
  # args: ["-y", "@modelcontextprotocol/server-filesystem", "${REPO_ROOT}"]
  # env:
  #   REPO_ROOT: /path/to/repo
  #
  # cli example
  # command: gh
  # args_template: ["pr", "view", "{pr_number}"]
  #
  # api example
  # endpoint: https://api.example.com/v1
  # auth: { type: bearer, token_env: EXAMPLE_TOKEN }
inputs:                         # optional; named parameters the tool accepts
  - name: <param>
    description: <what it is>
    required: true
outputs:                        # optional; what the tool returns
  - name: <field>
    description: <what it means>
---
```

## Body

The body is the **operator guide** for the tool:

1. **When to use it** — concrete trigger conditions for an agent.
2. **When not to use it** — known limitations or cheaper alternatives.
3. **Examples** — at least one full invocation with sample inputs and expected output.
4. **Errors** — common failure modes and how to recover.

See `_templates/TEMPLATE.tool.md` for a fillable starter and `repo-inspector.tool.md` for a complete example.

## Adding a new tool

1. Copy `_templates/TEMPLATE.tool.md` to `tools/<your-name>.tool.md` (or create a directory for a bundled tool).
2. Fill in the frontmatter — pay attention to `type` and `config`.
3. List the tool's id under any agent that should be allowed to call it (`tools:` in the agent's frontmatter).
4. See `../docs/CONTRIBUTING.md` for the contribution checklist.
