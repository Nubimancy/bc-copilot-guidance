# License Entitlements vs Permissions - Samples

This file contains practical examples demonstrating the relationship between license entitlements and permission sets.

## Essential License Permission Sets

```al
// Base permission set suitable for Essential license users
permissionset 50200 "SALES ESSENTIAL"
{
    Caption = 'Sales Essential Features';
    Permissions = 
        // Core sales functionality available to Essential users
        tabledata "Customer" = RIMD,
        tabledata "Sales Header" = RIMD,
        tabledata "Sales Line" = RIMD,
        tabledata "Item" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        
        // Essential sales pages
        page "Customer List" = X,
        page "Customer Card" = X,
        page "Sales Order List" = X,
        page "Sales Order" = X,
        page "Posted Sales Invoice List" = X,
        page "Posted Sales Invoice" = X,
        
        // Basic sales reports
        report "Standard Sales - Order Conf." = X,
        report "Standard Sales - Invoice" = X;
}
```

## Premium License Extensions

```al
// Premium features that extend Essential functionality
permissionset 50201 "SALES PREMIUM"
{
    Caption = 'Sales Premium Features';
    IncludedPermissionSets = "SALES ESSENTIAL";
    
    Permissions = 
        // Advanced sales functionality requiring Premium license
        tabledata "Sales Planning Line" = RIMD,
        tabledata "Drop Shipment" = RIMD,
        tabledata "Special Order" = RIMD,
        
        // Advanced warehouse integration (Premium feature)
        tabledata "Warehouse Shipment Header" = RIMD,
        tabledata "Warehouse Shipment Line" = RIMD,
        
        // Premium sales analysis features
        page "Sales Analysis" = X,
        page "Sales Planning" = X,
        
        // Advanced sales reports (Premium)
        report "Sales Forecast" = X,
        report "Advanced Sales Statistics" = X;
}
```

## Team Member License Permissions

```al
// Restricted permission set for Team Member license users
permissionset 50202 "TEAM MEMBER SALES"
{
    Caption = 'Team Member Sales Access';
    Permissions = 
        // Read-only access to customer information
        tabledata "Customer" = R,
        tabledata "Contact" = R,
        
        // Limited sales document access (read-only)
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        
        // Specific data entry scenario - sales quotes only
        tabledata "Sales Header" = RIM, // Where Document Type = Quote
        tabledata "Sales Line" = RIM,   // Related to quotes only
        
        // Limited page access
        page "Customer List" = X,
        page "Sales Quote List" = X,
        page "Sales Quote" = X,
        
        // No posting or advanced features
        // No report access except basic lookups
}
```

## License Validation in Custom Code

```al
// Codeunit to validate license requirements
codeunit 50200 "License Validation"
{
    procedure ValidateAdvancedSalesFeature(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        LicenseInformation: Codeunit "License Information";
    begin
        // Check if user has Premium license for advanced features
        if not LicenseInformation.IsPremiumUserLicense() then begin
            Error('Advanced sales features require a Premium license. Please contact your administrator.');
        end;
        
        exit(true);
    end;
    
    procedure ValidateManufacturingAccess(): Boolean
    var
        LicenseInformation: Codeunit "License Information";
    begin
        // Manufacturing features are Premium-only
        if not LicenseInformation.IsPremiumUserLicense() then begin
            Error('Manufacturing functionality requires a Premium license.');
        end;
        
        exit(true);
    end;
    
    procedure ValidateTeamMemberRestrictions(DocumentType: Enum "Sales Document Type"): Boolean
    var
        LicenseInformation: Codeunit "License Information";
    begin
        // Team Member users can only create quotes
        if LicenseInformation.IsTeamMemberLicense() then begin
            if DocumentType <> DocumentType::Quote then begin
                Error('Team Member license users can only create sales quotes.');
            end;
        end;
        
        exit(true);
    end;
}
```

## License-Aware Page Extensions

