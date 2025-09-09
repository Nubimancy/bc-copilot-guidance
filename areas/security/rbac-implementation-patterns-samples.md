# RBAC Implementation Patterns - Samples

This file contains practical examples demonstrating Role-Based Access Control implementation patterns in Business Central.

## Hierarchical Role Structure Examples

### Base Role - Foundation Permissions

```al
// Level 1: Base system access for all users
permissionset 50300 "BASE USER ACCESS"
{
    Caption = 'Base User Access';
    Permissions = 
        // Core system access
        tabledata "User" = R,
        tabledata "Company Information" = R,
        tabledata "User Setup" = R,
        
        // Basic navigation pages
        page "Company Information" = X,
        page "Role Center" = X,
        page "Tell Me" = X,
        
        // Essential system functions
        system "Tools, Backup/Restore" = X,
        system "Tools, Security" = X;
}
```

### Department-Specific Base Roles

```al
// Level 2: Sales department base access
permissionset 50301 "SALES DEPARTMENT BASE"
{
    Caption = 'Sales Department Base Access';
    IncludedPermissionSets = "BASE USER ACCESS";
    
    Permissions = 
        // Core sales data - read access
        tabledata "Customer" = R,
        tabledata "Item" = R,
        tabledata "Sales Price" = R,
        tabledata "Customer Price Group" = R,
        
        // Sales inquiry pages
        page "Customer List" = X,
        page "Customer Card" = X,
        page "Item List" = X,
        page "Item Card" = X,
        
        // Basic sales reports
        report "Customer List" = X,
        report "Sales Statistics" = X;
}

// Level 2: Finance department base access
permissionset 50302 "FINANCE DEPARTMENT BASE"
{
    Caption = 'Finance Department Base Access';
    IncludedPermissionSets = "BASE USER ACCESS";
    
    Permissions = 
        // Core financial data - read access
        tabledata "G/L Account" = R,
        tabledata "Customer" = R,
        tabledata "Vendor" = R,
        tabledata "G/L Entry" = R,
        
        // Financial inquiry pages
        page "Chart of Accounts" = X,
        page "Customer List" = X,
        page "Vendor List" = X,
        
        // Basic financial reports
        report "Trial Balance" = X,
        report "Aged Accounts Receivable" = X;
}
```

### Functional Role Examples

```al
// Level 3: Sales representative functional role
permissionset 50303 "SALES REPRESENTATIVE"
{
    Caption = 'Sales Representative';
    IncludedPermissionSets = "SALES DEPARTMENT BASE";
    
    Permissions = 
        // Sales document creation and modification
        tabledata "Sales Header" = RIMD,
        tabledata "Sales Line" = RIMD,
        tabledata "Sales Comment Line" = RIMD,
        
        // Customer interaction permissions
        tabledata "Customer" = RIM,
        tabledata "Contact" = RIMD,
        tabledata "Interaction Log Entry" = RIMD,
        
        // Sales processing pages
        page "Sales Order List" = X,
        page "Sales Order" = X,
        page "Sales Quote List" = X,
        page "Sales Quote" = X,
        
        // Sales representative reports
        report "Sales Quote" = X,
        report "Order Confirmation" = X;
}

// Level 3: Accounts receivable clerk functional role
permissionset 50304 "ACCOUNTS RECEIVABLE CLERK"
{
    Caption = 'Accounts Receivable Clerk';
    IncludedPermissionSets = "FINANCE DEPARTMENT BASE";
    
    Permissions = 
        // Customer financial management
        tabledata "Customer" = RIMD,
        tabledata "Customer Ledger Entry" = RIM,
        tabledata "Detailed Cust. Ledg. Entry" = RIM,
        
        // Payment processing
        tabledata "Payment Terms" = RIMD,
        tabledata "Payment Method" = RIMD,
        tabledata "Gen. Journal Line" = RIMD,
        
        // AR processing pages
        page "Customer Ledger Entries" = X,
        page "Payment Journal" = X,
        page "Cash Receipt Journal" = X,
        
        // AR reports
        report "Customer Statement" = X,
        report "Payment Receipt" = X;
}
```

### Composite Role Assembly

