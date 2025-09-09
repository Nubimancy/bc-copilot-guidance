---
title: "Error Prevention Strategies - Code Samples"
description: "Complete code examples demonstrating proactive error prevention patterns in AL"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "prevention", "samples", "validation"]
---

# Error Prevention Strategies - Code Samples

## Input Validation Patterns

### Parameter Validation Framework

```al
codeunit 50200 "Parameter Validator"
{
    procedure ValidateCustomerNo(CustomerNo: Code[20]; Context: Text)
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            Error('Customer number is required for %1', Context);
            
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 does not exist and cannot be used for %2', CustomerNo, Context);
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked (%2) and cannot be used for %3', 
                  CustomerNo, Customer.Blocked, Context);
    end;
    
    procedure ValidateItemNo(ItemNo: Code[20]; Context: Text)
    var
        Item: Record Item;
    begin
        if ItemNo = '' then
            Error('Item number is required for %1', Context);
            
        if not Item.Get(ItemNo) then
            Error('Item %1 does not exist and cannot be used for %2', ItemNo, Context);
            
        if Item.Blocked then
            Error('Item %1 is blocked and cannot be used for %2', ItemNo, Context);
            
        if Item.Type = Item.Type::Service then
            if not IsValidServiceItem(Item, Context) then
                Error('Service item %1 is not properly configured for %2', ItemNo, Context);
    end;
    
    procedure ValidateQuantity(Quantity: Decimal; Context: Text; MinValue: Decimal; MaxValue: Decimal)
    begin
        if Quantity <= MinValue then
            Error('Quantity must be greater than %1 for %2. Current value: %3', 
                  MinValue, Context, Quantity);
                  
        if Quantity > MaxValue then
            Error('Quantity cannot exceed %1 for %2. Current value: %3', 
                  MaxValue, Context, Quantity);
    end;
    
    procedure ValidateAmount(Amount: Decimal; Context: Text)
    begin
        if Amount < 0 then
            Error('Amount cannot be negative for %1. Current value: %2', Context, Amount);
            
        if Amount > 999999999 then
            Error('Amount is too large for %1. Maximum allowed: 999,999,999', Context);
    end;
    
    procedure ValidateEmail(Email: Text; Context: Text)
    var
        EmailRegex: Text;
    begin
        if Email = '' then
            Error('Email address is required for %1', Context);
            
        EmailRegex := '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
        if not Email.Match(EmailRegex) then
            Error('Invalid email format "%1" for %2. Please enter a valid email address.', 
                  Email, Context);
    end;
}
```

### Business Rule Validation

