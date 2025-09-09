---
title: "Test Data Cleanup Strategies"
description: "Comprehensive approaches for cleaning up test data after execution to prevent database pollution and maintain test environment integrity"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["Record", "RecordRef", "FieldRef", "List", "Dictionary"]
tags: ["testing", "cleanup", "data-management", "test-framework", "maintenance", "database-integrity"]
---

# Test Data Cleanup Strategies

## Core Cleanup Principles

### Automatic Cleanup
Implement automatic cleanup mechanisms that execute regardless of test success or failure.

### Complete Cleanup
Ensure all test data, including related records and dependencies, are properly removed.

### Performance-Optimized Cleanup
Use efficient cleanup strategies that minimize performance impact on test execution.

### Verification and Validation
Implement verification mechanisms to ensure cleanup was successful and complete.

## Implementation Strategies

### Batch Cleanup Operations

Efficiently remove large volumes of test data using batch operations:

```al
codeunit 50400 "Batch Cleanup Manager"
{
    var
        CleanupBatchSize: Integer;
        MaxCleanupTime: Duration;
        
    trigger OnRun()
    begin
        CleanupBatchSize := 1000;
        MaxCleanupTime := 30000; // 30 seconds
    end;
    
    /// <summary>
    /// Performs cleanup using optimized batch operations
    /// </summary>
    procedure ExecuteBatchCleanup(TableNo: Integer; FilterText: Text): Integer
    var
        RecordRef: RecordRef;
        DeletedCount: Integer;
        BatchCount: Integer;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        RecordRef.Open(TableNo);
        RecordRef.SetView(FilterText);
        
        while (not RecordRef.IsEmpty()) and ((CurrentDateTime - StartTime) < MaxCleanupTime) do begin
            BatchCount := DeleteBatch(RecordRef, CleanupBatchSize);
            DeletedCount += BatchCount;
            
            if BatchCount < CleanupBatchSize then
                break; // No more records to process
                
            Commit(); // Prevent long-running transactions
        end;
        
        RecordRef.Close();
        exit(DeletedCount);
    end;
    
    local procedure DeleteBatch(var RecordRef: RecordRef; BatchSize: Integer): Integer
    var
        TempRecordRef: RecordRef;
        DeletedCount: Integer;
        i: Integer;
    begin
        TempRecordRef.Open(RecordRef.Number, true);
        
        if RecordRef.FindSet() then
            repeat
                TempRecordRef := RecordRef;
                TempRecordRef.Insert();
                DeletedCount += 1;
                i += 1;
            until (RecordRef.Next() = 0) or (i >= BatchSize);
            
        // Delete the batch
        if TempRecordRef.FindSet() then
            repeat
                RecordRef.Get(TempRecordRef.RecordId);
                RecordRef.Delete(true);
            until TempRecordRef.Next() = 0;
            
        TempRecordRef.Close();
        exit(DeletedCount);
    end;
}
```

### Dependency-Aware Cleanup

Handle record dependencies and foreign key relationships during cleanup:

