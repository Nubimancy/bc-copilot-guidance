---
title: "BC Data Upgrade Patterns Implementation Samples"
description: "Working AL implementations for Business Central data upgrade patterns using upgrade codeunits, data migration tools, and BC platform upgrade procedures"
area: "data-management"
difficulty: "advanced"
object_types: ["Codeunit", "Table", "XmlPort", "Page"]
variable_types: ["Record", "RecordRef", "FieldRef", "Boolean", "DataUpgrade"]
tags: ["bc-data-upgrade", "upgrade-codeunits", "data-migration", "version-upgrade", "bc-platform"]
---

# BC Data Upgrade Patterns Implementation Samples

## Upgrade Codeunit Implementation

### Standard BC Upgrade Codeunit Pattern

```al
// Upgrade codeunit following BC standard patterns
codeunit 50500 "Custom Extension Upgrade"
{
    Subtype = Upgrade;
    
    trigger OnUpgradePerCompany()
    begin
        UpdateCustomFieldsV1_0();
        MigrateObsoleteTablesV1_1();
        UpdateNumberSeriesV1_2();
    end;
    
    trigger OnUpgradePerDatabase()
    begin
        UpdateGlobalSettingsV1_0();
        CreateDefaultConfigurationV1_1();
    end;
    
    [Upgrade('', '1.0.0.0')]
    internal procedure UpdateCustomFieldsV1_0()
    var
        Customer: Record Customer;
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Custom Upgrade Tags";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetCustomerFieldsUpgradeTag()) then
            exit;
        
        // Update custom fields added in version 1.0
        Customer.SetLoadFields("No.", "Name", "Phone No.");
        if Customer.FindSet(true) then
            repeat
                if Customer."Phone No." = '' then begin
                    Customer."Phone No." := GetDefaultPhoneNumber(Customer."No.");
                    Customer.Modify(true);
                end;
            until Customer.Next() = 0;
        
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetCustomerFieldsUpgradeTag());
    end;
    
    [Upgrade('1.0.0.0', '1.1.0.0')]
    internal procedure MigrateObsoleteTablesV1_1()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Custom Upgrade Tags";
        ObsoleteDataMigration: Codeunit "Obsolete Data Migration";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetObsoleteTableMigrationTag()) then
            exit;
        
        // Migrate data from obsolete table to new structure
        ObsoleteDataMigration.MigrateCustomerCategoriesData();
        ObsoleteDataMigration.MigrateProductCategoriesData();
        
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetObsoleteTableMigrationTag());
    end;
    
    [Upgrade('1.1.0.0', '1.2.0.0')]
    internal procedure UpdateNumberSeriesV1_2()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Custom Upgrade Tags";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetNumberSeriesUpgradeTag()) then
            exit;
        
        // Create new number series for custom documents
        if not NoSeries.Get('CUSORD') then begin
            NoSeries.Init();
            NoSeries.Code := 'CUSORD';
            NoSeries.Description := 'Custom Orders';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := false;
            NoSeries.Insert(true);
            
            // Create number series line
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NoSeries.Code;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'CO-001';
            NoSeriesLine."Ending No." := 'CO-999999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;
        
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetNumberSeriesUpgradeTag());
    end;
    
    internal procedure UpdateGlobalSettingsV1_0()
    var
        CustomSetup: Record "Custom Extension Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Custom Upgrade Tags";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetGlobalSettingsUpgradeTag()) then
            exit;
        
        // Create default setup record if it doesn't exist
        if not CustomSetup.Get() then begin
            CustomSetup.Init();
            CustomSetup."Primary Key" := '';
            CustomSetup."Enable Custom Processing" := true;
            CustomSetup."Default Category Code" := 'GENERAL';
            CustomSetup.Insert(true);
        end;
        
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetGlobalSettingsUpgradeTag());
    end;
    
    local procedure GetDefaultPhoneNumber(CustomerNo: Code[20]): Text[30]
    var
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        // Try to get phone number from related contact
        if Customer.Get(CustomerNo) then begin
            Contact.SetRange("No.", Customer."Primary Contact No.");
            if Contact.FindFirst() then
                exit(Contact."Phone No.");
        end;
        
        exit('');
    end;
}

// Upgrade tag definitions for tracking completed procedures
codeunit 50501 "Custom Upgrade Tags"
{
    procedure GetCustomerFieldsUpgradeTag(): Code[250]
    begin
        exit('MS-123456-CustomerFields-20240101');
    end;
    
    procedure GetObsoleteTableMigrationTag(): Code[250]
    begin
        exit('MS-123456-ObsoleteTableMigration-20240201');
    end;
    
    procedure GetNumberSeriesUpgradeTag(): Code[250]
    begin
        exit('MS-123456-NumberSeries-20240301');
    end;
    
    procedure GetGlobalSettingsUpgradeTag(): Code[250]
    begin
        exit('MS-123456-GlobalSettings-20240101');
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetCustomerFieldsUpgradeTag());
        PerCompanyUpgradeTags.Add(GetObsoleteTableMigrationTag());
        PerCompanyUpgradeTags.Add(GetNumberSeriesUpgradeTag());
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetGlobalSettingsUpgradeTag());
    end;
}
```

