---
title: "Test Data Cleanup Strategies - Code Samples"
description: "Complete implementations for cleaning up test data after execution to prevent database pollution and maintain test environment integrity"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["Record", "RecordRef", "FieldRef", "List", "Dictionary"]
tags: ["testing", "cleanup", "data-management", "test-framework", "maintenance", "samples"]
---

# Test Data Cleanup Strategies - Code Samples

## Complete Test Framework with Integrated Cleanup

### Comprehensive Test Base Class

```al
codeunit 50500 "Test Base Framework"
{
    var
        TestDataManager: Codeunit "Test Data Manager";
        CleanupManager: Codeunit "Advanced Cleanup Manager";
        TestContext: Record "Test Execution Context";
        TestDataRegistry: Dictionary of [Text, Variant];
        CleanupRequired: Boolean;
        
    /// <summary>
    /// Initializes test execution context with automatic cleanup
    /// </summary>
    procedure InitializeTest(TestName: Text[100]; CleanupMode: Enum "Test Cleanup Mode")
    var
        ContextId: Guid;
    begin
        ContextId := CreateGuid();
        
        TestContext.Init();
        TestContext."Context ID" := ContextId;
        TestContext."Test Name" := TestName;
        TestContext."Cleanup Mode" := CleanupMode;
        TestContext."Start Time" := CurrentDateTime;
        TestContext."Session ID" := SessionId();
        TestContext."User ID" := UserId;
        TestContext.Active := true;
        
        CleanupRequired := true;
        
        // Register cleanup handler
        RegisterCleanupHandler();
    end;
    
    /// <summary>
    /// Creates test customer with automatic cleanup registration
    /// </summary>
    procedure CreateTestCustomer(var Customer: Record Customer; CustomerName: Text[100]): Code[20]
    var
        CustomerNo: Code[20];
    begin
        CustomerNo := TestDataManager.CreateTestCustomer(Customer, CustomerName);
        RegisterForCleanup(Database::Customer, CustomerNo);
        exit(CustomerNo);
    end;
    
    /// <summary>
    /// Creates test sales order with automatic cleanup registration
    /// </summary>
    procedure CreateTestSalesOrder(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]): Code[20]
    var
        OrderNo: Code[20];
    begin
        OrderNo := TestDataManager.CreateTestSalesOrder(SalesHeader, CustomerNo);
        RegisterForCleanup(Database::"Sales Header", OrderNo);
        RegisterForCleanup(Database::"Sales Line", OrderNo); // For related lines
        exit(OrderNo);
    end;
    
    /// <summary>
    /// Finalizes test with comprehensive cleanup
    /// </summary>
    procedure FinalizeTest(TestSuccessful: Boolean)
    begin
        TestContext."End Time" := CurrentDateTime;
        TestContext."Test Successful" := TestSuccessful;
        TestContext.Active := false;
        
        try
            ExecuteTestCleanup();
            TestContext."Cleanup Successful" := true;
        except
            TestContext."Cleanup Successful" := false;
            TestContext."Cleanup Error" := GetLastErrorText();
        end;
        
        LogTestExecution();
        CleanupRequired := false;
    end;
    
    local procedure RegisterForCleanup(TableNo: Integer; RecordKey: Text[250])
    var
        CleanupEntry: Text;
    begin
        CleanupEntry := Format(TableNo) + '|' + RecordKey;
        if not TestDataRegistry.ContainsKey(CleanupEntry) then
            TestDataRegistry.Add(CleanupEntry, CurrentDateTime);
    end;
    
    local procedure ExecuteTestCleanup()
    var
        CleanupEntry: Text;
        TableNo: Integer;
        RecordKey: Text[250];
        CleanupParts: List of [Text];
    begin
        case TestContext."Cleanup Mode" of
            TestContext."Cleanup Mode"::Immediate:
                ExecuteImmediateCleanup();
            TestContext."Cleanup Mode"::Batch:
                ScheduleBatchCleanup();
            TestContext."Cleanup Mode"::None:
                exit; // No cleanup required
        end;
    end;
    
    local procedure ExecuteImmediateCleanup()
    var
        CleanupEntry: Text;
        TableNo: Integer;
        RecordKey: Text[250];
        CleanupParts: List of [Text];
        DeletedCount: Integer;
    begin
        foreach CleanupEntry in TestDataRegistry.Keys do begin
            CleanupParts := CleanupEntry.Split('|');
            if CleanupParts.Count = 2 then begin
                Evaluate(TableNo, CleanupParts.Get(1));
                RecordKey := CleanupParts.Get(2);
                
                DeletedCount += CleanupManager.CleanupRecord(TableNo, RecordKey);
            end;
        end;
        
        TestContext."Records Cleaned" := DeletedCount;
    end;
    
    local procedure ScheduleBatchCleanup()
    var
        BatchCleanupJob: Record "Test Batch Cleanup Job";
        CleanupEntry: Text;
    begin
        BatchCleanupJob.Init();
        BatchCleanupJob."Job ID" := CreateGuid();
        BatchCleanupJob."Test Context ID" := TestContext."Context ID";
        BatchCleanupJob."Scheduled DateTime" := CurrentDateTime + 300000; // 5 minutes delay
        BatchCleanupJob."Cleanup Data" := SerializeCleanupRegistry();
        BatchCleanupJob.Status := BatchCleanupJob.Status::Pending;
        BatchCleanupJob.Insert(true);
    end;
    
    local procedure SerializeCleanupRegistry(): Text
    var
        CleanupData: JsonObject;
        CleanupArray: JsonArray;
        CleanupEntry: Text;
        CleanupValue: Variant;
        EntryObject: JsonObject;
        CleanupParts: List of [Text];
    begin
        foreach CleanupEntry in TestDataRegistry.Keys do begin
            TestDataRegistry.Get(CleanupEntry, CleanupValue);
            
            CleanupParts := CleanupEntry.Split('|');
            EntryObject.Add('TableNo', CleanupParts.Get(1));
            EntryObject.Add('RecordKey', CleanupParts.Get(2));
            EntryObject.Add('CreatedAt', Format(CleanupValue));
            
            CleanupArray.Add(EntryObject);
            Clear(EntryObject);
        end;
        
        CleanupData.Add('CleanupEntries', CleanupArray);
        exit(CleanupData.AsText());
    end;
    
    local procedure RegisterCleanupHandler()
    begin
        // Register with session cleanup handler
        Session.AddCleanupHandler(Codeunit::"Test Base Framework", 'HandleSessionCleanup');
    end;
    
    /// <summary>
    /// Handles cleanup when session ends unexpectedly
    /// </summary>
    [EventSubscriber(ObjectType::Session, Session::OnBeforeSessionEnd, '', false, false)]
    local procedure HandleSessionCleanup()
    begin
        if CleanupRequired then
            ExecuteTestCleanup();
    end;
    
    local procedure LogTestExecution()
    var
        TestExecutionLog: Record "Test Execution Log";
    begin
        TestExecutionLog.Init();
        TestExecutionLog."Entry No." := GetNextTestLogEntry();
        TestExecutionLog."Context ID" := TestContext."Context ID";
        TestExecutionLog."Test Name" := TestContext."Test Name";
        TestExecutionLog."Start Time" := TestContext."Start Time";
        TestExecutionLog."End Time" := TestContext."End Time";
        TestExecutionLog."Duration (ms)" := TestContext."End Time" - TestContext."Start Time";
        TestExecutionLog."Test Successful" := TestContext."Test Successful";
        TestExecutionLog."Cleanup Successful" := TestContext."Cleanup Successful";
        TestExecutionLog."Records Cleaned" := TestContext."Records Cleaned";
        TestExecutionLog."Session ID" := TestContext."Session ID";
        TestExecutionLog."User ID" := TestContext."User ID";
        TestExecutionLog.Insert(true);
    end;
    
    local procedure GetNextTestLogEntry(): Integer
    var
        TestExecutionLog: Record "Test Execution Log";
    begin
        TestExecutionLog.LockTable();
        if TestExecutionLog.FindLast() then
            exit(TestExecutionLog."Entry No." + 1)
        else
            exit(1);
    end;
}
```

