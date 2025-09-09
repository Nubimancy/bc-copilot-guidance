---
title: "Event Testing Strategies - Code Samples"
description: "Complete test implementations for integration events, business events, and event-driven architecture validation"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "List", "JsonObject"]
tags: ["testing", "events", "validation", "integration", "business-events", "samples"]
---

# Event Testing Strategies - Code Samples

## Complete Integration Event Test Suite

### Customer Registration Event Testing System

```al
codeunit 50200 "Customer Registration Tests"
{
    Subtype = Test;
    
    var
        LibraryCustomer: Codeunit "Library - Customer";
        LibraryAssert: Codeunit "Library Assert";
        EventTestHelper: Codeunit "Customer Registration Event Test";
        
    [Test]
    procedure TestCustomerRegistrationEventChain()
    var
        Customer: Record Customer;
        CustomerReg: Codeunit "Customer Registration";
        OriginalCount: Integer;
    begin
        // Setup
        Initialize();
        LibraryCustomer.CreateCustomer(Customer);
        Customer.Delete(); // We'll recreate through registration
        
        // Get baseline customer count
        OriginalCount := GetCustomerCount();
        
        // Bind event testing subscriber
        BindSubscription(EventTestHelper);
        EventTestHelper.ResetEventState();
        
        // Execute registration process
        CustomerReg.RegisterNewCustomer(Customer);
        
        // Verify events fired in correct sequence
        LibraryAssert.IsTrue(EventTestHelper.WasBeforeEventFired(), 'Before event must fire');
        LibraryAssert.IsTrue(EventTestHelper.WasAfterEventFired(), 'After event must fire');
        LibraryAssert.AreEqual(Customer."No.", EventTestHelper.GetEventCustomerNo(), 'Event should contain correct customer number');
        
        // Verify business logic completed
        LibraryAssert.AreEqual(OriginalCount + 1, GetCustomerCount(), 'Customer should be created');
        LibraryAssert.IsTrue(Customer.Find(), 'Customer record should exist');
        
        // Cleanup
        UnbindSubscription(EventTestHelper);
    end;
    
    [Test]
    procedure TestEventParameterModification()
    var
        SalesHeader: Record "Sales Header";
        ValidationErrors: List of [Text];
        OrderValidation: Codeunit "Order Validation";
        TestSubscriber: Codeunit "Test Validation Subscriber";
        ErrorCount: Integer;
    begin
        // Setup
        Initialize();
        CreateTestSalesOrder(SalesHeader);
        
        // Bind subscriber that will add validation errors
        BindSubscription(TestSubscriber);
        TestSubscriber.SetShouldAddError(true);
        TestSubscriber.SetCustomErrorMessage('Test validation rule failed');
        
        // Execute validation - should collect errors from subscriber
        OrderValidation.ValidateOrder(SalesHeader, ValidationErrors);
        ErrorCount := ValidationErrors.Count;
        
        // Verify custom validation was included
        LibraryAssert.IsTrue(ErrorCount > 0, 'Validation should produce errors');
        LibraryAssert.IsTrue(ValidationErrorsContain(ValidationErrors, 'Test validation rule failed'), 
                           'Should contain custom validation error');
        
        // Test with subscriber disabled
        UnbindSubscription(TestSubscriber);
        Clear(ValidationErrors);
        OrderValidation.ValidateOrder(SalesHeader, ValidationErrors);
        
        LibraryAssert.IsTrue(ValidationErrors.Count < ErrorCount, 
                           'Error count should decrease when subscriber is disabled');
    end;
    
    [Test]
    procedure TestEventHandlerOverride()
    var
        Customer: Record Customer;
        CustomerReg: Codeunit "Customer Registration";
        OverrideSubscriber: Codeunit "Registration Override Subscriber";
        Result: Boolean;
    begin
        // Setup
        Initialize();
        LibraryCustomer.CreateCustomer(Customer);
        Customer.Delete(); // We'll test override behavior
        
        // Bind override subscriber
        BindSubscription(OverrideSubscriber);
        OverrideSubscriber.SetShouldOverride(true);
        
        // Execute - subscriber should handle the process
        Result := CustomerReg.RegisterNewCustomer(Customer);
        
        // Verify override worked
        LibraryAssert.IsTrue(Result, 'Registration should return success');
        LibraryAssert.IsTrue(OverrideSubscriber.WasOverrideExecuted(), 'Override should have executed');
        LibraryAssert.IsFalse(Customer.Find(), 'Customer should not be created by standard process');
        
        // Cleanup
        UnbindSubscription(OverrideSubscriber);
    end;
    
    [Test]
    procedure TestEventExceptionHandling()
    var
        Customer: Record Customer;
        CustomerReg: Codeunit "Customer Registration";
        FaultySubscriber: Codeunit "Faulty Event Subscriber";
        Result: Boolean;
    begin
        // Setup
        Initialize();
        LibraryCustomer.CreateCustomer(Customer);
        Customer.Delete();
        
        // Bind subscriber that will throw exception
        BindSubscription(FaultySubscriber);
        FaultySubscriber.SetShouldThrowError(true);
        
        // Execute - should handle exceptions gracefully
        Result := CustomerReg.RegisterNewCustomer(Customer);
        
        // Verify main process completed despite subscriber error
        LibraryAssert.IsTrue(Result, 'Main process should complete despite subscriber error');
        LibraryAssert.IsTrue(Customer.Find(), 'Customer should be created');
        LibraryAssert.IsTrue(FaultySubscriber.DidErrorOccur(), 'Error should have been caught');
        
        // Cleanup
        UnbindSubscription(FaultySubscriber);
    end;
    
    local procedure Initialize()
    begin
        // Setup common test data and state
    end;
    
    local procedure CreateTestSalesOrder(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        LibraryCustomer.CreateCustomer(Customer);
        
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := LibraryUtility.GenerateGUID();
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Insert(true);
        
        // Add test line
        LibraryInventory.CreateItem(Item);
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := Item."No.";
        SalesLine.Quantity := 1;
        SalesLine.Insert(true);
    end;
    
    local procedure GetCustomerCount(): Integer
    var
        Customer: Record Customer;
    begin
        exit(Customer.Count);
    end;
    
    local procedure ValidationErrorsContain(var ValidationErrors: List of [Text]; SearchText: Text): Boolean
    var
        ErrorMessage: Text;
    begin
        foreach ErrorMessage in ValidationErrors do
            if ErrorMessage.Contains(SearchText) then
                exit(true);
        exit(false);
    end;
}
```

