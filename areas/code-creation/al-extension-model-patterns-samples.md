# AL Extension Model Patterns - Code Samples

## Table Extension Examples

### Basic Table Extension with Field Additions

```al
// Extends Customer table with additional fields
tableextension 50100 "Customer Enhancement" extends Customer
{
    fields
    {
        field(50100; "Customer Classification"; Enum "Customer Classification")
        {
            Caption = 'Customer Classification';
            DataClassification = CustomerContent;
            
            trigger OnValidate()
            begin
                UpdateCustomerSettings();
            end;
        }
        
        field(50101; "Preferred Contact Method"; Enum "Contact Method")
        {
            Caption = 'Preferred Contact Method';
            DataClassification = CustomerContent;
        }
        
        field(50102; "Last Interaction Date"; Date)
        {
            Caption = 'Last Interaction Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(50103; "Customer Notes"; Blob)
        {
            Caption = 'Customer Notes';
            DataClassification = CustomerContent;
            SubType = Memo;
        }
    }
    
    /// <summary>
    /// Updates customer settings based on classification
    /// </summary>
    local procedure UpdateCustomerSettings()
    var
        PaymentTerms: Record "Payment Terms";
    begin
        case "Customer Classification" of
            "Customer Classification"::Premium:
                begin
                    if PaymentTerms.Get('NET30') then
                        "Payment Terms Code" := PaymentTerms.Code;
                    "Credit Limit (LCY)" := 100000;
                end;
            "Customer Classification"::Standard:
                begin
                    if PaymentTerms.Get('NET15') then
                        "Payment Terms Code" := PaymentTerms.Code;
                    "Credit Limit (LCY)" := 25000;
                end;
            "Customer Classification"::Basic:
                begin
                    if PaymentTerms.Get('COD') then
                        "Payment Terms Code" := PaymentTerms.Code;
                    "Credit Limit (LCY)" := 5000;
                end;
        end;
    end;
}

// Supporting enum extension
enumextension 50100 "Customer Classification" extends "Customer Classification"
{
    value(50100; Premium)
    {
        Caption = 'Premium Customer';
    }
    value(50101; Standard)
    {
        Caption = 'Standard Customer'; 
    }
    value(50102; Basic)
    {
        Caption = 'Basic Customer';
    }
}

enumextension 50101 "Contact Method" extends "Contact Method"
{
    value(50100; Email)
    {
        Caption = 'Email';
    }
    value(50101; Phone)
    {
        Caption = 'Phone';
    }
    value(50102; SMS)
    {
        Caption = 'SMS';
    }
    value(50103; Mail)
    {
        Caption = 'Mail';
    }
}
```

## Page Extension Examples

### Customer Card Extension with Enhanced UI

```al
pageextension 50100 "Customer Card Enhancement" extends "Customer Card"
{
    layout
    {
        // Add new FastTab for enhanced customer information
        addafter("Payments")
        {
            group("Customer Enhancement")
            {
                Caption = 'Customer Enhancement';
                
                field("Customer Classification"; Rec."Customer Classification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the classification level of this customer';
                    Importance = Promoted;
                    
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                
                field("Preferred Contact Method"; Rec."Preferred Contact Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how this customer prefers to be contacted';
                }
                
                field("Last Interaction Date"; Rec."Last Interaction Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the date of the last interaction with this customer';
                    Importance = Additional;
                }
                
                field("Customer Notes"; CustomerNotesText)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Notes';
                    ToolTip = 'Additional notes about this customer';
                    MultiLine = true;
                    
                    trigger OnValidate()
                    begin
                        SetCustomerNotes(CustomerNotesText);
                    end;
                    
                    trigger OnAssistEdit()
                    begin
                        CustomerNotesText := GetCustomerNotes();
                        ShowCustomerNotesDialog();
                    end;
                }
            }
        }
        
        // Modify existing field properties
        modify("Customer Posting Group")
        {
            Importance = Promoted;
            ShowMandatory = true;
        }
    }
    
    actions
    {
        addafter("&Customer")
        {
            group("Customer Enhancement Actions")
            {
                Caption = 'Customer Enhancement';
                Image = Customer;
                
                action("Update Customer Classification")
                {
                    ApplicationArea = All;
                    Caption = 'Update Classification';
                    ToolTip = 'Updates customer classification based on sales history';
                    Image = UpdateDescription;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    
                    trigger OnAction()
                    var
                        CustomerClassificationMgt: Codeunit "Customer Classification Mgt";
                    begin
                        CustomerClassificationMgt.UpdateClassification(Rec);
                        CurrPage.Update(false);
                        Message('Customer classification updated successfully');
                    end;
                }
                
                action("Customer Interaction History")
                {
                    ApplicationArea = All;
                    Caption = 'Interaction History';
                    ToolTip = 'View complete interaction history for this customer';
                    Image = History;
                    Promoted = true;
                    PromotedCategory = Related;
                    RunObject = Page "Customer Interaction History";
                    RunPageLink = "Customer No." = field("No.");
                }
            }
        }
    }
    
    var
        CustomerNotesText: Text;
    
    trigger OnAfterGetCurrRecord()
    begin
        CustomerNotesText := GetCustomerNotes();
    end;
    
    /// <summary>
    /// Gets customer notes from blob field
    /// </summary>
    /// <returns>Customer notes as text</returns>
    local procedure GetCustomerNotes(): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        NotesText: Text;
    begin
        Rec.CalcFields("Customer Notes");
        if not Rec."Customer Notes".HasValue() then
            exit('');
            
        TempBlob.FromRecord(Rec, Rec.FieldNo("Customer Notes"));
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(NotesText);
        exit(NotesText);
    end;
    
    /// <summary>
    /// Sets customer notes in blob field
    /// </summary>
    /// <param name="NotesText">Text to store in notes field</param>
    local procedure SetCustomerNotes(NotesText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NotesText);
        TempBlob.ToRecord(Rec, Rec.FieldNo("Customer Notes"));
    end;
    
    /// <summary>
    /// Shows dialog for editing customer notes
    /// </summary>
    local procedure ShowCustomerNotesDialog()
    var
        CustomerNotesDialog: Page "Customer Notes Dialog";
    begin
        CustomerNotesDialog.SetCustomerNotes(CustomerNotesText);
        CustomerNotesDialog.SetCustomerInfo(Rec."No.", Rec.Name);
        if CustomerNotesDialog.RunModal() = Action::OK then begin
            CustomerNotesText := CustomerNotesDialog.GetCustomerNotes();
            SetCustomerNotes(CustomerNotesText);
            CurrPage.Update(false);
        end;
    end;
}
```

