---
title: "Testing Workflow Integration - Code Samples"
description: "Complete code examples for integrating testing into development workflows with AI assistance"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: []
tags: ["testing-workflow", "ai-prompting", "devops", "samples", "test-organization"]
---

# Testing Workflow Integration - Code Samples

## AI-Assisted Test Generation Examples

### Effective AI Prompts for Test Creation

```al
// INSTEAD OF: Generic prompt
"Add tests for this function"

// USE: Comprehensive, specific prompt
"Create comprehensive test suite for loyalty point calculation including:
- Positive scenarios for each customer tier (Standard, VIP, Premium)
- Boundary conditions for amount thresholds (0, 0.01, 999.99, 1000.00, 1000.01)
- Error scenarios for blocked customers and invalid data
- Integration testing with external point systems including mock API responses"

// INSTEAD OF: Vague request
"Test the business logic"

// USE: Detailed coverage request
"Create tests covering:
1. Normal business flow: customer order → point calculation → balance update
2. Edge cases at tier boundaries and promotion periods
3. Error conditions for invalid data, blocked customers, expired promotions
4. Integration scenarios with external APIs including mock setup and failure handling"
```

### Test Coverage Analysis with AI

```al
// Ask AI to analyze your business logic:
/* AI PROMPT: 
"Review this AL business logic and identify missing test scenarios:
[paste your business logic code here]
Consider positive cases, boundary conditions, error scenarios, and integration points."
*/

/* AI PROMPT:
"What boundary conditions should I test for this customer discount calculation?
The business rules are:
- Standard customers: no discount
- VIP customers: 10% discount on orders > $500
- Premium customers: 15% discount on all orders
- Maximum discount cap: $1000 per order"
*/

/* AI PROMPT:
"What error scenarios am I missing for this order validation logic?
Current tests cover: valid orders, quantity limits, credit limits.
What other failure modes should I consider?"
*/
```

## Test Organization by Business Domain

```al
// Business-focused test organization
codeunit 50500 "Customer Loyalty Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    // Group tests by business scenario, not technical structure
    [Test]
    procedure TestStandardCustomerLoyaltyFlow()
    begin
        // Test complete business flow for standard customers
        ValidateStandardCustomerPointAccrual();
        ValidateStandardCustomerRedemption();
        ValidateStandardCustomerExpiration();
    end;
    
    [Test]
    procedure TestVIPCustomerLoyaltyFlow()
    begin
        // Test VIP-specific business rules
        ValidateVIPBonusMultiplier();
        ValidateVIPExclusiveRewards();
        ValidateVIPTierMaintenance();
    end;
    
    [Test]
    procedure TestLoyaltyBoundaryConditions()
    begin
        // Test edge cases across all customer types
        TestMinimumPointAccrual();
        TestMaximumPointLimits();
        TestTierTransitionBoundaries();
    end;
}

codeunit 50501 "Order Processing Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestCompleteOrderLifecycle()
    begin
        // Test full business process
        TestOrderCreation();
        TestInventoryReservation();
        TestPricingCalculation();
        TestShippingCoordination();
        TestPaymentProcessing();
        TestOrderFulfillment();
    end;
    
    [Test]
    procedure TestOrderErrorScenarios()
    begin
        // Test all failure modes in order processing
        TestInsufficientInventory();
        TestCreditLimitExceeded();
        TestInvalidShippingAddress();
        TestPaymentDeclined();
    end;
}
```

## Documented Test Scenarios

```al
codeunit 50502 "Payment Processing Tests"
{
    /* 
    TEST DOCUMENTATION:
    
    Business Scenarios Covered:
    1. Standard Payment Flow
       - Credit card processing
       - Bank transfer processing
       - Payment confirmation workflow
    
    2. Error Scenarios
       - Declined transactions
       - Network timeouts
       - Invalid payment methods
       - Insufficient funds
    
    3. Integration Points
       - Payment gateway API
       - Banking system integration
       - Fraud detection service
       - Compliance validation
    
    Coverage Matrix:
    - Payment Methods: Credit Card, Bank Transfer, Digital Wallet
    - Transaction Types: One-time, Recurring, Refund
    - Error Conditions: All decline reasons, technical failures
    - Compliance: PCI DSS, regional regulations
    */
    
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    [TestDescription('Validates standard credit card payment processing with successful authorization and capture')]
    procedure TestCreditCardPaymentSuccess()
    var
        PaymentProcessor: Codeunit "Payment Processor";
        PaymentRequest: Record "Payment Request";
        PaymentResult: Record "Payment Result";
    begin
        // Arrange: Standard credit card payment scenario
        CreateValidCreditCardPayment(PaymentRequest, 100.00);
        MockPaymentGatewayResponse('APPROVED');
        
        // Act: Process payment
        PaymentProcessor.ProcessPayment(PaymentRequest, PaymentResult);
        
        // Assert: Payment completed successfully
        Assert.AreEqual('APPROVED', PaymentResult.Status, 'Payment should be approved');
        Assert.AreEqual(100.00, PaymentResult."Amount Charged", 'Charged amount should match request');
        Assert.IsTrue(PaymentResult."Transaction ID" <> '', 'Transaction ID should be populated');
    end;
    
    [Test]
    [TestDescription('Validates payment decline handling with appropriate error messaging')]
    procedure TestPaymentDeclinedScenario()
    var
        PaymentProcessor: Codeunit "Payment Processor";
        PaymentRequest: Record "Payment Request";
        PaymentResult: Record "Payment Result";
    begin
        // Arrange: Payment that will be declined
        CreateValidCreditCardPayment(PaymentRequest, 500.00);
        MockPaymentGatewayResponse('DECLINED_INSUFFICIENT_FUNDS');
        
        // Act: Attempt payment processing
        PaymentProcessor.ProcessPayment(PaymentRequest, PaymentResult);
        
        // Assert: Decline handled gracefully
        Assert.AreEqual('DECLINED', PaymentResult.Status, 'Payment should be declined');
        Assert.AreEqual('Insufficient funds', PaymentResult."Error Message", 'User-friendly error message');
        Assert.AreEqual('', PaymentResult."Transaction ID", 'No transaction ID for declined payment');
    end;
}
```

