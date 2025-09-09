---
title: "Error Testing Strategies - Code Samples"
description: "Complete code examples for testing error handling scenarios in AL development"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "testing", "samples", "quality-assurance"]
---

# Error Testing Strategies - Code Samples

## Basic Error Testing Framework

### Core Test Structure

```al
codeunit 80100 "Error Testing Framework"
{
    Subtype = Test;
    
    [Test]
    procedure TestBasicErrorScenario()
    var
        Customer: Record Customer;
        SalesOrder: Codeunit "Sales Order Management";
    begin
        // Arrange - Set up error condition
        CreateInvalidCustomer(Customer);
        
        // Act & Assert - Verify error occurs
        asserterror SalesOrder.ValidateCustomer(Customer);
        
        // Verify error message
        Assert.ExpectedError('Customer validation failed');
    end;
    
    [Test]
    procedure TestErrorInfoStructure()
    var
        SalesHeader: Record "Sales Header";
        CaughtErrorInfo: ErrorInfo;
    begin
        // Arrange
        CreateOrderExceedingCreditLimit(SalesHeader);
        
        // Act
        ClearLastError();
        asserterror ProcessSalesOrder(SalesHeader);
        CaughtErrorInfo := GetLastErrorObject();
        
        // Assert ErrorInfo properties
        Assert.IsTrue(CaughtErrorInfo.Message <> '', 'Error message should not be empty');
        Assert.IsTrue(CaughtErrorInfo.DetailedMessage <> '', 'Detailed message should be provided');
        Assert.IsTrue(CaughtErrorInfo.HasActions, 'Error should have suggested actions');
        Assert.AreEqual(3, CaughtErrorInfo.Actions.Count, 'Should have exactly 3 actions');
        
        // Verify specific action exists
        AssertActionExists(CaughtErrorInfo, 'Increase Credit Limit');
    end;
    
    local procedure AssertActionExists(ErrorInfo: ErrorInfo; ActionCaption: Text)
    var
        ActionFound: Boolean;
        ActionItem: ErrorAction;
        i: Integer;
    begin
        for i := 1 to ErrorInfo.Actions.Count do begin
            ActionItem := ErrorInfo.Actions.Get(i);
            if ActionItem.Caption = ActionCaption then begin
                ActionFound := true;
                break;
            end;
        end;
        
        Assert.IsTrue(ActionFound, 
                     StrSubstNo('Expected action "%1" not found in error actions', ActionCaption));
    end;
}
```

### Test Data Setup Helpers

