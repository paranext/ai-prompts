<#
.SYNOPSIS
    Setup script for Claude Code configuration symlinks (Windows)

.DESCRIPTION
    This script creates symlinks from the config repo to a target project.
    Equivalent to setup-claude.sh for Windows systems.

.PARAMETER TargetProject
    Path to the target project (e.g., ..\paranext-core)

.PARAMETER NoClaudeMd
    Skip CLAUDE.md symlinks (for legacy codebases like Paratext)

.PARAMETER Update
    Re-run setup for all saved targets

.PARAMETER List
    Show all saved targets

.PARAMETER Remove
    Remove a target from the saved list

.EXAMPLE
    .\setup-claude.ps1 ..\..\paranext-core
    Full setup with CLAUDE.md files

.EXAMPLE
    .\setup-claude.ps1 ..\..\Paratext -NoClaudeMd
    Setup without CLAUDE.md files

.EXAMPLE
    .\setup-claude.ps1 -Update
    Update all previously configured targets

.EXAMPLE
    .\setup-claude.ps1 -List
    List all saved targets
#>

[CmdletBinding(DefaultParameterSetName = 'Setup')]
param(
    [Parameter(ParameterSetName = 'Setup', Position = 0)]
    [string]$TargetProject,

    [Parameter(ParameterSetName = 'Setup')]
    [switch]$NoClaudeMd,

    [Parameter(ParameterSetName = 'Update')]
    [switch]$Update,

    [Parameter(ParameterSetName = 'List')]
    [switch]$List,

    [Parameter(ParameterSetName = 'Remove', Mandatory = $true)]
    [string]$Remove
)

$ErrorActionPreference = 'Stop'
$ConfigRepo = $PSScriptRoot
$TargetsFile = Join-Path $ConfigRepo '.setup-targets'

function Show-Usage {
    Write-Host "Usage: .\setup-claude.ps1 <target-project-path> [-NoClaudeMd]"
    Write-Host "       .\setup-claude.ps1 -Update"
    Write-Host "       .\setup-claude.ps1 -List"
    Write-Host "       .\setup-claude.ps1 -Remove <path>"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -NoClaudeMd    Skip CLAUDE.md symlinks (for legacy codebases)"
    Write-Host "  -Update        Re-run setup for all saved targets"
    Write-Host "  -List          Show all saved targets"
    Write-Host "  -Remove <path> Remove a target from the saved list"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\setup-claude.ps1 ..\paranext-core              # Full setup with CLAUDE.md files"
    Write-Host "  .\setup-claude.ps1 ..\paratext -NoClaudeMd       # Without CLAUDE.md files"
    Write-Host "  .\setup-claude.ps1 -Update                       # Update all targets after git pull"
}

function Test-SymlinkCapability {
    $testTarget = Join-Path $env:TEMP "symlink-target-$(Get-Random)"
    $testLink = Join-Path $env:TEMP "symlink-test-$(Get-Random)"

    try {
        # Create a test directory
        New-Item -ItemType Directory -Path $testTarget -Force | Out-Null

        # Try to create a symlink
        New-Item -ItemType SymbolicLink -Path $testLink -Target $testTarget -ErrorAction Stop | Out-Null

        # Clean up
        Remove-Item $testLink -Force
        Remove-Item $testTarget -Force

        return $true
    }
    catch {
        # Clean up on failure
        if (Test-Path $testTarget) { Remove-Item $testTarget -Force -ErrorAction SilentlyContinue }
        if (Test-Path $testLink) { Remove-Item $testLink -Force -ErrorAction SilentlyContinue }
        return $false
    }
}

function Save-Target {
    param(
        [string]$Path,
        [string]$Flags
    )

    $entries = @()
    if (Test-Path $TargetsFile) {
        $entries = @(Get-Content $TargetsFile | Where-Object {
            $_ -and -not $_.StartsWith("$Path|")
        })
    }

    $entries += "$Path|$Flags"
    $entries | Set-Content $TargetsFile -Encoding UTF8
}

