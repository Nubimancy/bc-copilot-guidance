---
title: "Boundary Condition Testing - Code Samples"
description: "Complete code examples for testing edge cases, limits, and error scenarios in AL"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["Record", ]
tags: ["boundary-testing", "edge-cases", "error-scenarios", "samples"]
---

# Boundary Condition Testing - Code Samples

## Boundary Value Testing

```al
codeunit 50301 "Boundary Condition Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestBoundaryConditions()
    var
        BusinessRule: Codeunit "Business Rule Validator";
        BoundaryValues: List of [Decimal];
        BoundaryValue: Decimal;
        TestResults: Dictionary of [Decimal, Boolean];
    begin
        // Test critical boundary points
        BoundaryValues.Add(0);          // Zero value
        BoundaryValues.Add(0.01);       // Minimum positive
        BoundaryValues.Add(999.99);     // Just under threshold
        BoundaryValues.Add(1000.00);    // Exact threshold
        BoundaryValues.Add(1000.01);    // Just over threshold
        BoundaryValues.Add(999999.99);  // Maximum allowed
        
        foreach BoundaryValue in BoundaryValues do begin
            TestResults.Add(BoundaryValue, BusinessRule.ValidateAmount(BoundaryValue));
        end;
        
        // Assert expected behavior at each boundary
        Assert.IsFalse(TestResults.Get(0), 'Zero should be invalid');
        Assert.IsTrue(TestResults.Get(0.01), 'Minimum positive should be valid');
        Assert.IsTrue(TestResults.Get(999.99), 'Just under threshold should be valid');
        Assert.IsTrue(TestResults.Get(1000.00), 'Exact threshold should be valid');
        Assert.IsFalse(TestResults.Get(1000.01), 'Just over threshold should be invalid');
        Assert.IsFalse(TestResults.Get(999999.99), 'Maximum value should be invalid');
    end;
    
    [Test]
    procedure TestQuantityBoundaries()
    var
        SalesLine: Record "Sales Line";
        QuantityValidator: Codeunit "Quantity Validator";
        TestQuantities: List of [Decimal];
        Quantity: Decimal;
    begin
        // Test inventory quantity boundaries
        TestQuantities.Add(-1);     // Negative quantity
        TestQuantities.Add(0);      // Zero quantity  
        TestQuantities.Add(1);      // Minimum valid
        TestQuantities.Add(100);    // Available stock
        TestQuantities.Add(101);    // Over available stock
        
        CreateSalesLineWithInventory(SalesLine, 100); // 100 units available
        
        foreach Quantity in TestQuantities do begin
            SalesLine.Quantity := Quantity;
            
            case Quantity of
                -1, 0:
                    begin
                        asserterror QuantityValidator.ValidateQuantity(SalesLine);
                        Assert.ExpectedError('Quantity must be greater than zero');
                    end;
                1..100:
                    Assert.IsTrue(QuantityValidator.ValidateQuantity(SalesLine),
                        StrSubstNo('Quantity %1 should be valid', Quantity));
                101:
                    begin
                        asserterror QuantityValidator.ValidateQuantity(SalesLine);
                        Assert.ExpectedError('Insufficient inventory');
                    end;
            end;
        end;
    end;
}
```

## Error Scenario Testing

