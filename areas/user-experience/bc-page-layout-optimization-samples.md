---
title: "Progressive Form Disclosure Implementation Samples"
description: "Working AL implementations for Business Central page design with FastTab organization, Promoted actions, and performance-aware field management"
area: "user-experience"
difficulty: "intermediate"
object_types: ["Page", "PageExtension", "Codeunit", "Table"]
variable_types: ["Record", "Boolean", "Action", "PagePart"]
tags: ["progressive-disclosure", "page-design", "fasttabs", "promoted-actions", "bc-performance"]
---

# Progressive Form Disclosure Implementation Samples

## FastTab Organization Patterns

### Strategic FastTab Design for Card Pages

```al
// Customer Card with optimized FastTab organization
page 50200 "Custom Customer Card"
{
    Caption = 'Customer Card';
    PageType = Card;
    SourceTable = Customer;
    UsageCategory = None;
    
    layout
    {
        area(content)
        {
            // Primary information - most frequently accessed
            group(General)
            {
                Caption = 'General';
                
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = All;
                }
                
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                
                field("Privacy Blocked"; Rec."Privacy Blocked")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
            }
            
            // Communication information - logically grouped
            group(Communication)
            {
                Caption = 'Communication';
                
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                }
                
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                }
                
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = EMail;
                }
                
                field("Home Page"; Rec."Home Page")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                }
            }
            
            // Business relationship information
            group(Invoicing)
            {
                Caption = 'Invoicing';
                
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                }
                
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                }
                
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                }
            }
            
            // Shipping and logistics
            group(Shipping)
            {
                Caption = 'Shipping';
                
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                }
            }
            
            // Performance-aware: FlowFields in separate FastTab for Cards
            group(Statistics)
            {
                Caption = 'Statistics';
                
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    
                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(false);
                    end;
                }
                
                field("Credit Limit (LCY)"; Rec."Credit Limit (LCY)")
                {
                    ApplicationArea = All;
                    
                    trigger OnValidate()
                    begin
                        if Rec."Credit Limit (LCY)" < Rec."Balance (LCY)" then
                            Message('Credit limit is lower than current balance.');
                    end;
                }
                
                field("Sales (LCY)"; Rec."Sales (LCY)")
                {
                    ApplicationArea = All;
                    
                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(true);
                    end;
                }
            }
        }
        
        // Related information using Page Parts
        area(factboxes)
        {
            part("Customer Statistics FactBox"; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
            
            part("Customer Details FactBox"; "Customer Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
            
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
}
```

### Performance-Optimized List Page Design

```al
// Customer List with performance considerations
page 50201 "Optimized Customer List"
{
    Caption = 'Customer List';
    PageType = List;
    SourceTable = Customer;
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageID = "Customer Card";
    Editable = false;
    
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                // Essential fields only - no FlowFields for performance
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    StyleExpr = CustomerStyleTxt;
                }
                
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    StyleExpr = CustomerStyleTxt;
                }
                
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = EMail;
                }
                
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Visible = false; // Hidden by default, available via personalization
                }
                
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                
                // Base table fields for performance
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
                
                field("Privacy Blocked"; Rec."Privacy Blocked")
                {
                    ApplicationArea = All;
                }
                
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        
        area(factboxes)
        {
            part("Customer Statistics FactBox"; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    
    var
        CustomerStyleTxt: Text;
        
    trigger OnAfterGetRecord()
    begin
        // Conditional styling based on customer status
        CustomerStyleTxt := GetCustomerStyle();
    end;
    
    trigger OnOpenPage()
    begin
        // Apply security filters and performance optimizations
        ApplyFiltersAndOptimizations();
    end;
    
    local procedure GetCustomerStyle(): Text
    begin
        if Rec.Blocked <> Rec.Blocked::" " then
            exit('Unfavorable');
        if Rec."Privacy Blocked" then
            exit('Attention');
        exit('');
    end;
    
    local procedure ApplyFiltersAndOptimizations()
    var
        UserSetup: Record "User Setup";
    begin
        // Apply user-based filtering
        if UserSetup.Get(UserId) then
            if UserSetup."Salespers./Purch. Code" <> '' then
                Rec.SetRange("Salesperson Code", UserSetup."Salespers./Purch. Code");
                
        // Performance optimization: Load only essential fields
        Rec.SetLoadFields("No.", Name, "Phone No.", "E-Mail", City, "Post Code", Blocked, "Privacy Blocked");
    end;
}
```

## Promoted Action Strategy

### Strategic Action Promotion

