---
title: "Event Testing Patterns - Code Samples"
description: "Complete code examples for testing event-driven functionality"
area: "integration"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "JsonObject"]
tags: ["event-testing", "samples", "unit-testing", "mock-objects"]
---

# Event Testing Patterns - Code Samples

## Testing Integration Events

```al
codeunit 50105 "Event Testing"
{
    Subtype = Test;

    [Test]
    procedure TestCustomerRegistrationEvent()
    var
        Customer: Record Customer;
        CustomerRegistration: Codeunit "Customer Registration";
        EventFired: Boolean;
    begin
        // Setup
        Customer.Init();
        Customer."No." := 'TEST001';
        Customer.Name := 'Test Customer';
        
        // Bind event subscriber for testing
        BindSubscription(MockCustomerEventSubscriber);
        
        // Exercise
        CustomerRegistration.RegisterNewCustomer(Customer);
        
        // Verify
        EventFired := MockCustomerEventSubscriber.GetAfterEventFired();
        LibraryAssert.IsTrue(EventFired, 'After registration event should have fired');
        
        // Cleanup
        UnbindSubscription(MockCustomerEventSubscriber);
    end;
    
    var
        MockCustomerEventSubscriber: Codeunit "Mock Customer Event Subscriber";
}

codeunit 50106 "Mock Customer Event Subscriber"
{
    var
        AfterEventFired: Boolean;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration", 'OnAfterCustomerRegistration', '', false, false)]
    local procedure OnAfterCustomerRegistration(var Customer: Record Customer)
    begin
        AfterEventFired := true;
    end;
    
    procedure GetAfterEventFired(): Boolean
    begin
        exit(AfterEventFired);
    end;
    
    procedure Reset()
    begin
        AfterEventFired := false;
    end;
}
```

## Testing Business Events

```al
codeunit 50107 "Business Event Testing"
{
    Subtype = Test;

    [Test]
    procedure TestEventPayloadStructure()
    var
        Customer: Record Customer;
        BusinessEventPublisher: Codeunit "Business Event Publisher";
        MockHttpClient: Codeunit "Mock Http Client";
        EventPayload: Text;
        PayloadJson: JsonObject;
        EventTypeToken: JsonToken;
    begin
        // Setup
        Customer.Init();
        Customer."No." := 'CUST001';
        Customer.Name := 'Test Customer';
        Customer.Insert();
        
        // Mock HTTP client to capture payload
        MockHttpClient.SetupMockResponse(200, 'OK');
        
        // Exercise
        BusinessEventPublisher.PublishCustomerCreatedEvent(Customer);
        
        // Verify payload structure
        EventPayload := MockHttpClient.GetLastRequestContent();
        PayloadJson.ReadFrom(EventPayload);
        
        LibraryAssert.IsTrue(PayloadJson.Get('eventType', EventTypeToken), 'Event type should be present');
        LibraryAssert.AreEqual('CustomerCreated', EventTypeToken.AsValue().AsText(), 'Event type should be CustomerCreated');
        
        // Cleanup
        Customer.Delete();
    end;
}
```

## Event Subscriber Testing Patterns

```al
codeunit 50108 "Event Subscriber Testing"
{
    Subtype = Test;

    [Test]
    procedure TestEventSubscriberHandlesValidation()
    var
        SalesHeader: Record "Sales Header";
        OrderValidation: Codeunit "Order Validation";
        ValidationErrors: List of [Text];
    begin
        // Setup
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := 'TEST001';
        
        // Bind custom validation subscriber
        BindSubscription(TestValidationSubscriber);
        
        // Exercise - this should trigger validation events
        OrderValidation.ValidateOrder(SalesHeader);
        
        // Verify - check that custom validation was called
        LibraryAssert.IsTrue(TestValidationSubscriber.GetValidationCalled(), 'Custom validation should have been called');
        
        // Cleanup
        UnbindSubscription(TestValidationSubscriber);
    end;
    
    var
        TestValidationSubscriber: Codeunit "Test Validation Subscriber";
}
```

## Related Topics
- [Event Testing Patterns](event-testing-patterns.md)
- [Integration Event Patterns](integration-event-patterns.md)
- [Business Event Patterns](business-event-patterns.md)
