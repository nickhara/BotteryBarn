# scripts/

Automation for installing BotteryBarn into another repository.

All scripts require **PowerShell 7.0 or later** and run cross-platform (Windows, macOS, Linux).

## Scripts

| Script                          | Purpose                                                                                  |
|---------------------------------|------------------------------------------------------------------------------------------|
| `Install-BotteryBarn.ps1`       | Creates directory symlinks in a target repo pointing at this BotteryBarn repo's folders. |
| `Uninstall-BotteryBarn.ps1`     | Removes symlinks created by `Install-BotteryBarn.ps1` (only if they still point here).   |

For the full end-user workflow, see `../docs/USAGE.md`.

## Quickstart

```powershell
# From the BotteryBarn repo root:
./scripts/Install-BotteryBarn.ps1 -TargetPath <path-to-target-repo>

# Preview first:
./scripts/Install-BotteryBarn.ps1 -TargetPath <path-to-target-repo> -DryRun

# Uninstall:
./scripts/Uninstall-BotteryBarn.ps1 -TargetPath <path-to-target-repo>
```

## Help

Both scripts support `Get-Help`:

```powershell
Get-Help ./scripts/Install-BotteryBarn.ps1 -Full
Get-Help ./scripts/Uninstall-BotteryBarn.ps1 -Full
```
