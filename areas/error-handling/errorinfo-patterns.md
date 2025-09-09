---
title: "ErrorInfo Pattern Implementation"
description: "Modern error handling using ErrorInfo for rich, actionable error messages with suggested user actions"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["ErrorInfo", "Record"]
tags: ["error-handling", "errorinfo", "user-experience", "best-practices"]
source-extraction: "core-development/error-handling.md lines 40-90"
---

# ErrorInfo Pattern Implementation

## Quick Summary
Modern error handling using ErrorInfo for rich, actionable error messages with suggested user actions.

## When to Use This Pattern
- When errors need to provide clear guidance to users
- For business rule violations that users can potentially resolve
- When you want to offer specific actions for error recovery
- In scenarios where technical and user-friendly messages differ

## Traditional vs Modern Approach

### ❌ Traditional Error Handling (Avoid)
```al
// Poor user experience - cryptic message
if Customer."Credit Limit" < Amount then
    Error('Credit limit exceeded');

// No actionable information
Customer.TestField("Payment Terms Code");

// Technical message exposed to users
if not HttpClient.Get(Url, Response) then
    Error('HTTP GET failed with status %1', Response.HttpStatusCode);
```

### ✅ Modern ErrorInfo Patterns (Use)
```al
// Rich, actionable error information
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

## Key ErrorInfo Properties

- **Message**: User-friendly error message
- **DetailedMessage**: Additional context and guidance
- **Verbosity**: Controls when the error appears in logs
- **DataClassification**: Proper data handling classification
- **AddAction()**: Provides clickable recovery options

## Common Mistakes
- Using generic Error() calls instead of ErrorInfo
- Providing technical messages to end users
- Not including suggested recovery actions
- Missing proper data classification

## AI Prompting for This Topic
```
"Create an ErrorInfo pattern for customer validation that includes user-friendly messages and suggested actions for credit limit violations"

"Convert this generic Error() call to use ErrorInfo with actionable recovery options"

"Design error handling that provides different message levels for users vs administrators"
```

## Related Topics
- [Progressive Error Disclosure](progressive-disclosure.md) - When to show detailed vs simple messages
- [Error Prevention Strategies](error-prevention.md) - Avoiding errors before they happen  
- [Suggested Actions Implementation](suggested-actions.md) - Creating effective error recovery actions
- [Error Testing Patterns](../testing/error-testing-patterns.md) - Testing ErrorInfo implementations
