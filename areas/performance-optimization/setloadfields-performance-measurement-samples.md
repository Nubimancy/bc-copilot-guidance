---
title: "SetLoadFields Performance Measurement - Code Samples"
description: "Code examples for measuring and monitoring SetLoadFields performance in AL"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Codeunit", "Page"]
variable_types: ["DateTime", "Duration", "Record"]
tags: ["setloadfields", "performance-measurement", "monitoring", "samples", "telemetry"]
---

# SetLoadFields Performance Measurement - Code Samples

## Basic Performance Measurement

```al
codeunit 50705 "Performance Measurement Utils"
{
    procedure MeasureSetLoadFieldsPerformance()
    var
        Customer: Record Customer;
        StartTime: DateTime;
        EndTime: DateTime;
        WithSetLoadFields: Duration;
        WithoutSetLoadFields: Duration;
    begin
        // Test with SetLoadFields
        StartTime := CurrentDateTime;
        MeasureWithSetLoadFields();
        EndTime := CurrentDateTime;
        WithSetLoadFields := EndTime - StartTime;
        
        // Test without SetLoadFields
        StartTime := CurrentDateTime;
        MeasureWithoutSetLoadFields();
        EndTime := CurrentDateTime;
        WithoutSetLoadFields := EndTime - StartTime;
        
        // Log results
        LogPerformanceResults(WithSetLoadFields, WithoutSetLoadFields);
    end;
    
    local procedure MeasureWithSetLoadFields()
    var
        Customer: Record Customer;
        TotalBalance: Decimal;
    begin
        Customer.SetLoadFields("No.", "Name", "Balance (LCY)");
        if Customer.FindSet() then
            repeat
                TotalBalance += Customer."Balance (LCY)";
            until Customer.Next() = 0;
    end;
    
    local procedure MeasureWithoutSetLoadFields()
    var
        Customer: Record Customer;
        TotalBalance: Decimal;
    begin
        if Customer.FindSet() then
            repeat
                TotalBalance += Customer."Balance (LCY)";
            until Customer.Next() = 0;
    end;
    
    local procedure LogPerformanceResults(WithSetLoadFields: Duration; WithoutSetLoadFields: Duration)
    var
        ImprovementPercent: Decimal;
    begin
        if WithoutSetLoadFields <> 0 then
            ImprovementPercent := ((WithoutSetLoadFields - WithSetLoadFields) / WithoutSetLoadFields) * 100;
        
        Message('Performance Results:\With SetLoadFields: %1ms\Without SetLoadFields: %2ms\Improvement: %3%',
            WithSetLoadFields,
            WithoutSetLoadFields,
            ImprovementPercent);
    end;
}
```

## Advanced Performance Telemetry