```al
// Page extension that adapts based on license type
pageextension 50200 "Sales Order License Ext" extends "Sales Order"
{
    layout
    {
        modify("Shipment Method Code")
        {
            // Advanced shipping options only for Premium
            Visible = IsAdvancedShippingAllowed;
        }
        
        modify("Location Code")
        {
            // Advanced warehouse features require Premium
            Visible = IsAdvancedWarehouseAllowed;
        }
    }
    
    actions
    {
        modify("Create Warehouse Shipment")
        {
            // Warehouse management is Premium feature
            Visible = IsAdvancedWarehouseAllowed;
        }
    }
    
    var
        IsAdvancedShippingAllowed: Boolean;
        IsAdvancedWarehouseAllowed: Boolean;
    
    trigger OnOpenPage()
    var
        LicenseInformation: Codeunit "License Information";
    begin
        // Set visibility based on license type
        IsAdvancedShippingAllowed := LicenseInformation.IsPremiumUserLicense();
        IsAdvancedWarehouseAllowed := LicenseInformation.IsPremiumUserLicense();
    end;
}
```

## Multi-License Permission Architecture

```al
// Base permission set for all license types
permissionset 50210 "FINANCE BASE"
{
    Caption = 'Finance Base Access';
    Permissions = 
        // Core financial data (all licenses)
        tabledata "G/L Entry" = R,
        tabledata "Customer Ledger Entry" = R,
        tabledata "Vendor Ledger Entry" = R,
        
        // Basic financial pages
        page "Chart of Accounts" = X,
        page "Customer Ledger Entries" = X;
}

// Essential license finance features
permissionset 50211 "FINANCE ESSENTIAL"
{
    Caption = 'Finance Essential Features';
    IncludedPermissionSets = "FINANCE BASE";
    
    Permissions = 
        // General journal access (Essential+)
        tabledata "Gen. Journal Line" = RIMD,
        page "General Journal" = X,
        
        // Basic financial reports
        report "Trial Balance" = X,
        report "Customer Statement" = X;
}

// Premium license advanced finance features
permissionset 50212 "FINANCE PREMIUM"
{
    Caption = 'Finance Premium Features';
    IncludedPermissionSets = "FINANCE ESSENTIAL";
    
    Permissions = 
        // Advanced cost accounting (Premium only)
        tabledata "Cost Entry" = RIMD,
        tabledata "Cost Budget Entry" = RIMD,
        
        // Advanced financial analysis
        page "Cost Accounting Analysis" = X,
        page "Financial Reporting" = X,
        
        // Premium financial reports
        report "Cost Accounting Analysis" = X,
        report "Advanced Cash Flow Forecast" = X;
}
```

## Error Handling for License Restrictions

```al
// Table trigger example with license validation
table 50200 "Advanced Sales Feature"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Advanced Feature Code"; Code[20]) { }
    }
    
    trigger OnInsert()
    var
        LicenseInformation: Codeunit "License Information";
    begin
        // Validate Premium license for advanced features
        if not LicenseInformation.IsPremiumUserLicense() then begin
            Error('This advanced sales feature requires a Premium license. ' +
                  'Please contact your administrator to upgrade your license or use standard sales features.');
        end;
    end;
}

// Report with license checking
report 50200 "Advanced Analytics Report"
{
    trigger OnInitReport()
    var
        LicenseInformation: Codeunit "License Information";
    begin
        // Premium analytics require Premium license
        if not LicenseInformation.IsPremiumUserLicense() then begin
            Error('Advanced analytics reports require a Premium license. ' +
                  'Please use standard reports or contact your administrator.');
        end;
    end;
}
```

## License-Based Feature Toggles

```al
// Setup table with license-aware defaults
table 50201 "Custom Sales Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10]) { }
        field(2; "Enable Advanced Features"; Boolean) { }
        field(3; "Advanced Workflow Enabled"; Boolean) { }
    }
    
    trigger OnInsert()
    var
        LicenseInformation: Codeunit "License Information";
    begin
        // Auto-configure based on license type
        "Enable Advanced Features" := LicenseInformation.IsPremiumUserLicense();
        "Advanced Workflow Enabled" := LicenseInformation.IsPremiumUserLicense();
    end;
}
```
