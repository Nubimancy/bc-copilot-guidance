# Security Filters and Record-Level Access - Samples

This file contains practical code examples for implementing security filters and record-level access controls.

## Territory-Based Sales Access

```al
// Table to manage territory assignments
table 50100 "Territory Assignment"
{
    fields
    {
        field(1; "User ID"; Code[50]) { }
        field(2; "Territory Code"; Code[20]) { }
        field(3; "Include All"; Boolean) { }
    }
}

// Codeunit to apply territory-based security filters
codeunit 50100 "Territory Security Management"
{
    procedure ApplyTerritoryFilter(UserID: Code[50])
    var
        TerritoryAssignment: Record "Territory Assignment";
        User: Record User;
        SecurityFilter: Record "Security Filter";
    begin
        if TerritoryAssignment.Get(UserID) then begin
            if not TerritoryAssignment."Include All" then begin
                // Apply security filter to Customer table
                SecurityFilter.Init();
                SecurityFilter."User Security ID" := User."User Security ID";
                SecurityFilter."Object Type" := SecurityFilter."Object Type"::"Table Data";
                SecurityFilter."Object ID" := Database::Customer;
                SecurityFilter."Security Filter" := StrSubstNo('Territory Code=%1', TerritoryAssignment."Territory Code");
                SecurityFilter.Insert();
            end;
        end;
    end;
}
```

## Department-Based Document Access

```al
// Security filter for department-based G/L entry access
codeunit 50101 "Department Security Management"
{
    procedure ApplyDepartmentFilters(UserID: Code[50])
    var
        UserSetup: Record "User Setup";
        SecurityFilter: Record "Security Filter";
        DimensionValue: Record "Dimension Value";
    begin
        if UserSetup.Get(UserID) and (UserSetup."Department Code" <> '') then begin
            // Apply to G/L Entry
            CreateSecurityFilter(UserID, Database::"G/L Entry", 
                StrSubstNo('Global Dimension 1 Code=%1', UserSetup."Department Code"));
            
            // Apply to General Journal Line  
            CreateSecurityFilter(UserID, Database::"Gen. Journal Line",
                StrSubstNo('Shortcut Dimension 1 Code=%1', UserSetup."Department Code"));
        end;
    end;
    
    local procedure CreateSecurityFilter(UserID: Code[50]; ObjectID: Integer; FilterText: Text)
    var
        User: Record User;
        SecurityFilter: Record "Security Filter";
    begin
        User.SetRange("User Name", UserID);
        if User.FindFirst() then begin
            SecurityFilter.Init();
            SecurityFilter."User Security ID" := User."User Security ID";
            SecurityFilter."Object Type" := SecurityFilter."Object Type"::"Table Data";
            SecurityFilter."Object ID" := ObjectID;
            SecurityFilter."Security Filter" := FilterText;
            SecurityFilter.Insert();
        end;
    end;
}
```

## Hierarchical Access Control

```al
// Hierarchical security filters for sales management
codeunit 50102 "Hierarchical Security Mgmt"
{
    procedure ApplyHierarchicalFilters(UserID: Code[50])
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        UserSetup: Record "User Setup";
        FilterText: Text;
    begin
        if UserSetup.Get(UserID) then begin
            case UserSetup."Role Type" of
                UserSetup."Role Type"::Representative:
                    // Can only see own sales documents
                    FilterText := StrSubstNo('Salesperson Code=%1', UserSetup."Salespers./Purch. Code");
                    
                UserSetup."Role Type"::Manager:
                    // Can see own and subordinates' sales documents  
                    FilterText := GetSubordinatesFilter(UserSetup."Salespers./Purch. Code");
                    
                UserSetup."Role Type"::Director:
                    // Can see all in region/division
                    FilterText := GetDivisionFilter(UserSetup."Division Code");
            end;
            
            if FilterText <> '' then
                CreateSecurityFilter(UserID, Database::"Sales Header", FilterText);
        end;
    end;
    
    local procedure GetSubordinatesFilter(ManagerCode: Code[20]): Text
    var
        Salesperson: Record "Salesperson/Purchaser";
        FilterText: Text;
    begin
        Salesperson.SetRange("Manager Code", ManagerCode);
        if Salesperson.FindSet() then begin
            FilterText := StrSubstNo('Salesperson Code=%1', ManagerCode); // Include manager's own
            repeat
                FilterText += StrSubstNo('|%1', Salesperson.Code); // Add subordinates
            until Salesperson.Next() = 0;
        end;
        exit(FilterText);
    end;
}
```

