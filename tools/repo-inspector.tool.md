---
name: repo-inspector
description: |
  Use this tool to enumerate a local repository's structure, manifest files, and CI
  configuration in a single pass. Call it when an agent needs structured input for
  onboarding, architecture, or dependency-audit workflows and wants to avoid running
  many small shell commands.
type: cli
config:
  command: pwsh
  args_template:
    - -NoProfile
    - -File
    - "${BOTTERYBARN_ROOT}/tools/scripts/repo-inspector.ps1"
    - -RepoPath
    - "{repo_path}"
  # BOTTERYBARN_ROOT should be set by the host/runtime to the absolute path of this BotteryBarn checkout.
inputs:
  - name: repo_path
    description: Absolute path to the repository to inspect.
    required: true
outputs:
  - name: inventory
    description: |
      JSON object with keys: top_level_files, top_level_dirs, manifests (list of
      detected manifest files with type), ci_workflows (paths under .github/workflows),
      monorepo_indicators (list of detected monorepo config files).
---

# repo-inspector

> **Status: contract only.** This entry documents the intended interface. The
> reference implementation at `tools/scripts/repo-inspector.ps1` is currently a
> stub that fails fast with a clear "not implemented" message and exits with
> code 2. Downstream agents may register this tool by id today; an implementer
> can replace the stub later without renaming or rewiring.

## When to use

- The agent needs a structured inventory of an unknown repo before reasoning about it.
- An onboarding or architecture skill (e.g., `repo-onboarding`) is about to start and wants step-1 data in one call.

## When not to use

- For targeted searches within a single file — use a grep tool instead.
- For repositories you have already inspected in this session.

## Examples

### Example 1 — inspect a local clone

Inputs:
```json
{
  "repo_path": "C:/src/my-service"
}
```

Expected output (abbreviated):
```json
{
  "top_level_files": ["README.md", "package.json", "tsconfig.json"],
  "top_level_dirs": ["src", "test", ".github"],
  "manifests": [
    { "path": "package.json", "type": "npm" }
  ],
  "ci_workflows": [".github/workflows/ci.yml"],
  "monorepo_indicators": []
}
```

## Errors and expected conditions

- **`repo_path does not exist`** — verify the path; the tool refuses relative paths.
- **`No manifest detected`** — expected for repos without manifests; `manifests` will be `[]`. Treat the repo as plain source.