```al
// Level 4: Sales manager composite role
permissionset 50305 "SALES MANAGER"
{
    Caption = 'Sales Manager';
    IncludedPermissionSets = "SALES REPRESENTATIVE", "ACCOUNTS RECEIVABLE CLERK";
    
    Permissions = 
        // Sales management functions
        tabledata "Salesperson/Purchaser" = RIMD,
        tabledata "Customer Posting Group" = RIM,
        tabledata "Sales & Receivables Setup" = RIM,
        
        // Price and discount management
        tabledata "Sales Price" = RIMD,
        tabledata "Sales Line Discount" = RIMD,
        tabledata "Customer Discount Group" = RIMD,
        
        // Management pages
        page "Sales & Receivables Setup" = X,
        page "Salespeople/Purchasers" = X,
        page "Sales Analysis" = X,
        
        // Management reports
        report "Sales Analysis Report" = X,
        report "Top Customer List" = X,
        report "Commission Analysis" = X;
}
```

## Matrix-Based Role Design

### Function-Authority Matrix Implementation

```al
// Finance Read-Only role
permissionset 50310 "FINANCE READ ONLY"
{
    Caption = 'Finance Read Only';
    IncludedPermissionSets = "FINANCE DEPARTMENT BASE";
    
    Permissions = 
        // Extended read access to financial data
        tabledata "Bank Account" = R,
        tabledata "Vendor Ledger Entry" = R,
        tabledata "G/L Budget Entry" = R,
        
        // Financial inquiry pages (read-only)
        page "Bank Account List" = X,
        page "Vendor Ledger Entries" = X,
        page "Budget" = X;
}

// Finance Power User role  
permissionset 50311 "FINANCE POWER USER"
{
    Caption = 'Finance Power User';
    IncludedPermissionSets = "FINANCE READ ONLY";
    
    Permissions = 
        // Journal processing permissions
        tabledata "Gen. Journal Template" = RIMD,
        tabledata "Gen. Journal Batch" = RIMD,
        tabledata "Gen. Journal Line" = RIMD,
        
        // Advanced financial management
        tabledata "G/L Account" = RIM,
        tabledata "Bank Account" = RIM,
        tabledata "Fixed Asset" = RIMD,
        
        // Processing pages
        page "General Journal" = X,
        page "Bank Account Card" = X,
        page "Fixed Asset Card" = X,
        
        // Power user reports
        report "General Journal - Test" = X,
        report "Bank Account - Detail Trial Bal." = X;
}
```

## Resource-Based Access Control

### Data Ownership Role Pattern

```al
// Territory-based sales role with data restrictions
permissionset 50320 "SALES REP TERRITORY EAST"
{
    Caption = 'Sales Representative - Eastern Territory';
    IncludedPermissionSets = "SALES REPRESENTATIVE";
    
    Permissions = 
        // Territory-specific customer access
        tabledata "Customer" = RIMD,
        tabledata "Sales Header" = RIMD,
        tabledata "Sales Line" = RIMD;
        
    // Note: Actual data filtering would be implemented through
    // security filters in a codeunit (see samples below)
}

// Codeunit to apply territory-based security filters
codeunit 50320 "Territory Security Management"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Management", 'OnAfterCompanyOpen', '', false, false)]
    local procedure ApplyTerritorySecurityFilters()
    var
        User: Record User;
        SecurityFilter: Record "Security Filter";
        UserSetup: Record "User Setup";
    begin
        if User.Get(UserSecurityId()) then begin
            if UserSetup.Get(User."User Name") then begin
                case UserSetup."Territory Code" of
                    'EAST':
                        ApplySecurityFilter(User."User Security ID", Database::Customer, 'Territory Code=CONST(EAST)');
                    'WEST':
                        ApplySecurityFilter(User."User Security ID", Database::Customer, 'Territory Code=CONST(WEST)');
                    'CENTRAL':
                        ApplySecurityFilter(User."User Security ID", Database::Customer, 'Territory Code=CONST(CENTRAL)');
                end;
            end;
        end;
    end;
    
    local procedure ApplySecurityFilter(UserSecurityID: Guid; ObjectID: Integer; FilterText: Text)
    var
        SecurityFilter: Record "Security Filter";
    begin
        SecurityFilter.Init();
        SecurityFilter."User Security ID" := UserSecurityID;
        SecurityFilter."Object Type" := SecurityFilter."Object Type"::"Table Data";
        SecurityFilter."Object ID" := ObjectID;
        SecurityFilter."Security Filter" := CopyStr(FilterText, 1, MaxStrLen(SecurityFilter."Security Filter"));
        if not SecurityFilter.Insert() then
            SecurityFilter.Modify();
    end;
}
```

