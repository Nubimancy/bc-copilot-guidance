---
title: "Event Design Principles"
description: "Best practices for designing maintainable, extensible, and discoverable integration events in Business Central"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "Enum"]
tags: ["events", "design", "principles", "integration", "extensibility", "maintainability"]
---

# Event Design Principles

## Meaningful Event Names

### Business-Focused Naming

Create event names that reflect business meaning rather than technical implementation.

**✅ Good Examples:**
```al
// Clear business meaning
[IntegrationEvent(false, false)]
local procedure OnBeforeCustomerCreditLimitValidation(var Customer: Record Customer; 
                                                     RequestedLimit: Decimal; 
                                                     var IsApproved: Boolean; 
                                                     var ReasonCode: Code[10])
begin
end;

[IntegrationEvent(false, false)]
local procedure OnAfterSalesOrderConfirmation(var SalesHeader: Record "Sales Header")
begin
end;

[IntegrationEvent(false, false)]
local procedure OnCustomerLoyaltyStatusChanged(CustomerNo: Code[20]; 
                                             OldStatus: Enum "Customer Loyalty Status";
                                             NewStatus: Enum "Customer Loyalty Status")
begin
end;
```

**❌ Poor Examples:**
```al
// Technical focus without business context
[IntegrationEvent(false, false)]
local procedure OnBeforeValidate()
begin
end;

[IntegrationEvent(false, false)]
local procedure OnAfterProcess()
begin
end;

[IntegrationEvent(false, false)]
local procedure OnDataChange()
begin
end;
```

### Consistent Naming Patterns

Follow established patterns for event timing and purpose.

```al
// Before/After pattern for process events
OnBeforeCustomerRegistration()
OnAfterCustomerRegistration()

// Validation pattern
OnValidateCustomerCreditLimit()
OnValidateOrderShipmentDate()

// State change pattern
OnCustomerStatusChanged()
OnOrderStateTransition()

// Business action pattern
OnCustomerLoyaltyPointsEarned()
OnInventoryLevelAlert()
```

## Rich Event Context

### Comprehensive Parameter Design

Provide sufficient context for event subscribers to make informed decisions.

**✅ Good - Rich Context:**
```al
[IntegrationEvent(false, false)]
local procedure OnBeforeApplyCustomerCreditLimit(CustomerNo: Code[20]; 
                                               RequestedLimit: Decimal;
                                               CurrentLimit: Decimal;
                                               CurrentBalance: Decimal;
                                               PaymentHistory: Enum "Payment History Rating";
                                               var IsApproved: Boolean;
                                               var ReasonCode: Code[10];
                                               var SuggestedLimit: Decimal)
begin
end;
```

**❌ Poor - Insufficient Context:**
```al
[IntegrationEvent(false, false)]
local procedure OnBeforeApply(Code: Code[20]; var IsOK: Boolean)
begin
end;
```

### Record vs Individual Fields

Use record parameters when the event might need additional fields in the future.

**✅ Good - Future Extensible:**
```al
[IntegrationEvent(false, false)]
local procedure OnBeforeProcessSalesOrder(var SalesHeader: Record "Sales Header"; 
                                        var SalesLine: Record "Sales Line";
                                        ProcessingOptions: JsonObject)
begin
end;
```

**❌ Limited - Hard to Extend:**
```al
[IntegrationEvent(false, false)]
local procedure OnBeforeProcessSalesOrder(OrderNo: Code[20]; 
                                        CustomerNo: Code[20];
                                        Amount: Decimal)
begin
end;
```

## Extensible Parameters

### Flexible Control Parameters

Design parameters that allow subscribers to influence process flow.

```al
[IntegrationEvent(false, false)]
local procedure OnBeforeInventoryValuation(var Item: Record Item;
                                         ValuationDate: Date;
                                         var ValuationMethod: Enum "Costing Method";
                                         var IsHandled: Boolean;
                                         var CustomValuation: Decimal;
                                         var ValidationErrors: List of [Text])
begin
end;
```

### Structured Data Parameters

Use structured types for complex data exchange.

