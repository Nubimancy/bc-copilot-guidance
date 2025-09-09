---
title: "Event Design Principles - Code Samples"
description: "Complete code examples demonstrating event design principles and performance optimization"
area: "integration"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "Date"]
tags: ["event-design", "samples", "performance", "best-practices"]
---

# Event Design Principles - Code Samples

## Efficient Event Parameter Passing

```al
codeunit 50108 "Performance Optimized Events"
{
    // ✅ GOOD: Pass only necessary data
    [IntegrationEvent(false, false)]
    local procedure OnValidateOrderLine(OrderNo: Code[20]; LineNo: Integer; ItemNo: Code[20]; Quantity: Decimal)
    begin
    end;
    
    // ❌ AVOID: Passing entire record when not needed
    [IntegrationEvent(false, false)]
    local procedure OnValidateOrderLineInefficient(var SalesLine: Record "Sales Line")
    begin
    end;
    
    // ✅ GOOD: Use SetLoadFields for performance
    procedure ProcessOrderWithEvents(OrderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.SetLoadFields("No.", "Sell-to Customer No.", "Order Date");
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        
        OnBeforeProcessOrder(SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Order Date");
        
        // Process order...
        
        OnAfterProcessOrder(SalesHeader."No.");
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrder(OrderNo: Code[20]; CustomerNo: Code[20]; OrderDate: Date)
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessOrder(OrderNo: Code[20])
    begin
    end;
}
```

## Event Naming Best Practices

```al
codeunit 50109 "Event Naming Examples"
{
    // ✅ GOOD: Clear, descriptive names
    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateOrderLine(OrderNo: Code[20]; LineNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateOrderTotal(OrderNo: Code[20]; TotalAmount: Decimal)
    begin
    end;

    // ❌ AVOID: Generic or unclear names
    [IntegrationEvent(false, false)]
    local procedure OnEvent(var Rec: Record "Sales Line")
    begin
    end;
    
    // ✅ GOOD: Consistent patterns across similar events
    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateCustomer(var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateItem(var Item: Record Item; var IsHandled: Boolean)
    begin
    end;
}
```

## Performance-Optimized Event Subscribers

```al
codeunit 50110 "Optimized Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)
    begin
        // ✅ GOOD: Quick checks to avoid unnecessary processing
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        
        if PreviewMode then
            exit;
            
        // Main logic here only if needed
        PerformCustomOrderValidation(SalesHeader);
    end;
    
    local procedure PerformCustomOrderValidation(var SalesHeader: Record "Sales Header")
    begin
        // Custom validation logic
    end;
}
```

## Related Topics
- [Event Design Principles](event-design-principles.md)
- [Integration Event Patterns](integration-event-patterns.md)
- [Business Event Patterns](business-event-patterns.md)
