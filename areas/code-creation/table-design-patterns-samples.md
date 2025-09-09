---
title: "Table Design Patterns - Code Samples"
description: "Complete code examples for implementing proven table design patterns in AL"
area: "code-creation"
difficulty: "intermediate"
object_types: ["Table"]
variable_types: ["Record", ]
tags: ["design-patterns", "samples", "table-structure", "best-practices"]
---

# Table Design Patterns - Code Samples

## Master-Detail Pattern Implementation

```al
// Master table
table 50201 "Sales Quote Header Ext"
{
    Caption = 'Sales Quote Header Extension';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            DataClassification = CustomerContent;
        }
        
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
        }
        
        field(10; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Quote Line Ext"."Line Amount" where("Quote No." = field("Quote No.")));
        }
        
        field(11; "Line Count"; Integer)
        {
            Caption = 'Line Count';
            FieldClass = FlowField;
            CalcFormula = count("Sales Quote Line Ext" where("Quote No." = field("Quote No.")));
        }
    }
    
    keys
    {
        key(PK; "Quote No.")
        {
            Clustered = true;
        }
    }
    
    trigger OnDelete()
    var
        SalesQuoteLineExt: Record "Sales Quote Line Ext";
    begin
        // Cascade delete pattern
        SalesQuoteLineExt.SetRange("Quote No.", "Quote No.");
        SalesQuoteLineExt.DeleteAll(true);
    end;
}

// Detail table
table 50202 "Sales Quote Line Ext"
{
    Caption = 'Sales Quote Line Extension';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            TableRelation = "Sales Quote Header Ext"."Quote No.";
            DataClassification = CustomerContent;
        }
        
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        
        field(11; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            
            trigger OnValidate()
            begin
                UpdateHeaderTotals();
            end;
        }
    }
    
    keys
    {
        key(PK; "Quote No.", "Line No.")
        {
            Clustered = true;
        }
    }
    
    local procedure UpdateHeaderTotals()
    var
        SalesQuoteHeaderExt: Record "Sales Quote Header Ext";
    begin
        if SalesQuoteHeaderExt.Get("Quote No.") then begin
            SalesQuoteHeaderExt.CalcFields("Total Amount", "Line Count");
            SalesQuoteHeaderExt.Modify();
        end;
    end;
}
```

## Audit Trail Pattern

```al
table 50203 "Document Status History"
{
    Caption = 'Document Status History';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;
        }
        
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        
        field(10; "Old Status"; Text[50])
        {
            Caption = 'Old Status';
            DataClassification = CustomerContent;
        }
        
        field(11; "New Status"; Text[50])
        {
            Caption = 'New Status';
            DataClassification = CustomerContent;
        }
        
        field(20; "Changed DateTime"; DateTime)
        {
            Caption = 'Changed Date/Time';
            DataClassification = SystemMetadata;
        }
        
        field(21; "Changed By"; Code[50])
        {
            Caption = 'Changed By';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;
        }
        
        field(22; "Change Reason"; Text[250])
        {
            Caption = 'Change Reason';
            DataClassification = CustomerContent;
        }
    }
    
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        
        key(Document; "Table ID", "Document No.", "Changed DateTime")
        {
            // For document history queries
        }
    }
}

// Usage example in a main table
table 50204 "Purchase Request"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        
        field(10; Status; Enum "Purchase Request Status")
        {
            Caption = 'Status';
            
            trigger OnValidate()
            begin
                LogStatusChange();
            end;
        }
    }
    
    local procedure LogStatusChange()
    var
        DocumentStatusHistory: Record "Document Status History";
    begin
        if xRec.Status = Status then
            exit;
            
        DocumentStatusHistory.Init();
        DocumentStatusHistory."Table ID" := Database::"Purchase Request";
        DocumentStatusHistory."Document No." := "No.";
        DocumentStatusHistory."Old Status" := Format(xRec.Status);
        DocumentStatusHistory."New Status" := Format(Status);
        DocumentStatusHistory."Changed DateTime" := CurrentDateTime;
        DocumentStatusHistory."Changed By" := UserId;
        DocumentStatusHistory.Insert();
    end;
}
```

