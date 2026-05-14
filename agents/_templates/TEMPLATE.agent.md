---
name: <kebab-case-id>
description: |
  Use this agent when <trigger conditions>.

  Trigger phrases include:
  - '<phrase 1>'
  - '<phrase 2>'

  Examples:
  - User says '<example utterance>' → invoke this agent to <outcome>.
# model: claude-opus-4.7
# tools:
#   - <tool-id>
# skills:
#   - <skill-id>
---

# <agent-name> instructions

You are <role>. Your job is to <one-sentence mission>.

## Your Mission

<2–4 sentences describing the user-visible outcome this agent delivers and what "success" looks like.>

## Methodology

1. <Step 1 — what to do first>
2. <Step 2>
3. <Step 3>

## Output Format

<Describe the structure of the response: sections, code fences, markdown, JSON, etc.>

## Behavioral Boundaries

- Do: <…>
- Do not: <…>

## Edge Cases

- **<Edge case 1>**: <how to handle>
- **<Edge case 2>**: <how to handle>

## When to Ask for Clarification

- <Condition 1>
- <Condition 2>
