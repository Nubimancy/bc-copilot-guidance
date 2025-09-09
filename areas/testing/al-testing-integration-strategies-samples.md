# AL Testing Integration Strategies - Code Samples

## Unit Testing Examples

### Basic AL Unit Test Structure

```al
// Unit test codeunit for customer validation logic
codeunit 50200 "Customer Validation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;

    [Test]
    procedure TestCustomerValidationWithValidData()
    var
        Customer: Record Customer;
        CustomerValidationMgt: Codeunit "Customer Validation Manager";
        ValidationResult: Boolean;
    begin
        // [GIVEN] A customer with valid data
        Initialize();
        CreateTestCustomerWithValidData(Customer);
        
        // [WHEN] Validation is performed
        ValidationResult := CustomerValidationMgt.ValidateCustomerData(Customer);
        
        // [THEN] Validation should succeed
        Assert.IsTrue(ValidationResult, 'Customer validation should succeed with valid data');
    end;

    [Test]
    procedure TestCustomerValidationWithInvalidName()
    var
        Customer: Record Customer;
        CustomerValidationMgt: Codeunit "Customer Validation Manager";
        ValidationResult: Boolean;
    begin
        // [GIVEN] A customer with invalid name (empty)
        Initialize();
        CreateTestCustomerWithInvalidName(Customer);
        
        // [WHEN] Validation is performed
        asserterror CustomerValidationMgt.ValidateCustomerData(Customer);
        
        // [THEN] Should get specific error about name
        Assert.ExpectedError('Customer name is required');
    end;

    [Test]
    procedure TestCustomerValidationWithInvalidCreditLimit()
    var
        Customer: Record Customer;
        CustomerValidationMgt: Codeunit "Customer Validation Manager";
    begin
        // [GIVEN] A customer with credit limit exceeding maximum
        Initialize();
        CreateTestCustomerWithExcessiveCreditLimit(Customer);
        
        // [WHEN] Validation is performed
        asserterror CustomerValidationMgt.ValidateCustomerData(Customer);
        
        // [THEN] Should get credit limit error
        Assert.ExpectedError('Credit limit cannot exceed');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
            
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Customer Validation Tests");
        
        // Clean up test data
        CleanupTestData();
        
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Customer Validation Tests");
    end;

    local procedure CreateTestCustomerWithValidData(var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Name := 'Test Customer ' + LibraryUtility.GenerateGUID();
        Customer."Customer Posting Group" := GetValidCustomerPostingGroup();
        Customer."Credit Limit (LCY)" := 50000;
        Customer.Modify(true);
    end;

    local procedure CreateTestCustomerWithInvalidName(var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Name := '';  // Invalid: empty name
        Customer."Customer Posting Group" := GetValidCustomerPostingGroup();
        Customer.Modify(true);
    end;

    local procedure CreateTestCustomerWithExcessiveCreditLimit(var Customer: Record Customer)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Name := 'Test Customer ' + LibraryUtility.GenerateGUID();
        Customer."Customer Posting Group" := GetValidCustomerPostingGroup();
        
        // Set credit limit above maximum allowed
        SalesSetup.Get();
        Customer."Credit Limit (LCY)" := SalesSetup."Max. Credit Limit Amount" + 1;
        Customer.Modify(true);
    end;

    local procedure GetValidCustomerPostingGroup(): Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if not CustomerPostingGroup.FindFirst() then
            LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);
        exit(CustomerPostingGroup.Code);
    end;

    local procedure CleanupTestData()
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter(Name, 'Test Customer*');
        Customer.DeleteAll(true);
    end;
}
```

### Integration Testing Example