```al
codeunit 50201 "Business Rule Validator"
{
    procedure ValidateCustomerForSales(Customer: Record Customer; OrderAmount: Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OutstandingAmount: Decimal;
        AvailableCredit: Decimal;
    begin
        // Check customer is not blocked
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 (%2) is blocked for %3 and cannot be used for sales orders', 
                  Customer."No.", Customer.Name, Customer.Blocked);
        
        // Check credit limit if applicable
        if Customer."Credit Limit (LCY)" > 0 then begin
            CustLedgerEntry.SetRange("Customer No.", Customer."No.");
            CustLedgerEntry.SetRange(Open, true);
            CustLedgerEntry.CalcSums("Amount (LCY)");
            OutstandingAmount := Abs(CustLedgerEntry."Amount (LCY)");
            
            AvailableCredit := Customer."Credit Limit (LCY)" - OutstandingAmount;
            
            if OrderAmount > AvailableCredit then
                Error('Order amount %1 exceeds available credit %2 for customer %3 (%4). ' +
                      'Outstanding amount: %5, Credit limit: %6',
                      OrderAmount, AvailableCredit, Customer."No.", Customer.Name,
                      OutstandingAmount, Customer."Credit Limit (LCY)");
        end;
        
        // Check payment terms are configured
        if Customer."Payment Terms Code" = '' then
            Error('Payment terms are not configured for customer %1 (%2). ' +
                  'Please set payment terms before creating sales orders.',
                  Customer."No.", Customer.Name);
    end;
    
    procedure ValidateItemForSales(Item: Record Item; Quantity: Decimal; CustomerNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        AvailableInventory: Decimal;
    begin
        // Check item is not blocked
        if Item.Blocked then
            Error('Item %1 (%2) is blocked and cannot be sold', Item."No.", Item.Description);
            
        // Check item type allows sales
        if Item.Type = Item.Type::"Non-Inventory" then
            if not Item."Allow Online Adjustment" then
                Error('Non-inventory item %1 (%2) is not configured for sales transactions',
                      Item."No.", Item.Description);
        
        // Check inventory availability for inventory items
        if Item.Type = Item.Type::Inventory then begin
            ItemLedgerEntry.SetRange("Item No.", Item."No.");
            ItemLedgerEntry.CalcSums(Quantity);
            AvailableInventory := ItemLedgerEntry.Quantity;
            
            if Quantity > AvailableInventory then
                Error('Requested quantity %1 exceeds available inventory %2 for item %3 (%4)',
                      Quantity, AvailableInventory, Item."No.", Item.Description);
        end;
        
        // Check if item requires special handling for this customer
        ValidateItemCustomerRestrictions(Item, CustomerNo);
    end;
    
    local procedure ValidateItemCustomerRestrictions(Item: Record Item; CustomerNo: Code[20])
    var
        Customer: Record Customer;
        ItemCustomerRestriction: Record "Item Customer Restriction"; // Hypothetical table
    begin
        Customer.Get(CustomerNo);
        
        // Example: Check if customer has restrictions for this item category
        if ItemCustomerRestriction.Get(Item."No.", CustomerNo) then
            if ItemCustomerRestriction.Blocked then
                Error('Item %1 (%2) is restricted for customer %3 (%4) due to: %5',
                      Item."No.", Item.Description, Customer."No.", Customer.Name,
                      ItemCustomerRestriction."Restriction Reason");
    end;
}
```

## TryFunction Patterns

### Safe Processing Framework

```al
codeunit 50202 "Safe Processing Framework"
{
    [TryFunction]
    procedure TryProcessSalesOrder(var SalesHeader: Record "Sales Header")
    begin
        ValidateOrderHeader(SalesHeader);
        ValidateOrderLines(SalesHeader);
        ValidateBusinessRules(SalesHeader);
        ProcessOrderLogic(SalesHeader);
    end;
    
    [TryFunction]
    procedure TryValidateCustomerData(Customer: Record Customer)
    begin
        ValidateCustomerMandatoryFields(Customer);
        ValidateCustomerBusinessRules(Customer);
        ValidateCustomerDependencies(Customer);
    end;
    
    [TryFunction]
    procedure TryConnectToExternalService(ServiceUrl: Text; var Response: Text)
    var
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
    begin
        if ServiceUrl = '' then
            Error('Service URL cannot be empty');
            
        if not HttpClient.Get(ServiceUrl, HttpResponse) then
            Error('Failed to connect to service: %1', ServiceUrl);
            
        if not HttpResponse.IsSuccessStatusCode then
            Error('Service returned error status: %1', HttpResponse.HttpStatusCode);
            
        HttpResponse.Content.ReadAs(Response);
    end;
    
    procedure SafeProcessSalesOrder(var SalesHeader: Record "Sales Header"): Boolean
    var
        ProcessingError: Text;
    begin
        ClearLastError();
        
        if TryProcessSalesOrder(SalesHeader) then
            exit(true);
            
        ProcessingError := GetLastErrorText();
        LogProcessingError('Sales Order Processing', SalesHeader."No.", ProcessingError);
        HandleProcessingError(SalesHeader, ProcessingError);
        
        exit(false);
    end;
    
    procedure SafeValidateCustomer(Customer: Record Customer): Boolean
    var
        ValidationError: Text;
        ValidationErrorInfo: ErrorInfo;
    begin
        ClearLastError();
        
        if TryValidateCustomerData(Customer) then
            exit(true);
            
        ValidationError := GetLastErrorText();
        
        // Convert basic error to ErrorInfo for better user experience
        ValidationErrorInfo.Message := StrSubstNo('Customer validation failed for %1', Customer."No.");
        ValidationErrorInfo.DetailedMessage := ValidationError;
        ValidationErrorInfo.AddAction('Open Customer Card', Codeunit::"Customer Management", 'OpenCustomerCard');
        ValidationErrorInfo.AddAction('Validate Required Fields', Codeunit::"Customer Management", 'ValidateRequiredFields');
        
        Error(ValidationErrorInfo);
    end;
    
    local procedure LogProcessingError(ProcessType: Text; DocumentNo: Code[20]; ErrorMessage: Text)
    begin
        Session.LogMessage('ProcessingError', 
                          StrSubstNo('%1 failed for %2: %3', ProcessType, DocumentNo, ErrorMessage),
                          Verbosity::Error, 
                          DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher);
    end;
}
```