```al
codeunit 80101 "Error Test Data Setup"
{
    procedure CreateInvalidCustomer(var Customer: Record Customer)
    begin
        Customer.Init();
        Customer."No." := 'INVALID001';
        Customer.Name := ''; // Invalid - empty name
        Customer."Credit Limit" := -100; // Invalid - negative credit limit
        Customer.Blocked := Customer.Blocked::All; // Blocked customer
        Customer.Insert();
    end;
    
    procedure CreateCustomerWithCreditLimit(var Customer: Record Customer; CreditLimit: Decimal)
    begin
        Customer.Init();
        Customer."No." := LibraryUtility.GenerateRandomCode(Customer.FieldNo("No."), Database::Customer);
        Customer.Name := 'Test Customer ' + Customer."No.";
        Customer."Credit Limit" := CreditLimit;
        Customer."Payment Terms Code" := CreatePaymentTerms();
        Customer.Insert();
    end;
    
    procedure CreateSalesOrderWithAmount(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; Amount: Decimal)
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        // Create header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := LibraryUtility.GenerateRandomCode(SalesHeader.FieldNo("No."), Database::"Sales Header");
        SalesHeader."Sell-to Customer No." := CustomerNo;
        SalesHeader.Insert();
        
        // Create line with specific amount
        CreateItemForTesting(Item, Amount);
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := Item."No.";
        SalesLine.Quantity := 1;
        SalesLine."Unit Price" := Amount;
        SalesLine.Insert();
    end;
    
    procedure CreateOrderExceedingCreditLimit(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        CreateCustomerWithCreditLimit(Customer, 1000);
        CreateSalesOrderWithAmount(SalesHeader, Customer."No.", 1500);
    end;
    
    procedure CreateMultipleValidationIssuesOrder(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
    begin
        // Create customer with issues
        Customer.Init();
        Customer."No." := 'PROBLEM001';
        Customer.Name := 'Problem Customer';
        Customer."Credit Limit" := 100; // Very low credit limit
        Customer."Payment Terms Code" := ''; // Missing payment terms
        Customer.Insert();
        
        // Create order header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := LibraryUtility.GenerateRandomCode(SalesHeader.FieldNo("No."), Database::"Sales Header");
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader."Document Date" := 0D; // Invalid date
        SalesHeader.Insert();
        
        // Create line with multiple issues
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := 'NONEXISTENT'; // Non-existent item
        SalesLine.Quantity := -5; // Negative quantity
        SalesLine."Unit Price" := -10; // Negative price
        SalesLine.Insert();
    end;
    
    local procedure CreatePaymentTerms(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.Init();
        PaymentTerms.Code := 'TEST30';
        PaymentTerms.Description := 'Test 30 days';
        PaymentTerms."Due Date Calculation" := '<30D>';
        if not PaymentTerms.Insert() then;
        exit(PaymentTerms.Code);
    end;
    
    local procedure CreateItemForTesting(var Item: Record Item; UnitPrice: Decimal)
    begin
        Item.Init();
        Item."No." := LibraryUtility.GenerateRandomCode(Item.FieldNo("No."), Database::Item);
        Item.Description := 'Test Item ' + Item."No.";
        Item.Type := Item.Type::Inventory;
        Item."Unit Price" := UnitPrice;
        Item.Insert();
    end;
}
```

## Boundary Condition Testing

### Range and Limit Testing

