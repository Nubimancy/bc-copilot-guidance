# DevOps Style Integration - Code Samples

## Azure DevOps Pipeline Configuration

```yaml
# azure-pipelines.yml - AL code style validation pipeline
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    exclude:
    - docs/*
    - README.md

pool:
  vmImage: 'windows-latest'

variables:
  - group: 'AL-Build-Variables'
  - name: 'BCVERSION'
    value: '22.0'

stages:
- stage: StyleValidation
  displayName: 'Code Style Validation'
  jobs:
  - job: ValidateStyle
    displayName: 'Validate AL Code Style'
    steps:
    
    # Install AL Language Extension
    - task: PowerShell@2
      displayName: 'Install AL Language Extension'
      inputs:
        targetType: 'inline'
        script: |
          Install-Module -Name ALOps -Force -Scope CurrentUser
          Import-Module ALOps

    # Validate naming conventions
    - task: PowerShell@2
      displayName: 'Validate Naming Conventions'
      inputs:
        targetType: 'filePath'
        filePath: 'scripts/Validate-NamingConventions.ps1'
        arguments: '-SourcePath "$(Build.SourcesDirectory)" -FailOnError'

    # Check code formatting
    - task: PowerShell@2
      displayName: 'Validate Code Formatting'
      inputs:
        targetType: 'filePath'
        filePath: 'scripts/Validate-CodeFormatting.ps1'
        arguments: '-SourcePath "$(Build.SourcesDirectory)" -ReportPath "$(Agent.TempDirectory)/formatting-report.xml"'

    # Validate frontmatter compliance
    - task: PowerShell@2
      displayName: 'Validate Documentation Standards'
      inputs:
        targetType: 'inline'
        script: |
          .\Validate-FrontMatter.ps1 -Verbose
          if ($LASTEXITCODE -ne 0) { 
            Write-Error "Documentation validation failed"
            exit 1
          }

    # Publish test results
    - task: PublishTestResults@2
      displayName: 'Publish Style Validation Results'
      inputs:
        testResultsFormat: 'NUnit'
        testResultsFiles: '$(Agent.TempDirectory)/*-report.xml'
        failTaskOnFailedTests: true
```

## PowerShell Style Validation Scripts

```powershell
# Validate-NamingConventions.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [switch]$FailOnError,
    
    [string]$ReportPath = "naming-validation-report.xml"
)

$ErrorActionPreference = "Stop"
$ViolationCount = 0
$ValidationResults = @()

# Check AL object naming conventions
function Test-ALObjectNaming {
    param([string]$FilePath, [string]$Content)
    
    $violations = @()
    
    # Check for proper prefix usage
    if ($Content -match '(table|page|codeunit|report)\s+(\d+)\s+"([^"]+)"') {
        $objectName = $matches[3]
        if ($objectName -notmatch '^[A-Z]{2,4}\s+') {
            $violations += "Missing or invalid prefix in object: $objectName"
        }
    }
    
    # Check variable naming (PascalCase)
    $variableMatches = [regex]::Matches($Content, '^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(Record|Codeunit|Page)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    foreach ($match in $variableMatches) {
        $varName = $match.Groups[1].Value
        if ($varName -cnotmatch '^[A-Z][a-zA-Z0-9]*$') {
            $violations += "Variable '$varName' does not follow PascalCase convention"
        }
    }
    
    return $violations
}

# Process all AL files
Get-ChildItem -Path $SourcePath -Filter "*.al" -Recurse | ForEach-Object {
    Write-Host "Validating: $($_.FullName)"
    $content = Get-Content $_.FullName -Raw
    $violations = Test-ALObjectNaming -FilePath $_.FullName -Content $content
    
    if ($violations.Count -gt 0) {
        $ViolationCount += $violations.Count
        $ValidationResults += [PSCustomObject]@{
            File = $_.FullName
            Violations = $violations
        }
    }
}

# Generate XML report
$xmlReport = @"
<?xml version="1.0" encoding="UTF-8"?>
<test-results name="Naming Convention Validation" total="$($ValidationResults.Count)" errors="0" failures="$ViolationCount" not-run="0" inconclusive="0" ignored="0" skipped="0" invalid="0" date="$(Get-Date -Format 'yyyy-MM-dd')" time="$(Get-Date -Format 'HH:mm:ss')">
"@

foreach ($result in $ValidationResults) {
    $xmlReport += @"
    <test-suite name="$($result.File)">
"@
    foreach ($violation in $result.Violations) {
        $xmlReport += @"
        <test-case name="$violation" success="False">
            <failure message="$violation" />
        </test-case>
"@
    }
    $xmlReport += @"
    </test-suite>
"@
}

$xmlReport += @"
</test-results>
"@

$xmlReport | Out-File -FilePath $ReportPath -Encoding UTF8

if ($ViolationCount -gt 0) {
    Write-Host "Found $ViolationCount naming convention violations" -ForegroundColor Red
    if ($FailOnError) {
        exit 1
    }
} else {
    Write-Host "All naming conventions validated successfully" -ForegroundColor Green
}
```

