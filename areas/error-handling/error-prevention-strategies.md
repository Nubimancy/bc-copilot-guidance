---
title: "Error Prevention Strategies"
description: "Proactive strategies to prevent errors through validation, try patterns, and defensive programming"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "prevention", "validation", "defensive-programming"]
---

# Error Prevention Strategies

## Overview

Error prevention is more valuable than error handling. By implementing proactive validation, defensive coding patterns, and comprehensive input checking, you can prevent many errors from occurring in the first place.

## Core Prevention Strategies

### 1. Input Validation at Entry Points

Validate all inputs at the earliest possible point:

```al
procedure ProcessCustomerOrder(CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal)
begin
    // Validate immediately at entry
    ValidateCustomerExists(CustomerNo);
    ValidateItemExists(ItemNo);
    ValidateQuantityPositive(Quantity);
    
    // Continue with processing...
end;
```

**Benefits:**
- Fails fast with clear context
- Prevents cascading errors downstream
- Reduces debugging time
- Provides immediate feedback to users

### 2. Parameter Validation Pattern

Create consistent validation methods for common scenarios:

```al
procedure ValidateCustomerForOperation(Customer: Record Customer; OperationType: Text)
var
    ValidationError: ErrorInfo;
begin
    if Customer."No." = '' then
        ThrowValidationError('Customer number is required for ' + OperationType);
        
    if Customer.Blocked <> Customer.Blocked::" " then
        ThrowValidationError(StrSubstNo('Customer %1 is blocked and cannot be used for %2', 
                                       Customer."No.", OperationType));
                                       
    if (OperationType = 'SALES') and (Customer."Credit Limit" <= 0) then
        ThrowValidationError(StrSubstNo('Customer %1 has no credit limit set for sales operations', 
                                       Customer."No."));
end;
```

### 3. Defensive Null Checking

Always check for empty or null values before processing:

```al
procedure ProcessCustomerEmail(Customer: Record Customer)
begin
    // Defensive check
    if Customer."E-Mail" = '' then
        exit; // Graceful exit for optional operations
        
    // OR throw informative error for required operations
    if Customer."E-Mail" = '' then
        Error('Email address is required for this customer operation');
        
    // Continue processing...
end;
```

### 4. Range and Boundary Validation

Validate numeric inputs are within expected ranges:

```al
procedure ValidateDiscountPercentage(DiscountPct: Decimal)
begin
    if (DiscountPct < 0) or (DiscountPct > 100) then
        Error('Discount percentage must be between 0 and 100. Current value: %1', DiscountPct);
end;

procedure ValidateQuantity(Quantity: Decimal; Context: Text)
begin
    if Quantity <= 0 then
        Error('Quantity must be positive for %1. Current value: %2', Context, Quantity);
        
    if Quantity > 999999 then
        Error('Quantity is too large for %1. Maximum allowed: 999,999', Context);
end;
```

## Advanced Prevention Patterns

### 1. TryFunction Pattern

Use try functions to handle potential failures gracefully:

```al
[TryFunction]
procedure TryValidateAndProcess(var SalesHeader: Record "Sales Header")
begin
    ValidateCustomerData(SalesHeader);
    ValidateLineData(SalesHeader);
    ProcessOrder(SalesHeader);
end;

// In calling code
procedure SafeOrderProcessing(var SalesHeader: Record "Sales Header")
begin
    if not TryValidateAndProcess(SalesHeader) then
        HandleOrderProcessingError(SalesHeader, GetLastErrorText());
end;
```

### 2. Collectible Error Pattern

Collect multiple validation errors instead of stopping at the first one:

```al
procedure ComprehensiveOrderValidation(var SalesHeader: Record "Sales Header")
var
    ValidationIssues: List of [Text];
    ErrorSummary: ErrorInfo;
begin
    // Collect all issues
    CollectCustomerIssues(SalesHeader, ValidationIssues);
    CollectItemIssues(SalesHeader, ValidationIssues);
    CollectPricingIssues(SalesHeader, ValidationIssues);
    CollectShippingIssues(SalesHeader, ValidationIssues);
    
    // Report all issues at once
    if ValidationIssues.Count > 0 then begin
        ErrorSummary.Message := StrSubstNo('%1 validation issues found', ValidationIssues.Count);
        ErrorSummary.DetailedMessage := BuildIssuesSummary(ValidationIssues);
        ErrorSummary.AddAction('Fix All Issues', Codeunit::"Order Fix Management", 'FixAllIssues');
        Error(ErrorSummary);
    end;
end;
```

