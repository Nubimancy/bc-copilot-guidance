---
title: "Test Library Design Patterns - Code Samples"
description: "Complete implementations demonstrating architectural patterns and best practices for creating maintainable, reusable test libraries"
area: "testing"
difficulty: "intermediate" 
object_types: ["Codeunit"]
variable_types: ["Record", "Interface", "Dictionary", "List", "Variant"]
tags: ["testing", "library-design", "architecture", "reusability", "test-framework", "samples"]
---

# Test Library Design Patterns - Code Samples

## Complete Factory Pattern Implementation

### Base Test Factory Interface and Implementation

```al
interface "ITestDataFactory"
{
    /// <summary>
    /// Creates a minimal test record with only required fields
    /// </summary>
    procedure CreateMinimal(): Variant;
    
    /// <summary>
    /// Creates a standard test record with common field values
    /// </summary>
    procedure CreateStandard(): Variant;
    
    /// <summary>
    /// Creates a complete test record with all fields populated
    /// </summary>
    procedure CreateComplete(): Variant;
    
    /// <summary>
    /// Creates a custom test record based on specifications
    /// </summary>
    procedure CreateCustom(Specifications: Dictionary of [Text, Variant]): Variant;
    
    /// <summary>
    /// Creates multiple test records at once
    /// </summary>
    procedure CreateBatch(Count: Integer; CreationType: Enum "Test Creation Type"): List of [Variant];
    
    /// <summary>
    /// Validates if creation specifications are valid
    /// </summary>
    procedure ValidateSpecifications(Specifications: Dictionary of [Text, Variant]): Boolean;
}

codeunit 50700 "Customer Test Factory" implements "ITestDataFactory"
{
    var
        CounterRegistry: Dictionary of [Text, Integer];
        DefaultValues: Dictionary of [Text, Variant];
        ValidationRules: Dictionary of [Text, Interface "IFieldValidator"];
        
    trigger OnRun()
    begin
        InitializeDefaults();
        InitializeValidators();
    end;
    
    procedure CreateMinimal(): Variant
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
    begin
        CustomerNo := GetNextCustomerNo();
        
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'XTest Customer ' + CopyStr(CustomerNo, 6); // Remove XCUST prefix for display
        Customer.Insert(true);
        
        exit(Customer);
    end;
    
    procedure CreateStandard(): Variant
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
        PostingGroups: Codeunit "Test Posting Groups Manager";
    begin
        CustomerNo := GetNextCustomerNo();
        
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'XTest Customer ' + CopyStr(CustomerNo, 6);
        Customer."Name 2" := 'XStandard Customer';
        Customer.Address := 'XTest Street ' + Format(Random(999));
        Customer.City := 'XTest City';
        Customer."Post Code" := 'X' + Format(Random(99999)).PadLeft(5, '0');
        Customer."Country/Region Code" := 'US';
        Customer."Phone No." := '+1-555-X' + Format(Random(999)).PadLeft(3, '0') + '-' + Format(Random(9999)).PadLeft(4, '0');
        Customer."E-Mail" := 'customer' + CopyStr(CustomerNo, 6) + '@test.example.com';
        Customer."Customer Posting Group" := PostingGroups.GetTestCustomerPostingGroup();
        Customer."Gen. Bus. Posting Group" := PostingGroups.GetTestGenBusPostingGroup();
        Customer."VAT Bus. Posting Group" := PostingGroups.GetTestVATBusPostingGroup();
        Customer."Payment Terms Code" := GetTestPaymentTermsCode();
        Customer."Payment Method Code" := GetTestPaymentMethodCode();
        Customer."Salesperson Code" := GetTestSalespersonCode();
        Customer.Insert(true);
        
        exit(Customer);
    end;
    
    procedure CreateComplete(): Variant
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
        PostingGroups: Codeunit "Test Posting Groups Manager";
        ContactManager: Codeunit "Test Contact Manager";
        Contact: Record Contact;
    begin
        CustomerNo := GetNextCustomerNo();
        
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'XTest Customer ' + CopyStr(CustomerNo, 6);
        Customer."Name 2" := 'XComplete Test Customer';
        Customer."Search Name" := UpperCase(Customer.Name);
        Customer.Address := 'XTest Street ' + Format(Random(999));
        Customer."Address 2" := 'XSuite ' + Format(Random(100));
        Customer.City := 'XTest City';
        Customer.County := 'XTest County';
        Customer."Post Code" := 'X' + Format(Random(99999)).PadLeft(5, '0');
        Customer."Country/Region Code" := 'US';
        Customer."Phone No." := '+1-555-X' + Format(Random(999)).PadLeft(3, '0') + '-' + Format(Random(9999)).PadLeft(4, '0');
        Customer."Mobile Phone No." := '+1-555-M' + Format(Random(999)).PadLeft(3, '0') + '-' + Format(Random(9999)).PadLeft(4, '0');
        Customer."Fax No." := '+1-555-F' + Format(Random(999)).PadLeft(3, '0') + '-' + Format(Random(9999)).PadLeft(4, '0');
        Customer."E-Mail" := 'customer' + CopyStr(CustomerNo, 6) + '@test.example.com';
        Customer."Home Page" := 'https://customer' + CopyStr(CustomerNo, 6) + '.test.example.com';
        Customer."Language Code" := 'ENU';
        Customer."Customer Posting Group" := PostingGroups.GetTestCustomerPostingGroup();
        Customer."Gen. Bus. Posting Group" := PostingGroups.GetTestGenBusPostingGroup();
        Customer."VAT Bus. Posting Group" := PostingGroups.GetTestVATBusPostingGroup();
        Customer."Customer Price Group" := GetTestPriceGroupCode();
        Customer."Customer Disc. Group" := GetTestDiscountGroupCode();
        Customer."Payment Terms Code" := GetTestPaymentTermsCode();
        Customer."Payment Method Code" := GetTestPaymentMethodCode();
        Customer."Shipment Method Code" := GetTestShipmentMethodCode();
        Customer."Salesperson Code" := GetTestSalespersonCode();
        Customer."Credit Limit (LCY)" := Random(100000) + 50000;
        Customer."Max. Invoice Discount %" := Random(10) + 5;
        Customer."Invoice Disc. Code" := Customer."No.";
        Customer."Customer Statistics Group" := 1;
        Customer."Currency Code" := ''; // LCY
        Customer."Last Date Modified" := Today;
        Customer.Insert(true);
        
        // Create related contact
        ContactManager.CreateCustomerContact(Customer, Contact);
        
        exit(Customer);
    end;
    
    procedure CreateCustom(Specifications: Dictionary of [Text, Variant]): Variant
    var
        Customer: Record Customer;
        FieldName: Text;
        FieldValue: Variant;
        CustomerNo: Code[20];
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if not ValidateSpecifications(Specifications) then
            Error('Invalid customer specifications provided');
            
        // Start with standard customer
        Customer := CreateStandard();
        
        // Apply custom specifications
        RecordRef.GetTable(Customer);
        
        foreach FieldName in Specifications.Keys do begin
            if FieldName = 'No.' then begin
                // Handle special case for customer number
                Specifications.Get(FieldName, FieldValue);
                CustomerNo := FieldValue;
                Customer.Rename(CustomerNo);
                RecordRef.GetTable(Customer);
            end else begin
                if TryGetFieldRef(RecordRef, FieldName, FieldRef) then begin
                    Specifications.Get(FieldName, FieldValue);
                    SetFieldValue(FieldRef, FieldValue);
                end;
            end;
        end;
        
        RecordRef.Modify(true);
        RecordRef.SetTable(Customer);
        
        exit(Customer);
    end;
    
    procedure CreateBatch(Count: Integer; CreationType: Enum "Test Creation Type"): List of [Variant]
    var
        Customers: List of [Variant];
        Customer: Variant;
        i: Integer;
    begin
        if Count <= 0 then
            Error('Batch count must be greater than zero');
            
        for i := 1 to Count do begin
            case CreationType of
                CreationType::Minimal:
                    Customer := CreateMinimal();
                CreationType::Standard:
                    Customer := CreateStandard();
                CreationType::Complete:
                    Customer := CreateComplete();
            end;
            
            Customers.Add(Customer);
            
            // Commit every 50 records to prevent long transactions
            if i mod 50 = 0 then
                Commit();
        end;
        
        exit(Customers);
    end;
    
    procedure ValidateSpecifications(Specifications: Dictionary of [Text, Variant]): Boolean
    var
        FieldName: Text;
        FieldValue: Variant;
        Validator: Interface "IFieldValidator";
    begin
        foreach FieldName in Specifications.Keys do begin
            if ValidationRules.Get(FieldName, Validator) then begin
                Specifications.Get(FieldName, FieldValue);
                if not Validator.Validate(FieldValue) then
                    exit(false);
            end;
        end;
        
        exit(true);
    end;
    
    local procedure GetNextCustomerNo(): Code[20]
    var
        Counter: Integer;
        CounterKey: Text;
        CustomerNo: Code[20];
        Customer: Record Customer;
        MaxAttempts: Integer;
    begin
        CounterKey := 'CUSTOMER_COUNTER';
        MaxAttempts := 100;
        
        if CounterRegistry.Get(CounterKey, Counter) then
            Counter += 1
        else
            Counter := 1;
            
        repeat
            CustomerNo := 'XCUST' + Format(Counter).PadLeft(6, '0');
            Counter += 1;
            MaxAttempts -= 1;
        until (not Customer.Get(CustomerNo)) or (MaxAttempts = 0);
        
        if MaxAttempts = 0 then
            Error('Unable to generate unique customer number after 100 attempts');
            
        CounterRegistry.Set(CounterKey, Counter);
        exit(CustomerNo);
    end;
    
    local procedure TryGetFieldRef(var RecordRef: RecordRef; FieldName: Text; var FieldRef: FieldRef): Boolean
    var
        i: Integer;
    begin
        for i := 1 to RecordRef.FieldCount do begin
            FieldRef := RecordRef.FieldIndex(i);
            if UpperCase(FieldRef.Name) = UpperCase(FieldName) then
                exit(true);
        end;
        
        exit(false);
    end;
    
    local procedure SetFieldValue(var FieldRef: FieldRef; Value: Variant)
    var
        IntValue: Integer;
        DecValue: Decimal;
        DateValue: Date;
        TimeValue: Time;
        DateTimeValue: DateTime;
        BoolValue: Boolean;
        GuidValue: Guid;
    begin
        case FieldRef.Type of
            FieldType::Code,
            FieldType::Text:
                FieldRef.Value := Format(Value);
            FieldType::Integer:
                begin
                    if Evaluate(IntValue, Format(Value)) then
                        FieldRef.Value := IntValue;
                end;
            FieldType::Decimal:
                begin
                    if Evaluate(DecValue, Format(Value)) then
                        FieldRef.Value := DecValue;
                end;
            FieldType::Date:
                begin
                    if Evaluate(DateValue, Format(Value)) then
                        FieldRef.Value := DateValue;
                end;
            FieldType::Time:
                begin
                    if Evaluate(TimeValue, Format(Value)) then
                        FieldRef.Value := TimeValue;
                end;
            FieldType::DateTime:
                begin
                    if Evaluate(DateTimeValue, Format(Value)) then
                        FieldRef.Value := DateTimeValue;
                end;
            FieldType::Boolean:
                begin
                    if Evaluate(BoolValue, Format(Value)) then
                        FieldRef.Value := BoolValue;
                end;
            FieldType::GUID:
                begin
                    if Evaluate(GuidValue, Format(Value)) then
                        FieldRef.Value := GuidValue;
                end;
        end;
    end;
    
    local procedure InitializeDefaults()
    begin
        DefaultValues.Add('Country/Region Code', 'US');
        DefaultValues.Add('Language Code', 'ENU');
        DefaultValues.Add('Customer Statistics Group', 1);
        DefaultValues.Add('Credit Limit (LCY)', 100000);
        DefaultValues.Add('Max. Invoice Discount %', 10);
    end;
    
    local procedure InitializeValidators()
    var
        EmailValidator: Codeunit "Email Field Validator";
        PhoneValidator: Codeunit "Phone Field Validator";
        CreditLimitValidator: Codeunit "Credit Limit Validator";
    begin
        ValidationRules.Add('E-Mail', EmailValidator);
        ValidationRules.Add('Phone No.', PhoneValidator);
        ValidationRules.Add('Mobile Phone No.', PhoneValidator);
        ValidationRules.Add('Credit Limit (LCY)', CreditLimitValidator);
    end;
    
    local procedure GetTestPaymentTermsCode(): Code[10]
    begin
        exit('X30DAYS');
    end;
    
    local procedure GetTestPaymentMethodCode(): Code[10]
    begin
        exit('XCHECK');
    end;
    
    local procedure GetTestSalespersonCode(): Code[20]
    begin
        exit('XSALES01');
    end;
    
    local procedure GetTestPriceGroupCode(): Code[20]
    begin
        exit('XSTANDARD');
    end;
    
    local procedure GetTestDiscountGroupCode(): Code[20]
    begin
        exit('XRETAIL');
    end;
    
    local procedure GetTestShipmentMethodCode(): Code[10]
    begin
        exit('XGROUND');
    end;
}
```