function New-SymlinkWithBackup {
    param(
        [string]$Source,
        [string]$Target
    )

    $name = Split-Path $Target -Leaf

    if (-not (Test-Path $Source)) {
        Write-Host "  Skipping $name (not found in config repo)" -ForegroundColor Yellow
        return
    }

    # Ensure parent directory exists
    $parentDir = Split-Path $Target -Parent
    if ($parentDir -and -not (Test-Path $parentDir)) {
        Write-Host "  Skipping $name (target directory does not exist: $parentDir)" -ForegroundColor Yellow
        return
    }

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force

        if ($item.LinkType -eq 'SymbolicLink') {
            Write-Host "  Updating $name (replacing existing symlink)"
            Remove-Item $Target -Force
        }
        else {
            $backupPath = "$Target.backup"
            Write-Host "  Backing up existing $name to $name.backup"
            Move-Item $Target $backupPath -Force
        }
    }

    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    Write-Host "  $([char]0x2713) Linked $name" -ForegroundColor Green
}

function Invoke-Setup {
    param(
        [string]$TargetPath,
        [switch]$SkipClaudeMd
    )

    Write-Host "Setting up Claude Code symlinks..."
    Write-Host "Config repo: $ConfigRepo"
    Write-Host "Target project: $TargetPath"
    Write-Host ""

    # Root configuration
    Write-Host "Root configuration:"
    New-SymlinkWithBackup -Source (Join-Path $ConfigRepo '.claude') -Target (Join-Path $TargetPath '.claude')
    New-SymlinkWithBackup -Source (Join-Path $ConfigRepo '.context') -Target (Join-Path $TargetPath '.context')

    if (-not $SkipClaudeMd) {
        New-SymlinkWithBackup -Source (Join-Path $ConfigRepo 'claude-md\CLAUDE.md') -Target (Join-Path $TargetPath 'CLAUDE.md')

        Write-Host ""
        Write-Host "Subdirectory CLAUDE.md files:"
        New-SymlinkWithBackup -Source (Join-Path $ConfigRepo 'claude-md\c-sharp\CLAUDE.md') -Target (Join-Path $TargetPath 'c-sharp\CLAUDE.md')
        New-SymlinkWithBackup -Source (Join-Path $ConfigRepo 'claude-md\extension-host\CLAUDE.md') -Target (Join-Path $TargetPath 'src\extension-host\CLAUDE.md')
        New-SymlinkWithBackup -Source (Join-Path $ConfigRepo 'claude-md\platform-bible-react\CLAUDE.md') -Target (Join-Path $TargetPath 'lib\platform-bible-react\CLAUDE.md')
        New-SymlinkWithBackup -Source (Join-Path $ConfigRepo 'claude-md\extensions\CLAUDE.md') -Target (Join-Path $TargetPath 'extensions\CLAUDE.md')
    }
    else {
        Write-Host ""
        Write-Host "Skipping CLAUDE.md files (-NoClaudeMd flag)"
    }

    Write-Host ""
    Write-Host "Done! Claude Code configuration is now linked." -ForegroundColor Green
    Write-Host ""

    # Check prerequisites
    Write-Host "Checking prerequisites..."
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        Write-Host "  $([char]0x2713) Worktrunk is installed" -ForegroundColor Green
    }
    else {
        Write-Host "  $([char]0x26A0) Worktrunk not found - required for git-worktree skill" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Install Worktrunk for parallel agent development:"
        Write-Host "    winget install worktrunk.wt"
        Write-Host "    # OR via Scoop: scoop install wt"
        Write-Host ""
        Write-Host "  See: https://worktrunk.dev/"
    }
    Write-Host ""

    # .gitignore reminder
    Write-Host "Note: Make sure these are in the target project's .gitignore:"
    Write-Host "  .claude"
    Write-Host "  .context"
    if (-not $SkipClaudeMd) {
        Write-Host "  CLAUDE.md"
        Write-Host "  c-sharp/CLAUDE.md"
        Write-Host "  src/extension-host/CLAUDE.md"
        Write-Host "  lib/platform-bible-react/CLAUDE.md"
        Write-Host "  extensions/CLAUDE.md"
    }
}

