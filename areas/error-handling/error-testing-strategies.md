---
title: "Error Testing Strategies"
description: "Comprehensive approaches to testing error handling scenarios in AL development"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "testing", "validation", "quality-assurance"]
---

# Error Testing Strategies

## Overview

Testing error handling is as important as testing happy path scenarios. Comprehensive error testing ensures your application handles edge cases gracefully, provides clear user feedback, and maintains system stability under adverse conditions.

## Core Testing Principles

### 1. Test Error Scenarios Explicitly

Error handling should be tested with the same rigor as business logic:

```al
[Test]
procedure TestCreditLimitValidation()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
begin
    // Arrange - Create scenario that will trigger error
    CreateCustomerWithCreditLimit(Customer, 1000);
    CreateSalesOrderWithAmount(SalesHeader, Customer."No.", 1500);
    
    // Act & Assert - Verify error occurs
    asserterror ValidateSalesOrder(SalesHeader);
    
    // Verify error message content
    Assert.ExpectedError('Credit limit of 1000 exceeded');
end;
```

### 2. Validate ErrorInfo Usage

Test that modern ErrorInfo patterns are implemented correctly:

```al
[Test]
procedure TestErrorInfoStructure()
var
    Customer: Record Customer;
    CaughtErrorInfo: ErrorInfo;
begin
    // Arrange
    CreateCustomerWithInvalidData(Customer);
    
    // Act
    ClearLastError();
    asserterror ValidateCustomer(Customer);
    CaughtErrorInfo := GetLastErrorObject();
    
    // Assert ErrorInfo properties
    Assert.IsTrue(CaughtErrorInfo.Message <> '', 'Error message should be populated');
    Assert.IsTrue(CaughtErrorInfo.DetailedMessage <> '', 'Detailed message should be provided');
    Assert.IsTrue(CaughtErrorInfo.HasActions, 'Error should have suggested actions');
    Assert.IsTrue(CaughtErrorInfo.Actions.Count >= 1, 'At least one action should be available');
end;
```

### 3. Test Suggested Actions

Verify that suggested actions are available and functional:

```al
[Test]
procedure TestSuggestedActionsAvailable()
var
    SalesHeader: Record "Sales Header";
    CaughtErrorInfo: ErrorInfo;
begin
    // Arrange
    CreateSalesOrderExceedingCreditLimit(SalesHeader);
    
    // Act
    ClearLastError();
    asserterror ProcessSalesOrder(SalesHeader);
    CaughtErrorInfo := GetLastErrorObject();
    
    // Assert specific actions exist
    AssertActionExists(CaughtErrorInfo, 'Increase Credit Limit');
    AssertActionExists(CaughtErrorInfo, 'Adjust Order Amount');
    AssertActionExists(CaughtErrorInfo, 'Contact Credit Manager');
end;

local procedure AssertActionExists(ErrorInfo: ErrorInfo; ActionCaption: Text)
var
    ActionFound: Boolean;
    i: Integer;
begin
    for i := 1 to ErrorInfo.Actions.Count do begin
        if ErrorInfo.Actions.Get(i).Caption = ActionCaption then begin
            ActionFound := true;
            break;
        end;
    end;
    
    Assert.IsTrue(ActionFound, StrSubstNo('Expected action "%1" not found', ActionCaption));
end;
```

## Comprehensive Error Scenarios

### 1. Boundary Condition Testing

Test edge cases and limits:

```al
[Test]
procedure TestQuantityBoundaryConditions()
begin
    // Test zero quantity
    asserterror ValidateQuantity(0);
    Assert.ExpectedError('Quantity must be greater than zero');
    
    // Test negative quantity
    asserterror ValidateQuantity(-1);
    Assert.ExpectedError('Quantity cannot be negative');
    
    // Test maximum allowed quantity
    asserterror ValidateQuantity(1000000);
    Assert.ExpectedError('Quantity exceeds maximum allowed value');
end;
```