```al
// Integration test for customer processing workflow
codeunit 50201 "Customer Processing Integration Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestFullCustomerProcessingWorkflow()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CustomerProcessingEngine: Codeunit "Customer Processing Engine";
        LibrarySales: Codeunit "Library - Sales";
        ProcessingResult: Boolean;
    begin
        // [GIVEN] A complete customer processing scenario
        Initialize();
        CreateTestCustomerWithOrders(Customer, SalesHeader, SalesLine);
        
        // [WHEN] Full processing workflow is executed
        ProcessingResult := CustomerProcessingEngine.ProcessCustomerData(Customer);
        
        // [THEN] All processing steps should complete successfully
        Assert.IsTrue(ProcessingResult, 'Customer processing workflow should complete successfully');
        
        // [AND] Customer data should be updated correctly
        Customer.Find();
        Assert.AreNotEqual(0DT, Customer."Last Processing Date", 'Last processing date should be updated');
        
        // [AND] Related sales orders should be processed
        SalesHeader.Find();
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'Sales order should be released');
    end;

    [Test]
    procedure TestCustomerProcessingWithDependentRecords()
    var
        Customer: Record Customer;
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        ProcessingResult: Boolean;
    begin
        // [GIVEN] Customer with ledger entries
        Initialize();
        CreateCustomerWithLedgerEntries(Customer, CustomerLedgerEntry);
        
        // [WHEN] Processing includes ledger entry updates
        ProcessingResult := ProcessCustomerWithLedgerEntries(Customer);
        
        // [THEN] Both customer and ledger entries should be updated
        Assert.IsTrue(ProcessingResult, 'Processing with dependent records should succeed');
        VerifyLedgerEntriesUpdated(Customer."No.");
    end;

    local procedure CreateTestCustomerWithOrders(var Customer: Record Customer; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // Create test customer
        LibrarySales.CreateCustomer(Customer);
        
        // Create test item
        LibraryInventory.CreateItem(Item);
        
        // Create sales order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 10);
    end;

    local procedure ProcessCustomerWithLedgerEntries(Customer: Record Customer): Boolean
    var
        CustomerProcessingEngine: Codeunit "Customer Processing Engine";
    begin
        exit(CustomerProcessingEngine.ProcessCustomerWithDependencies(Customer));
    end;

    local procedure VerifyLedgerEntriesUpdated(CustomerNo: Code[20])
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustomerLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustomerLedgerEntry.SetRange("Last Processing Flag", true);
        Assert.RecordIsNotEmpty(CustomerLedgerEntry);
    end;
}
```

## Performance Testing Integration

### Performance Test Framework

```al
// Performance testing codeunit
codeunit 50202 "AL Performance Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestCustomerProcessingPerformance()
    var
        Customer: Record Customer;
        CustomerProcessingEngine: Codeunit "Customer Processing Engine";
        StartTime: DateTime;
        EndTime: DateTime;
        Duration: Duration;
        MaxAllowedDuration: Duration;
    begin
        // [GIVEN] Performance test scenario with multiple customers
        Initialize();
        CreatePerformanceTestData();
        MaxAllowedDuration := 5000; // 5 seconds maximum
        
        // [WHEN] Processing is performed and timed
        StartTime := CurrentDateTime();
        CustomerProcessingEngine.ProcessAllCustomers();
        EndTime := CurrentDateTime();
        Duration := EndTime - StartTime;
        
        // [THEN] Processing should complete within acceptable time
        Assert.IsTrue(Duration <= MaxAllowedDuration, 
            StrSubstNo('Processing took %1ms, maximum allowed is %2ms', Duration, MaxAllowedDuration));
    end;

    [Test]
    procedure TestSetLoadFieldsPerformanceOptimization()
    var
        Customer: Record Customer;
        StartTime: DateTime;
        EndTime: DateTime;
        OptimizedDuration: Duration;
        UnoptimizedDuration: Duration;
    begin
        // [GIVEN] Large dataset for performance comparison
        Initialize();
        CreateLargeCustomerDataset();
        
        // [WHEN] Processing without SetLoadFields
        StartTime := CurrentDateTime();
        ProcessCustomersWithoutOptimization();
        EndTime := CurrentDateTime();
        UnoptimizedDuration := EndTime - StartTime;
        
        // [AND] Processing with SetLoadFields optimization
        StartTime := CurrentDateTime();
        ProcessCustomersWithSetLoadFields();
        EndTime := CurrentDateTime();
        OptimizedDuration := EndTime - StartTime;
        
        // [THEN] Optimized version should be significantly faster
        Assert.IsTrue(OptimizedDuration < (UnoptimizedDuration * 0.7), 
            'SetLoadFields optimization should improve performance by at least 30%');
    end;

    local procedure CreatePerformanceTestData()
    var
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
        Counter: Integer;
    begin
        // Create 1000 test customers for performance testing
        for Counter := 1 to 1000 do begin
            LibrarySales.CreateCustomer(Customer);
            Customer.Name := 'Performance Test Customer ' + Format(Counter);
            Customer.Modify();
        end;
    end;

    local procedure ProcessCustomersWithoutOptimization()
    var
        Customer: Record Customer;
        CustomerNames: List of [Text];
    begin
        Customer.SetFilter(Name, 'Performance Test Customer*');
        if Customer.FindSet() then
            repeat
                CustomerNames.Add(Customer.Name); // Loads entire record
            until Customer.Next() = 0;
    end;

    local procedure ProcessCustomersWithSetLoadFields()
    var
        Customer: Record Customer;
        CustomerNames: List of [Text];
    begin
        Customer.SetFilter(Name, 'Performance Test Customer*');
        Customer.SetLoadFields(Name); // Only load Name field
        if Customer.FindSet(false, false) then
            repeat
                CustomerNames.Add(Customer.Name);
            until Customer.Next() = 0;
    end;
}
```

