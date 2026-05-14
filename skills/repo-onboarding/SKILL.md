---
name: repo-onboarding
description: |
  Use this skill to produce a concise onboarding document for an unfamiliar repository.
  Trigger when a user has just cloned a repo and asks "where do I start?" or "explain
  this codebase". Outputs a markdown brief covering stack, components, build/test/dev
  commands, and a recommended learning path.
version: 0.1.0
inputs:
  - name: repo_path
    description: Absolute path to the repository to analyze.
outputs:
  - name: onboarding_doc
    description: Markdown document with the sections listed under "Output" below.
---

# repo-onboarding

## Purpose

Given a local repository path, produce a single-page markdown brief that lets a new contributor become productive without reading every file.

## Preconditions

- The user has supplied an absolute `repo_path` that exists locally.
- You have read access to the repo and can run shell commands within it.

## Procedure

1. **Inventory the root.** List the top-level files and directories. Note the presence of `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `*.sln`, `Makefile`, `Dockerfile`, `.github/workflows/`, and any monorepo indicators (`pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json`).
2. **Classify the project.** From step 1, identify: project type (library / app / service / CLI / monorepo), primary language(s), framework(s), and package manager.
3. **Locate entry points.** Search for `main`, `index`, `cmd/`, `bin/`, or framework-specific entry points (e.g., `app.py`, `server.ts`, `Program.cs`).
4. **Map components.** Walk the source directory one level deep. Cluster siblings by responsibility (API, domain, data, UI, infra, tests). Capture the cluster name and a one-line description per cluster.
5. **Trace dependencies.** Use the manifest from step 1 to list the top 5–10 production dependencies and what each is for.
6. **Extract dev/build/test commands.** From the manifest's scripts section (or `Makefile`/`taskfile.yml`/CI workflow), capture the canonical commands for: install, dev, build, test, lint.
7. **Identify CI signals.** Open `.github/workflows/*.yml` (or other CI config) and note which workflows run on PR vs. main.
8. **Compose the brief** in the structure under "Output" below. Keep each section to ≤5 bullets.

## Output

A single markdown document with these sections, in order:

- **Overview** — 1–2 sentence project summary
- **Stack** — language, framework, package manager
- **Architecture pattern** — one phrase (e.g., "layered MVC", "hexagonal", "monorepo of services")
- **Main components** — bulleted, ≤5
- **Key files** — `path/to/file` — why it matters
- **Dev setup** — exact commands
- **Build / Test / Lint** — exact commands
- **CI** — what runs when
- **Recommended learning path** — ordered list of files/directories to read

## References

- The companion `codebase-architecture-guide` agent (see `agents/codebase-architecture-guide.agent.md`) wraps this skill with conversational behavior and output-format guarantees.
