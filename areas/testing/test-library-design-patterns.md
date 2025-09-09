---
title: "Test Library Design Patterns"
description: "Architectural patterns and best practices for creating maintainable, reusable test libraries that support comprehensive automated testing scenarios"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "Interface", "Dictionary", "List", "Variant"]
tags: ["testing", "library-design", "architecture", "reusability", "test-framework", "patterns"]
---

# Test Library Design Patterns

## Core Design Principles

### Single Responsibility
Each test library should focus on a specific domain or functional area with clear boundaries.

### Interface-Based Design
Use interfaces to define contracts between test libraries and consuming tests.

### Dependency Injection
Support dependency injection to enable flexible test configurations and mocking.

### Fluent API Design
Provide fluent, chainable methods that make test code more readable and maintainable.

## Implementation Patterns

### Factory Pattern for Test Data

Create specialized factories for different types of test data:

```al
interface "Test Data Factory"
{
    /// <summary>
    /// Creates a basic test record with minimal required fields
    /// </summary>
    procedure CreateBasic(var RecordRef: RecordRef): Boolean;
    
    /// <summary>
    /// Creates a complete test record with all fields populated
    /// </summary>
    procedure CreateComplete(var RecordRef: RecordRef): Boolean;
    
    /// <summary>
    /// Creates a custom test record based on provided specifications
    /// </summary>
    procedure CreateCustom(var RecordRef: RecordRef; Specifications: Dictionary of [Text, Variant]): Boolean;
}
```

### Builder Pattern for Complex Scenarios

Implement builders for complex test scenarios that require multiple related records:

