# AL Anti-Patterns to Avoid ⚠️

**Legacy patterns that were once acceptable but should be avoided in modern Business Central development**

## Table of Contents

1. [Object Design Anti-Patterns](#object-design-anti-patterns)
2. [Code Structure Anti-Patterns](#code-structure-anti-patterns) 
3. [Integration Anti-Patterns](#integration-anti-patterns)
4. [Performance Anti-Patterns](#performance-anti-patterns)
5. [Error Handling Anti-Patterns](#error-handling-anti-patterns)
6. [Extension Anti-Patterns](#extension-anti-patterns)

---

## Object Design Anti-Patterns

### ❌ God Objects (Everything in One Place)

**Legacy Approach:**
```al
// Don't do this - violates Single Responsibility Principle
codeunit 50100 "Customer Everything Manager"
{
    // Validation, processing, reporting, integration, notifications...
    procedure ValidateCustomer() // 200+ lines
    procedure ProcessCustomerOrders() // 300+ lines  
    procedure SendNotifications() // 150+ lines
    procedure GenerateReports() // 250+ lines
    procedure IntegrateWithExternalSystems() // 400+ lines
}
```

**Modern Approach:**
```al
// ✅ Single responsibility - focused, testable, maintainable
codeunit 50100 "Customer Validator"
{
    procedure ValidateCustomer(var Customer: Record Customer): Boolean
}

codeunit 50101 "Customer Order Processor"  
{
    procedure ProcessCustomerOrders(CustomerNo: Code[20])
}

codeunit 50102 "Customer Notification Manager"
{
    procedure SendWelcomeNotification(CustomerNo: Code[20])
}
```

### ❌ Magic Numbers and Hardcoded Values

**Legacy Approach:**
```al
// Don't do this - unclear business meaning
if Customer."Credit Limit" > 50000 then
    // Why 50000? What does this represent?
    
if SalesLine.Type = 2 then // What is type 2?
    
Customer.SetRange("Customer Posting Group", 'DOMESTIC'); // Hardcoded value
```

**Modern Approach:**
```al
// ✅ Named constants with business meaning
codeunit 50100 "Customer Credit Constants"
{
    procedure GetHighValueCustomerThreshold(): Decimal
    begin
        exit(50000); // Centralized, documented threshold
    end;
}

// Use enums instead of magic numbers
if SalesLine.Type = SalesLine.Type::Item then

// Use setup tables for configurable values
CustomerSetup.Get();
Customer.SetRange("Customer Posting Group", CustomerSetup."Default Domestic Posting Group");
```

---

## Code Structure Anti-Patterns

### ❌ Copy-Paste Programming

**Legacy Approach:**
```al
// Don't do this - repeated validation logic
procedure ValidateCustomerOrder()
begin
    if Customer."Credit Limit" < OrderTotal then
        Error('Credit limit exceeded');
    if Customer.Blocked <> Customer.Blocked::" " then
        Error('Customer is blocked');
    if Customer."Payment Terms Code" = '' then
        Error('Payment terms required');
end;

procedure ValidateCustomerInvoice()  
begin
    if Customer."Credit Limit" < InvoiceTotal then
        Error('Credit limit exceeded');
    if Customer.Blocked <> Customer.Blocked::" " then
        Error('Customer is blocked');
    if Customer."Payment Terms Code" = '' then
        Error('Payment terms required');
end;
```

**Modern Approach:**
```al
// ✅ Reusable validation with proper abstraction
codeunit 50100 "Customer Credit Validator"
{
    procedure ValidateCreditLimit(CustomerNo: Code[20]; Amount: Decimal)
    procedure ValidateCustomerStatus(CustomerNo: Code[20])
    procedure ValidatePaymentTerms(CustomerNo: Code[20])
    
    procedure ValidateForTransaction(CustomerNo: Code[20]; Amount: Decimal)
    begin
        ValidateCreditLimit(CustomerNo, Amount);
        ValidateCustomerStatus(CustomerNo);
        ValidatePaymentTerms(CustomerNo);
    end;
}
```

### ❌ Nested IF-ELSE Pyramids

**Legacy Approach:**
```al
// Don't do this - pyramid of doom
procedure ProcessOrder()
begin
    if CustomerExists then begin
        if CustomerNotBlocked then begin
            if CreditLimitOK then begin
                if ItemsAvailable then begin
                    if PaymentTermsValid then begin
                        if ShippingAddressExists then begin
                            // Finally do something 6 levels deep
                            PostOrder();
                        end else
                            Error('Shipping address missing');
                    end else
                        Error('Payment terms invalid');
                end else
                    Error('Items not available');
            end else
                Error('Credit limit exceeded');
        end else
            Error('Customer blocked');
    end else
        Error('Customer not found');
end;
```

**Modern Approach:**
```al
// ✅ Guard clauses with early returns
procedure ProcessOrder()
var
    ValidationResult: Boolean;
begin
    // Guard clauses - fail fast pattern
    if not CustomerExists then
        Error('Customer not found');
        
    if CustomerBlocked then
        Error('Customer is blocked');
        
    if not CreditLimitOK then
        Error('Credit limit exceeded');
        
    if not ItemsAvailable then
        Error('Items not available');
        
    if not PaymentTermsValid then
        Error('Payment terms invalid');
        
    if not ShippingAddressExists then
        Error('Shipping address missing');
    
    // Happy path at normal indentation level
    PostOrder();
end;
```

---

## Integration Anti-Patterns

### ❌ Synchronous External Calls in User Transactions

**Legacy Approach:**
```al
// Don't do this - blocks UI and can timeout
procedure OnAfterInsertCustomer()
var
    HttpClient: HttpClient;
    Response: HttpResponseMessage;
begin
    // This blocks the user while waiting for external system
    if not HttpClient.Post('https://external-crm.com/api/customers', Content, Response) then
        Error('Failed to sync customer'); // Transaction fails if external system is down
end;
```

**Modern Approach:**
```al
// ✅ Asynchronous processing with job queue
procedure OnAfterInsertCustomer()
var
    CustomerSyncQueue: Record "Job Queue Entry";
begin
    // Queue for background processing
    CreateCustomerSyncJob(Rec."No.");
    
    // User transaction continues immediately
end;

codeunit 50100 "Customer Sync Job"
{
    procedure SyncCustomerToExternalSystem(CustomerNo: Code[20])
    begin
        // Runs in background with proper error handling
        if not TryCallExternalAPI(CustomerNo) then
            LogSyncFailure(CustomerNo, GetLastErrorText());
    end;
}
```

### ❌ Direct Database Integration

**Legacy Approach:**
```al
// Don't do this - bypasses BC business logic
procedure ImportCustomersFromSQL()
var
    SqlConnection: DotNet SqlConnection;
    SqlCommand: DotNet SqlCommand;
begin
    // Direct database access bypasses validation, events, etc.
    SqlConnection.ConnectionString := 'Data Source=...';
    SqlCommand.CommandText := 'INSERT INTO Customer VALUES...';
    SqlCommand.ExecuteNonQuery();
end;
```

**Modern Approach:**
```al
// ✅ Use BC APIs and business logic
procedure ImportCustomersFromExternalSystem()
var
    Customer: Record Customer;
    ImportData: JsonObject;
begin
    // Uses BC business logic, triggers events, validates data
    Customer.Init();
    PopulateCustomerFromJson(Customer, ImportData);
    Customer.Insert(true); // Triggers all validation and events
end;
```

---

## Performance Anti-Patterns

### ❌ N+1 Query Problem

**Legacy Approach:**
```al
// Don't do this - creates one query per customer
procedure UpdateAllCustomerBalances()
var
    Customer: Record Customer;
    CustLedgerEntry: Record "Cust. Ledger Entry";
    Balance: Decimal;
begin
    if Customer.FindSet() then
        repeat
            // This creates a separate query for each customer
            CustLedgerEntry.SetRange("Customer No.", Customer."No.");
            CustLedgerEntry.CalcSums(Amount);
            Balance := CustLedgerEntry.Amount;
            
            Customer.Modify(); // One modify per customer
        until Customer.Next() = 0;
end;
```

**Modern Approach:**
```al
// ✅ Batch processing with calculated fields
procedure UpdateAllCustomerBalances()
var
    Customer: Record Customer;
begin
    if Customer.FindSet() then
        repeat
            // Use FlowFields - calculated by BC engine efficiently
            Customer.CalcFields(Balance);
            // Or use batch updates with temporary records
        until Customer.Next() = 0;
end;
```

### ❌ Loading All Records Into Memory

**Legacy Approach:**
```al
// Don't do this - loads entire table into memory
procedure ProcessAllItems()
var
    Item: Record Item;
    ItemList: List of [Record Item];
begin
    if Item.FindSet() then
        repeat
            ItemList.Add(Item); // Memory consumption grows linearly
        until Item.Next() = 0;
    
    // Process entire list in memory
end;
```

**Modern Approach:**
```al
// ✅ Stream processing with pagination
procedure ProcessAllItems()
var
    Item: Record Item;
    ProcessedCount: Integer;
begin
    if Item.FindSet() then
        repeat
            ProcessSingleItem(Item);
            ProcessedCount += 1;
            
            // Commit periodically to avoid long transactions
            if ProcessedCount mod 1000 = 0 then
                Commit();
        until Item.Next() = 0;
end;
```

---

## Error Handling Anti-Patterns

### ❌ Generic Error Messages

**Legacy Approach:**
```al
// Don't do this - provides no actionable information
if ValidationFailed then
    Error('Validation failed');
    
Customer.TestField("Payment Terms Code"); // Generic "must have a value" message

if not HttpResponse.IsSuccessStatusCode then
    Error('API call failed'); // No context about what to do
```

**Modern Approach:**
```al
// ✅ Specific, actionable error messages with ErrorInfo
procedure ValidateCustomer(var Customer: Record Customer)
var
    ValidationError: ErrorInfo;
begin
    if Customer."Payment Terms Code" = '' then begin
        ValidationError.Message := 'Payment terms are required for customer processing';
        ValidationError.DetailedMessage := 'Customer must have payment terms assigned before creating orders or invoices.';
        ValidationError.AddAction('Open Payment Terms', Codeunit::"Customer Actions", 'OpenPaymentTerms');
        ValidationError.AddAction('Set Default Terms', Codeunit::"Customer Actions", 'SetDefaultTerms');
        Error(ValidationError);
    end;
end;
```

### ❌ Silent Failure Patterns

**Legacy Approach:**
```al
// Don't do this - hides problems from users and logs
procedure SyncCustomerData()
begin
    if not TryCallExternalAPI() then
        exit; // Silent failure - no logging, no user notification
end;

procedure ProcessOrder()
begin
    TryValidateInventory(); // Ignores validation result
    PostOrder(); // Proceeds anyway
end;
```

**Modern Approach:**
```al
// ✅ Explicit error handling with proper logging
procedure SyncCustomerData()
var
    ErrorMessage: Text;
begin
    if not TryCallExternalAPI() then begin
        ErrorMessage := GetLastErrorText();
        Session.LogMessage('CustomerSync', ErrorMessage, Verbosity::Error, 
                          DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher);
        
        // Inform user about the issue
        Message('Customer synchronization failed. The issue has been logged for review.');
    end;
end;
```

---

## Extension Anti-Patterns

### ❌ Heavy Customization of Standard Objects

**Legacy Approach:**
```al
// Don't do this - modifies core BC behavior heavily
tableextension 50100 "Customer Extension" extends Customer
{
    fields
    {
        // Adding 20+ custom fields
        field(50100; "Custom Field 1"; Text[100]) { }
        field(50101; "Custom Field 2"; Text[100]) { }
        // ... 18 more fields
    }
    
    trigger OnInsert()
    begin
        // Complex custom logic that changes standard behavior
        CompletelyDifferentInsertLogic();
    end;
    
    trigger OnModify()  
    begin
        // Overrides standard modification behavior
        CompletelyDifferentModifyLogic();
    end;
}
```

**Modern Approach:**
```al
// ✅ Composition over heavy extension
table 50100 "Customer Extension Data"
{
    // Separate table for custom data
    fields
    {
        field(1; "Customer No."; Code[20]) { TableRelation = Customer; }
        field(10; "Custom Field 1"; Text[100]) { }
        field(11; "Custom Field 2"; Text[100]) { }
    }
}

// Lightweight extension with events
tableextension 50100 "Customer Extension" extends Customer
{
    trigger OnAfterInsert()
    begin
        CreateCustomerExtensionData(Rec."No.");
    end;
}
```

### ❌ Ignoring Upgrade Considerations

**Legacy Approach:**
```al
// Don't do this - hardcoded assumptions about BC versions
procedure ProcessData()
begin
    // Assumes specific BC version behavior
    Customer.SetRange("Credit Limit", 0, 999999);
    
    // Uses deprecated methods without fallback
    OldDeprecatedFunction();
    
    // Modifies system tables directly
    CompanyInformation.ModifyAll("Primary Key", NewValue);
end;
```

**Modern Approach:**
```al
// ✅ Version-aware, upgrade-safe patterns
procedure ProcessData()
var
    CustomerSetup: Record "Customer Setup";
begin
    // Use setup table for configurable limits
    CustomerSetup.Get();
    Customer.SetRange("Credit Limit", 0, CustomerSetup."Max Credit Limit for Processing");
    
    // Check for feature availability
    if IsFeatureAvailable() then
        NewFunction()
    else
        FallbackFunction();
        
    // Use proper upgrade procedures
    OnUpgradePerDatabase();
end;
```

---

## AI Prompting to Avoid Anti-Patterns

### Good Prompts for Modern Patterns

```al
// ✅ Ask Copilot to identify anti-patterns:
"Review this code for anti-patterns and suggest modern alternatives"
"Convert this nested IF structure to use guard clauses"
"Refactor this god object into single-responsibility components"
"Replace these magic numbers with named constants or enums"
```

### Prompt for Better Architecture

```al
// ✅ Guide Copilot toward good patterns:
"Create a validation codeunit that follows single responsibility principle"
"Design this integration with proper error handling and async processing"  
"Implement this feature using events for extensibility"
"Add ErrorInfo with suggested actions to this validation"
```

---

## Migration Guidelines

### When You Encounter Anti-Patterns

1. **Don't Fix Everything At Once**
   - Identify the most problematic patterns first
   - Refactor incrementally to avoid breaking changes
   - Test thoroughly after each refactoring step

2. **Use Deprecation Warnings**
   ```al
   [Obsolete('Use CustomerValidator codeunit instead', '1.5')]
   procedure OldValidationMethod()
   ```

3. **Create Compatibility Layers**
   ```al
   // Keep old interface working while promoting new approach
   procedure LegacyMethod()
   begin
       NewImprovedMethod(); // Delegate to new implementation
   end;
   ```

4. **Document Migration Path**
   - Explain why the old pattern is problematic
   - Provide clear examples of the new approach
   - Include timeline for deprecation

---

**Avoiding anti-patterns leads to more maintainable, performant, and AI-friendly Business Central solutions!** 🎯

*Remember: These patterns were often appropriate in their time, but modern AL development has better alternatives.*
