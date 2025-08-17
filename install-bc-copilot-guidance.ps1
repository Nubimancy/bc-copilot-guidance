<#!
.SYNOPSIS
Plug-and-play installer that wires Copilot guidance compliance into a BC repo with one command.

.DESCRIPTION
Sets up lightweight, non-invasive hooks so agents discover and follow centralized guidance:
- Creates .github/copilot-instructions.md shim pointing to copilot-guidance/copilot-instructions.md
- Adds ai-guidance.json (machine-readable mustRead policy)
- Nudges VS Code to open README on startup (non-blocking)
- Adds a soft PR checklist acknowledgment

Optional (opt-in flags):
-EnableCI: Adds a GitHub Action that requires the PR checkbox to be ticked
-AnnotateAL: Prepends a one-line comment to .al files reminding agents to read the guidance
-Force: Overwrite existing files created by the installer
-DryRun: Print intended changes without writing files

.PARAMETER ProjectRoot
Root of the target project. Defaults to repo root (one level above this script).

.PARAMETER GuidancePath
Relative path to the guidance folder. Default: copilot-guidance

.PARAMETER DryRun
Preview changes without writing files.

.PARAMETER Force
Overwrite files this script manages if they already exist.

.PARAMETER EnableCI
Create a minimal GitHub Action that enforces PR acknowledgment.

.PARAMETER AnnotateAL
Prepend a one-line comment to .al files reminding agents to read instructions first.

.EXAMPLE
pwsh -File ./scripts/install-bc-copilot-guidance.ps1 -DryRun
Preview all changes without modifying files.

.EXAMPLE
pwsh -File ./scripts/install-bc-copilot-guidance.ps1
Apply default, non-invasive hooks.

.EXAMPLE
pwsh -File ./scripts/install-bc-copilot-guidance.ps1 -EnableCI -AnnotateAL
Enable stricter PR gate and annotate AL files with a one-line reminder.

.NOTES
- Safe to re-run; use -Force to overwrite managed files.
- Keeps canonical rules in copilot-guidance; shims only point there.
#>
param(
    [string]$ProjectRoot,
    [string]$GuidancePath = 'copilot-guidance',
    [switch]$DryRun,
    [switch]$Force,
    [switch]$EnableCI,
    [switch]$AnnotateAL
)