### 2. State Validation Testing

Test invalid object states:

```al
[Test]
procedure TestInvalidOrderStateProcessing()
var
    SalesHeader: Record "Sales Header";
begin
    // Test processing released order
    CreateReleasedSalesOrder(SalesHeader);
    asserterror ModifySalesOrder(SalesHeader);
    Assert.ExpectedError('Cannot modify released sales order');
    
    // Test processing cancelled order
    CreateCancelledSalesOrder(SalesHeader);
    asserterror ProcessSalesOrder(SalesHeader);
    Assert.ExpectedError('Cannot process cancelled order');
end;
```

### 3. Dependency Validation Testing

Test missing or invalid dependencies:

```al
[Test]
procedure TestMissingCustomerValidation()
var
    SalesHeader: Record "Sales Header";
    NonExistentCustomerNo: Code[20];
begin
    // Arrange
    NonExistentCustomerNo := 'INVALID001';
    CreateSalesOrderWithCustomer(SalesHeader, NonExistentCustomerNo);
    
    // Act & Assert
    asserterror ValidateSalesOrderCustomer(SalesHeader);
    Assert.ExpectedError(StrSubstNo('Customer %1 does not exist', NonExistentCustomerNo));
end;
```

## Advanced Testing Patterns

### 1. Collectible Error Testing

Test that multiple errors are collected properly:

```al
[Test]
procedure TestMultipleValidationErrors()
var
    SalesHeader: Record "Sales Header";
    CaughtErrorInfo: ErrorInfo;
    ValidationErrorCount: Integer;
begin
    // Arrange - Create order with multiple issues
    CreateSalesOrderWithMultipleIssues(SalesHeader);
    
    // Act
    ClearLastError();
    asserterror ValidateCompleteOrder(SalesHeader);
    CaughtErrorInfo := GetLastErrorObject();
    
    // Assert - Check multiple errors are reported
    Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('3 validation errors found'), 
                 'Should report multiple validation errors');
    Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Customer'), 
                 'Should include customer validation error');
    Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Item'), 
                 'Should include item validation error');
    Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Quantity'), 
                 'Should include quantity validation error');
end;
```

### 2. TryFunction Pattern Testing

Test graceful error handling with try functions:

```al
[Test]
procedure TestTryFunctionErrorHandling()
var
    SalesHeader: Record "Sales Header";
    ProcessingResult: Boolean;
    ErrorMessage: Text;
begin
    // Arrange
    CreateProblemOrderForTesting(SalesHeader);
    
    // Act
    ClearLastError();
    ProcessingResult := TryProcessSalesOrder(SalesHeader);
    ErrorMessage := GetLastErrorText();
    
    // Assert
    Assert.IsFalse(ProcessingResult, 'Processing should fail for problematic order');
    Assert.IsTrue(ErrorMessage <> '', 'Error message should be captured');
    Assert.IsTrue(ErrorMessage.Contains('Credit limit'), 'Should identify specific issue');
end;
```

### 3. Error Context Testing

Test that error context is preserved correctly:

```al
[Test]
procedure TestErrorContextPreservation()
var
    Customer: Record Customer;
    SalesOrderNo: Code[20];
begin
    // Arrange
    CreateCustomerAndOrder(Customer, SalesOrderNo);
    
    // Act - Trigger error that should preserve context
    asserterror ProcessOrderWithContext(Customer."No.", SalesOrderNo);
    
    // Assert - Verify context is available for action handlers
    Assert.IsTrue(SessionStorage.Contains('ErrorContext_CustomerNo'), 
                 'Customer context should be preserved');
    Assert.IsTrue(SessionStorage.Contains('ErrorContext_SalesOrderNo'), 
                 'Sales order context should be preserved');
end;
```

## Performance Testing for Errors

### 1. Error Handling Performance

Test that error handling doesn't create performance bottlenecks:

