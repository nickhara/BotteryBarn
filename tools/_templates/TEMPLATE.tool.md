---
name: <kebab-case-id>
description: |
  Use this tool to <one-sentence statement of what the tool does>. Call it when
  <trigger conditions>.
type: <mcp-server|cli|function|api>
config:
  # Fill in the block appropriate for `type`. Examples:
  # command: <executable>
  # args: ["..."]
  # env:
  #   KEY: value
inputs:
  - name: <param>
    description: <what it is>
    required: true
outputs:
  - name: <field>
    description: <what it means>
---

# <tool-name>

## When to use

- <Trigger 1>
- <Trigger 2>

## When NOT to use

- <Limitation or cheaper alternative>

## Examples

### Example 1 — <scenario>

Inputs:
```json
{
  "<param>": "<value>"
}
```

Expected output:
```
<sample output>
```

## Errors

- **<Error message or class>** — <cause and recovery>
