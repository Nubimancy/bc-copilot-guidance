---
title: "Business Logic Testing Patterns - Code Samples"
description: "Complete code examples for comprehensive business logic testing in AL"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", ]
tags: ["business-logic", "testing-patterns", "samples", "comprehensive-testing"]
---

# Business Logic Testing Patterns - Code Samples

## Advanced Testing with Comprehensive Scenario Coverage

```al
codeunit 50200 "BRC Loyalty Points Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestPointsAccrualCalculation()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        LoyaltyCalculator: Codeunit "BRC Loyalty Calculator";
        ExpectedPoints: Integer;
        ActualPoints: Integer;
    begin
        // Arrange: Customer with specific tier and purchase amount
        CreateTierTwoCustomer(Customer);
        CreateSalesOrderWithAmount(SalesHeader, Customer."No.", 1000);
        ExpectedPoints := 50; // 5% of 1000 for tier 2 customer
        
        // Act: Calculate loyalty points
        ActualPoints := LoyaltyCalculator.CalculatePoints(SalesHeader);
        
        // Assert: Points match expected calculation
        Assert.AreEqual(ExpectedPoints, ActualPoints, 
            'Points calculation incorrect for tier 2 customer');
    end;
    
    [Test]
    procedure TestValidBusinessScenario()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        OrderProcessor: Codeunit "Order Processor";
    begin
        // Arrange: Set up normal, expected conditions
        CreateStandardCustomer(Customer);
        CreateNormalSalesOrder(SalesHeader, Customer."No.");
        
        // Act: Execute business logic
        OrderProcessor.ProcessBusinessTransaction(SalesHeader);
        
        // Assert: Verify expected outcomes
        Assert.IsTrue(TransactionCompleted(SalesHeader), 'Normal scenario should succeed');
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'Order should be released');
    end;
}
```

## Multi-Dimensional Business Logic Testing

```al
codeunit 50201 "Discount Calculation Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestDiscountCalculationAllScenarios()
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        DiscountCalculator: Codeunit "Discount Calculator";
        TestScenarios: List of [Text];
        Scenario: Text;
    begin
        // Test multiple business scenarios
        TestScenarios.Add('STANDARD_CUSTOMER');
        TestScenarios.Add('VIP_CUSTOMER');
        TestScenarios.Add('BULK_ORDER');
        TestScenarios.Add('PROMOTIONAL_PERIOD');
        
        foreach Scenario in TestScenarios do begin
            // Arrange scenario-specific data
            SetupScenario(Scenario, Customer, SalesLine);
            
            // Act: Apply business logic
            DiscountCalculator.CalculateDiscount(SalesLine);
            
            // Assert: Verify scenario-specific outcomes
            ValidateScenarioResult(Scenario, SalesLine);
        end;
    end;
    
    local procedure SetupScenario(Scenario: Text; var Customer: Record Customer; var SalesLine: Record "Sales Line")
    begin
        case Scenario of
            'STANDARD_CUSTOMER':
                begin
                    CreateStandardCustomer(Customer);
                    CreateSalesLineWithQuantity(SalesLine, Customer."No.", 5);
                end;
            'VIP_CUSTOMER':
                begin
                    CreateVIPCustomer(Customer);
                    CreateSalesLineWithQuantity(SalesLine, Customer."No.", 5);
                end;
            'BULK_ORDER':
                begin
                    CreateStandardCustomer(Customer);
                    CreateSalesLineWithQuantity(SalesLine, Customer."No.", 100);
                end;
            'PROMOTIONAL_PERIOD':
                begin
                    SetPromotionalPeriod(true);
                    CreateStandardCustomer(Customer);
                    CreateSalesLineWithQuantity(SalesLine, Customer."No.", 10);
                end;
        end;
    end;
    
    local procedure ValidateScenarioResult(Scenario: Text; SalesLine: Record "Sales Line")
    begin
        case Scenario of
            'STANDARD_CUSTOMER':
                Assert.AreEqual(0, SalesLine."Line Discount %", 'Standard customer should get no discount');
            'VIP_CUSTOMER':
                Assert.AreEqual(10, SalesLine."Line Discount %", 'VIP customer should get 10% discount');
            'BULK_ORDER':
                Assert.AreEqual(5, SalesLine."Line Discount %", 'Bulk order should get 5% discount');
            'PROMOTIONAL_PERIOD':
                Assert.AreEqual(15, SalesLine."Line Discount %", 'Promotional period should get 15% discount');
        end;
    end;
}
```