## GitHub Actions Workflow

```yaml
# .github/workflows/al-style-check.yml
name: AL Style Validation

on:
  pull_request:
    branches: [ main, develop ]
    paths: 
      - '**/*.al'
      - 'app.json'
      - 'Validate-*.ps1'

jobs:
  style-validation:
    runs-on: windows-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup PowerShell modules
      shell: pwsh
      run: |
        Install-Module -Name ALOps -Force -Scope CurrentUser
        Install-Module -Name Pester -Force -Scope CurrentUser

    - name: Validate AL Code Style
      shell: pwsh
      run: |
        # Run comprehensive style validation
        $results = @()
        
        # Check naming conventions
        Write-Host "Validating naming conventions..."
        $namingResult = .\scripts\Validate-NamingConventions.ps1 -SourcePath "." -ReportPath "naming-report.xml"
        $results += $namingResult
        
        # Check code formatting
        Write-Host "Validating code formatting..."
        $formattingResult = .\scripts\Validate-CodeFormatting.ps1 -SourcePath "." -ReportPath "formatting-report.xml"  
        $results += $formattingResult
        
        # Check documentation compliance
        Write-Host "Validating documentation standards..."
        $docResult = .\Validate-FrontMatter.ps1 -Verbose
        $results += $docResult
        
        # Fail if any validation failed
        $failureCount = ($results | Where-Object { $_ -ne 0 }).Count
        if ($failureCount -gt 0) {
          Write-Error "Style validation failed with $failureCount error(s)"
          exit 1
        }
        
        Write-Host "All style validations passed!" -ForegroundColor Green

    - name: Upload validation reports
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: style-validation-reports
        path: |
          naming-report.xml
          formatting-report.xml
          frontmatter-validation.log
```

## Pre-commit Hook Integration

```powershell
# .git/hooks/pre-commit.ps1
# Automatically validate style before commits
param()

Write-Host "Running pre-commit style validation..." -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$ValidationFailed = $false

try {
    # Get staged AL files
    $stagedFiles = git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.al$' }
    
    if ($stagedFiles.Count -eq 0) {
        Write-Host "No AL files to validate" -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Validating $($stagedFiles.Count) AL files..." -ForegroundColor Yellow
    
    # Quick validation for staged files
    foreach ($file in $stagedFiles) {
        if (Test-Path $file) {
            $content = Get-Content $file -Raw
            
            # Check basic naming conventions
            if ($content -match '(table|page|codeunit|report)\s+(\d+)\s+"([^"]+)"') {
                $objectName = $matches[3]
                if ($objectName -notmatch '^[A-Z]{2,4}\s+') {
                    Write-Host "❌ $file: Missing or invalid prefix in object: $objectName" -ForegroundColor Red
                    $ValidationFailed = $true
                }
            }
            
            # Check for hard-coded strings
            if ($content -match "Message\s*\(\s*'[^%]|Error\s*\(\s*'[^%]") {
                Write-Host "❌ $file: Contains hard-coded strings that should use labels" -ForegroundColor Red
                $ValidationFailed = $true
            }
            
            # Check variable naming
            $variableMatches = [regex]::Matches($content, '^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*Record', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            foreach ($match in $variableMatches) {
                $varName = $match.Groups[1].Value
                if ($varName -cnotmatch '^[A-Z][a-zA-Z0-9]*$') {
                    Write-Host "❌ $file: Variable '$varName' should use PascalCase" -ForegroundColor Red
                    $ValidationFailed = $true
                }
            }
        }
    }
    
    if ($ValidationFailed) {
        Write-Host "`n💡 Style validation failed. Please fix the issues above before committing." -ForegroundColor Yellow
        Write-Host "   Run 'git commit --no-verify' to bypass validation if needed." -ForegroundColor Gray
        exit 1
    }
    
    Write-Host "✅ All style validations passed!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Pre-commit validation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

