---
title: "Open-Closed Principle in AL - Code Samples"
description: "Complete code examples demonstrating Open-Closed Principle implementation in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Interface", "Enum"]
variable_types: ["Record", ]
tags: ["solid-principles", "ocp", "open-closed", "events", "extensibility", "samples"]
---

# Open-Closed Principle in AL - Code Samples

## Sales Order Processing with Events

```al
codeunit 50100 "Sales Order Processing"
{
    /// <summary>
    /// Base sales order processing with extension points
    /// Closed for modification, open for extension
    /// </summary>
    
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        ValidateOrderData(SalesHeader);
        
        OnBeforeProcessOrder(SalesHeader); // Extension point for validation
        
        if not ProcessOrderInternal(SalesHeader) then
            exit;
            
        OnAfterProcessOrder(SalesHeader); // Extension point for additional processing
    end;
    
    local procedure ProcessOrderInternal(var SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        // Core processing logic - protected from modification
        CreateOrderEntries(SalesHeader);
        
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                ProcessOrderLine(SalesLine);
            until SalesLine.Next() = 0;
            
        UpdateOrderStatus(SalesHeader);
        exit(true);
    end;
    
    local procedure ValidateOrderData(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.TestField("Sell-to Customer No.");
        SalesHeader.TestField("Document Date");
    end;
    
    local procedure CreateOrderEntries(var SalesHeader: Record "Sales Header")
    begin
        // Create necessary ledger entries
    end;
    
    local procedure ProcessOrderLine(var SalesLine: Record "Sales Line")
    begin
        // Process individual order line
    end;
    
    local procedure UpdateOrderStatus(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify();
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

## Extension: Custom Order Processing

```al
codeunit 50101 "Custom Order Processing"
{
    /// <summary>
    /// Extends sales order processing without modifying original code
    /// Demonstrates Open-Closed Principle compliance
    /// </summary>
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Processing", 'OnBeforeProcessOrder', '', false, false)]
    local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        // Add custom validation logic
        ValidateCustomBusinessRules(SalesHeader);
        CheckCreditLimit(SalesHeader);
        ValidateSpecialPricing(SalesHeader);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Processing", 'OnAfterProcessOrder', '', false, false)]
    local procedure OnAfterProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        // Add custom post-processing logic
        SendCustomerNotification(SalesHeader);
        UpdateCRMSystem(SalesHeader);
        CreateCustomAnalyticsEntry(SalesHeader);
    end;
    
    local procedure ValidateCustomBusinessRules(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;
            
        // Custom validation: VIP customers only on weekdays
        if Customer."ABC Customer Category" = Customer."ABC Customer Category"::Premium then
            if Date2DWY(SalesHeader."Document Date", 1) in [6, 7] then // Saturday, Sunday
                Error('Premium customers can only place orders on weekdays');
    end;
    
    local procedure CheckCreditLimit(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OutstandingAmount: Decimal;
        OrderAmount: Decimal;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;
            
        // Calculate outstanding amount
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.CalcSums("Remaining Amt. (LCY)");
        OutstandingAmount := CustLedgerEntry."Remaining Amt. (LCY)";
        
        // Calculate order amount
        SalesHeader.CalcFields("Amount Including VAT");
        OrderAmount := SalesHeader."Amount Including VAT";
        
        // Check credit limit
        if (OutstandingAmount + OrderAmount) > Customer."Credit Limit (LCY)" then
            Error('Order would exceed customer credit limit. Current outstanding: %1, Order amount: %2, Credit limit: %3',
                OutstandingAmount, OrderAmount, Customer."Credit Limit (LCY)");
    end;
    
    local procedure ValidateSpecialPricing(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        SpecialPriceRequired: Boolean;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        
        if SalesLine.FindSet() then
            repeat
                if Item.Get(SalesLine."No.") then
                    if Item."Item Category Code" = 'PREMIUM' then
                        if SalesLine."Line Discount %" > 10 then begin
                            SpecialPriceRequired := true;
                            break;
                        end;
            until SalesLine.Next() = 0;
            
        if SpecialPriceRequired then
            if not ConfirmSpecialPricing() then
                Error('Special pricing approval required for premium items with discount > 10%');
    end;
    
    local procedure SendCustomerNotification(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        EmailMessage: Text;
    begin
        if Customer.Get(SalesHeader."Sell-to Customer No.") then
            if Customer."E-Mail" <> '' then begin
                EmailMessage := BuildOrderConfirmationEmail(SalesHeader);
                SendEmailNotification(Customer."E-Mail", 'Order Confirmation', EmailMessage);
            end;
    end;
    
    local procedure UpdateCRMSystem(var SalesHeader: Record "Sales Header")
    begin
        // Integration with external CRM system
        // This demonstrates extending functionality without modifying core processing
    end;
    
    local procedure CreateCustomAnalyticsEntry(var SalesHeader: Record "Sales Header")
    var
        AnalyticsEntry: Record "Custom Analytics Entry";
    begin
        AnalyticsEntry.Init();
        AnalyticsEntry."Entry No." := GetNextAnalyticsEntryNo();
        AnalyticsEntry."Document Type" := AnalyticsEntry."Document Type"::"Sales Order";
        AnalyticsEntry."Document No." := SalesHeader."No.";
        AnalyticsEntry."Customer No." := SalesHeader."Sell-to Customer No.";
        AnalyticsEntry."Processing Date" := Today;
        SalesHeader.CalcFields("Amount Including VAT");
        AnalyticsEntry."Amount (LCY)" := SalesHeader."Amount Including VAT";
        AnalyticsEntry.Insert();
    end;
    
    local procedure ConfirmSpecialPricing(): Boolean
    begin
        exit(Confirm('This order contains premium items with high discounts. Approve special pricing?'));
    end;
    
    local procedure BuildOrderConfirmationEmail(SalesHeader: Record "Sales Header"): Text
    var
        EmailBuilder: TextBuilder;
    begin
        EmailBuilder.AppendLine('Dear Customer,');
        EmailBuilder.AppendLine('');
        EmailBuilder.AppendLine(StrSubstNo('Your order %1 has been processed successfully.', SalesHeader."No."));
        EmailBuilder.AppendLine(StrSubstNo('Order Date: %1', SalesHeader."Document Date"));
        SalesHeader.CalcFields("Amount Including VAT");
        EmailBuilder.AppendLine(StrSubstNo('Total Amount: %1', SalesHeader."Amount Including VAT"));
        EmailBuilder.AppendLine('');
        EmailBuilder.AppendLine('Thank you for your business!');
        
        exit(EmailBuilder.ToText());
    end;
    
    local procedure SendEmailNotification(ToEmail: Text; Subject: Text; Body: Text)
    begin
        // Implementation would use email functionality
        // This is a placeholder for actual email sending
    end;
    
    local procedure GetNextAnalyticsEntryNo(): Integer
    var
        AnalyticsEntry: Record "Custom Analytics Entry";
    begin
        AnalyticsEntry.LockTable();
        if AnalyticsEntry.FindLast() then
            exit(AnalyticsEntry."Entry No." + 1);
        exit(1);
    end;
}
```

## Interface-Based Extensibility

```al
interface "IOrder Validator"
{
    /// <summary>
    /// Interface for order validation - enables multiple implementations
    /// </summary>
    procedure ValidateOrder(var SalesHeader: Record "Sales Header"): Boolean;
    procedure GetValidationErrors(): List of [Text];
}

interface "IOrder Processor"
{
    /// <summary>
    /// Interface for order processing - allows different processing strategies
    /// </summary>
    procedure ProcessOrder(var SalesHeader: Record "Sales Header"): Boolean;
    procedure CanProcessOrder(var SalesHeader: Record "Sales Header"): Boolean;
}

interface "INotification Sender"
{
    /// <summary>
    /// Interface for notifications - supports different notification methods
    /// </summary>
    procedure SendOrderConfirmation(var SalesHeader: Record "Sales Header"): Boolean;
    procedure SendOrderStatusUpdate(var SalesHeader: Record "Sales Header"; NewStatus: Text): Boolean;
}
```

## Configurable Order Management

```al
codeunit 50102 "Configurable Order Manager"
{
    /// <summary>
    /// Demonstrates OCP through configurable behavior
    /// Open for extension through different implementations
    /// </summary>
    
    var
        OrderValidator: Interface "IOrder Validator";
        OrderProcessor: Interface "IOrder Processor";
        NotificationSender: Interface "INotification Sender";
    
    procedure SetOrderValidator(NewValidator: Interface "IOrder Validator")
    begin
        OrderValidator := NewValidator;
    end;
    
    procedure SetOrderProcessor(NewProcessor: Interface "IOrder Processor")
    begin
        OrderProcessor := NewProcessor;
    end;
    
    procedure SetNotificationSender(NewSender: Interface "INotification Sender")
    begin
        NotificationSender := NewSender;
    end;
    
    procedure ProcessOrderWithStrategy(var SalesHeader: Record "Sales Header"): Boolean
    begin
        // Validate order using configured validator
        if not OrderValidator.ValidateOrder(SalesHeader) then begin
            LogValidationErrors(OrderValidator.GetValidationErrors());
            exit(false);
        end;
        
        // Check if processor can handle this order
        if not OrderProcessor.CanProcessOrder(SalesHeader) then begin
            Error('Current processor cannot handle this order type');
            exit(false);
        end;
        
        // Process order using configured processor
        if not OrderProcessor.ProcessOrder(SalesHeader) then
            exit(false);
        
        // Send notification using configured sender
        NotificationSender.SendOrderConfirmation(SalesHeader);
        
        exit(true);
    end;
    
    local procedure LogValidationErrors(ValidationErrors: List of [Text])
    var
        ErrorText: Text;
    begin
        foreach ErrorText in ValidationErrors do
            Message('Validation Error: %1', ErrorText);
    end;
}
```

## Multiple Validator Implementations

```al
codeunit 50103 "Basic Order Validator" implements "IOrder Validator"
{
    /// <summary>
    /// Basic implementation of order validation
    /// Can be replaced without modifying calling code
    /// </summary>
    
    var
        ValidationErrors: List of [Text];
    
    procedure ValidateOrder(var SalesHeader: Record "Sales Header"): Boolean
    var
        IsValid: Boolean;
    begin
        Clear(ValidationErrors);
        IsValid := true;
        
        // Basic validations
        if SalesHeader."Sell-to Customer No." = '' then begin
            ValidationErrors.Add('Customer number is required');
            IsValid := false;
        end;
        
        if SalesHeader."Document Date" = 0D then begin
            ValidationErrors.Add('Document date is required');
            IsValid := false;
        end;
        
        exit(IsValid);
    end;
    
    procedure GetValidationErrors(): List of [Text]
    begin
        exit(ValidationErrors);
    end;
}

codeunit 50104 "Advanced Order Validator" implements "IOrder Validator"
{
    /// <summary>
    /// Advanced implementation with additional business rules
    /// Extends validation without changing the interface
    /// </summary>
    
    var
        ValidationErrors: List of [Text];
    
    procedure ValidateOrder(var SalesHeader: Record "Sales Header"): Boolean
    var
        IsValid: Boolean;
    begin
        Clear(ValidationErrors);
        IsValid := true;
        
        // Include basic validations
        if not ValidateBasicFields(SalesHeader) then
            IsValid := false;
        
        // Advanced validations
        if not ValidateCustomerCredit(SalesHeader) then
            IsValid := false;
            
        if not ValidateOrderLimits(SalesHeader) then
            IsValid := false;
        
        if not ValidateBusinessHours(SalesHeader) then
            IsValid := false;
        
        exit(IsValid);
    end;
    
    procedure GetValidationErrors(): List of [Text]
    begin
        exit(ValidationErrors);
    end;
    
    local procedure ValidateBasicFields(var SalesHeader: Record "Sales Header"): Boolean
    var
        IsValid: Boolean;
    begin
        IsValid := true;
        
        if SalesHeader."Sell-to Customer No." = '' then begin
            ValidationErrors.Add('Customer number is required');
            IsValid := false;
        end;
        
        if SalesHeader."Document Date" = 0D then begin
            ValidationErrors.Add('Document date is required');
            IsValid := false;
        end;
        
        exit(IsValid);
    end;
    
    local procedure ValidateCustomerCredit(var SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OutstandingAmount: Decimal;
        OrderAmount: Decimal;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit(true);
            
        // Calculate outstanding amount
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.CalcSums("Remaining Amt. (LCY)");
        OutstandingAmount := CustLedgerEntry."Remaining Amt. (LCY)";
        
        // Calculate order amount
        SalesHeader.CalcFields("Amount Including VAT");
        OrderAmount := SalesHeader."Amount Including VAT";
        
        // Check credit limit
        if (OutstandingAmount + OrderAmount) > Customer."Credit Limit (LCY)" then begin
            ValidationErrors.Add(StrSubstNo('Order exceeds credit limit. Outstanding: %1, Order: %2, Limit: %3',
                OutstandingAmount, OrderAmount, Customer."Credit Limit (LCY)"));
            exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure ValidateOrderLimits(var SalesHeader: Record "Sales Header"): Boolean
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        
        // Example business rule: Orders over 50,000 require special approval
        if SalesHeader."Amount Including VAT" > 50000 then begin
            ValidationErrors.Add('Orders over 50,000 require special approval');
            exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure ValidateBusinessHours(var SalesHeader: Record "Sales Header"): Boolean
    var
        CurrentHour: Integer;
    begin
        // Example: Orders can only be placed during business hours
        CurrentHour := Time2Hour(Time);
        
        if (CurrentHour < 8) or (CurrentHour > 17) then begin
            ValidationErrors.Add('Orders can only be placed during business hours (8 AM - 5 PM)');
            exit(false);
        end;
        
        exit(true);
    end;
}
```

## Order Processing Factory

```al
codeunit 50105 "Order Processing Factory"
{
    /// <summary>
    /// Factory for creating order processing strategies
    /// Enables adding new processors without modifying existing code
    /// </summary>
    
    procedure CreateOrderValidator(ValidatorType: Enum "Order Validator Type"): Interface "IOrder Validator"
    var
        BasicValidator: Codeunit "Basic Order Validator";
        AdvancedValidator: Codeunit "Advanced Order Validator";
    begin
        case ValidatorType of
            ValidatorType::Basic:
                exit(BasicValidator);
            ValidatorType::Advanced:
                exit(AdvancedValidator);
            else
                exit(BasicValidator); // Default
        end;
    end;
    
    procedure CreateOrderProcessor(ProcessorType: Enum "Order Processor Type"): Interface "IOrder Processor"
    var
        StandardProcessor: Codeunit "Standard Order Processor";
        ExpressProcessor: Codeunit "Express Order Processor";
        BulkProcessor: Codeunit "Bulk Order Processor";
    begin
        case ProcessorType of
            ProcessorType::Standard:
                exit(StandardProcessor);
            ProcessorType::Express:
                exit(ExpressProcessor);
            ProcessorType::Bulk:
                exit(BulkProcessor);
            else
                exit(StandardProcessor); // Default
        end;
    end;
    
    procedure CreateNotificationSender(SenderType: Enum "Notification Sender Type"): Interface "INotification Sender"
    var
        EmailSender: Codeunit "Email Notification Sender";
        SMSSender: Codeunit "SMS Notification Sender";
        IntegratedSender: Codeunit "Integrated Notification Sender";
    begin
        case SenderType of
            SenderType::Email:
                exit(EmailSender);
            SenderType::SMS:
                exit(SMSSender);
            SenderType::Integrated:
                exit(IntegratedSender);
            else
                exit(EmailSender); // Default
        end;
    end;
}
```

## Configuration and Usage Example

```al
codeunit 50106 "Order Processing Setup"
{
    /// <summary>
    /// Configuration codeunit demonstrating OCP in practice
    /// New processing strategies can be added without modifying this code
    /// </summary>
    
    procedure SetupOrderProcessing(): Codeunit "Configurable Order Manager"
    var
        OrderManager: Codeunit "Configurable Order Manager";
        Factory: Codeunit "Order Processing Factory";
        Setup: Record "Order Processing Setup";
    begin
        // Get configuration from setup
        Setup.Get();
        
        // Configure with interfaces - open for extension, closed for modification
        OrderManager.SetOrderValidator(Factory.CreateOrderValidator(Setup."Validator Type"));
        OrderManager.SetOrderProcessor(Factory.CreateOrderProcessor(Setup."Processor Type"));
        OrderManager.SetNotificationSender(Factory.CreateNotificationSender(Setup."Notification Type"));
        
        exit(OrderManager);
    end;
    
    procedure ProcessOrderWithConfiguration(var SalesHeader: Record "Sales Header"): Boolean
    var
        OrderManager: Codeunit "Configurable Order Manager";
    begin
        OrderManager := SetupOrderProcessing();
        exit(OrderManager.ProcessOrderWithStrategy(SalesHeader));
    end;
}
```

## Related Topics
- [Open-Closed Principle](open-closed-principle.md)
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Dependency Inversion Principle](dependency-inversion-principle.md)