## Obsolete Data Migration Patterns

### Handling Obsolete Table Migration

```al
// Codeunit for migrating data from obsolete tables
codeunit 50502 "Obsolete Data Migration"
{
    procedure MigrateCustomerCategoriesData()
    var
        ObsoleteCustomerCategory: Record "Obsolete Customer Category";
        Customer: Record Customer;
        CustomerCategory: Record "Customer Category";
        RecordCount: Integer;
        ProcessedCount: Integer;
    begin
        // Check if obsolete table exists (may have been removed)
        if not ObsoleteCustomerCategory.ReadPermission then
            exit;
        
        RecordCount := ObsoleteCustomerCategory.Count;
        if RecordCount = 0 then
            exit;
        
        // Create progress dialog
        Window.Open('Migrating Customer Categories\\' +
                   'Progress: @1@@@@@@@@@@@@@@@@@@@@@@@@@');
        
        // Migrate customer category data
        ObsoleteCustomerCategory.SetLoadFields("Customer No.", "Category Code", Description);
        if ObsoleteCustomerCategory.FindSet() then
            repeat
                ProcessedCount += 1;
                Window.Update(1, Round(ProcessedCount / RecordCount * 10000, 1));
                
                // Create new customer category record
                if not CustomerCategory.Get(ObsoleteCustomerCategory."Customer No.", ObsoleteCustomerCategory."Category Code") then begin
                    CustomerCategory.Init();
                    CustomerCategory."Customer No." := ObsoleteCustomerCategory."Customer No.";
                    CustomerCategory."Category Code" := ObsoleteCustomerCategory."Category Code";
                    CustomerCategory.Description := ObsoleteCustomerCategory.Description;
                    CustomerCategory."Migration Date" := Today;
                    CustomerCategory."Migrated From Version" := '1.0.0.0';
                    CustomerCategory.Insert(true);
                end;
                
                // Update customer with primary category
                if Customer.Get(ObsoleteCustomerCategory."Customer No.") then begin
                    if Customer."Primary Category Code" = '' then begin
                        Customer."Primary Category Code" := ObsoleteCustomerCategory."Category Code";
                        Customer.Modify(true);
                    end;
                end;
            until ObsoleteCustomerCategory.Next() = 0;
        
        Window.Close();
        
        // Log migration results
        Session.LogMessage('MIGRATE001',
                          StrSubstNo('Migrated %1 customer category records', ProcessedCount),
                          Verbosity::Normal,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher,
                          'Category', 'Data Migration');
    end;
    
    procedure MigrateProductCategoriesData()
    var
        ObsoleteProductCategory: Record "Obsolete Product Category";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ItemCategoryCode: Code[20];
    begin
        if not ObsoleteProductCategory.ReadPermission then
            exit;
        
        ObsoleteProductCategory.SetLoadFields("Product Code", "Category Name", Description);
        if ObsoleteProductCategory.FindSet() then
            repeat
                // Create item category if it doesn't exist
                ItemCategoryCode := CopyStr(ObsoleteProductCategory."Category Name", 1, 20);
                if not ItemCategory.Get(ItemCategoryCode) then begin
                    ItemCategory.Init();
                    ItemCategory.Code := ItemCategoryCode;
                    ItemCategory.Description := ObsoleteProductCategory.Description;
                    ItemCategory."Parent Category" := '';
                    ItemCategory.Insert(true);
                end;
                
                // Update item with category
                if Item.Get(ObsoleteProductCategory."Product Code") then begin
                    Item."Item Category Code" := ItemCategoryCode;
                    Item.Modify(true);
                end;
            until ObsoleteProductCategory.Next() = 0;
    end;
    
    var
        Window: Dialog;
}

// Example obsolete table structure (for reference)
table 50500 "Obsolete Customer Category"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced by new Customer Category structure in version 1.1';
    ObsoleteTag = '1.1.0.0';
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        
        field(2; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
        }
        
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
    }
    
    keys
    {
        key(PK; "Customer No.", "Category Code")
        {
            Clustered = true;
        }
    }
}

// New table structure
table 50501 "Customer Category"
{
    Caption = 'Customer Category';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        
        field(2; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            TableRelation = "Category Master";
        }
        
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        
        field(4; "Migration Date"; Date)
        {
            Caption = 'Migration Date';
            DataClassification = SystemMetadata;
        }
        
        field(5; "Migrated From Version"; Text[30])
        {
            Caption = 'Migrated From Version';
            DataClassification = SystemMetadata;
        }
    }
    
    keys
    {
        key(PK; "Customer No.", "Category Code")
        {
            Clustered = true;
        }
    }
}
```