## Dynamic Role Assignment Patterns

### Time-Based Role Management

```al
// Temporary project role with expiration
table 50320 "Temporary Role Assignment"
{
    DataClassification = CustomerContent;
    Caption = 'Temporary Role Assignment';
    
    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            TableRelation = User."User Security ID";
        }
        
        field(2; "Permission Set ID"; Code[20])
        {
            Caption = 'Permission Set ID';
            TableRelation = "Permission Set"."Role ID";
        }
        
        field(3; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        
        field(4; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        
        field(5; "Approved By"; Code[50])
        {
            Caption = 'Approved By';
            TableRelation = User."User Name";
        }
        
        field(6; "Active"; Boolean)
        {
            Caption = 'Active';
        }
    }
    
    keys
    {
        key(PK; "User Security ID", "Permission Set ID")
        {
            Clustered = true;
        }
    }
    
    trigger OnInsert()
    begin
        if "Start Date" = 0D then
            "Start Date" := Today();
            
        if "End Date" < "Start Date" then
            Error('End date must be after start date.');
    end;
}

// Codeunit to manage temporary role assignments
codeunit 50321 "Temporary Role Management"
{
    procedure ActivateTemporaryRoles()
    var
        TempRoleAssignment: Record "Temporary Role Assignment";
        AccessControl: Record "Access Control";
    begin
        // Activate roles that should be active today
        TempRoleAssignment.SetRange(Active, false);
        TempRoleAssignment.SetFilter("Start Date", '<=%1', Today());
        TempRoleAssignment.SetFilter("End Date", '>=%1', Today());
        
        if TempRoleAssignment.FindSet() then
            repeat
                // Create access control entry
                AccessControl.Init();
                AccessControl."User Security ID" := TempRoleAssignment."User Security ID";
                AccessControl."Role ID" := TempRoleAssignment."Permission Set ID";
                AccessControl."Company Name" := CompanyName();
                if AccessControl.Insert() then begin
                    TempRoleAssignment.Active := true;
                    TempRoleAssignment.Modify();
                end;
            until TempRoleAssignment.Next() = 0;
    end;
    
    procedure DeactivateExpiredRoles()
    var
        TempRoleAssignment: Record "Temporary Role Assignment";
        AccessControl: Record "Access Control";
    begin
        // Deactivate roles that have expired
        TempRoleAssignment.SetRange(Active, true);
        TempRoleAssignment.SetFilter("End Date", '<%1', Today());
        
        if TempRoleAssignment.FindSet() then
            repeat
                // Remove access control entry
                AccessControl.SetRange("User Security ID", TempRoleAssignment."User Security ID");
                AccessControl.SetRange("Role ID", TempRoleAssignment."Permission Set ID");
                AccessControl.SetRange("Company Name", CompanyName());
                if AccessControl.FindFirst() then
                    AccessControl.Delete();
                    
                TempRoleAssignment.Active := false;
                TempRoleAssignment.Modify();
            until TempRoleAssignment.Next() = 0;
    end;
}
```

## Role Segregation and Compliance

### Conflicting Role Prevention