```al
// Sales Order page with optimized action promotion
page 50202 "Optimized Sales Order"
{
    Caption = 'Sales Order';
    PageType = Document;
    SourceTable = "Sales Header";
    UsageCategory = None;
    
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    StyleExpr = StatusStyleTxt;
                }
            }
        }
    }
    
    actions
    {
        // Primary actions - most frequently used
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                
                action(Release)
                {
                    ApplicationArea = All;
                    Caption = '&Release';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+F9';
                    
                    trigger OnAction()
                    var
                        ReleaseSalesDocument: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDocument.PerformManualRelease(Rec);
                    end;
                }
                
                action(Reopen)
                {
                    ApplicationArea = All;
                    Caption = 'Re&open';
                    Enabled = Rec.Status <> Rec.Status::Open;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    
                    trigger OnAction()
                    var
                        ReleaseSalesDocument: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDocument.PerformManualReopen(Rec);
                    end;
                }
            }
            
            group(Posting)
            {
                Caption = 'Posting';
                
                action("Post")
                {
                    ApplicationArea = All;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    
                    trigger OnAction()
                    begin
                        PostDocument(Codeunit::"Sales-Post (Yes/No)", "Navigate After Posting"::Posted);
                    end;
                }
                
                action("Post and &New")
                {
                    ApplicationArea = All;
                    Caption = 'Post and &New';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Alt+F9';
                    
                    trigger OnAction()
                    begin
                        PostDocument(Codeunit::"Sales-Post (Yes/No)", "Navigate After Posting"::New);
                    end;
                }
                
                action("Post and &Send")
                {
                    ApplicationArea = All;
                    Caption = 'Post and &Send';
                    Ellipsis = true;
                    Image = PostSend;
                    Promoted = true;
                    PromotedCategory = Process;
                    
                    trigger OnAction()
                    begin
                        PostDocument(Codeunit::"Sales-Post + Send", "Navigate After Posting"::Posted);
                    end;
                }
            }
            
            group("Request Approval")
            {
                Caption = 'Request Approval';
                
                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if ApprovalsMgmt.CheckSalesApprovalPossible(Rec) then
                            ApprovalsMgmt.OnSendSalesDocForApproval(Rec);
                    end;
                }
                
                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OnCancelSalesApprovalRequest(Rec);
                    end;
                }
            }
        }
        
        // Secondary actions - available but not promoted
        area(navigation)
        {
            group("&Order")
            {
                Caption = '&Order';
                
                action(Statistics)
                {
                    ApplicationArea = All;
                    Caption = 'Statistics';
                    Image = Statistics;
                    RunObject = Page "Sales Statistics";
                    RunPageLink = "No." = field("No."),
                                  "Document Type" = field("Document Type");
                    ShortCutKey = 'F7';
                }
                
                action(Dimensions)
                {
                    ApplicationArea = All;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    
                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
            }
        }
        
        // Print and send actions
        area(reporting)
        {
            action("Print")
            {
                ApplicationArea = All;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Report;
                
                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesHeader);
                    SalesHeader.PrintRecords(true);
                end;
            }
        }
    }
    
    var
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        StatusStyleTxt: Text;
        
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;
    
    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance();
    end;
    
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        
        case Rec.Status of
            Rec.Status::Open:
                StatusStyleTxt := 'Standard';
            Rec.Status::Released:
                StatusStyleTxt := 'Favorable';
            Rec.Status::"Pending Approval":
                StatusStyleTxt := 'Attention';
            Rec.Status::"Pending Prepayment":
                StatusStyleTxt := 'Unfavorable';
        end;
    end;
    
    local procedure PostDocument(PostingCodeunitID: Integer; Navigate: Enum "Navigate After Posting")
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesHeader.Copy(Rec);
        Codeunit.Run(PostingCodeunitID, SalesHeader);
        
        case Navigate of
            Navigate::Posted:
                begin
                    Rec.Find();
                    CurrPage.Update(false);
                end;
            Navigate::New:
                begin
                    CurrPage.Close();
                    Clear(SalesHeader);
                    SalesHeader.Init();
                    SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                    SalesHeader.Insert(true);
                    Page.Run(Page::"Sales Order", SalesHeader);
                end;
        end;
    end;
}

enum 50200 "Navigate After Posting"
{
    Extensible = true;
    
    value(0; Posted)
    {
        Caption = 'Stay on Posted Document';
    }
    
    value(1; New)
    {
        Caption = 'Create New Document';
    }
}
```

## Performance-Aware Field Management

### SetLoadFields Implementation