```al
codeunit 50600 "Sales Order Test Builder" implements "Test Scenario Builder"
{
    var
        SalesHeader: Record "Sales Header";
        CustomerBuilder: Codeunit "Customer Test Builder";
        ItemBuilders: List of [Codeunit "Item Test Builder"];
        LineBuilders: List of [Codeunit "Sales Line Test Builder"];
        ConfigurationSettings: Dictionary of [Text, Variant];
        
    /// <summary>
    /// Initializes a new sales order builder with default settings
    /// </summary>
    procedure Initialize(): Interface "Test Scenario Builder"
    var
        Builder: Interface "Test Scenario Builder";
    begin
        Clear(SalesHeader);
        Clear(CustomerBuilder);
        Clear(ItemBuilders);
        Clear(LineBuilders);
        Clear(ConfigurationSettings);
        
        // Set default configuration
        ConfigurationSettings.Add('DocumentType', SalesHeader."Document Type"::Order);
        ConfigurationSettings.Add('AutoCreateCustomer', true);
        ConfigurationSettings.Add('AutoCreateItems', true);
        ConfigurationSettings.Add('DefaultLineCount', 3);
        
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Configures the customer for the sales order
    /// </summary>
    procedure WithCustomer(CustomerSpec: Dictionary of [Text, Variant]): Interface "Test Scenario Builder"
    var
        Builder: Interface "Test Scenario Builder";
    begin
        CustomerBuilder.Initialize();
        CustomerBuilder.WithSpecifications(CustomerSpec);
        ConfigurationSettings.Set('AutoCreateCustomer', false);
        
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Adds a sales line with specified item and quantity
    /// </summary>
    procedure WithLine(ItemSpec: Dictionary of [Text, Variant]; Quantity: Decimal; UnitPrice: Decimal): Interface "Test Scenario Builder"
    var
        LineBuilder: Codeunit "Sales Line Test Builder";
        ItemBuilder: Codeunit "Item Test Builder";
        Builder: Interface "Test Scenario Builder";
    begin
        ItemBuilder.Initialize();
        ItemBuilder.WithSpecifications(ItemSpec);
        ItemBuilders.Add(ItemBuilder);
        
        LineBuilder.Initialize();
        LineBuilder.WithQuantity(Quantity);
        LineBuilder.WithUnitPrice(UnitPrice);
        LineBuilder.WithItemBuilder(ItemBuilder);
        LineBuilders.Add(LineBuilder);
        
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Sets the document date and related dates
    /// </summary>
    procedure WithDates(DocumentDate: Date; OrderDate: Date; RequestedDeliveryDate: Date): Interface "Test Scenario Builder"
    var
        Builder: Interface "Test Scenario Builder";
    begin
        ConfigurationSettings.Set('DocumentDate', DocumentDate);
        ConfigurationSettings.Set('OrderDate', OrderDate);
        ConfigurationSettings.Set('RequestedDeliveryDate', RequestedDeliveryDate);
        
        Builder := this;
        exit(Builder);
    end;
    
    /// <summary>
    /// Builds and creates the complete sales order scenario
    /// </summary>
    procedure Build(): Variant
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesLine: Record "Sales Line";
        LineBuilder: Codeunit "Sales Line Test Builder";
        ItemBuilder: Codeunit "Item Test Builder";
        DocumentNo: Code[20];
        LineNo: Integer;
        Result: Dictionary of [Text, Variant];
    begin
        // Create customer if needed
        if ConfigurationSettings.Get('AutoCreateCustomer') then
            CustomerBuilder.Build(Customer)
        else
            Customer := CustomerBuilder.GetCustomer();
            
        // Create sales header
        CreateSalesHeader(Customer);
        
        // Create items and lines
        LineNo := 10000;
        foreach LineBuilder in LineBuilders do begin
            ItemBuilder := LineBuilder.GetItemBuilder();
            ItemBuilder.Build(Item);
            
            LineBuilder.WithDocumentInfo(SalesHeader."Document Type", SalesHeader."No.", LineNo);
            LineBuilder.WithItem(Item."No.");
            LineBuilder.Build(SalesLine);
            
            LineNo += 10000;
        end;
        
        // Build result
        Result.Add('SalesHeader', SalesHeader);
        Result.Add('Customer', Customer);
        Result.Add('LineCount', LineBuilders.Count);
        Result.Add('DocumentNo', SalesHeader."No.");
        
        exit(Result);
    end;
    
    local procedure CreateSalesHeader(Customer: Record Customer)
    var
        DocumentDate: Date;
        OrderDate: Date;
        RequestedDeliveryDate: Date;
        DocumentType: Variant;
    begin
        SalesHeader.Init();
        
        ConfigurationSettings.Get('DocumentType', DocumentType);
        SalesHeader."Document Type" := DocumentType;
        SalesHeader."No." := GetNextDocumentNo();
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader."Bill-to Customer No." := Customer."No.";
        
        if ConfigurationSettings.Get('DocumentDate', DocumentDate) then
            SalesHeader."Document Date" := DocumentDate
        else
            SalesHeader."Document Date" := Today;
            
        if ConfigurationSettings.Get('OrderDate', OrderDate) then
            SalesHeader."Order Date" := OrderDate
        else
            SalesHeader."Order Date" := SalesHeader."Document Date";
            
        if ConfigurationSettings.Get('RequestedDeliveryDate', RequestedDeliveryDate) then
            SalesHeader."Requested Delivery Date" := RequestedDeliveryDate
        else
            SalesHeader."Requested Delivery Date" := CalcDate('<+7D>', SalesHeader."Order Date");
            
        SalesHeader."Posting Date" := SalesHeader."Document Date";
        SalesHeader.Insert(true);
    end;
    
    local procedure GetNextDocumentNo(): Code[20]
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        SalesSetup.Get();
        exit(NoSeriesManagement.GetNextNo(SalesSetup."Order Nos.", Today, true));
    end;
}
```

### Repository Pattern for Test Data Management

Implement repository pattern to abstract test data access and management:

