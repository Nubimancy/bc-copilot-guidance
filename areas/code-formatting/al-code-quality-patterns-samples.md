# AL Code Quality Patterns - Code Samples

## Code Analyzer Configuration

### VS Code Settings for AL Quality

```json
{
    "al.enableCodeAnalysis": true,
    "al.codeAnalyzers": [
        "${CodeCop}",
        "${PerTenantExtensionCop}", 
        "${UICop}",
        "${AppSourceCop}"
    ],
    "al.enableCodeActions": true,
    "al.ruleSetPath": "./ruleset.json",
    "editor.formatOnSave": true,
    "al.compileOnSave": false,
    "al.backgroundCodeAnalysis": true
}
```

### Custom Ruleset Configuration (ruleset.json)

```json
{
    "name": "Team AL Quality Rules",
    "description": "Custom quality rules for AL development team",
    "rules": [
        {
            "id": "AA0001", 
            "action": "Error",
            "justification": "Variables must be initialized before use"
        },
        {
            "id": "AA0005",
            "action": "Warning", 
            "justification": "Variable should be initialized"
        },
        {
            "id": "LC0001",
            "action": "Error",
            "justification": "FlowField should not be editable"
        },
        {
            "id": "AS0001",
            "action": "Warning",
            "justification": "Procedure should have documentation comment"
        }
    ]
}
```

## High-Quality AL Code Examples

### Well-Structured Codeunit with Quality Patterns

```al
/// <summary>
/// Handles customer validation business logic following quality standards
/// </summary>
codeunit 50100 "Customer Validation Manager"
{
    Access = Internal;

    /// <summary>
    /// Validates customer data before processing
    /// </summary>
    /// <param name="CustomerRec">Customer record to validate</param>
    /// <returns>True if validation passes, false otherwise</returns>
    procedure ValidateCustomerData(var CustomerRec: Record Customer): Boolean
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        ValidationResult: Boolean;
    begin
        // Initialize result to false for safety
        ValidationResult := false;
        
        // Validate required fields
        if not ValidateRequiredFields(CustomerRec) then
            exit(ValidationResult);
            
        // Validate posting group exists
        if not CustomerPostingGroup.Get(CustomerRec."Customer Posting Group") then begin
            CustomerRec.FieldError("Customer Posting Group", 'Posting Group does not exist');
            exit(ValidationResult);
        end;
        
        // Validate credit limit
        if not ValidateCreditLimit(CustomerRec) then
            exit(ValidationResult);
            
        ValidationResult := true;
        exit(ValidationResult);
    end;

    /// <summary>
    /// Validates that required customer fields are populated
    /// </summary>
    /// <param name="CustomerRec">Customer record to validate</param>
    /// <returns>True if required fields are valid</returns>
    local procedure ValidateRequiredFields(var CustomerRec: Record Customer): Boolean
    begin
        // Check required fields with meaningful error messages
        if CustomerRec.Name = '' then begin
            CustomerRec.FieldError(Name, 'Customer name is required');
            exit(false);
        end;
        
        if CustomerRec."Customer Posting Group" = '' then begin
            CustomerRec.FieldError("Customer Posting Group", 'Posting group is required');
            exit(false);
        end;
        
        exit(true);
    end;

    /// <summary>
    /// Validates customer credit limit against company policies
    /// </summary>
    /// <param name="CustomerRec">Customer record to validate</param>
    /// <returns>True if credit limit is acceptable</returns>
    local procedure ValidateCreditLimit(var CustomerRec: Record Customer): Boolean
    var
        MaxCreditLimit: Decimal;
    begin
        MaxCreditLimit := GetMaxCreditLimit();
        
        if CustomerRec."Credit Limit (LCY)" > MaxCreditLimit then begin
            CustomerRec.FieldError("Credit Limit (LCY)", 
                StrSubstNo('Credit limit cannot exceed %1', MaxCreditLimit));
            exit(false);
        end;
        
        exit(true);
    end;

    /// <summary>
    /// Retrieves maximum allowed credit limit from setup
    /// </summary>
    /// <returns>Maximum credit limit amount</returns>
    local procedure GetMaxCreditLimit(): Decimal
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        exit(SalesSetup."Max. Credit Limit Amount");
    end;
}
```

### Quality Page Extension Example