## Visual Studio Code Integration

```json
// .vscode/settings.json - IDE integration for style enforcement
{
    "al.enableCodeAnalysis": true,
    "al.codeAnalyzers": [
        "${CodeCop}",
        "${PerTenantExtensionCop}",
        "${AppSourceCop}"
    ],
    "al.ruleSetPath": "./.vscode/custom.ruleset.json",
    "al.enableCodeActions": true,
    
    // Formatting settings
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "editor.insertSpaces": true,
    "editor.tabSize": 4,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    
    // AL specific settings
    "al.assemblyProbingPaths": [],
    "al.packageCachePath": "./.alpackages",
    "al.enableCodeAnalysis": true
}
```

```json
// .vscode/custom.ruleset.json - Custom style rules
{
    "name": "Custom AL Rules",
    "description": "Enhanced style validation rules for AL development",
    "rules": [
        {
            "id": "AA0001",
            "action": "Error",
            "justification": "Enforce proper object naming with prefixes"
        },
        {
            "id": "AA0002", 
            "action": "Warning",
            "justification": "Variables should follow PascalCase convention"
        },
        {
            "id": "AA0072",
            "action": "Error", 
            "justification": "Mandatory suffix for text constants (Msg, Err, Qst, etc.)"
        },
        {
            "id": "AA0074",
            "action": "Error",
            "justification": "TextConst and Label variable names should have approved suffix"
        }
    ]
}
```

## Team Style Dashboard

```powershell
# Generate-StyleDashboard.ps1 - Team style compliance reporting
param(
    [Parameter(Mandatory=$true)]
    [string]$RepositoryPath,
    
    [string]$OutputPath = "style-dashboard.html",
    
    [int]$DaysBack = 30
)

# Collect style metrics
$styleMetrics = @{
    TotalFiles = 0
    CompliantFiles = 0
    ViolationsByType = @{}
    TrendData = @()
}

# Analyze recent commits for style trends
$commits = git log --since="$DaysBack days ago" --pretty=format:"%H|%ad|%s" --date=short | ConvertFrom-Csv -Delimiter '|' -Header 'Hash','Date','Message'

foreach ($commit in $commits) {
    # Get files changed in this commit
    $changedFiles = git show --name-only --pretty=format: $commit.Hash | Where-Object { $_ -match '\.al$' }
    
    if ($changedFiles.Count -gt 0) {
        # Run style validation on this commit
        git checkout $commit.Hash -q
        $violations = .\scripts\Validate-AllStyles.ps1 -QuietMode
        
        $styleMetrics.TrendData += [PSCustomObject]@{
            Date = $commit.Date
            CommitHash = $commit.Hash.Substring(0,8)
            FilesChanged = $changedFiles.Count
            Violations = $violations.Count
            ComplianceScore = [math]::Round((1 - ($violations.Count / $changedFiles.Count)) * 100, 2)
        }
    }
}

# Generate HTML dashboard
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>AL Code Style Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric-card { display: inline-block; margin: 10px; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .metric-value { font-size: 2em; font-weight: bold; color: #007acc; }
        .chart-container { width: 800px; height: 400px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>AL Code Style Compliance Dashboard</h1>
    <div class="metrics">
        <div class="metric-card">
            <div class="metric-value">$($styleMetrics.CompliantFiles)/$($styleMetrics.TotalFiles)</div>
            <div>Compliant Files</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">$(([math]::Round(($styleMetrics.CompliantFiles / $styleMetrics.TotalFiles) * 100, 1)))%</div>
            <div>Compliance Rate</div>
        </div>
    </div>
    
    <div class="chart-container">
        <canvas id="trendChart"></canvas>
    </div>
    
    <script>
        const ctx = document.getElementById('trendChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: [$($styleMetrics.TrendData | ForEach-Object { "'$($_.Date)'" } | Join-String -Separator ',')],
                datasets: [{
                    label: 'Style Compliance Score',
                    data: [$($styleMetrics.TrendData | ForEach-Object { $_.ComplianceScore } | Join-String -Separator ',')],
                    borderColor: 'rgb(75, 192, 192)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                scales: { y: { beginAtZero: true, max: 100 } }
            }
        });
    </script>
</body>
</html>
"@

$html | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "Style dashboard generated: $OutputPath" -ForegroundColor Green
```