### Event Testing Support Codeunits

```al
codeunit 50201 "Customer Registration Event Test"
{
    var
        BeforeEventFired: Boolean;
        AfterEventFired: Boolean;
        EventCustomerNo: Code[20];
        EventFireSequence: List of [Text];
        EventTimestamp: DateTime;
        
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration", 'OnBeforeCustomerRegistration', '', false, false)]
    local procedure OnBeforeCustomerRegistration(var Customer: Record Customer; var IsHandled: Boolean)
    begin
        BeforeEventFired := true;
        EventCustomerNo := Customer."No.";
        EventFireSequence.Add('BeforeRegistration');
        EventTimestamp := CurrentDateTime;
        
        // Log event firing for debugging
        Session.LogMessage('EventTest', 
                          StrSubstNo('BeforeCustomerRegistration fired for %1', Customer."No."), 
                          Verbosity::Normal, DataClassification::CustomerContent, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'EventTest');
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration", 'OnAfterCustomerRegistration', '', false, false)]
    local procedure OnAfterCustomerRegistration(var Customer: Record Customer)
    begin
        AfterEventFired := true;
        EventFireSequence.Add('AfterRegistration');
        
        // Verify customer data is available in after event
        Customer.TestField("No.");
        if Customer."No." = '' then
            Error('Customer number should be populated in after event');
            
        Session.LogMessage('EventTest', 
                          StrSubstNo('AfterCustomerRegistration fired for %1', Customer."No."), 
                          Verbosity::Normal, DataClassification::CustomerContent, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'EventTest');
    end;
    
    procedure WasBeforeEventFired(): Boolean
    begin
        exit(BeforeEventFired);
    end;
    
    procedure WasAfterEventFired(): Boolean
    begin
        exit(AfterEventFired);
    end;
    
    procedure GetEventCustomerNo(): Code[20]
    begin
        exit(EventCustomerNo);
    end;
    
    procedure GetEventSequence(): List of [Text]
    begin
        exit(EventFireSequence);
    end;
    
    procedure GetEventTimestamp(): DateTime
    begin
        exit(EventTimestamp);
    end;
    
    procedure ResetEventState()
    begin
        BeforeEventFired := false;
        AfterEventFired := false;
        Clear(EventCustomerNo);
        Clear(EventFireSequence);
        Clear(EventTimestamp);
    end;
    
    procedure VerifyEventSequence(ExpectedSequence: List of [Text]): Boolean
    var
        ActualEvent: Text;
        ExpectedEvent: Text;
        Index: Integer;
    begin
        if EventFireSequence.Count <> ExpectedSequence.Count then
            exit(false);
            
        for Index := 1 to EventFireSequence.Count do begin
            ActualEvent := EventFireSequence.Get(Index);
            ExpectedEvent := ExpectedSequence.Get(Index);
            if ActualEvent <> ExpectedEvent then
                exit(false);
        end;
        
        exit(true);
    end;
}

codeunit 50202 "Registration Override Subscriber"
{
    var
        ShouldOverride: Boolean;
        OverrideExecuted: Boolean;
        
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration", 'OnBeforeCustomerRegistration', '', false, false)]
    local procedure OverrideCustomerRegistration(var Customer: Record Customer; var IsHandled: Boolean)
    begin
        if ShouldOverride then begin
            IsHandled := true;
            OverrideExecuted := true;
            
            // Custom override logic here
            Session.LogMessage('EventTest', 
                              StrSubstNo('Customer registration overridden for %1', Customer."No."), 
                              Verbosity::Normal, DataClassification::CustomerContent, 
                              TelemetryScope::ExtensionPublisher, 'Category', 'EventTest');
        end;
    end;
    
    procedure SetShouldOverride(Override: Boolean)
    begin
        ShouldOverride := Override;
    end;
    
    procedure WasOverrideExecuted(): Boolean
    begin
        exit(OverrideExecuted);
    end;
    
    procedure Reset()
    begin
        ShouldOverride := false;
        OverrideExecuted := false;
    end;
}
```

