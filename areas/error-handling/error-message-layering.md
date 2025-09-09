---
title: "Progressive Error Disclosure"
description: "Provide simple, user-friendly error messages while making technical details available when needed"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit", "Page"]
variable_types: ["ErrorInfo", "Notification"]
tags: ["error-handling", "progressive-disclosure", "user-experience", "technical-details"]
source-extraction: "core-development/error-handling.md lines 90-120"
---

# Progressive Error Disclosure

## Quick Summary
Provide simple, user-friendly error messages while making technical details available when needed.

## When to Use This Pattern
- When errors have both user-impact and technical complexity
- For integration failures that users can't directly fix
- When different audiences need different levels of detail
- In production systems where technical details should be hidden from end users

## Implementation Example

```al
procedure ProcessPaymentWithGracefulHandling(PaymentData: Record "Payment Information")
var
    PaymentError: ErrorInfo;
begin
    if not TryProcessPayment(PaymentData) then begin
        // User-friendly message (what they see first)
        PaymentError.Message := 'Payment processing failed. Please try again or contact support.';
        
        // Technical details for troubleshooting (available if needed)
        PaymentError.DetailedMessage := StrSubstNo('Payment gateway returned error: %1. Transaction ID: %2. Timestamp: %3', 
                                                   GetLastErrorText(), PaymentData."Transaction ID", CurrentDateTime);
        
        // Context-aware actions based on error type
        PaymentError.AddAction('Retry Payment', Codeunit::"Payment Processor", 'RetryPayment');
        PaymentError.AddAction('Use Alternative Method', Codeunit::"Payment Processor", 'ShowAlternativeMethods');
        PaymentError.AddAction('Contact Support', Codeunit::"Payment Processor", 'ContactSupport');
        
        Error(PaymentError);
    end;
end;
```

## Progressive Disclosure Principles

### 1. Start Simple
- **Message**: What users need to know immediately
- Keep it non-technical and actionable

### 2. Provide Detail When Needed
- **DetailedMessage**: Technical context for troubleshooting
- Include timestamps, transaction IDs, error codes

### 3. Offer Appropriate Actions
- User-level actions (retry, use alternative)
- Support-level actions (contact, escalate)
- Technical actions (view logs, diagnostic info)

## Message Hierarchy

```al
// Level 1: User sees this first
PaymentError.Message := 'Payment could not be processed';

// Level 2: Available if they need more context  
PaymentError.DetailedMessage := 'Credit card validation failed: Invalid expiry date format';

// Level 3: Technical details for support/developers
Session.LogMessage('PaymentFailure', 
    StrSubstNo('Gateway response: %1, HTTP Status: %2, Reference: %3', 
               Response.ReasonPhrase, Response.HttpStatusCode, TransactionRef),
    Verbosity::Error, DataClassification::SystemMetadata, 
    TelemetryScope::ExtensionPublisher, 'Category', 'Payment');
```

## Common Patterns

### Integration Errors
```al
// User message: Simple and actionable
ErrorInfo.Message := 'Unable to sync data with external system';

// Technical message: Specific for troubleshooting
ErrorInfo.DetailedMessage := StrSubstNo('API call failed: %1. Endpoint: %2. Response code: %3', 
                                        GetLastErrorText(), ApiEndpoint, HttpStatusCode);
```

### Business Rule Violations
```al
// User message: Clear business context
ErrorInfo.Message := 'Customer credit limit exceeded';

// Detailed message: Specific numbers and guidance
ErrorInfo.DetailedMessage := StrSubstNo('Requested amount (%1) exceeds credit limit (%2). Current balance: %3', 
                                        RequestedAmount, CreditLimit, CurrentBalance);
```

## AI Prompting for This Topic
```
"Create a progressive error disclosure pattern for API integration failures that shows users simple messages but provides technical details for support"

"Design error messages that start user-friendly but allow drilling down to technical specifics"

"Implement error handling that adapts message detail level based on user role or context"
```

## Related Topics
- [ErrorInfo Patterns](errorinfo-patterns.md) - Foundation for implementing progressive disclosure
- [Suggested Actions Implementation](suggested-actions.md) - Providing appropriate actions for each disclosure level
- [User Experience Guidelines](../code-creation/user-experience.md) - Broader UX considerations
- [Error Testing Patterns](../testing/error-testing-patterns.md) - Testing different disclosure scenarios
