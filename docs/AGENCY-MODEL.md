# The agency model

BotteryBarn is organized around the **agency model**: agents are the primary primitive, and every other resource type (skills, tools, prompts, instructions) exists to be composed by an agent.

## The five resource types

```text
                        ┌────────────────────┐
                        │      Agent         │
                        │  (persona + plan)  │
                        └─────────┬──────────┘
              composes  ┌─────────┼─────────┬─────────────┐
                        ▼         ▼         ▼             ▼
                    ┌────────┐┌────────┐┌─────────┐┌──────────────┐
                    │ Skill  ││  Tool  ││ Prompt  ││ Instruction  │
                    │(runbook││(capab- ││(one-shot││(scoped rule, │
                    │  steps)││ ility) ││ request)││ glob-applied)│
                    └────────┘└────────┘└─────────┘└──────────────┘
```

### Agent

A persona with a mission, methodology, and output format. Agents make plans, decide which skills/tools/prompts to use, and produce the user-visible result. **Agents are the only entity that contains "judgment."**

### Skill

A multi-step procedure (a runbook) that an agent — or a human — can execute. Skills are bundled directories that may carry their own scripts, resources, and references. Skills are deterministic in shape: same inputs, same procedure.

### Tool

A callable capability with named inputs and outputs. Tools have no judgment — they execute. An MCP server, a CLI, an HTTP endpoint, or an in-process function all fit here.

### Prompt

A single-shot, parameterized request the agent (or a slash command) fires off to a model. No persona, no methodology — just a templated instruction with placeholders.

### Instruction

A scoped, glob-applied rule that should always be true when matching files are in play. Instructions do not need to be invoked; they layer themselves onto whatever agent is active.

## Why agents are first

Most other organizing frameworks for AI assets center on **prompts** ("a library of prompts") or **tools** ("a registry of MCP servers"). BotteryBarn centers on **agents** because:

1. **The user's mental model is "who is helping me?"**, not "which prompt fragment was used?" An agent name is something a human can talk about.
2. **Agents compose everything else.** Skills, tools, prompts, and instructions are reusable inputs, but only agents are user-facing endpoints.
3. **Agents are the locus of judgment.** If something has to make a decision — when to use which tool, when to ask for clarification, how to format output — it belongs in an agent.
4. **Agents are testable as units.** "Does the `pr-reviewer` agent produce a good review on PR X?" is a question you can answer end-to-end.

## Decision tree for new content

When you want to add something, decide what kind of resource it is:

| If the new thing is …                                                                | Put it in       |
|---------------------------------------------------------------------------------------|-----------------|
| A persona with methodology and a contract for its output                              | `agents/`       |
| A multi-step procedure that's deterministic in shape (and may need bundled helpers)   | `skills/`       |
| A callable thing with structured inputs and outputs                                   | `tools/`        |
| A single-shot, parameterized request to a model                                       | `prompts/`      |
| A rule that should always apply when editing matching files                           | `instructions/` |

If you find yourself wanting to put methodology, persona, or branching logic into a prompt, **promote it to an agent**. If you find yourself putting procedure into an instruction, **promote it to a skill**. If you find yourself putting judgment into a tool, **the judgment belongs in the agent calling the tool, not in the tool itself.**

## Composition mechanics

- **Agent → Skill:** list the skill id under `skills:` in the agent's frontmatter. The agent's body should describe *when* to invoke each listed skill.
- **Agent → Tool:** list the tool id under `tools:` in the agent's frontmatter. The agent may call any listed tool at runtime.
- **Agent → Prompt:** reference the prompt by name from the agent's body (e.g., "Use the `summarize-pr` prompt to produce the review brief.") — no frontmatter wiring needed.
- **Agent ← Instruction:** instructions are *not* listed by agents. They apply themselves automatically when the agent is operating on files matching the instruction's `applyTo` glob.

This asymmetry is deliberate. Skills and tools are *capabilities the agent reaches for*; instructions are *constraints the environment imposes on the agent*. Prompts sit between — referenced by name but not "owned" by the agent.

## Practical implications

- **Reuse happens at the skill/tool/prompt layer.** Two agents can share a skill; you don't duplicate the procedure.
- **Customization happens at the agent layer.** Different teams can wire the same skills and tools into agents with different personas, output formats, or guardrails.
- **Policy lives in instructions.** Repo-wide rules ("never log PII", "always use the project's logger") belong in `instructions/`, not in every agent.

When in doubt: ask "is this the *persona*, the *procedure*, the *capability*, the *request*, or the *rule*?" — and place it accordingly.
