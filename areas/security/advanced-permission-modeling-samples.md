---
title: "Advanced Permission Modeling Implementation Samples"
description: "Working AL implementations for permission sets, security filters, and role-based access control patterns in Business Central"
area: "security"
difficulty: "advanced"
object_types: ["Codeunit", "Table", "Page", "Enum", "PermissionSet", "XmlPort"]
variable_types: ["Record", "PermissionSet", "Boolean", "UserId", "SecurityFilter", "TableFilter"]
tags: ["permission-modeling", "rbac", "security-filters", "permission-sets", "access-control"]
---

# Advanced Permission Modeling Implementation Samples

## Permission Set Creation Patterns

### Role-Based Permission Set Structure

```al
// Permission set for Sales Representative role
permissionset 50100 "SALESREP"
{
    Assignable = true;
    Caption = 'Sales Representative';
    
    Permissions = 
        tabledata Customer = RIMD,
        tabledata "Customer Ledger Entry" = R,
        tabledata "Sales Header" = RIMD,
        tabledata "Sales Line" = RIMD,
        tabledata Item = R,
        tabledata "Item Ledger Entry" = R,
        page "Customer Card" = X,
        page "Customer List" = X,
        page "Sales Quote" = X,
        page "Sales Order" = X,
        page "Item List" = X,
        report "Customer - Top 10 List" = X;
}

// Hierarchical permission with base permissions
permissionset 50101 "SALESMANAGER"
{
    Assignable = true;
    Caption = 'Sales Manager';
    IncludedPermissionSets = "SALESREP";
    
    Permissions = 
        tabledata "Sales & Receivables Setup" = RIM,
        tabledata "Customer Price Group" = RIMD,
        tabledata "Sales Price" = RIMD,
        page "Sales & Receivables Setup" = X,
        page "Customer Price Groups" = X,
        page "Sales Prices" = X,
        report "Sales Statistics" = X;
}

// Extension permission set for custom functionality
permissionset 50102 "SALESEXTENSION"
{
    Assignable = false;
    Caption = 'Sales Extension Objects';
    
    Permissions = 
        tabledata "Custom Sales Analysis" = RIMD,
        tabledata "Sales Commission Setup" = RM,
        page "Sales Analysis Card" = X,
        page "Commission Setup" = X,
        codeunit "Sales Commission Calc" = X;
}
```

### Permission Set Composition Pattern

```al
// Base data access permission
permissionset 50110 "BASEDATA"
{
    Assignable = false;
    Caption = 'Base Data Access';
    
    Permissions = 
        tabledata "Company Information" = R,
        tabledata "General Ledger Setup" = R,
        tabledata "User Setup" = R,
        tabledata "Sales & Receivables Setup" = R,
        tabledata "Purchases & Payables Setup" = R;
}

// Document creation permissions
permissionset 50111 "DOCCREATION"
{
    Assignable = false;
    Caption = 'Document Creation';
    
    Permissions = 
        tabledata "No. Series" = R,
        tabledata "No. Series Line" = R,
        codeunit "No. Series Management" = X,
        codeunit "Document Print" = X;
}

// Composed role permission set
permissionset 50112 "ORDERPROCESSOR"
{
    Assignable = true;
    Caption = 'Order Processor';
    IncludedPermissionSets = "BASEDATA", "DOCCREATION";
    
    Permissions = 
        tabledata "Sales Header" = RIMD,
        tabledata "Sales Line" = RIMD,
        page "Sales Order" = X,
        page "Sales Order List" = X,
        codeunit "Sales-Post" = X;
}
```

## Security Filter Implementation

### User-Based Record Filtering