## Configuration Package Migration

### Data Migration using Configuration Packages

```al
// Codeunit for configuration package-based data migration
codeunit 50503 "Config Package Migration"
{
    procedure ImportCustomerDataFromPackage(PackageCode: Code[20]): Boolean
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        TempConfigPackageError: Record "Config. Package Error" temporary;
        ImportSuccess: Boolean;
    begin
        if not ConfigPackage.Get(PackageCode) then
            Error('Configuration package %1 not found.', PackageCode);
        
        // Validate package before import
        ConfigValidateMgt.ValidatePackage(ConfigPackage, TempConfigPackageError, true);
        if not TempConfigPackageError.IsEmpty then begin
            ShowPackageErrors(TempConfigPackageError);
            exit(false);
        end;
        
        // Apply data from configuration package
        ConfigPackageTable.SetRange("Package Code", PackageCode);
        ConfigPackageTable.SetRange("Table ID", Database::Customer);
        if ConfigPackageTable.FindFirst() then begin
            ImportSuccess := ConfigPackageMgt.ApplyPackage(ConfigPackage, ConfigPackageTable, true);
            
            if ImportSuccess then
                LogSuccessfulImport(PackageCode, ConfigPackageTable."Table ID")
            else
                LogFailedImport(PackageCode, ConfigPackageTable."Table ID");
        end;
        
        exit(ImportSuccess);
    end;
    
    procedure CreateCustomerMigrationPackage(): Code[20]
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
        Customer: Record Customer;
        PackageCode: Code[20];
    begin
        PackageCode := 'CUSTMIGR';
        
        // Create configuration package
        ConfigPackage.Init();
        ConfigPackage.Code := PackageCode;
        ConfigPackage."Package Name" := 'Customer Migration Package';
        ConfigPackage."Language ID" := GlobalLanguage;
        ConfigPackage.Insert(true);
        
        // Add Customer table to package
        ConfigPackageTable.Init();
        ConfigPackageTable."Package Code" := PackageCode;
        ConfigPackageTable."Table ID" := Database::Customer;
        ConfigPackageTable."Table Name" := Customer.TableCaption;
        ConfigPackageTable."Data Template" := 'CUSTOMER';
        ConfigPackageTable.Insert(true);
        
        // Configure essential fields
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo("No."), true, true);
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo(Name), true, false);
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo(Address), false, false);
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo(City), false, false);
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo("Phone No."), false, false);
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo("E-Mail"), false, false);
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo("Customer Posting Group"), true, false);
        AddPackageField(PackageCode, Database::Customer, Customer.FieldNo("Gen. Bus. Posting Group"), true, false);
        
        exit(PackageCode);
    end;
    
    local procedure AddPackageField(PackageCode: Code[20]; TableID: Integer; FieldID: Integer; IsPrimaryKey: Boolean; ValidateField: Boolean)
    var
        ConfigPackageField: Record "Config. Package Field";
        Field: Record Field;
    begin
        if Field.Get(TableID, FieldID) then begin
            ConfigPackageField.Init();
            ConfigPackageField."Package Code" := PackageCode;
            ConfigPackageField."Table ID" := TableID;
            ConfigPackageField."Field ID" := FieldID;
            ConfigPackageField."Field Name" := Field.FieldName;
            ConfigPackageField."Field Caption" := Field."Field Caption";
            ConfigPackageField."Primary Key" := IsPrimaryKey;
            ConfigPackageField."Validate Field" := ValidateField;
            ConfigPackageField."Include Field" := true;
            ConfigPackageField.Insert(true);
        end;
    end;
    
    local procedure ShowPackageErrors(var TempConfigPackageError: Record "Config. Package Error" temporary)
    var
        ErrorText: Text;
    begin
        if TempConfigPackageError.FindSet() then
            repeat
                ErrorText += TempConfigPackageError."Error Text" + '\';
            until TempConfigPackageError.Next() = 0;
        
        if ErrorText <> '' then
            Message('Package validation errors:\\%1', ErrorText);
    end;
    
    local procedure LogSuccessfulImport(PackageCode: Code[20]; TableID: Integer)
    begin
        Session.LogMessage('MIGRATE002',
                          StrSubstNo('Successfully imported data from package %1 for table %2', PackageCode, TableID),
                          Verbosity::Normal,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher,
                          'Category', 'Configuration Package');
    end;
    
    local procedure LogFailedImport(PackageCode: Code[20]; TableID: Integer)
    begin
        Session.LogMessage('MIGRATE003',
                          StrSubstNo('Failed to import data from package %1 for table %2', PackageCode, TableID),
                          Verbosity::Error,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher,
                          'Category', 'Configuration Package');
    end;
}
```

