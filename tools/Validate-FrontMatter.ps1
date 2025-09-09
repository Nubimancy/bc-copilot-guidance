# Validate-FrontMatter.ps1
# Validates frontmatter compliance for microatomic BC Copilot Community files
# Usage: .\Validate-FrontMatter.ps1

param(
    [string]$Path = ".\areas",
    [switch]$Fix,
    [switch]$Verbose
)

# Define the required frontmatter schema
$RequiredFields = @('title', 'description', 'area', 'difficulty', 'object_types', 'variable_types', 'tags')
$ValidAreas = @('architecture-design', 'code-creation', 'code-formatting', 'error-handling', 'integration', 
                'naming-conventions', 'performance-optimization', 'project-workflow', 'testing', 'ai-assistance', 
                'appsource-compliance', 'security', 'data-management', 'user-experience', 'code-review')
$ValidDifficulties = @('beginner', 'intermediate', 'advanced', 'expert')

# Forbidden fields (Microsoft docs fields that don't belong)
$ForbiddenFields = @('author', 'ms.date', 'ms.topic', 'ms.service', 'ai_guidance', 'copilot_behavior', 
                    'devops_integration', 'last_modified', 'skill_level', 'object_type', 'variable_type', 'ai_tags')

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$White = "White"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-FrontMatter {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    if (-not $content.StartsWith('---')) {
        return $null
    }
    
    $frontMatterEnd = $content.IndexOf('---', 3)
    if ($frontMatterEnd -eq -1) {
        return $null
    }
    
    $frontMatterText = $content.Substring(3, $frontMatterEnd - 3).Trim()
    $frontMatter = @{}
    
    foreach ($line in $frontMatterText -split "`n") {
        $line = $line.Trim()
        if ($line -match '^([^:]+):\s*(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Handle array values
            if ($value.StartsWith('[') -and $value.EndsWith(']')) {
                $arrayContent = $value.Substring(1, $value.Length - 2)
                $frontMatter[$key] = @($arrayContent -split ',\s*' | ForEach-Object { $_.Trim('"') })
            } else {
                $frontMatter[$key] = $value.Trim('"')
            }
        }
    }
    
    return $frontMatter
}

function Test-FrontMatter {
    param([hashtable]$FrontMatter, [string]$FilePath)
    
    $errors = @()
    $warnings = @()
    
    # Check for required fields
    foreach ($field in $RequiredFields) {
        if (-not $FrontMatter.ContainsKey($field)) {
            $errors += "Missing required field: $field"
        }
    }
    
    # Check for forbidden fields
    foreach ($field in $ForbiddenFields) {
        if ($FrontMatter.ContainsKey($field)) {
            $errors += "Forbidden field found: $field (should not be present)"
        }
    }
    
    # Validate area format
    if ($FrontMatter.ContainsKey('area')) {
        $area = $FrontMatter['area']
        if ($area -notin $ValidAreas) {
            $errors += "Invalid area: '$area'. Must be one of: $($ValidAreas -join ', ')"
        }
        if ($area -cne $area.ToLower() -or $area.Contains(' ')) {
            $errors += "Area must be lowercase with hyphens: '$area'"
        }
    }
    
    # Validate difficulty
    if ($FrontMatter.ContainsKey('difficulty')) {
        $difficulty = $FrontMatter['difficulty']
        if ($difficulty -notin $ValidDifficulties) {
            $errors += "Invalid difficulty: '$difficulty'. Must be one of: $($ValidDifficulties -join ', ')"
        }
    }
    
    # Validate title format
    if ($FrontMatter.ContainsKey('title')) {
        $title = $FrontMatter['title']
        if ($title.Length -lt 10) {
            $warnings += "Title is quite short: '$title'"
        }
        if ($title.Length -gt 100) {
            $errors += "Title is too long (>100 chars): '$title'"
        }
    }
    
    # Validate description
    if ($FrontMatter.ContainsKey('description')) {
        $description = $FrontMatter['description']
        if ($description.Length -lt 20) {
            $warnings += "Description is quite short: '$description'"
        }
        if ($description.Length -gt 200) {
            $errors += "Description is too long (>200 chars): '$description'"
        }
    }
    
    # Validate arrays
    foreach ($arrayField in @('object_types', 'variable_types', 'tags')) {
        if ($FrontMatter.ContainsKey($arrayField)) {
            $value = $FrontMatter[$arrayField]
            if ($value -isnot [array]) {
                $errors += "$arrayField must be an array: [$($value -join ', ')]"
            } elseif ($value.Count -eq 0) {
                $warnings += "$arrayField is empty array"
            }
        }
    }
    
    return @{
        Errors = $errors
        Warnings = $warnings
    }
}