```al
codeunit 50401 "Dependency Cleanup Manager"
{
    var
        CleanupOrder: List of [Integer];
        TableDependencies: Dictionary of [Integer, List of [Integer]];
        
    trigger OnRun()
    begin
        InitializeCleanupOrder();
    end;
    
    /// <summary>
    /// Performs cleanup in proper dependency order
    /// </summary>
    procedure ExecuteDependencyCleanup(TestDataPrefix: Text[10]): Boolean
    var
        TableNo: Integer;
        CleanupResults: Dictionary of [Integer, Integer];
        TotalCleaned: Integer;
    begin
        foreach TableNo in CleanupOrder do begin
            TotalCleaned += CleanupTable(TableNo, TestDataPrefix);
            CleanupResults.Add(TableNo, TotalCleaned);
        end;
        
        LogCleanupResults(CleanupResults);
        ValidateCleanupComplete(TestDataPrefix);
        
        exit(true);
    end;
    
    local procedure CleanupTable(TableNo: Integer; TestDataPrefix: Text[10]): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FilterValue: Text;
        DeletedCount: Integer;
    begin
        RecordRef.Open(TableNo);
        
        // Apply filter based on table structure
        case TableNo of
            Database::Customer:
                begin
                    FieldRef := RecordRef.Field(1); // No. field
                    FieldRef.SetFilter(TestDataPrefix + '*');
                end;
            Database::Vendor:
                begin
                    FieldRef := RecordRef.Field(1); // No. field
                    FieldRef.SetFilter(TestDataPrefix + '*');
                end;
            Database::Item:
                begin
                    FieldRef := RecordRef.Field(1); // No. field
                    FieldRef.SetFilter(TestDataPrefix + '*');
                end;
            Database::"Sales Header":
                begin
                    FieldRef := RecordRef.Field(3); // No. field
                    FieldRef.SetFilter(TestDataPrefix + '*');
                end;
            Database::"Sales Line":
                CleanupSalesLines(TestDataPrefix);
            else
                CleanupGenericTable(RecordRef, TestDataPrefix);
        end;
        
        DeletedCount := RecordRef.Count();
        if DeletedCount > 0 then
            RecordRef.DeleteAll(true);
            
        RecordRef.Close();
        exit(DeletedCount);
    end;
    
    local procedure CleanupSalesLines(TestDataPrefix: Text[10])
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        // Find sales lines belonging to test documents
        SalesHeader.SetFilter("No.", TestDataPrefix + '*');
        if SalesHeader.FindSet() then
            repeat
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.DeleteAll(true);
            until SalesHeader.Next() = 0;
    end;
    
    local procedure CleanupGenericTable(var RecordRef: RecordRef; TestDataPrefix: Text[10])
    var
        FieldRef: FieldRef;
        KeyFieldNo: Integer;
    begin
        // Try to find a Code or No. field to filter on
        KeyFieldNo := FindKeyField(RecordRef);
        if KeyFieldNo > 0 then begin
            FieldRef := RecordRef.Field(KeyFieldNo);
            if FieldRef.Type in [FieldType::Code, FieldType::Text] then
                FieldRef.SetFilter(TestDataPrefix + '*');
        end;
    end;
    
    local procedure FindKeyField(var RecordRef: RecordRef): Integer
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        i: Integer;
    begin
        KeyRef := RecordRef.KeyIndex(1); // Primary key
        
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);
            if FieldRef.Type in [FieldType::Code, FieldType::Text] then
                if (StrPos(UpperCase(FieldRef.Name), 'NO.') > 0) or 
                   (StrPos(UpperCase(FieldRef.Name), 'CODE') > 0) then
                    exit(FieldRef.Number);
        end;
        
        exit(0);
    end;
    
    local procedure InitializeCleanupOrder()
    begin
        // Define cleanup order based on dependencies
        CleanupOrder.Add(Database::"Sales Line");
        CleanupOrder.Add(Database::"Purchase Line");
        CleanupOrder.Add(Database::"Sales Header");
        CleanupOrder.Add(Database::"Purchase Header");
        CleanupOrder.Add(Database::"Item Ledger Entry");
        CleanupOrder.Add(Database::"Item Application Entry");
        CleanupOrder.Add(Database::"Value Entry");
        CleanupOrder.Add(Database::"Cust. Ledger Entry");
        CleanupOrder.Add(Database::"Vendor Ledger Entry");
        CleanupOrder.Add(Database::"G/L Entry");
        CleanupOrder.Add(Database::Item);
        CleanupOrder.Add(Database::Customer);
        CleanupOrder.Add(Database::Vendor);
        CleanupOrder.Add(Database::Contact);
    end;
    
    local procedure LogCleanupResults(CleanupResults: Dictionary of [Integer, Integer])
    var
        TableNo: Integer;
        DeletedCount: Integer;
        CleanupLog: Record "Test Cleanup Log";
        EntryNo: Integer;
    begin
        EntryNo := GetNextCleanupLogEntry();
        
        foreach TableNo in CleanupResults.Keys do begin
            CleanupResults.Get(TableNo, DeletedCount);
            
            CleanupLog.Init();
            CleanupLog."Entry No." := EntryNo;
            CleanupLog."Table No." := TableNo;
            CleanupLog."Table Name" := GetTableName(TableNo);
            CleanupLog."Records Deleted" := DeletedCount;
            CleanupLog."Cleanup DateTime" := CurrentDateTime;
            CleanupLog."User ID" := UserId;
            CleanupLog."Session ID" := SessionId();
            CleanupLog.Insert(true);
            
            EntryNo += 1;
        end;
    end;
    
    local procedure ValidateCleanupComplete(TestDataPrefix: Text[10]): Boolean
    var
        ValidationErrors: List of [Text];
    begin
        ValidateTableCleanup(Database::Customer, TestDataPrefix, ValidationErrors);
        ValidateTableCleanup(Database::Vendor, TestDataPrefix, ValidationErrors);
        ValidateTableCleanup(Database::Item, TestDataPrefix, ValidationErrors);
        ValidateTableCleanup(Database::"Sales Header", TestDataPrefix, ValidationErrors);
        ValidateTableCleanup(Database::"Purchase Header", TestDataPrefix, ValidationErrors);
        
        if ValidationErrors.Count > 0 then begin
            ReportValidationErrors(ValidationErrors);
            exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure ValidateTableCleanup(TableNo: Integer; TestDataPrefix: Text[10]; var ValidationErrors: List of [Text])
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        RemainingCount: Integer;
        ErrorMsg: Text;
    begin
        RecordRef.Open(TableNo);
        
        // Apply appropriate filter for each table
        case TableNo of
            Database::Customer, Database::Vendor, Database::Item:
                begin
                    FieldRef := RecordRef.Field(1);
                    FieldRef.SetFilter(TestDataPrefix + '*');
                end;
            Database::"Sales Header", Database::"Purchase Header":
                begin
                    FieldRef := RecordRef.Field(3);
                    FieldRef.SetFilter(TestDataPrefix + '*');
                end;
        end;
        
        RemainingCount := RecordRef.Count();
        if RemainingCount > 0 then begin
            ErrorMsg := StrSubstNo('%1 test records remain in table %2 (%3)', 
                                  RemainingCount, GetTableName(TableNo), TableNo);
            ValidationErrors.Add(ErrorMsg);
        end;
        
        RecordRef.Close();
    end;
    
    local procedure GetTableName(TableNo: Integer): Text[30]
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
    
    local procedure ReportValidationErrors(ValidationErrors: List of [Text])
    var
        ErrorMsg: Text;
        AllErrors: Text;
    begin
        foreach ErrorMsg in ValidationErrors do begin
            if AllErrors <> '' then
                AllErrors += '\';
            AllErrors += ErrorMsg;
        end;
        
        Error('Test data cleanup validation failed:\%1', AllErrors);
    end;
}
```

