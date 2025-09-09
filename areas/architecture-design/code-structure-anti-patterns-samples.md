---
title: "Code Structure Anti-Patterns - Code Samples"
description: "Complete code examples showing common code organization mistakes and their solutions in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["Record", ]
tags: ["anti-patterns", "code-structure", "copy-paste", "nested-conditions", "samples"]
---

# Code Structure Anti-Patterns - Code Samples

## Copy-Paste Programming

### ❌ Problem: Duplicated logic leads to maintenance nightmares

```al
// Don't do this - repeated validation logic across multiple procedures
codeunit 50300 "Order Validation Bad Example"
{
    procedure ValidateCustomerOrder()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        OrderTotal: Decimal;
    begin
        // Duplicated validation logic #1
        Customer.Get(SalesHeader."Sell-to Customer No.");
        
        if Customer."Credit Limit" < OrderTotal then
            Error('Credit limit of %1 exceeded. Order total: %2', 
                Customer."Credit Limit", OrderTotal);
                
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked and cannot place orders', Customer."No.");
            
        if Customer."Payment Terms Code" = '' then
            Error('Customer %1 must have payment terms configured', Customer."No.");
            
        if Customer."Customer Posting Group" = '' then
            Error('Customer %1 must have posting group configured', Customer."No.");
    end;

    procedure ValidateCustomerInvoice()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        InvoiceTotal: Decimal;
    begin
        // Duplicated validation logic #2 - exactly the same!
        Customer.Get(SalesHeader."Bill-to Customer No.");
        
        if Customer."Credit Limit" < InvoiceTotal then
            Error('Credit limit of %1 exceeded. Invoice total: %2', 
                Customer."Credit Limit", InvoiceTotal);
                
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked and cannot be invoiced', Customer."No.");
            
        if Customer."Payment Terms Code" = '' then
            Error('Customer %1 must have payment terms configured', Customer."No.");
            
        if Customer."Customer Posting Group" = '' then
            Error('Customer %1 must have posting group configured', Customer."No.");
    end;
    
    procedure ValidateCustomerCreditMemo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CreditMemoTotal: Decimal;
    begin
        // Duplicated validation logic #3 - same again with slight variations!
        Customer.Get(SalesHeader."Bill-to Customer No.");
        
        if Customer."Credit Limit" < CreditMemoTotal then
            Error('Credit limit of %1 exceeded. Credit memo total: %2', 
                Customer."Credit Limit", CreditMemoTotal);
                
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked', Customer."No.");
            
        if Customer."Payment Terms Code" = '' then
            Error('Customer %1 payment terms missing', Customer."No.");
            
        // Notice: Missing posting group validation - inconsistent!
    end;
}
```

### ✅ Solution: Reusable validation with proper abstraction