```al
codeunit 50302 "Error Scenario Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestErrorScenarios()
    begin
        // Test various error conditions systematically
        TestWithBlockedCustomer();
        TestWithInvalidData();
        TestWithSystemConstraints();
        TestWithExternalSystemFailure();
    end;

    [Test]
    procedure TestWithBlockedCustomer()
    var
        Customer: Record Customer;
        TransactionProcessor: Codeunit "Transaction Processor";
    begin
        // Arrange: Blocked customer
        CreateBlockedCustomer(Customer);
        
        // Act & Assert: Should raise appropriate error
        asserterror TransactionProcessor.ProcessCustomerTransaction(Customer);
        Assert.ExpectedError('Cannot process transaction for blocked customer');
    end;
    
    [Test]
    procedure TestWithInvalidData()
    var
        SalesHeader: Record "Sales Header";
        DataValidator: Codeunit "Data Validator";
        InvalidDataScenarios: List of [Text];
        Scenario: Text;
    begin
        InvalidDataScenarios.Add('EMPTY_CUSTOMER');
        InvalidDataScenarios.Add('INVALID_DATES');
        InvalidDataScenarios.Add('MISSING_CURRENCY');
        InvalidDataScenarios.Add('NEGATIVE_AMOUNTS');
        
        foreach Scenario in InvalidDataScenarios do begin
            // Arrange: Create invalid data scenario
            CreateInvalidDataScenario(SalesHeader, Scenario);
            
            // Act & Assert: Should fail validation
            asserterror DataValidator.ValidateDocument(SalesHeader);
            Assert.ExpectedError(GetExpectedErrorForScenario(Scenario));
        end;
    end;
    
    [Test]
    procedure TestSystemConstraintViolations()
    var
        Customer: Record Customer;
        ConstraintTester: Codeunit "Constraint Tester";
    begin
        // Test database and system constraints
        
        // Test maximum field length
        Customer.Name := PadStr('X', MaxStrLen(Customer.Name) + 1, 'X');
        asserterror ConstraintTester.ValidateFieldLengths(Customer);
        Assert.ExpectedError('Field length exceeds maximum allowed');
        
        // Test decimal precision limits
        Customer."Credit Limit (LCY)" := 999999999.999; // Over precision limit
        asserterror ConstraintTester.ValidateDecimalPrecision(Customer);
        Assert.ExpectedError('Decimal precision exceeds system limits');
    end;
    
    [Test]
    procedure TestConcurrencyConstraints()
    var
        SalesHeader1, SalesHeader2: Record "Sales Header";
        ConcurrencyHandler: Codeunit "Concurrency Handler";
    begin
        // Arrange: Two processes trying to modify same record
        CreateSalesOrder(SalesHeader1, 'ORDER001');
        SalesHeader2.Get(SalesHeader1.RecordId);
        
        // Simulate concurrent modification
        SalesHeader1.Status := SalesHeader1.Status::Released;
        SalesHeader1.Modify();
        
        SalesHeader2.Status := SalesHeader2.Status::Released;
        
        // Act & Assert: Second modification should fail
        asserterror SalesHeader2.Modify();
        Assert.ExpectedError('The record has been modified by another user');
    end;
}
```

## Date and Time Boundary Testing

```al
codeunit 50303 "Date Boundary Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestDateBoundaries()
    var
        DateValidator: Codeunit "Date Validator";
        TestDates: List of [Date];
        TestDate: Date;
        CurrentFiscalYear: Date;
    begin
        CurrentFiscalYear := DMY2Date(1, 1, Date2DMY(Today, 3)); // Current fiscal year start
        
        // Test fiscal year boundaries
        TestDates.Add(CurrentFiscalYear - 1);           // Previous year
        TestDates.Add(CurrentFiscalYear);               // Fiscal year start
        TestDates.Add(CurrentFiscalYear + 1);           // Day after start
        TestDates.Add(CalcDate('<1Y-1D>', CurrentFiscalYear)); // Last day of fiscal year
        TestDates.Add(CalcDate('<1Y>', CurrentFiscalYear));     // Next fiscal year start
        
        foreach TestDate in TestDates do begin
            case TestDate of
                CurrentFiscalYear - 1:
                    begin
                        asserterror DateValidator.ValidateFiscalYearDate(TestDate);
                        Assert.ExpectedError('Date is outside current fiscal year');
                    end;
                CurrentFiscalYear, CurrentFiscalYear + 1:
                    Assert.IsTrue(DateValidator.ValidateFiscalYearDate(TestDate),
                        StrSubstNo('Date %1 should be valid', TestDate));
                CalcDate('<1Y-1D>', CurrentFiscalYear):
                    Assert.IsTrue(DateValidator.ValidateFiscalYearDate(TestDate),
                        'Last day of fiscal year should be valid');
                CalcDate('<1Y>', CurrentFiscalYear):
                    begin
                        asserterror DateValidator.ValidateFiscalYearDate(TestDate);
                        Assert.ExpectedError('Date is outside current fiscal year');
                    end;
            end;
        end;
    end;
    
    [Test]
    procedure TestTimeZoneBoundaries()
    var
        TimeValidator: Codeunit "Time Validator";
        TestTimes: List of [DateTime];
        TestTime: DateTime;
    begin
        // Test time zone transition boundaries
        TestTimes.Add(CreateDateTime(Today, 000000T)); // Midnight
        TestTimes.Add(CreateDateTime(Today, 235959T)); // Last second of day
        TestTimes.Add(CreateDateTime(Today + 1, 000000T)); // Next day midnight
        
        foreach TestTime in TestTimes do begin
            Assert.IsTrue(TimeValidator.ValidateBusinessHours(TestTime) in [true, false],
                StrSubstNo('Time validation should complete for %1', TestTime));
        end;
    end;
}
```

## Related Topics
- [Boundary Condition Testing](boundary-condition-testing.md)
- [Business Logic Testing Patterns](business-logic-testing-patterns.md)
- [Test Data Management](test-data-management.md)
