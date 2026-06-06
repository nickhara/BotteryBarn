#Requires -Version 7.0
<#
.SYNOPSIS
    Install BotteryBarn into a target repository by creating directory symlinks.

.DESCRIPTION
    Creates directory symlinks at <TargetPath>/<folder> pointing at this BotteryBarn
    repo's <folder>, for each folder in -Folders (default: agents, skills, tools,
    prompts, instructions).

    Idempotent: if a symlink already points at the correct source, it is left in
    place. Refuses to overwrite real (non-symlink) directories unless -Force is
    supplied, in which case the existing entry is renamed to
    <name>.botterybarn-backup before linking.

    On Windows, symlink creation requires either Developer Mode or an elevated
    (admin) shell. The script detects this and prints actionable guidance.

.PARAMETER TargetPath
    Path to the consuming repo's root directory. Required.

.PARAMETER Folders
    Subset of folders to link. Default: agents, skills, tools, prompts, instructions.
    Only folders that exist in this BotteryBarn repo are linked; missing source
    folders are reported and skipped.

.PARAMETER Force
    Replace existing entries at the target. Real directories are renamed to
    <name>.botterybarn-backup; mismatched symlinks are removed and recreated.

.PARAMETER Relative
    Create relative-path symlinks (computed from <TargetPath> to this repo).
    Useful when BotteryBarn and the target repo are siblings that may move
    together.

.PARAMETER DryRun
    Print the planned actions without executing them. Alias for -WhatIf.

.EXAMPLE
    ./Install-BotteryBarn.ps1 -TargetPath C:\src\my-repo

    Installs all five top-level folders into C:\src\my-repo.

.EXAMPLE
    ./Install-BotteryBarn.ps1 -TargetPath ..\my-repo -Folders agents,prompts -Relative

    Installs only agents and prompts, using relative-path symlinks.

.EXAMPLE
    ./Install-BotteryBarn.ps1 -TargetPath C:\src\my-repo -DryRun

    Shows what would happen without making changes.

.NOTES
    See ../docs/USAGE.md for end-user documentation.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $TargetPath,

    [Parameter()]
    [ValidateSet('agents', 'skills', 'tools', 'prompts', 'instructions')]
    [string[]] $Folders = @('agents', 'skills', 'tools', 'prompts', 'instructions'),

    [Parameter()]
    [switch] $Force,

    [Parameter()]
    [switch] $Relative,

    [Parameter()]
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Treat -DryRun as -WhatIf for downstream cmdlets and our own gating.
if ($DryRun) {
    $WhatIfPreference = $true
}

function Get-BotteryBarnRoot {
    # scripts/ lives directly under the repo root.
    $scriptDir = Split-Path -Parent $PSCommandPath
    return (Resolve-Path (Join-Path $scriptDir '..')).ProviderPath
}

function Test-WindowsSymlinkCapability {
    if (-not $IsWindows) {
        return $true
    }

    # Admin?
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    if ($principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $true
    }

    # Developer Mode?
    $devModeKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    try {
        $value = Get-ItemPropertyValue -Path $devModeKey -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction Stop
        if ($value -eq 1) { return $true }
    } catch {
        # Key or value missing — treat as "not enabled".
    }

    return $false
}

function Resolve-LinkValue {
    param(
        [Parameter(Mandatory)] [string] $SourcePath,
        [Parameter(Mandatory)] [string] $LinkPath,
        [Parameter(Mandatory)] [bool]   $UseRelative
    )

    if (-not $UseRelative) {
        return $SourcePath
    }

    $linkParent = Split-Path -Parent $LinkPath
    if (-not $linkParent) { $linkParent = (Get-Location).Path }
    return [System.IO.Path]::GetRelativePath($linkParent, $SourcePath)
}

function Test-SymlinkPointsTo {
    param(
        [Parameter(Mandatory)] [System.IO.FileSystemInfo] $Item,
        [Parameter(Mandatory)] [string] $ExpectedPath
    )

    # $Item.Target is a string[] in PS 7 for symlinks.
    $target = $Item.Target
    if (-not $target) { return $false }
    $candidate = if ($target -is [System.Array]) { $target[0] } else { $target }
    if (-not $candidate) { return $false }

    # Resolve the symlink's recorded target relative to the link's parent directory.
    $linkParent = Split-Path -Parent $Item.FullName
    try {
        if ([System.IO.Path]::IsPathRooted($candidate)) {
            $resolved = (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).ProviderPath
        } else {
            $resolved = (Resolve-Path -LiteralPath (Join-Path $linkParent $candidate) -ErrorAction Stop).ProviderPath
        }
    } catch {
        return $false
    }

    $expected = (Resolve-Path -LiteralPath $ExpectedPath -ErrorAction Stop).ProviderPath
    $resolvedTrim = [System.IO.Path]::TrimEndingDirectorySeparator($resolved)
    $expectedTrim = [System.IO.Path]::TrimEndingDirectorySeparator($expected)
    if ($IsWindows) {
        return ($resolvedTrim -ieq $expectedTrim)
    }
    return ($resolvedTrim -ceq $expectedTrim)
}