```al
interface "Test Data Repository"
{
    /// <summary>
    /// Finds test records matching the specified criteria
    /// </summary>
    procedure Find(SearchCriteria: Dictionary of [Text, Variant]; var Results: List of [RecordRef]): Boolean;
    
    /// <summary>
    /// Creates a new test record with specified data
    /// </summary>
    procedure Create(RecordData: Dictionary of [Text, Variant]; var NewRecord: RecordRef): Boolean;
    
    /// <summary>
    /// Updates an existing test record
    /// </summary>
    procedure Update(RecordKey: Dictionary of [Text, Variant]; UpdateData: Dictionary of [Text, Variant]): Boolean;
    
    /// <summary>
    /// Deletes test records matching criteria
    /// </summary>
    procedure Delete(SearchCriteria: Dictionary of [Text, Variant]): Integer;
    
    /// <summary>
    /// Validates test record state
    /// </summary>
    procedure Validate(RecordKey: Dictionary of [Text, Variant]; ValidationRules: List of [Interface "Validation Rule"]): Boolean;
}
```

### Command Pattern for Test Operations

Use command pattern to encapsulate test operations and enable undo functionality:

```al
interface "Test Command"
{
    /// <summary>
    /// Executes the test command
    /// </summary>
    procedure Execute(): Boolean;
    
    /// <summary>
    /// Undoes the test command effects
    /// </summary>
    procedure Undo(): Boolean;
    
    /// <summary>
    /// Gets the command description for logging
    /// </summary>
    procedure GetDescription(): Text[250];
    
    /// <summary>
    /// Validates if command can be executed
    /// </summary>
    procedure CanExecute(): Boolean;
}

codeunit 50601 "Create Customer Test Command" implements "Test Command"
{
    var
        CustomerData: Dictionary of [Text, Variant];
        CreatedCustomer: Record Customer;
        CommandExecuted: Boolean;
        
    procedure Initialize(Data: Dictionary of [Text, Variant])
    begin
        CustomerData := Data;
        CommandExecuted := false;
    end;
    
    procedure Execute(): Boolean
    var
        CustomerFactory: Codeunit "Customer Test Factory";
    begin
        if not CanExecute() then
            exit(false);
            
        if CustomerFactory.CreateCustom(CreatedCustomer, CustomerData) then begin
            CommandExecuted := true;
            LogCommandExecution();
            exit(true);
        end;
        
        exit(false);
    end;
    
    procedure Undo(): Boolean
    begin
        if not CommandExecuted then
            exit(true);
            
        if CreatedCustomer."No." <> '' then begin
            CreatedCustomer.Delete(true);
            CommandExecuted := false;
            LogCommandUndo();
            exit(true);
        end;
        
        exit(false);
    end;
    
    procedure GetDescription(): Text[250]
    var
        CustomerNo: Variant;
        CustomerName: Variant;
    begin
        if CustomerData.Get('No.', CustomerNo) and CustomerData.Get('Name', CustomerName) then
            exit(StrSubstNo('Create Customer %1 (%2)', CustomerNo, CustomerName))
        else
            exit('Create Customer with custom data');
    end;
    
    procedure CanExecute(): Boolean
    begin
        exit(CustomerData.Count > 0);
    end;
    
    local procedure LogCommandExecution()
    var
        CommandLog: Record "Test Command Log";
    begin
        CommandLog.Init();
        CommandLog."Entry No." := GetNextCommandLogEntry();
        CommandLog."Command Type" := 'CREATE_CUSTOMER';
        CommandLog.Description := GetDescription();
        CommandLog."Execution Time" := CurrentDateTime;
        CommandLog."User ID" := UserId;
        CommandLog.Executed := true;
        CommandLog.Insert(true);
    end;
    
    local procedure LogCommandUndo()
    var
        CommandLog: Record "Test Command Log";
    begin
        CommandLog.SetRange("Command Type", 'CREATE_CUSTOMER');
        CommandLog.SetRange(Description, GetDescription());
        CommandLog.SetRange("User ID", UserId);
        if CommandLog.FindLast() then begin
            CommandLog."Undo Time" := CurrentDateTime;
            CommandLog."Undone" := true;
            CommandLog.Modify(true);
        end;
    end;
    
    local procedure GetNextCommandLogEntry(): Integer
    var
        CommandLog: Record "Test Command Log";
    begin
        CommandLog.LockTable();
        if CommandLog.FindLast() then
            exit(CommandLog."Entry No." + 1)
        else
            exit(1);
    end;
}
```

### Observer Pattern for Test Event Handling

