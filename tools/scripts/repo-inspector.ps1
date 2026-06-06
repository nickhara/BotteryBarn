#Requires -Version 7.0

<#
.SYNOPSIS
    Stub reference implementation for the `repo-inspector` tool contract.

.DESCRIPTION
    The `repo-inspector` tool is documented at tools/repo-inspector.tool.md as
    "contract only" — the documented interface exists so downstream agents can
    register the tool today, but the real implementation is deferred to a
    future BotteryBarn release.

    This stub exists so that any runtime that *executes* the registered config
    fails fast with a clear, actionable message instead of throwing an opaque
    "file not found" or producing garbage output. It always exits non-zero.

.PARAMETER RepoPath
    Accepted to match the documented contract; ignored by the stub.

.EXAMPLE
    pwsh -NoProfile -File tools/scripts/repo-inspector.ps1 -RepoPath C:\src\foo
    # -> writes an error to stderr and exits with code 2.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string] $RepoPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$message = @"
repo-inspector is not implemented in this release of BotteryBarn.

The tool contract at tools/repo-inspector.tool.md documents the intended
interface so downstream agents can register the tool by id today. The
reference implementation script has not yet been written.

To implement it, replace this stub with a script that:
  - accepts -RepoPath <absolute path>
  - emits a JSON object on stdout with the keys documented in
    tools/repo-inspector.tool.md (top_level_files, top_level_dirs,
    manifests, ci_workflows, monorepo_indicators).

Exiting non-zero so callers do not consume empty/invalid output as success.
"@

[Console]::Error.WriteLine($message)
exit 2