```al
// Table with security filtering capability
table 50200 "Customer Territory"
{
    Caption = 'Customer Territory';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        
        field(2; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = "Territory"."Code";
        }
        
        field(3; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
    }
    
    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
        
        key(Territory; "Territory Code", "Salesperson Code")
        {
        }
    }
}

// Codeunit for applying security filters
codeunit 50200 "Security Filter Management"
{
    procedure ApplyCustomerSecurityFilter(var CustomerRec: Record Customer)
    var
        UserSetup: Record "User Setup";
        SalespersonFilter: Text;
    begin
        if not UserSetup.Get(UserId) then
            exit;
            
        // Apply salesperson-based filtering
        if UserSetup."Salespers./Purch. Code" <> '' then begin
            SalespersonFilter := UserSetup."Salespers./Purch. Code";
            CustomerRec.SetRange("Salesperson Code", SalespersonFilter);
        end;
        
        // Apply territory-based filtering if configured
        ApplyTerritoryFilter(CustomerRec, UserSetup);
    end;
    
    local procedure ApplyTerritoryFilter(var CustomerRec: Record Customer; UserSetup: Record "User Setup")
    var
        CustomerTerritory: Record "Customer Territory";
        TerritoryFilter: Text;
    begin
        if UserSetup."Territory Code" = '' then
            exit;
            
        CustomerTerritory.SetRange("Territory Code", UserSetup."Territory Code");
        if CustomerTerritory.FindSet() then begin
            repeat
                if TerritoryFilter <> '' then
                    TerritoryFilter += '|';
                TerritoryFilter += CustomerTerritory."Customer No.";
            until CustomerTerritory.Next() = 0;
            
            if TerritoryFilter <> '' then
                CustomerRec.SetFilter("No.", TerritoryFilter);
        end;
    end;
    
    procedure GetUserLocationFilter(): Text
    var
        UserSetup: Record "User Setup";
        ResponsibilityCenter: Record "Responsibility Center";
        LocationFilter: Text;
    begin
        if not UserSetup.Get(UserId) then
            exit('');
            
        if UserSetup."Responsibility Center" <> '' then begin
            ResponsibilityCenter.Get(UserSetup."Responsibility Center");
            LocationFilter := ResponsibilityCenter."Location Filter";
        end;
        
        exit(LocationFilter);
    end;
}
```

### Dynamic Security Filter Application

```al
// Page with integrated security filtering
page 50200 "Secured Customer List"
{
    Caption = 'Secured Customer List';
    PageType = List;
    SourceTable = Customer;
    UsageCategory = Lists;
    ApplicationArea = All;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
    trigger OnOpenPage()
    var
        SecurityFilterMgt: Codeunit "Security Filter Management";
        LocationFilter: Text;
    begin
        // Apply user-based security filters
        SecurityFilterMgt.ApplyCustomerSecurityFilter(Rec);
        
        // Apply location-based filtering
        LocationFilter := SecurityFilterMgt.GetUserLocationFilter();
        if LocationFilter <> '' then
            Rec.SetFilter("Location Code", LocationFilter);
    end;
}

// Event subscriber for automatic filter application
codeunit 50201 "Security Filter Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterGetRecord', '', false, false)]
    local procedure OnAfterGetCustomerRecord(var Rec: Record Customer)
    var
        SecurityFilterMgt: Codeunit "Security Filter Management";
    begin
        // Apply additional context-based filtering
        ApplyDynamicSecurityContext(Rec);
    end;
    
    local procedure ApplyDynamicSecurityContext(var CustomerRec: Record Customer)
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then
            exit;
            
        // Apply time-based access restrictions
        if UserSetup."Allow Posting From" <> 0D then
            if Today < UserSetup."Allow Posting From" then
                Error('Access restricted outside allowed posting period.');
                
        // Apply customer credit limit visibility
        if not UserSetup."Allow View Credit Limit" then
            CustomerRec."Credit Limit (LCY)" := 0;
    end;
}
```

## User Setup Integration Patterns

### Extended User Setup for Security

