# Principle-Based Validation Strategies - Code Samples

## Static Code Analysis Examples

```powershell
# PowerShell script for principle-based validation
param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "validation-config.json"
)

# Load validation configuration
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Principle 1: Clean Code Validation
function Test-CleanCodePrinciples {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $violations = @()
    
    # Check for proper procedure naming
    if ($content -match 'procedure\s+[a-z]') {
        $violations += "Procedure names should start with capital letter"
    }
    
    # Check for magic numbers
    if ($content -match '\b\d{2,}\b' -and $content -notmatch '//.*\d{2,}') {
        $violations += "Consider using named constants instead of magic numbers"
    }
    
    # Check for proper error handling
    if ($content -match 'Error\(' -and $content -notmatch 'ErrorInfo') {
        $violations += "Consider using ErrorInfo for user-friendly error messages"
    }
    
    return $violations
}

# Principle 2: Performance Validation
function Test-PerformancePrinciples {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $violations = @()
    
    # Check for SetLoadFields usage in loops
    if ($content -match 'repeat.*Get\(' -and $content -notmatch 'SetLoadFields') {
        $violations += "Consider using SetLoadFields for better performance in loops"
    }
    
    # Check for FindSet vs Find usage
    if ($content -match '\.Find\(\).*repeat') {
        $violations += "Use FindSet() instead of Find() when iterating records"
    }
    
    return $violations
}
```

## Dynamic Testing Validation Examples

```al
// Test codeunit for principle validation
codeunit 50199 "Principle Validation Tests"
{
    Subtype = Test;

    [Test]
    procedure TestCleanCodePrinciples()
    var
        CustomerMgt: Codeunit "Customer Management Helper";
        Assert: Codeunit Assert;
    begin
        // Test that procedures have clear, descriptive names
        // and proper parameter validation
        
        // This should pass - good principle adherence
        CustomerMgt.UpdateCustomerLoyaltyPoints('CUST001', 100);
        
        // This should fail with clear error message
        asserterror CustomerMgt.UpdateCustomerLoyaltyPoints('', 100);
        Assert.ExpectedError('Customer number cannot be empty');
    end;

    [Test]
    procedure TestPerformancePrinciples()
    var
        Customer: Record Customer;
        StartTime: DateTime;
        EndTime: DateTime;
        Duration: Duration;
        Assert: Codeunit Assert;
    begin
        // Test that bulk operations meet performance standards
        StartTime := CurrentDateTime;
        
        // Execute performance-critical operation
        Customer.SetLoadFields("No.", Name);
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        if Customer.FindSet() then
            repeat
                // Process customer
            until Customer.Next() = 0;
        
        EndTime := CurrentDateTime;
        Duration := EndTime - StartTime;
        
        // Validate performance meets standards (e.g., < 5 seconds)
        Assert.IsTrue(Duration < 5000, 'Bulk operation exceeded performance threshold');
    end;

    [Test]
    procedure TestErrorHandlingPrinciples()
    var
        CustomerMgt: Codeunit "Customer Management Helper";
        ErrorInfo: ErrorInfo;
        Assert: Codeunit Assert;
    begin
        // Test that error handling follows ErrorInfo patterns
        asserterror CustomerMgt.ValidateCustomerData('INVALID');
        
        // Verify error provides helpful information
        ErrorInfo := GetLastErrorCallStack().GetErrorInfo();
        Assert.AreNotEqual('', ErrorInfo.Title, 'Error should have descriptive title');
        Assert.AreNotEqual('', ErrorInfo.DetailedMessage, 'Error should provide detailed guidance');
    end;
}
```

## Compliance Validation Examples

```al
// AppSource compliance validation codeunit
codeunit 50198 "AppSource Compliance Tests"
{
    Subtype = Test;

    [Test]
    procedure TestObjectNamingCompliance()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Assert: Codeunit Assert;
    begin
        // Validate that all custom objects use consistent prefixes
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetFilter("Object ID", '50000..99999'); // Custom range
        
        if AllObjWithCaption.FindSet() then
            repeat
                // Check for proper prefix usage
                Assert.IsTrue(
                    AllObjWithCaption."Object Name".StartsWith('LYL ') or
                    AllObjWithCaption."Object Name".StartsWith('Loyalty '),
                    StrSubstNo('Object %1 does not follow naming convention', AllObjWithCaption."Object Name")
                );
            until AllObjWithCaption.Next() = 0;
    end;

    [Test]
    procedure TestPermissionCompliance()
    var
        Customer: Record Customer;
        Assert: Codeunit Assert;
    begin
        // Test that operations work with minimum required permissions
        // Simulate limited permission scenario
        
        Customer.SetRange("No.", 'TEST001');
        Assert.IsTrue(Customer.ReadPermission, 'Should have read permission for Customer table');
        
        // Test that modification requires proper permissions
        if Customer.FindFirst() then
            Assert.IsTrue(Customer.WritePermission, 'Should have write permission for Customer modifications');
    end;
}
```

## Continuous Validation Dashboard

```json
{
    "validation_results": {
        "timestamp": "2025-01-20T10:30:00Z",
        "principle_compliance": {
            "clean_code": {
                "score": 92,
                "violations": 3,
                "top_issues": [
                    "Magic numbers in validation logic",
                    "Inconsistent naming in helper procedures"
                ]
            },
            "performance": {
                "score": 88,
                "violations": 5,
                "top_issues": [
                    "Missing SetLoadFields in bulk operations",
                    "Inefficient record looping patterns"
                ]
            },
            "extension_model": {
                "score": 95,
                "violations": 1,
                "top_issues": [
                    "Direct table modification instead of using events"
                ]
            },
            "error_handling": {
                "score": 85,
                "violations": 7,
                "top_issues": [
                    "Using Error() instead of ErrorInfo",
                    "Missing user guidance in error messages"
                ]
            }
        },
        "trends": {
            "improving": ["extension_model", "clean_code"],
            "declining": ["error_handling"],
            "stable": ["performance"]
        },
        "recommendations": [
            "Focus on ErrorInfo implementation training",
            "Review performance optimization guidelines",
            "Implement automated naming convention checks"
        ]
    }
}
```