```al
// Table to define conflicting permission sets
table 50321 "Permission Set Conflicts"
{
    DataClassification = SystemMetadata;
    Caption = 'Permission Set Conflicts';
    
    fields
    {
        field(1; "Permission Set 1"; Code[20])
        {
            Caption = 'Permission Set 1';
            TableRelation = "Permission Set"."Role ID";
        }
        
        field(2; "Permission Set 2"; Code[20])
        {
            Caption = 'Permission Set 2';
            TableRelation = "Permission Set"."Role ID";
        }
        
        field(3; "Conflict Reason"; Text[100])
        {
            Caption = 'Conflict Reason';
        }
        
        field(4; "Severity"; Option)
        {
            Caption = 'Severity';
            OptionMembers = Warning,Error,"Critical Error";
        }
    }
    
    keys
    {
        key(PK; "Permission Set 1", "Permission Set 2")
        {
            Clustered = true;
        }
    }
}

// Validation codeunit for role conflicts
codeunit 50322 "Role Conflict Validation"
{
    [EventSubscriber(ObjectType::Table, Database::"Access Control", 'OnBeforeInsertEvent', '', false, false)]
    local procedure ValidateRoleConflicts(var Rec: Record "Access Control")
    var
        ExistingAccessControl: Record "Access Control";
        PermissionSetConflicts: Record "Permission Set Conflicts";
    begin
        // Check for conflicts with existing roles
        ExistingAccessControl.SetRange("User Security ID", Rec."User Security ID");
        ExistingAccessControl.SetRange("Company Name", Rec."Company Name");
        
        if ExistingAccessControl.FindSet() then
            repeat
                if CheckRoleConflict(ExistingAccessControl."Role ID", Rec."Role ID") then begin
                    PermissionSetConflicts.SetRange("Permission Set 1", ExistingAccessControl."Role ID");
                    PermissionSetConflicts.SetRange("Permission Set 2", Rec."Role ID");
                    if not PermissionSetConflicts.FindFirst() then begin
                        PermissionSetConflicts.SetRange("Permission Set 1", Rec."Role ID");
                        PermissionSetConflicts.SetRange("Permission Set 2", ExistingAccessControl."Role ID");
                        PermissionSetConflicts.FindFirst();
                    end;
                    
                    case PermissionSetConflicts.Severity of
                        PermissionSetConflicts.Severity::Warning:
                            Message('WARNING: Potential conflict between roles %1 and %2: %3', 
                                ExistingAccessControl."Role ID", Rec."Role ID", PermissionSetConflicts."Conflict Reason");
                        PermissionSetConflicts.Severity::Error,
                        PermissionSetConflicts.Severity::"Critical Error":
                            Error('CONFLICT: Cannot assign role %1 with existing role %2: %3',
                                Rec."Role ID", ExistingAccessControl."Role ID", PermissionSetConflicts."Conflict Reason");
                    end;
                end;
            until ExistingAccessControl.Next() = 0;
    end;
    
    local procedure CheckRoleConflict(RoleID1: Code[20]; RoleID2: Code[20]): Boolean
    var
        PermissionSetConflicts: Record "Permission Set Conflicts";
    begin
        PermissionSetConflicts.SetRange("Permission Set 1", RoleID1);
        PermissionSetConflicts.SetRange("Permission Set 2", RoleID2);
        if PermissionSetConflicts.FindFirst() then
            exit(true);
            
        PermissionSetConflicts.SetRange("Permission Set 1", RoleID2);
        PermissionSetConflicts.SetRange("Permission Set 2", RoleID1);
        exit(PermissionSetConflicts.FindFirst());
    end;
}
```

## Multi-Environment Role Synchronization

### Cross-Environment Role Management

```al
// Table to track role definitions across environments
table 50322 "Role Definition Master"
{
    DataClassification = SystemMetadata;
    Caption = 'Role Definition Master';
    
    fields
    {
        field(1; "Role ID"; Code[20])
        {
            Caption = 'Role ID';
        }
        
        field(2; "Role Name"; Text[100])
        {
            Caption = 'Role Name';
        }
        
        field(3; "Business Purpose"; Text[250])
        {
            Caption = 'Business Purpose';
        }
        
        field(4; "Target Environment"; Text[30])
        {
            Caption = 'Target Environment';
        }
        
        field(5; "Version"; Integer)
        {
            Caption = 'Version';
        }
        
        field(6; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
        }
        
        field(7; "Updated By"; Code[50])
        {
            Caption = 'Updated By';
        }
    }
    
    keys
    {
        key(PK; "Role ID", "Target Environment")
        {
            Clustered = true;
        }
    }
}

// API for role synchronization across environments
page 50322 "Role Sync API"
{
    APIGroup = 'security';
    APIPublisher = 'company';
    APIVersion = 'v1.0';
    EntityName = 'roleDefinition';
    EntitySetName = 'roleDefinitions';
    PageType = API;
    SourceTable = "Role Definition Master";
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(roleId; Rec."Role ID") { }
                field(roleName; Rec."Role Name") { }
                field(businessPurpose; Rec."Business Purpose") { }
                field(targetEnvironment; Rec."Target Environment") { }
                field(version; Rec.Version) { }
                field(lastUpdated; Rec."Last Updated") { }
                field(updatedBy; Rec."Updated By") { }
            }
        }
    }
}
```