```al
// Codeunit for performance-optimized data loading
codeunit 50200 "Performance Page Management"
{
    procedure OptimizeCustomerPageLoading(var Customer: Record Customer)
    begin
        // Load only essential fields for initial page display
        Customer.SetLoadFields("No.", Name, "Phone No.", "E-Mail", Address, City, 
                              "Post Code", "Country/Region Code", Blocked, "Privacy Blocked",
                              "Customer Posting Group", "Gen. Bus. Posting Group", 
                              "Payment Terms Code", "Salesperson Code");
    end;
    
    procedure LoadCustomerStatisticsFields(var Customer: Record Customer)
    begin
        // Load additional fields when statistics FastTab is accessed
        Customer.SetLoadFields("Balance (LCY)", "Credit Limit (LCY)", "Sales (LCY)",
                              "Outstanding Orders (LCY)", "Shipped Not Invoiced (LCY)");
    end;
    
    procedure OptimizeSalesOrderLoading(var SalesHeader: Record "Sales Header")
    begin
        // Essential fields for sales order processing
        SalesHeader.SetLoadFields("No.", "Document Type", "Sell-to Customer No.", 
                                 "Sell-to Customer Name", "Order Date", "Document Date",
                                 "Requested Delivery Date", Status, "Amount Including VAT",
                                 "Outstanding Amount (LCY)", "Shipped Not Invoiced (LCY)");
    end;
    
    procedure LoadSalesOrderDetailFields(var SalesHeader: Record "Sales Header")
    begin
        // Additional fields for detailed view
        SalesHeader.SetLoadFields("Bill-to Customer No.", "Ship-to Code", "Location Code",
                                 "Shipment Method Code", "Payment Terms Code", 
                                 "Currency Code", "Prices Including VAT");
    end;
}

// Page extension demonstrating SetLoadFields usage
pageextension 50200 "Customer List Performance" extends "Customer List"
{
    trigger OnOpenPage()
    var
        PerfMgt: Codeunit "Performance Page Management";
    begin
        PerfMgt.OptimizeCustomerPageLoading(Rec);
    end;
    
    trigger OnAfterGetCurrRecord()
    begin
        // Load additional fields when user navigates to specific record
        LoadAdditionalFieldsOnDemand();
    end;
    
    local procedure LoadAdditionalFieldsOnDemand()
    var
        Customer: Record Customer;
        PerfMgt: Codeunit "Performance Page Management";
    begin
        if Customer.Get(Rec."No.") then begin
            PerfMgt.LoadCustomerStatisticsFields(Customer);
            Rec := Customer;
        end;
    end;
}
```

### Conditional Field Display Implementation

```al
// Page with conditional field visibility
page 50203 "Conditional Sales Order"
{
    Caption = 'Sales Order - Conditional Display';
    PageType = Document;
    SourceTable = "Sales Header";
    
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
            
            // Show shipping information only when order has lines
            group(Shipping)
            {
                Caption = 'Shipping';
                Visible = HasSalesLines;
                
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                }
                
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                }
            }
            
            // Show financial information only for released orders
            group(Financial)
            {
                Caption = 'Financial Information';
                Visible = Rec.Status = Rec.Status::Released;
                
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                
                field("Outstanding Amount (LCY)"; Rec."Outstanding Amount (LCY)")
                {
                    ApplicationArea = All;
                }
            }
            
            // Show approval information when in approval process
            group(Approval)
            {
                Caption = 'Approval Status';
                Visible = Rec.Status = Rec.Status::"Pending Approval";
                
                field("Approval Status"; GetApprovalStatus())
                {
                    ApplicationArea = All;
                    Caption = 'Current Approval Status';
                    Editable = false;
                }
                
                field("Pending Approvals"; GetPendingApprovalCount())
                {
                    ApplicationArea = All;
                    Caption = 'Pending Approvals';
                    Editable = false;
                }
            }
        }
    }
    
    var
        HasSalesLines: Boolean;
        
    trigger OnAfterGetRecord()
    begin
        UpdateFieldVisibility();
    end;
    
    trigger OnAfterGetCurrRecord()
    begin
        UpdateFieldVisibility();
    end;
    
    local procedure UpdateFieldVisibility()
    var
        SalesLine: Record "Sales Line";
    begin
        // Check if order has sales lines
        SalesLine.SetRange("Document Type", Rec."Document Type");
        SalesLine.SetRange("Document No.", Rec."No.");
        HasSalesLines := not SalesLine.IsEmpty();
    end;
    
    local procedure GetApprovalStatus(): Text
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", Database::"Sales Header");
        ApprovalEntry.SetRange("Document No.", Rec."No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        
        if ApprovalEntry.FindFirst() then
            exit(Format(ApprovalEntry.Status))
        else
            exit('No Active Approvals');
    end;
    
    local procedure GetPendingApprovalCount(): Integer
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", Database::"Sales Header");
        ApprovalEntry.SetRange("Document No.", Rec."No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        exit(ApprovalEntry.Count);
    end;
}
```

