# Permission Sets Creation and Management - Samples

This file contains practical code examples for the permission sets creation and management atomic topic.

## Enterprise-Grade Permission Set Hierarchy

```al
// Base permission set for all sales personnel
permissionset 50100 "SALES BASE"
{
    Caption = 'Sales Base Permissions';
    Permissions = 
        // Core customer access
        tabledata "Customer" = R,
        tabledata "Contact" = R,
        tabledata "Ship-to Address" = R,
        
        // Item reference access
        tabledata "Item" = R,
        tabledata "Item Variant" = R,
        tabledata "Unit of Measure" = R,
        
        // Basic sales document access
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R,
        
        // Essential pages
        page "Customer List" = X,
        page "Customer Card" = X,
        page "Item List" = X,
        page "Item Card" = X;
}

// Sales representative permissions - can create and modify orders
permissionset 50101 "SALES REP"
{
    Caption = 'Sales Representative';
    IncludedPermissionSets = "SALES BASE";
    Permissions = 
        // Enhanced sales document permissions
        tabledata "Sales Header" = RIM,
        tabledata "Sales Line" = RIM,
        tabledata "Sales Comment Line" = RIM,
        
        // Order processing pages
        page "Sales Order List" = X,
        page "Sales Order" = X,
        page "Sales Quote List" = X,
        page "Sales Quote" = X,
        
        // Supporting functionality
        codeunit "Sales-Calc. Discount" = X,
        codeunit "Sales Line-Reserve" = X,
        report "Standard Sales - Quote" = X;
}

// Sales manager permissions - adds approval, statistics, and full CRUD
permissionset 50102 "SALES MANAGER"
{
    Caption = 'Sales Manager';
    IncludedPermissionSets = "SALES REP";
    Permissions = 
        // Full sales document access including delete
        tabledata "Sales Header" = RIMD,
        tabledata "Sales Line" = RIMD,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        
        // Management and reporting pages
        page "Sales Statistics" = X,
        page "Customer Statistics" = X,
        page "Sales Analysis" = X,
        
        // Advanced reports
        report "Customer - Top 10 List" = X,
        report "Sales Statistics" = X,
        report "Customer - Sales List" = X,
        
        // Approval workflows (if implemented)
        codeunit "Approval Mgmt." = X;
}
```

## Feature-Specific Permission Set

```al
// Feature-specific permission set for custom sales workflow
permissionset 50103 "CUSTOM SALES WORKFLOW"
{
    Caption = 'Custom Sales Workflow';
    Permissions = 
        // Custom workflow tables (example IDs)
        tabledata "Sales Approval Entry" = RIMD,
        tabledata "Sales Workflow Step" = RIM,
        
        // Custom pages
        page "Sales Approval List" = X,
        page "Sales Workflow Setup" = X,
        
        // Custom business logic
        codeunit "Sales Workflow Management" = X,
        codeunit "Sales Approval Handler" = X;
}
```

## AppSource-Compliant Permission Set

```al
// AppSource-compliant permission set example
permissionset 50104 "MY APP SALES ADDON"
{
    Caption = 'My Sales Add-on Feature';
    Permissions = 
        // Only objects from your app - avoid system object permissions
        tabledata "My Sales Extension Table" = RIMD,
        tabledata "My Sales Configuration" = RIM,
        
        page "My Sales Setup" = X,
        page "My Sales Dashboard" = X,
        
        codeunit "My Sales Logic" = X,
        
        // Standard reports if genuinely needed for your feature
        report "My Custom Sales Report" = X;
        
    // Note: Don't include broad system permissions like:
    // tabledata "Sales Header" = RIMD; // Unless absolutely necessary
    // This should be handled by separate permission sets
}
```

## Read-Only Analyst Permission Set

```al
// Example of read-only analyst permission set
permissionset 50105 "SALES ANALYST"
{
    Caption = 'Sales Data Analyst';
    Permissions = 
        // Read-only access to sales data
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        tabledata "Customer" = R,
        tabledata "Item" = R,
        
        // Analysis and reporting tools only
        page "Sales Analysis" = X,
        page "Customer Statistics" = X,
        page "Item Statistics" = X,
        
        // Reporting permissions
        report "Sales Statistics" = X,
        report "Customer - Sales List" = X,
        report "Inventory - Sales Statistics" = X,
        
        // Query objects for data analysis
        query "Sales Analysis Query" = X;
}
```

## Regional Permission Set (with Security Filters)

```al
// Regional sales rep with territory restrictions (to be combined with security filters)
permissionset 50106 "REGIONAL SALES REP"
{
    Caption = 'Regional Sales Representative';
    IncludedPermissionSets = "SALES REP";
    
    // Same permissions as SALES REP, but security filters would be applied:
    // Customer table: Territory Code filter = user's assigned territory
    // Sales Header: Salesperson Code filter = current user
    // This demonstrates separation of permissions vs. data access rules
}
```

## Supervisor Multi-Role Permission Set

```al
// Supervisor permission set combining multiple roles
permissionset 50107 "SALES SUPERVISOR"
{
    Caption = 'Sales Supervisor';
    IncludedPermissionSets = "SALES MANAGER", "SALES ANALYST";
    
    Permissions = 
        // Additional supervisory functions
        tabledata "Salesperson/Purchaser" = RIM,
        page "Salesperson/Purchaser Setup" = X,
        
        // Team management
        page "Sales Team Performance" = X,
        report "Salesperson Performance" = X;
}
```

## Customer Service Read-Only Permission Set

```al
// Minimal permission set for customer service (read-only sales info)
permissionset 50108 "CUSTOMER SERVICE SALES"
{
    Caption = 'Customer Service - Sales Info';
    Permissions = 
        // Read-only sales document access for customer service
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        tabledata "Sales Shipment Header" = R,
        tabledata "Sales Shipment Line" = R,
        
        // Customer information
        tabledata "Customer" = R,
        tabledata "Contact" = R,
        
        // Lookup pages only
        page "Sales Order List" = X,
        page "Posted Sales Invoice List" = X,
        page "Posted Sales Shipment List" = X,
        page "Customer List" = X;
        
    // Note: No modification rights, pure lookup for customer service
}
```