## Configuration/Setup Pattern

```al
table 50205 "Application Settings"
{
    Caption = 'Application Settings';
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        
        // Email settings
        field(10; "SMTP Server"; Text[250])
        {
            Caption = 'SMTP Server';
            DataClassification = OrganizationIdentifiableInformation;
        }
        
        field(11; "SMTP Port"; Integer)
        {
            Caption = 'SMTP Port';
            InitValue = 587;
            DataClassification = OrganizationIdentifiableInformation;
        }
        
        // Business rules
        field(20; "Max Discount %"; Decimal)
        {
            Caption = 'Maximum Discount %';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            MaxValue = 100;
            InitValue = 10;
            DataClassification = SystemMetadata;
        }
        
        field(21; "Approval Required Amount"; Decimal)
        {
            Caption = 'Approval Required Amount';
            DataClassification = SystemMetadata;
        }
        
        // Feature toggles
        field(30; "Enable Advanced Features"; Boolean)
        {
            Caption = 'Enable Advanced Features';
            DataClassification = SystemMetadata;
        }
    }
    
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
    
    // Singleton pattern implementation
    procedure GetInstance(): Record "Application Settings"
    var
        ApplicationSettings: Record "Application Settings";
    begin
        if not ApplicationSettings.Get() then begin
            ApplicationSettings.Init();
            ApplicationSettings."Primary Key" := '';
            ApplicationSettings.Insert();
        end;
        exit(ApplicationSettings);
    end;
    
    procedure GetMaxDiscountPercent(): Decimal
    var
        ApplicationSettings: Record "Application Settings";
    begin
        ApplicationSettings := GetInstance();
        exit(ApplicationSettings."Max Discount %");
    end;
    
    procedure IsAdvancedFeaturesEnabled(): Boolean
    var
        ApplicationSettings: Record "Application Settings";
    begin
        ApplicationSettings := GetInstance();
        exit(ApplicationSettings."Enable Advanced Features");
    end;
}
```

## Document Numbering Pattern

```al
table 50206 "Number Series Line Ext"
{
    Caption = 'Number Series Line Extension';
    
    fields
    {
        field(1; "Series Code"; Code[20])
        {
            Caption = 'Series Code';
            TableRelation = "No. Series";
        }
        
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        
        field(11; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        
        field(20; "Starting No."; Code[20])
        {
            Caption = 'Starting No.';
        }
        
        field(21; "Ending No."; Code[20])
        {
            Caption = 'Ending No.';
        }
        
        field(22; "Last No. Used"; Code[20])
        {
            Caption = 'Last No. Used';
        }
    }
    
    keys
    {
        key(PK; "Series Code", "Line No.")
        {
            Clustered = true;
        }
        
        key(Date; "Series Code", "Starting Date")
        {
            // For date range lookups
        }
    }
    
    procedure GetNextNo(SeriesCode: Code[20]): Code[20]
    var
        NumberSeriesLineExt: Record "Number Series Line Ext";
        NextNo: Code[20];
    begin
        NumberSeriesLineExt.SetRange("Series Code", SeriesCode);
        NumberSeriesLineExt.SetRange("Starting Date", 0D, Today);
        NumberSeriesLineExt.SetFilter("Ending Date", '%1|>=%2', 0D, Today);
        
        if NumberSeriesLineExt.FindLast() then begin
            NextNo := IncStr(NumberSeriesLineExt."Last No. Used");
            NumberSeriesLineExt."Last No. Used" := NextNo;
            NumberSeriesLineExt.Modify();
            exit(NextNo);
        end;
        
        Error('No valid number series found for %1', SeriesCode);
    end;
}
```

## Related Topics
- [Table Design Patterns](table-design-patterns.md)
- [Table Field Validation](table-field-validation.md)
- [Table Business Rules](table-business-rules.md)