## RapidStart Integration

### RapidStart Services for Data Migration

```al
// RapidStart integration for efficient data migration
codeunit 50504 "RapidStart Migration Manager"
{
    procedure SetupCustomerMigrationWorksheet(): Code[20]
    var
        ConfigLine: Record "Config. Line";
        ConfigPackageTable: Record "Config. Package Table";
        Customer: Record Customer;
        LineNo: Integer;
        PackageCode: Code[20];
    begin
        PackageCode := 'RAPIDCUST';
        LineNo := 10000;
        
        // Create main group
        CreateConfigLine(ConfigLine, LineNo, ConfigLine."Line Type"::Group, 
                        'CUSTOMERS', 'Customer Migration', '', '', 0);
        
        // Add Customer table
        LineNo += 10000;
        CreateConfigLine(ConfigLine, LineNo, ConfigLine."Line Type"::"Table", 
                        '', Customer.TableCaption, PackageCode, '', Database::Customer);
        
        // Add related tables
        LineNo += 10000;
        CreateConfigLine(ConfigLine, LineNo, ConfigLine."Line Type"::"Table", 
                        '', 'Customer Posting Groups', PackageCode, '', Database::"Customer Posting Group");
        
        LineNo += 10000;
        CreateConfigLine(ConfigLine, LineNo, ConfigLine."Line Type"::"Table", 
                        '', 'Gen. Business Posting Groups', PackageCode, '', Database::"Gen. Business Posting Group");
        
        // Create configuration packages for each table
        CreateCustomerConfigurationPackage(PackageCode);
        
        exit(PackageCode);
    end;
    
    local procedure CreateConfigLine(var ConfigLine: Record "Config. Line"; LineNo: Integer; LineType: Option; 
                                    Name: Text[30]; Description: Text[250]; PackageCode: Code[20]; 
                                    TableCaption: Text[250]; TableID: Integer)
    begin
        ConfigLine.Init();
        ConfigLine."Line No." := LineNo;
        ConfigLine."Line Type" := LineType;
        ConfigLine.Name := Name;
        ConfigLine.Description := Description;
        ConfigLine."Package Code" := PackageCode;
        ConfigLine."Table Caption" := TableCaption;
        ConfigLine."Table ID" := TableID;
        ConfigLine."Responsible ID" := UserId;
        ConfigLine.Status := ConfigLine.Status::"In Progress";
        ConfigLine.Insert(true);
    end;
    
    procedure ExecuteRapidStartMigration(PackageCode: Code[20])
    var
        ConfigLine: Record "Config. Line";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        ConfigMgt: Codeunit "Config. Management";
        Window: Dialog;
        TotalLines: Integer;
        ProcessedLines: Integer;
    begin
        ConfigLine.SetRange("Package Code", PackageCode);
        ConfigLine.SetRange("Line Type", ConfigLine."Line Type"::"Table");
        TotalLines := ConfigLine.Count;
        
        if TotalLines = 0 then
            exit;
        
        Window.Open('Processing RapidStart Migration\\' +
                   'Table: #1####################\\' +
                   'Progress: @2@@@@@@@@@@@@@@@@@@@@@@@@@');
        
        if ConfigLine.FindSet(true) then
            repeat
                ProcessedLines += 1;
                Window.Update(1, ConfigLine."Table Caption");
                Window.Update(2, Round(ProcessedLines / TotalLines * 10000, 1));
                
                // Apply configuration for each table
                if ConfigLine."Table ID" <> 0 then begin
                    ConfigMgt.ApplyConfigTables(ConfigLine);
                    ConfigLine.Status := ConfigLine.Status::Completed;
                    ConfigLine.Modify(true);
                end;
            until ConfigLine.Next() = 0;
        
        Window.Close();
        
        // Generate completion report
        GenerateMigrationReport(PackageCode);
    end;
    
    local procedure CreateCustomerConfigurationPackage(PackageCode: Code[20])
    var
        ConfigPackage: Record "Config. Package";
        ConfigMgt: Codeunit "Config. Management";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        // Create package if it doesn't exist
        if not ConfigPackage.Get(PackageCode) then begin
            ConfigPackage.Init();
            ConfigPackage.Code := PackageCode;
            ConfigPackage."Package Name" := 'RapidStart Customer Migration';
            ConfigPackage.Insert(true);
        end;
        
        // Add tables to package with proper field selection
        ConfigMgt.InsertToConfigLine(ConfigPackage.Code, Database::Customer, '', true, false);
        ConfigMgt.InsertToConfigLine(ConfigPackage.Code, Database::"Customer Posting Group", '', true, false);
        ConfigMgt.InsertToConfigLine(ConfigPackage.Code, Database::"Gen. Business Posting Group", '', true, false);
        
        // Apply field selection and validation rules
        ConfigPackageMgt.SelectAllPackageFields(ConfigPackage.Code, false);
        ConfigPackageMgt.SetFieldFilter(ConfigPackage.Code, Database::Customer, 'No.|Name|Address|City|Phone No.|E-Mail');
    end;
    
    local procedure GenerateMigrationReport(PackageCode: Code[20])
    var
        ConfigLine: Record "Config. Line";
        ConfigPackageRecord: Record "Config. Package Record";
        TotalRecords: Integer;
        ErrorRecords: Integer;
        ReportText: Text;
    begin
        ConfigLine.SetRange("Package Code", PackageCode);
        ConfigLine.SetRange("Line Type", ConfigLine."Line Type"::"Table");
        
        if ConfigLine.FindSet() then
            repeat
                ConfigPackageRecord.SetRange("Package Code", PackageCode);
                ConfigPackageRecord.SetRange("Table ID", ConfigLine."Table ID");
                TotalRecords += ConfigPackageRecord.Count;
                
                ConfigPackageRecord.SetRange(Invalid, true);
                ErrorRecords += ConfigPackageRecord.Count;
                ConfigPackageRecord.SetRange(Invalid);
            until ConfigLine.Next() = 0;
        
        ReportText := StrSubstNo('Migration completed for package %1\\' +
                                'Total records processed: %2\\' +
                                'Records with errors: %3', 
                                PackageCode, TotalRecords, ErrorRecords);
        
        Message(ReportText);
        
        // Log to telemetry
        Session.LogMessage('MIGRATE004', ReportText, Verbosity::Normal,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher,
                          'Category', 'RapidStart Migration');
    end;
}
```