```al
codeunit 50706 "Performance Telemetry Manager"
{
    var
        PerformanceCounters: Dictionary of [Text, Duration];
        RecordCounts: Dictionary of [Text, Integer];
        
    procedure StartPerformanceSession(SessionName: Text)
    var
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        PerformanceCounters.Set(SessionName + '_START', StartTime);
    end;
    
    procedure EndPerformanceSession(SessionName: Text): Duration
    var
        StartTime: DateTime;
        EndTime: DateTime;
        Duration: Duration;
    begin
        EndTime := CurrentDateTime;
        if PerformanceCounters.Get(SessionName + '_START', StartTime) then begin
            Duration := EndTime - StartTime;
            PerformanceCounters.Set(SessionName + '_DURATION', Duration);
            exit(Duration);
        end;
        exit(0);
    end;
    
    procedure MeasureCustomerProcessing()
    var
        Customer: Record Customer;
        ProcessingTime: Duration;
        RecordCount: Integer;
    begin
        StartPerformanceSession('CUSTOMER_PROCESSING');
        
        Customer.SetLoadFields("No.", "Name", "Balance (LCY)", "Sales (LCY)");
        if Customer.FindSet() then
            repeat
                ProcessCustomerRecord(Customer);
                RecordCount += 1;
            until Customer.Next() = 0;
        
        ProcessingTime := EndPerformanceSession('CUSTOMER_PROCESSING');
        RecordCounts.Set('CUSTOMER_RECORDS', RecordCount);
        
        LogTelemetryData('CUSTOMER_PROCESSING', ProcessingTime, RecordCount);
    end;
    
    procedure MeasureItemProcessing()
    var
        Item: Record Item;
        ProcessingTime: Duration;
        RecordCount: Integer;
    begin
        StartPerformanceSession('ITEM_PROCESSING');
        
        Item.SetLoadFields("No.", Description, "Unit Cost", "Unit Price");
        if Item.FindSet() then
            repeat
                ProcessItemRecord(Item);
                RecordCount += 1;
            until Item.Next() = 0;
        
        ProcessingTime := EndPerformanceSession('ITEM_PROCESSING');
        RecordCounts.Set('ITEM_RECORDS', RecordCount);
        
        LogTelemetryData('ITEM_PROCESSING', ProcessingTime, RecordCount);
    end;
    
    local procedure ProcessCustomerRecord(Customer: Record Customer)
    begin
        // Simulate customer processing
        if Customer."Balance (LCY)" > 0 then begin
            // Process positive balance customers
        end;
    end;
    
    local procedure ProcessItemRecord(Item: Record Item)
    begin
        // Simulate item processing
        if Item."Unit Price" > Item."Unit Cost" then begin
            // Process profitable items
        end;
    end;
    
    local procedure LogTelemetryData(OperationName: Text; Duration: Duration; RecordCount: Integer)
    var
        AvgTimePerRecord: Decimal;
        TelemetryMsg: Text;
    begin
        if RecordCount > 0 then
            AvgTimePerRecord := Duration / RecordCount;
        
        TelemetryMsg := StrSubstNo('Operation: %1, Duration: %2ms, Records: %3, Avg/Record: %4ms',
            OperationName, Duration, RecordCount, AvgTimePerRecord);
        
        // Log to system or send to telemetry service
        Session.LogMessage('PERF001', TelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', 'Performance');
    end;
    
    procedure GeneratePerformanceReport()
    var
        ReportBuilder: TextBuilder;
        OperationName: Text;
        Duration: Duration;
        RecordCount: Integer;
    begin
        ReportBuilder.AppendLine('Performance Report');
        ReportBuilder.AppendLine('==================');
        
        foreach OperationName in PerformanceCounters.Keys do begin
            if PerformanceCounters.Get(OperationName, Duration) and 
               RecordCounts.Get(OperationName.Replace('_DURATION', '_RECORDS'), RecordCount) then begin
                ReportBuilder.AppendLine(StrSubstNo('%1: %2ms (%3 records)', 
                    OperationName.Replace('_DURATION', ''), Duration, RecordCount));
            end;
        end;
        
        Message(ReportBuilder.ToText());
    end;
}
```

## Memory Usage Monitoring

```al
codeunit 50707 "Memory Usage Monitor"
{
    procedure MonitorMemoryUsage()
    var
        Customer: Record Customer;
        InitialMemory: BigInteger;
        PostLoadMemory: BigInteger;
        MemoryDifference: BigInteger;
    begin
        // Get initial memory usage (if available through system functions)
        InitialMemory := GetCurrentMemoryUsage();
        
        // Load data with SetLoadFields
        Customer.SetLoadFields("No.", "Name");
        if Customer.FindSet() then
            repeat
                // Process customer minimally to simulate real usage
                ProcessMinimalCustomer(Customer);
            until Customer.Next() = 0;
        
        PostLoadMemory := GetCurrentMemoryUsage();
        MemoryDifference := PostLoadMemory - InitialMemory;
        
        LogMemoryUsage('CUSTOMER_MINIMAL_LOAD', InitialMemory, PostLoadMemory, MemoryDifference);
        
        // Clear and test full load
        Customer.Reset();
        InitialMemory := GetCurrentMemoryUsage();
        
        // Load all fields (no SetLoadFields)
        if Customer.FindSet() then
            repeat
                ProcessMinimalCustomer(Customer);
            until Customer.Next() = 0;
        
        PostLoadMemory := GetCurrentMemoryUsage();
        MemoryDifference := PostLoadMemory - InitialMemory;
        
        LogMemoryUsage('CUSTOMER_FULL_LOAD', InitialMemory, PostLoadMemory, MemoryDifference);
    end;
    
    local procedure GetCurrentMemoryUsage(): BigInteger
    begin
        // This would require system-level memory monitoring
        // Implementation depends on available system functions
        exit(0); // Placeholder
    end;
    
    local procedure ProcessMinimalCustomer(Customer: Record Customer)
    begin
        // Minimal processing to simulate real usage
        if Customer.Name <> '' then begin
            // Simple validation
        end;
    end;
    
    local procedure LogMemoryUsage(TestName: Text; Initial: BigInteger; PostLoad: BigInteger; Difference: BigInteger)
    begin
        Session.LogMessage('MEM001', 
            StrSubstNo('Memory Test: %1, Initial: %2, Post-Load: %3, Difference: %4', 
                TestName, Initial, PostLoad, Difference),
            Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', 'MemoryUsage');
    end;
}
```