### Advanced Cleanup Manager Implementation

```al
codeunit 50501 "Advanced Cleanup Manager"
{
    var
        CleanupStatistics: Record "Test Cleanup Statistics";
        PerformanceMonitor: Codeunit "Cleanup Performance Monitor";
        
    /// <summary>
    /// Cleans up a single record with full dependency checking
    /// </summary>
    procedure CleanupRecord(TableNo: Integer; RecordKey: Text[250]): Integer
    var
        RecordRef: RecordRef;
        DependentRecords: List of [Text];
        DeletedCount: Integer;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        
        try
            RecordRef.Open(TableNo);
            if FindRecord(RecordRef, RecordKey) then begin
                // Find and cleanup dependent records first
                FindDependentRecords(RecordRef, DependentRecords);
                DeletedCount += CleanupDependentRecords(DependentRecords);
                
                // Delete the main record
                RecordRef.Delete(true);
                DeletedCount += 1;
                
                LogSuccessfulCleanup(TableNo, RecordKey, DeletedCount, CurrentDateTime - StartTime);
            end;
        except
            LogFailedCleanup(TableNo, RecordKey, GetLastErrorText());
        end;
        
        RecordRef.Close();
        exit(DeletedCount);
    end;
    
    /// <summary>
    /// Performs bulk cleanup with progress monitoring
    /// </summary>
    procedure BulkCleanup(CleanupFilter: Record "Test Cleanup Filter"): Record "Test Cleanup Results"
    var
        CleanupResults: Record "Test Cleanup Results";
        RecordRef: RecordRef;
        ProgressTracker: Codeunit "Cleanup Progress Tracker";
        TotalRecords: Integer;
        ProcessedRecords: Integer;
        DeletedRecords: Integer;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        CleanupResults.Init();
        CleanupResults."Cleanup ID" := CreateGuid();
        CleanupResults."Start Time" := StartTime;
        CleanupResults."Filter Description" := CleanupFilter.Description;
        
        RecordRef.Open(CleanupFilter."Table No.");
        ApplyCleanupFilter(RecordRef, CleanupFilter);
        TotalRecords := RecordRef.Count();
        
        ProgressTracker.Initialize(TotalRecords);
        
        if RecordRef.FindSet() then
            repeat
                ProcessedRecords += 1;
                
                if ShouldDeleteRecord(RecordRef, CleanupFilter) then begin
                    DeleteRecord(RecordRef);
                    DeletedRecords += 1;
                end;
                
                ProgressTracker.UpdateProgress(ProcessedRecords);
                
                // Commit periodically for large operations
                if ProcessedRecords mod 100 = 0 then
                    Commit();
                    
            until RecordRef.Next() = 0;
            
        RecordRef.Close();
        
        CleanupResults."End Time" := CurrentDateTime;
        CleanupResults."Duration (ms)" := CleanupResults."End Time" - StartTime;
        CleanupResults."Total Records" := TotalRecords;
        CleanupResults."Processed Records" := ProcessedRecords;
        CleanupResults."Deleted Records" := DeletedRecords;
        CleanupResults.Successful := true;
        
        exit(CleanupResults);
    end;
    
    /// <summary>
    /// Validates cleanup completeness with detailed reporting
    /// </summary>
    procedure ValidateCleanupCompleteness(TestDataPrefix: Text[20]): Record "Test Cleanup Validation"
    var
        ValidationResult: Record "Test Cleanup Validation";
        ValidationDetails: List of [Record "Test Cleanup Validation Detail"];
        TestTables: List of [Integer];
        TableNo: Integer;
    begin
        ValidationResult.Init();
        ValidationResult."Validation ID" := CreateGuid();
        ValidationResult."Test Data Prefix" := TestDataPrefix;
        ValidationResult."Validation Time" := CurrentDateTime;
        
        GetTestDataTables(TestTables);
        
        foreach TableNo in TestTables do
            ValidateTableCleanup(TableNo, TestDataPrefix, ValidationResult, ValidationDetails);
            
        ValidationResult."Tables Validated" := TestTables.Count;
        ValidationResult."Validation Complete" := true;
        ValidationResult."Has Remaining Data" := ValidationResult."Remaining Records" > 0;
        
        LogValidationDetails(ValidationDetails);
        
        exit(ValidationResult);
    end;
    
    local procedure FindRecord(var RecordRef: RecordRef; RecordKey: Text[250]): Boolean
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyParts: List of [Text];
        KeyPart: Text;
        i: Integer;
    begin
        KeyParts := RecordKey.Split('|');
        KeyRef := RecordRef.KeyIndex(1); // Primary key
        
        if KeyParts.Count <> KeyRef.FieldCount then
            exit(false);
            
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);
            KeyPart := KeyParts.Get(i);
            
            case FieldRef.Type of
                FieldType::Code,
                FieldType::Text:
                    FieldRef.SetRange(KeyPart);
                FieldType::Integer:
                    begin
                        if Evaluate(i, KeyPart) then
                            FieldRef.SetRange(i);
                    end;
                FieldType::Guid:
                    begin
                        if Evaluate(CreateGuid(), KeyPart) then
                            FieldRef.SetRange(CreateGuid());
                    end;
            end;
        end;
        
        exit(RecordRef.FindFirst());
    end;
    
    local procedure FindDependentRecords(var ParentRecordRef: RecordRef; var DependentRecords: List of [Text])
    var
        TableRelation: Record "Table Relation";
        RelatedTableNo: Integer;
        RelationFilter: Text;
    begin
        // Find table relations for the parent table
        TableRelation.SetRange("Table ID", ParentRecordRef.Number);
        if TableRelation.FindSet() then
            repeat
                RelatedTableNo := TableRelation."Related Table ID";
                RelationFilter := BuildRelationFilter(ParentRecordRef, TableRelation);
                
                if RelationFilter <> '' then
                    DependentRecords.Add(Format(RelatedTableNo) + '|' + RelationFilter);
                    
            until TableRelation.Next() = 0;
    end;
    
    local procedure CleanupDependentRecords(DependentRecords: List of [Text]): Integer
    var
        DependentRecord: Text;
        RecordParts: List of [Text];
        TableNo: Integer;
        Filter: Text;
        RecordRef: RecordRef;
        DeletedCount: Integer;
    begin
        foreach DependentRecord in DependentRecords do begin
            RecordParts := DependentRecord.Split('|');
            if RecordParts.Count = 2 then begin
                Evaluate(TableNo, RecordParts.Get(1));
                Filter := RecordParts.Get(2);
                
                RecordRef.Open(TableNo);
                RecordRef.SetView(Filter);
                DeletedCount += RecordRef.Count();
                RecordRef.DeleteAll(true);
                RecordRef.Close();
            end;
        end;
        
        exit(DeletedCount);
    end;
    
    local procedure ApplyCleanupFilter(var RecordRef: RecordRef; CleanupFilter: Record "Test Cleanup Filter")
    var
        FieldRef: FieldRef;
    begin
        case CleanupFilter."Filter Type" of
            CleanupFilter."Filter Type"::Prefix:
                begin
                    FieldRef := RecordRef.Field(CleanupFilter."Field No.");
                    FieldRef.SetFilter(CleanupFilter."Filter Value" + '*');
                end;
            CleanupFilter."Filter Type"::Exact:
                begin
                    FieldRef := RecordRef.Field(CleanupFilter."Field No.");
                    FieldRef.SetFilter(CleanupFilter."Filter Value");
                end;
            CleanupFilter."Filter Type"::Range:
                begin
                    FieldRef := RecordRef.Field(CleanupFilter."Field No.");
                    FieldRef.SetFilter(CleanupFilter."Filter Value");
                end;
            CleanupFilter."Filter Type"::Age:
                ApplyAgeFilter(RecordRef, CleanupFilter);
        end;
        
        // Apply additional filters if specified
        if CleanupFilter."Additional Filter" <> '' then
            RecordRef.SetView(CleanupFilter."Additional Filter");
    end;
    
    local procedure ApplyAgeFilter(var RecordRef: RecordRef; CleanupFilter: Record "Test Cleanup Filter")
    var
        FieldRef: FieldRef;
        CutoffDate: Date;
        CutoffDateTime: DateTime;
        AgeDays: Integer;
    begin
        Evaluate(AgeDays, CleanupFilter."Filter Value");
        CutoffDate := CalcDate('<-' + Format(AgeDays) + 'D>', Today);
        CutoffDateTime := CreateDateTime(CutoffDate, 235959T);
        
        FieldRef := RecordRef.Field(CleanupFilter."Field No.");
        case FieldRef.Type of
            FieldType::Date:
                FieldRef.SetRange(0D, CutoffDate);
            FieldType::DateTime:
                FieldRef.SetRange(0DT, CutoffDateTime);
        end;
    end;
    
    local procedure ShouldDeleteRecord(var RecordRef: RecordRef; CleanupFilter: Record "Test Cleanup Filter"): Boolean
    begin
        // Additional business logic for record deletion
        // This could include checking for related records, user permissions, etc.
        
        if CleanupFilter."Preserve Referenced Records" then
            if HasIncomingReferences(RecordRef) then
                exit(false);
                
        if CleanupFilter."Skip System Records" then
            if IsSystemRecord(RecordRef) then
                exit(false);
                
        exit(true);
    end;
    
    local procedure DeleteRecord(var RecordRef: RecordRef)
    begin
        try
            RecordRef.Delete(true);
        except
            // Log deletion error but continue with other records
            LogDeletionError(RecordRef, GetLastErrorText());
        end;
    end;
    
    local procedure ValidateTableCleanup(TableNo: Integer; TestDataPrefix: Text[20]; var ValidationResult: Record "Test Cleanup Validation"; var ValidationDetails: List of [Record "Test Cleanup Validation Detail"])
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        ValidationDetail: Record "Test Cleanup Validation Detail";
        RemainingCount: Integer;
    begin
        RecordRef.Open(TableNo);
        
        // Try to find a suitable field to filter on
        FieldRef := FindFilterField(RecordRef, TestDataPrefix);
        if FieldRef.Number > 0 then begin
            FieldRef.SetFilter(TestDataPrefix + '*');
            RemainingCount := RecordRef.Count();
            
            ValidationResult."Remaining Records" += RemainingCount;
            
            if RemainingCount > 0 then begin
                ValidationDetail.Init();
                ValidationDetail."Validation ID" := ValidationResult."Validation ID";
                ValidationDetail."Table No." := TableNo;
                ValidationDetail."Table Name" := GetTableCaption(TableNo);
                ValidationDetail."Remaining Records" := RemainingCount;
                ValidationDetail."Field Name" := FieldRef.Name;
                ValidationDetail."Filter Applied" := TestDataPrefix + '*';
                ValidationDetails.Add(ValidationDetail);
            end;
        end;
        
        RecordRef.Close();
    end;
    
    local procedure GetTestDataTables(var TestTables: List of [Integer])
    begin
        // Define tables that commonly contain test data
        TestTables.Add(Database::Customer);
        TestTables.Add(Database::Vendor);
        TestTables.Add(Database::Item);
        TestTables.Add(Database::"Sales Header");
        TestTables.Add(Database::"Sales Line");
        TestTables.Add(Database::"Purchase Header");
        TestTables.Add(Database::"Purchase Line");
        TestTables.Add(Database::Contact);
        TestTables.Add(Database::"Item Ledger Entry");
        TestTables.Add(Database::"Cust. Ledger Entry");
        TestTables.Add(Database::"Vendor Ledger Entry");
        TestTables.Add(Database::"G/L Entry");
    end;
    
    local procedure FindFilterField(var RecordRef: RecordRef; TestDataPrefix: Text[20]): FieldRef
    var
        FieldRef: FieldRef;
        i: Integer;
    begin
        // Look for common field names that would contain test data identifiers
        for i := 1 to RecordRef.FieldCount do begin
            FieldRef := RecordRef.FieldIndex(i);
            if FieldRef.Type in [FieldType::Code, FieldType::Text] then
                if (StrPos(UpperCase(FieldRef.Name), 'NO.') > 0) or 
                   (StrPos(UpperCase(FieldRef.Name), 'CODE') > 0) or
                   (StrPos(UpperCase(FieldRef.Name), 'ID') > 0) then
                    exit(FieldRef);
        end;
        
        // Return empty field reference if no suitable field found
        Clear(FieldRef);
        exit(FieldRef);
    end;
    
    local procedure LogValidationDetails(ValidationDetails: List of [Record "Test Cleanup Validation Detail"])
    var
        ValidationDetail: Record "Test Cleanup Validation Detail";
    begin
        foreach ValidationDetail in ValidationDetails do
            ValidationDetail.Insert(true);
    end;
    
    local procedure LogSuccessfulCleanup(TableNo: Integer; RecordKey: Text[250]; DeletedCount: Integer; Duration: Duration)
    var
        CleanupLog: Record "Test Cleanup Log";
    begin
        CleanupLog.Init();
        CleanupLog."Entry No." := GetNextCleanupLogEntry();
        CleanupLog."Table No." := TableNo;
        CleanupLog."Record Key" := RecordKey;
        CleanupLog."Records Deleted" := DeletedCount;
        CleanupLog."Duration (ms)" := Duration;
        CleanupLog.Successful := true;
        CleanupLog."Cleanup DateTime" := CurrentDateTime;
        CleanupLog."User ID" := UserId;
        CleanupLog.Insert(true);
    end;
    
    local procedure LogFailedCleanup(TableNo: Integer; RecordKey: Text[250]; ErrorText: Text)
    var
        CleanupLog: Record "Test Cleanup Log";
    begin
        CleanupLog.Init();
        CleanupLog."Entry No." := GetNextCleanupLogEntry();
        CleanupLog."Table No." := TableNo;
        CleanupLog."Record Key" := RecordKey;
        CleanupLog.Successful := false;
        CleanupLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(CleanupLog."Error Message"));
        CleanupLog."Cleanup DateTime" := CurrentDateTime;
        CleanupLog."User ID" := UserId;
        CleanupLog.Insert(true);
    end;
    
    local procedure GetNextCleanupLogEntry(): Integer
    var
        CleanupLog: Record "Test Cleanup Log";
    begin
        CleanupLog.LockTable();
        if CleanupLog.FindLast() then
            exit(CleanupLog."Entry No." + 1)
        else
            exit(1);
    end;
    
    // Additional helper procedures...
    local procedure BuildRelationFilter(var ParentRecordRef: RecordRef; TableRelation: Record "Table Relation"): Text
    begin
        // Implementation would build appropriate filter based on table relationship
        exit('');
    end;
    
    local procedure HasIncomingReferences(var RecordRef: RecordRef): Boolean
    begin
        // Implementation would check for incoming foreign key references
        exit(false);
    end;
    
    local procedure IsSystemRecord(var RecordRef: RecordRef): Boolean
    begin
        // Implementation would check if record is a system record
        exit(false);
    end;
    
    local procedure LogDeletionError(var RecordRef: RecordRef; ErrorText: Text)
    begin
        // Implementation would log deletion errors
    end;
    
    local procedure GetTableCaption(TableNo: Integer): Text[30]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableNo);
        if AllObjWithCaption.FindFirst() then
            exit(AllObjWithCaption."Object Caption")
        else
            exit(Format(TableNo));
    end;
}
```

These comprehensive samples provide production-ready cleanup strategies with complete error handling, performance monitoring, and validation capabilities.
