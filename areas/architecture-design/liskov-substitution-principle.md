---
title: "Liskov Substitution Principle in AL"
description: "Apply the Liskov Substitution Principle (LSP) to AL development with interface consistency"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Interface"]
variable_types: ["Record", ]
tags: ["solid-principles", "lsp", "liskov-substitution", "interfaces", "polymorphism"]
---

# Liskov Substitution Principle in AL

The Liskov Substitution Principle (LSP) states that objects of a superclass should be replaceable with objects of its subclasses without breaking the application. In AL, this applies to interface implementations.

## Core Concept

Any implementation of an interface should be substitutable for any other implementation without changing the correctness of the program. Interface contracts must be honored by all implementations.

## AL Application: Interface Consistency

### Proper Interface Implementation

**✅ Good Example:**
```al
// Base interface defines contract
interface "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean;
    procedure ValidatePayment(Amount: Decimal): Boolean;
}

codeunit 50100 "Payment Processor" implements "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Base implementation
        exit(true);
    end;
    
    procedure ValidatePayment(Amount: Decimal): Boolean  
    begin
        // Base validation
        exit(Amount > 0);
    end;
}

// Specialized implementations maintain interface contract
codeunit 50101 "Credit Card Processor" implements "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Credit card specific processing
        // Still returns Boolean as expected
        exit(ProcessCreditCardPayment(Amount, CustomerNo));
    end;
    
    procedure ValidatePayment(Amount: Decimal): Boolean
    begin
        // Enhanced validation but maintains contract
        exit((Amount > 0) and (Amount <= GetCreditLimit(CustomerNo)));
    end;
}
```

## Contract Consistency Rules

### 1. Parameter Compatibility
Implementations must accept the same or more general parameter types:
```al
// Interface defines contract
procedure ProcessItem(Item: Record Item): Boolean;

// ✅ Good: Same parameter type
procedure ProcessItem(Item: Record Item): Boolean;

// ❌ Bad: More restrictive parameter type
// procedure ProcessItem(InventoryItem: Record "Inventory Item"): Boolean;
```

### 2. Return Type Consistency
All implementations must return the same type with consistent meaning:
```al
// All implementations must return Boolean with same meaning
// true = success, false = failure
procedure ValidateData(): Boolean;
```

### 3. Behavioral Consistency
Implementations may be more permissive but not more restrictive:
```al
// Base validation: Amount > 0
procedure ValidatePayment(Amount: Decimal): Boolean
begin
    exit(Amount > 0);
end;

// ✅ Good: More permissive (allows zero for promotional payments)
procedure ValidatePayment(Amount: Decimal): Boolean
begin
    exit(Amount >= 0);
end;

// ❌ Bad: More restrictive (higher minimum amount)
procedure ValidatePayment(Amount: Decimal): Boolean
begin
    exit(Amount > 100);
end;
```

## Common LSP Violations in AL

### 1. Strengthening Preconditions
```al
// ❌ Bad: Subclass requires more than interface promises
interface "IDocument Validator"
{
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean;
}

codeunit 50100 "Basic Validator" implements "IDocument Validator"
{
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean
    begin
        exit(DocumentNo <> ''); // Basic check
    end;
}

codeunit 50101 "Strict Validator" implements "IDocument Validator"
{
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean
    begin
        // ❌ Violation: Requires specific format, breaking substitutability
        if StrLen(DocumentNo) <> 10 then
            Error('Document number must be exactly 10 characters');
        exit(DocumentNo <> '');
    end;
}
```

### 2. Weakening Postconditions
```al
// ❌ Bad: Subclass guarantees less than interface promises
codeunit 50102 "Unreliable Validator" implements "IDocument Validator"
{
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean
    begin
        // ❌ Violation: Sometimes fails silently instead of returning false
        if Random(2) = 1 then
            exit(true);
        // Should return false but doesn't return anything
    end;
}
```

## Testing for LSP Compliance

Create tests that work with the interface, not specific implementations:

```al
procedure TestPaymentProcessors()
var
    Processors: List of [Interface "IPayment Processor"];
    Processor: Interface "IPayment Processor";
begin
    // Add all implementations
    Processors.Add(GetCreditCardProcessor());
    Processors.Add(GetBankTransferProcessor());
    Processors.Add(GetCashProcessor());
    
    // Test that all implementations work the same way
    foreach Processor in Processors do begin
        Assert.IsTrue(Processor.ValidatePayment(100), 'Should validate positive amount');
        Assert.IsFalse(Processor.ValidatePayment(-10), 'Should reject negative amount');
    end;
end;
```

## Benefits in AL Development

1. **Polymorphic Behavior**: Different implementations can be used interchangeably
2. **Robust Extensions**: New implementations won't break existing code
3. **Reliable Testing**: Interface contracts ensure predictable behavior
4. **Future-Proof Design**: New implementations follow established patterns

## AI Prompting for LSP

When working with AI assistants:

```
// Good prompts for LSP compliance:
"Create an interface implementation that maintains the same contract behavior"
"Ensure this implementation doesn't strengthen preconditions or weaken postconditions"
"Review this interface implementation for Liskov Substitution Principle compliance"
```

## Design Guidelines

### Interface Design
- Keep interfaces focused and minimal
- Define clear contracts in documentation
- Consider all possible implementations when designing

### Implementation Rules
- Honor all interface contracts
- Don't add required parameters through other means
- Maintain expected error handling patterns
- Document any enhanced behavior clearly

## Related Topics
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Open-Closed Principle](open-closed-principle.md)
- [Interface Segregation Principle](interface-segregation-principle.md)
- [Dependency Inversion Principle](dependency-inversion-principle.md)