```al
// Table extension for enhanced user security setup
tableextension 50200 "User Setup Security" extends "User Setup"
{
    fields
    {
        field(50200; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
            DataClassification = EndUserIdentifiableInformation;
        }
        
        field(50201; "Customer Group Filter"; Code[20])
        {
            Caption = 'Customer Group Filter';
            TableRelation = "Customer Posting Group";
            DataClassification = EndUserIdentifiableInformation;
        }
        
        field(50202; "Allow View Credit Limit"; Boolean)
        {
            Caption = 'Allow View Credit Limit';
            DataClassification = EndUserIdentifiableInformation;
        }
        
        field(50203; "Max Discount %"; Decimal)
        {
            Caption = 'Maximum Discount %';
            DecimalPlaces = 2 : 5;
            MaxValue = 100;
            MinValue = 0;
            DataClassification = EndUserIdentifiableInformation;
        }
        
        field(50204; "Security Level"; Enum "User Security Level")
        {
            Caption = 'Security Level';
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}

// Enum for security levels
enum 50200 "User Security Level"
{
    Extensible = true;
    
    value(0; "Standard")
    {
        Caption = 'Standard';
    }
    
    value(1; "Elevated")
    {
        Caption = 'Elevated';
    }
    
    value(2; "Administrative")
    {
        Caption = 'Administrative';
    }
}

// Codeunit for user security validation
codeunit 50202 "User Security Validation"
{
    procedure ValidateUserAccess(ActionType: Enum "Security Action Type"; RecordRef: RecordRef): Boolean
    var
        UserSetup: Record "User Setup";
        SecurityLevel: Enum "User Security Level";
    begin
        if not UserSetup.Get(UserId) then
            exit(false);
            
        SecurityLevel := UserSetup."Security Level";
        
        case ActionType of
            ActionType::"View Credit Limit":
                exit(UserSetup."Allow View Credit Limit" or (SecurityLevel = SecurityLevel::Administrative));
            
            ActionType::"Modify Prices":
                exit(SecurityLevel in [SecurityLevel::Elevated, SecurityLevel::Administrative]);
            
            ActionType::"Delete Records":
                exit(SecurityLevel = SecurityLevel::Administrative);
        end;
        
        exit(false);
    end;
    
    procedure GetMaxDiscountAllowed(): Decimal
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then
            exit(UserSetup."Max Discount %");
        
        exit(0);
    end;
}

// Enum for security actions
enum 50201 "Security Action Type"
{
    Extensible = true;
    
    value(0; "View Credit Limit")
    {
        Caption = 'View Credit Limit';
    }
    
    value(1; "Modify Prices")
    {
        Caption = 'Modify Prices';
    }
    
    value(2; "Delete Records")
    {
        Caption = 'Delete Records';
    }
}
```

## Extension Permission Patterns

### API Permission Management

```al
// Permission set for API access
permissionset 50300 "API ACCESS"
{
    Assignable = true;
    Caption = 'API Access';
    
    Permissions = 
        // Read access to master data
        tabledata Customer = R,
        tabledata Item = R,
        tabledata Vendor = R,
        
        // API-specific objects
        page "APIV2 - Customers" = X,
        page "APIV2 - Items" = X,
        page "APIV2 - Vendors" = X,
        
        // Required system objects for API
        codeunit "Graph Mgt - General Tools" = X,
        codeunit "API Data Type Helper" = X;
}

// Web service permission management
codeunit 50300 "Web Service Permission Mgt"
{
    procedure ValidateAPIAccess(ServiceName: Text; Operation: Text): Boolean
    var
        WebServicePermission: Record "Web Service Permission";
        UserSetup: Record "User Setup";
    begin
        // Check if user has API access permission set
        if not HasPermissionSet('API ACCESS') then
            exit(false);
            
        // Validate specific service permissions
        WebServicePermission.SetRange("User ID", UserId);
        WebServicePermission.SetRange("Service Name", ServiceName);
        WebServicePermission.SetRange("Operation", Operation);
        
        exit(not WebServicePermission.IsEmpty);
    end;
    
    local procedure HasPermissionSet(PermissionSetID: Code[20]): Boolean
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Permission Set ID", PermissionSetID);
        exit(not AccessControl.IsEmpty);
    end;
}

// Table for tracking web service permissions
table 50300 "Web Service Permission"
{
    Caption = 'Web Service Permission';
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
        }
        
        field(2; "Service Name"; Text[100])
        {
            Caption = 'Service Name';
        }
        
        field(3; "Operation"; Text[50])
        {
            Caption = 'Operation';
        }
        
        field(4; "Allow Access"; Boolean)
        {
            Caption = 'Allow Access';
        }
    }
    
    keys
    {
        key(PK; "User ID", "Service Name", "Operation")
        {
            Clustered = true;
        }
    }
}
```

### Cross-Extension Permission Coordination