### 3. Early Warning System

Implement warnings for potential issues before they become errors:

```al
procedure CheckPotentialIssues(SalesHeader: Record "Sales Header")
begin
    // Warn about approaching credit limits
    if GetRemainingCreditLimit(SalesHeader."Sell-to Customer No.") < (SalesHeader."Amount Including VAT" * 1.1) then
        Message('Warning: This order will use most of the customer''s available credit limit.');
        
    // Warn about low inventory
    CheckInventoryLevels(SalesHeader);
    
    // Warn about delivery date issues
    CheckDeliveryFeasibility(SalesHeader);
end;
```

## Business Logic Protection

### 1. State Validation

Validate object state before operations:

```al
procedure ProcessSalesOrder(var SalesHeader: Record "Sales Header")
begin
    // Validate state before processing
    case SalesHeader.Status of
        SalesHeader.Status::Open:
            ; // OK to process
        SalesHeader.Status::Released:
            Error('Cannot modify released sales order %1', SalesHeader."No.");
        SalesHeader.Status::"Pending Approval":
            Error('Sales order %1 is pending approval and cannot be processed', SalesHeader."No.");
        else
            Error('Sales order %1 is in an invalid state for processing', SalesHeader."No.");
    end;
    
    // Continue with processing...
end;
```

### 2. Dependency Validation

Check required dependencies exist and are valid:

```al
procedure ValidateOrderDependencies(SalesHeader: Record "Sales Header")
begin
    // Check customer exists and is valid
    ValidateCustomerForSales(SalesHeader."Sell-to Customer No.");
    
    // Check payment terms are configured
    ValidatePaymentTerms(SalesHeader."Payment Terms Code");
    
    // Check shipping method is available
    ValidateShippingMethod(SalesHeader."Shipment Method Code");
    
    // Check all line items are valid
    ValidateAllOrderLines(SalesHeader);
end;
```

### 3. Configuration Validation

Validate system configuration before operations:

```al
procedure ValidateSystemConfiguration(OperationType: Text)
var
    SalesSetup: Record "Sales & Receivables Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
begin
    SalesSetup.Get();
    
    case OperationType of
        'ORDER':
            if SalesSetup."Order Nos." = '' then
                Error('Sales Order number series is not configured. Please contact your administrator.');
        'INVOICE':
            if SalesSetup."Invoice Nos." = '' then
                Error('Sales Invoice number series is not configured. Please contact your administrator.');
    end;
    
    // Validate number series is active and has available numbers
    if not NoSeriesManagement.IsNoSeriesActive(SalesSetup."Order Nos.") then
        Error('Sales Order number series %1 is not active', SalesSetup."Order Nos.");
end;
```

## Implementation Guidelines

### 1. Validation Layer Architecture

Structure your validation in layers:
- **Entry Point Validation** - Parameters and basic requirements
- **Business Rule Validation** - Domain-specific rules
- **System Validation** - Configuration and dependencies
- **State Validation** - Object state and workflow rules

### 2. Consistent Error Messaging

Create standard validation error formats:
```al
procedure StandardValidationError(FieldName: Text; Value: Text; Requirement: Text): Text
begin
    exit(StrSubstNo('%1 value "%2" %3', FieldName, Value, Requirement));
end;

// Usage:
Error(StandardValidationError('Credit Limit', Format(CreditLimit), 'must be greater than zero'));
```

### 3. Performance Considerations

Balance thorough validation with performance:
- **Cache validation results** for expensive checks
- **Use early exit patterns** to avoid unnecessary validation
- **Batch validate** multiple items when possible
- **Consider async validation** for non-blocking scenarios

## Benefits of Prevention

### User Experience
- Fewer frustrating error encounters
- More predictable system behavior
- Faster task completion

### Development Efficiency
- Less time debugging production issues
- Clearer code with explicit assumptions
- Easier maintenance and testing

### System Reliability
- Reduced support tickets
- More stable system behavior
- Better data integrity

### Business Impact
- Higher user adoption
- Improved productivity
- Lower operational costs

Prevention-focused error handling transforms your AL code from reactive to proactive, creating more reliable and user-friendly business applications.
