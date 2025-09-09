---
title: "Database Performance Measurement - Code Samples"
description: "Complete code examples for measuring and monitoring database performance in AL"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["DateTime", "Duration"]
tags: ["performance-measurement", "samples", "monitoring", "benchmarking"]
---

# Database Performance Measurement - Code Samples

## Before and After Testing Pattern

```al
procedure TestPerformanceImprovement()
var
    StartTime: DateTime;
    EndTime: DateTime;
    ElapsedTime: Duration;
begin
    // Test original method
    StartTime := CurrentDateTime;
    CalculateCustomerTotalsInefficient();
    EndTime := CurrentDateTime;
    ElapsedTime := EndTime - StartTime;
    Message('Original method took: %1 ms', ElapsedTime);
    
    // Test optimized method
    StartTime := CurrentDateTime;
    CalculateCustomerTotalsOptimized();
    EndTime := CurrentDateTime;
    ElapsedTime := EndTime - StartTime;
    Message('Optimized method took: %1 ms', ElapsedTime);
end;
```

## Performance Monitoring Framework

```al
codeunit 50200 "Performance Monitor"
{
    procedure MeasureOperation(OperationName: Text; var OperationToMeasure: Codeunit "Operation Interface")
    var
        StartTime: DateTime;
        EndTime: DateTime;
        ElapsedTime: Duration;
        PerformanceLog: Record "Performance Log";
    begin
        StartTime := CurrentDateTime;
        
        // Execute the operation
        OperationToMeasure.Execute();
        
        EndTime := CurrentDateTime;
        ElapsedTime := EndTime - StartTime;
        
        // Log performance metrics
        PerformanceLog.Init();
        PerformanceLog."Operation Name" := OperationName;
        PerformanceLog."Start Time" := StartTime;
        PerformanceLog."End Time" := EndTime;
        PerformanceLog."Duration (ms)" := ElapsedTime;
        PerformanceLog."User ID" := UserId;
        PerformanceLog.Insert();
        
        Message('Operation "%1" completed in %2 ms', OperationName, ElapsedTime);
    end;
}
```

## Query Performance Comparison

```al
procedure CompareQueryMethods()
var
    Customer: Record Customer;
    Method1Time: Duration;
    Method2Time: Duration;
    StartTime: DateTime;
begin
    // Method 1: Individual queries
    StartTime := CurrentDateTime;
    if Customer.FindSet() then
        repeat
            ProcessCustomerIndividually(Customer."No.");
        until Customer.Next() = 0;
    Method1Time := CurrentDateTime - StartTime;
    
    // Method 2: Bulk operations
    StartTime := CurrentDateTime;
    ProcessCustomersInBulk();
    Method2Time := CurrentDateTime - StartTime;
    
    // Compare results
    Message('Individual queries: %1 ms\nBulk operations: %2 ms\nImprovement: %3x faster',
        Method1Time,
        Method2Time,
        Method1Time / Method2Time);
end;
```

## Memory and Resource Monitoring

```al
procedure MonitorResourceUsage()
var
    StartTime: DateTime;
    MemoryBefore: BigInteger;
    MemoryAfter: BigInteger;
    QueryCountBefore: Integer;
    QueryCountAfter: Integer;
begin
    StartTime := CurrentDateTime;
    // MemoryBefore := GetMemoryUsage(); // Pseudocode - would need custom implementation
    // QueryCountBefore := GetDatabaseQueryCount(); // Pseudocode
    
    // Execute operation to monitor
    PerformDatabaseIntensiveOperation();
    
    // MemoryAfter := GetMemoryUsage(); // Pseudocode  
    // QueryCountAfter := GetDatabaseQueryCount(); // Pseudocode
    
    Message('Operation took: %1 ms\nMemory used: %2 MB\nDatabase queries: %3',
        CurrentDateTime - StartTime,
        MemoryAfter - MemoryBefore,
        QueryCountAfter - QueryCountBefore);
end;
```

## Performance Testing Framework

```al
codeunit 50201 "Performance Test Suite"
{
    procedure RunPerformanceTests()
    begin
        TestCustomerProcessing();
        TestInventoryCalculations();
        TestReportGeneration();
        GeneratePerformanceReport();
    end;
    
    local procedure TestCustomerProcessing()
    var
        TestResults: Record "Performance Test Results";
    begin
        TestResults.Init();
        TestResults."Test Name" := 'Customer Processing';
        TestResults."Start Time" := CurrentDateTime;
        
        // Execute test
        ProcessAllCustomers();
        
        TestResults."End Time" := CurrentDateTime;
        TestResults."Duration (ms)" := TestResults."End Time" - TestResults."Start Time";
        TestResults.Insert();
    end;
    
    local procedure GeneratePerformanceReport()
    var
        TestResults: Record "Performance Test Results";
    begin
        if TestResults.FindSet() then
            repeat
                Message('Test: %1 - Duration: %2 ms', 
                    TestResults."Test Name", 
                    TestResults."Duration (ms)");
            until TestResults.Next() = 0;
    end;
}
```

## Load Testing Pattern

```al
procedure SimulateHighLoad()
var
    CustomerCount: Integer;
    BatchSize: Integer;
    CurrentBatch: Integer;
    StartTime: DateTime;
    BatchTime: Duration;
begin
    CustomerCount := 10000;
    BatchSize := 100;
    
    for CurrentBatch := 1 to (CustomerCount div BatchSize) do begin
        StartTime := CurrentDateTime;
        
        ProcessCustomerBatch(CurrentBatch, BatchSize);
        
        BatchTime := CurrentDateTime - StartTime;
        
        // Log batch performance
        Message('Batch %1: %2 customers processed in %3 ms', 
            CurrentBatch, BatchSize, BatchTime);
        
        // Add delay to simulate real load
        Sleep(100);
    end;
end;
```

## Related Topics
- [Database Performance Measurement](database-performance-measurement.md)
- [N+1 Query Problem](n-plus-one-query-problem.md)
- [Query Filtering Optimization](query-filtering-optimization.md)
