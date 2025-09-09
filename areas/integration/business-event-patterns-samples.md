---
title: "Business Event Patterns - Code Samples"
description: "Complete code examples for business event publishing and consuming patterns"
area: "integration"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["JsonObject", "HttpClient", "JsonToken"]
tags: ["business-events", "samples", "event-publishing", "event-consuming"]
---

# Business Event Patterns - Code Samples

## Publishing Business Events

```al
codeunit 50103 "Business Event Publisher"
{
    procedure PublishCustomerCreatedEvent(Customer: Record Customer)
    var
        BusinessEventPayload: JsonObject;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        JsonContent: Text;
    begin
        // Build event payload
        BusinessEventPayload.Add('eventType', 'CustomerCreated');
        BusinessEventPayload.Add('timestamp', Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24>:<Minutes,2>:<Seconds,2>Z'));
        BusinessEventPayload.Add('customerNo', Customer."No.");
        BusinessEventPayload.Add('customerName', Customer.Name);
        BusinessEventPayload.Add('customerType', Format(Customer."Customer Type"));
        
        BusinessEventPayload.WriteTo(JsonContent);
        
        // Publish to external system
        HttpContent.WriteFrom(JsonContent);
        HttpContent.GetHeaders().Add('Content-Type', 'application/json');
        
        if HttpClient.Post('https://external-system.com/api/events', HttpContent, HttpResponse) then begin
            if HttpResponse.IsSuccessStatusCode() then
                LogEventPublished('CustomerCreated', Customer."No.")
            else
                LogEventFailed('CustomerCreated', Customer."No.", HttpResponse.ReasonPhrase());
        end else
            HandleEventPublishingError('CustomerCreated', Customer."No.");
    end;
    
    local procedure LogEventPublished(EventType: Text; EntityKey: Text)
    begin
        // Log successful event publishing
    end;
    
    local procedure LogEventFailed(EventType: Text; EntityKey: Text; ErrorMessage: Text)
    begin
        // Log failed event publishing
    end;
    
    local procedure HandleEventPublishingError(EventType: Text; EntityKey: Text)
    begin
        // Handle publishing errors (retry logic, etc.)
    end;
}
```

## Consuming Business Events from External Systems

```al
codeunit 50104 "Business Event Consumer"
{
    procedure ProcessIncomingEvent(EventPayload: JsonObject): Boolean
    var
        EventType: Text;
        EventToken: JsonToken;
    begin
        if not EventPayload.Get('eventType', EventToken) then
            exit(false);
            
        EventType := EventToken.AsValue().AsText();
        
        case EventType of
            'OrderStatusChanged':
                ProcessOrderStatusChange(EventPayload);
            'PaymentReceived':
                ProcessPaymentReceived(EventPayload);
            'ShippingUpdate':
                ProcessShippingUpdate(EventPayload);
            else
                exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure ProcessOrderStatusChange(EventPayload: JsonObject)
    var
        SalesHeader: Record "Sales Header";
        OrderNoToken: JsonToken;
        StatusToken: JsonToken;
        OrderNo: Code[20];
        NewStatus: Text;
    begin
        if EventPayload.Get('orderNo', OrderNoToken) and EventPayload.Get('status', StatusToken) then begin
            OrderNo := OrderNoToken.AsValue().AsCode();
            NewStatus := StatusToken.AsValue().AsText();
            
            if SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then begin
                // Update order based on external status change
                UpdateOrderStatus(SalesHeader, NewStatus);
            end;
        end;
    end;
    
    local procedure ProcessPaymentReceived(EventPayload: JsonObject)
    var
        PaymentAmount: Decimal;
        CustomerNo: Code[20];
        AmountToken: JsonToken;
        CustomerToken: JsonToken;
    begin
        if EventPayload.Get('amount', AmountToken) and EventPayload.Get('customerNo', CustomerToken) then begin
            PaymentAmount := AmountToken.AsValue().AsDecimal();
            CustomerNo := CustomerToken.AsValue().AsCode();
            
            // Process payment receipt
            CreatePaymentEntry(CustomerNo, PaymentAmount);
        end;
    end;
    
    local procedure ProcessShippingUpdate(EventPayload: JsonObject)
    begin
        // Process shipping update logic
    end;
    
    local procedure UpdateOrderStatus(var SalesHeader: Record "Sales Header"; NewStatus: Text)
    begin
        // Update order status based on external system
        case NewStatus of
            'Shipped':
                SalesHeader.Status := SalesHeader.Status::Released;
            'Delivered':
                begin
                    // Custom delivery processing
                end;
        end;
        SalesHeader.Modify();
    end;
    
    local procedure CreatePaymentEntry(CustomerNo: Code[20]; Amount: Decimal)
    begin
        // Create payment entry logic
    end;
}
```

## Related Topics
- [Business Event Patterns](business-event-patterns.md)
- [Event Design Principles](event-design-principles.md)
- [Integration Event Patterns](integration-event-patterns.md)