## Automated Testing Pipeline Integration

### PowerShell Test Automation Script

```powershell
# AL Test Execution Script for DevOps Pipeline
param(
    [string]$ContainerName = "bc-test",
    [string]$CompanyName = "CRONUS International Ltd.",
    [string]$TestSuite = "Customer Management Tests",
    [string]$OutputPath = ".\TestResults"
)

function Run-ALTests {
    param(
        [string]$Container,
        [string]$Company,
        [string]$Suite,
        [string]$ResultsPath
    )
    
    Write-Host "Starting AL test execution..."
    Write-Host "Container: $Container"
    Write-Host "Company: $Company"
    Write-Host "Test Suite: $Suite"
    
    # Ensure output directory exists
    if (-not (Test-Path $ResultsPath)) {
        New-Item -Path $ResultsPath -ItemType Directory -Force
    }
    
    try {
        # Run AL tests in Business Central container
        $testResults = Run-TestsInBCContainer `
            -containerName $Container `
            -companyName $Company `
            -testSuite $Suite `
            -XUnitResultFileName "$ResultsPath\ALTestResults.xml" `
            -AppendToXUnitResultFile $false `
            -GetResults
            
        Write-Host "Test execution completed"
        
        # Parse and report results
        Parse-TestResults -TestResults $testResults -OutputPath $ResultsPath
        
        # Check for failures
        $failedTests = $testResults | Where-Object { $_.Result -eq "FAILURE" }
        if ($failedTests.Count -gt 0) {
            Write-Host "##vso[task.logissue type=error]$($failedTests.Count) tests failed"
            Write-Host "Failed tests:"
            $failedTests | ForEach-Object { 
                Write-Host "  - $($_.MethodName): $($_.ErrorMessage)"
            }
            exit 1
        }
        
        Write-Host "All tests passed successfully"
        
    } catch {
        Write-Host "##vso[task.logissue type=error]Test execution failed: $($_.Exception.Message)"
        exit 1
    }
}

function Parse-TestResults {
    param(
        [array]$TestResults,
        [string]$OutputPath
    )
    
    $totalTests = $TestResults.Count
    $passedTests = ($TestResults | Where-Object { $_.Result -eq "SUCCESS" }).Count
    $failedTests = ($TestResults | Where-Object { $_.Result -eq "FAILURE" }).Count
    $skippedTests = ($TestResults | Where-Object { $_.Result -eq "SKIPPED" }).Count
    
    $summary = @{
        TotalTests = $totalTests
        PassedTests = $passedTests
        FailedTests = $failedTests
        SkippedTests = $skippedTests
        PassRate = [math]::Round(($passedTests / $totalTests) * 100, 2)
    }
    
    # Output summary
    Write-Host "Test Results Summary:"
    Write-Host "  Total Tests: $($summary.TotalTests)"
    Write-Host "  Passed: $($summary.PassedTests)"
    Write-Host "  Failed: $($summary.FailedTests)"
    Write-Host "  Skipped: $($summary.SkippedTests)"
    Write-Host "  Pass Rate: $($summary.PassRate)%"
    
    # Save detailed results
    $summary | ConvertTo-Json | Out-File "$OutputPath\TestSummary.json"
    $TestResults | Export-Csv "$OutputPath\DetailedTestResults.csv" -NoTypeInformation
}

# Execute tests
Run-ALTests -Container $ContainerName -Company $CompanyName -Suite $TestSuite -ResultsPath $OutputPath
```

