# Error Handling - Complete Guide

<!-- AI_TRIGGER: When developer implements error handling, proactively suggest best practices, modern ErrorInfo patterns, and validation strategies -->
<!-- COPILOT_GUIDANCE: This guide teaches comprehensive error handling from basic principles to modern ErrorInfo patterns with proactive prevention -->

This document provides complete guidance for error handling in Business Central AL development, from basic principles to advanced ErrorInfo patterns.

## How to Use This Guide with Copilot

<!-- AI_INSTRUCTION: When developers work on error handling, proactively suggest:
1. ErrorInfo patterns for actionable error messages with user guidance
2. Error prevention strategies and validation patterns  
3. Progressive error disclosure for technical vs user-facing errors
4. DevOps integration for error monitoring, logging, and continuous improvement
-->

### Prompt Enhancement for Error Handling

<!-- PROMPT_EDUCATION: 
WEAK: "Add error handling"
BETTER: "Implement comprehensive ErrorInfo-based error handling with actionable user messages, suggested recovery actions, progressive error disclosure, logging integration, and DevOps monitoring for improved user experience and system reliability"
EDUCATIONAL_NOTE: "Enhanced prompts specify modern ErrorInfo approach, include user experience (actionable messages, recovery actions), add technical considerations (progressive disclosure, logging), consider monitoring (DevOps), and focus on outcomes. This ensures thorough, modern error handling."
-->

## Table of Contents

