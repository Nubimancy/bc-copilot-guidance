---
title: "AI-Assisted Event Development - Code Samples"
description: "Complete examples of using AI tools effectively for event-driven AL development"
area: "ai-assistance"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "List"]
tags: ["ai-assistance", "copilot", "events", "samples", "prompting"]
---

# AI-Assisted Event Development - Code Samples

## Effective Prompting Examples

### Customer Registration Events - AI Conversation Flow

**Developer Prompt:**
```
"Create integration events for customer registration with before/after patterns that allow extensions to modify customer data and add custom validation"
```

**AI Generated Code:**
```al
codeunit 50100 "Customer Registration Manager"
{
    procedure RegisterNewCustomer(var Customer: Record Customer): Boolean
    var
        IsHandled: Boolean;
        ValidationErrors: List of [Text];
    begin
        // Before event with modification and override capability
        OnBeforeCustomerRegistration(Customer, ValidationErrors, IsHandled);
        if IsHandled then
            exit(true);
            
        // Handle validation errors collected by subscribers
        if ValidationErrors.Count > 0 then
            HandleValidationErrors(ValidationErrors);
            
        // Core registration logic
        ValidateRequiredFields(Customer);
        Customer.Insert(true);
        SetupDefaultConfiguration(Customer);
        
        // After event for additional processing
        OnAfterCustomerRegistration(Customer);
        
        exit(true);
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerRegistration(var Customer: Record Customer; 
                                               var ValidationErrors: List of [Text]; 
                                               var IsHandled: Boolean)
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterCustomerRegistration(var Customer: Record Customer)
    begin
    end;
    
    local procedure HandleValidationErrors(ValidationErrors: List of [Text])
    var
        ErrorMessage: Text;
        ErrorBuilder: TextBuilder;
    begin
        ErrorBuilder.AppendLine('Customer registration validation failed:');
        foreach ErrorMessage in ValidationErrors do
            ErrorBuilder.AppendLine('- ' + ErrorMessage);
            
        Error(ErrorBuilder.ToText());
    end;
}
```

### Sales Order Validation Events - Iterative Development

**Initial Prompt:**
```
"Add integration events to sales order validation that collect validation errors from multiple subscribers"
```

**AI Initial Response:**
```al
codeunit 50101 "Sales Order Validator"
{
    procedure ValidateOrder(var SalesHeader: Record "Sales Header")
    var
        ValidationErrors: List of [Text];
    begin
        OnValidateOrder(SalesHeader, ValidationErrors);
        
        if ValidationErrors.Count > 0 then
            Error(StrSubstNo('%1 validation errors found', ValidationErrors.Count));
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnValidateOrder(var SalesHeader: Record "Sales Header"; var ValidationErrors: List of [Text])
    begin
    end;
}
```

**Follow-up Prompt:**
```
"Enhance this validation to provide more context in the error message and include related sales lines in the event parameters"
```

**AI Enhanced Response:**
```al
codeunit 50101 "Sales Order Validator"
{
    procedure ValidateOrder(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ValidationErrors: List of [Text];
        ValidationContext: Text;
    begin
        // Get sales lines for validation context
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        
        OnValidateOrder(SalesHeader, SalesLine, ValidationErrors);
        
        if ValidationErrors.Count > 0 then begin
            ValidationContext := BuildValidationContext(SalesHeader, ValidationErrors);
            Error(ValidationContext);
        end;
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnValidateOrder(var SalesHeader: Record "Sales Header"; 
                                   var SalesLine: Record "Sales Line";
                                   var ValidationErrors: List of [Text])
    begin
    end;
    
    local procedure BuildValidationContext(SalesHeader: Record "Sales Header"; ValidationErrors: List of [Text]): Text
    var
        ErrorBuilder: TextBuilder;
        ErrorMessage: Text;
    begin
        ErrorBuilder.AppendLine(StrSubstNo('Sales Order %1 validation failed:', SalesHeader."No."));
        ErrorBuilder.AppendLine(StrSubstNo('Customer: %1 - %2', SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name"));
        ErrorBuilder.AppendLine('');
        ErrorBuilder.AppendLine('Validation Issues:');
        
        foreach ErrorMessage in ValidationErrors do
            ErrorBuilder.AppendLine('• ' + ErrorMessage);
            
        exit(ErrorBuilder.ToText());
    end;
}
```

