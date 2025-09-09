#Requires -Version 5.1

<#
.SYNOPSIS
    Validates and rebuilds object/variable type indexes from microatomic topic frontmatter.

.DESCRIPTION
    This script serves as the source of truth for valid AL object types and variable types.
    It scans all microatomic topic files, validates their frontmatter against the authoritative
    type lists, and generates/updates the JSON indexes used by AI agents for discovery.

.PARAMETER ValidateOnly
    Only validate existing frontmatter without rebuilding indexes.

.PARAMETER RebuildIndexes
    Rebuild the JSON indexes after validation.

.EXAMPLE
    .\Validate-TypeIndexes.ps1 -ValidateOnly
    Validates frontmatter without rebuilding indexes.

.EXAMPLE
    .\Validate-TypeIndexes.ps1 -RebuildIndexes
    Validates and rebuilds both JSON indexes.
#>

[CmdletBinding()]
param(
    [switch]$ValidateOnly,
    [switch]$RebuildIndexes
)

# =============================================================================
# SOURCE OF TRUTH: AUTHORITATIVE TYPE LISTS
# =============================================================================

# AL Object Types - Master List
$ValidObjectTypes = @(
    "Table",
    "TableExtension", 
    "Page",
    "PageExtension",
    "PageCustomization",
    "Report",
    "ReportExtension",
    "Codeunit",
    "Query",
    "QueryExtension",
    "XMLport",
    "MenuSuite",
    "ControlAddin",
    "Profile",
    "Enum",
    "EnumExtension",
    "Interface",
    "PermissionSet",
    "PermissionSetExtension",
    "Entitlement",
    "DotNet"
)

# AL Variable Types - Master List (Complex/Important Types Only)
$ValidVariableTypes = @(
    # Core Record Types
    "Record",
    "RecordRef",
    "RecordId",
    "FieldRef",
    "KeyRef",
    "TestPage",
    
    # Data Transfer & Migration
    "DataTransfer",
    "DataClassification",
    
    # HTTP/API Types
    "HttpClient",
    "HttpRequestMessage", 
    "HttpResponseMessage",
    "HttpContent",
    "HttpHeaders",
    
    # JSON Types
    "JsonToken",
    "JsonValue", 
    "JsonObject",
    "JsonArray",
    
    # XML Types
    "XmlDocument",
    "XmlNode",
    "XmlNodeList",
    "XmlElement",
    "XmlAttribute",
    
    # File I/O Types
    "File",
    "InStream",
    "OutStream",
    "Blob",
    "Media",
    "MediaSet",
    
    # Collections
    "Dictionary",
    "List",
    "Array",
    
    # Date/Time Types
    "DateTime",
    "Date", 
    "Time",
    "Duration",
    
    # Advanced Types
    "Variant",
    "Interface",
    "Enum",
    "Database",
    "FilterPageBuilder",
    "SessionSettings",
    "Environment",
    "ClientType",
    "ExecutionMode",
    
    # Report Types
    "Report",
    "ReportFormat",
    "ReportLayoutType",
    
    # System Types
    "ErrorInfo",
    "Notification",
    "SecretText",
    "IsolatedStorage",
    
    # Testing Types
    "LibraryAssert",
    "Any"
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-ValidationError {
    param(
        [string]$Message,
        [string]$File = "",
        [string]$Detail = ""
    )
    
    $errorMsg = "VALIDATION ERROR: $Message"
    if ($File) { $errorMsg += " in file: $File" }
    if ($Detail) { $errorMsg += " - $Detail" }
    
    Write-Host $errorMsg -ForegroundColor Red
}

function Write-ValidationWarning {
    param(
        [string]$Message,
        [string]$File = "",
        [string]$Detail = ""
    )
    
    $warningMsg = "WARNING: $Message"
    if ($File) { $warningMsg += " in file: $File" }
    if ($Detail) { $warningMsg += " - $Detail" }
    
    Write-Host $warningMsg -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Parse-YamlFrontmatter {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    if ($content -notmatch '(?s)^---\r?\n(.*?)\r?\n---') {
        return $null
    }
    
    $yamlContent = $matches[1]
    $frontmatter = @{}
    
    # Simple YAML parser for our specific needs
    $yamlContent -split "`n" | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^(\w+):\s*(.+)$') {
            $key = $matches[1]
            $value = $matches[2].Trim()
            
            # Handle arrays [item1, item2, item3]
            if ($value -match '^\[(.*)\]$') {
                $arrayContent = $matches[1]
                $frontmatter[$key] = $arrayContent -split ',' | ForEach-Object { 
                    $_.Trim().Trim('"').Trim("'") 
                } | Where-Object { $_ -ne '' }
            } else {
                $frontmatter[$key] = $value.Trim('"').Trim("'")
            }
        }
    }
    
    return $frontmatter
}

