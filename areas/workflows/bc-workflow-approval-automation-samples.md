---
title: "BC Workflow Approval Automation Implementation Samples"
description: "Working AL implementations for Business Central workflow approval automation using approval entries, workflow events, and automated approval routing"
area: "workflows"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page", "Enum"]
variable_types: ["Record", "WorkflowStepInstance", "Boolean", "UserId", "DateTime"]
tags: ["bc-workflows", "approval-entries", "workflow-events", "approval-automation", "business-rules"]
---

# BC Workflow Approval Automation Implementation Samples

## Workflow Event Handling

### Purchase Order Approval Event Subscriber

```al
// Event subscriber for purchase order approval workflow
codeunit 50400 "Purchase Approval Event Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSendPurchaseDocForApproval', '', false, false)]
    local procedure OnSendPurchaseDocForApproval(var PurchaseHeader: Record "Purchase Header")
    var
        WorkflowManagement: Codeunit "Workflow Management";
        PurchaseApprovalWorkflow: Codeunit "Purchase Approval Workflow";
    begin
        // Apply business rules before sending for approval
        PurchaseApprovalWorkflow.ApplyBusinessRulesBeforeApproval(PurchaseHeader);
        
        // Send workflow event
        WorkflowManagement.HandleEvent(
            PurchaseApprovalWorkflow.RunWorkflowOnSendPurchaseDocForApprovalCode(),
            PurchaseHeader);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnCancelPurchaseApprovalRequest', '', false, false)]
    local procedure OnCancelPurchaseApprovalRequest(var PurchaseHeader: Record "Purchase Header")
    var
        WorkflowManagement: Codeunit "Workflow Management";
        PurchaseApprovalWorkflow: Codeunit "Purchase Approval Workflow";
    begin
        WorkflowManagement.HandleEvent(
            PurchaseApprovalWorkflow.RunWorkflowOnCancelPurchaseApprovalRequestCode(),
            PurchaseHeader);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenPurchaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        case RecRef.Number of
            Database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchaseHeader);
                    OpenPurchaseDocument(PurchaseHeader);
                    Handled := true;
                end;
        end;
    end;
    
    local procedure OpenPurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseOrder: Page "Purchase Order";
    begin
        PurchaseOrder.SetRecord(PurchaseHeader);
        PurchaseOrder.Run();
    end;
}

// Purchase approval workflow management
codeunit 50401 "Purchase Approval Workflow"
{
    procedure ApplyBusinessRulesBeforeApproval(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        // Validate vendor is not blocked
        if Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then
            if Vendor.Blocked <> Vendor.Blocked::" " then
                Error('Cannot send blocked vendor %1 for approval.', Vendor."No.");
        
        // Validate document has lines
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.IsEmpty then
            Error('Cannot send empty purchase document for approval.');
        
        // Check if approval is required based on amount
        if not ApprovalRequired(PurchaseHeader) then
            Error('Approval is not required for this document amount.');
    end;
    
    procedure ApprovalRequired(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        ApprovalUserSetup: Record "User Setup";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        DocumentAmount: Decimal;
    begin
        PurchCalcDiscByType.ApplyDefaultInvoiceDiscount(0, PurchaseHeader);
        DocumentAmount := PurchaseHeader."Amount Including VAT";
        
        // Check current user's purchase approval limit
        if ApprovalUserSetup.Get(UserId) then
            if (ApprovalUserSetup."Unlimited Purchase Approval") or
               (DocumentAmount <= ApprovalUserSetup."Purchase Amount Approval Limit")
            then
                exit(false);
        
        exit(true);
    end;
    
    procedure RunWorkflowOnSendPurchaseDocForApprovalCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDPURCHASEDOCFORAPPROVAL');
    end;
    
    procedure RunWorkflowOnCancelPurchaseApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELPURCHASEAPPROVALREQUEST');
    end;
    
    procedure RunWorkflowOnApprovePurchaseDocCode(): Code[128]
    begin
        exit('RUNWORKFLOWONAPPROVEPURCHASEDOC');
    end;
    
    procedure RunWorkflowOnRejectPurchaseDocCode(): Code[128]
    begin
        exit('RUNWORKFLOWONREJECTPURCHASEDOC');
    end;
}
```