## Business Event Generation Examples

### Inventory Level Events - AI-Driven Development

**Developer Prompt:**
```
"Create business events for inventory level changes that external systems can consume for automated reordering workflows, include item details, location, old quantity, new quantity, and reorder recommendations"
```

**AI Generated Implementation:**
```al
codeunit 50102 "Inventory Event Publisher"
{
    procedure PublishInventoryLevelChanged(ItemNo: Code[20]; LocationCode: Code[10]; 
                                         OldQuantity: Decimal; NewQuantity: Decimal)
    var
        Item: Record Item;
        Location: Record Location;
        EventPayload: Text;
    begin
        if Item.Get(ItemNo) then begin
            if Location.Get(LocationCode) then;
            
            EventPayload := BuildInventoryEventPayload(Item, Location, OldQuantity, NewQuantity);
            
            // Publish business event
            Session.LogMessage('InventoryLevelChanged', EventPayload, Verbosity::Normal, 
                              DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 
                              'Category', 'BusinessEvent');
            
            // Trigger integration event for internal subscribers
            OnInventoryLevelChanged(Item, Location, OldQuantity, NewQuantity);
        end;
    end;
    
    local procedure BuildInventoryEventPayload(Item: Record Item; Location: Record Location; 
                                             OldQuantity: Decimal; NewQuantity: Decimal): Text
    var
        EventJson: JsonObject;
        ReorderRecommendation: JsonObject;
    begin
        // Main event data
        EventJson.Add('eventType', 'InventoryLevelChanged');
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('itemNo', Item."No.");
        EventJson.Add('itemDescription', Item.Description);
        EventJson.Add('locationCode', Location.Code);
        EventJson.Add('locationName', Location.Name);
        EventJson.Add('oldQuantity', OldQuantity);
        EventJson.Add('newQuantity', NewQuantity);
        EventJson.Add('quantityChange', NewQuantity - OldQuantity);
        EventJson.Add('unitOfMeasure', Item."Base Unit of Measure");
        
        // Reorder analysis
        BuildReorderRecommendation(ReorderRecommendation, Item, NewQuantity);
        EventJson.Add('reorderRecommendation', ReorderRecommendation);
        
        exit(Format(EventJson));
    end;
    
    local procedure BuildReorderRecommendation(var ReorderJson: JsonObject; Item: Record Item; CurrentQuantity: Decimal)
    var
        ShouldReorder: Boolean;
        RecommendedQuantity: Decimal;
    begin
        ShouldReorder := CurrentQuantity <= Item."Reorder Point";
        RecommendedQuantity := 0;
        
        if ShouldReorder then
            RecommendedQuantity := Item."Maximum Order Quantity" - CurrentQuantity;
            
        ReorderJson.Add('shouldReorder', ShouldReorder);
        ReorderJson.Add('belowReorderPoint', CurrentQuantity <= Item."Reorder Point");
        ReorderJson.Add('belowSafetyStock', CurrentQuantity <= Item."Safety Stock Quantity");
        ReorderJson.Add('reorderPoint', Item."Reorder Point");
        ReorderJson.Add('safetyStockQuantity', Item."Safety Stock Quantity");
        ReorderJson.Add('recommendedOrderQuantity', RecommendedQuantity);
        ReorderJson.Add('leadTime', Format(Item."Lead Time Calculation"));
        ReorderJson.Add('vendorNo', Item."Vendor No.");
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnInventoryLevelChanged(var Item: Record Item; var Location: Record Location; 
                                          OldQuantity: Decimal; NewQuantity: Decimal)
    begin
    end;
}
```

## Event Testing - AI-Generated Test Framework

### Comprehensive Event Testing

**Developer Prompt:**
```
"Create comprehensive test code that verifies integration events fire correctly, validates business event payloads, and tests subscriber behavior"
```

