# scripts/

Automation for installing PromptCraft into another repository.

All scripts require **PowerShell 7.0 or later** and run cross-platform (Windows, macOS, Linux).

## Scripts

| Script                          | Purpose                                                                                  |
|---------------------------------|------------------------------------------------------------------------------------------|
| `Install-PromptCraft.ps1`       | Creates directory symlinks in a target repo pointing at this PromptCraft repo's folders. |
| `Uninstall-PromptCraft.ps1`     | Removes symlinks created by `Install-PromptCraft.ps1` (only if they still point here).   |

For the full end-user workflow, see `../docs/USAGE.md`.

## Quickstart

```powershell
# From the PromptCraft repo root:
./scripts/Install-PromptCraft.ps1 -TargetPath <path-to-target-repo>

# Preview first:
./scripts/Install-PromptCraft.ps1 -TargetPath <path-to-target-repo> -DryRun

# Uninstall:
./scripts/Uninstall-PromptCraft.ps1 -TargetPath <path-to-target-repo>
```

## Help

Both scripts support `Get-Help`:

```powershell
Get-Help ./scripts/Install-PromptCraft.ps1 -Full
Get-Help ./scripts/Uninstall-PromptCraft.ps1 -Full
```
