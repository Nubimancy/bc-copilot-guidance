# Localization Text Patterns - Code Samples

## Standard Label Declaration Patterns

```al
// Comprehensive label declarations for localization
codeunit 50000 "ABC Customer Management"
{
    var
        // Success and information messages
        CustomerCreatedMsg: Label 'Customer %1 has been created successfully.';
        CustomerUpdatedMsg: Label 'Customer %1 has been updated with new information.';
        ProcessingMsg: Label 'Processing %1 customer records...';
        ProcessCompletedMsg: Label 'Processing completed. %1 records updated, %2 records failed.';
        
        // Error messages
        CustomerNotFoundErr: Label 'Customer %1 does not exist in the system.';
        InvalidDataErr: Label 'Invalid data provided: %1';
        AccessDeniedErr: Label 'You do not have permission to modify customer %1.';
        ValidationFailedErr: Label 'Validation failed for field %1: %2';
        
        // Confirmation questions
        DeleteCustomerQst: Label 'Do you want to delete customer %1?\\This action cannot be undone.';
        UpdatePricingQst: Label 'This will update pricing for %1 customers. Do you want to continue?';
        ApproveChangesQst: Label 'Do you want to approve the changes for customer %1?';
        
        // Warning messages
        CreditLimitWarningMsg: Label 'Customer %1 is approaching credit limit. Current balance: %2, Credit limit: %3.';
        DataIncompleteWarningMsg: Label 'Customer %1 has incomplete data. Missing: %2.';
```

## Multi-Parameter Label Examples

```al
// Complex labels with multiple parameters for rich localization
var
    DetailedProcessingMsg: Label 'Processing customers in %1 region. Progress: %2 of %3 completed (%4%).';
    TransactionSummaryMsg: Label 'Transaction completed for %1:\\Amount: %2 %3\\Date: %4\\Reference: %5';
    ValidationSummaryErr: Label 'Validation failed for %1:\\Field: %2\\Value: %3\\Error: %4';
    
procedure ShowDetailedProgress(Region: Text; Current: Integer; Total: Integer)
var
    ProgressPercentage: Decimal;
begin
    if Total > 0 then
        ProgressPercentage := Round(Current / Total * 100, 1);
    
    Message(DetailedProcessingMsg, Region, Current, Total, ProgressPercentage);
end;

procedure ShowTransactionSummary(CustomerName: Text; Amount: Decimal; CurrencyCode: Code[10]; TransDate: Date; Reference: Code[20])
begin
    Message(TransactionSummaryMsg, CustomerName, Amount, CurrencyCode, TransDate, Reference);
end;
```

## Date and Number Formatting for Localization

```al
// Localization-friendly date and number formatting
var
    DateRangeMsg: Label 'Analyzing data from %1 to %2';
    AmountRangeMsg: Label 'Amount range: %1 to %2 in %3';
    
procedure DisplayDateRange(StartDate: Date; EndDate: Date)
begin
    // Format() function automatically handles regional date formatting
    Message(DateRangeMsg, Format(StartDate), Format(EndDate));
end;

procedure DisplayAmountRange(MinAmount: Decimal; MaxAmount: Decimal; CurrencyCode: Code[10])
begin
    // Format() with currency code handles regional number formatting
    Message(AmountRangeMsg, 
        Format(MinAmount, 0, '<Precision,2><Standard Format,0>'),
        Format(MaxAmount, 0, '<Precision,2><Standard Format,0>'),
        CurrencyCode);
end;
```

## Status and Enum Localization

```al
// Localizable status messages using enums
enum 50000 "Processing Status"
{
    Extensible = true;
    
    value(0; " ") { Caption = ' '; }
    value(1; "In Progress") { Caption = 'In Progress'; }
    value(2; "Completed") { Caption = 'Completed'; }
    value(3; "Failed") { Caption = 'Failed'; }
    value(4; "Cancelled") { Caption = 'Cancelled'; }
}

// Status-related messages that work with localized enum captions
var
    StatusChangeMsg: Label 'Status changed from %1 to %2 for customer %3';
    StatusValidationErr: Label 'Cannot change status from %1 to %2. Invalid transition.';
    
procedure UpdateProcessingStatus(CustomerNo: Code[20]; OldStatus: Enum "Processing Status"; NewStatus: Enum "Processing Status")
begin
    // Enum captions are automatically localized
    Message(StatusChangeMsg, Format(OldStatus), Format(NewStatus), CustomerNo);
end;
```

## Error Context with Localization