```al
// ✅ Reusable validation with proper abstraction
codeunit 50300 "Customer Credit Validator"
{
    procedure ValidateCreditLimit(CustomerNo: Code[20]; Amount: Decimal)
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        
        if Customer."Credit Limit" < Amount then
            Error('Credit limit of %1 exceeded. Transaction amount: %2', 
                Customer."Credit Limit", Amount);
    end;
    
    procedure ValidateCustomerStatus(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked and cannot process transactions', CustomerNo);
    end;
    
    procedure ValidatePaymentTerms(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        
        if Customer."Payment Terms Code" = '' then
            Error('Customer %1 must have payment terms configured before processing transactions', CustomerNo);
    end;
    
    procedure ValidatePostingSetup(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        
        if Customer."Customer Posting Group" = '' then
            Error('Customer %1 must have posting group configured', CustomerNo);
    end;
    
    // Combined validation method for common scenarios
    procedure ValidateForTransaction(CustomerNo: Code[20]; Amount: Decimal)
    begin
        ValidateCustomerStatus(CustomerNo);
        ValidatePaymentTerms(CustomerNo);
        ValidatePostingSetup(CustomerNo);
        ValidateCreditLimit(CustomerNo, Amount);
    end;
    
    // Specific validation for different document types
    procedure ValidateForOrder(SalesHeader: Record "Sales Header")
    begin
        ValidateForTransaction(SalesHeader."Sell-to Customer No.", GetOrderTotal(SalesHeader));
    end;
    
    procedure ValidateForInvoice(SalesHeader: Record "Sales Header")
    begin
        ValidateForTransaction(SalesHeader."Bill-to Customer No.", GetInvoiceTotal(SalesHeader));
    end;
    
    procedure ValidateForCreditMemo(SalesHeader: Record "Sales Header")
    begin
        // Credit memos might have different validation rules
        ValidateCustomerStatus(SalesHeader."Bill-to Customer No.");
        ValidatePaymentTerms(SalesHeader."Bill-to Customer No.");
        ValidatePostingSetup(SalesHeader."Bill-to Customer No.");
        // Note: Credit limit not validated for credit memos
    end;
    
    local procedure GetOrderTotal(SalesHeader: Record "Sales Header"): Decimal
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        exit(SalesHeader."Amount Including VAT");
    end;
    
    local procedure GetInvoiceTotal(SalesHeader: Record "Sales Header"): Decimal
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        exit(SalesHeader."Amount Including VAT");
    end;
}

// Usage in other codeunits
codeunit 50301 "Order Processing Good Example"
{
    procedure ValidateCustomerOrder(SalesHeader: Record "Sales Header")
    var
        CustomerValidator: Codeunit "Customer Credit Validator";
    begin
        CustomerValidator.ValidateForOrder(SalesHeader);
    end;
    
    procedure ValidateCustomerInvoice(SalesHeader: Record "Sales Header")
    var
        CustomerValidator: Codeunit "Customer Credit Validator";
    begin
        CustomerValidator.ValidateForInvoice(SalesHeader);
    end;
}
```

## Nested IF-ELSE Pyramids (Pyramid of Doom)

### ❌ Problem: Deep nesting reduces readability

```al
// Don't do this - pyramid of doom makes code unreadable
codeunit 50400 "Order Processor Bad Example"
{
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        // 6 levels of nesting - cognitive overload!
        if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
            if Customer.Blocked = Customer.Blocked::" " then begin
                if Customer."Credit Limit" >= GetOrderTotal(SalesHeader) then begin
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    if SalesLine.FindSet() then begin
                        repeat
                            if Item.Get(SalesLine."No.") then begin
                                if Item.Inventory >= SalesLine.Quantity then begin
                                    if SalesHeader."Payment Terms Code" <> '' then begin
                                        if SalesHeader."Shipment Method Code" <> '' then begin
                                            // Finally, 8 levels deep, we can do something!
                                            ReserveSalesLine(SalesLine);
                                            PostSalesOrder(SalesHeader);
                                        end else
                                            Error('Shipment method is required');
                                    end else
                                        Error('Payment terms are required');
                                end else
                                    Error('Insufficient inventory for item %1', SalesLine."No.");
                            end else
                                Error('Item %1 does not exist', SalesLine."No.");
                        until SalesLine.Next() = 0;
                    end else
                        Error('Order has no lines');
                end else
                    Error('Customer credit limit exceeded');
            end else
                Error('Customer is blocked');
        end else
            Error('Customer not found');
    end;
}
```

### ✅ Solution: Guard clauses with early returns