## Centralized Security Filter Management

```al
// Centralized filter management
codeunit 50103 "Security Filter Management"
{
    procedure UpdateUserSecurityFilters(UserID: Code[50])
    begin
        ClearExistingFilters(UserID);
        ApplyRoleBasedFilters(UserID);
        ApplyTerritoryFilters(UserID);
        ApplyDepartmentFilters(UserID);
        LogSecurityFilterChanges(UserID);
    end;
    
    local procedure ClearExistingFilters(UserID: Code[50])
    var
        User: Record User;
        SecurityFilter: Record "Security Filter";
    begin
        User.SetRange("User Name", UserID);
        if User.FindFirst() then begin
            SecurityFilter.SetRange("User Security ID", User."User Security ID");
            SecurityFilter.DeleteAll();
        end;
    end;
    
    local procedure LogSecurityFilterChanges(UserID: Code[50])
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(Database::"Security Filter", ActivityLog.Status::Success,
            'Security Filters Updated', 
            StrSubstNo('Security filters refreshed for user: %1', UserID),
            '');
    end;
}
```

## Multi-Company Security Filters

```al
// Handle multi-company security filters
procedure ApplyCompanySpecificFilters(UserID: Code[50])
var
    AllowedCompanies: Record "Allowed Companies";
    CompanyFilter: Text;
begin
    AllowedCompanies.SetRange("User ID", UserID);
    if AllowedCompanies.FindSet() then begin
        repeat
            if CompanyFilter <> '' then
                CompanyFilter += '|';
            CompanyFilter += AllowedCompanies."Company Name";
        until AllowedCompanies.Next() = 0;
        
        // Apply company restriction to cross-company tables if needed
        CreateSecurityFilter(UserID, Database::"Company Information", 
            StrSubstNo('Name=%1', CompanyFilter));
    end;
end;
```

## Performance-Optimized Security Filters

```al
// Good: Use indexed fields for filters
procedure CreateOptimizedFilter(UserID: Code[50])
var
    SecurityFilter: Record "Security Filter";
begin
    SecurityFilter."Security Filter" := 'Salesperson Code=ALICE'; // Indexed field - good performance
    
    // Avoid: Complex expressions that can't use indexes
    // SecurityFilter."Security Filter" := 'UPPERCASE(Name)=ALICE'; // Poor performance
end;
```

## Common Filter Patterns

```al
// Date-based access - restrict to current period only
procedure ApplyDateBasedFilter(UserID: Code[50])
var
    FilterText: Text;
begin
    FilterText := StrSubstNo('Posting Date>=%1&Posting Date<=%2', 
                           CalcDate('-1M', Today()), CalcDate('+1M', Today()));
    CreateSecurityFilter(UserID, Database::"G/L Entry", FilterText);
end;

// Status-based filters - allow access to open documents only
procedure ApplyStatusFilter(UserID: Code[50])
begin
    CreateSecurityFilter(UserID, Database::"Sales Header", 'Status=Open');
end;

// Multi-dimensional filters - combine department and project
procedure ApplyMultiDimensionalFilter(UserID: Code[50])
var
    UserSetup: Record "User Setup";
    FilterText: Text;
begin
    if UserSetup.Get(UserID) then begin
        FilterText := StrSubstNo('Global Dimension 1 Code=%1&Global Dimension 2 Code=%2',
                               UserSetup."Department Code", UserSetup."Project Code");
        CreateSecurityFilter(UserID, Database::"G/L Entry", FilterText);
    end;
end;
```

## Workflow Integration

```al
// Security filter integration with approval workflows
procedure CheckApprovalSecurity(DocumentNo: Code[20]; UserID: Code[50]): Boolean
var
    SalesHeader: Record "Sales Header";
begin
    // Security filter automatically applies when user tries to read record
    SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo);
    // If user can read record, they can approve it
    exit(not SalesHeader.IsEmpty());
end;
```

## Audit Trail Implementation

```al
// Log security filter applications for audit trail
procedure LogSecurityFilterApplication(UserID: Code[50]; ObjectID: Integer; FilterText: Text)
var
    ActivityLog: Record "Activity Log";
begin
    ActivityLog.LogActivity(Database::"Security Filter", ActivityLog.Status::Success,
        'Security Filter Applied', 
        StrSubstNo('User: %1, Object: %2, Filter: %3', UserID, ObjectID, FilterText),
        '');
end;
```