## Approval Entry Management

### Enhanced Approval Management

```al
// Enhanced approval management with business rules
codeunit 50402 "Enhanced Approval Management"
{
    procedure CreateApprovalRequestsWithRouting(RecRef: RecordRef): Boolean
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ApprovalRouter: Codeunit "Approval Router";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        ApprovalEntryArgument: Record "Approval Entry";
        NextApprovers: List of [Code[50]];
    begin
        // Get approval routing based on document
        NextApprovers := ApprovalRouter.GetNextApprovers(RecRef);
        
        if NextApprovers.Count = 0 then
            Error('No approvers found for this request.');
        
        // Create approval entries for each approver
        exit(CreateMultipleApprovalEntries(RecRef, NextApprovers));
    end;
    
    local procedure CreateMultipleApprovalEntries(RecRef: RecordRef; Approvers: List of [Code[50]]): Boolean
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ApproverUserId: Code[50];
        EntryNo: Integer;
        Success: Boolean;
    begin
        Success := true;
        
        foreach ApproverUserId in Approvers do begin
            Clear(ApprovalEntry);
            ApprovalEntry.Init();
            
            // Get next entry number
            ApprovalEntry.SetRange("Table ID", RecRef.Number);
            if ApprovalEntry.FindLast() then
                EntryNo := ApprovalEntry."Entry No." + 1
            else
                EntryNo := 1;
            
            ApprovalEntry."Entry No." := EntryNo;
            ApprovalEntry."Table ID" := RecRef.Number;
            ApprovalEntry."Document Type" := GetDocumentType(RecRef);
            ApprovalEntry."Document No." := GetDocumentNo(RecRef);
            ApprovalEntry."Sequence No." := GetSequenceNo(ApproverUserId, RecRef);
            ApprovalEntry."Approval Code" := GetApprovalCode(RecRef);
            ApprovalEntry."Sender ID" := UserId;
            ApprovalEntry."Salespers./Purch. Code" := GetSalespersonPurchaserCode(RecRef);
            ApprovalEntry."Approver ID" := ApproverUserId;
            ApprovalEntry.Status := ApprovalEntry.Status::Open;
            ApprovalEntry."Date-Time Sent for Approval" := CurrentDateTime;
            ApprovalEntry."Last Date-Time Modified" := CurrentDateTime;
            ApprovalEntry."Last Modified By User ID" := UserId;
            ApprovalEntry.Amount := GetDocumentAmount(RecRef);
            ApprovalEntry."Amount (LCY)" := GetDocumentAmountLCY(RecRef);
            ApprovalEntry."Currency Code" := GetDocumentCurrencyCode(RecRef);
            ApprovalEntry."Approval Type" := GetApprovalType(RecRef);
            ApprovalEntry."Limit Type" := GetLimitType(RecRef);
            ApprovalEntry."Available Credit Limit (LCY)" := GetAvailableCreditLimit(RecRef);
            
            if not ApprovalEntry.Insert(true) then
                Success := false;
                
            // Send notification to approver
            SendApprovalNotification(ApprovalEntry);
        end;
        
        exit(Success);
    end;
    
    local procedure GetNextApprovers(RecRef: RecordRef): List of [Code[50]]
    var
        ApprovalRouter: Codeunit "Approval Router";
    begin
        // Delegate to approval router for business logic
        exit(ApprovalRouter.GetNextApprovers(RecRef));
    end;
    
    local procedure GetDocumentType(RecRef: RecordRef): Enum "Approval Document Type"
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        case RecRef.Number of
            Database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchaseHeader);
                    case PurchaseHeader."Document Type" of
                        PurchaseHeader."Document Type"::Quote:
                            exit("Approval Document Type"::"Purchase Quote");
                        PurchaseHeader."Document Type"::Order:
                            exit("Approval Document Type"::"Purchase Order");
                        PurchaseHeader."Document Type"::Invoice:
                            exit("Approval Document Type"::"Purchase Invoice");
                        PurchaseHeader."Document Type"::"Credit Memo":
                            exit("Approval Document Type"::"Purchase Credit Memo");
                        PurchaseHeader."Document Type"::"Blanket Order":
                            exit("Approval Document Type"::"Purchase Blanket Order");
                        PurchaseHeader."Document Type"::"Return Order":
                            exit("Approval Document Type"::"Purchase Return Order");
                    end;
                end;
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    case SalesHeader."Document Type" of
                        SalesHeader."Document Type"::Quote:
                            exit("Approval Document Type"::"Sales Quote");
                        SalesHeader."Document Type"::Order:
                            exit("Approval Document Type"::"Sales Order");
                        SalesHeader."Document Type"::Invoice:
                            exit("Approval Document Type"::"Sales Invoice");
                        SalesHeader."Document Type"::"Credit Memo":
                            exit("Approval Document Type"::"Sales Credit Memo");
                        SalesHeader."Document Type"::"Blanket Order":
                            exit("Approval Document Type"::"Sales Blanket Order");
                        SalesHeader."Document Type"::"Return Order":
                            exit("Approval Document Type"::"Sales Return Order");
                    end;
                end;
        end;
        
        exit("Approval Document Type"::" ");
    end;
    
    local procedure GetDocumentNo(RecRef: RecordRef): Code[20]
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field(3); // "No." field is typically field 3
        exit(FieldRef.Value);
    end;
    
    local procedure GetDocumentAmount(RecRef: RecordRef): Decimal
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        case RecRef.Number of
            Database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchaseHeader);
                    PurchaseHeader.CalcFields("Amount Including VAT");
                    exit(PurchaseHeader."Amount Including VAT");
                end;
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    SalesHeader.CalcFields("Amount Including VAT");
                    exit(SalesHeader."Amount Including VAT");
                end;
        end;
        
        exit(0);
    end;
    
    local procedure GetDocumentAmountLCY(RecRef: RecordRef): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Amount: Decimal;
        CurrencyCode: Code[10];
    begin
        Amount := GetDocumentAmount(RecRef);
        CurrencyCode := GetDocumentCurrencyCode(RecRef);
        
        if CurrencyCode = '' then
            exit(Amount);
            
        exit(CurrencyExchangeRate.ExchangeAmtFCYToLCY(
            WorkDate(), CurrencyCode, Amount, 
            CurrencyExchangeRate.ExchangeRate(WorkDate(), CurrencyCode)));
    end;
    
    local procedure GetDocumentCurrencyCode(RecRef: RecordRef): Code[10]
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        case RecRef.Number of
            Database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchaseHeader);
                    exit(PurchaseHeader."Currency Code");
                end;
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    exit(SalesHeader."Currency Code");
                end;
        end;
        
        exit('');
    end;
    
    local procedure SendApprovalNotification(ApprovalEntry: Record "Approval Entry")
    var
        NotificationMgt: Codeunit "Notification Management";
        ApprovalNotification: Notification;
        RecRef: RecordRef;
    begin
        ApprovalNotification.Id := CreateGuid();
        ApprovalNotification.Message := 
            StrSubstNo('You have a new approval request for %1 %2.', 
                       ApprovalEntry."Approval Type", 
                       ApprovalEntry."Document No.");
        ApprovalNotification.Scope := NotificationScope::LocalScope;
        
        // Add approval entry record as context
        RecRef.GetTable(ApprovalEntry);
        ApprovalNotification.SetData('ApprovalEntrySystemId', Format(ApprovalEntry.SystemId));
        ApprovalNotification.SetData('TableId', Format(ApprovalEntry."Table ID"));
        ApprovalNotification.SetData('DocumentNo', ApprovalEntry."Document No.");
        
        // Send to specific approver
        NotificationMgt.SendNotification(ApprovalNotification, ApprovalEntry."Approver ID");
    end;
}
```