## Database Query Optimization Measurement

```al
codeunit 50708 "Query Optimization Measurement"
{
    procedure MeasureDatabaseQueries()
    var
        Customer: Record Customer;
        QueryStartTime: DateTime;
        QueryEndTime: DateTime;
        QueryCount: Integer;
    begin
        // Measure optimized queries with SetLoadFields
        QueryStartTime := CurrentDateTime;
        QueryCount := 0;
        
        Customer.SetLoadFields("No.", "Name", "Phone No.");
        Customer.SetRange("Customer Posting Group", 'DOMESTIC');
        
        if Customer.FindSet() then
            repeat
                QueryCount += 1;
                ProcessCustomerForQuery(Customer);
            until Customer.Next() = 0;
        
        QueryEndTime := CurrentDateTime;
        LogQueryPerformance('OPTIMIZED_QUERY', QueryStartTime, QueryEndTime, QueryCount);
        
        // Measure unoptimized queries
        Customer.Reset();
        QueryStartTime := CurrentDateTime;
        QueryCount := 0;
        
        Customer.SetRange("Customer Posting Group", 'DOMESTIC');
        // No SetLoadFields - all fields loaded
        
        if Customer.FindSet() then
            repeat
                QueryCount += 1;
                ProcessCustomerForQuery(Customer);
            until Customer.Next() = 0;
        
        QueryEndTime := CurrentDateTime;
        LogQueryPerformance('UNOPTIMIZED_QUERY', QueryStartTime, QueryEndTime, QueryCount);
    end;
    
    procedure MeasureComplexJoins()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        StartTime: DateTime;
        EndTime: DateTime;
        ProcessedOrders: Integer;
    begin
        StartTime := CurrentDateTime;
        
        // Optimized multi-table processing
        SalesHeader.SetLoadFields("No.", "Sell-to Customer No.", "Order Date");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("Order Date", '>=%1', CalcDate('<-30D>', Today));
        
        if SalesHeader.FindSet() then
            repeat
                // Load customer data efficiently
                if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
                    Customer.SetLoadFields("No.", "Name", "Credit Limit (LCY)");
                    
                    // Process order lines efficiently
                    SalesLine.SetLoadFields("Document No.", "No.", Quantity, "Line Amount");
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    if SalesLine.FindSet() then
                        repeat
                            ProcessOrderLine(SalesHeader, SalesLine, Customer);
                        until SalesLine.Next() = 0;
                    
                    ProcessedOrders += 1;
                end;
            until SalesHeader.Next() = 0;
        
        EndTime := CurrentDateTime;
        LogComplexQueryPerformance('OPTIMIZED_MULTI_TABLE', StartTime, EndTime, ProcessedOrders);
    end;
    
    local procedure ProcessCustomerForQuery(Customer: Record Customer)
    begin
        // Simulate processing that uses loaded fields
        if (Customer."No." <> '') and (Customer.Name <> '') then begin
            // Process customer
        end;
    end;
    
    local procedure ProcessOrderLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; Customer: Record Customer)
    begin
        // Simulate order line processing
        if SalesLine."Line Amount" > 1000 then begin
            // Special processing for high-value lines
        end;
    end;
    
    local procedure LogQueryPerformance(QueryType: Text; StartTime: DateTime; EndTime: DateTime; RecordCount: Integer)
    var
        Duration: Duration;
        AvgTimePerRecord: Decimal;
    begin
        Duration := EndTime - StartTime;
        if RecordCount > 0 then
            AvgTimePerRecord := Duration / RecordCount;
        
        Session.LogMessage('QUERY001',
            StrSubstNo('Query Performance - Type: %1, Duration: %2ms, Records: %3, Avg/Record: %4ms',
                QueryType, Duration, RecordCount, AvgTimePerRecord),
            Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', 'QueryPerformance');
    end;
    
    local procedure LogComplexQueryPerformance(QueryType: Text; StartTime: DateTime; EndTime: DateTime; ProcessedCount: Integer)
    var
        Duration: Duration;
    begin
        Duration := EndTime - StartTime;
        
        Session.LogMessage('COMPLEX001',
            StrSubstNo('Complex Query - Type: %1, Duration: %2ms, Processed: %3 orders',
                QueryType, Duration, ProcessedCount),
            Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', 'ComplexQueryPerformance');
    end;
}
```