```al
codeunit 80102 "Boundary Condition Tests"
{
    Subtype = Test;
    
    [Test]
    procedure TestQuantityBoundaryConditions()
    var
        QuantityValidator: Codeunit "Quantity Validator";
    begin
        // Test zero quantity
        asserterror QuantityValidator.ValidateQuantity(0, 'Sales Order');
        Assert.ExpectedError('Quantity must be greater than zero');
        
        // Test negative quantity
        asserterror QuantityValidator.ValidateQuantity(-1, 'Sales Order');
        Assert.ExpectedError('Quantity cannot be negative');
        
        // Test minimum valid quantity
        QuantityValidator.ValidateQuantity(0.001, 'Sales Order'); // Should not error
        
        // Test maximum allowed quantity
        asserterror QuantityValidator.ValidateQuantity(1000000, 'Sales Order');
        Assert.ExpectedError('Quantity exceeds maximum allowed');
        
        // Test just under maximum
        QuantityValidator.ValidateQuantity(999999, 'Sales Order'); // Should not error
    end;
    
    [Test]
    procedure TestAmountBoundaryConditions()
    var
        AmountValidator: Codeunit "Amount Validator";
        MaxAmount: Decimal;
    begin
        MaxAmount := 999999999.99;
        
        // Test negative amounts
        asserterror AmountValidator.ValidateAmount(-0.01, 'Sales Order');
        Assert.ExpectedError('Amount cannot be negative');
        
        // Test zero amount (may be valid in some contexts)
        AmountValidator.ValidateAmount(0, 'Sales Order'); // Should not error
        
        // Test very small amount
        AmountValidator.ValidateAmount(0.01, 'Sales Order'); // Should not error
        
        // Test maximum amount
        AmountValidator.ValidateAmount(MaxAmount, 'Sales Order'); // Should not error
        
        // Test over maximum
        asserterror AmountValidator.ValidateAmount(MaxAmount + 0.01, 'Sales Order');
        Assert.ExpectedError('Amount exceeds maximum allowed');
    end;
    
    [Test]
    procedure TestDiscountPercentageBoundaries()
    var
        DiscountValidator: Codeunit "Discount Validator";
    begin
        // Test negative discount
        asserterror DiscountValidator.ValidateDiscountPercent(-0.1);
        Assert.ExpectedError('Discount percentage cannot be negative');
        
        // Test zero discount
        DiscountValidator.ValidateDiscountPercent(0); // Should not error
        
        // Test valid discounts
        DiscountValidator.ValidateDiscountPercent(15.5); // Should not error
        DiscountValidator.ValidateDiscountPercent(100); // Should not error
        
        // Test over 100%
        asserterror DiscountValidator.ValidateDiscountPercent(100.1);
        Assert.ExpectedError('Discount percentage cannot exceed 100%');
    end;
    
    [Test]
    procedure TestDateBoundaryConditions()
    var
        DateValidator: Codeunit "Date Validator";
        EarliestAllowedDate: Date;
        LatestAllowedDate: Date;
    begin
        EarliestAllowedDate := 20200101D; // Jan 1, 2020
        LatestAllowedDate := 20991231D;   // Dec 31, 2099
        
        // Test dates before allowed range
        asserterror DateValidator.ValidateBusinessDate(19991231D, 'Order Date');
        Assert.ExpectedError('Date is before the allowed range');
        
        // Test minimum valid date
        DateValidator.ValidateBusinessDate(EarliestAllowedDate, 'Order Date');
        
        // Test current date
        DateValidator.ValidateBusinessDate(Today, 'Order Date');
        
        // Test maximum valid date
        DateValidator.ValidateBusinessDate(LatestAllowedDate, 'Order Date');
        
        // Test dates after allowed range
        asserterror DateValidator.ValidateBusinessDate(21000101D, 'Order Date');
        Assert.ExpectedError('Date is after the allowed range');
    end;
}
```

## State Validation Testing

### Object State Testing

```al
codeunit 80103 "State Validation Tests"
{
    Subtype = Test;
    
    [Test]
    procedure TestSalesOrderStateTransitions()
    var
        SalesHeader: Record "Sales Header";
        OrderProcessor: Codeunit "Sales Order Processor";
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        // Test modifying open order (should work)
        TestDataSetup.CreateValidSalesOrder(SalesHeader);
        SalesHeader.Status := SalesHeader.Status::Open;
        SalesHeader.Modify();
        
        OrderProcessor.ModifyOrderLine(SalesHeader, 10000, 5); // Should not error
        
        // Test modifying released order (should fail)
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify();
        
        asserterror OrderProcessor.ModifyOrderLine(SalesHeader, 10000, 10);
        Assert.ExpectedError('Cannot modify released sales order');
        
        // Test processing pending approval order (should fail)
        SalesHeader.Status := SalesHeader.Status::"Pending Approval";
        SalesHeader.Modify();
        
        asserterror OrderProcessor.ProcessOrder(SalesHeader);
        Assert.ExpectedError('Order is pending approval and cannot be processed');
    end;
    
    [Test]
    procedure TestCustomerBlockingStates()
    var
        Customer: Record Customer;
        OrderValidator: Codeunit "Order Validator";
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        TestDataSetup.CreateValidCustomer(Customer);
        
        // Test unblocked customer (should work)
        Customer.Blocked := Customer.Blocked::" ";
        Customer.Modify();
        OrderValidator.ValidateCustomerForSales(Customer); // Should not error
        
        // Test blocked for shipping
        Customer.Blocked := Customer.Blocked::Ship;
        Customer.Modify();
        asserterror OrderValidator.ValidateCustomerForSales(Customer);
        Assert.ExpectedError('Customer is blocked for shipping');
        
        // Test blocked for invoicing
        Customer.Blocked := Customer.Blocked::Invoice;
        Customer.Modify();
        asserterror OrderValidator.ValidateCustomerForSales(Customer);
        Assert.ExpectedError('Customer is blocked for invoicing');
        
        // Test blocked for all transactions
        Customer.Blocked := Customer.Blocked::All;
        Customer.Modify();
        asserterror OrderValidator.ValidateCustomerForSales(Customer);
        Assert.ExpectedError('Customer is blocked for all transactions');
    end;
    
    [Test]
    procedure TestItemAvailabilityStates()
    var
        Item: Record Item;
        ItemValidator: Codeunit "Item Validator";
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        TestDataSetup.CreateValidItem(Item);
        
        // Test active item (should work)
        Item.Blocked := false;
        Item."Sales Blocked" := false;
        Item.Modify();
        ItemValidator.ValidateItemForSales(Item); // Should not error
        
        // Test completely blocked item
        Item.Blocked := true;
        Item.Modify();
        asserterror ItemValidator.ValidateItemForSales(Item);
        Assert.ExpectedError('Item is blocked');
        
        // Test sales-blocked item
        Item.Blocked := false;
        Item."Sales Blocked" := true;
        Item.Modify();
        asserterror ItemValidator.ValidateItemForSales(Item);
        Assert.ExpectedError('Item is blocked for sales');
    end;
}
```