# Main execution

# Check symlink capability first (except for List operation)
if (-not $List) {
    if (-not (Test-SymlinkCapability)) {
        Write-Host "ERROR: Cannot create symbolic links." -ForegroundColor Red
        Write-Host ""
        Write-Host "To fix this, either:" -ForegroundColor Yellow
        Write-Host "  1. Enable Developer Mode:" -ForegroundColor Yellow
        Write-Host "     Settings > Update & Security > For developers > Developer Mode" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  2. OR run PowerShell as Administrator" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
}

switch ($PSCmdlet.ParameterSetName) {
    'List' {
        if (-not (Test-Path $TargetsFile)) {
            Write-Host "No saved targets."
            exit 0
        }

        $content = Get-Content $TargetsFile | Where-Object { $_ }
        if (-not $content) {
            Write-Host "No saved targets."
            exit 0
        }

        Write-Host "Saved targets:"
        $content | ForEach-Object {
            $parts = $_ -split '\|', 2
            $path = $parts[0]
            $flags = if ($parts.Length -gt 1 -and $parts[1]) { $parts[1] } else { $null }

            if ($flags) {
                Write-Host "  $path ($flags)"
            }
            else {
                Write-Host "  $path"
            }
        }
    }

    'Remove' {
        # Resolve to absolute path
        $removePath = $Remove
        if (Test-Path $Remove) {
            $removePath = (Resolve-Path $Remove).Path
        }
        else {
            Write-Host "ERROR: Path not found: $Remove" -ForegroundColor Red
            exit 1
        }

        if (-not (Test-Path $TargetsFile)) {
            Write-Host "No saved targets."
            exit 0
        }

        $originalContent = Get-Content $TargetsFile | Where-Object { $_ }
        $remaining = $originalContent | Where-Object {
            -not $_.StartsWith("$removePath|")
        }

        if ($remaining.Count -eq $originalContent.Count) {
            Write-Host "Target not found: $removePath" -ForegroundColor Red
            exit 1
        }

        if ($remaining) {
            $remaining | Set-Content $TargetsFile -Encoding UTF8
        }
        else {
            Remove-Item $TargetsFile -Force
        }
        Write-Host "Removed: $removePath"
    }

    'Update' {
        if (-not (Test-Path $TargetsFile)) {
            Write-Host "No saved targets. Run setup with a target path first."
            exit 1
        }

        $content = Get-Content $TargetsFile | Where-Object { $_ }
        if (-not $content) {
            Write-Host "No saved targets. Run setup with a target path first."
            exit 1
        }

        Write-Host "Updating all saved targets..."
        Write-Host ""

        $content | ForEach-Object {
            $parts = $_ -split '\|', 2
            $path = $parts[0]
            $flags = if ($parts.Length -gt 1) { $parts[1] } else { '' }

            if (Test-Path $path -PathType Container) {
                Write-Host ("=" * 60)
                $skipClaudeMd = $flags -eq '--no-claude-md'
                Invoke-Setup -TargetPath $path -SkipClaudeMd:$skipClaudeMd
                Write-Host ""
            }
            else {
                Write-Host "Warning: Skipping $path (directory not found)" -ForegroundColor Yellow
            }
        }

        Write-Host "All targets updated!" -ForegroundColor Green
    }

    'Setup' {
        if (-not $TargetProject) {
            Show-Usage
            exit 1
        }

        # Resolve to absolute path
        if (-not (Test-Path $TargetProject -PathType Container)) {
            Write-Host "ERROR: Target directory not found: $TargetProject" -ForegroundColor Red
            exit 1
        }

        $targetPath = (Resolve-Path $TargetProject).Path
        $flags = if ($NoClaudeMd) { '--no-claude-md' } else { '' }

        Save-Target -Path $targetPath -Flags $flags
        Invoke-Setup -TargetPath $targetPath -SkipClaudeMd:$NoClaudeMd
    }
}