### Advanced Builder Pattern with Fluent Interface

```al
codeunit 50701 "Sales Scenario Builder"
{
    var
        ScenarioData: Dictionary of [Text, Variant];
        CustomerFactory: Codeunit "Customer Test Factory";
        ItemFactory: Codeunit "Item Test Factory";
        LineBuilders: List of [Dictionary of [Text, Variant]];
        ValidationEnabled: Boolean;
        
    /// <summary>
    /// Initializes a new sales scenario builder
    /// </summary>
    procedure NewScenario(): Codeunit "Sales Scenario Builder"
    var
        Builder: Codeunit "Sales Scenario Builder";
    begin
        Clear(ScenarioData);
        Clear(LineBuilders);
        ValidationEnabled := true;
        
        // Set default values
        ScenarioData.Add('DocumentType', "Sales Document Type"::Order);
        ScenarioData.Add('DocumentDate', Today);
        ScenarioData.Add('PostingDate', Today);
        ScenarioData.Add('OrderDate', Today);
        
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Configures the customer using fluent syntax
    /// </summary>
    procedure WithCustomer(): Codeunit "Customer Scenario Builder"
    var
        CustomerBuilder: Codeunit "Customer Scenario Builder";
    begin
        CustomerBuilder.Initialize(this);
        exit(CustomerBuilder);
    end;
    
    /// <summary>
    /// Sets the document type
    /// </summary>
    procedure AsOrder(): Codeunit "Sales Scenario Builder"
    var
        Builder: Codeunit "Sales Scenario Builder";
    begin
        ScenarioData.Set('DocumentType', "Sales Document Type"::Order);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Sets the document type to invoice
    /// </summary>
    procedure AsInvoice(): Codeunit "Sales Scenario Builder"
    var
        Builder: Codeunit "Sales Scenario Builder";
    begin
        ScenarioData.Set('DocumentType', "Sales Document Type"::Invoice);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Sets the document date
    /// </summary>
    procedure OnDate(DocumentDate: Date): Codeunit "Sales Scenario Builder"
    var
        Builder: Codeunit "Sales Scenario Builder";
    begin
        ScenarioData.Set('DocumentDate', DocumentDate);
        ScenarioData.Set('PostingDate', DocumentDate);
        ScenarioData.Set('OrderDate', DocumentDate);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Adds a sales line with fluent configuration
    /// </summary>
    procedure WithLine(): Codeunit "Sales Line Builder"
    var
        LineBuilder: Codeunit "Sales Line Builder";
    begin
        LineBuilder.Initialize(this);
        exit(LineBuilder);
    end;
    
    /// <summary>
    /// Adds multiple identical lines
    /// </summary>
    procedure WithLines(Count: Integer): Codeunit "Multiple Lines Builder"
    var
        MultiLineBuilder: Codeunit "Multiple Lines Builder";
    begin
        MultiLineBuilder.Initialize(this, Count);
        exit(MultiLineBuilder);
    end;
    
    /// <summary>
    /// Enables or disables validation during build
    /// </summary>
    procedure WithValidation(Enabled: Boolean): Codeunit "Sales Scenario Builder"
    var
        Builder: Codeunit "Sales Scenario Builder";
    begin
        ValidationEnabled := Enabled;
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Builds the complete sales scenario
    /// </summary>
    procedure Build(): Dictionary of [Text, Variant]
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        LineBuilder: Dictionary of [Text, Variant];
        Results: Dictionary of [Text, Variant];
        LineResults: List of [Record "Sales Line"];
        DocumentNo: Code[20];
    begin
        // Validate scenario before building
        if ValidationEnabled then
            ValidateScenario();
            
        // Create or get customer
        Customer := CreateOrGetCustomer();
        
        // Create sales header
        SalesHeader := CreateSalesHeader(Customer);
        DocumentNo := SalesHeader."No.";
        
        // Create sales lines
        foreach LineBuilder in LineBuilders do
            LineResults.Add(CreateSalesLine(SalesHeader, LineBuilder));
            
        // Build result dictionary
        Results.Add('SalesHeader', SalesHeader);
        Results.Add('Customer', Customer);
        Results.Add('DocumentNo', DocumentNo);
        Results.Add('LineCount', LineResults.Count);
        Results.Add('Lines', LineResults);
        Results.Add('TotalAmount', CalculateTotalAmount(LineResults));
        
        exit(Results);
    end;
    
    /// <summary>
    /// Adds line configuration to the builder
    /// </summary>
    procedure AddLineConfiguration(LineConfig: Dictionary of [Text, Variant])
    begin
        LineBuilders.Add(LineConfig);
    end;
    
    /// <summary>
    /// Sets customer configuration
    /// </summary>
    procedure SetCustomerConfiguration(CustomerConfig: Dictionary of [Text, Variant])
    begin
        ScenarioData.Add('CustomerConfig', CustomerConfig);
    end;
    
    local procedure ValidateScenario()
    var
        ValidationErrors: List of [Text];
    begin
        // Validate document type
        if not ScenarioData.ContainsKey('DocumentType') then
            ValidationErrors.Add('Document type is required');
            
        // Validate dates
        if not ScenarioData.ContainsKey('DocumentDate') then
            ValidationErrors.Add('Document date is required');
            
        // Validate lines
        if LineBuilders.Count = 0 then
            ValidationErrors.Add('At least one sales line is required');
            
        if ValidationErrors.Count > 0 then
            Error('Scenario validation failed:\%1', JoinValidationErrors(ValidationErrors));
    end;
    
    local procedure CreateOrGetCustomer(): Record Customer
    var
        Customer: Record Customer;
        CustomerConfig: Dictionary of [Text, Variant];
        CustomerConfigVariant: Variant;
    begin
        if ScenarioData.Get('CustomerConfig', CustomerConfigVariant) then begin
            CustomerConfig := CustomerConfigVariant;
            Customer := CustomerFactory.CreateCustom(CustomerConfig);
        end else begin
            Customer := CustomerFactory.CreateStandard();
        end;
        
        exit(Customer);
    end;
    
    local procedure CreateSalesHeader(Customer: Record Customer): Record "Sales Header"
    var
        SalesHeader: Record "Sales Header";
        DocumentType: Variant;
        DocumentDate: Variant;
        OrderDate: Variant;
        PostingDate: Variant;
    begin
        SalesHeader.Init();
        
        ScenarioData.Get('DocumentType', DocumentType);
        SalesHeader."Document Type" := DocumentType;
        SalesHeader."No." := GetNextDocumentNo(SalesHeader."Document Type");
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader."Bill-to Customer No." := Customer."No.";
        
        if ScenarioData.Get('DocumentDate', DocumentDate) then
            SalesHeader."Document Date" := DocumentDate;
            
        if ScenarioData.Get('OrderDate', OrderDate) then
            SalesHeader."Order Date" := OrderDate;
            
        if ScenarioData.Get('PostingDate', PostingDate) then
            SalesHeader."Posting Date" := PostingDate;
            
        SalesHeader.Insert(true);
        exit(SalesHeader);
    end;
    
    local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; LineConfig: Dictionary of [Text, Variant]): Record "Sales Line"
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ItemConfig: Dictionary of [Text, Variant];
        ItemConfigVariant: Variant;
        Quantity: Variant;
        UnitPrice: Variant;
        LineNo: Integer;
    begin
        LineNo := GetNextLineNo(SalesHeader);
        
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Type := SalesLine.Type::Item;
        
        // Create or get item
        if LineConfig.Get('ItemConfig', ItemConfigVariant) then begin
            ItemConfig := ItemConfigVariant;
            Item := ItemFactory.CreateCustom(ItemConfig);
        end else begin
            Item := ItemFactory.CreateStandard();
        end;
        
        SalesLine."No." := Item."No.";
        
        if LineConfig.Get('Quantity', Quantity) then
            SalesLine.Quantity := Quantity
        else
            SalesLine.Quantity := 1;
            
        if LineConfig.Get('UnitPrice', UnitPrice) then
            SalesLine."Unit Price" := UnitPrice
        else
            SalesLine."Unit Price" := Item."Unit Price";
            
        SalesLine.Insert(true);
        exit(SalesLine);
    end;
    
    local procedure GetNextDocumentNo(DocumentType: Enum "Sales Document Type"): Code[20]
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesCode: Code[20];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        SalesSetup.Get();
        
        case DocumentType of
            DocumentType::Order:
                NoSeriesCode := SalesSetup."Order Nos.";
            DocumentType::Invoice:
                NoSeriesCode := SalesSetup."Invoice Nos.";
            DocumentType::"Credit Memo":
                NoSeriesCode := SalesSetup."Credit Memo Nos.";
            DocumentType::"Return Order":
                NoSeriesCode := SalesSetup."Return Order Nos.";
        end;
        
        exit(NoSeriesManagement.GetNextNo(NoSeriesCode, Today, true));
    end;
    
    local procedure GetNextLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000)
        else
            exit(10000);
    end;
    
    local procedure CalculateTotalAmount(Lines: List of [Record "Sales Line"]): Decimal
    var
        SalesLine: Record "Sales Line";
        TotalAmount: Decimal;
    begin
        foreach SalesLine in Lines do
            TotalAmount += SalesLine.Quantity * SalesLine."Unit Price";
            
        exit(TotalAmount);
    end;
    
    local procedure JoinValidationErrors(ValidationErrors: List of [Text]): Text
    var
        ErrorMsg: Text;
        AllErrors: Text;
    begin
        foreach ErrorMsg in ValidationErrors do begin
            if AllErrors <> '' then
                AllErrors += '\';
            AllErrors += ErrorMsg;
        end;
        
        exit(AllErrors);
    end;
}

codeunit 50702 "Customer Scenario Builder"
{
    var
        ParentBuilder: Codeunit "Sales Scenario Builder";
        CustomerConfig: Dictionary of [Text, Variant];
        
    procedure Initialize(Parent: Codeunit "Sales Scenario Builder")
    begin
        ParentBuilder := Parent;
        Clear(CustomerConfig);
    end;
    
    /// <summary>
    /// Sets customer name
    /// </summary>
    procedure Named(CustomerName: Text[100]): Codeunit "Customer Scenario Builder"
    var
        Builder: Codeunit "Customer Scenario Builder";
    begin
        CustomerConfig.Set('Name', CustomerName);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Sets customer address
    /// </summary>
    procedure At(Address: Text[100]; City: Text[30]; PostCode: Code[20]): Codeunit "Customer Scenario Builder"
    var
        Builder: Codeunit "Customer Scenario Builder";
    begin
        CustomerConfig.Set('Address', Address);
        CustomerConfig.Set('City', City);
        CustomerConfig.Set('Post Code', PostCode);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Sets customer credit limit
    /// </summary>
    procedure WithCreditLimit(CreditLimit: Decimal): Codeunit "Customer Scenario Builder"
    var
        Builder: Codeunit "Customer Scenario Builder";
    begin
        CustomerConfig.Set('Credit Limit (LCY)', CreditLimit);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Returns to the parent sales scenario builder
    /// </summary>
    procedure EndCustomer(): Codeunit "Sales Scenario Builder"
    begin
        ParentBuilder.SetCustomerConfiguration(CustomerConfig);
        exit(ParentBuilder);
    end;
}

codeunit 50703 "Sales Line Builder"
{
    var
        ParentBuilder: Codeunit "Sales Scenario Builder";
        LineConfig: Dictionary of [Text, Variant];
        
    procedure Initialize(Parent: Codeunit "Sales Scenario Builder")
    begin
        ParentBuilder := Parent;
        Clear(LineConfig);
    end;
    
    /// <summary>
    /// Sets the item for this line
    /// </summary>
    procedure ForItem(ItemNo: Code[20]): Codeunit "Sales Line Builder"
    var
        Builder: Codeunit "Sales Line Builder";
        ItemConfig: Dictionary of [Text, Variant];
    begin
        ItemConfig.Add('No.', ItemNo);
        LineConfig.Set('ItemConfig', ItemConfig);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Creates a new item with specifications
    /// </summary>
    procedure ForNewItem(ItemDescription: Text[100]; UnitPrice: Decimal): Codeunit "Sales Line Builder"
    var
        Builder: Codeunit "Sales Line Builder";
        ItemConfig: Dictionary of [Text, Variant];
    begin
        ItemConfig.Add('Description', ItemDescription);
        ItemConfig.Add('Unit Price', UnitPrice);
        LineConfig.Set('ItemConfig', ItemConfig);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Sets the quantity
    /// </summary>
    procedure WithQuantity(Quantity: Decimal): Codeunit "Sales Line Builder"
    var
        Builder: Codeunit "Sales Line Builder";
    begin
        LineConfig.Set('Quantity', Quantity);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Sets the unit price
    /// </summary>
    procedure AtPrice(UnitPrice: Decimal): Codeunit "Sales Line Builder"
    var
        Builder: Codeunit "Sales Line Builder";
    begin
        LineConfig.Set('UnitPrice', UnitPrice);
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Returns to the parent sales scenario builder
    /// </summary>
    procedure EndLine(): Codeunit "Sales Scenario Builder"
    begin
        ParentBuilder.AddLineConfiguration(LineConfig);
        exit(ParentBuilder);
    end;
}
```