## Approval Router with Business Rules

### Intelligent Approval Routing

```al
// Approval router with business rules and hierarchy management
codeunit 50403 "Approval Router"
{
    procedure GetNextApprovers(RecRef: RecordRef): List of [Code[50]]
    var
        ApprovalUserSetup: Record "User Setup";
        Approvers: List of [Code[50]];
        DocumentAmount: Decimal;
        ApprovalType: Text;
    begin
        DocumentAmount := GetDocumentAmountLCY(RecRef);
        ApprovalType := GetApprovalTypeText(RecRef);
        
        // Get approvers based on document type and amount
        case ApprovalType of
            'PURCHASE':
                Approvers := GetPurchaseApprovers(DocumentAmount, RecRef);
            'SALES':
                Approvers := GetSalesApprovers(DocumentAmount, RecRef);
            'GENERAL':
                Approvers := GetGeneralApprovers(DocumentAmount, RecRef);
            else
                Approvers := GetDefaultApprovers(DocumentAmount, RecRef);
        end;
        
        // Apply business rules and filters
        Approvers := ApplyBusinessRuleFilters(Approvers, RecRef);
        
        exit(Approvers);
    end;
    
    local procedure GetPurchaseApprovers(DocumentAmount: Decimal; RecRef: RecordRef): List of [Code[50]]
    var
        ApprovalUserSetup: Record "User Setup";
        PurchaseHeader: Record "Purchase Header";
        Approvers: List of [Code[50]];
        VendorNo: Code[20];
    begin
        RecRef.SetTable(PurchaseHeader);
        VendorNo := PurchaseHeader."Buy-from Vendor No.";
        
        // Check for vendor-specific approvers first
        Approvers := GetVendorSpecificApprovers(VendorNo, DocumentAmount);
        if Approvers.Count > 0 then
            exit(Approvers);
        
        // Get approvers based on purchase amount limits
        ApprovalUserSetup.SetRange("Unlimited Purchase Approval", false);
        ApprovalUserSetup.SetFilter("Purchase Amount Approval Limit", '>=%1', DocumentAmount);
        ApprovalUserSetup.SetCurrentKey("Purchase Amount Approval Limit");
        ApprovalUserSetup.SetAscending("Purchase Amount Approval Limit", true);
        
        if ApprovalUserSetup.FindSet() then
            repeat
                if IsUserAvailable(ApprovalUserSetup."User ID") then
                    Approvers.Add(ApprovalUserSetup."User ID");
            until (ApprovalUserSetup.Next() = 0) or (Approvers.Count >= GetMaxApproversRequired());
        
        // If no specific limit approvers, get unlimited approvers
        if Approvers.Count = 0 then begin
            ApprovalUserSetup.Reset();
            ApprovalUserSetup.SetRange("Unlimited Purchase Approval", true);
            if ApprovalUserSetup.FindSet() then
                repeat
                    if IsUserAvailable(ApprovalUserSetup."User ID") then
                        Approvers.Add(ApprovalUserSetup."User ID");
                until ApprovalUserSetup.Next() = 0;
        end;
        
        exit(Approvers);
    end;
    
    local procedure GetSalesApprovers(DocumentAmount: Decimal; RecRef: RecordRef): List of [Code[50]]
    var
        ApprovalUserSetup: Record "User Setup";
        SalesHeader: Record "Sales Header";
        Approvers: List of [Code[50]];
        CustomerNo: Code[20];
    begin
        RecRef.SetTable(SalesHeader);
        CustomerNo := SalesHeader."Sell-to Customer No.";
        
        // Check for customer-specific approvers first
        Approvers := GetCustomerSpecificApprovers(CustomerNo, DocumentAmount);
        if Approvers.Count > 0 then
            exit(Approvers);
        
        // Get approvers based on sales amount limits
        ApprovalUserSetup.SetRange("Unlimited Sales Approval", false);
        ApprovalUserSetup.SetFilter("Sales Amount Approval Limit", '>=%1', DocumentAmount);
        ApprovalUserSetup.SetCurrentKey("Sales Amount Approval Limit");
        ApprovalUserSetup.SetAscending("Sales Amount Approval Limit", true);
        
        if ApprovalUserSetup.FindSet() then
            repeat
                if IsUserAvailable(ApprovalUserSetup."User ID") then
                    Approvers.Add(ApprovalUserSetup."User ID");
            until (ApprovalUserSetup.Next() = 0) or (Approvers.Count >= GetMaxApproversRequired());
        
        // If no specific limit approvers, get unlimited approvers
        if Approvers.Count = 0 then begin
            ApprovalUserSetup.Reset();
            ApprovalUserSetup.SetRange("Unlimited Sales Approval", true);
            if ApprovalUserSetup.FindSet() then
                repeat
                    if IsUserAvailable(ApprovalUserSetup."User ID") then
                        Approvers.Add(ApprovalUserSetup."User ID");
                until ApprovalUserSetup.Next() = 0;
        end;
        
        exit(Approvers);
    end;
    
    local procedure GetVendorSpecificApprovers(VendorNo: Code[20]; DocumentAmount: Decimal): List of [Code[50]]
    var
        VendorApprovalSetup: Record "Vendor Approval Setup";
        Approvers: List of [Code[50]];
    begin
        // Custom table for vendor-specific approval rules
        VendorApprovalSetup.SetRange("Vendor No.", VendorNo);
        VendorApprovalSetup.SetFilter("Amount Limit", '>=%1|%2', DocumentAmount, 0);
        VendorApprovalSetup.SetCurrentKey("Amount Limit");
        
        if VendorApprovalSetup.FindSet() then
            repeat
                if IsUserAvailable(VendorApprovalSetup."Approver User ID") then
                    Approvers.Add(VendorApprovalSetup."Approver User ID");
            until VendorApprovalSetup.Next() = 0;
            
        exit(Approvers);
    end;
    
    local procedure GetCustomerSpecificApprovers(CustomerNo: Code[20]; DocumentAmount: Decimal): List of [Code[50]]
    var
        CustomerApprovalSetup: Record "Customer Approval Setup";
        Approvers: List of [Code[50]];
    begin
        // Custom table for customer-specific approval rules
        CustomerApprovalSetup.SetRange("Customer No.", CustomerNo);
        CustomerApprovalSetup.SetFilter("Amount Limit", '>=%1|%2', DocumentAmount, 0);
        CustomerApprovalSetup.SetCurrentKey("Amount Limit");
        
        if CustomerApprovalSetup.FindSet() then
            repeat
                if IsUserAvailable(CustomerApprovalSetup."Approver User ID") then
                    Approvers.Add(CustomerApprovalSetup."Approver User ID");
            until CustomerApprovalSetup.Next() = 0;
            
        exit(Approvers);
    end;
    
    local procedure IsUserAvailable(UserId: Code[50]): Boolean
    var
        ApprovalUserSetup: Record "User Setup";
        User: Record User;
    begin
        // Check if user exists and is not disabled
        if not User.Get(UserId) then
            exit(false);
            
        if User.State <> User.State::Enabled then
            exit(false);
        
        // Check if user has substitute during absence
        if ApprovalUserSetup.Get(UserId) then begin
            if ApprovalUserSetup."Substitute" <> '' then begin
                // Check if we're in substitution period
                if (ApprovalUserSetup."Substitute Start Date" <= Today) and
                   (ApprovalUserSetup."Substitute End Date" >= Today)
                then
                    exit(IsUserAvailable(ApprovalUserSetup."Substitute"));
            end;
        end;
        
        exit(true);
    end;
    
    local procedure ApplyBusinessRuleFilters(Approvers: List of [Code[50]]; RecRef: RecordRef): List of [Code[50]]
    var
        FilteredApprovers: List of [Code[50]];
        ApproverUserId: Code[50];
        DimensionFilter: Codeunit "Dimension Approval Filter";
    begin
        // Apply dimension-based filtering
        foreach ApproverUserId in Approvers do begin
            if DimensionFilter.UserCanApproveForDimensions(ApproverUserId, RecRef) then
                FilteredApprovers.Add(ApproverUserId);
        end;
        
        // If no approvers pass dimension filter, return original list
        if FilteredApprovers.Count = 0 then
            exit(Approvers);
            
        exit(FilteredApprovers);
    end;
    
    local procedure GetMaxApproversRequired(): Integer
    begin
        // Business rule: Maximum number of approvers to assign simultaneously
        exit(3);
    end;
    
    local procedure GetDocumentAmountLCY(RecRef: RecordRef): Decimal
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Amount: Decimal;
        CurrencyCode: Code[10];
    begin
        case RecRef.Number of
            Database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchaseHeader);
                    PurchaseHeader.CalcFields("Amount Including VAT");
                    Amount := PurchaseHeader."Amount Including VAT";
                    CurrencyCode := PurchaseHeader."Currency Code";
                end;
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    SalesHeader.CalcFields("Amount Including VAT");
                    Amount := SalesHeader."Amount Including VAT";
                    CurrencyCode := SalesHeader."Currency Code";
                end;
        end;
        
        if CurrencyCode = '' then
            exit(Amount);
            
        exit(CurrencyExchangeRate.ExchangeAmtFCYToLCY(
            WorkDate(), CurrencyCode, Amount,
            CurrencyExchangeRate.ExchangeRate(WorkDate(), CurrencyCode)));
    end;
    
    local procedure GetApprovalTypeText(RecRef: RecordRef): Text
    begin
        case RecRef.Number of
            Database::"Purchase Header":
                exit('PURCHASE');
            Database::"Sales Header":
                exit('SALES');
            Database::"Gen. Journal Line":
                exit('GENERAL');
            else
                exit('OTHER');
        end;
    end;
}
```