function New-FrontMatter {
    param([string]$FilePath)
    
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $areaName = Split-Path (Split-Path $FilePath) -Leaf
    
    # Generate title from filename
    $title = ($fileName -replace '-', ' ').Split(' ') | ForEach-Object {
        (Get-Culture).TextInfo.ToTitleCase($_.ToLower())
    }
    $titleString = ($title -join ' ')
    
    # Generate description template
    $description = "Comprehensive patterns and best practices for $titleString in Business Central AL development"
    
    # Suggest object types based on filename patterns
    $objectTypes = @()
    if ($fileName -match 'table|record') { $objectTypes += 'Table' }
    if ($fileName -match 'page|list|card') { $objectTypes += 'Page' }
    if ($fileName -match 'codeunit|procedure|function') { $objectTypes += 'Codeunit' }
    if ($fileName -match 'report') { $objectTypes += 'Report' }
    if ($fileName -match 'query') { $objectTypes += 'Query' }
    if ($fileName -match 'api|webservice') { $objectTypes += 'Page' }
    if ($objectTypes.Count -eq 0) { $objectTypes = @('Codeunit') }
    
    # Generate basic tags from filename
    $tags = @()
    $words = $fileName -split '-'
    foreach ($word in $words) {
        if ($word.Length -gt 2) {
            $tags += $word.ToLower()
        }
    }
    $tags += 'best-practices'
    
    $frontMatter = @"
---
title: "$titleString"
description: "$description"
area: "$areaName"
difficulty: "intermediate"
object_types: ["$($objectTypes -join '", "')"]
variable_types: ["Record"]
tags: ["$($tags -join '", "')"]
---
"@
    
    return $frontMatter
}

# Main execution
Write-ColorOutput "BC Copilot Community FrontMatter Validator" $Cyan
Write-ColorOutput "================================================" $Cyan

# Find all markdown files in areas (excluding samples)
$files = Get-ChildItem -Path $Path -Recurse -Filter "*.md" | Where-Object { 
    $_.Name -notmatch 'samples' -and $_.Name -ne 'README.md' 
}

$totalFiles = $files.Count
$validFiles = 0
$invalidFiles = 0
$filesWithWarnings = 0

Write-ColorOutput "`nFound $totalFiles files to validate" $White

foreach ($file in $files) {
    $relativePath = $file.FullName.Replace((Get-Location).Path, '').TrimStart('\')
    
    if ($Verbose) {
        Write-ColorOutput "`nChecking: $relativePath" $Cyan
    }
    
    $frontMatter = Get-FrontMatter -FilePath $file.FullName
    
    if (-not $frontMatter) {
        Write-ColorOutput "ERROR $relativePath - No frontmatter found" $Red
        $invalidFiles++
        
        if ($Fix) {
            Write-ColorOutput "Generating frontmatter template..." $Yellow
            $newFrontMatter = New-FrontMatter -FilePath $file.FullName
            Write-ColorOutput $newFrontMatter $Green
            Write-ColorOutput "Please review and customize the generated frontmatter" $Yellow
        }
        continue
    }
    
    $validation = Test-FrontMatter -FrontMatter $frontMatter -FilePath $file.FullName
    
    if ($validation.Errors.Count -eq 0) {
        if ($validation.Warnings.Count -eq 0) {
            if ($Verbose) {
                Write-ColorOutput "VALID $relativePath" $Green
            }
            $validFiles++
        } else {
            Write-ColorOutput "WARNING $relativePath - Valid with warnings:" $Yellow
            foreach ($warning in $validation.Warnings) {
                Write-ColorOutput "   - $warning" $Yellow
            }
            $filesWithWarnings++
            $validFiles++
        }
    } else {
        Write-ColorOutput "ERROR $relativePath - Invalid:" $Red
        foreach ($validationError in $validation.Errors) {
            Write-ColorOutput "   - $validationError" $Red
        }
        if ($validation.Warnings.Count -gt 0) {
            Write-ColorOutput "   Warnings:" $Yellow
            foreach ($warning in $validation.Warnings) {
                Write-ColorOutput "   - $warning" $Yellow
            }
        }
        $invalidFiles++
        
        if ($Fix) {
            Write-ColorOutput "Suggested frontmatter template:" $Yellow
            $newFrontMatter = New-FrontMatter -FilePath $file.FullName
            Write-ColorOutput $newFrontMatter $Green
        }
    }
}

# Summary report
Write-ColorOutput "`nVALIDATION SUMMARY" $Cyan
Write-ColorOutput "=====================" $Cyan
Write-ColorOutput "Total files checked: $totalFiles" $White
Write-ColorOutput "Valid files: $validFiles" $Green
Write-ColorOutput "Files with warnings: $filesWithWarnings" $Yellow
Write-ColorOutput "Invalid files: $invalidFiles" $Red

$successRate = [math]::Round(($validFiles / $totalFiles) * 100, 1)
Write-ColorOutput "`nSuccess Rate: $successRate%" $(if ($successRate -ge 95) { $Green } elseif ($successRate -ge 80) { $Yellow } else { $Red })

if ($invalidFiles -eq 0) {
    Write-ColorOutput "`nALL FILES PASS FRONTMATTER VALIDATION!" $Green
    exit 0
} else {
    Write-ColorOutput "`nRun with -Fix flag to see suggested frontmatter templates" $Yellow
    Write-ColorOutput "Run with -Verbose flag for detailed output" $Yellow
    exit 1
}