function Get-ExistingEntry {
    # Returns the FileSystemInfo for $LiteralPath if anything exists there (including
    # a symlink whose target is missing — which Test-Path -LiteralPath reports as
    # absent on Windows/PS7), or $null otherwise.
    param(
        [Parameter(Mandatory)] [string] $LiteralPath
    )

    $item = Get-Item -LiteralPath $LiteralPath -Force -ErrorAction SilentlyContinue
    if ($item) { return $item }

    # Fallback: enumerate the parent directory so we can see a dangling reparse
    # point that Get-Item refuses to materialize (Windows only).
    if (-not $IsWindows) { return $null }

    $parent = Split-Path -Parent $LiteralPath
    $leaf   = Split-Path -Leaf   $LiteralPath
    if (-not $parent -or -not (Test-Path -LiteralPath $parent -PathType Container)) {
        return $null
    }
    return Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ieq $leaf } |
        Select-Object -First 1
}

# ----- main -----

$botteryBarnRoot = Get-BotteryBarnRoot
Write-Host "BotteryBarn root : $botteryBarnRoot"

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    throw "TargetPath does not exist or is not a directory: $TargetPath"
}
$resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).ProviderPath
Write-Host "Target repo      : $resolvedTarget"
Write-Host "Folders          : $($Folders -join ', ')"
if ($Relative) { Write-Host "Mode             : relative-path symlinks" }
if ($DryRun)   { Write-Host "Mode             : DRY RUN (no changes will be made)" -ForegroundColor Yellow }
Write-Host ""

if (-not (Test-WindowsSymlinkCapability)) {
    $msg = @"
This Windows session cannot create symlinks without elevation.
Either:
  - Enable Developer Mode (Settings -> Privacy & security -> For developers), or
  - Re-run this script from an elevated PowerShell.
"@
    if ($WhatIfPreference) {
        Write-Warning ($msg + "`nContinuing because -DryRun/-WhatIf was specified; no changes will be made.")
    } else {
        throw ($msg + "`nAborting.")
    }
}

$summary = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($folder in $Folders) {
    $source = Join-Path $botteryBarnRoot $folder
    $link   = Join-Path $resolvedTarget $folder

    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (no source)'; Detail = $source })
        continue
    }

    $linkValue = Resolve-LinkValue -SourcePath $source -LinkPath $link -UseRelative:$Relative.IsPresent

    $existing = Get-ExistingEntry -LiteralPath $link
    $plannedPreRemoval = $null   # tracks dry-run preview for the pre-removal step
    if ($existing) {
        $isSymlink = $existing.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)

        if ($isSymlink) {
            $pointsHere = $false
            try { $pointsHere = Test-SymlinkPointsTo -Item $existing -ExpectedPath $source } catch { $pointsHere = $false }

            if ($pointsHere) {
                $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (already linked)'; Detail = $link })
                continue
            }
            # Mismatched OR dangling symlink — both refuse without -Force.
            $existingTarget = if ($existing.Target) {
                if ($existing.Target -is [System.Array]) { $existing.Target[0] } else { $existing.Target }
            } else { '<unreadable>' }
            if (-not $Force) {
                $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'BLOCKED (wrong/dangling link, use -Force)'; Detail = "$link -> $existingTarget" })
                continue
            }
            if ($PSCmdlet.ShouldProcess($link, 'Remove mismatched/dangling symlink')) {
                Remove-Item -LiteralPath $link -Force
            } elseif ($WhatIfPreference) {
                $plannedPreRemoval = [pscustomobject]@{ Folder = $folder; Action = 'would remove (dry run)'; Detail = "$link -> $existingTarget" }
            } else {
                $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (confirmation declined)'; Detail = $link })
                continue
            }
        } else {
            if (-not $Force) {
                $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'BLOCKED (real dir/file present, use -Force)'; Detail = $link })
                continue
            }
            $backup = "$link.botterybarn-backup"
            if (Get-ExistingEntry -LiteralPath $backup) {
                $backup = "$link.botterybarn-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
            }
            if ($PSCmdlet.ShouldProcess($link, "Rename existing entry to $backup")) {
                Move-Item -LiteralPath $link -Destination $backup
            } elseif ($WhatIfPreference) {
                $plannedPreRemoval = [pscustomobject]@{ Folder = $folder; Action = 'would rename (dry run)'; Detail = "$link -> $backup" }
            } else {
                $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (confirmation declined)'; Detail = $link })
                continue
            }
        }
    }

    if ($PSCmdlet.ShouldProcess($link, "Create symlink -> $linkValue")) {
        New-Item -ItemType SymbolicLink -Path $link -Target $linkValue | Out-Null
        if ($plannedPreRemoval) { $summary.Add($plannedPreRemoval) }
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'linked'; Detail = "$link -> $linkValue" })
    } elseif ($WhatIfPreference) {
        if ($plannedPreRemoval) { $summary.Add($plannedPreRemoval) }
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'would link (dry run)'; Detail = "$link -> $linkValue" })
    } else {
        if ($plannedPreRemoval) { $summary.Add($plannedPreRemoval) }
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (confirmation declined)'; Detail = "$link -> $linkValue" })
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
$summary | Format-Table -AutoSize
