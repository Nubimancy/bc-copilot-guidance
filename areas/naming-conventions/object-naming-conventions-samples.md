# Object Naming Conventions - Code Samples

## Table Naming Examples

```al
// Correct table naming - singular nouns
table 50000 "ABC Customer Rating"
{
    fields
    {
        field(1; "Customer No."; Code[20]) { }
        field(2; "Rating Value"; Integer) { }
        field(3; "Is Active"; Boolean) { }  // Positive assertion
        field(4; "Last Updated"; DateTime) { }
    }
}

// Master data tables
table 50001 "ABC Product Category"
{
    fields
    {
        field(1; "Code"; Code[20]) { }
        field(2; "Description"; Text[100]) { }
        field(3; "Is Default Category"; Boolean) { }  // Positive assertion
    }
}
```

## Field Naming Examples

```al
// Boolean field naming - positive assertions
table 50002 "ABC Sales Configuration"
{
    fields
    {
        // RIGHT - Positive assertions
        field(1; "Allow Discount"; Boolean) { }
        field(2; "Is Tax Exempt"; Boolean) { }
        field(3; "Enable Auto Posting"; Boolean) { }
        
        // WRONG - Negative assertions (avoid these)
        // field(4; "Not Taxable"; Boolean) { }
        // field(5; "Disable Processing"; Boolean) { }
    }
}
```

## Page Naming Examples

```al
// List pages - plural forms
page 50000 "ABC Customer Ratings"
{
    PageType = List;
    SourceTable = "ABC Customer Rating";
    
    layout
    {
        // Layout definition
    }
}

// Card pages - "Card" suffix
page 50001 "ABC Customer Rating Card"
{
    PageType = Card;
    SourceTable = "ABC Customer Rating";
    
    layout
    {
        // Layout definition
    }
}

// Document pages - document type naming
page 50002 "ABC Sales Quote"
{
    PageType = Document;
    SourceTable = "ABC Sales Header";
    
    layout
    {
        // Layout definition
    }
}
```

## Codeunit Naming Examples

```al
// Business logic codeunits - functionality-based naming
codeunit 50000 "ABC Customer Management"
{
    procedure ValidateCustomerRating(CustomerNo: Code[20]): Boolean
    begin
        // Business logic implementation
    end;
}

// Utility codeunits - purpose suffix
codeunit 50001 "ABC Data Migration Mgt"
{
    procedure ImportCustomerData()
    begin
        // Migration utility functions
    end;
}

// Event subscriber codeunits - clear identification
codeunit 50002 "ABC Sales Event Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Name', false, false)]
    local procedure OnAfterValidateCustomerName(var Rec: Record Customer)
    begin
        // Event handling logic
    end;
}
```

## Report Naming Examples

```al
// Document reports - document type naming
report 50000 "ABC Customer Statement"
{
    DefaultLayout = RDLC;
    RDLCLayout = './CustomerStatement.rdlc';
    
    dataset
    {
        // Data definition
    }
}

// Processing reports - "Processing" included
report 50001 "ABC Customer Data Processing"
{
    ProcessingOnly = true;
    
    dataset
    {
        // Processing logic
    }
}

// Analysis reports - purpose-based naming
report 50002 "ABC Sales Analysis by Region"
{
    DefaultLayout = Excel;
    ExcelLayout = './SalesAnalysis.xlsx';
    
    dataset
    {
        // Analysis data
    }
}
```

## Complete Object Set Example

```al
// Related objects with consistent naming
table 50010 "ABC Project Task"
{
    fields
    {
        field(1; "Project No."; Code[20]) { }
        field(2; "Task No."; Code[20]) { }
        field(3; "Description"; Text[100]) { }
        field(4; "Is Completed"; Boolean) { }  // Positive assertion
    }
}

// List page - plural form
page 50010 "ABC Project Tasks"
{
    PageType = List;
    SourceTable = "ABC Project Task";
}

// Card page - "Card" suffix  
page 50011 "ABC Project Task Card"
{
    PageType = Card;
    SourceTable = "ABC Project Task";
}

// Management codeunit - functionality-based
codeunit 50010 "ABC Project Task Management"
{
    procedure CompleteTask(ProjectTaskRec: Record "ABC Project Task")
    begin
        // Task completion logic
    end;
}

// Report - purpose-based naming
report 50010 "ABC Project Task Summary"
{
    DefaultLayout = RDLC;
    dataset
    {
        // Summary data
    }
}
```