### List Page Extension with Additional Columns

```al
pageextension 50101 "Customer List Enhancement" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field("Customer Classification"; Rec."Customer Classification")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the classification level of this customer';
                
                StyleExpr = ClassificationStyleExpr;
            }
            
            field("Last Interaction Date"; Rec."Last Interaction Date")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the date of the last interaction with this customer';
            }
        }
    }
    
    actions
    {
        addafter("New")
        {
            action("Bulk Update Classification")
            {
                ApplicationArea = All;
                Caption = 'Bulk Update Classification';
                ToolTip = 'Updates classification for all visible customers';
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                
                trigger OnAction()
                var
                    Customer: Record Customer;
                    CustomerClassificationMgt: Codeunit "Customer Classification Mgt";
                    ProcessedCount: Integer;
                begin
                    CurrPage.SetSelectionFilter(Customer);
                    if Customer.FindSet() then begin
                        repeat
                            CustomerClassificationMgt.UpdateClassification(Customer);
                            ProcessedCount += 1;
                        until Customer.Next() = 0;
                        Message('Updated classification for %1 customers', ProcessedCount);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
    
    var
        ClassificationStyleExpr: Text;
    
    trigger OnAfterGetRecord()
    begin
        // Set style based on classification
        case Rec."Customer Classification" of
            Rec."Customer Classification"::Premium:
                ClassificationStyleExpr := 'Favorable';
            Rec."Customer Classification"::Standard:
                ClassificationStyleExpr := 'Standard';
            Rec."Customer Classification"::Basic:
                ClassificationStyleExpr := 'Unfavorable';
            else
                ClassificationStyleExpr := '';
        end;
    end;
}
```

## Report Extension Example

### Customer Report Enhancement

```al
reportextension 50100 "Customer List Enhancement" extends "Customer - List"
{
    dataset
    {
        add(Customer)
        {
            column(CustomerClassification; "Customer Classification")
            {
                IncludeCaption = true;
            }
            column(PreferredContactMethod; "Preferred Contact Method")
            {
                IncludeCaption = true;
            }
            column(LastInteractionDate; "Last Interaction Date")
            {
                IncludeCaption = true;
            }
        }
    }
    
    requestpage
    {
        layout
        {
            addafter(Customer)
            {
                group("Enhancement Options")
                {
                    Caption = 'Enhancement Options';
                    
                    field(IncludeClassification; IncludeClassificationDetails)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Classification Details';
                        ToolTip = 'Include customer classification information in the report';
                    }
                    
                    field(FilterByClassification; FilterClassification)
                    {
                        ApplicationArea = All;
                        Caption = 'Filter by Classification';
                        ToolTip = 'Filter customers by specific classification';
                    }
                }
            }
        }
        
        trigger OnOpenPage()
        begin
            IncludeClassificationDetails := true;
        end;
    }
    
    rendering
    {
        layout("CustomerListEnhanced")
        {
            Type = RDLC;
            LayoutFile = './Reports/CustomerListEnhanced.rdl';
            Caption = 'Customer List (Enhanced)';
            Summary = 'Enhanced customer list with classification and contact preferences';
        }
    }
    
    var
        IncludeClassificationDetails: Boolean;
        FilterClassification: Enum "Customer Classification";
    
    trigger OnPreReport()
    begin
        if FilterClassification <> FilterClassification::" " then
            Customer.SetRange("Customer Classification", FilterClassification);
    end;
}
```