```al
// ✅ Guard clauses with early returns - clean and readable
codeunit 50400 "Order Processor Good Example"
{
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
    begin
        // Guard clauses - fail fast with clear error messages
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            Error('Customer %1 not found', SalesHeader."Sell-to Customer No.");
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked and cannot place orders', Customer."No.");
            
        if Customer."Credit Limit" < GetOrderTotal(SalesHeader) then
            Error('Order total %1 exceeds customer credit limit %2', 
                GetOrderTotal(SalesHeader), Customer."Credit Limit");
                
        if SalesHeader."Payment Terms Code" = '' then
            Error('Payment terms are required for order %1', SalesHeader."No.");
            
        if SalesHeader."Shipment Method Code" = '' then
            Error('Shipment method is required for order %1', SalesHeader."No.");
        
        // Validate all order lines before processing
        ValidateOrderLines(SalesHeader);
        
        // Happy path - main business logic at normal indentation
        ProcessOrderLines(SalesHeader);
        ReserveInventory(SalesHeader);
        PostSalesOrder(SalesHeader);
    end;
    
    local procedure ValidateOrderLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        
        if not SalesLine.FindSet() then
            Error('Order %1 has no lines to process', SalesHeader."No.");
        
        repeat
            // Guard clauses for each line validation
            if not Item.Get(SalesLine."No.") then
                Error('Item %1 on line %2 does not exist', SalesLine."No.", SalesLine."Line No.");
                
            if Item.Inventory < SalesLine.Quantity then
                Error('Insufficient inventory for item %1. Available: %2, Required: %3', 
                    SalesLine."No.", Item.Inventory, SalesLine.Quantity);
                    
            if SalesLine.Quantity <= 0 then
                Error('Line %1 has invalid quantity %2', SalesLine."Line No.", SalesLine.Quantity);
                
        until SalesLine.Next() = 0;
    end;
    
    local procedure ProcessOrderLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LineProcessor: Codeunit "Sales Line Processor";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        
        SalesLine.FindSet();
        repeat
            LineProcessor.ProcessLine(SalesLine);
        until SalesLine.Next() = 0;
    end;
    
    local procedure ReserveInventory(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ReservationManager: Codeunit "Reservation Manager";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        
        SalesLine.FindSet();
        repeat
            ReservationManager.ReserveSalesLine(SalesLine);
        until SalesLine.Next() = 0;
    end;
    
    local procedure GetOrderTotal(SalesHeader: Record "Sales Header"): Decimal
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        exit(SalesHeader."Amount Including VAT");
    end;
}
```

## Boolean Logic Simplification

### ❌ Problem: Complex boolean expressions are hard to understand

```al
// Don't do this - complex nested boolean logic
procedure ComplexValidation(Customer: Record Customer; Order: Record "Sales Header"): Boolean
begin
    if not ((Customer.Blocked = Customer.Blocked::" ") and 
           (Customer."Credit Limit" > 0) and 
           ((Customer."Payment Method Code" <> '') or (Customer."Payment Terms Code" <> '')) and
           not ((Order."Document Date" < Today) and (Order."Shipment Date" < Today))) then
        exit(false);
        
    exit(true);
end;
```

### ✅ Solution: Extract boolean logic to meaningful methods

```al
// ✅ Extract complex conditions into meaningful method names
procedure ValidateOrderEligibility(Customer: Record Customer; Order: Record "Sales Header"): Boolean
begin
    if not IsCustomerEligible(Customer) then
        exit(false);
        
    if not HasValidPaymentSetup(Customer) then
        exit(false);
        
    if not HasValidOrderDates(Order) then
        exit(false);
        
    exit(true);
end;

local procedure IsCustomerEligible(Customer: Record Customer): Boolean
begin
    exit((Customer.Blocked = Customer.Blocked::" ") and (Customer."Credit Limit" > 0));
end;

local procedure HasValidPaymentSetup(Customer: Record Customer): Boolean
begin
    exit((Customer."Payment Method Code" <> '') or (Customer."Payment Terms Code" <> ''));
end;

local procedure HasValidOrderDates(Order: Record "Sales Header"): Boolean
begin
    exit(not ((Order."Document Date" < Today) and (Order."Shipment Date" < Today)));
end;
```

## Related Topics
- [Code Structure Anti-Patterns](code-structure-anti-patterns.md)
- [Object Design Anti-Patterns](object-design-anti-patterns.md)
- [Performance Anti-Patterns](performance-anti-patterns.md)
