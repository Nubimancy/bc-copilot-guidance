# Event-Driven Extensibility Patterns 📡

**Creating extensible Business Central solutions through business events and integration events**

## Business Events vs Integration Events

### Integration Events
**Purpose:** Technical extension points within AL code  
**Scope:** Current extension and consuming extensions
**Use Cases:** Adding custom logic to standard processes

### Business Events  
**Purpose:** Business-meaningful occurrences that external systems can consume  
**Scope:** Cross-application integration (Power Automate, Logic Apps, external systems)
**Use Cases:** Workflow automation, external system notifications

## Integration Event Patterns

### Core Pattern: Before/After Events

```al
codeunit 50100 "Customer Registration"
{
    procedure RegisterNewCustomer(var Customer: Record Customer): Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeCustomerRegistration(Customer, IsHandled);
        if IsHandled then
            exit(true);
            
        // Core registration logic
        ValidateCustomerData(Customer);
        Customer.Insert(true);
        SetDefaultSettings(Customer);
        
        OnAfterCustomerRegistration(Customer);
        
        exit(true);
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerRegistration(var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterCustomerRegistration(var Customer: Record Customer)
    begin
    end;
}
```

### Advanced Pattern: Validation Events with Error Handling

```al
codeunit 50101 "Order Validation"
{
    procedure ValidateOrder(var SalesHeader: Record "Sales Header")
    var
        ValidationErrors: List of [Text];
        ErrorMessage: Text;
    begin
        OnValidateOrder(SalesHeader, ValidationErrors);
        
        if ValidationErrors.Count > 0 then begin
            foreach ErrorMessage in ValidationErrors do
                Error(ErrorMessage);
        end;
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnValidateOrder(var SalesHeader: Record "Sales Header"; var ValidationErrors: List of [Text])
    begin
    end;
}

// Extension consuming the event
codeunit 50102 "Custom Order Validation"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Order Validation", 'OnValidateOrder', '', false, false)]
    local procedure OnValidateOrder(var SalesHeader: Record "Sales Header"; var ValidationErrors: List of [Text])
    begin
        if not ValidateCustomBusinessRule(SalesHeader) then
            ValidationErrors.Add('Custom business rule validation failed');
    end;
}
```

## Business Event Patterns

### Publishing Business Events

```al
codeunit 50103 "Customer Events Publisher"
{
    procedure PublishCustomerCreated(Customer: Record Customer)
    var
        BusinessEventJson: Text;
    begin
        BusinessEventJson := CreateCustomerEventJson(Customer);
        
        // Publish to Business Central's event system
        Session.LogMessage('CustomerCreated', BusinessEventJson, Verbosity::Normal, 
                          DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 
                          'Category', 'BusinessEvent');
    end;
    
    local procedure CreateCustomerEventJson(Customer: Record Customer): Text
    var
        EventJson: JsonObject;
    begin
        EventJson.Add('eventType', 'CustomerCreated');
        EventJson.Add('customerNo', Customer."No.");
        EventJson.Add('customerName', Customer.Name);
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('createdBy', UserId);
        
        exit(Format(EventJson));
    end;
}
```

### Consuming Business Events from External Systems

```al
// Event subscriber for external consumption patterns
codeunit 50104 "External System Notifier"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration", 'OnAfterCustomerRegistration', '', false, false)]
    local procedure NotifyExternalSystemOfNewCustomer(var Customer: Record Customer)
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        EventPayload: Text;
    begin
        EventPayload := CreateCustomerEventPayload(Customer);
        
        HttpContent.WriteFrom(EventPayload);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        
        if HttpClient.Post('https://external-system.com/api/customer-events', HttpContent, Response) then
            Session.LogMessage('ExternalNotification', 'Customer event sent successfully', 
                              Verbosity::Normal, DataClassification::SystemMetadata, 
                              TelemetryScope::ExtensionPublisher, 'Category', 'Integration')
        else
            Session.LogMessage('ExternalNotificationError', 'Failed to send customer event', 
                              Verbosity::Error, DataClassification::SystemMetadata, 
                              TelemetryScope::ExtensionPublisher, 'Category', 'Integration');
    end;
}
```

## Event Design Principles

### 1. Meaningful Event Names
```al
// ✅ Good - Clear business meaning
OnBeforeCustomerCreditLimitValidation()
OnAfterSalesOrderConfirmation()
OnCustomerLoyaltyStatusChanged()

// ❌ Avoid - Technical focus without business context
OnBeforeValidate()
OnAfterProcess()  
OnDataChange()
```

