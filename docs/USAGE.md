# Usage

This document explains how to consume BotteryBarn from another repository on your machine.

## What you get

BotteryBarn is an **ecosystem-neutral library** of agents, skills, tools, prompts, and instructions. You install it into a target repo by symlinking selected folders, so updates to BotteryBarn are immediately visible in every repo that uses it.

The BotteryBarn installer creates symlinks for **generic top-level folders only**:

```text
<target-repo>/
├── agents/        → <BotteryBarn>/agents/
├── skills/        → <BotteryBarn>/skills/
├── tools/         → <BotteryBarn>/tools/
├── prompts/       → <BotteryBarn>/prompts/
└── instructions/  → <BotteryBarn>/instructions/
```

If you want ecosystem-specific surfaces (e.g., `.github/agents/` for GitHub Copilot, `.claude/agents/` for Claude Code), add those symlinks yourself on top — see [Ecosystem-specific overlays](#ecosystem-specific-overlays-optional) below.

## Prerequisites

- **PowerShell 7.0 or later** (cross-platform — works on Windows, macOS, and Linux).
- **Symlink permissions:**
  - **Windows:** Enable [Developer Mode](https://learn.microsoft.com/windows/apps/get-started/enable-your-device-for-development) (Settings → Privacy & security → For developers → Developer Mode), or run the installer from an elevated (admin) PowerShell.
  - **macOS / Linux:** No special configuration needed.

Check your PowerShell version:

```powershell
$PSVersionTable.PSVersion
```

## Install

From any directory:

```powershell
cd <path-to-BotteryBarn>
./scripts/Install-BotteryBarn.ps1 -TargetPath <path-to-target-repo>
```

This creates directory symlinks for all five top-level folders in the target repo.

### Common options

```powershell
# Install only a subset of folders
./scripts/Install-BotteryBarn.ps1 -TargetPath C:\src\my-repo -Folders agents,prompts

# Preview without making changes
./scripts/Install-BotteryBarn.ps1 -TargetPath C:\src\my-repo -DryRun

# Replace existing entries at the target (use with care)
./scripts/Install-BotteryBarn.ps1 -TargetPath C:\src\my-repo -Force

# Create relative-path symlinks (recommended if BotteryBarn lives next to your target repo)
./scripts/Install-BotteryBarn.ps1 -TargetPath ..\my-repo -Relative
```

### Idempotency

Running the installer twice is safe. If a symlink already points at the correct BotteryBarn folder, it is left in place and reported as `skipped`. If a real (non-symlink) directory exists at the target path, the installer refuses to touch it unless you pass `-Force`.

## Uninstall

```powershell
./scripts/Uninstall-BotteryBarn.ps1 -TargetPath <path-to-target-repo>
```

For safety, the uninstaller only removes entries at the target that are symlinks **and** point back into this BotteryBarn repo. Anything else is left alone.

Options:

```powershell
# Remove only specific folders
./scripts/Uninstall-BotteryBarn.ps1 -TargetPath C:\src\my-repo -Folders prompts

# Preview without making changes
./scripts/Uninstall-BotteryBarn.ps1 -TargetPath C:\src\my-repo -DryRun
```

## Verify

After install, confirm the symlinks resolve correctly:

```powershell
Get-Item <target-repo>\agents |
    Select-Object FullName, @{ Name = 'Target'; Expression = { $_.Target -join ', ' } }
```

You should see `Target` pointing at `<BotteryBarn>\agents`.

## Updating BotteryBarn

Because the consumer repo uses symlinks, you don't need to re-run the installer to pick up changes. Just `git pull` inside the BotteryBarn repo and the new files are visible everywhere it's linked.

## Ecosystem-specific overlays (optional)

If a particular tool expects content under an ecosystem-specific path, add a second symlink layer in the target repo. Examples:

```powershell
# GitHub Copilot surfaces
New-Item -ItemType SymbolicLink -Path .github/agents       -Target ../agents
New-Item -ItemType SymbolicLink -Path .github/prompts      -Target ../prompts
New-Item -ItemType SymbolicLink -Path .github/instructions -Target ../instructions

# Claude Code surfaces
New-Item -ItemType SymbolicLink -Path .claude/agents       -Target ../agents
New-Item -ItemType SymbolicLink -Path .claude/skills       -Target ../skills
```

These overlays live in the consuming repo's git history (they are real symlinks committed to the repo) and are intentionally out of scope for the BotteryBarn installer.

## Troubleshooting

### "A required privilege is not held by the client" (Windows)

Symlink creation failed. Either:
- Enable Developer Mode, **or**
- Re-run the installer from an elevated PowerShell.

### "The term '...' is not recognized" or version errors

Your PowerShell is too old. BotteryBarn requires PowerShell 7+. Install from <https://aka.ms/powershell>.

### The installer reports `skipped (already linked)`

That's the success state for an already-installed folder. No action needed.

### A real directory blocks installation

The installer refuses to overwrite real directories. Either move/delete the directory yourself, or re-run with `-Force` (which moves the existing entry to `<name>.botterybarn-backup` before linking).

### My target repo's `.gitignore` doesn't ignore the new folders

That's intentional — the consuming repo decides whether to commit symlinks or ignore them. To ignore:

```gitignore
# BotteryBarn symlinks (not tracked in this repo)
/agents
/skills
/tools
/prompts
/instructions
```

To commit them, leave `.gitignore` alone; git will record the symlink targets.