```al
// Comprehensive error reporting with localized context
var
    FieldValidationErr: Label 'Field validation error in %1:\\Field: %2\\Current Value: %3\\Expected: %4\\Reason: %5';
    SystemErrorErr: Label 'A system error occurred while processing %1:\\Error Code: %2\\Details: %3\\Contact support if this continues.';
    BusinessRuleViolationErr: Label 'Business rule violation for %1:\\Rule: %2\\Current State: %3\\Required State: %4';
    
procedure ReportFieldValidationError(TableName: Text; FieldName: Text; CurrentValue: Text; ExpectedValue: Text; Reason: Text)
begin
    Error(FieldValidationErr, TableName, FieldName, CurrentValue, ExpectedValue, Reason);
end;

procedure ReportSystemError(Context: Text; ErrorCode: Text; ErrorDetails: Text)
begin
    Error(SystemErrorErr, Context, ErrorCode, ErrorDetails);
end;
```

## User Interface Localization

```al
// Page captions and tooltips for localization
page 50000 "ABC Customer Processing"
{
    PageType = Card;
    Caption = 'Customer Processing Center';
    
    layout
    {
        area(Content)
        {
            group(Processing)
            {
                Caption = 'Processing Options';
                
                field(RegionFilter; RegionFilter)
                {
                    Caption = 'Region Filter';
                    ToolTip = 'Specifies the region to filter customers for processing. Leave blank to process all regions.';
                }
                
                field(DateFilter; DateFilter)
                {
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the date range for customer data processing. Use standard Business Central date filter syntax.';
                }
            }
            
            group(Results)
            {
                Caption = 'Processing Results';
                
                field(ProcessedCount; ProcessedCount)
                {
                    Caption = 'Records Processed';
                    ToolTip = 'Specifies the number of customer records that have been successfully processed.';
                    Editable = false;
                }
                
                field(ErrorCount; ErrorCount)
                {
                    Caption = 'Errors Encountered';
                    ToolTip = 'Specifies the number of errors that occurred during processing. Click the Process Log action to view details.';
                    Editable = false;
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(StartProcessing)
            {
                Caption = 'Start Processing';
                ToolTip = 'Begins the customer data processing operation using the specified filters and options.';
                Image = Start;
                
                trigger OnAction()
                begin
                    StartCustomerProcessing();
                end;
            }
        }
    }
}
```

## Cultural-Sensitive Formatting

```al
// Cultural and regional formatting considerations
var
    AddressFormatMsg: Label 'Customer Address:\\%1\\%2\\%3, %4 %5\\%6';
    PhoneFormatMsg: Label 'Phone: %1\\Mobile: %2\\Fax: %3';
    
procedure FormatCustomerAddress(Customer: Record Customer): Text
var
    FormattedAddress: Text;
begin
    // Address formatting that works across different regional formats
    FormattedAddress := StrSubstNo(AddressFormatMsg,
        Customer.Name,
        Customer.Address,
        Customer.City,
        Customer.County,
        Customer."Post Code",
        Customer."Country/Region Code");
    
    exit(FormattedAddress);
end;

// Currency and number formatting for different locales
procedure FormatFinancialSummary(Customer: Record Customer)
var
    FinancialSummaryMsg: Label 'Financial Summary for %1:\\Credit Limit: %2\\Current Balance: %3\\Available Credit: %4\\Last Payment: %5 on %6';
    AvailableCredit: Decimal;
begin
    Customer.CalcFields("Balance (LCY)");
    AvailableCredit := Customer."Credit Limit (LCY)" - Customer."Balance (LCY)";
    
    Message(FinancialSummaryMsg,
        Customer.Name,
        Format(Customer."Credit Limit (LCY)", 0, '<Precision,2><Standard Format,0>'),
        Format(Customer."Balance (LCY)", 0, '<Precision,2><Standard Format,0>'),
        Format(AvailableCredit, 0, '<Precision,2><Standard Format,0>'),
        Format(Customer."Last Payment Amount", 0, '<Precision,2><Standard Format,0>'),
        Format(Customer."Last Payment Date"));
end;
```

## Report and Export Localization

```al
// Localized report headers and content
var
    ReportHeaderTxt: Label 'Customer Analysis Report';
    ReportPeriodTxt: Label 'Report Period: %1 to %2';
    ReportGeneratedTxt: Label 'Generated on %1 at %2 by %3';
    NoDataFoundTxt: Label 'No data found for the specified criteria.';
    
procedure GenerateLocalizedReport(StartDate: Date; EndDate: Date)
var
    ReportStream: OutStream;
    ReportContent: Text;
begin
    // Build localized report content
    ReportContent := ReportHeaderTxt + '\\' +
        StrSubstNo(ReportPeriodTxt, Format(StartDate), Format(EndDate)) + '\\' +
        StrSubstNo(ReportGeneratedTxt, Format(Today()), Format(Time()), UserId()) + '\\\\';
    
    // Add report data...
    if ReportContent = '' then
        ReportContent += NoDataFoundTxt;
    
    // Output report with localized content
end;
```