```al
// Permission coordination codeunit
codeunit 50301 "Extension Permission Coordinator"
{
    // Interface for extension permission management
    procedure RegisterExtensionPermissions(ExtensionName: Text; PermissionSetID: Code[20])
    var
        ExtensionPermission: Record "Extension Permission Registry";
    begin
        ExtensionPermission.Init();
        ExtensionPermission."Extension Name" := ExtensionName;
        ExtensionPermission."Permission Set ID" := PermissionSetID;
        ExtensionPermission."Registration Date" := Today;
        ExtensionPermission.Insert(true);
    end;
    
    procedure ValidateExtensionAccess(RequiredExtension: Text; UserID: Text): Boolean
    var
        ExtensionPermission: Record "Extension Permission Registry";
        AccessControl: Record "Access Control";
        UserRec: Record User;
    begin
        // Find required permission set for extension
        ExtensionPermission.SetRange("Extension Name", RequiredExtension);
        if not ExtensionPermission.FindFirst() then
            exit(false);
        
        // Check user access to permission set
        if UserRec.Get(UserID) then begin
            AccessControl.SetRange("User Security ID", UserRec."User Security ID");
            AccessControl.SetRange("Permission Set ID", ExtensionPermission."Permission Set ID");
            exit(not AccessControl.IsEmpty);
        end;
        
        exit(false);
    end;
}

// Registry table for extension permissions
table 50301 "Extension Permission Registry"
{
    Caption = 'Extension Permission Registry';
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Extension Name"; Text[100])
        {
            Caption = 'Extension Name';
        }
        
        field(2; "Permission Set ID"; Code[20])
        {
            Caption = 'Permission Set ID';
        }
        
        field(3; "Registration Date"; Date)
        {
            Caption = 'Registration Date';
        }
        
        field(4; "Required Base Permissions"; Text[250])
        {
            Caption = 'Required Base Permissions';
        }
    }
    
    keys
    {
        key(PK; "Extension Name")
        {
            Clustered = true;
        }
    }
}
```

## Multi-Company Permission Patterns

### Company-Scoped Security Implementation

```al
// Company security management
codeunit 50302 "Company Security Manager"
{
    procedure ApplyCompanySecurityFilters(var RecordRef: RecordRef)
    var
        UserSetup: Record "User Setup";
        CompanyFilter: Text;
    begin
        if not UserSetup.Get(UserId) then
            exit;
            
        CompanyFilter := GetAllowedCompanies(UserId);
        if CompanyFilter <> '' then
            ApplyCompanyFilter(RecordRef, CompanyFilter);
    end;
    
    local procedure GetAllowedCompanies(UserID: Text): Text
    var
        UserCompanyAccess: Record "User Company Access";
        CompanyFilter: Text;
    begin
        UserCompanyAccess.SetRange("User ID", UserID);
        if UserCompanyAccess.FindSet() then begin
            repeat
                if CompanyFilter <> '' then
                    CompanyFilter += '|';
                CompanyFilter += UserCompanyAccess."Company Name";
            until UserCompanyAccess.Next() = 0;
        end;
        
        exit(CompanyFilter);
    end;
    
    local procedure ApplyCompanyFilter(var RecordRef: RecordRef; CompanyFilter: Text)
    var
        CompanyFieldRef: FieldRef;
    begin
        // Apply company filter if the table has a company field
        if RecordRef.FieldExist(1) then begin // Company field is typically field 1
            CompanyFieldRef := RecordRef.Field(1);
            if CompanyFieldRef.Type = FieldType::Code then
                CompanyFieldRef.SetFilter(CompanyFilter);
        end;
    end;
    
    procedure ValidateCompanyAccess(CompanyName: Text): Boolean
    var
        UserCompanyAccess: Record "User Company Access";
    begin
        UserCompanyAccess.SetRange("User ID", UserId);
        UserCompanyAccess.SetRange("Company Name", CompanyName);
        exit(not UserCompanyAccess.IsEmpty);
    end;
}

// Table for managing user company access
table 50302 "User Company Access"
{
    Caption = 'User Company Access';
    DataClassification = EndUserIdentifiableInformation;
    
    fields
    {
        field(1; "User ID"; Text[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
        }
        
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        
        field(3; "Access Level"; Option)
        {
            Caption = 'Access Level';
            OptionMembers = "Read Only","Full Access","Administrative";
        }
        
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
        }
    }
    
    keys
    {
        key(PK; "User ID", "Company Name")
        {
            Clustered = true;
        }
    }
}
```