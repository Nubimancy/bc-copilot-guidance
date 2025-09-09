---
title: "Integration Event Patterns - Code Samples"
description: "Complete code examples for integration event implementation patterns"
area: "integration"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "List"]
tags: ["integration-events", "samples", "before-after-pattern", "validation-events"]
---

# Integration Event Patterns - Code Samples

## Core Pattern: Before/After Events

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
    
    local procedure ValidateCustomerData(var Customer: Record Customer)
    begin
        // Validation logic
        if Customer."No." = '' then
            Error('Customer number is required');
    end;
    
    local procedure SetDefaultSettings(var Customer: Record Customer)
    begin
        // Default settings logic
        Customer."Customer Posting Group" := 'DOMESTIC';
        Customer.Modify();
    end;
}
```

## Advanced Pattern: Validation Events with Error Handling

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
            
        if not ValidateCreditLimit(SalesHeader) then
            ValidationErrors.Add('Customer credit limit exceeded');
    end;
    
    local procedure ValidateCustomBusinessRule(SalesHeader: Record "Sales Header"): Boolean
    begin
        // Custom business validation logic
        exit(SalesHeader."Document Type" = SalesHeader."Document Type"::Order);
    end;
    
    local procedure ValidateCreditLimit(SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
    begin
        if Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit(Customer."Credit Limit (LCY)" >= SalesHeader."Amount Including VAT");
        exit(false);
    end;
}
```

## Related Topics
- [Integration Event Patterns](integration-event-patterns.md)
- [Event Design Principles](event-design-principles.md)
- [Event Testing Patterns](event-testing-patterns.md)
