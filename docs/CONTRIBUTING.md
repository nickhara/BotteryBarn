# Contributing

Thanks for adding to PromptCraft. This guide covers the mechanics of contributing a new agent, skill, tool, prompt, or instruction.

## Before you start

1. Read `STRUCTURE.md` for naming conventions and frontmatter schemas.
2. Read `AGENCY-MODEL.md` to confirm you're adding the right *kind* of resource.
3. Search the relevant folder for an existing entry that already solves your problem — extend it rather than duplicate it.

## Adding a new resource

### 1. Choose the type

Use the decision tree in `AGENCY-MODEL.md`:

- Persona with methodology → **agent**
- Multi-step procedure → **skill**
- Callable capability → **tool**
- Single-shot parameterized request → **prompt**
- Scoped rule applied by file glob → **instruction**

### 2. Copy the template

| Type         | Copy from                                            | Copy to                                          |
|--------------|------------------------------------------------------|--------------------------------------------------|
| agent        | `agents/_templates/TEMPLATE.agent.md`                | `agents/<your-name>.agent.md`                    |
| skill        | `skills/_templates/example-skill/`                   | `skills/<your-name>/`                            |
| tool         | `tools/_templates/TEMPLATE.tool.md`                  | `tools/<your-name>.tool.md`                      |
| prompt       | `prompts/_templates/TEMPLATE.prompt.md`              | `prompts/<your-name>.prompt.md`                  |
| instruction  | `instructions/_templates/TEMPLATE.instructions.md`   | `instructions/<your-name>.instructions.md`       |

### 3. Fill it in

- For agents, skills, and tools, set `name` in frontmatter to match the file or directory stem. Prompts and instructions have no `name` field; the filename stem is the identifier.
- Write the body following the section structure in the template — don't drop sections, leave them empty if you have nothing useful to add and the section truly doesn't apply.
- Use **second person** ("You are…", "You should…") for agent bodies and instruction bodies. Use **imperative** ("Inventory the root.", "Compose the brief.") for skill procedures.

### 4. Wire it up

- **New agent that uses a skill or tool?** Add the id to the agent's `skills:` / `tools:` list.
- **New skill bundled with code?** Place scripts under `skills/<name>/scripts/` and reference them with relative paths in `SKILL.md`.
- **New tool with a runtime config?** Fill in the `config` block in frontmatter — don't hard-code paths; use `${PROMPTCRAFT_ROOT}` or environment variables.
- **New instruction?** Set `applyTo` to the narrowest correct glob — repo-wide (`**`) is a last resort.

### 5. Check it

Run through this checklist before opening a PR:

- [ ] Filename and directory name are `kebab-case`.
- [ ] Where the schema includes a `name` field (agents, skills, tools), it matches the filename/directory stem.
- [ ] Frontmatter parses as valid YAML.
- [ ] All cross-references resolve (e.g., every id in an agent's `tools:` exists under `tools/`).
- [ ] You linked to the new entry from the parent folder's `README.md` table if your folder maintains one (currently only `STRUCTURE.md` keeps the central seed-example table — update it if the new entry replaces or augments a seed example).
- [ ] No secrets, tokens, or absolute machine-local paths are baked in.
- [ ] You ran the installer in `-DryRun` mode against a scratch directory to confirm nothing in your change broke discovery.

### 6. Document significant changes

- Adding a new resource type or changing a frontmatter schema → update `STRUCTURE.md` and `AGENCY-MODEL.md`.
- Adding a new installer flag or behavior → update `USAGE.md` and `scripts/README.md`.

## Style

- Markdown headings: `#` for the file title, `##` for top-level sections, `###` for subsections. No skipping levels.
- Code blocks always specify a language fence (` ```yaml `, ` ```powershell `, ` ```json `, …).
- Sentence-case headings.
- One blank line between sections; no trailing whitespace.

## Reviewing changes

When reviewing a PR:

- Confirm the new resource is in the right folder (use the decision tree).
- Confirm naming and frontmatter schema compliance.
- Confirm the body is appropriately scoped (no methodology in instructions, no persona in prompts, etc.).
- Confirm the example or seed content is **realistic** — a contributor should be able to read it and build on it.