## Extension Management Patterns

### Extension Dependencies and Version Management

```json
// app.json with proper dependency management
{
    "id": "12345678-1234-1234-1234-123456789012",
    "name": "Customer Enhancement Suite",
    "publisher": "Your Company",
    "version": "2.1.0.0",
    "brief": "Enhanced customer management capabilities",
    "description": "Adds customer classification, interaction tracking, and enhanced reporting",
    "privacyStatement": "https://yourcompany.com/privacy",
    "EULA": "https://yourcompany.com/eula",
    "help": "https://yourcompany.com/help/customer-enhancement",
    "url": "https://yourcompany.com",
    "logo": "logo.png",
    "dependencies": [
        {
            "id": "63ca2fa4-4f03-4f2b-a480-172fef340d3f",
            "publisher": "Microsoft",
            "name": "System Application",
            "version": "19.0.0.0"
        },
        {
            "id": "437dbf0e-84ff-417a-965d-ed2bb9650972",
            "publisher": "Microsoft",
            "name": "Base Application", 
            "version": "19.0.0.0"
        }
    ],
    "screenshots": [
        "screenshots/customer-card.png",
        "screenshots/customer-list.png"
    ],
    "platform": "19.0.0.0",
    "application": "19.0.0.0",
    "idRanges": [
        {
            "from": 50100,
            "to": 50199
        }
    ],
    "resourceExposurePolicy": {
        "allowDebugging": true,
        "allowDownloadingSource": false,
        "includeSourceInSymbolFile": false
    },
    "runtime": "9.0",
    "features": [
        "NoImplicitWith",
        "TranslationFile"
    ]
}
```

### Extension Health Monitoring

```al
// Extension health and monitoring codeunit
codeunit 50199 "Extension Health Monitor"
{
    /// <summary>
    /// Validates extension health and configuration
    /// </summary>
    procedure ValidateExtensionHealth(): Boolean
    var
        HealthIssues: List of [Text];
        IsHealthy: Boolean;
    begin
        IsHealthy := true;
        
        // Validate table extensions
        if not ValidateTableExtensions(HealthIssues) then
            IsHealthy := false;
            
        // Validate page extensions
        if not ValidatePageExtensions(HealthIssues) then
            IsHealthy := false;
            
        // Validate business logic
        if not ValidateBusinessLogic(HealthIssues) then
            IsHealthy := false;
            
        // Report any issues found
        if not IsHealthy then
            ReportHealthIssues(HealthIssues);
            
        exit(IsHealthy);
    end;
    
    local procedure ValidateTableExtensions(var HealthIssues: List of [Text]): Boolean
    var
        Customer: Record Customer;
        IsValid: Boolean;
    begin
        IsValid := true;
        
        // Test that custom fields are accessible
        if not Customer.ReadPermission() then begin
            HealthIssues.Add('Customer table permissions insufficient');
            IsValid := false;
        end;
        
        // Test field access
        Customer.Init();
        try
            Customer."Customer Classification" := Customer."Customer Classification"::Premium;
        except
            HealthIssues.Add('Customer Classification field not accessible');
            IsValid := false;
        end;
        
        exit(IsValid);
    end;
    
    local procedure ValidatePageExtensions(var HealthIssues: List of [Text]): Boolean
    var
        IsValid: Boolean;
    begin
        IsValid := true;
        
        // Validate that page extensions are working
        // Implementation would test page functionality
        
        exit(IsValid);
    end;
    
    local procedure ValidateBusinessLogic(var HealthIssues: List of [Text]): Boolean
    var
        CustomerClassificationMgt: Codeunit "Customer Classification Mgt";
        TestCustomer: Record Customer;
        IsValid: Boolean;
    begin
        IsValid := true;
        
        // Test business logic components
        try
            TestCustomer.Init();
            CustomerClassificationMgt.UpdateClassification(TestCustomer);
        except
            HealthIssues.Add('Customer classification business logic error');
            IsValid := false;
        end;
        
        exit(IsValid);
    end;
    
    local procedure ReportHealthIssues(HealthIssues: List of [Text])
    var
        Issue: Text;
        AllIssues: Text;
    begin
        foreach Issue in HealthIssues do
            AllIssues += Issue + '\';
            
        Error('Extension health validation failed:\%1', AllIssues);
    end;
}
```