$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host "[bc-copilot] $msg" -ForegroundColor Cyan }
function Write-Change($msg) { Write-Host "  - $msg" -ForegroundColor Green }
function Ensure-Dir([string]$Path) {
    if ($DryRun) { Write-Change "Would ensure directory: $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null }
}
function Ensure-File([string]$Path, [string]$Content) {
    if (Test-Path -LiteralPath $Path) {
        if (-not $Force) { Write-Change "Exists, skipping: $Path"; return }
        if ($DryRun) { Write-Change "Would overwrite: $Path"; return }
        Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
        Write-Change "Overwritten: $Path"
        return
    }
    if ($DryRun) { Write-Change "Would create: $Path"; return }
    $parent = Split-Path -Parent $Path
    Ensure-Dir $parent
    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    Write-Change "Created: $Path"
}
function Merge-SettingsJson([string]$Path, [hashtable]$Fragment) {
    $existing = @{}
    if (Test-Path -LiteralPath $Path) {
        try { $existing = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable } catch { $existing = @{} }
    }
    $changed = $false
    foreach ($k in $Fragment.Keys) {
        if (-not $existing.ContainsKey($k) -or $existing[$k] -ne $Fragment[$k]) {
            $existing[$k] = $Fragment[$k]
            $changed = $true
        }
    }
    if (-not $changed -and (Test-Path -LiteralPath $Path)) { Write-Change "No change to settings: $Path"; return }
    if ($DryRun) { Write-Change "Would write settings: $Path"; return }
    $parent = Split-Path -Parent $Path
    Ensure-Dir $parent
    ($existing | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $Path -Encoding UTF8
    Write-Change "Updated settings: $Path"
}

function Test-ProjectMarkers([string]$Path) {
    return (
        (Test-Path -LiteralPath (Join-Path $Path 'app.json')) -or
        (Test-Path -LiteralPath (Join-Path $Path '.git')) -or
        (Test-Path -LiteralPath (Join-Path $Path '.gitmodules'))
    )
}

function Resolve-ProjectRootAuto() {
    # Try common roots relative to script location to support submodule usage
    $candidates = @()
    try { $candidates += (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path } catch {}
    try { $candidates += (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path } catch {}
    try { $candidates += (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..')).Path } catch {}
    foreach ($c in $candidates) { if (Test-ProjectMarkers $c) { return $c } }
    # Fallback: script directory’s parent
    try { return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path } catch { return $PSScriptRoot }
}

if (-not $PSBoundParameters.ContainsKey('ProjectRoot') -or [string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = Resolve-ProjectRootAuto
}
else {
    try { $ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path } catch {}
}

Write-Step "Plug-and-play guidance installer starting (ProjectRoot: $ProjectRoot)"

# Validate guidance location
$guidanceFile = Join-Path $ProjectRoot (Join-Path $GuidancePath 'copilot-instructions.md')
if (-not (Test-Path -LiteralPath $guidanceFile)) {
    # Try relative to script (inside submodule)
    $alt = Join-Path (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path 'copilot-instructions.md'
    if (Test-Path -LiteralPath $alt) {
        $guidanceFile = $alt
    }
    else {
        Write-Host "[bc-copilot] WARNING: Guidance file not found at $guidanceFile" -ForegroundColor Yellow
    }
}

# 1) Copilot discovery shim
$shimPath = Join-Path $ProjectRoot '.github/copilot-instructions.md'
$shimContent = @"
---
applyTo: '**'
---

# READ THIS FIRST: Business Central Copilot Guidance

This repository uses centralized guidance. Agents and contributors must read and follow:
- [$GuidancePath/copilot-instructions.md]($GuidancePath/copilot-instructions.md)

TL;DR for agents:
- Read the guidance before assisting
- If this is a template/minimal BC project, do planning first — no code until requirements are captured
- Always include business context, error handling, and explain why
- Summarize the rules you’re following before your first edit
"@
Write-Step "Ensuring Copilot discovery shim"
Ensure-File -Path $shimPath -Content $shimContent

# 2) Machine-readable policy
$policyPath = Join-Path $ProjectRoot 'ai-guidance.json'
$policyContent = @'
{
    "applyTo": "**",
    "mustRead": [
        "copilot-guidance/copilot-instructions.md"
    ],
    "requireSummary": true
}
'@
Write-Step "Ensuring machine-readable policy"
Ensure-File -Path $policyPath -Content $policyContent

# 3) VS Code gentle nudge
$settingsPath = Join-Path $ProjectRoot '.vscode/settings.json'
$settingsFragment = @{ 'workbench.startupEditor' = 'readme' }
Write-Step "Ensuring VS Code startup nudge"
Merge-SettingsJson -Path $settingsPath -Fragment $settingsFragment

# 4) PR template (soft acknowledgment)
$prTemplatePath = Join-Path $ProjectRoot '.github/pull_request_template.md'
$prTemplateContent = @'
### Guidance Acknowledgment

- [ ] I have read and will follow copilot-guidance/copilot-instructions.md

> Tip: For template BC projects, complete planning before any code changes.
'@
Write-Step "Ensuring PR template"
Ensure-File -Path $prTemplatePath -Content $prTemplateContent

# 5) Optional CI gate
if ($EnableCI) {
    $workflowDir = Join-Path $ProjectRoot '.github/workflows'
    $workflowPath = Join-Path $workflowDir 'guidance-ack.yml'
    $workflowContent = @'
name: Guidance Acknowledgment
on:
    pull_request:
        types: [opened, edited, synchronize]
jobs:
    check:
        runs-on: ubuntu-latest
        steps:
            - name: Validate PR checklist
                uses: actions-ecosystem/action-regex-match@v2
                id: match
                with:
                    text: "${{ github.event.pull_request.body }}"
                    regex: "- \\[x\\] I have read and will follow copilot-guidance/copilot-instructions.md"
            - name: Fail if not acknowledged
                if: steps.match.outputs.match != 'true'
                run: |
                    echo "Please acknowledge reading copilot-guidance/copilot-instructions.md."
                    exit 1
'@
    Write-Step "Ensuring optional CI workflow"
    if ($DryRun) { Write-Change "Would create/update: $workflowPath" }
    else {
        Ensure-Dir $workflowDir
        Set-Content -LiteralPath $workflowPath -Value $workflowContent -Encoding UTF8
        Write-Change "Created/Updated: $workflowPath"
    }
}

# 6) Optional AL annotation (non-invasive, comment-only)
if ($AnnotateAL) {
    Write-Step "Annotating AL templates with a one-line reminder"
    $alFiles = Get-ChildItem -LiteralPath $ProjectRoot -Recurse -Filter '*.al' | Where-Object { $_.Length -lt 1MB }
    foreach ($f in $alFiles) {
        $content = Get-Content -LiteralPath $f.FullName -Raw
        if ($content -notmatch 'AGENT NOTE: Read \\/?\.github\\/copilot-instructions\.md') {
            $injected = "// AGENT NOTE: Read .github/copilot-instructions.md before editing.`n" + $content
            if ($DryRun) { Write-Change "Would annotate: $($f.FullName)" }
            else { $injected | Set-Content -LiteralPath $f.FullName -Encoding UTF8; Write-Change "Annotated: $($f.FullName)" }
        } else {
            Write-Change "Already annotated: $($f.FullName)"
        }
    }
}

Write-Step "Done. Use -DryRun to preview, -Force to overwrite, -EnableCI for a PR gate, -AnnotateAL to add comment headers."