```al
/// <summary>
/// Extends Customer Card with enhanced validation and user experience
/// </summary>
pageextension 50101 "Customer Card Enhancement" extends "Customer Card"
{
    layout
    {
        addafter("Customer Posting Group")
        {
            field("Validation Status"; Rec."Validation Status")
            {
                ApplicationArea = All;
                Caption = 'Validation Status';
                ToolTip = 'Shows the current validation status of this customer';
                Importance = Promoted;
                Editable = false;
                
                trigger OnDrillDown()
                begin
                    ShowValidationDetails();
                end;
            }
        }
    }

    actions
    {
        addafter("&Customer")
        {
            action("Validate Customer Data")
            {
                ApplicationArea = All;
                Caption = 'Validate Customer Data';
                ToolTip = 'Validates customer data against business rules';
                Image = Validate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                
                trigger OnAction()
                var
                    CustomerValidationManager: Codeunit "Customer Validation Manager";
                    ValidationSuccess: Boolean;
                begin
                    ValidationSuccess := CustomerValidationManager.ValidateCustomerData(Rec);
                    
                    if ValidationSuccess then
                        Message('Customer validation completed successfully')
                    else
                        Message('Customer validation failed. Please review the data.');
                        
                    CurrPage.Update(false);
                end;
            }
        }
    }

    /// <summary>
    /// Shows detailed validation information for the customer
    /// </summary>
    local procedure ShowValidationDetails()
    var
        CustomerValidationDetails: Page "Customer Validation Details";
    begin
        CustomerValidationDetails.SetCustomer(Rec);
        CustomerValidationDetails.RunModal();
    end;
}
```

## Code Quality Validation Scripts

### PowerShell Script for Quality Checks

```powershell
# AL Code Quality Validation Script
param(
    [string]$ALProjectPath,
    [string]$OutputPath = ".\QualityReport.txt"
)

function Test-ALCodeQuality {
    param([string]$ProjectPath)
    
    $qualityIssues = @()
    $alFiles = Get-ChildItem -Path $ProjectPath -Filter "*.al" -Recurse
    
    foreach ($file in $alFiles) {
        $content = Get-Content $file.FullName -Raw
        
        # Check for common quality issues
        
        # 1. Check for proper object documentation
        if (-not ($content -match '/// <summary>')) {
            $qualityIssues += @{
                File = $file.Name
                Issue = "Missing object documentation"
                Severity = "Warning"
                Line = 1
            }
        }
        
        # 2. Check for hardcoded strings
        $hardcodedMatches = [regex]::Matches($content, "Error\('([^']+)'\)")
        foreach ($match in $hardcodedMatches) {
            $qualityIssues += @{
                File = $file.Name
                Issue = "Hardcoded error message: $($match.Groups[1].Value)"
                Severity = "Info"
                Line = ($content.Substring(0, $match.Index) -split "`n").Length
            }
        }
        
        # 3. Check for proper variable initialization
        $varMatches = [regex]::Matches($content, "var\s+(\w+):\s*(\w+);")
        foreach ($match in $varMatches) {
            $varName = $match.Groups[1].Value
            $varUsage = $content.IndexOf($varName, $match.Index + $match.Length)
            if ($varUsage -eq -1) {
                $qualityIssues += @{
                    File = $file.Name
                    Issue = "Variable '$varName' declared but not used"
                    Severity = "Warning"
                    Line = ($content.Substring(0, $match.Index) -split "`n").Length
                }
            }
        }
        
        # 4. Check for proper field error usage
        if ($content -match "FieldError\([^,]+\)" -and -not ($content -match "FieldError\([^,]+,\s*'[^']+'\)")) {
            $qualityIssues += @{
                File = $file.Name
                Issue = "FieldError should include descriptive message"
                Severity = "Warning"
                Line = "Multiple"
            }
        }
    }
    
    return $qualityIssues
}

# Run quality analysis
$issues = Test-ALCodeQuality -ProjectPath $ALProjectPath

# Generate report
$report = @"
AL Code Quality Report
Generated: $(Get-Date)
Project: $ALProjectPath

Total Issues Found: $($issues.Count)

Issues by Severity:
$($issues | Group-Object Severity | ForEach-Object { "$($_.Name): $($_.Count)" } | Out-String)

Detailed Issues:
$($issues | ForEach-Object { 
    "File: $($_.File)"
    "Issue: $($_.Issue)"
    "Severity: $($_.Severity)"
    "Line: $($_.Line)"
    "---"
} | Out-String)
"@

$report | Out-File -Path $OutputPath -Encoding UTF8
Write-Host "Quality report generated: $OutputPath"
```

### Build Pipeline Quality Gate

```yaml
# Azure DevOps pipeline with AL quality gates
steps:
- task: ALOpsDockerCreate@1
  inputs:
    artifacttype: 'OnPrem'
    