## Collectible Error Testing

### Multiple Error Scenarios

```al
codeunit 80104 "Collectible Error Tests"
{
    Subtype = Test;
    
    [Test]
    procedure TestMultipleValidationErrors()
    var
        SalesHeader: Record "Sales Header";
        ComprehensiveValidator: Codeunit "Comprehensive Order Validator";
        CaughtErrorInfo: ErrorInfo;
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        // Arrange - Create order with multiple issues
        TestDataSetup.CreateMultipleValidationIssuesOrder(SalesHeader);
        
        // Act
        ClearLastError();
        asserterror ComprehensiveValidator.ValidateCompleteOrder(SalesHeader);
        CaughtErrorInfo := GetLastErrorObject();
        
        // Assert - Verify multiple errors are reported
        Assert.IsTrue(CaughtErrorInfo.Message.Contains('validation issues found'), 
                     'Should report multiple validation issues');
        
        // Check that specific errors are mentioned in detailed message
        Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Customer'), 
                     'Should mention customer validation error');
        Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Payment terms'), 
                     'Should mention payment terms error');
        Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Document date'), 
                     'Should mention document date error');
        Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Item'), 
                     'Should mention item validation error');
        Assert.IsTrue(CaughtErrorInfo.DetailedMessage.Contains('Quantity'), 
                     'Should mention quantity error');
    end;
    
    [Test]
    procedure TestErrorCollectionOrder()
    var
        OrderWithIssues: Record "Sales Header";
        ValidationErrors: List of [Text];
        ErrorCollector: Codeunit "Error Collector";
        TestDataSetup: Codeunit "Error Test Data Setup";
        ExpectedErrorCount: Integer;
    begin
        // Arrange
        TestDataSetup.CreateOrderWithSpecificIssues(OrderWithIssues, 5); // Create order with exactly 5 issues
        ExpectedErrorCount := 5;
        
        // Act
        ErrorCollector.CollectAllOrderErrors(OrderWithIssues, ValidationErrors);
        
        // Assert
        Assert.AreEqual(ExpectedErrorCount, ValidationErrors.Count, 
                       StrSubstNo('Should collect exactly %1 errors', ExpectedErrorCount));
        
        // Verify error prioritization (critical errors should come first)
        Assert.IsTrue(ValidationErrors.Get(1).Contains('Customer'), 
                     'First error should be customer-related (critical)');
        Assert.IsTrue(ValidationErrors.Get(ValidationErrors.Count).Contains('formatting'), 
                     'Last error should be formatting-related (minor)');
    end;
}
```