**AI Generated Test Framework:**
```al
codeunit 80100 "Event Testing Framework"
{
    Subtype = Test;
    
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        EventTestSubscriber: Codeunit "Event Test Subscriber";
        Assert: Codeunit Assert;
    
    [Test]
    procedure TestCustomerRegistrationEvents()
    var
        Customer: Record Customer;
        CustomerRegistration: Codeunit "Customer Registration Manager";
        TestResult: Boolean;
    begin
        // Initialize
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Event Testing Framework");
        BindSubscription(EventTestSubscriber);
        
        // Setup test customer
        InitializeTestCustomer(Customer);
        
        // Execute registration with events
        TestResult := CustomerRegistration.RegisterNewCustomer(Customer);
        
        // Verify events fired
        Assert.IsTrue(TestResult, 'Customer registration should succeed');
        Assert.IsTrue(EventTestSubscriber.GetBeforeEventFired(), 'Before event should fire');
        Assert.IsTrue(EventTestSubscriber.GetAfterEventFired(), 'After event should fire');
        
        // Verify event parameters
        VerifyEventParameters(Customer);
        
        UnbindSubscription(EventTestSubscriber);
    end;
    
    [Test]
    procedure TestEventValidationErrorCollection()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        OrderValidator: Codeunit "Sales Order Validator";
    begin
        // Initialize
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Event Testing Framework");
        BindSubscription(EventTestSubscriber);
        
        // Setup order with validation issues
        CreateOrderWithValidationIssues(SalesHeader, SalesLine);
        
        // Configure subscriber to add validation errors
        EventTestSubscriber.SetShouldAddValidationError(true);
        EventTestSubscriber.SetValidationErrorMessage('Custom validation failed');
        
        // Execute validation (should collect errors)
        asserterror OrderValidator.ValidateOrder(SalesHeader);
        
        // Verify error collection worked
        Assert.IsTrue(StrPos(GetLastErrorText(), 'Custom validation failed') > 0, 
                     'Should contain custom validation error');
        
        UnbindSubscription(EventTestSubscriber);
    end;
    
    [Test]
    procedure TestBusinessEventPayloadStructure()
    var
        Item: Record Item;
        Location: Record Location;
        InventoryPublisher: Codeunit "Inventory Event Publisher";
        TelemetrySubscriber: Codeunit "Test Telemetry Subscriber";
        EventPayload: Text;
        PayloadJson: JsonObject;
    begin
        // Initialize
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Event Testing Framework");
        BindSubscription(TelemetrySubscriber);
        
        // Setup test data
        CreateTestItem(Item);
        CreateTestLocation(Location);
        
        // Publish inventory event
        InventoryPublisher.PublishInventoryLevelChanged(Item."No.", Location.Code, 100, 75);
        
        // Retrieve and validate payload
        EventPayload := TelemetrySubscriber.GetLastBusinessEventPayload();
        Assert.IsTrue(EventPayload <> '', 'Business event payload should be captured');
        
        PayloadJson.ReadFrom(EventPayload);
        ValidateInventoryEventStructure(PayloadJson, Item, Location);
        
        UnbindSubscription(TelemetrySubscriber);
    end;
    
    local procedure ValidateInventoryEventStructure(PayloadJson: JsonObject; Item: Record Item; Location: Record Location)
    var
        EventType: Text;
        ItemNo: Text;
        OldQty: Decimal;
        NewQty: Decimal;
    begin
        // Validate required fields
        Assert.IsTrue(GetJsonValue(PayloadJson, 'eventType', EventType), 'Should have eventType');
        Assert.AreEqual('InventoryLevelChanged', EventType, 'Should be correct event type');
        
        Assert.IsTrue(GetJsonValue(PayloadJson, 'itemNo', ItemNo), 'Should have itemNo');
        Assert.AreEqual(Item."No.", ItemNo, 'Should match test item');
        
        Assert.IsTrue(GetJsonValue(PayloadJson, 'oldQuantity', OldQty), 'Should have oldQuantity');
        Assert.IsTrue(GetJsonValue(PayloadJson, 'newQuantity', NewQty), 'Should have newQuantity');
        
        // Validate reorder recommendation structure
        ValidateReorderRecommendationStructure(PayloadJson);
    end;
    
    local procedure ValidateReorderRecommendationStructure(PayloadJson: JsonObject)
    var
        ReorderToken: JsonToken;
        ReorderObject: JsonObject;
        ShouldReorder: Boolean;
    begin
        Assert.IsTrue(PayloadJson.Get('reorderRecommendation', ReorderToken), 
                     'Should have reorderRecommendation object');
                     
        ReorderObject := ReorderToken.AsObject();
        
        Assert.IsTrue(GetJsonValue(ReorderObject, 'shouldReorder', ShouldReorder), 
                     'Should have shouldReorder flag');
        Assert.IsTrue(ReorderObject.Contains('reorderPoint'), 'Should have reorderPoint');
        Assert.IsTrue(ReorderObject.Contains('safetyStockQuantity'), 'Should have safetyStockQuantity');
    end;
    
    local procedure GetJsonValue(JsonObj: JsonObject; KeyName: Text; var Value: Variant): Boolean
    var
        Token: JsonToken;
    begin
        if JsonObj.Get(KeyName, Token) then begin
            case true of
                Token.IsValue and Token.AsValue().IsText():
                    Value := Token.AsValue().AsText();
                Token.IsValue and Token.AsValue().IsDecimal():
                    Value := Token.AsValue().AsDecimal();
                Token.IsValue and Token.AsValue().IsBoolean():
                    Value := Token.AsValue().AsBoolean();
            end;
            exit(true);
        end;
        exit(false);
    end;
}

// Test subscriber codeunit for event testing
codeunit 80101 "Event Test Subscriber"
{
    var
        BeforeEventFired: Boolean;
        AfterEventFired: Boolean;
        ShouldAddValidationError: Boolean;
        ValidationErrorMessage: Text;
    
    procedure GetBeforeEventFired(): Boolean
    begin
        exit(BeforeEventFired);
    end;
    
    procedure GetAfterEventFired(): Boolean
    begin
        exit(AfterEventFired);
    end;
    
    procedure SetShouldAddValidationError(ShouldAdd: Boolean)
    begin
        ShouldAddValidationError := ShouldAdd;
    end;
    
    procedure SetValidationErrorMessage(ErrorMsg: Text)
    begin
        ValidationErrorMessage := ErrorMsg;
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration Manager", 'OnBeforeCustomerRegistration', '', false, false)]
    local procedure OnBeforeCustomerRegistration(var Customer: Record Customer; var ValidationErrors: List of [Text]; var IsHandled: Boolean)
    begin
        BeforeEventFired := true;
        
        if ShouldAddValidationError and (ValidationErrorMessage <> '') then
            ValidationErrors.Add(ValidationErrorMessage);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration Manager", 'OnAfterCustomerRegistration', '', false, false)]
    local procedure OnAfterCustomerRegistration(var Customer: Record Customer)
    begin
        AfterEventFired := true;
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Validator", 'OnValidateOrder', '', false, false)]
    local procedure OnValidateOrder(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ValidationErrors: List of [Text])
    begin
        if ShouldAddValidationError and (ValidationErrorMessage <> '') then
            ValidationErrors.Add(ValidationErrorMessage);
    end;
}
```