## Performance Comparison Dashboard

```al
page 50700 "SetLoadFields Performance"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    
    layout
    {
        area(Content)
        {
            group(Performance)
            {
                Caption = 'Performance Measurements';
                
                field(CustomerProcessingTime; CustomerProcessingTime)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Processing Time (ms)';
                    Editable = false;
                }
                
                field(ItemProcessingTime; ItemProcessingTime)
                {
                    ApplicationArea = All;
                    Caption = 'Item Processing Time (ms)';
                    Editable = false;
                }
                
                field(MemoryUsage; MemoryUsage)
                {
                    ApplicationArea = All;
                    Caption = 'Memory Usage (MB)';
                    Editable = false;
                }
                
                field(QueryOptimizationGain; QueryOptimizationGain)
                {
                    ApplicationArea = All;
                    Caption = 'Query Optimization Gain (%)';
                    Editable = false;
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(RunPerformanceTests)
            {
                ApplicationArea = All;
                Caption = 'Run Performance Tests';
                Image = ExecuteBatch;
                
                trigger OnAction()
                begin
                    RunAllPerformanceTests();
                end;
            }
            
            action(ResetCounters)
            {
                ApplicationArea = All;
                Caption = 'Reset Counters';
                Image = ResetStatus;
                
                trigger OnAction()
                begin
                    ResetAllCounters();
                end;
            }
        }
    }
    
    var
        CustomerProcessingTime: Duration;
        ItemProcessingTime: Duration;
        MemoryUsage: Decimal;
        QueryOptimizationGain: Decimal;
        
    local procedure RunAllPerformanceTests()
    var
        PerfTelemetry: Codeunit "Performance Telemetry Manager";
        MemoryMonitor: Codeunit "Memory Usage Monitor";
        QueryMeasurement: Codeunit "Query Optimization Measurement";
    begin
        // Run customer processing test
        PerfTelemetry.MeasureCustomerProcessing();
        CustomerProcessingTime := GetLastMeasurement('CUSTOMER_PROCESSING');
        
        // Run item processing test
        PerfTelemetry.MeasureItemProcessing();
        ItemProcessingTime := GetLastMeasurement('ITEM_PROCESSING');
        
        // Run memory usage test
        MemoryMonitor.MonitorMemoryUsage();
        MemoryUsage := GetMemoryUsage();
        
        // Run query optimization test
        QueryMeasurement.MeasureDatabaseQueries();
        QueryOptimizationGain := CalculateOptimizationGain();
        
        CurrPage.Update();
        Message('Performance tests completed successfully.');
    end;
    
    local procedure ResetAllCounters()
    begin
        CustomerProcessingTime := 0;
        ItemProcessingTime := 0;
        MemoryUsage := 0;
        QueryOptimizationGain := 0;
        CurrPage.Update();
    end;
    
    local procedure GetLastMeasurement(OperationName: Text): Duration
    begin
        // Implementation would retrieve the last measurement from telemetry
        exit(0); // Placeholder
    end;
    
    local procedure GetMemoryUsage(): Decimal
    begin
        // Implementation would retrieve memory usage data
        exit(0); // Placeholder
    end;
    
    local procedure CalculateOptimizationGain(): Decimal
    begin
        // Implementation would calculate the optimization gain percentage
        exit(0); // Placeholder
    end;
}
```

## Related Topics
- [SetLoadFields Performance Measurement](setloadfields-performance-measurement.md)
- [SetLoadFields Basic Patterns](setloadfields-basic-patterns.md)
- [SetLoadFields Advanced Scenarios](setloadfields-advanced-scenarios.md)