## Collectible Error Pattern

### Comprehensive Validation Framework

```al
codeunit 50203 "Comprehensive Validator"
{
    procedure ValidateCompleteOrder(var SalesHeader: Record "Sales Header")
    var
        ValidationErrors: List of [Text];
        ErrorSummary: ErrorInfo;
    begin
        // Collect all validation errors instead of stopping at first
        CollectHeaderValidationErrors(SalesHeader, ValidationErrors);
        CollectLineValidationErrors(SalesHeader, ValidationErrors);
        CollectBusinessRuleErrors(SalesHeader, ValidationErrors);
        CollectSystemConfigurationErrors(ValidationErrors);
        
        if ValidationErrors.Count > 0 then begin
            ErrorSummary.Message := StrSubstNo('%1 validation issues found for order %2', 
                                              ValidationErrors.Count, SalesHeader."No.");
            ErrorSummary.DetailedMessage := BuildErrorSummary(ValidationErrors);
            
            // Add contextual actions
            ErrorSummary.AddAction('Fix Order Issues', Codeunit::"Order Fix Management", 'FixOrderIssues');
            ErrorSummary.AddAction('Open Order', Codeunit::"Order Management", 'OpenOrder');
            ErrorSummary.AddAction('Validate Step by Step', Codeunit::"Order Management", 'ValidateStepByStep');
            
            Error(ErrorSummary);
        end;
    end;
    
    local procedure CollectHeaderValidationErrors(SalesHeader: Record "Sales Header"; var ValidationErrors: List of [Text])
    var
        Customer: Record Customer;
        ErrorMsg: Text;
    begin
        // Customer validation
        if SalesHeader."Sell-to Customer No." = '' then
            ValidationErrors.Add('Customer number is required');
        else begin
            if not Customer.Get(SalesHeader."Sell-to Customer No.") then
                ValidationErrors.Add(StrSubstNo('Customer %1 does not exist', SalesHeader."Sell-to Customer No."))
            else begin
                if Customer.Blocked <> Customer.Blocked::" " then
                    ValidationErrors.Add(StrSubstNo('Customer %1 is blocked (%2)', Customer."No.", Customer.Blocked));
                    
                if Customer."Payment Terms Code" = '' then
                    ValidationErrors.Add(StrSubstNo('Customer %1 has no payment terms configured', Customer."No."));
            end;
        end;
        
        // Document date validation
        if SalesHeader."Document Date" = 0D then
            ValidationErrors.Add('Document date is required');
        else if SalesHeader."Document Date" > Today then
            ValidationErrors.Add('Document date cannot be in the future');
            
        // Posting date validation
        if SalesHeader."Posting Date" = 0D then
            ValidationErrors.Add('Posting date is required');
    end;
    
    local procedure CollectLineValidationErrors(SalesHeader: Record "Sales Header"; var ValidationErrors: List of [Text])
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        
        if not SalesLine.FindSet() then begin
            ValidationErrors.Add('Order has no lines');
            exit;
        end;
        
        repeat
            LineNo += 1;
            
            // Item validation
            if SalesLine.Type = SalesLine.Type::Item then begin
                if SalesLine."No." = '' then
                    ValidationErrors.Add(StrSubstNo('Line %1: Item number is required', LineNo))
                else begin
                    if not Item.Get(SalesLine."No.") then
                        ValidationErrors.Add(StrSubstNo('Line %1: Item %2 does not exist', LineNo, SalesLine."No."))
                    else begin
                        if Item.Blocked then
                            ValidationErrors.Add(StrSubstNo('Line %1: Item %2 is blocked', LineNo, SalesLine."No."));
                    end;
                end;
            end;
            
            // Quantity validation
            if SalesLine.Quantity <= 0 then
                ValidationErrors.Add(StrSubstNo('Line %1: Quantity must be positive', LineNo));
                
            // Unit price validation
            if SalesLine."Unit Price" < 0 then
                ValidationErrors.Add(StrSubstNo('Line %1: Unit price cannot be negative', LineNo));
                
        until SalesLine.Next() = 0;
    end;
    
    local procedure CollectBusinessRuleErrors(SalesHeader: Record "Sales Header"; var ValidationErrors: List of [Text])
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OutstandingAmount: Decimal;
        OrderTotal: Decimal;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit; // Already validated in header validation
            
        // Credit limit validation
        if Customer."Credit Limit (LCY)" > 0 then begin
            CustLedgerEntry.SetRange("Customer No.", Customer."No.");
            CustLedgerEntry.SetRange(Open, true);
            CustLedgerEntry.CalcSums("Amount (LCY)");
            OutstandingAmount := Abs(CustLedgerEntry."Amount (LCY)");
            
            SalesHeader.CalcFields("Amount Including VAT");
            OrderTotal := SalesHeader."Amount Including VAT";
            
            if (OutstandingAmount + OrderTotal) > Customer."Credit Limit (LCY)" then
                ValidationErrors.Add(StrSubstNo('Order total %1 plus outstanding amount %2 exceeds credit limit %3',
                                              OrderTotal, OutstandingAmount, Customer."Credit Limit (LCY)"));
        end;
        
        // Shipping method validation
        if SalesHeader."Shipment Method Code" = '' then
            ValidationErrors.Add('Shipping method is required');
    end;
    
    local procedure CollectSystemConfigurationErrors(var ValidationErrors: List of [Text])
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Record "No. Series";
    begin
        // Check sales setup
        if not SalesSetup.Get() then begin
            ValidationErrors.Add('Sales & Receivables Setup is not configured');
            exit;
        end;
        
        // Check number series
        if SalesSetup."Order Nos." = '' then
            ValidationErrors.Add('Order number series is not configured in Sales Setup');
        else begin
            if not NoSeries.Get(SalesSetup."Order Nos.") then
                ValidationErrors.Add(StrSubstNo('Order number series %1 does not exist', SalesSetup."Order Nos."));
        end;
    end;
    
    local procedure BuildErrorSummary(ValidationErrors: List of [Text]): Text
    var
        ErrorSummary: TextBuilder;
        ErrorText: Text;
        ErrorCount: Integer;
    begin
        ErrorSummary.AppendLine('The following validation issues were found:');
        ErrorSummary.AppendLine('');
        
        foreach ErrorText in ValidationErrors do begin
            ErrorCount += 1;
            ErrorSummary.AppendLine(StrSubstNo('%1. %2', ErrorCount, ErrorText));
        end;
        
        ErrorSummary.AppendLine('');
        ErrorSummary.AppendLine('Please resolve these issues before proceeding.');
        
        exit(ErrorSummary.ToText());
    end;
}
```

