---
title: "Bulk Processing Patterns - Code Samples"
description: "Complete code examples for efficient bulk data processing using temporary tables and batching"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Table]
variable_types: ["List"]
tags: ["bulk-processing", "samples", "temporary-tables", "batching"]
---

# Bulk Processing Patterns - Code Samples

## Bulk Update with Temporary Tables

```al
procedure UpdateCustomerRatingsInBulk(var CustomerNos: List of [Code[20]])
var
    Customer: Record Customer;
    TempCustomerUpdate: Record Customer temporary;
    Rating: Record "Customer Rating";
    Counter: Integer;
    BatchSize: Integer;
begin
    BatchSize := 1000; // Process in batches of 1000
    
    // Step 1: Load all required data into temporary table
    foreach CustomerNo in CustomerNos do begin
        if Customer.Get(CustomerNo) then begin
            TempCustomerUpdate := Customer;
            
            // Calculate average rating (single query per batch)
            Rating.SetRange("Customer No.", CustomerNo);
            Rating.CalcSums("Rating Score", "Rating Count");
            if Rating."Rating Count" > 0 then
                TempCustomerUpdate."Average Rating" := Rating."Rating Score" / Rating."Rating Count";
                
            TempCustomerUpdate.Insert();
            Counter += 1;
            
            // Process in batches to avoid memory issues
            if Counter >= BatchSize then begin
                CommitCustomerUpdates(TempCustomerUpdate);
                TempCustomerUpdate.DeleteAll();
                Counter := 0;
                Commit(); // Free memory and locks
            end;
        end;
    end;
    
    // Process remaining records
    if Counter > 0 then
        CommitCustomerUpdates(TempCustomerUpdate);
end;

local procedure CommitCustomerUpdates(var TempCustomerUpdate: Record Customer temporary)
var
    Customer: Record Customer;
begin
    if TempCustomerUpdate.FindSet() then
        repeat
            if Customer.Get(TempCustomerUpdate."No.") then begin
                Customer."Average Rating" := TempCustomerUpdate."Average Rating";
                Customer."Last Rating Update" := Today;
                Customer.Modify();
            end;
        until TempCustomerUpdate.Next() = 0;
end;
```

## Bulk Insert with Error Handling

```al
procedure BulkInsertItems(var ItemDataList: List of [JsonObject])
var
    Item: Record Item;
    TempItemBuffer: Record Item temporary;
    ErrorCount: Integer;
    SuccessCount: Integer;
    ItemData: JsonObject;
    ItemNo: Code[20];
begin
    // Step 1: Validate and prepare all items in temporary table
    foreach ItemData in ItemDataList do begin
        if ValidateItemJson(ItemData, ItemNo) then begin
            TempItemBuffer.Init();
            PopulateItemFromJson(TempItemBuffer, ItemData);
            if TempItemBuffer.Insert() then
                SuccessCount += 1
            else
                ErrorCount += 1;
        end else
            ErrorCount += 1;
    end;
    
    // Step 2: Bulk insert validated items
    if TempItemBuffer.FindSet() then
        repeat
            Item := TempItemBuffer;
            if not Item.Insert(true) then
                ErrorCount += 1;
        until TempItemBuffer.Next() = 0;
    
    // Report results
    Message('Bulk insert completed. Success: %1, Errors: %2', SuccessCount, ErrorCount);
end;

local procedure ValidateItemJson(ItemData: JsonObject; var ItemNo: Code[20]): Boolean
var
    ItemNoToken: JsonToken;
begin
    if not ItemData.Get('itemNo', ItemNoToken) then
        exit(false);
    
    ItemNo := ItemNoToken.AsValue().AsCode();
    exit(ItemNo <> '');
end;
```

## Parallel Processing Pattern

```al
procedure ProcessLargeDatasetInParallel()
var
    Customer: Record Customer;
    TempCustomerBatch: Record Customer temporary;
    BatchCount: Integer;
    ProcessingJobs: List of [Guid];
    JobId: Guid;
begin
    // Step 1: Divide customers into batches
    Customer.SetCurrentKey("No.");
    if Customer.FindSet() then
        repeat
            TempCustomerBatch := Customer;
            TempCustomerBatch.Insert();
            BatchCount += 1;
            
            // Create batch every 500 records
            if BatchCount >= 500 then begin
                JobId := CreateGuid();
                ProcessingJobs.Add(JobId);
                ProcessCustomerBatch(TempCustomerBatch, JobId);
                
                TempCustomerBatch.DeleteAll();
                BatchCount := 0;
            end;
        until Customer.Next() = 0;
    
    // Process remaining records
    if BatchCount > 0 then begin
        JobId := CreateGuid();
        ProcessingJobs.Add(JobId);
        ProcessCustomerBatch(TempCustomerBatch, JobId);
    end;
    
    // Wait for all jobs to complete
    WaitForJobCompletion(ProcessingJobs);
end;
```

## Related Topics
- [Bulk Processing Patterns](bulk-processing-patterns.md)
- [N+1 Query Problem](n-plus-one-query-problem.md)
- [Query Filtering Optimization](query-filtering-optimization.md)
