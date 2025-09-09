# String Formatting Standards - Code Samples

## Text Constant Declaration Examples

```al
// Standard text constant declarations
codeunit 50000 "ABC Customer Management"
{
    var
        // Success messages
        CustomerCreatedMsg: Label 'Customer %1 has been created successfully.';
        CustomerUpdatedMsg: Label 'Customer %1 has been updated.';
        
        // Error messages  
        CustomerNotFoundErr: Label 'Customer %1 does not exist.';
        TypeMismatchErr: Label 'Field type mismatch: %1 field cannot be mapped to %2 field.';
        DeleteBlockedErr: Label 'Cannot delete %1 %2 because it has %3 active entries.';
        
        // Confirmation questions
        DeleteCustomerQst: Label 'Do you want to delete customer %1?';
        UpdatePricesQst: Label 'This will update prices for %1 items. Do you want to continue?';
        
        // Information messages
        ProcessingMsg: Label 'Processing %1 records...';
        CompletedMsg: Label 'Process completed successfully. %1 records processed.';
}
```

## StrSubstNo Usage Examples

```al
// Single parameter formatting
procedure CreateCustomer(CustomerNo: Code[20])
var
    Customer: Record Customer;
begin
    // ... customer creation logic ...
    Message(CustomerCreatedMsg, CustomerNo);
end;

// Multiple parameter formatting  
procedure ValidateFieldMapping(SourceFieldType: Text; TargetFieldType: Text)
var
    ErrorMessage: Text;
begin
    if SourceFieldType <> TargetFieldType then begin
        ErrorMessage := StrSubstNo(TypeMismatchErr, SourceFieldType, TargetFieldType);
        Error(ErrorMessage);
    end;
end;

// Complex formatting with multiple parameters
procedure CheckDeletionRestrictions(TableName: Text; RecordKey: Text; EntryCount: Integer)
begin
    if EntryCount > 0 then
        Error(DeleteBlockedErr, TableName, RecordKey, EntryCount);
end;
```

## Message and Confirmation Examples

```al
// Information messages with dynamic content
procedure ProcessCustomerBatch(var Customer: Record Customer)
var
    RecordCount: Integer;
begin
    RecordCount := Customer.Count();
    Message(ProcessingMsg, RecordCount);
    
    if Customer.FindSet() then
        repeat
            // Process each customer
        until Customer.Next() = 0;
    
    Message(CompletedMsg, RecordCount);
end;

// Confirmation dialogs with formatting
procedure DeleteCustomerWithConfirmation(CustomerNo: Code[20])
var
    Customer: Record Customer;
begin
    if not Customer.Get(CustomerNo) then
        Error(CustomerNotFoundErr, CustomerNo);
    
    if Confirm(DeleteCustomerQst, false, CustomerNo) then begin
        Customer.Delete(true);
        Message(CustomerDeletedMsg, CustomerNo);
    end;
end;
```

## Error Handling with Formatted Messages

```al
// Standard error handling pattern
procedure ValidateCustomerData(var Customer: Record Customer)
var
    SalesHeader: Record "Sales Header";
    EntryCount: Integer;
begin
    if Customer."No." = '' then
        Error(CustomerNoRequiredErr);
    
    // Check for dependent records before deletion
    SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
    EntryCount := SalesHeader.Count();
    
    if EntryCount > 0 then
        Error(DeleteBlockedErr, Customer.TableCaption(), Customer."No.", EntryCount);
end;
```

## Progress and Status Messages

```al
// Progress indication with formatted messages
procedure ImportCustomerData()
var
    ImportFile: File;
    TotalRecords: Integer;
    ProcessedRecords: Integer;
    ProgressMsg: Label 'Importing customers: %1 of %2 completed...';
begin
    TotalRecords := GetImportRecordCount();
    
    repeat
        // Process each record
        ProcessedRecords += 1;
        
        // Update progress every 100 records
        if ProcessedRecords mod 100 = 0 then
            Message(ProgressMsg, ProcessedRecords, TotalRecords);
            
    until ProcessedRecords = TotalRecords;
    
    Message(CompletedMsg, ProcessedRecords);
end;
```

## Localization-Ready String Patterns

```al
// Multi-language support with proper text constants
codeunit 50001 "ABC Localization Example"
{
    var
        // English base labels (will be translated)
        WelcomeMsg: Label 'Welcome to %1, %2!';
        DateFormatMsg: Label 'Current date: %1';
        CurrencyFormatMsg: Label 'Amount: %1 %2';
        
    procedure DisplayUserWelcome(CompanyName: Text; UserName: Text)
    begin
        Message(WelcomeMsg, CompanyName, UserName);
    end;
    
    procedure DisplayFormattedDate(CurrentDate: Date)
    begin
        Message(DateFormatMsg, Format(CurrentDate));
    end;
    
    procedure DisplayAmount(Amount: Decimal; CurrencyCode: Code[10])
    begin
        Message(CurrencyFormatMsg, Format(Amount), CurrencyCode);
    end;
}
```

## Advanced Formatting Scenarios

```al
// Complex business scenarios with proper string formatting
procedure GenerateCustomerReport(var Customer: Record Customer; ReportType: Text)
var
    ReportGeneratedMsg: Label 'Report "%1" generated for customer %2. %3 records included.';
    EmptyReportWarningMsg: Label 'No data found for customer %1 in report type %2.';
    ReportErrorMsg: Label 'Error generating report "%1" for customer %2: %3';
    RecordCount: Integer;
    ErrorText: Text;
begin
    Customer.SetRange("Report Type Filter", ReportType);
    RecordCount := Customer.Count();
    
    if RecordCount = 0 then begin
        Message(EmptyReportWarningMsg, Customer."No.", ReportType);
        exit;
    end;
    
    if not TryGenerateReport(Customer, ReportType) then begin
        ErrorText := GetLastErrorText();
        Error(ReportErrorMsg, ReportType, Customer."No.", ErrorText);
    end;
    
    Message(ReportGeneratedMsg, ReportType, Customer."No.", RecordCount);
end;

// Helper procedure for error handling
[TryFunction]
local procedure TryGenerateReport(var Customer: Record Customer; ReportType: Text): Boolean
begin
    // Report generation logic that might fail
    // Return true if successful, false if error occurs
end;
```