## Defensive Programming Examples

### Null-Safe Operations

```al
codeunit 50204 "Null-Safe Operations"
{
    procedure SafeGetCustomerName(CustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            exit('[No Customer]');
            
        if not Customer.Get(CustomerNo) then
            exit(StrSubstNo('[Customer %1 Not Found]', CustomerNo));
            
        if Customer.Name = '' then
            exit(StrSubstNo('[Customer %1 - No Name]', CustomerNo));
            
        exit(Customer.Name);
    end;
    
    procedure SafeCalculateDiscount(UnitPrice: Decimal; DiscountPct: Decimal): Decimal
    begin
        // Defensive validation
        if UnitPrice < 0 then
            UnitPrice := 0;
            
        if (DiscountPct < 0) or (DiscountPct > 100) then
            DiscountPct := 0;
            
        exit(UnitPrice * DiscountPct / 100);
    end;
    
    procedure SafeFormatAmount(Amount: Decimal; CurrencyCode: Code[10]): Text
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DecimalPlaces: Integer;
    begin
        // Handle empty currency code
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
            DecimalPlaces := GeneralLedgerSetup."Amount Decimal Places";
        end else begin
            if Currency.Get(CurrencyCode) then
                DecimalPlaces := Currency."Amount Decimal Places"
            else
                DecimalPlaces := 2; // Default to 2 decimal places
        end;
        
        // Format with proper decimal places
        exit(Format(Amount, 0, StrSubstNo('<Precision,%1><Standard Format,0>', DecimalPlaces)));
    end;
}
```