```al
[Test]
procedure TestErrorHandlingPerformance()
var
    StartTime: DateTime;
    EndTime: DateTime;
    Duration: Duration;
    i: Integer;
begin
    // Measure error handling performance
    StartTime := CurrentDateTime;
    
    for i := 1 to 100 do begin
        ClearLastError();
        asserterror ProcessInvalidData(i);
    end;
    
    EndTime := CurrentDateTime;
    Duration := EndTime - StartTime;
    
    // Assert reasonable performance (adjust threshold as needed)
    Assert.IsTrue(Duration < 5000, 'Error handling should not be slow');
end;
```

### 2. Memory Usage Testing

Test that error handling doesn't cause memory leaks:

```al
[Test]
procedure TestErrorMemoryUsage()
var
    InitialMemory: Integer;
    FinalMemory: Integer;
    i: Integer;
begin
    // Get initial memory baseline
    InitialMemory := GetMemoryUsage();
    
    // Generate and handle multiple errors
    for i := 1 to 1000 do begin
        ClearLastError();
        asserterror ProcessTestError(i);
        // Process error info to simulate real usage
        ProcessErrorInfo(GetLastErrorObject());
    end;
    
    // Check final memory usage
    FinalMemory := GetMemoryUsage();
    
    // Assert memory usage is reasonable (adjust threshold based on testing)
    Assert.IsTrue(FinalMemory - InitialMemory < 10000000, 
                 'Error handling should not consume excessive memory');
end;
```

## Integration Testing

### 1. Cross-Module Error Testing

Test error handling across module boundaries:

```al
[Test]
procedure TestCrossModuleErrorHandling()
var
    SalesHeader: Record "Sales Header";
    InventoryError: ErrorInfo;
begin
    // Test that inventory module errors are handled properly in sales module
    CreateSalesOrderWithInvalidItem(SalesHeader);
    
    ClearLastError();
    asserterror ProcessSalesOrderWithInventoryCheck(SalesHeader);
    InventoryError := GetLastErrorObject();
    
    // Verify error comes from inventory module but is handled in sales context
    Assert.IsTrue(InventoryError.Message.Contains('inventory'), 'Should be inventory-related error');
    Assert.IsTrue(InventoryError.HasActions, 'Should have actions even from different module');
end;
```

### 2. End-to-End Error Scenarios

Test complete business process error scenarios:

```al
[Test]
procedure TestCompleteOrderProcessErrorFlow()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    ProcessingErrors: List of [ErrorInfo];
begin
    // Create complete test scenario
    CreateEndToEndTestScenario(Customer, SalesHeader);
    
    // Test complete flow with various error points
    TestCustomerValidationErrors(SalesHeader, ProcessingErrors);
    TestInventoryValidationErrors(SalesHeader, ProcessingErrors);
    TestPricingValidationErrors(SalesHeader, ProcessingErrors);
    TestShippingValidationErrors(SalesHeader, ProcessingErrors);
    
    // Verify comprehensive error reporting
    Assert.IsTrue(ProcessingErrors.Count > 0, 'Should detect errors in complete flow');
end;
```

## Error Testing Best Practices

### 1. Consistent Test Structure
- **Arrange** - Set up error conditions
- **Act** - Execute code that should fail
- **Assert** - Verify error behavior and content

### 2. Comprehensive Coverage
- Test all error paths, not just happy paths
- Verify error messages are helpful and actionable
- Test suggested actions are available and functional
- Validate ErrorInfo usage over basic Error() calls

### 3. Maintainable Tests
- Use helper methods for common error scenarios
- Create reusable assertion methods
- Keep tests focused on single error conditions
- Document expected error behavior

### 4. Performance Awareness
- Test error handling performance impact
- Verify no memory leaks in error scenarios
- Ensure error logging doesn't affect system performance

Comprehensive error testing ensures your AL applications provide excellent user experiences even when things go wrong, building user confidence and reducing support burden.