## TryFunction Pattern Testing

### Safe Processing Testing

```al
codeunit 80105 "TryFunction Pattern Tests"
{
    Subtype = Test;
    
    [Test]
    procedure TestTryFunctionSuccessScenario()
    var
        SalesHeader: Record "Sales Header";
        SafeProcessor: Codeunit "Safe Order Processor";
        ProcessingResult: Boolean;
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        // Arrange - Create valid order
        TestDataSetup.CreateValidSalesOrder(SalesHeader);
        
        // Act
        ClearLastError();
        ProcessingResult := SafeProcessor.TryProcessOrder(SalesHeader);
        
        // Assert
        Assert.IsTrue(ProcessingResult, 'Processing should succeed for valid order');
        Assert.AreEqual('', GetLastErrorText(), 'No error should be recorded');
    end;
    
    [Test]
    procedure TestTryFunctionFailureScenario()
    var
        SalesHeader: Record "Sales Header";
        SafeProcessor: Codeunit "Safe Order Processor";
        ProcessingResult: Boolean;
        ErrorMessage: Text;
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        // Arrange - Create problematic order
        TestDataSetup.CreateOrderExceedingCreditLimit(SalesHeader);
        
        // Act
        ClearLastError();
        ProcessingResult := SafeProcessor.TryProcessOrder(SalesHeader);
        ErrorMessage := GetLastErrorText();
        
        // Assert
        Assert.IsFalse(ProcessingResult, 'Processing should fail for problematic order');
        Assert.IsTrue(ErrorMessage <> '', 'Error message should be captured');
        Assert.IsTrue(ErrorMessage.Contains('Credit limit'), 
                     'Error should mention credit limit issue');
    end;
    
    [Test]
    procedure TestTryFunctionWithGracefulHandling()
    var
        SalesHeader: Record "Sales Header";
        SafeProcessor: Codeunit "Safe Order Processor";
        HandlingResult: Boolean;
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        // Arrange
        TestDataSetup.CreateOrderWithRecoverableIssue(SalesHeader);
        
        // Act
        HandlingResult := SafeProcessor.ProcessOrderWithGracefulHandling(SalesHeader);
        
        // Assert
        Assert.IsTrue(HandlingResult, 'Should handle recoverable issues gracefully');
        
        // Verify that appropriate recovery actions were taken
        Assert.IsTrue(SafeProcessor.GetRecoveryActionsCount() > 0, 
                     'Should have taken recovery actions');
    end;
}
```

## Performance Testing for Error Handling

### Error Processing Performance

```al
codeunit 80106 "Error Performance Tests"
{
    Subtype = Test;
    
    [Test]
    procedure TestErrorHandlingPerformance()
    var
        StartTime: DateTime;
        EndTime: DateTime;
        Duration: Duration;
        ErrorProcessor: Codeunit "Error Processor";
        TestErrorInfo: ErrorInfo;
        i: Integer;
        MaxDuration: Duration;
    begin
        MaxDuration := 5000; // 5 seconds maximum
        
        // Arrange
        TestErrorInfo.Message := 'Test error for performance testing';
        TestErrorInfo.DetailedMessage := 'This is a detailed error message for performance testing purposes';
        
        // Act
        StartTime := CurrentDateTime;
        
        for i := 1 to 1000 do begin
            ClearLastError();
            ErrorProcessor.ProcessErrorInfo(TestErrorInfo);
        end;
        
        EndTime := CurrentDateTime;
        Duration := EndTime - StartTime;
        
        // Assert
        Assert.IsTrue(Duration < MaxDuration, 
                     StrSubstNo('Error handling took %1ms, should be under %2ms', Duration, MaxDuration));
    end;
    
    [Test]
    procedure TestLargeErrorMessagePerformance()
    var
        LargeErrorMessage: TextBuilder;
        TestErrorInfo: ErrorInfo;
        StartTime: DateTime;
        EndTime: DateTime;
        Duration: Duration;
        i: Integer;
    begin
        // Create large error message
        for i := 1 to 1000 do begin
            LargeErrorMessage.AppendLine(StrSubstNo('Error detail line %1 with additional context information', i));
        end;
        
        TestErrorInfo.Message := 'Large error message test';
        TestErrorInfo.DetailedMessage := LargeErrorMessage.ToText();
        
        // Measure processing time
        StartTime := CurrentDateTime;
        
        ClearLastError();
        asserterror Error(TestErrorInfo);
        
        EndTime := CurrentDateTime;
        Duration := EndTime - StartTime;
        
        // Assert reasonable performance even with large messages
        Assert.IsTrue(Duration < 1000, 'Large error messages should process quickly');
    end;
}
```