- task: ALOpsDockerStart@1

- task: ALOpsCompilerTask@1
  inputs:
    projectpath: '$(System.DefaultWorkingDirectory)'
    outputpath: '$(Build.ArtifactStagingDirectory)'
    nav_app_version: '$(Build.BuildNumber)'
    al_analyzer: |
      CodeCop
      PerTenantExtensionCop
      UICop
    failon: 'error'
    
# Quality gate: Fail build if code analysis issues found
- task: PowerShell@2
  displayName: 'Code Quality Validation'
  inputs:
    targetType: 'inline'
    script: |
      $analysisResults = Get-Content "$(Build.ArtifactStagingDirectory)\*.json" | ConvertFrom-Json
      $errors = $analysisResults | Where-Object { $_.severity -eq "error" }
      $warnings = $analysisResults | Where-Object { $_.severity -eq "warning" }
      
      Write-Host "Code Analysis Results:"
      Write-Host "Errors: $($errors.Count)"
      Write-Host "Warnings: $($warnings.Count)"
      
      if ($errors.Count -gt 0) {
          Write-Host "##vso[task.logissue type=error]Code analysis found $($errors.Count) errors"
          exit 1
      }
      
      if ($warnings.Count -gt 10) {
          Write-Host "##vso[task.logissue type=warning]Code analysis found $($warnings.Count) warnings (threshold: 10)"
      }
```

## Quality Metrics Tracking

### AL Object Complexity Analysis

```al
/// <summary>
/// Analyzes and reports on AL code complexity metrics
/// </summary>
codeunit 50200 "Code Quality Analyzer"
{
    /// <summary>
    /// Analyzes object complexity and generates quality metrics
    /// </summary>
    procedure AnalyzeObjectComplexity()
    var
        ALObject: Record "AL Object";
        ComplexityMetric: Record "Code Complexity Metric";
        ObjectComplexity: Integer;
    begin
        // Iterate through AL objects and calculate complexity
        if ALObject.FindSet() then
            repeat
                ObjectComplexity := CalculateObjectComplexity(ALObject);
                
                ComplexityMetric.Init();
                ComplexityMetric."Object Type" := ALObject."Object Type";
                ComplexityMetric."Object ID" := ALObject."Object ID";
                ComplexityMetric."Object Name" := ALObject."Object Name";
                ComplexityMetric.Complexity := ObjectComplexity;
                ComplexityMetric."Analysis Date" := Today();
                ComplexityMetric.Insert();
                
            until ALObject.Next() = 0;
    end;
    
    /// <summary>
    /// Calculates complexity score for an AL object
    /// </summary>
    /// <param name="ALObjectRec">AL Object record to analyze</param>
    /// <returns>Complexity score (higher = more complex)</returns>
    local procedure CalculateObjectComplexity(ALObjectRec: Record "AL Object"): Integer
    var
        ComplexityScore: Integer;
        ObjectSource: Text;
    begin
        // Get object source code (implementation would depend on source access)
        ObjectSource := GetObjectSourceCode(ALObjectRec);
        
        // Calculate complexity based on various factors
        ComplexityScore := 0;
        
        // Add points for procedures
        ComplexityScore += CountOccurrences(ObjectSource, 'procedure ') * 2;
        
        // Add points for conditional statements
        ComplexityScore += CountOccurrences(ObjectSource, 'if ') * 1;
        ComplexityScore += CountOccurrences(ObjectSource, 'case ') * 2;
        
        // Add points for loops
        ComplexityScore += CountOccurrences(ObjectSource, 'for ') * 3;
        ComplexityScore += CountOccurrences(ObjectSource, 'while ') * 3;
        ComplexityScore += CountOccurrences(ObjectSource, 'repeat') * 3;
        
        // Add points for exception handling
        ComplexityScore += CountOccurrences(ObjectSource, 'try') * 2;
        
        exit(ComplexityScore);
    end;
    
    local procedure GetObjectSourceCode(ALObjectRec: Record "AL Object"): Text
    begin
        // Implementation would retrieve actual source code
        // This is a placeholder for the concept
        exit('');
    end;
    
    local procedure CountOccurrences(SourceText: Text; SearchPattern: Text): Integer
    var
        Position: Integer;
        Count: Integer;
    begin
        Count := 0;
        Position := 1;
        
        while Position > 0 do begin
            Position := SourceText.IndexOf(SearchPattern, Position);
            if Position > 0 then begin
                Count += 1;
                Position += StrLen(SearchPattern);
            end;
        end;
        
        exit(Count);
    end;
}
```