## Business Event Testing Framework

### Complete Business Event Test Suite

```al
codeunit 50203 "Business Event Tests"
{
    Subtype = Test;
    
    var
        LibraryAssert: Codeunit "Library Assert";
        TelemetryLogger: Codeunit "Test Telemetry Logger";
        
    [Test]
    procedure TestCustomerCreatedBusinessEvent()
    var
        Customer: Record Customer;
        CustomerEvents: Codeunit "Customer Events Publisher";
        ExpectedEventType: Text;
        EventPayload: JsonObject;
    begin
        // Setup
        Initialize();
        CreateTestCustomer(Customer);
        ExpectedEventType := 'CustomerCreated';
        
        // Bind telemetry capture
        BindSubscription(TelemetryLogger);
        TelemetryLogger.Reset();
        
        // Execute business event
        CustomerEvents.PublishCustomerCreated(Customer);
        
        // Verify event was published
        LibraryAssert.IsTrue(TelemetryLogger.ContainsMessage(ExpectedEventType), 
                           'Business event should be logged');
        LibraryAssert.IsTrue(TelemetryLogger.ContainsCategory('BusinessEvent'), 
                           'Event should use BusinessEvent category');
        
        // Verify event structure
        EventPayload := ParseEventPayload(TelemetryLogger.GetLastMessage());
        VerifyCustomerEventStructure(EventPayload, Customer);
        
        // Cleanup
        UnbindSubscription(TelemetryLogger);
    end;
    
    [Test]
    procedure TestMultipleBusinessEventsSequence()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CustomerEvents: Codeunit "Customer Events Publisher";
        OrderEvents: Codeunit "Order Events Publisher";
        EventSequence: List of [Text];
        ExpectedSequence: List of [Text];
    begin
        // Setup
        Initialize();
        CreateTestCustomer(Customer);
        CreateTestSalesOrder(SalesHeader);
        
        BindSubscription(TelemetryLogger);
        TelemetryLogger.Reset();
        
        // Execute business event sequence
        CustomerEvents.PublishCustomerCreated(Customer);
        OrderEvents.PublishOrderCreated(SalesHeader);
        OrderEvents.PublishOrderStatusChanged(SalesHeader, SalesHeader.Status::"Pending Approval");
        
        // Verify event sequence
        EventSequence := TelemetryLogger.GetEventTypes();
        ExpectedSequence.Add('CustomerCreated');
        ExpectedSequence.Add('OrderCreated');
        ExpectedSequence.Add('OrderStatusChanged');
        
        VerifyEventSequence(EventSequence, ExpectedSequence);
        
        // Verify each event has correct timestamp ordering
        VerifyEventTimestampOrdering(TelemetryLogger.GetEventTimestamps());
        
        UnbindSubscription(TelemetryLogger);
    end;
    
    [Test]
    procedure TestBusinessEventErrorHandling()
    var
        Customer: Record Customer;
        CustomerEvents: Codeunit "Customer Events Publisher";
        FaultyEventPublisher: Codeunit "Faulty Event Publisher";
        Result: Boolean;
    begin
        // Setup
        Initialize();
        CreateTestCustomer(Customer);
        
        // Bind faulty publisher that will cause errors
        BindSubscription(FaultyEventPublisher);
        FaultyEventPublisher.SetShouldFail(true);
        
        BindSubscription(TelemetryLogger);
        TelemetryLogger.Reset();
        
        // Execute - should handle publishing errors gracefully
        Result := TryPublishCustomerEvent(Customer);
        
        // Verify error handling
        LibraryAssert.IsFalse(Result, 'Publishing should fail with faulty publisher');
        LibraryAssert.IsTrue(TelemetryLogger.ContainsMessage('Error'), 
                           'Error should be logged');
        
        // Verify main process continues despite event publishing failure
        LibraryAssert.IsTrue(Customer.Find(), 'Customer should still exist');
        
        // Cleanup
        UnbindSubscription(FaultyEventPublisher);
        UnbindSubscription(TelemetryLogger);
    end;
    
    [Test]
    procedure TestEventPayloadDataClassification()
    var
        Customer: Record Customer;
        CustomerEvents: Codeunit "Customer Events Publisher";
        EventMessage: Text;
        PayloadJson: JsonObject;
        CustomerName: Text;
    begin
        // Setup customer with sensitive data
        Initialize();
        CreateTestCustomer(Customer);
        Customer.Name := 'Sensitive Customer Name';
        Customer.Modify();
        
        BindSubscription(TelemetryLogger);
        TelemetryLogger.Reset();
        
        // Publish event
        CustomerEvents.PublishCustomerCreated(Customer);
        
        // Verify data classification in telemetry
        EventMessage := TelemetryLogger.GetLastMessage();
        LibraryAssert.IsTrue(EventMessage <> '', 'Event message should be captured');
        
        // Verify sensitive data is properly classified
        PayloadJson := ParseEventPayload(EventMessage);
        if PayloadJson.Get('customerName', CustomerName) then
            LibraryAssert.AreEqual(Customer.Name, CustomerName, 'Customer name should match');
            
        // Verify telemetry used correct data classification
        LibraryAssert.IsTrue(TelemetryLogger.GetLastDataClassification() = DataClassification::CustomerContent, 
                           'Should use CustomerContent classification for customer data');
        
        UnbindSubscription(TelemetryLogger);
    end;
    
    local procedure Initialize()
    begin
        // Common test setup
        Commit(); // Ensure clean state
    end;
    
    local procedure CreateTestCustomer(var Customer: Record Customer)
    begin
        Customer.Init();
        Customer."No." := LibraryUtility.GenerateGUID();
        Customer.Name := 'Test Customer ' + Customer."No.";
        Customer."Customer Posting Group" := GetDefaultCustomerPostingGroup();
        Customer."Gen. Bus. Posting Group" := GetDefaultGenBusPostingGroup();
        Customer.Insert(true);
    end;
    
    local procedure CreateTestSalesOrder(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        CreateTestCustomer(Customer);
        
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := LibraryUtility.GenerateGUID();
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Insert(true);
    end;
    
    local procedure ParseEventPayload(EventMessage: Text): JsonObject
    var
        EventJson: JsonObject;
    begin
        if not EventJson.ReadFrom(EventMessage) then
            Error('Failed to parse event payload: %1', EventMessage);
        exit(EventJson);
    end;
    
    local procedure VerifyCustomerEventStructure(EventPayload: JsonObject; Customer: Record Customer)
    var
        EventToken: JsonToken;
        ActualValue: Text;
    begin
        // Verify required fields
        LibraryAssert.IsTrue(EventPayload.Get('eventType', EventToken), 'Should contain eventType');
        LibraryAssert.AreEqual('CustomerCreated', EventToken.AsValue().AsText(), 'Event type should match');
        
        LibraryAssert.IsTrue(EventPayload.Get('customerNo', EventToken), 'Should contain customerNo');
        ActualValue := EventToken.AsValue().AsText();
        LibraryAssert.AreEqual(Customer."No.", ActualValue, 'Customer number should match');
        
        LibraryAssert.IsTrue(EventPayload.Get('customerName', EventToken), 'Should contain customerName');
        ActualValue := EventToken.AsValue().AsText();
        LibraryAssert.AreEqual(Customer.Name, ActualValue, 'Customer name should match');
        
        LibraryAssert.IsTrue(EventPayload.Get('timestamp', EventToken), 'Should contain timestamp');
        LibraryAssert.IsTrue(EventPayload.Get('createdBy', EventToken), 'Should contain createdBy');
        
        ActualValue := EventToken.AsValue().AsText();
        LibraryAssert.AreEqual(UserId, ActualValue, 'Created by should match current user');
    end;
    
    local procedure VerifyEventSequence(ActualSequence: List of [Text]; ExpectedSequence: List of [Text])
    var
        Index: Integer;
        ActualEvent: Text;
        ExpectedEvent: Text;
    begin
        LibraryAssert.AreEqual(ExpectedSequence.Count, ActualSequence.Count, 
                             'Event sequence count should match');
        
        for Index := 1 to ExpectedSequence.Count do begin
            ActualEvent := ActualSequence.Get(Index);
            ExpectedEvent := ExpectedSequence.Get(Index);
            LibraryAssert.AreEqual(ExpectedEvent, ActualEvent, 
                                  StrSubstNo('Event %1 should match at position %2', ExpectedEvent, Index));
        end;
    end;
    
    local procedure VerifyEventTimestampOrdering(Timestamps: List of [DateTime])
    var
        PreviousTimestamp: DateTime;
        CurrentTimestamp: DateTime;
        Index: Integer;
    begin
        if Timestamps.Count <= 1 then
            exit; // No ordering to verify
            
        PreviousTimestamp := Timestamps.Get(1);
        for Index := 2 to Timestamps.Count do begin
            CurrentTimestamp := Timestamps.Get(Index);
            LibraryAssert.IsTrue(CurrentTimestamp >= PreviousTimestamp, 
                               StrSubstNo('Timestamp at position %1 should be >= previous timestamp', Index));
            PreviousTimestamp := CurrentTimestamp;
        end;
    end;
    
    [TryFunction]
    local procedure TryPublishCustomerEvent(Customer: Record Customer)
    var
        CustomerEvents: Codeunit "Customer Events Publisher";
    begin
        CustomerEvents.PublishCustomerCreated(Customer);
    end;
    
    local procedure GetDefaultCustomerPostingGroup(): Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        CustomerPostingGroup.FindFirst();
        exit(CustomerPostingGroup.Code);
    end;
    
    local procedure GetDefaultGenBusPostingGroup(): Code[20]
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        GenBusinessPostingGroup.FindFirst();
        exit(GenBusinessPostingGroup.Code);
    end;
}
```