### 2. Rich Event Context
```al
// ✅ Good - Provides sufficient context
[IntegrationEvent(false, false)]
local procedure OnBeforeApplyCreditLimit(CustomerNo: Code[20]; RequestedLimit: Decimal; 
                                       CurrentLimit: Decimal; var IsApproved: Boolean; 
                                       var ReasonCode: Code[10])
begin
end;

// ❌ Avoid - Insufficient context  
[IntegrationEvent(false, false)]
local procedure OnBeforeApply(Code: Code[20]; var IsOK: Boolean)
begin
end;
```

### 3. Extensible Parameters
```al
// Use record parameters for future extensibility
[IntegrationEvent(false, false)]  
local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header"; 
                                    var SalesLine: Record "Sales Line")
begin
end;

// Better than individual fields that might need expansion
```

## AI Prompting for Event-Driven Code

### Effective Prompts for Event Design

```al
// Good prompts for Copilot:
"Create integration events for customer registration with before/after patterns"
"Add business events to notify external systems when order status changes"
"Design event parameters that provide rich context for extensibility"
```

### Event Discovery Prompts
```al
// Ask Copilot to identify event opportunities:
"Where should I add integration events in this sales order processing codeunit?"
"What business events would be valuable for external system integration?"
"How can I make this validation codeunit more extensible through events?"
```

## Testing Event-Driven Code

### Testing Integration Events
```al
[Test]
procedure TestCustomerRegistrationEvents()
var
    Customer: Record Customer;
    EventTester: Codeunit "Customer Registration Event Test";
    CustomerReg: Codeunit "Customer Registration";
begin
    // Setup
    Customer.Init();
    Customer."No." := 'TEST001';
    Customer.Name := 'Test Customer';
    
    // Bind event subscriber for testing
    BindSubscription(EventTester);
    
    // Execute
    CustomerReg.RegisterNewCustomer(Customer);
    
    // Verify events were fired
    Assert.IsTrue(EventTester.WasBeforeEventFired(), 'Before event should fire');
    Assert.IsTrue(EventTester.WasAfterEventFired(), 'After event should fire');
    
    UnbindSubscription(EventTester);
end;
```

### Testing Business Events
```al
[Test]
procedure TestBusinessEventPublishing()
var
    Customer: Record Customer;
    TelemetryLogger: Codeunit "Test Telemetry Logger";
begin
    // Setup telemetry capture
    BindSubscription(TelemetryLogger);
    
    // Execute business event
    Customer.Get('TEST001');
    PublishCustomerCreatedEvent(Customer);
    
    // Verify event was logged
    Assert.IsTrue(TelemetryLogger.ContainsMessage('CustomerCreated'), 
                 'Business event should be logged');
    
    UnbindSubscription(TelemetryLogger);
end;
```

## Event Documentation Patterns

### Self-Documenting Events
```al
/// <summary>
/// Raised before customer credit limit validation begins.
/// Use to add custom validation rules or modify validation behavior.
/// </summary>
/// <param name="Customer">The customer record being validated</param>
/// <param name="RequestedLimit">The requested credit limit amount</param>  
/// <param name="IsHandled">Set to true to skip standard validation</param>
/// <param name="ValidationResult">Set validation result when IsHandled = true</param>
[IntegrationEvent(false, false)]
local procedure OnBeforeValidateCustomerCreditLimit(var Customer: Record Customer; 
                                                   RequestedLimit: Decimal;
                                                   var IsHandled: Boolean;
                                                   var ValidationResult: Boolean)
begin
end;
```

## Performance Considerations

### Event Performance Best Practices
```al
// ✅ Good - Early exit for performance
procedure ProcessLargeDataset()
var
    IsHandled: Boolean;
begin
    OnBeforeProcessLargeDataset(IsHandled);
    if IsHandled then
        exit; // Skip expensive processing if handled by extension
        
    // Expensive processing here
end;

// ✅ Good - Batch events for multiple records  
[IntegrationEvent(false, false)]
local procedure OnProcessCustomerBatch(var CustomerList: List of [Code[20]])
begin
end;
```

## Common Event Patterns

### 1. Validation Events
```al
OnValidate[Entity][Property](var Record; var IsValid: Boolean; var ErrorMessage: Text)
```

### 2. Processing Events  
```al
OnBefore[Process][Entity](var Record; var IsHandled: Boolean)
OnAfter[Process][Entity](var Record)
```

### 3. State Change Events
```al
On[Entity][State]Changed(var Record; OldValue; NewValue)
```

### 4. Business Events
```al
On[Entity][BusinessAction]([Entity]Info; Timestamp; UserId)
```

---

**Event-driven architecture makes Business Central extensions more flexible, maintainable, and integration-ready!** 🔗