```al
[IntegrationEvent(false, false)]
local procedure OnBeforeShipmentProcessing(var SalesHeader: Record "Sales Header";
                                         var ShipmentOptions: JsonObject;
                                         var ProcessingResults: Dictionary of [Text, Boolean];
                                         var ValidationMessages: List of [Text])
begin
end;
```

## Event Documentation Standards

### Self-Documenting Events

Include comprehensive XML documentation for all integration events.

```al
/// <summary>
/// Raised before customer credit limit validation begins.
/// Use this event to implement custom credit limit validation rules 
/// or to bypass standard validation with custom logic.
/// </summary>
/// <param name="Customer">The customer record being validated</param>
/// <param name="RequestedLimit">The credit limit amount being requested</param>  
/// <param name="CurrentBalance">The customer's current outstanding balance</param>
/// <param name="IsHandled">Set to true to skip standard validation</param>
/// <param name="ValidationResult">Set validation result when IsHandled = true</param>
/// <param name="ReasonCode">Reason code for approval or rejection</param>
/// <example>
/// Use this event to integrate with external credit rating services:
/// <code>
/// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Credit Management", 
///                  'OnBeforeValidateCustomerCreditLimit', '', false, false)]
/// local procedure CheckExternalCreditRating(var Customer: Record Customer; 
///                                          RequestedLimit: Decimal;
///                                          CurrentBalance: Decimal;
///                                          var IsHandled: Boolean;
///                                          var ValidationResult: Boolean;
///                                          var ReasonCode: Code[10])
/// begin
///     ValidationResult := ExternalCreditService.ValidateLimit(Customer."No.", RequestedLimit);
///     ReasonCode := 'EXTERNAL';
///     IsHandled := true;
/// end;
/// </code>
/// </example>
[IntegrationEvent(false, false)]
local procedure OnBeforeValidateCustomerCreditLimit(var Customer: Record Customer; 
                                                   RequestedLimit: Decimal;
                                                   CurrentBalance: Decimal;
                                                   var IsHandled: Boolean;
                                                   var ValidationResult: Boolean;
                                                   var ReasonCode: Code[10])
begin
end;
```

### Event Usage Examples

Provide practical examples showing how to consume events.

```al
/// <summary>
/// Integration event fired after sales order status changes.
/// </summary>
/// <example>
/// Track order progression through workflow stages:
/// <code>
/// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Management", 
///                  'OnAfterOrderStatusChange', '', false, false)]
/// local procedure TrackOrderProgression(var SalesHeader: Record "Sales Header"; 
///                                      OldStatus: Enum "Sales Document Status";
///                                      NewStatus: Enum "Sales Document Status")
/// var
///     OrderTracking: Record "Order Status Tracking";
/// begin
///     OrderTracking.Init();
///     OrderTracking."Order No." := SalesHeader."No.";
///     OrderTracking."Status From" := OldStatus;
///     OrderTracking."Status To" := NewStatus;
///     OrderTracking."Change DateTime" := CurrentDateTime;
///     OrderTracking."Changed By" := UserId;
///     OrderTracking.Insert();
/// end;
/// </code>
/// </example>
[IntegrationEvent(false, false)]
local procedure OnAfterOrderStatusChange(var SalesHeader: Record "Sales Header"; 
                                       OldStatus: Enum "Sales Document Status";
                                       NewStatus: Enum "Sales Document Status")
begin
end;
```

## Event Granularity Guidelines

### Atomic vs Composite Events

Balance between too many granular events and overly broad events.

**✅ Good - Appropriate Granularity:**
```al
// Specific business events
OnBeforeCustomerCreditLimitChange()
OnAfterCustomerCreditLimitChange()
OnCustomerCreditLimitExceeded()
OnCustomerCreditLimitRestored()
```

**❌ Too Granular:**
```al
// Overly specific events
OnBeforeCustomerCreditLimitFieldValidation()
OnAfterCustomerCreditLimitFieldValidation()
OnBeforeCustomerCreditLimitFieldModification()
OnAfterCustomerCreditLimitFieldModification()
```