### Scheduled Cleanup Management

Implement scheduled cleanup for long-term test environment maintenance:

```al
codeunit 50402 "Scheduled Cleanup Manager"
{
    var
        CleanupSchedules: Dictionary of [Text, Record "Test Cleanup Schedule"];
        
    /// <summary>
    /// Creates a scheduled cleanup job for specific test data
    /// </summary>
    procedure ScheduleCleanup(ScheduleName: Text[100]; TestDataPattern: Text[50]; CleanupAfterDays: Integer; RecurringCleanup: Boolean)
    var
        CleanupSchedule: Record "Test Cleanup Schedule";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CleanupSchedule.Init();
        CleanupSchedule."Schedule Name" := ScheduleName;
        CleanupSchedule."Test Data Pattern" := TestDataPattern;
        CleanupSchedule."Cleanup After Days" := CleanupAfterDays;
        CleanupSchedule."Recurring Cleanup" := RecurringCleanup;
        CleanupSchedule."Next Cleanup Date" := CalcDate('<+' + Format(CleanupAfterDays) + 'D>', Today);
        CleanupSchedule.Active := true;
        CleanupSchedule.Insert(true);
        
        // Create job queue entry
        CreateCleanupJobQueueEntry(CleanupSchedule, JobQueueEntry);
        
        CleanupSchedules.Add(ScheduleName, CleanupSchedule);
    end;
    
    /// <summary>
    /// Executes scheduled cleanup for expired test data
    /// </summary>
    procedure ExecuteScheduledCleanup(ScheduleName: Text[100]): Boolean
    var
        CleanupSchedule: Record "Test Cleanup Schedule";
        CleanupResults: Record "Test Cleanup Results";
    begin
        if not CleanupSchedules.Get(ScheduleName, CleanupSchedule) then
            exit(false);
            
        if not CleanupSchedule.Active then
            exit(false);
            
        if CleanupSchedule."Next Cleanup Date" > Today then
            exit(false); // Not ready for cleanup yet
            
        // Execute cleanup
        CleanupResults := ExecutePatternCleanup(CleanupSchedule."Test Data Pattern", CleanupSchedule."Cleanup After Days");
        
        // Log results
        LogScheduledCleanupResults(ScheduleName, CleanupResults);
        
        // Update schedule for next run
        UpdateCleanupSchedule(CleanupSchedule);
        
        exit(true);
    end;
    
    local procedure ExecutePatternCleanup(TestDataPattern: Text[50]; MinAgeDays: Integer): Record "Test Cleanup Results"
    var
        CleanupResults: Record "Test Cleanup Results";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        TableNo: Integer;
        CutoffDate: Date;
    begin
        CutoffDate := CalcDate('<-' + Format(MinAgeDays) + 'D>', Today);
        CleanupResults.Init();
        CleanupResults."Cleanup DateTime" := CurrentDateTime;
        CleanupResults."Test Data Pattern" := TestDataPattern;
        CleanupResults."Cutoff Date" := CutoffDate;
        
        // Clean up major tables
        CleanupResults."Customers Deleted" := CleanupAgedRecords(Database::Customer, TestDataPattern, CutoffDate);
        CleanupResults."Vendors Deleted" := CleanupAgedRecords(Database::Vendor, TestDataPattern, CutoffDate);
        CleanupResults."Items Deleted" := CleanupAgedRecords(Database::Item, TestDataPattern, CutoffDate);
        CleanupResults."Documents Deleted" := CleanupAgedDocuments(TestDataPattern, CutoffDate);
        
        CleanupResults."Total Records Deleted" := CleanupResults."Customers Deleted" + 
                                                 CleanupResults."Vendors Deleted" + 
                                                 CleanupResults."Items Deleted" + 
                                                 CleanupResults."Documents Deleted";
        
        exit(CleanupResults);
    end;
    
    local procedure CleanupAgedRecords(TableNo: Integer; TestDataPattern: Text[50]; CutoffDate: Date): Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        DateFieldRef: FieldRef;
        DeletedCount: Integer;
    begin
        RecordRef.Open(TableNo);
        
        // Set pattern filter
        FieldRef := RecordRef.Field(1); // Assume first field is No./Code
        FieldRef.SetFilter(TestDataPattern);
        
        // Set date filter (look for creation date or modified date)
        DateFieldRef := FindDateField(RecordRef, 'SystemCreatedAt,SystemModifiedAt,Created,Modified');
        if DateFieldRef.Number > 0 then begin
            DateFieldRef.SetRange(0D, CutoffDate);
            
            DeletedCount := RecordRef.Count();
            if DeletedCount > 0 then
                RecordRef.DeleteAll(true);
        end;
        
        RecordRef.Close();
        exit(DeletedCount);
    end;
    
    local procedure CleanupAgedDocuments(TestDataPattern: Text[50]; CutoffDate: Date): Integer
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        DeletedCount: Integer;
    begin
        // Cleanup sales documents
        SalesHeader.SetFilter("No.", TestDataPattern);
        SalesHeader.SetRange("Document Date", 0D, CutoffDate);
        DeletedCount += SalesHeader.Count();
        SalesHeader.DeleteAll(true);
        
        // Cleanup purchase documents
        PurchaseHeader.SetFilter("No.", TestDataPattern);
        PurchaseHeader.SetRange("Document Date", 0D, CutoffDate);
        DeletedCount += PurchaseHeader.Count();
        PurchaseHeader.DeleteAll(true);
        
        exit(DeletedCount);
    end;
    
    local procedure FindDateField(var RecordRef: RecordRef; DateFieldNames: Text): FieldRef
    var
        FieldRef: FieldRef;
        FieldNames: List of [Text];
        FieldName: Text;
        i: Integer;
    begin
        FieldNames := DateFieldNames.Split(',');
        
        foreach FieldName in FieldNames do begin
            for i := 1 to RecordRef.FieldCount do begin
                FieldRef := RecordRef.FieldIndex(i);
                if UpperCase(FieldRef.Name) = UpperCase(FieldName) then
                    if FieldRef.Type in [FieldType::Date, FieldType::DateTime] then
                        exit(FieldRef);
            end;
        end;
        
        // Return empty field reference
        Clear(FieldRef);
        exit(FieldRef);
    end;
    
    local procedure CreateCleanupJobQueueEntry(CleanupSchedule: Record "Test Cleanup Schedule"; var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Scheduled Cleanup Manager";
        JobQueueEntry.Description := 'Test Cleanup: ' + CleanupSchedule."Schedule Name";
        JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(CleanupSchedule."Next Cleanup Date", 020000T); // 2:00 AM
        JobQueueEntry."Job Queue Category Code" := 'TESTCLEANUP';
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        
        if CleanupSchedule."Recurring Cleanup" then begin
            JobQueueEntry."Recurring Job" := true;
            JobQueueEntry."Run on Mondays" := true;
            JobQueueEntry."Run on Tuesdays" := true;
            JobQueueEntry."Run on Wednesdays" := true;
            JobQueueEntry."Run on Thursdays" := true;
            JobQueueEntry."Run on Fridays" := true;
        end;
        
        JobQueueEntry.Insert(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;
    
    local procedure UpdateCleanupSchedule(var CleanupSchedule: Record "Test Cleanup Schedule")
    begin
        CleanupSchedule."Last Cleanup Date" := Today;
        
        if CleanupSchedule."Recurring Cleanup" then
            CleanupSchedule."Next Cleanup Date" := CalcDate('<+' + Format(CleanupSchedule."Cleanup After Days") + 'D>', Today)
        else
            CleanupSchedule.Active := false;
            
        CleanupSchedule.Modify(true);
        CleanupSchedules.Set(CleanupSchedule."Schedule Name", CleanupSchedule);
    end;
    
    local procedure LogScheduledCleanupResults(ScheduleName: Text[100]; CleanupResults: Record "Test Cleanup Results")
    var
        CleanupLog: Record "Test Scheduled Cleanup Log";
    begin
        CleanupLog.Init();
        CleanupLog."Entry No." := GetNextScheduledLogEntry();
        CleanupLog."Schedule Name" := ScheduleName;
        CleanupLog."Cleanup DateTime" := CleanupResults."Cleanup DateTime";
        CleanupLog."Test Data Pattern" := CleanupResults."Test Data Pattern";
        CleanupLog."Cutoff Date" := CleanupResults."Cutoff Date";
        CleanupLog."Total Records Deleted" := CleanupResults."Total Records Deleted";
        CleanupLog."Customers Deleted" := CleanupResults."Customers Deleted";
        CleanupLog."Vendors Deleted" := CleanupResults."Vendors Deleted";
        CleanupLog."Items Deleted" := CleanupResults."Items Deleted";
        CleanupLog."Documents Deleted" := CleanupResults."Documents Deleted";
        CleanupLog.Insert(true);
    end;
    
    local procedure GetNextScheduledLogEntry(): Integer
    var
        CleanupLog: Record "Test Scheduled Cleanup Log";
    begin
        CleanupLog.LockTable();
        if CleanupLog.FindLast() then
            exit(CleanupLog."Entry No." + 1)
        else
            exit(1);
    end;
}
```

## Best Practices

### Cleanup Timing
- Execute cleanup in finally blocks to ensure execution regardless of test outcome
- Use batch operations for large data volumes
- Schedule regular cleanup for long-running test environments
- Implement cleanup timeouts to prevent hanging operations

### Data Dependencies  
- Clean up dependent records before parent records
- Handle foreign key relationships properly
- Use cascading delete where appropriate
- Validate cleanup completeness with dependency checks

### Performance Optimization
- Use bulk delete operations instead of single record deletes
- Commit transactions periodically during large cleanups
- Implement cleanup progress monitoring
- Provide cleanup cancellation mechanisms

### Monitoring and Logging
- Log all cleanup operations with detailed statistics
- Track cleanup performance metrics
- Implement cleanup failure alerting
- Maintain cleanup history for analysis