Implement observer pattern for test event notifications and monitoring:

```al
interface "Test Event Observer"
{
    /// <summary>
    /// Handles test event notifications
    /// </summary>
    procedure OnTestEvent(EventType: Enum "Test Event Type"; EventData: Dictionary of [Text, Variant]);
    
    /// <summary>
    /// Gets observer priority for event handling order
    /// </summary>
    procedure GetPriority(): Integer;
    
    /// <summary>
    /// Determines if observer should handle the event
    /// </summary>
    procedure ShouldHandle(EventType: Enum "Test Event Type"): Boolean;
}

codeunit 50602 "Test Event Manager"
{
    var
        Observers: List of [Interface "Test Event Observer"];
        EventHistory: List of [Record "Test Event History"];
        
    /// <summary>
    /// Registers an observer for test events
    /// </summary>
    procedure RegisterObserver(Observer: Interface "Test Event Observer")
    var
        InsertIndex: Integer;
        ExistingObserver: Interface "Test Event Observer";
        i: Integer;
    begin
        // Insert observer based on priority
        InsertIndex := Observers.Count + 1;
        
        for i := 1 to Observers.Count do begin
            ExistingObserver := Observers.Get(i);
            if Observer.GetPriority() > ExistingObserver.GetPriority() then begin
                InsertIndex := i;
                break;
            end;
        end;
        
        Observers.Insert(InsertIndex, Observer);
    end;
    
    /// <summary>
    /// Publishes test event to all registered observers
    /// </summary>
    procedure PublishEvent(EventType: Enum "Test Event Type"; EventData: Dictionary of [Text, Variant])
    var
        Observer: Interface "Test Event Observer";
        EventRecord: Record "Test Event History";
    begin
        // Log event
        LogEvent(EventType, EventData, EventRecord);
        
        // Notify observers
        foreach Observer in Observers do begin
            if Observer.ShouldHandle(EventType) then
                Observer.OnTestEvent(EventType, EventData);
        end;
    end;
    
    local procedure LogEvent(EventType: Enum "Test Event Type"; EventData: Dictionary of [Text, Variant]; var EventRecord: Record "Test Event History")
    begin
        EventRecord.Init();
        EventRecord."Entry No." := GetNextEventEntry();
        EventRecord."Event Type" := EventType;
        EventRecord."Event Time" := CurrentDateTime;
        EventRecord."Session ID" := SessionId();
        EventRecord."User ID" := UserId;
        EventRecord."Event Data" := SerializeEventData(EventData);
        EventRecord.Insert(true);
        
        EventHistory.Add(EventRecord);
    end;
    
    local procedure SerializeEventData(EventData: Dictionary of [Text, Variant]): Text
    var
        EventJson: JsonObject;
        Key: Text;
        Value: Variant;
    begin
        foreach Key in EventData.Keys do begin
            EventData.Get(Key, Value);
            EventJson.Add(Key, Format(Value));
        end;
        
        exit(EventJson.AsText());
    end;
    
    local procedure GetNextEventEntry(): Integer
    var
        EventHistory: Record "Test Event History";
    begin
        EventHistory.LockTable();
        if EventHistory.FindLast() then
            exit(EventHistory."Entry No." + 1)
        else
            exit(1);
    end;
}
```

## Best Practices

### Library Organization
- Group related functionality into focused libraries
- Use consistent naming conventions across libraries
- Implement proper error handling and validation
- Provide comprehensive documentation and examples

### Configuration Management
- Support external configuration files
- Enable environment-specific settings
- Implement configuration validation
- Provide configuration templates and examples

### Performance Optimization
- Use lazy loading for expensive operations
- Implement caching where appropriate
- Optimize database operations with proper indexing
- Monitor and profile library performance

### Testing the Libraries
- Write comprehensive unit tests for library functions
- Implement integration tests for complex scenarios
- Use property-based testing for validation
- Maintain high code coverage standards

### Version Management
- Follow semantic versioning for library releases
- Maintain backward compatibility where possible
- Document breaking changes clearly
- Provide migration guides for major updates
