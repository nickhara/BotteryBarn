#Requires -Version 7.0
<#
.SYNOPSIS
    Remove PromptCraft symlinks from a target repository.

.DESCRIPTION
    For each folder in -Folders (default: agents, skills, tools, prompts,
    instructions), inspects <TargetPath>/<folder> and removes it ONLY IF it is
    a symlink that points back into this PromptCraft repo. Real directories
    and unrelated symlinks are left untouched.

.PARAMETER TargetPath
    Path to the consuming repo's root directory. Required.

.PARAMETER Folders
    Subset of folders to consider. Default: agents, skills, tools, prompts, instructions.

.PARAMETER DryRun
    Print the planned actions without executing them. Alias for -WhatIf.

.EXAMPLE
    ./Uninstall-PromptCraft.ps1 -TargetPath C:\src\my-repo

.EXAMPLE
    ./Uninstall-PromptCraft.ps1 -TargetPath C:\src\my-repo -Folders prompts -DryRun

.NOTES
    Backup files left behind by Install-PromptCraft.ps1 (named
    <folder>.promptcraft-backup) are NOT touched by this script; restore or
    delete them manually as needed.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $TargetPath,

    [Parameter()]
    [ValidateSet('agents', 'skills', 'tools', 'prompts', 'instructions')]
    [string[]] $Folders = @('agents', 'skills', 'tools', 'prompts', 'instructions'),

    [Parameter()]
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($DryRun) {
    $WhatIfPreference = $true
}

function Get-PromptCraftRoot {
    $scriptDir = Split-Path -Parent $PSCommandPath
    return (Resolve-Path (Join-Path $scriptDir '..')).ProviderPath
}

function Test-SymlinkPointsInto {
    param(
        [Parameter(Mandatory)] [System.IO.FileSystemInfo] $Item,
        [Parameter(Mandatory)] [string] $ExpectedRoot
    )

    $target = $Item.Target
    if (-not $target) { return $false }
    $candidate = if ($target -is [System.Array]) { $target[0] } else { $target }
    if (-not $candidate) { return $false }

    $linkParent = Split-Path -Parent $Item.FullName
    try {
        if ([System.IO.Path]::IsPathRooted($candidate)) {
            $resolvedCandidate = $candidate
        } else {
            $resolvedCandidate = Join-Path $linkParent $candidate
        }
        # Normalize without requiring the target to exist (handles dangling links).
        $resolved = [System.IO.Path]::GetFullPath($resolvedCandidate)
    } catch {
        return $false
    }

    $expectedRootResolved = (Resolve-Path -LiteralPath $ExpectedRoot -ErrorAction Stop).ProviderPath
    $resolvedTrim = [System.IO.Path]::TrimEndingDirectorySeparator($resolved)
    $rootTrim     = [System.IO.Path]::TrimEndingDirectorySeparator($expectedRootResolved)

    # Equal-to-root, or strictly under root.
    if ($resolvedTrim -ieq $rootTrim) { return $true }
    return $resolvedTrim.StartsWith($rootTrim + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-ExistingEntry {
    # Returns the FileSystemInfo for $Path if anything exists there (including a
    # symlink whose target is missing — Test-Path -LiteralPath reports those as
    # absent on Windows/PS7), or $null otherwise.
    param(
        [Parameter(Mandatory)] [string] $Path
    )

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($item) { return $item }

    $parent = Split-Path -Parent $Path
    $leaf   = Split-Path -Leaf   $Path
    if (-not $parent -or -not (Test-Path -LiteralPath $parent -PathType Container)) {
        return $null
    }
    return Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ieq $leaf } |
        Select-Object -First 1
}

# ----- main -----

$promptCraftRoot = Get-PromptCraftRoot
Write-Host "PromptCraft root : $promptCraftRoot"

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    throw "TargetPath does not exist or is not a directory: $TargetPath"
}
$resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).ProviderPath
Write-Host "Target repo      : $resolvedTarget"
Write-Host "Folders          : $($Folders -join ', ')"
if ($DryRun) { Write-Host "Mode             : DRY RUN (no changes will be made)" -ForegroundColor Yellow }
Write-Host ""

$summary = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($folder in $Folders) {
    $link = Join-Path $resolvedTarget $folder

    $item = Get-ExistingEntry -Path $link
    if (-not $item) {
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (absent)'; Detail = $link })
        continue
    }

    $isSymlink = $item.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)

    if (-not $isSymlink) {
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (real directory, untouched)'; Detail = $link })
        continue
    }

    if (-not (Test-SymlinkPointsInto -Item $item -ExpectedRoot $promptCraftRoot)) {
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'skipped (link points elsewhere)'; Detail = "$link -> $($item.Target)" })
        continue
    }

    if ($PSCmdlet.ShouldProcess($link, 'Remove PromptCraft symlink')) {
        Remove-Item -LiteralPath $link -Force
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'removed'; Detail = $link })
    } else {
        $summary.Add([pscustomobject]@{ Folder = $folder; Action = 'would remove (dry run)'; Detail = $link })
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
$summary | Format-Table -AutoSize