## Custom Approval Setup Tables

### Vendor and Customer Specific Approval Rules

```al
// Table for vendor-specific approval setup
table 50400 "Vendor Approval Setup"
{
    Caption = 'Vendor Approval Setup';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        
        field(2; "Approver User ID"; Code[50])
        {
            Caption = 'Approver User ID';
            TableRelation = "User Setup";
        }
        
        field(3; "Amount Limit"; Decimal)
        {
            Caption = 'Amount Limit';
        }
        
        field(4; "Unlimited Approval"; Boolean)
        {
            Caption = 'Unlimited Approval';
        }
        
        field(5; "Approval Priority"; Integer)
        {
            Caption = 'Approval Priority';
        }
        
        field(6; "Effective Start Date"; Date)
        {
            Caption = 'Effective Start Date';
        }
        
        field(7; "Effective End Date"; Date)
        {
            Caption = 'Effective End Date';
        }
    }
    
    keys
    {
        key(PK; "Vendor No.", "Approver User ID")
        {
            Clustered = true;
        }
        
        key(Amount; "Vendor No.", "Amount Limit", "Approval Priority")
        {
        }
    }
    
    trigger OnInsert()
    begin
        ValidateApprovalSetup();
    end;
    
    trigger OnModify()
    begin
        ValidateApprovalSetup();
    end;
    
    local procedure ValidateApprovalSetup()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get("Approver User ID") then
            Error('User %1 does not exist in approval user setup.', "Approver User ID");
            
        if ("Effective Start Date" <> 0D) and ("Effective End Date" <> 0D) then
            if "Effective End Date" < "Effective Start Date" then
                Error('Effective End Date cannot be earlier than Start Date.');
    end;
}

// Table for customer-specific approval setup
table 50401 "Customer Approval Setup"
{
    Caption = 'Customer Approval Setup';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        
        field(2; "Approver User ID"; Code[50])
        {
            Caption = 'Approver User ID';
            TableRelation = "User Setup";
        }
        
        field(3; "Amount Limit"; Decimal)
        {
            Caption = 'Amount Limit';
        }
        
        field(4; "Unlimited Approval"; Boolean)
        {
            Caption = 'Unlimited Approval';
        }
        
        field(5; "Approval Priority"; Integer)
        {
            Caption = 'Approval Priority';
        }
        
        field(6; "Effective Start Date"; Date)
        {
            Caption = 'Effective Start Date';
        }
        
        field(7; "Effective End Date"; Date)
        {
            Caption = 'Effective End Date';
        }
    }
    
    keys
    {
        key(PK; "Customer No.", "Approver User ID")
        {
            Clustered = true;
        }
        
        key(Amount; "Customer No.", "Amount Limit", "Approval Priority")
        {
        }
    }
}

// Dimension-based approval filtering
codeunit 50404 "Dimension Approval Filter"
{
    procedure UserCanApproveForDimensions(UserId: Code[50]; RecRef: RecordRef): Boolean
    var
        UserDimensionSetup: Record "User Dimension Setup";
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DocumentDimensions: Record "Dimension Set Entry";
        DimensionSetId: Integer;
    begin
        // Get document dimension set
        DimensionSetId := GetDocumentDimensionSetId(RecRef);
        if DimensionSetId = 0 then
            exit(true); // No dimensions to filter on
        
        // Check if user has dimension restrictions
        UserDimensionSetup.SetRange("User ID", UserId);
        if UserDimensionSetup.IsEmpty then
            exit(true); // No restrictions for this user
        
        // Validate each dimension restriction
        DocumentDimensions.SetRange("Dimension Set ID", DimensionSetId);
        if DocumentDimensions.FindSet() then
            repeat
                UserDimensionSetup.Reset();
                UserDimensionSetup.SetRange("User ID", UserId);
                UserDimensionSetup.SetRange("Dimension Code", DocumentDimensions."Dimension Code");
                
                if UserDimensionSetup.FindFirst() then begin
                    if UserDimensionSetup."Dimension Value Filter" <> '' then begin
                        UserDimensionSetup.SetFilter("Dimension Value Filter", 
                            UserDimensionSetup."Dimension Value Filter");
                        UserDimensionSetup.SetRange("Dimension Value Code", 
                            DocumentDimensions."Dimension Value Code");
                        if UserDimensionSetup.IsEmpty then
                            exit(false); // User cannot approve for this dimension value
                    end;
                end;
            until DocumentDimensions.Next() = 0;
        
        exit(true);
    end;
    
    local procedure GetDocumentDimensionSetId(RecRef: RecordRef): Integer
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        case RecRef.Number of
            Database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchaseHeader);
                    exit(PurchaseHeader."Dimension Set ID");
                end;
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    exit(SalesHeader."Dimension Set ID");
                end;
        end;
        
        exit(0);
    end;
}

// Table for user dimension approval setup
table 50402 "User Dimension Setup"
{
    Caption = 'User Dimension Setup';
    DataClassification = EndUserIdentifiableInformation;
    
    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = "User Setup";
        }
        
        field(2; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            TableRelation = Dimension;
        }
        
        field(3; "Dimension Value Code"; Code[20])
        {
            Caption = 'Dimension Value Code';
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("Dimension Code"));
        }
        
        field(4; "Dimension Value Filter"; Text[250])
        {
            Caption = 'Dimension Value Filter';
        }
        
        field(5; "Approval Type"; Option)
        {
            Caption = 'Approval Type';
            OptionMembers = "All","Purchase","Sales","General";
        }
    }
    
    keys
    {
        key(PK; "User ID", "Dimension Code", "Dimension Value Code")
        {
            Clustered = true;
        }
    }
}
```