## Usage Examples

### Complete Sales Scenario Creation

```al
codeunit 50704 "Sales Scenario Examples"
{
    /// <summary>
    /// Demonstrates comprehensive sales scenario building
    /// </summary>
    [Test]
    procedure TestComplexSalesScenario()
    var
        ScenarioBuilder: Codeunit "Sales Scenario Builder";
        ScenarioResults: Dictionary of [Text, Variant];
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
        TotalAmount: Decimal;
    begin
        // Arrange: Build a complex sales scenario using fluent interface
        ScenarioResults := ScenarioBuilder.NewScenario()
            .AsOrder()
            .OnDate(CalcDate('<+5D>', Today))
            .WithCustomer()
                .Named('XTest Premium Customer')
                .At('X123 Premium Street', 'XPremium City', 'X12345')
                .WithCreditLimit(500000)
            .EndCustomer()
            .WithLine()
                .ForNewItem('XPremium Widget', 199.99)
                .WithQuantity(5)
                .AtPrice(189.99)
            .EndLine()
            .WithLine()
                .ForNewItem('XStandard Service', 99.99)
                .WithQuantity(3)
            .EndLine()
            .WithValidation(true)
            .Build();
            
        // Act: Extract results
        DocumentNo := ScenarioResults.Get('DocumentNo');
        SalesHeader := ScenarioResults.Get('SalesHeader');
        TotalAmount := ScenarioResults.Get('TotalAmount');
        
        // Assert: Validate the scenario
        Assert.AreNotEqual('', DocumentNo, 'Document number should be generated');
        Assert.AreEqual(DocumentNo, SalesHeader."No.", 'Header should match document number');
        Assert.AreEqual(2, ScenarioResults.Get('LineCount'), 'Should have 2 lines');
        Assert.AreEqual(1249.92, TotalAmount, 'Total should be calculated correctly'); // (5*189.99) + (3*99.99)
        
        // Verify customer was created correctly
        Customer.Get(SalesHeader."Sell-to Customer No.");
        Assert.AreEqual('XTest Premium Customer', Customer.Name, 'Customer name should match');
        Assert.AreEqual(500000, Customer."Credit Limit (LCY)", 'Credit limit should match');
    end;
    
    /// <summary>
    /// Demonstrates batch creation with different configurations
    /// </summary>
    [Test]
    procedure TestBatchCustomerCreation()
    var
        CustomerFactory: Codeunit "Customer Test Factory";
        Customers: List of [Variant];
        Customer: Record Customer;
        CustomerVariant: Variant;
        i: Integer;
    begin
        // Arrange & Act: Create batch of customers
        Customers := CustomerFactory.CreateBatch(10, "Test Creation Type"::Standard);
        
        // Assert: Validate batch creation
        Assert.AreEqual(10, Customers.Count, 'Should create 10 customers');
        
        i := 1;
        foreach CustomerVariant in Customers do begin
            Customer := CustomerVariant;
            Assert.AreNotEqual('', Customer."No.", StrSubstNo('Customer %1 should have number', i));
            Assert.IsTrue(Customer."No.".StartsWith('XCUST'), StrSubstNo('Customer %1 should have test prefix', i));
            i += 1;
        end;
    end;
    
    /// <summary>
    /// Demonstrates custom specifications with validation
    /// </summary>
    [Test]
    procedure TestCustomerWithSpecifications()
    var
        CustomerFactory: Codeunit "Customer Test Factory";
        Customer: Record Customer;
        Specifications: Dictionary of [Text, Variant];
    begin
        // Arrange: Define custom specifications
        Specifications.Add('Name', 'XSpecial Test Customer');
        Specifications.Add('E-Mail', 'special@test.example.com');
        Specifications.Add('Credit Limit (LCY)', 250000);
        Specifications.Add('Phone No.', '+1-555-SPECIAL');
        
        // Act: Create customer with specifications
        Customer := CustomerFactory.CreateCustom(Specifications);
        
        // Assert: Validate specifications were applied
        Assert.AreEqual('XSpecial Test Customer', Customer.Name, 'Name should match specification');
        Assert.AreEqual('special@test.example.com', Customer."E-Mail", 'Email should match specification');
        Assert.AreEqual(250000, Customer."Credit Limit (LCY)", 'Credit limit should match specification');
        Assert.AreEqual('+1-555-SPECIAL', Customer."Phone No.", 'Phone should match specification');
    end;
}
```

These comprehensive samples demonstrate production-ready test library design patterns with complete factory implementations, fluent builders, and usage examples.