## Performance Optimization - AI Analysis

### AI-Driven Performance Analysis

**Developer Prompt:**
```
"Analyze this event-driven code for performance bottlenecks and suggest caching strategies for high-volume scenarios"
```

**AI Performance Analysis Response:**
```al
// Original event publishing code
codeunit 50103 "Order Status Event Publisher"
{
    // ❌ Performance Issue: Individual event publishing
    procedure PublishOrderStatusChange(OrderNo: Code[20]; OldStatus: Enum "Sales Document Status"; NewStatus: Enum "Sales Document Status")
    var
        SalesHeader: Record "Sales Header";
        EventPayload: Text;
    begin
        if SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then begin
            EventPayload := BuildOrderEventPayload(SalesHeader, OldStatus, NewStatus);
            Session.LogMessage('OrderStatusChanged', EventPayload, Verbosity::Normal, 
                              DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 
                              'Category', 'BusinessEvent');
        end;
    end;
}

// ✅ AI Optimized Version with Batching
codeunit 50104 "Optimized Order Event Publisher"
{
    var
        EventBatch: List of [Text];
        BatchTimer: DateTime;
        BatchSize: Integer;
        
    procedure Initialize()
    begin
        BatchSize := 50; // Configurable batch size
        BatchTimer := CurrentDateTime;
    end;
    
    procedure PublishOrderStatusChange(OrderNo: Code[20]; OldStatus: Enum "Sales Document Status"; NewStatus: Enum "Sales Document Status")
    var
        SalesHeader: Record "Sales Header";
        EventPayload: Text;
    begin
        if SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then begin
            EventPayload := BuildOrderEventPayload(SalesHeader, OldStatus, NewStatus);
            
            // Add to batch instead of immediate publishing
            EventBatch.Add(EventPayload);
            
            // Publish batch when size reached or time elapsed
            if (EventBatch.Count >= BatchSize) or (CurrentDateTime - BatchTimer > 5000) then // 5 seconds
                PublishEventBatch();
        end;
    end;
    
    procedure PublishEventBatch()
    var
        BatchPayload: Text;
        EventPayload: Text;
        BatchJson: JsonObject;
        EventsArray: JsonArray;
    begin
        if EventBatch.Count = 0 then
            exit;
            
        // Build batch payload
        BatchJson.Add('eventType', 'BatchOrderStatusChanges');
        BatchJson.Add('timestamp', CurrentDateTime);
        BatchJson.Add('eventCount', EventBatch.Count);
        
        foreach EventPayload in EventBatch do
            EventsArray.Add(EventPayload);
            
        BatchJson.Add('events', EventsArray);
        BatchPayload := Format(BatchJson);
        
        // Publish batch
        Session.LogMessage('BatchOrderStatusChanged', BatchPayload, Verbosity::Normal, 
                          DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 
                          'Category', 'BusinessEvent');
        
        // Reset batch
        Clear(EventBatch);
        BatchTimer := CurrentDateTime;
    end;
    
    // Cache expensive data lookups
    local procedure BuildOrderEventPayload(SalesHeader: Record "Sales Header"; OldStatus: Enum "Sales Document Status"; NewStatus: Enum "Sales Document Status"): Text
    var
        EventJson: JsonObject;
        CustomerInfo: JsonObject;
    begin
        EventJson.Add('eventType', 'OrderStatusChanged');
        EventJson.Add('orderNo', SalesHeader."No.");
        EventJson.Add('oldStatus', Format(OldStatus));
        EventJson.Add('newStatus', Format(NewStatus));
        EventJson.Add('timestamp', CurrentDateTime);
        
        // Use cached customer data to avoid repeated lookups
        GetCachedCustomerInfo(SalesHeader."Sell-to Customer No.", CustomerInfo);
        EventJson.Add('customer', CustomerInfo);
        
        exit(Format(EventJson));
    end;
    
    // Customer data cache implementation
    local procedure GetCachedCustomerInfo(CustomerNo: Code[20]; var CustomerInfo: JsonObject)
    var
        Customer: Record Customer;
        CacheKey: Text;
    begin
        CacheKey := 'Customer_' + CustomerNo;
        
        // Try to get from cache first (implementation would use actual caching mechanism)
        if not GetFromCache(CacheKey, CustomerInfo) then begin
            if Customer.Get(CustomerNo) then begin
                CustomerInfo.Add('no', Customer."No.");
                CustomerInfo.Add('name', Customer.Name);
                CustomerInfo.Add('blocked', Format(Customer.Blocked));
                
                // Cache for future use
                StoreInCache(CacheKey, CustomerInfo, 300000); // 5 minutes cache
            end;
        end;
    end;
}
```

These comprehensive examples demonstrate how AI can accelerate event-driven development while maintaining high code quality and performance standards.