### Azure DevOps Pipeline Integration

```yaml
# Azure DevOps pipeline with AL testing integration
trigger:
  branches:
    include:
    - main
    - feature/*
  paths:
    include:
    - 'src/**'

variables:
  ALProjectPath: '$(System.DefaultWorkingDirectory)/src'
  TestResultsPath: '$(Agent.TempDirectory)/TestResults'
  
stages:
- stage: Build
  jobs:
  - job: CompileAndTest
    steps:
    - task: ALOpsDockerCreate@1
      displayName: 'Create BC Container'
      inputs:
        artifacttype: 'OnPrem'
        artifactcountry: 'us'
        
    - task: ALOpsDockerStart@1
      displayName: 'Start BC Container'
      
    - task: ALOpsCompilerTask@1
      displayName: 'Compile AL Project'
      inputs:
        projectpath: '$(ALProjectPath)'
        outputpath: '$(Build.ArtifactStagingDirectory)'
        nav_app_version: '$(Build.BuildNumber)'
        
    - task: ALOpsAppPublish@1
      displayName: 'Publish AL App to Container'
      inputs:
        usedocker: true
        nav_artifact_app_filter: '*.app'
        skip_verification: true
        
    - task: PowerShell@2
      displayName: 'Run AL Tests'
      inputs:
        targetType: 'filePath'
        filePath: '$(System.DefaultWorkingDirectory)/scripts/Run-ALTests.ps1'
        arguments: '-ContainerName "$(containerName)" -OutputPath "$(TestResultsPath)"'
        
    - task: PublishTestResults@2
      displayName: 'Publish Test Results'
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '$(TestResultsPath)/**/*.xml'
        failTaskOnFailedTests: true
        testRunTitle: 'AL Unit Tests'
        
    - task: PublishCodeCoverageResults@1
      displayName: 'Publish Code Coverage'
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(TestResultsPath)/coverage.xml'
```

### Test Data Management

```al
// Test data management codeunit
codeunit 50203 "Test Data Management"
{
    /// <summary>
    /// Creates isolated test data for AL testing
    /// </summary>
    procedure CreateIsolatedTestData(): Code[20]
    var
        TestDataPrefix: Code[20];
        Customer: Record Customer;
        Item: Record Item;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        TestDataPrefix := 'TEST' + Format(Random(99999), 0, '<Integer,5><Filler Character,0>');
        
        // Create test customer
        LibrarySales.CreateCustomer(Customer);
        Customer."No." := TestDataPrefix + 'CUST';
        Customer.Name := 'Test Customer ' + TestDataPrefix;
        Customer.Modify();
        
        // Create test item
        LibraryInventory.CreateItem(Item);
        Item."No." := TestDataPrefix + 'ITEM';
        Item.Description := 'Test Item ' + TestDataPrefix;
        Item.Modify();
        
        exit(TestDataPrefix);
    end;
    
    /// <summary>
    /// Cleans up test data after test execution
    /// </summary>
    procedure CleanupTestData(TestDataPrefix: Code[20])
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Clean up in reverse dependency order
        
        // Delete sales lines
        SalesLine.SetFilter("No.", TestDataPrefix + '*');
        SalesLine.DeleteAll(true);
        
        // Delete sales headers
        SalesHeader.SetFilter("Sell-to Customer No.", TestDataPrefix + '*');
        SalesHeader.DeleteAll(true);
        
        // Delete customers
        Customer.SetFilter("No.", TestDataPrefix + '*');
        Customer.DeleteAll(true);
        
        // Delete items
        Item.SetFilter("No.", TestDataPrefix + '*');
        Item.DeleteAll(true);
    end;
    
    /// <summary>
    /// Sets up test environment with required master data
    /// </summary>
    procedure SetupTestEnvironment()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // Ensure required setup records exist
        if not SalesSetup.Get() then begin
            SalesSetup.Init();
            SalesSetup.Insert();
        end;
        
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert();
        end;
        
        // Set required test values
        SalesSetup."Max. Credit Limit Amount" := 1000000;
        SalesSetup.Modify();
    end;
}
```