# =============================================================================
# MAIN VALIDATION LOGIC
# =============================================================================

function Test-MicroatomicFiles {
    Write-Host "[SCAN] Scanning for microatomic topic files..." -ForegroundColor Cyan
    
    # Find all markdown files in areas subdirectories (excluding README and index files)
    $microatomicFiles = Get-ChildItem -Path "areas" -Recurse -Filter "*.md" | 
        Where-Object { 
            $_.Name -notmatch '^(README|.*-topics)\.md$' -and
            $_.Directory.Name -ne 'areas'  # Exclude files directly in /areas/
        }
    
    Write-Host "Found $($microatomicFiles.Count) microatomic files to validate" -ForegroundColor Gray
    
    $validationErrors = 0
    $validationWarnings = 0
    $typeUsage = @{
        ObjectTypes = @{}
        VariableTypes = @{}
    }
    
    foreach ($file in $microatomicFiles) {
        Write-Host "Validating: $($file.FullName.Replace($PWD, '.'))" -ForegroundColor Gray
        
        $frontmatter = Parse-YamlFrontmatter -FilePath $file.FullName
        
        if (-not $frontmatter) {
            Write-ValidationWarning "No YAML frontmatter found" -File $file.Name
            $validationWarnings++
            continue
        }
        
        # Validate object_types
        if ($frontmatter.ContainsKey('object_types')) {
            $objectTypes = $frontmatter['object_types']
            if ($objectTypes -is [string]) { $objectTypes = @($objectTypes) }
            
            foreach ($type in $objectTypes) {
                if ($type -notin $ValidObjectTypes) {
                    Write-ValidationError "Invalid object_type '$type'" -File $file.Name -Detail "Valid types: $($ValidObjectTypes -join ', ')"
                    $validationErrors++
                } else {
                    # Track usage for index building
                    if (-not $typeUsage.ObjectTypes.ContainsKey($type)) {
                        $typeUsage.ObjectTypes[$type] = @()
                    }
                    $typeUsage.ObjectTypes[$type] += $file.FullName.Replace($PWD, '.').Replace('\', '/')
                }
            }
        }
        
        # Validate variable_types  
        if ($frontmatter.ContainsKey('variable_types')) {
            $variableTypes = $frontmatter['variable_types']
            if ($variableTypes -is [string]) { $variableTypes = @($variableTypes) }
            
            foreach ($type in $variableTypes) {
                if ($type -notin $ValidVariableTypes) {
                    Write-ValidationError "Invalid variable_type '$type'" -File $file.Name -Detail "Valid types: $($ValidVariableTypes -join ', ')"
                    $validationErrors++
                } else {
                    # Track usage for index building
                    if (-not $typeUsage.VariableTypes.ContainsKey($type)) {
                        $typeUsage.VariableTypes[$type] = @()
                    }
                    $typeUsage.VariableTypes[$type] += $file.FullName.Replace($PWD, '.').Replace('\', '/')
                }
            }
        }
    }
    
    # Summary
    Write-Host "`n[SUMMARY] VALIDATION SUMMARY" -ForegroundColor Cyan
    Write-Host "Files scanned: $($microatomicFiles.Count)" -ForegroundColor Gray
    Write-Host "Errors: $validationErrors" -ForegroundColor $(if ($validationErrors -gt 0) { "Red" } else { "Green" })
    Write-Host "Warnings: $validationWarnings" -ForegroundColor $(if ($validationWarnings -gt 0) { "Yellow" } else { "Green" })
    
    if ($validationErrors -eq 0 -and $validationWarnings -eq 0) {
        Write-Success "All microatomic files validated successfully!"
    }
    
    return @{
        Errors = $validationErrors
        Warnings = $validationWarnings  
        TypeUsage = $typeUsage
        Success = ($validationErrors -eq 0)
    }
}

function Build-TypeIndexes {
    param([hashtable]$TypeUsage)
    
    Write-Host "`n[BUILD] Building type indexes..." -ForegroundColor Cyan
    
    # Build Object Types Index
    $objectIndex = @{
        generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        description = "Index mapping AL object types to relevant guidance files"
        total_types = $TypeUsage.ObjectTypes.Keys.Count
        object_types = @{}
    }
    
    foreach ($type in $TypeUsage.ObjectTypes.Keys | Sort-Object) {
        $objectIndex.object_types[$type] = @{
            files = $TypeUsage.ObjectTypes[$type] | Sort-Object
            count = $TypeUsage.ObjectTypes[$type].Count
        }
    }
    
    # Build Variable Types Index
    $variableIndex = @{
        generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ") 
        description = "Index mapping AL variable types to relevant guidance files"
        total_types = $TypeUsage.VariableTypes.Keys.Count
        variable_types = @{}
    }
    
    foreach ($type in $TypeUsage.VariableTypes.Keys | Sort-Object) {
        $variableIndex.variable_types[$type] = @{
            files = $TypeUsage.VariableTypes[$type] | Sort-Object
            count = $TypeUsage.VariableTypes[$type].Count  
        }
    }
    
    # Write JSON files
    $objectIndexPath = Join-Path "areas" "object-types-index.json"
    $variableIndexPath = Join-Path "areas" "variable-types-index.json"
    
    $objectIndex | ConvertTo-Json -Depth 4 | Set-Content -Path $objectIndexPath -Encoding UTF8
    $variableIndex | ConvertTo-Json -Depth 4 | Set-Content -Path $variableIndexPath -Encoding UTF8
    
    Write-Success "Object types index written to: $objectIndexPath"
    Write-Success "Variable types index written to: $variableIndexPath"
    
    Write-Host "`n[STATS] INDEX STATISTICS" -ForegroundColor Cyan
    Write-Host "Object types covered: $($objectIndex.total_types)" -ForegroundColor Gray
    Write-Host "Variable types covered: $($variableIndex.total_types)" -ForegroundColor Gray
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

Write-Host "[START] BC Copilot Community - Type Index Validator" -ForegroundColor Magenta
Write-Host "=================================================" -ForegroundColor Magenta

# Validate current directory
if (-not (Test-Path "areas")) {
    Write-Host "[ERROR] Must be run from bc-copilot-community root directory" -ForegroundColor Red
    exit 1
}

# Run validation
$validationResult = Test-MicroatomicFiles

if (-not $validationResult.Success) {
    Write-Host "`n[FAILED] Validation failed with $($validationResult.Errors) errors" -ForegroundColor Red
    Write-Host "Please fix validation errors before rebuilding indexes." -ForegroundColor Yellow
    exit 1
}

# Rebuild indexes if requested and validation passed
if ($RebuildIndexes -or (-not $ValidateOnly)) {
    if ($validationResult.Success) {
        Build-TypeIndexes -TypeUsage $validationResult.TypeUsage
        Write-Host "`n[COMPLETE] Type indexes successfully rebuilt!" -ForegroundColor Green
    }
} else {
    Write-Host "`n[SUCCESS] Validation completed. Use -RebuildIndexes to update JSON indexes." -ForegroundColor Green
}