1. [Core Error Handling Principles](#core-error-handling-principles)
2. [Modern ErrorInfo Patterns](#modern-errorinfo-patterns)
3. [Progressive Error Disclosure](#progressive-error-disclosure)
4. [Suggested Actions Implementation](#suggested-actions-implementation)
5. [Error Prevention Strategies](#error-prevention-strategies)
6. [Testing Error Handling](#testing-error-handling)
7. [Best Practices Summary](#best-practices-summary)

## Core Error Handling Principles

### 1. Always Provide Actionable Information
Error messages should:
- Clearly explain what went wrong
- Provide context about why it happened  
- Offer guidance on how to fix the problem
- When possible, include actions the user can take directly from the error

### 2. Use Appropriate AL Mechanisms
- Use `Error` for critical errors that should stop processing
- Use `Message` for informational messages that don't stop processing
- Use `Confirm` when user confirmation is required before proceeding
- Use `StrMenu` when the user needs to make a choice

## Modern ErrorInfo Patterns

### Traditional Error Handling (Avoid)
```al
// ❌ Poor user experience - cryptic message
if Customer."Credit Limit" < Amount then
    Error('Credit limit exceeded');

// ❌ No actionable information
Customer.TestField("Payment Terms Code");

// ❌ Technical message exposed to users
if not HttpClient.Get(Url, Response) then
    Error('HTTP GET failed with status %1', Response.HttpStatusCode);
```

### Modern ErrorInfo Patterns (Use)
```al
// ✅ Rich, actionable error information
procedure ValidateCreditLimit(Customer: Record Customer; Amount: Decimal)
var
    CreditLimitError: ErrorInfo;
begin
    if Customer."Credit Limit" < Amount then begin
        CreditLimitError.Message := StrSubstNo('Credit limit of %1 exceeded. Requested amount: %2', 
                                              Customer."Credit Limit", Amount);
        CreditLimitError.DetailedMessage := 'The customer credit limit validation failed. Consider increasing the credit limit or reducing the order amount.';
        CreditLimitError.Verbosity := Verbosity::Normal;
        CreditLimitError.DataClassification := DataClassification::CustomerContent;
        
        // Add suggested actions
        CreditLimitError.AddAction('Increase Credit Limit', Codeunit::"Customer Credit Management", 'IncreaseCreditLimit');
        CreditLimitError.AddAction('Contact Credit Manager', Codeunit::"Customer Credit Management", 'ContactCreditManager');
        CreditLimitError.AddAction('Review Customer History', Codeunit::"Customer Credit Management", 'ReviewCustomerHistory');
        
        Error(CreditLimitError);
    end;
end;
```

## Progressive Error Disclosure

### User-Facing vs Technical Errors

```al
// ✅ Simple message for users, technical details available
procedure ProcessPaymentWithGracefulHandling(PaymentData: Record "Payment Information")
var
    PaymentError: ErrorInfo;
begin
    if not TryProcessPayment(PaymentData) then begin
        // User-friendly message
        PaymentError.Message := 'Payment processing failed. Please try again or contact support.';
        
        // Technical details for troubleshooting
        PaymentError.DetailedMessage := StrSubstNo('Payment gateway returned error: %1. Transaction ID: %2. Timestamp: %3', 
                                                   GetLastErrorText(), PaymentData."Transaction ID", CurrentDateTime);
        
        // Context-aware actions
        PaymentError.AddAction('Retry Payment', Codeunit::"Payment Processor", 'RetryPayment');
        PaymentError.AddAction('Use Alternative Method', Codeunit::"Payment Processor", 'ShowAlternativeMethods');
        PaymentError.AddAction('Contact Support', Codeunit::"Payment Processor", 'ContactSupport');
        
        Error(PaymentError);
    end;
end;
```

## Suggested Actions Implementation

### Action Implementation Pattern
```al
codeunit 50100 "Customer Credit Management"
{
    procedure IncreaseCreditLimit()
    var
        CustomerCard: Page "Customer Card";
        Customer: Record Customer;
    begin
        if Customer.Get(GetContextCustomerNo()) then begin
            Customer.SetRecFilter();
            CustomerCard.SetTableView(Customer);
            CustomerCard.RunModal();
        end;
    end;
    
    procedure ContactCreditManager()
    var
        EmailDialog: Page "Email Dialog";
        CreditManager: Text;
    begin
        CreditManager := GetCreditManagerEmail();
        if CreditManager <> '' then begin
            EmailDialog.SetPredefinedContent(CreditManager, 
                'Credit Limit Review Required', 
                CreateCreditLimitEmailBody());
            EmailDialog.RunModal();
        end;
    end;
    
    procedure ReviewCustomerHistory()
    var
        CustomerLedgerEntries: Page "Customer Ledger Entries";
        Customer: Record Customer;
    begin
        if Customer.Get(GetContextCustomerNo()) then begin
            CustomerLedgerEntries.SetTableView(Customer);
            CustomerLedgerEntries.Run();
        end;
    end;
}
```

## Error Prevention Strategies

### 1. Validate Input Parameters
```al
// ✅ Clear, contextual validation
procedure ValidateCustomerEmail(Customer: Record Customer)
var
    ValidationError: ErrorInfo;
begin
    if Customer."E-Mail" = '' then begin
        ValidationError.Message := StrSubstNo('Customer %1 requires an email address for this operation', Customer."No.");
        ValidationError.DetailedMessage := 'Email address is required for sending invoices and notifications.';
        ValidationError.AddAction('Open Customer Card', Codeunit::"Customer Management", 'OpenCustomerCard');
        Error(ValidationError);
    end;
end;
```

### 2. Use TryFunction Pattern
```al
[TryFunction]
local procedure TryProcessOrder(var SalesHeader: Record "Sales Header")
begin
    ValidateOrderData(SalesHeader);
    ProcessOrderLogic(SalesHeader);
end;

// In calling code:
if not TryProcessOrder(SalesHeader) then begin
    // Handle error with ErrorInfo pattern
    HandleProcessingError(SalesHeader);
end;
```

### 3. Collectible Error Patterns
```al
procedure ValidateOrderData(var SalesHeader: Record "Sales Header")
var
    ValidationErrors: List of [ErrorInfo];
    ValidationError: ErrorInfo;
begin
    // Collect all validation errors instead of failing on first
    CollectCustomerValidationErrors(SalesHeader, ValidationErrors);
    CollectItemValidationErrors(SalesHeader, ValidationErrors);
    CollectPaymentValidationErrors(SalesHeader, ValidationErrors);
    
    if ValidationErrors.Count > 0 then begin
        // Create summary error with all issues
        ValidationError.Message := StrSubstNo('%1 validation errors found. Please review and correct:', ValidationErrors.Count);
        ValidationError.DetailedMessage := BuildValidationSummary(ValidationErrors);
        
        // Add actions to fix common issues
        ValidationError.AddAction('Open Customer Card', Codeunit::"Order Validation Actions", 'OpenCustomerCard');
        ValidationError.AddAction('Validate All Items', Codeunit::"Order Validation Actions", 'ValidateItems');
        ValidationError.AddAction('Review Order', Codeunit::"Order Validation Actions", 'ReviewOrder');
        
        Error(ValidationError);
    end;
end;
```

## Testing Error Handling

### Testing ErrorInfo Patterns
```al
[Test]
procedure TestCreditLimitErrorInfo()
var
    Customer: Record Customer;
    CreditValidator: Codeunit "Credit Limit Validator";
    ErrorInfo: ErrorInfo;
begin
    // Setup customer with limited credit
    Customer.Init();
    Customer."No." := 'TEST001';
    Customer."Credit Limit" := 1000;
    Customer.Insert();
    
    // Test error collection
    asserterror CreditValidator.ValidateCreditLimit(Customer, 1500);
    
    // Verify ErrorInfo was used (not basic Error)
    ErrorInfo := GetLastErrorObject();
    Assert.IsTrue(ErrorInfo.Message <> '', 'ErrorInfo message should be populated');
    Assert.IsTrue(ErrorInfo.DetailedMessage <> '', 'Detailed message should be provided');
    Assert.AreEqual(3, ErrorInfo.Actions.Count, 'Should have 3 suggested actions');
end;
```

## Best Practices Summary

### 1. Always Provide Context
```al
// ✅ Good - Provides business context
Error('Cannot post sales order %1 because customer %2 has exceeded credit limit of %3', 
      OrderNo, CustomerNo, CreditLimit);

// ❌ Avoid - Generic message
Error('Validation failed');
```

### 2. Include Recovery Actions
```al
// ✅ Good - Tells user what they can do
ErrorInfo.AddAction('Increase Credit Limit', Codeunit::Actions, 'IncreaseCreditLimit');
ErrorInfo.AddAction('Split Order', Codeunit::Actions, 'SplitOrder');

// ❌ Avoid - No guidance for resolution
Error('Credit limit exceeded');
```

### 3. Use Progressive Disclosure
```al
// ✅ Good - Simple message, detailed technical info available
ErrorInfo.Message := 'Payment processing failed';
ErrorInfo.DetailedMessage := 'Gateway returned HTTP 502: Bad Gateway. Connection timeout after 30 seconds.';
```

### 4. Add Telemetry for Analysis
```al
// ✅ Good - Log errors for continuous improvement
Session.LogMessage('PaymentProcessing', 
                  StrSubstNo('Payment failed: %1', ErrorInfo.Message), 
                  Verbosity::Error, 
                  DataClassification::CustomerContent, 
                  TelemetryScope::ExtensionPublisher);
```

### 5. Avoid Silent Failures
```al
// ❌ Avoid - Silent failure hides problems
procedure SyncCustomerData()
begin
    if not TryCallExternalAPI() then
        exit; // Silent failure - no logging, no user notification
end;

// ✅ Good - Explicit error handling with logging
procedure SyncCustomerData()
var
    ErrorMessage: Text;
begin
    if not TryCallExternalAPI() then begin
        ErrorMessage := GetLastErrorText();
        Session.LogMessage('CustomerSync', ErrorMessage, Verbosity::Error, 
                          DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher);
        
        Message('Customer synchronization failed. The issue has been logged for review.');
    end;
end;
```

## Cross-References

### Related Guidelines
- **Code Style**: `coding-standards.md` - Error message formatting and style standards
- **Naming Conventions**: `naming-conventions.md` - Error variable and message naming
- **Testing Strategy**: `../testing-validation/testing-strategy.md` - Testing error scenarios
- **Performance**: `../performance-optimization/optimization-guide.md` - Error handling performance

### Workflow Applications
- **CoreDevelopment**: Essential error handling patterns for all AL objects
- **TestingValidation**: Error scenario testing and validation approaches
- **AppSourcePublishing**: Error handling compliance for marketplace requirements
- **DevOpsIntegration**: Error logging, monitoring, and continuous improvement