## State Transition Testing

```al
codeunit 50202 "Document Workflow Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestDocumentStatusTransitions()
    var
        PurchaseHeader: Record "Purchase Header";
        WorkflowManager: Codeunit "Workflow Manager";
        ValidTransitions: List of [Text];
        Transition: Text;
    begin
        // Test all valid state transitions
        ValidTransitions.Add('DRAFT_TO_PENDING');
        ValidTransitions.Add('PENDING_TO_APPROVED');
        ValidTransitions.Add('APPROVED_TO_RELEASED');
        ValidTransitions.Add('RELEASED_TO_COMPLETED');
        
        foreach Transition in ValidTransitions do begin
            // Arrange: Set up document in initial state
            CreateDocumentInState(PurchaseHeader, GetInitialState(Transition));
            
            // Act: Attempt state transition
            ExecuteTransition(WorkflowManager, PurchaseHeader, Transition);
            
            // Assert: Verify successful transition
            Assert.AreEqual(GetExpectedState(Transition), PurchaseHeader.Status, 
                StrSubstNo('Transition %1 should succeed', Transition));
        end;
    end;
    
    [Test]
    procedure TestInvalidStateTransitions()
    var
        PurchaseHeader: Record "Purchase Header";
        WorkflowManager: Codeunit "Workflow Manager";
        InvalidTransitions: List of [Text];
        Transition: Text;
    begin
        // Test invalid state transitions
        InvalidTransitions.Add('DRAFT_TO_COMPLETED');
        InvalidTransitions.Add('PENDING_TO_RELEASED');
        InvalidTransitions.Add('COMPLETED_TO_DRAFT');
        
        foreach Transition in InvalidTransitions do begin
            // Arrange: Set up document in initial state
            CreateDocumentInState(PurchaseHeader, GetInitialState(Transition));
            
            // Act & Assert: Should fail with appropriate error
            asserterror ExecuteTransition(WorkflowManager, PurchaseHeader, Transition);
            Assert.ExpectedError(GetExpectedTransitionError(Transition));
        end;
    end;
}
```

## Complex Business Rule Testing

```al
codeunit 50203 "Credit Limit Validation Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestCreditLimitEnforcement()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CreditManager: Codeunit "Credit Manager";
        TestAmounts: List of [Decimal];
        TestAmount: Decimal;
    begin
        // Arrange: Customer with $1000 credit limit
        CreateCustomerWithCreditLimit(Customer, 1000);
        
        // Test various order amounts
        TestAmounts.Add(500);   // Within limit
        TestAmounts.Add(1000);  // At limit
        TestAmounts.Add(1001);  // Over limit
        
        foreach TestAmount in TestAmounts do begin
            // Arrange: Create order with test amount
            CreateSalesOrderWithAmount(SalesHeader, Customer."No.", TestAmount);
            
            if TestAmount <= 1000 then begin
                // Act & Assert: Should succeed for amounts within limit
                Assert.IsTrue(CreditManager.ValidateCreditLimit(SalesHeader),
                    StrSubstNo('Order for %1 should be approved', TestAmount));
            end else begin
                // Act & Assert: Should fail for amounts over limit
                Assert.IsFalse(CreditManager.ValidateCreditLimit(SalesHeader),
                    StrSubstNo('Order for %1 should be rejected', TestAmount));
            end;
        end;
    end;
}
```

## Related Topics
- [Business Logic Testing Patterns](business-logic-testing-patterns.md)
- [Boundary Condition Testing](boundary-condition-testing.md)
- [Test Data Management](test-data-management.md)