## Configuration Validation

### System Readiness Validation

```al
codeunit 50205 "System Configuration Validator"
{
    procedure ValidateCompleteSystemConfiguration()
    var
        ConfigErrors: List of [Text];
        ConfigErrorInfo: ErrorInfo;
    begin
        ValidateGeneralLedgerSetup(ConfigErrors);
        ValidateSalesSetup(ConfigErrors);
        ValidateInventorySetup(ConfigErrors);
        ValidateEmailConfiguration(ConfigErrors);
        ValidateNumberSeries(ConfigErrors);
        
        if ConfigErrors.Count > 0 then begin
            ConfigErrorInfo.Message := StrSubstNo('%1 configuration issues detected', ConfigErrors.Count);
            ConfigErrorInfo.DetailedMessage := BuildConfigurationErrorSummary(ConfigErrors);
            ConfigErrorInfo.AddAction('Open Setup Wizard', Codeunit::"Setup Management", 'RunSetupWizard');
            ConfigErrorInfo.AddAction('Review Configuration', Codeunit::"Setup Management", 'ReviewConfiguration');
            ConfigErrorInfo.AddAction('Contact Administrator', Codeunit::"Support Management", 'ContactAdmin');
            
            Error(ConfigErrorInfo);
        end;
    end;
    
    local procedure ValidateGeneralLedgerSetup(var ConfigErrors: List of [Text])
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.Get() then begin
            ConfigErrors.Add('General Ledger Setup is missing');
            exit;
        end;
        
        if GLSetup."LCY Code" = '' then
            ConfigErrors.Add('Local Currency Code is not configured');
            
        if GLSetup."Amount Decimal Places" = '' then
            ConfigErrors.Add('Amount Decimal Places are not configured');
    end;
    
    local procedure ValidateSalesSetup(var ConfigErrors: List of [Text])
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if not SalesSetup.Get() then begin
            ConfigErrors.Add('Sales & Receivables Setup is missing');
            exit;
        end;
        
        if SalesSetup."Order Nos." = '' then
            ConfigErrors.Add('Sales Order number series is not configured');
            
        if SalesSetup."Invoice Nos." = '' then
            ConfigErrors.Add('Sales Invoice number series is not configured');
            
        if SalesSetup."Posted Invoice Nos." = '' then
            ConfigErrors.Add('Posted Sales Invoice number series is not configured');
    end;
    
    local procedure ValidateEmailConfiguration(var ConfigErrors: List of [Text])
    var
        EmailAccount: Record "Email Account";
    begin
        if not EmailAccount.FindFirst() then
            ConfigErrors.Add('No email accounts are configured');
    end;
    
    local procedure BuildConfigurationErrorSummary(ConfigErrors: List of [Text]): Text
    var
        Summary: TextBuilder;
        ErrorText: Text;
        ErrorNum: Integer;
    begin
        Summary.AppendLine('System configuration issues:');
        Summary.AppendLine('');
        
        foreach ErrorText in ConfigErrors do begin
            ErrorNum += 1;
            Summary.AppendLine(StrSubstNo('%1. %2', ErrorNum, ErrorText));
        end;
        
        Summary.AppendLine('');
        Summary.AppendLine('Please resolve these configuration issues before using the system.');
        
        exit(Summary.ToText());
    end;
}
```

These comprehensive examples demonstrate how proactive error prevention creates more reliable, user-friendly AL applications by catching and handling issues before they become runtime errors.