### Temporary Table Usage for Complex UI Logic

```al
// Page using temporary tables for complex data presentation
page 50204 "Sales Analysis Dashboard"
{
    Caption = 'Sales Analysis Dashboard';
    PageType = List;
    SourceTable = "Sales Analysis Temp";
    SourceTableTemporary = true;
    Editable = false;
    
    layout
    {
        area(content)
        {
            repeater(Analysis)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                
                field("Current Month Sales"; Rec."Current Month Sales")
                {
                    ApplicationArea = All;
                }
                
                field("Previous Month Sales"; Rec."Previous Month Sales")
                {
                    ApplicationArea = All;
                }
                
                field("Sales Growth %"; Rec."Sales Growth %")
                {
                    ApplicationArea = All;
                    StyleExpr = GrowthStyleTxt;
                }
                
                field("Order Count"; Rec."Order Count")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
    actions
    {
        area(processing)
        {
            action(RefreshData)
            {
                ApplicationArea = All;
                Caption = 'Refresh Analysis';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                
                trigger OnAction()
                begin
                    LoadAnalysisData();
                    CurrPage.Update(false);
                end;
            }
        }
    }
    
    var
        GrowthStyleTxt: Text;
        
    trigger OnOpenPage()
    begin
        LoadAnalysisData();
    end;
    
    trigger OnAfterGetRecord()
    begin
        if Rec."Sales Growth %" > 0 then
            GrowthStyleTxt := 'Favorable'
        else if Rec."Sales Growth %" < 0 then
            GrowthStyleTxt := 'Unfavorable'
        else
            GrowthStyleTxt := 'Standard';
    end;
    
    local procedure LoadAnalysisData()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CurrentMonthStart: Date;
        PreviousMonthStart: Date;
        PreviousMonthEnd: Date;
    begin
        Rec.DeleteAll();
        
        CurrentMonthStart := CalcDate('<-CM>', Today);
        PreviousMonthStart := CalcDate('<-1M-CM>', Today);
        PreviousMonthEnd := CalcDate('<CM-1M>', Today);
        
        Customer.SetLoadFields("No.", Name);
        if Customer.FindSet() then
            repeat
                Rec.Init();
                Rec."Customer No." := Customer."No.";
                Rec."Customer Name" := Customer.Name;
                
                // Calculate current month sales
                Rec."Current Month Sales" := CalculateSalesAmount(Customer."No.", CurrentMonthStart, Today);
                
                // Calculate previous month sales
                Rec."Previous Month Sales" := CalculateSalesAmount(Customer."No.", PreviousMonthStart, PreviousMonthEnd);
                
                // Calculate growth percentage
                if Rec."Previous Month Sales" <> 0 then
                    Rec."Sales Growth %" := Round(((Rec."Current Month Sales" - Rec."Previous Month Sales") / Rec."Previous Month Sales") * 100, 0.1)
                else if Rec."Current Month Sales" > 0 then
                    Rec."Sales Growth %" := 100;
                    
                // Count orders
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
                SalesHeader.SetRange("Order Date", CurrentMonthStart, Today);
                Rec."Order Count" := SalesHeader.Count();
                
                if (Rec."Current Month Sales" <> 0) or (Rec."Previous Month Sales" <> 0) then
                    Rec.Insert();
            until Customer.Next() = 0;
    end;
    
    local procedure CalculateSalesAmount(CustomerNo: Code[20]; StartDate: Date; EndDate: Date): Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TotalAmount: Decimal;
    begin
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesInvoiceHeader.SetRange("Posting Date", StartDate, EndDate);
        SalesInvoiceHeader.SetLoadFields("Amount Including VAT");
        
        if SalesInvoiceHeader.FindSet() then
            repeat
                TotalAmount += SalesInvoiceHeader."Amount Including VAT";
            until SalesInvoiceHeader.Next() = 0;
            
        exit(TotalAmount);
    end;
}

// Temporary table for sales analysis
table 50200 "Sales Analysis Temp"
{
    Caption = 'Sales Analysis Temporary';
    TableType = Temporary;
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        
        field(2; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        
        field(3; "Current Month Sales"; Decimal)
        {
            Caption = 'Current Month Sales';
        }
        
        field(4; "Previous Month Sales"; Decimal)
        {
            Caption = 'Previous Month Sales';
        }
        
        field(5; "Sales Growth %"; Decimal)
        {
            Caption = 'Sales Growth %';
            DecimalPlaces = 1 : 1;
        }
        
        field(6; "Order Count"; Integer)
        {
            Caption = 'Order Count';
        }
    }
    
    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
        
        key(Growth; "Sales Growth %")
        {
        }
    }
}
```