## DevOps Integration Examples

```al
codeunit 50503 "Test Execution Helper"
{
    // Helper for CI/CD pipeline integration
    
    procedure RunBusinessLogicTestSuite(): Boolean
    var
        TestRunner: TestRequestPage;
        TestSuite: List of [Text];
    begin
        // Define business-critical test suites for CI/CD
        TestSuite.Add('Customer Loyalty Tests');
        TestSuite.Add('Order Processing Tests');
        TestSuite.Add('Payment Processing Tests');
        TestSuite.Add('Inventory Management Tests');
        
        // Execute test suites and capture results
        exit(ExecuteTestSuites(TestSuite));
    end;
    
    procedure GenerateTestCoverageReport(): Text
    var
        CoverageAnalyzer: Codeunit "Coverage Analyzer";
        BusinessAreas: List of [Text];
        Area: Text;
        CoverageReport: Text;
    begin
        BusinessAreas.Add('Customer Management');
        BusinessAreas.Add('Order Processing');
        BusinessAreas.Add('Inventory Control');
        BusinessAreas.Add('Financial Processing');
        
        CoverageReport := 'TEST COVERAGE REPORT' + '\n';
        CoverageReport += '=====================' + '\n\n';
        
        foreach Area in BusinessAreas do begin
            CoverageReport += StrSubstNo('%1: %2%% coverage\n', 
                Area, CoverageAnalyzer.GetCoveragePercentage(Area));
        end;
        
        exit(CoverageReport);
    end;
}
```

## Test-First Development Pattern

```al
codeunit 50504 "New Feature Test Template"
{
    /* 
    TEST-FIRST DEVELOPMENT TEMPLATE
    
    Use this template when developing new features:
    1. Write tests for expected behavior FIRST
    2. Implement minimal code to make tests pass
    3. Refactor while keeping tests green
    4. Add edge cases and error scenarios
    5. Document business rules in test descriptions
    */
    
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    [TestDescription('FEATURE: Customer subscription renewal - Happy path scenario')]
    procedure TestSubscriptionRenewalSuccess()
    var
        SubscriptionManager: Codeunit "Subscription Manager"; // TO BE IMPLEMENTED
        Customer: Record Customer;
        Subscription: Record "Customer Subscription"; // TO BE IMPLEMENTED
    begin
        // Arrange: Customer with expiring subscription
        CreateCustomerWithExpiringSubscription(Customer, Subscription);
        
        // Act: Renew subscription
        SubscriptionManager.RenewSubscription(Subscription);
        
        // Assert: Subscription renewed successfully
        Subscription.Get(Subscription."Subscription ID");
        Assert.AreEqual(CalcDate('<1Y>', Today), Subscription."Expiration Date", 
            'Subscription should be renewed for one year');
        Assert.AreEqual('ACTIVE', Subscription.Status, 'Subscription should be active');
    end;
    
    [Test]
    [TestDescription('FEATURE: Customer subscription renewal - Payment failure scenario')]
    procedure TestSubscriptionRenewalPaymentFailure()
    var
        SubscriptionManager: Codeunit "Subscription Manager"; // TO BE IMPLEMENTED
        Customer: Record Customer;
        Subscription: Record "Customer Subscription"; // TO BE IMPLEMENTED
    begin
        // Arrange: Customer with expired payment method
        CreateCustomerWithExpiredPaymentMethod(Customer, Subscription);
        
        // Act & Assert: Renewal should fail with payment error
        asserterror SubscriptionManager.RenewSubscription(Subscription);
        Assert.ExpectedError('Payment method expired. Please update payment information.');
    end;
}
```

## Related Topics
- [Testing Workflow Integration](testing-workflow-integration.md)
- [Business Logic Testing Patterns](business-logic-testing-patterns.md)
- [Test Data Management](test-data-management.md)