**❌ Too Broad:**
```al
// Overly generic events
OnCustomerDataChange()
OnAnyFieldModified()
```

### Event Timing Design

Provide events at appropriate process stages.

```al
// Complete event lifecycle for complex processes
[IntegrationEvent(false, false)]
local procedure OnBeforeOrderProcessingStart(var SalesHeader: Record "Sales Header"; 
                                           var ProcessingOptions: JsonObject;
                                           var IsHandled: Boolean)
begin
end;

[IntegrationEvent(false, false)]
local procedure OnOrderValidationComplete(var SalesHeader: Record "Sales Header";
                                        var ValidationResults: List of [Text];
                                        var ContinueProcessing: Boolean)
begin
end;

[IntegrationEvent(false, false)]
local procedure OnAfterOrderProcessingComplete(var SalesHeader: Record "Sales Header";
                                             ProcessingDuration: Duration;
                                             ProcessingResults: JsonObject)
begin
end;
```

## Error Handling in Events

### Graceful Error Propagation

Design events to handle errors without breaking the main process.

```al
[IntegrationEvent(false, false)]
local procedure OnValidateCustomerOrder(var SalesHeader: Record "Sales Header";
                                      var ValidationErrors: List of [Text];
                                      var CriticalErrors: List of [Text];
                                      var Warnings: List of [Text])
begin
end;

// Usage in main process
local procedure ValidateOrder(var SalesHeader: Record "Sales Header"): Boolean
var
    ValidationErrors: List of [Text];
    CriticalErrors: List of [Text];
    Warnings: List of [Text];
    ErrorMessage: Text;
begin
    OnValidateCustomerOrder(SalesHeader, ValidationErrors, CriticalErrors, Warnings);
    
    // Handle critical errors (stop processing)
    if CriticalErrors.Count > 0 then begin
        foreach ErrorMessage in CriticalErrors do
            Error(ErrorMessage);
    end;
    
    // Log warnings but continue
    foreach ErrorMessage in Warnings do
        Session.LogMessage('OrderValidation', ErrorMessage, Verbosity::Warning, 
                          DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 
                          'Category', 'Validation');
    
    // Handle non-critical validation errors
    exit(ValidationErrors.Count = 0);
end;
```

### Try Function Patterns

Use try functions for optional event processing.

```al
[TryFunction]
local procedure TryPublishBusinessEvent(EventData: JsonObject)
var
    EventPublisher: Codeunit "Business Event Publisher";
begin
    EventPublisher.PublishEvent('CustomerCreated', Format(EventData));
end;

local procedure ProcessCustomerCreation(var Customer: Record Customer)
begin
    // Core business logic always executes
    Customer.Insert(true);
    SetupCustomerDefaults(Customer);
    
    // Optional event publishing - don't fail if it has issues
    if not TryPublishBusinessEvent(CreateCustomerEventData(Customer)) then
        Session.LogMessage('EventPublishing', 
                          'Failed to publish customer created event: ' + GetLastErrorText(), 
                          Verbosity::Warning, DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'Events');
end;
```

## Event Versioning Strategy

### Future-Proof Event Design

Design events to accommodate future changes without breaking existing subscribers.

```al
// Version 1.0
[IntegrationEvent(false, false)]
local procedure OnBeforeCustomerRegistration(var Customer: Record Customer;
                                           var IsHandled: Boolean)
begin
end;

// Version 2.0 - Add parameters, keep backward compatibility
[IntegrationEvent(false, false)]
local procedure OnBeforeCustomerRegistration(var Customer: Record Customer;
                                           var IsHandled: Boolean;
                                           RegistrationContext: JsonObject) // New parameter with default value
begin
end;

// Use overloads for major changes
[IntegrationEvent(false, false)]
local procedure OnBeforeCustomerRegistrationV2(var Customer: Record Customer;
                                              var IsHandled: Boolean;
                                              RegistrationContext: JsonObject;
                                              var ValidationErrors: List of [Text])
begin
end;
```

Following these event design principles creates maintainable, discoverable, and extensible integration points that serve both current needs and future requirements.
