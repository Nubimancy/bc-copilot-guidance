---
title: "Suggested Actions Implementation"
description: "Implementing suggested actions in ErrorInfo to provide users with direct resolution paths"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit", "Page"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "suggested-actions", "user-experience", "errorinfo"]
---

# Suggested Actions Implementation

## Overview

Suggested Actions in ErrorInfo provide users with direct, actionable buttons in error dialogs, transforming passive error messages into active problem-solving tools. This pattern significantly improves user experience by offering immediate resolution paths.

## Core Concept

Instead of just telling users what went wrong, suggested actions let them fix the problem directly from the error dialog:

- **Traditional approach**: "Credit limit exceeded" → User must figure out what to do
- **Suggested actions approach**: "Credit limit exceeded" + [Increase Credit Limit] + [Contact Credit Manager] buttons

## Implementation Pattern

### Basic Structure

```al
procedure ThrowErrorWithActions()
var
    CreditError: ErrorInfo;
begin
    CreditError.Message := 'Credit limit exceeded';
    CreditError.DetailedMessage := 'The customer credit limit validation failed. Choose an action below to resolve.';
    
    // Add suggested actions
    CreditError.AddAction('Increase Credit Limit', Codeunit::"Customer Credit Management", 'IncreaseCreditLimit');
    CreditError.AddAction('Contact Credit Manager', Codeunit::"Customer Credit Management", 'ContactCreditManager');
    CreditError.AddAction('Review Customer History', Codeunit::"Customer Credit Management", 'ReviewCustomerHistory');
    
    Error(CreditError);
end;
```

### Action Handler Codeunit

Create dedicated codeunits to handle suggested actions:

```al
codeunit 50100 "Customer Credit Management"
{
    procedure IncreaseCreditLimit()
    begin
        // Open Customer Card for credit limit modification
        OpenCustomerCardForCreditLimit();
    end;
    
    procedure ContactCreditManager()
    begin
        // Open email dialog with pre-filled content
        SendCreditLimitReviewRequest();
    end;
    
    procedure ReviewCustomerHistory()
    begin
        // Open Customer Ledger Entries
        ShowCustomerLedgerEntries();
    end;
}
```

## Design Principles

### 1. Action Relevance
Each suggested action should be directly related to resolving the specific error:
- **Contextual** - Actions match the error scenario
- **Specific** - Avoid generic "Contact Administrator" actions
- **Prioritized** - Most likely resolution first

### 2. Action Clarity
Use clear, action-oriented labels:
- ✅ "Increase Credit Limit" (specific action)
- ❌ "Credit Limit" (vague)
- ✅ "Contact Credit Manager" (clear recipient)
- ❌ "Get Help" (generic)

### 3. Progressive Assistance
Order actions from most to least autonomous:
1. **Self-service** - Actions users can complete themselves
2. **Guided assistance** - Actions that provide help or guidance
3. **Escalation** - Actions that involve others (managers, IT, etc.)

## Context Management

### Passing Context to Actions

Use session variables or parameters to pass context:

```al
procedure ValidateOrderWithContext(SalesHeader: Record "Sales Header")
var
    OrderError: ErrorInfo;
begin
    if SalesHeader."Amount Including VAT" > GetCreditLimit(SalesHeader."Sell-to Customer No.") then begin
        // Store context for action handlers
        SetErrorContext(SalesHeader."Sell-to Customer No.", SalesHeader."No.");
        
        OrderError.Message := 'Order exceeds credit limit';
        OrderError.AddAction('Adjust Order Amount', Codeunit::"Order Management", 'AdjustOrderAmount');
        OrderError.AddAction('Request Credit Increase', Codeunit::"Credit Management", 'RequestCreditIncrease');
        
        Error(OrderError);
    end;
end;
```

## Common Patterns

### Configuration Errors
```al
// Configuration missing or invalid
ConfigError.AddAction('Open Setup Page', Codeunit::"Setup Management", 'OpenSetupPage');
ConfigError.AddAction('Run Setup Wizard', Codeunit::"Setup Management", 'RunSetupWizard');
```

### Data Validation Errors
```al
// Required field missing
ValidationError.AddAction('Open Record', Codeunit::"Record Management", 'OpenRecord');
ValidationError.AddAction('Fill Required Fields', Codeunit::"Record Management", 'FillRequiredFields');
```

### Permission Errors
```al
// Access denied
PermissionError.AddAction('Request Access', Codeunit::"Permission Management", 'RequestAccess');
PermissionError.AddAction('Contact Administrator', Codeunit::"Permission Management", 'ContactAdmin');
```

### Business Rule Violations
```al
// Business logic validation failed
BusinessError.AddAction('Review Business Rules', Codeunit::"Business Rule Management", 'ReviewRules');
BusinessError.AddAction('Request Exception', Codeunit::"Business Rule Management", 'RequestException');
```

## Best Practices

### 1. Limit Action Count
- Maximum 3-4 suggested actions per error
- Too many options create decision paralysis
- Focus on the most relevant solutions

### 2. Test Action Flows
- Verify each action works in the error context
- Test with different user permissions
- Ensure actions provide clear feedback

### 3. Handle Action Failures
- Gracefully handle cases where actions fail
- Provide fallback options or error messages
- Don't create nested error scenarios

### 4. Use Consistent Patterns
- Standardize action naming conventions
- Create reusable action handler codeunits
- Document common action patterns for team use

## User Experience Benefits

Suggested actions transform error handling from:
- **Frustrating roadblocks** → **Guided problem-solving**
- **Passive messages** → **Active resolution tools**
- **Support ticket generators** → **Self-service opportunities**
- **Process interruptions** → **Workflow continuations**

This pattern significantly reduces support burden while improving user satisfaction and system adoption.