## Data Validation and Quality Control

### Comprehensive Data Validation

```al
// Data validation during upgrade and migration
codeunit 50505 "Data Migration Validator"
{
    procedure ValidateCustomerDataIntegrity(): Boolean
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        ValidationErrors: List of [Text];
        ErrorCount: Integer;
    begin
        // Validate customer posting groups
        Customer.SetLoadFields("No.", "Customer Posting Group", "Gen. Bus. Posting Group");
        if Customer.FindSet() then
            repeat
                if Customer."Customer Posting Group" = '' then
                    ValidationErrors.Add(StrSubstNo('Customer %1 has no Customer Posting Group', Customer."No."));
                    
                if Customer."Gen. Bus. Posting Group" = '' then
                    ValidationErrors.Add(StrSubstNo('Customer %1 has no Gen. Bus. Posting Group', Customer."No."));
                    
                // Validate posting group exists
                if (Customer."Customer Posting Group" <> '') and 
                   (not CustomerPostingGroup.Get(Customer."Customer Posting Group")) then
                    ValidationErrors.Add(StrSubstNo('Customer %1 has invalid Customer Posting Group %2', 
                                        Customer."No.", Customer."Customer Posting Group"));
                
                // Validate gen. bus. posting group exists
                if (Customer."Gen. Bus. Posting Group" <> '') and 
                   (not GenBusPostingGroup.Get(Customer."Gen. Bus. Posting Group")) then
                    ValidationErrors.Add(StrSubstNo('Customer %1 has invalid Gen. Bus. Posting Group %2', 
                                        Customer."No.", Customer."Gen. Bus. Posting Group"));
            until Customer.Next() = 0;
        
        ErrorCount := ValidationErrors.Count;
        if ErrorCount > 0 then
            LogValidationErrors(ValidationErrors);
        
        exit(ErrorCount = 0);
    end;
    
    procedure ValidateNumberSeriesIntegrity(): Boolean
    var
        Customer: Record Customer;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        ValidationSuccess: Boolean;
    begin
        ValidationSuccess := true;
        
        // Validate customer number series
        SalesSetup.Get();
        if SalesSetup."Customer Nos." <> '' then begin
            if not NoSeries.Get(SalesSetup."Customer Nos.") then begin
                LogValidationError(StrSubstNo('Customer number series %1 does not exist', SalesSetup."Customer Nos."));
                ValidationSuccess := false;
            end else begin
                NoSeriesLine.SetRange("Series Code", SalesSetup."Customer Nos.");
                if NoSeriesLine.IsEmpty then begin
                    LogValidationError(StrSubstNo('Customer number series %1 has no lines defined', SalesSetup."Customer Nos."));
                    ValidationSuccess := false;
                end;
            end;
        end;
        
        // Validate no duplicate customer numbers
        Customer.SetCurrentKey("No.");
        Customer.SetLoadFields("No.");
        if Customer.FindSet() then begin
            repeat
                Customer.SetRange("No.", Customer."No.");
                if Customer.Count > 1 then begin
                    LogValidationError(StrSubstNo('Duplicate customer number found: %1', Customer."No."));
                    ValidationSuccess := false;
                end;
                Customer.SetRange("No.");
            until Customer.Next() = 0;
        end;
        
        exit(ValidationSuccess);
    end;
    
    procedure ValidateDimensionIntegrity(): Boolean
    var
        Customer: Record Customer;
        DefaultDimension: Record "Default Dimension";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        ValidationSuccess: Boolean;
    begin
        ValidationSuccess := true;
        
        // Validate default dimensions
        DefaultDimension.SetRange("Table ID", Database::Customer);
        DefaultDimension.SetLoadFields("No.", "Dimension Code", "Dimension Value Code");
        if DefaultDimension.FindSet() then
            repeat
                // Check if dimension exists
                if not Dimension.Get(DefaultDimension."Dimension Code") then begin
                    LogValidationError(StrSubstNo('Invalid dimension %1 for customer %2', 
                                      DefaultDimension."Dimension Code", DefaultDimension."No."));
                    ValidationSuccess := false;
                end;
                
                // Check if dimension value exists
                if not DimensionValue.Get(DefaultDimension."Dimension Code", DefaultDimension."Dimension Value Code") then begin
                    LogValidationError(StrSubstNo('Invalid dimension value %1 for dimension %2 on customer %3', 
                                      DefaultDimension."Dimension Value Code", 
                                      DefaultDimension."Dimension Code", 
                                      DefaultDimension."No."));
                    ValidationSuccess := false;
                end;
            until DefaultDimension.Next() = 0;
        
        exit(ValidationSuccess);
    end;
    
    local procedure LogValidationErrors(ValidationErrors: List of [Text])
    var
        ErrorText: Text;
        i: Integer;
    begin
        for i := 1 to ValidationErrors.Count do begin
            ValidationErrors.Get(i, ErrorText);
            LogValidationError(ErrorText);
        end;
    end;
    
    local procedure LogValidationError(ErrorText: Text)
    begin
        Session.LogMessage('VALIDATE001', ErrorText, Verbosity::Error,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher,
                          'Category', 'Data Validation');
    end;
}
```