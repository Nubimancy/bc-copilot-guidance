---
title: "Open-Closed Principle in AL"
description: "Apply the Open-Closed Principle (OCP) to AL development using events and interfaces"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Interface"]
variable_types: ["Record", ]
tags: ["solid-principles", "ocp", "open-closed", "events", "extensibility"]
---

# Open-Closed Principle in AL

The Open-Closed Principle (OCP) states that software entities should be open for extension but closed for modification. In AL development, this is primarily achieved through integration events and interfaces.

## Core Concept

You should be able to extend the behavior of existing code without modifying it. This protects existing functionality while allowing new features to be added safely.

## AL Application: Extension Through Events

### Integration Events for Extensibility

The primary mechanism in AL for achieving OCP compliance is through integration events that provide extension points:

**✅ Good Example:**
```al
// Base codeunit is closed for modification, open for extension
codeunit 50100 "Sales Order Processing"
{
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        ValidateOrderData(SalesHeader);
        OnBeforeProcessOrder(SalesHeader); // Extension point
        
        // Core processing logic
        CreateOrderEntries(SalesHeader);
        
        OnAfterProcessOrder(SalesHeader); // Extension point
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header")
    begin
    end;
    
    [IntegrationEvent(false, false)]  
    local procedure OnAfterProcessOrder(var SalesHeader: Record "Sales Header")
    begin
    end;
}
```

**Extension Usage:**
```al
// Extend behavior without modifying original code
codeunit 50101 "Custom Order Processing"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Processing", 
                     'OnBeforeProcessOrder', '', false, false)]
    local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        // Add custom validation or logic
        ValidateCustomBusinessRules(SalesHeader);
    end;
}
```

## Interface-Based Extensions

Interfaces provide another way to implement OCP by allowing different implementations:

```al
interface "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean;
}

codeunit 50100 "Order Management"
{
    var
        PaymentProcessor: Interface "IPayment Processor";
        
    procedure SetPaymentProcessor(NewProcessor: Interface "IPayment Processor")
    begin
        PaymentProcessor := NewProcessor;
    end;
}
```

## Benefits in AL Development

1. **Safe Extensions**: Add new functionality without risking existing code
2. **Multiple Implementations**: Different behaviors for different scenarios
3. **Easier Testing**: Mock implementations can be injected
4. **Reduced Coupling**: Extensions don't depend on internal implementation details

## Event Placement Strategy

### Before Events
Use for validation, preparation, or cancellation:
```al
[IntegrationEvent(false, false)]
local procedure OnBeforeValidateCustomer(var Customer: Record Customer; var IsHandled: Boolean)
```

### After Events
Use for additional processing, notifications, or cleanup:
```al
[IntegrationEvent(false, false)]
local procedure OnAfterCreateCustomer(Customer: Record Customer)
```

### Replace Events
Use to completely override default behavior:
```al
[IntegrationEvent(false, false)]
local procedure OnReplaceProcessPayment(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
```

## Common OCP Violations in AL

1. **Hard-coded Logic**: Business rules embedded without extension points
2. **Direct Modifications**: Changing existing code instead of extending it
3. **Missing Events**: No extension points in critical business processes
4. **Tightly Coupled Code**: Dependencies on concrete implementations

## AI Prompting for OCP

When working with AI assistants:

```
// Instead of asking for modifications:
"Modify this codeunit to add new validation rules"

// Ask for extension patterns:
"Add integration events to this codeunit for validation and processing extensions"
"Create an interface for this payment processing functionality"
```

## Related Topics
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Liskov Substitution Principle](liskov-substitution-principle.md)
- [Interface Segregation Principle](interface-segregation-principle.md)
- [Dependency Inversion Principle](dependency-inversion-principle.md)