## Integration Testing for Error Scenarios

### Cross-Module Error Testing

```al
codeunit 80107 "Integration Error Tests"
{
    Subtype = Test;
    
    [Test]
    procedure TestCrossModuleErrorPropagation()
    var
        SalesHeader: Record "Sales Header";
        InventoryError: ErrorInfo;
        SalesProcessor: Codeunit "Sales Order Processor";
        TestDataSetup: Codeunit "Error Test Data Setup";
    begin
        // Arrange - Create order that will trigger inventory module error
        TestDataSetup.CreateOrderWithInventoryIssues(SalesHeader);
        
        // Act
        ClearLastError();
        asserterror SalesProcessor.ProcessOrderWithInventoryValidation(SalesHeader);
        InventoryError := GetLastErrorObject();
        
        // Assert - Verify error comes from inventory but handled in sales context
        Assert.IsTrue(InventoryError.Message.Contains('inventory'), 
                     'Error should originate from inventory module');
        Assert.IsTrue(InventoryError.HasActions, 
                     'Should have actions even from cross-module error');
        
        // Verify sales-specific actions are added
        AssertActionExists(InventoryError, 'Adjust Order Quantity');
        AssertActionExists(InventoryError, 'Check Item Availability');
    end;
    
    [Test]
    procedure TestExternalServiceErrorHandling()
    var
        ExternalServiceError: ErrorInfo;
        ServiceConnector: Codeunit "External Service Connector";
        TestServiceUrl: Text;
    begin
        // Arrange - Use test service that will fail
        TestServiceUrl := 'https://invalid-test-service.example.com/api/test';
        
        // Act
        ClearLastError();
        asserterror ServiceConnector.ConnectToService(TestServiceUrl);
        ExternalServiceError := GetLastErrorObject();
        
        // Assert
        Assert.IsTrue(ExternalServiceError.Message.Contains('service'), 
                     'Should identify service connectivity issue');
        Assert.IsTrue(ExternalServiceError.DetailedMessage.Contains('timeout') or 
                     ExternalServiceError.DetailedMessage.Contains('connection'), 
                     'Should provide technical details about the failure');
        
        // Verify appropriate recovery actions
        AssertActionExists(ExternalServiceError, 'Retry Connection');
        AssertActionExists(ExternalServiceError, 'Check Service Status');
        AssertActionExists(ExternalServiceError, 'Contact Administrator');
    end;
    
    local procedure AssertActionExists(ErrorInfo: ErrorInfo; ActionCaption: Text)
    var
        ActionFound: Boolean;
        ActionItem: ErrorAction;
        i: Integer;
    begin
        for i := 1 to ErrorInfo.Actions.Count do begin
            ActionItem := ErrorInfo.Actions.Get(i);
            if ActionItem.Caption = ActionCaption then begin
                ActionFound := true;
                break;
            end;
        end;
        
        Assert.IsTrue(ActionFound, 
                     StrSubstNo('Expected action "%1" not found in error actions', ActionCaption));
    end;
}
```

These comprehensive testing examples ensure your error handling is robust, user-friendly, and maintains high quality standards across all scenarios.