### Advanced Telemetry Testing Helper

```al
codeunit 50204 "Advanced Telemetry Logger"
{
    var
        LoggedMessages: List of [Text];
        EventTypes: List of [Text];
        EventTimestamps: List of [DateTime];
        MessageCategories: List of [Text];
        DataClassifications: List of [DataClassification];
        VerbosityLevels: List of [Verbosity];
        
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnAfterLogTelemetry', '', false, false)]
    local procedure CaptureLoggedMessages(EventId: Text; Message: Text; Verbosity: Verbosity; 
                                        DataClassification: DataClassification; 
                                        TelemetryScope: TelemetryScope; Category: Text)
    var
        MessageJson: JsonObject;
        EventTypeToken: JsonToken;
        TimestampToken: JsonToken;
        EventTimestamp: DateTime;
    begin
        LoggedMessages.Add(Message);
        MessageCategories.Add(Category);
        DataClassifications.Add(DataClassification);
        VerbosityLevels.Add(Verbosity);
        
        // Extract event type and timestamp if message is JSON
        if MessageJson.ReadFrom(Message) then begin
            if MessageJson.Get('eventType', EventTypeToken) then
                EventTypes.Add(EventTypeToken.AsValue().AsText());
                
            if MessageJson.Get('timestamp', TimestampToken) then begin
                if Evaluate(EventTimestamp, TimestampToken.AsValue().AsText()) then
                    EventTimestamps.Add(EventTimestamp)
                else
                    EventTimestamps.Add(CurrentDateTime);
            end else
                EventTimestamps.Add(CurrentDateTime);
        end else begin
            // Non-JSON message
            EventTypes.Add('Unknown');
            EventTimestamps.Add(CurrentDateTime);
        end;
    end;
    
    procedure ContainsMessage(SearchText: Text): Boolean
    var
        Message: Text;
    begin
        foreach Message in LoggedMessages do
            if Message.Contains(SearchText) then
                exit(true);
        exit(false);
    end;
    
    procedure ContainsCategory(SearchCategory: Text): Boolean
    var
        Category: Text;
    begin
        foreach Category in MessageCategories do
            if Category = SearchCategory then
                exit(true);
        exit(false);
    end;
    
    procedure GetLastMessage(): Text
    begin
        if LoggedMessages.Count > 0 then
            exit(LoggedMessages.Get(LoggedMessages.Count))
        else
            exit('');
    end;
    
    procedure GetLastDataClassification(): DataClassification
    begin
        if DataClassifications.Count > 0 then
            exit(DataClassifications.Get(DataClassifications.Count))
        else
            exit(DataClassification::SystemMetadata);
    end;
    
    procedure GetEventTypes(): List of [Text]
    begin
        exit(EventTypes);
    end;
    
    procedure GetEventTimestamps(): List of [DateTime]
    begin
        exit(EventTimestamps);
    end;
    
    procedure GetMessageCount(): Integer
    begin
        exit(LoggedMessages.Count);
    end;
    
    procedure GetMessagesByCategory(Category: Text): List of [Text]
    var
        FilteredMessages: List of [Text];
        Index: Integer;
        CurrentCategory: Text;
    begin
        for Index := 1 to MessageCategories.Count do begin
            CurrentCategory := MessageCategories.Get(Index);
            if CurrentCategory = Category then
                FilteredMessages.Add(LoggedMessages.Get(Index));
        end;
        exit(FilteredMessages);
    end;
    
    procedure GetMessagesByVerbosity(Verbosity: Verbosity): List of [Text]
    var
        FilteredMessages: List of [Text];
        Index: Integer;
        CurrentVerbosity: Verbosity;
    begin
        for Index := 1 to VerbosityLevels.Count do begin
            CurrentVerbosity := VerbosityLevels.Get(Index);
            if CurrentVerbosity = Verbosity then
                FilteredMessages.Add(LoggedMessages.Get(Index));
        end;
        exit(FilteredMessages);
    end;
    
    procedure Reset()
    begin
        Clear(LoggedMessages);
        Clear(EventTypes);
        Clear(EventTimestamps);
        Clear(MessageCategories);
        Clear(DataClassifications);
        Clear(VerbosityLevels);
    end;
    
    procedure GenerateTestReport(): Text
    var
        ReportJson: JsonObject;
        StatsJson: JsonObject;
        EventTypeStats: JsonObject;
        CategoryStats: JsonObject;
        EventType: Text;
        Category: Text;
        TypeCount: Integer;
        CatCount: Integer;
        UniqueEventTypes: List of [Text];
        UniqueCategories: List of [Text];
    begin
        // Generate summary statistics
        StatsJson.Add('totalMessages', LoggedMessages.Count);
        StatsJson.Add('totalEventTypes', GetUniqueCount(EventTypes));
        StatsJson.Add('totalCategories', GetUniqueCount(MessageCategories));
        
        // Event type breakdown
        UniqueEventTypes := GetUniqueValues(EventTypes);
        foreach EventType in UniqueEventTypes do begin
            TypeCount := CountOccurrences(EventTypes, EventType);
            EventTypeStats.Add(EventType, TypeCount);
        end;
        
        // Category breakdown  
        UniqueCategories := GetUniqueValues(MessageCategories);
        foreach Category in UniqueCategories do begin
            CatCount := CountOccurrences(MessageCategories, Category);
            CategoryStats.Add(Category, CatCount);
        end;
        
        ReportJson.Add('summary', StatsJson);
        ReportJson.Add('eventTypeBreakdown', EventTypeStats);
        ReportJson.Add('categoryBreakdown', CategoryStats);
        ReportJson.Add('generatedAt', CurrentDateTime);
        
        exit(Format(ReportJson));
    end;
    
    local procedure GetUniqueCount(Values: List of [Text]): Integer
    var
        UniqueValues: List of [Text];
        Value: Text;
    begin
        foreach Value in Values do
            if not UniqueValues.Contains(Value) then
                UniqueValues.Add(Value);
        exit(UniqueValues.Count);
    end;
    
    local procedure GetUniqueValues(Values: List of [Text]): List of [Text]
    var
        UniqueValues: List of [Text];
        Value: Text;
    begin
        foreach Value in Values do
            if not UniqueValues.Contains(Value) then
                UniqueValues.Add(Value);
        exit(UniqueValues);
    end;
    
    local procedure CountOccurrences(Values: List of [Text]; SearchValue: Text): Integer
    var
        Count: Integer;
        Value: Text;
    begin
        foreach Value in Values do
            if Value = SearchValue then
                Count += 1;
        exit(Count);
    end;
}
```

These comprehensive test samples provide a complete framework for validating event-driven architecture in Business Central, ensuring your integration and business events work reliably under all conditions.
