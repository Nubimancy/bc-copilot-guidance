# Upgrade & Lifecycle Management 🔄

**Essential patterns for AppSource compliance, data migration, and graceful evolution of Business Central extensions**

## Table of Contents

1. [Upgrade Fundamentals](#upgrade-fundamentals)
2. [Data Transfer Object Patterns](#data-transfer-object-patterns)
3. [Graceful Obsoleting](#graceful-obsoleting)
4. [Breaking Change Management](#breaking-change-management)
5. [AppSource Compliance](#appsource-compliance)
6. [Version Strategy](#version-strategy)

---

## Upgrade Fundamentals

### Upgrade Codeunits with Tags

**Essential Pattern for Data Migrations:**

```al
codeunit 50100 "MyApp Upgrade Management"
{
    Subtype = Upgrade;
    
    // Upgrade procedure with unique tag
    trigger OnUpgradePerCompany()
    begin
        // Check if specific upgrade already completed
        if not UpgradeTag.HasUpgradeTag('50100-CustomerCreditLimit-20240815') then begin
            UpgradeCustomerCreditLimits();
            UpgradeTag.SetUpgradeTag('50100-CustomerCreditLimit-20240815');
        end;
        
        if not UpgradeTag.HasUpgradeTag('50100-ItemCategories-20241101') then begin
            MigrateItemCategories();
            UpgradeTag.SetUpgradeTag('50100-ItemCategories-20241101');
        end;
    end;
    
    trigger OnUpgradePerDatabase()
    begin
        if not UpgradeTag.HasUpgradeTag('50100-SetupTables-20240815', '', true) then begin
            CreateDefaultSetupRecords();
            UpgradeTag.SetUpgradeTag('50100-SetupTables-20240815', '', true);
        end;
    end;
}
```

### Upgrade Tag Naming Convention

```al
// ✅ Good naming pattern: AppId-Feature-Date
'50100-CustomerCreditLimit-20240815'
'50100-APIEndpoints-20241201' 
'50100-WorkflowIntegration-20250115'

// Include company-specific flag when needed
UpgradeTag.SetUpgradeTag('50100-SetupTables-20240815', '', true); // Per-database
UpgradeTag.SetUpgradeTag('50100-CustomerData-20240815', '', false); // Per-company
```

---

## Data Transfer Object Patterns

### Modern Data Migration with DataTransfer

**Replace old TRANSFERFIELDS with DataTransfer:**

```al
procedure MigrateCustomerDataToNewStructure()
var
    OldCustomerTable: Record "Old Customer Table";
    NewCustomerTable: Record "New Customer Table";
    DataTransfer: DataTransfer;
begin
    // ✅ Use DataTransfer for efficient bulk operations
    DataTransfer.SetTables(Database::"Old Customer Table", Database::"New Customer Table");
    
    // Map fields with transformation if needed
    DataTransfer.AddFieldValue(OldCustomerTable.FieldNo("Customer No."), NewCustomerTable.FieldNo("Customer No."));
    DataTransfer.AddFieldValue(OldCustomerTable.FieldNo(Name), NewCustomerTable.FieldNo("Customer Name"));
    
    // Transform data during transfer
    DataTransfer.AddConstantValue('NEW', NewCustomerTable.FieldNo("Migration Status"));
    
    // Apply filters if needed
    OldCustomerTable.SetRange("Migration Status", '');
    DataTransfer.UpdateAuditFields := false; // Preserve original timestamps
    
    // Execute the transfer
    DataTransfer.CopyRows();
    
    // Mark source records as migrated
    OldCustomerTable.ModifyAll("Migration Status", 'MIGRATED');
end;
```

### Complex Data Transformation

```al
procedure MigrateItemCategoriesWithLogic()
var
    OldItem: Record "Item (Old)";
    NewItem: Record Item;
    DataTransfer: DataTransfer;
begin
    // Handle complex migrations that need custom logic
    if OldItem.FindSet() then
        repeat
            NewItem.Init();
            TransformItemData(OldItem, NewItem);
            
            if NewItem.Insert() then
                // Log successful migration
                LogMigrationSuccess(OldItem."No.")
            else
                // Log and handle failures
                LogMigrationFailure(OldItem."No.", GetLastErrorText());
        until OldItem.Next() = 0;
end;

local procedure TransformItemData(var SourceItem: Record "Item (Old)"; var TargetItem: Record Item)
begin
    TargetItem."No." := SourceItem."Item Code";
    TargetItem.Description := SourceItem."Item Name";
    
    // Business logic transformation
    case SourceItem."Old Category Code" of
        'RAW':
            TargetItem."Item Category Code" := 'MATERIALS';
        'FIN':
            TargetItem."Item Category Code" := 'FINISHED';
        else
            TargetItem."Item Category Code" := 'MISC';
    end;
    
    // Preserve audit fields
    TargetItem.SystemCreatedAt := SourceItem."Created Date";
    TargetItem.SystemCreatedBy := SourceItem."Created By";
end;
```

---

## Graceful Obsoleting

### Obsolete Attribute Patterns

**Required for AppSource Compliance:**

```al
// ✅ Proper deprecation timeline
table 50100 "Customer Extension"
{
    fields
    {
        field(10; "Customer No."; Code[20]) { }
        
        // Obsolete field with clear migration path
        field(20; "Old Credit Rating"; Option) 
        { 
            ObsoleteState = PendingObsolete;
            ObsoleteReason = 'Replaced by Credit Rating Code field for better flexibility';
            ObsoleteTag = '1.5'; // Version when deprecated
            OptionMembers = Low,Medium,High;
        }
        
        // New replacement field
        field(21; "Credit Rating Code"; Code[10]) 
        { 
            TableRelation = "Credit Rating";
        }
    }
}
```

### Obsolete Function Migration

```al
codeunit 50100 "Customer Management"
{
    // ✅ Obsolete with replacement guidance
    [Obsolete('Use ValidateCustomerCreditWithDetails instead for enhanced error handling', '1.8')]
    procedure ValidateCustomerCredit(CustomerNo: Code[20]): Boolean
    begin
        // Keep working but delegate to new method
        exit(ValidateCustomerCreditWithDetails(CustomerNo, ''));
    end;
    
    // New improved method
    procedure ValidateCustomerCreditWithDetails(CustomerNo: Code[20]; Context: Text[100]): Boolean
    var
        ValidationResult: Record "Credit Validation Result";
    begin
        // Enhanced validation with detailed results
        exit(PerformDetailedCreditValidation(CustomerNo, Context, ValidationResult));
    end;
}
```

### Interface Evolution

```al
// ✅ Evolving interfaces gracefully
interface "ICustomer Validator"
{
    procedure ValidateCustomer(CustomerNo: Code[20]): Boolean;
    
    // Add new methods without breaking existing implementations
    procedure ValidateCustomerWithContext(CustomerNo: Code[20]; Context: Text): Boolean;
}

// Implementation maintains backward compatibility
codeunit 50101 "Customer Validator" implements "ICustomer Validator"
{
    procedure ValidateCustomer(CustomerNo: Code[20]): Boolean
    begin
        // Delegate to enhanced version with default context
        exit(ValidateCustomerWithContext(CustomerNo, 'Default'));
    end;
    
    procedure ValidateCustomerWithContext(CustomerNo: Code[20]; Context: Text): Boolean
    begin
        // New enhanced implementation
    end;
}
```

---

## Breaking Change Management

### API Versioning Strategy

```al
// ✅ Version your APIs properly
page 50100 "Customer API v1"
{
    PageType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'customers';
    APIVersion = 'v1.0'; // Explicit version
    EntityName = 'customer';
    EntitySetName = 'customers';
    
    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(customerNumber; Rec."No.") { }
                field(name; Rec.Name) { }
                // v1.0 fields only
            }
        }
    }
}

// New version with additional fields
page 50101 "Customer API v2"
{
    PageType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'customers';
    APIVersion = 'v2.0'; // New version
    EntityName = 'customer';
    EntitySetName = 'customers';
    
    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(customerNumber; Rec."No.") { }
                field(name; Rec.Name) { }
                field(creditRating; Rec."Credit Rating Code") { } // New field in v2.0
                field(riskLevel; Rec."Risk Assessment") { } // New field in v2.0
            }
        }
    }
}
```

### Event Signature Evolution

```al
codeunit 50100 "Customer Events"
{
    // ✅ Version your event signatures
    [IntegrationEvent(false, false)]
    procedure OnBeforeValidateCustomer(var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;
    
    // Enhanced event with additional context - new signature
    [IntegrationEvent(false, false)]
    procedure OnBeforeValidateCustomerWithContext(var Customer: Record Customer; Context: Text; var IsHandled: Boolean; var ValidationResult: Record "Validation Result")
    begin
    end;
    
    procedure ValidateCustomerInternal(var Customer: Record Customer; Context: Text)
    var
        IsHandled: Boolean;
        ValidationResult: Record "Validation Result";
    begin
        // Fire both events for backward compatibility
        OnBeforeValidateCustomer(Customer, IsHandled);
        if IsHandled then
            exit;
            
        OnBeforeValidateCustomerWithContext(Customer, Context, IsHandled, ValidationResult);
        if IsHandled then
            exit;
            
        // Perform validation
    end;
}
```

---

## AppSource Compliance

### Required Obsolete Patterns

```al
// ✅ AppSource requires specific obsolete handling
table 50100 "My Business Table"
{
    fields
    {
        field(1; "Primary Key"; Code[20]) { }
        
        // Must use PendingObsolete before removal
        field(10; "Deprecated Field"; Text[100])
        {
            ObsoleteState = PendingObsolete;
            ObsoleteReason = 'This field is no longer used and will be removed in version 2.0. Use New Field instead.';
            ObsoleteTag = '1.5';
        }
        
        // Cannot be removed until next major version
        field(11; "New Field"; Text[200]) { }
    }
}
```

### Upgrade Validation

```al
codeunit 50100 "AppSource Upgrade Validation"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Lifecycle Management", 'OnBeforeUpgradePerCompany', '', false, false)]
    local procedure ValidateUpgradeCompatibility()
    var
        ExtensionManagement: Codeunit "Extension Management";
        CurrentVersion: Version;
        TargetVersion: Version;
    begin
        // Validate upgrade path is supported
        CurrentVersion := ExtensionManagement.GetCurrentVersion();
        TargetVersion := ExtensionManagement.GetTargetVersion();
        
        if not IsUpgradePathSupported(CurrentVersion, TargetVersion) then
            Error('Upgrade from version %1 to %2 is not supported. Please upgrade to intermediate version first.', 
                  CurrentVersion, TargetVersion);
    end;
    
    local procedure IsUpgradePathSupported(FromVersion: Version; ToVersion: Version): Boolean
    begin
        // Define supported upgrade paths
        // Example: Cannot skip major versions
        if (ToVersion.Major - FromVersion.Major) > 1 then
            exit(false);
            
        exit(true);
    end;
}
```

---

## Version Strategy

### Semantic Versioning for BC

```al
// app.json version strategy
{
    "version": "1.5.2.0",
    // Major.Minor.Patch.Build
    // Major: Breaking changes (require upgrade procedures)
    // Minor: New features (backward compatible)
    // Patch: Bug fixes (backward compatible)  
    // Build: Internal builds/hotfixes
}
```

### Feature Flag Pattern

```al
codeunit 50100 "Feature Management"
{
    procedure IsNewFeatureEnabled(): Boolean
    var
        FeatureManagement: Codeunit "Feature Management Facade";
    begin
        // Use BC's feature management for controlled rollouts
        exit(FeatureManagement.IsEnabled('MyExtension-NewCustomerValidation'));
    end;
    
    procedure EnableNewCustomerWorkflow()
    begin
        if IsNewFeatureEnabled() then
            ProcessWithNewWorkflow()
        else
            ProcessWithLegacyWorkflow(); // Maintain old behavior during transition
    end;
}
```

### Migration Tracking

```al
table 50100 "Migration Log"
{
    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Migration Tag"; Text[250]) { }
        field(3; "Migration Date"; DateTime) { }
        field(4; "Records Processed"; Integer) { }
        field(5; "Records Failed"; Integer) { }
        field(6; "Error Details"; Blob) { }
        field(7; "Duration (ms)"; Integer) { }
    }
}

procedure LogMigrationResult(Tag: Text; ProcessedCount: Integer; FailedCount: Integer; StartTime: DateTime)
var
    MigrationLog: Record "Migration Log";
begin
    MigrationLog.Init();
    MigrationLog."Migration Tag" := Tag;
    MigrationLog."Migration Date" := CurrentDateTime;
    MigrationLog."Records Processed" := ProcessedCount;
    MigrationLog."Records Failed" := FailedCount;
    MigrationLog."Duration (ms)" := CurrentDateTime - StartTime;
    MigrationLog.Insert();
end;
```

---

## Best Practices Summary

### ✅ DO This

1. **Always use upgrade tags** for idempotent upgrades
2. **Use DataTransfer** for bulk data operations
3. **Plan obsolete timeline** (PendingObsolete → Obsolete → Removed)
4. **Version APIs explicitly** with clear migration paths
5. **Test upgrade scenarios** in sandbox environments
6. **Document breaking changes** in release notes
7. **Provide migration tools** for complex data transformations

### ❌ DON'T Do This

1. **Skip upgrade tags** - causes duplicate processing
2. **Remove fields immediately** - breaks AppSource compliance
3. **Change event signatures** without backward compatibility
4. **Break API contracts** without versioning
5. **Ignore migration failures** - always log and handle
6. **Remove obsolete items too quickly** - follow deprecation timeline

---

## AI Prompting for Upgrades

### Good Prompts for Migration

```al
// ✅ Ask Copilot for upgrade guidance:
"Create an upgrade codeunit with proper tags for migrating this table structure"
"Design a DataTransfer pattern for bulk customer data migration"  
"Show me how to obsolete this field following AppSource compliance"
"Create a versioned API that maintains backward compatibility"
"Design feature flags for controlled rollout of this new functionality"
```

### Validation Prompts

```al
// ✅ Validate upgrade safety:
"Review this upgrade procedure for potential data loss"
"Check this obsolete pattern for AppSource compliance"
"Validate this migration handles all edge cases"
"Ensure this API change maintains backward compatibility"
```

---

**Proper upgrade management ensures your extensions can evolve safely while maintaining customer trust and AppSource compliance!** 🔄✨

*Remember: Upgrades are not just technical - they're about maintaining relationships with users who depend on your solution.*
