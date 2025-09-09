---
title: "Event Performance Optimization"
description: "Performance optimization strategies and patterns for AL integration and business events"
area: "performance-optimization"
difficulty: "advanced"
object_types: ["Codeunit"]
variable_types: ["Record", "List"]
tags: ["performance", "events", "optimization", "batching", "caching"]
---

# Event Performance Optimization

Event-driven architectures can introduce performance overhead if not carefully designed. Optimizing event performance ensures that extensibility doesn't compromise core business process speed and responsiveness.

## Performance Impact Analysis

### Event Publishing Overhead

Every event creates measurable overhead:
- **Parameter marshaling**: Copying data to pass to subscribers
- **Subscriber enumeration**: Finding and calling all subscribers  
- **Context switching**: Moving between publisher and subscriber code
- **Memory allocation**: Creating temporary objects and collections

### Subscriber Execution Cost

Subscriber performance directly impacts overall system performance:
- **Sequential execution**: Subscribers run one after another
- **Cumulative delay**: Each subscriber adds to total processing time
- **Resource contention**: Multiple subscribers competing for same resources
- **Error propagation**: Slow subscribers delay entire business process

## Early Exit Optimization

### IsHandled Pattern for Performance

Use the `IsHandled` parameter to skip expensive processing when possible:

```al
procedure ProcessLargeDataset(var DataTable: Record "Data Table")
var
    IsHandled: Boolean;
    ProcessingStartTime: DateTime;
begin
    ProcessingStartTime := CurrentDateTime;
    
    // Allow extensions to completely replace processing
    OnBeforeProcessLargeDataset(DataTable, IsHandled);
    if IsHandled then begin
        LogPerformanceMetric('DataProcessing', 'Handled by extension', 
                            CurrentDateTime - ProcessingStartTime);
        exit;
    end;
    
    // Expensive standard processing only if not handled
    PerformComplexCalculations(DataTable);
    GenerateComplexReports(DataTable);
    
    OnAfterProcessLargeDataset(DataTable);
    
    LogPerformanceMetric('DataProcessing', 'Standard processing', 
                        CurrentDateTime - ProcessingStartTime);
end;

[IntegrationEvent(false, false)]
local procedure OnBeforeProcessLargeDataset(var DataTable: Record "Data Table"; var IsHandled: Boolean)
begin
end;
```

### Conditional Event Publishing

Only fire events when subscribers exist or conditions warrant:

```al
procedure UpdateCustomerStatus(var Customer: Record Customer; NewStatus: Enum "Customer Status")
var
    OldStatus: Enum "Customer Status";
    HasStatusSubscribers: Boolean;
begin
    OldStatus := Customer.Status;
    
    // Check if any subscribers exist before expensive event preparation
    HasStatusSubscribers := HasEventSubscribers(Codeunit::"Customer Management", 'OnCustomerStatusChanged');
    
    Customer.Status := NewStatus;
    Customer.Modify(true);
    
    // Only fire event if there are subscribers
    if HasStatusSubscribers and (OldStatus <> NewStatus) then
        OnCustomerStatusChanged(Customer, OldStatus, NewStatus);
end;
```

## Batch Event Processing

### Record Collection Events

Process multiple records in single events rather than individual record events:

```al
procedure ProcessInventoryAdjustments(var ItemLedgerEntries: Record "Item Ledger Entry")
var
    AdjustmentList: List of [Code[20]];
    ItemNo: Code[20];
begin
    // Collect all items being adjusted
    if ItemLedgerEntries.FindSet() then
        repeat
            if not AdjustmentList.Contains(ItemLedgerEntries."Item No.") then
                AdjustmentList.Add(ItemLedgerEntries."Item No.");
        until ItemLedgerEntries.Next() = 0;
    
    // Single event with all affected items
    OnBeforeProcessInventoryAdjustmentBatch(AdjustmentList, ItemLedgerEntries);
    
    // Process adjustments
    ProcessAdjustmentEntries(ItemLedgerEntries);
    
    OnAfterProcessInventoryAdjustmentBatch(AdjustmentList, ItemLedgerEntries);
end;

[IntegrationEvent(false, false)]
local procedure OnBeforeProcessInventoryAdjustmentBatch(var ItemNumbers: List of [Code[20]]; 
                                                       var ItemLedgerEntries: Record "Item Ledger Entry")
begin
end;
```

### Business Event Batching

Batch multiple business events for external system efficiency:

```al
codeunit 50400 "Optimized Event Publisher"
{
    var
        EventBatchQueue: List of [Text];
        BatchTimer: DateTime;
        BatchSizeLimit: Integer;
        BatchTimeLimit: Integer;
        
    procedure Initialize()
    begin
        BatchSizeLimit := 50;
        BatchTimeLimit := 5000; // 5 seconds
        BatchTimer := CurrentDateTime;
    end;
    
    procedure QueueCustomerEvent(EventType: Text; Customer: Record Customer)
    var
        EventPayload: Text;
    begin
        EventPayload := BuildCustomerEventPayload(EventType, Customer);
        EventBatchQueue.Add(EventPayload);
        
        // Publish batch when limits reached
        if (EventBatchQueue.Count >= BatchSizeLimit) or 
           (CurrentDateTime - BatchTimer > BatchTimeLimit) then
            PublishEventBatch();
    end;
    
    procedure PublishEventBatch()
    var
        BatchPayload: Text;
        EventPayload: Text;
        BatchJson: JsonObject;
        EventsArray: JsonArray;
    begin
        if EventBatchQueue.Count = 0 then
            exit;
            
        // Build consolidated batch payload
        BatchJson.Add('eventType', 'CustomerEventBatch');
        BatchJson.Add('timestamp', CurrentDateTime);
        BatchJson.Add('eventCount', EventBatchQueue.Count);
        BatchJson.Add('batchId', CreateGuid());
        
        foreach EventPayload in EventBatchQueue do
            EventsArray.Add(EventPayload);
            
        BatchJson.Add('events', EventsArray);
        BatchPayload := Format(BatchJson);
        
        // Single publish for entire batch
        Session.LogMessage('CustomerEventBatch', BatchPayload, Verbosity::Normal, 
                          DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 
                          'Category', 'BusinessEventBatch');
        
        // Reset batch state
        Clear(EventBatchQueue);
        BatchTimer := CurrentDateTime;
    end;
    
    // Force immediate batch publish (called before major operations complete)
    procedure FlushEventBatch()
    begin
        if EventBatchQueue.Count > 0 then
            PublishEventBatch();
    end;
}
```

## Data Caching Strategies

### Subscriber Data Caching

Cache expensive lookups within subscriber implementations:

```al
codeunit 50401 "Cached Event Subscriber"
{
    var
        CustomerCreditCache: Dictionary of [Code[20], Decimal];
        CacheExpiry: Dictionary of [Code[20], DateTime];
        CacheTimeout: Integer;
    
    trigger OnRun()
    begin
        CacheTimeout := 300000; // 5 minutes
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Validator", 'OnValidateOrder', '', false, false)]
    local procedure ValidateCustomerCredit(var SalesHeader: Record "Sales Header"; var ValidationErrors: List of [Text])
    var
        CreditLimit: Decimal;
        OrderTotal: Decimal;
    begin
        // Use cached credit limit to avoid repeated database queries
        CreditLimit := GetCachedCustomerCreditLimit(SalesHeader."Sell-to Customer No.");
        OrderTotal := CalculateOrderTotal(SalesHeader);
        
        if OrderTotal > CreditLimit then
            ValidationErrors.Add(StrSubstNo('Order total %1 exceeds credit limit %2', OrderTotal, CreditLimit));
    end;
    
    local procedure GetCachedCustomerCreditLimit(CustomerNo: Code[20]): Decimal
    var
        Customer: Record Customer;
        CachedLimit: Decimal;
        CachedTime: DateTime;
    begin
        // Check cache first
        if CustomerCreditCache.ContainsKey(CustomerNo) then begin
            CachedTime := CacheExpiry.Get(CustomerNo);
            if CurrentDateTime - CachedTime < CacheTimeout then
                exit(CustomerCreditCache.Get(CustomerNo));
        end;
        
        // Cache miss or expired - load from database
        if Customer.Get(CustomerNo) then begin
            CachedLimit := Customer."Credit Limit";
            CustomerCreditCache.Set(CustomerNo, CachedLimit);
            CacheExpiry.Set(CustomerNo, CurrentDateTime);
            exit(CachedLimit);
        end;
        
        exit(0);
    end;
    
    // Clean up expired cache entries periodically
    procedure CleanupExpiredCache()
    var
        CustomerNo: Code[20];
        CachedTime: DateTime;
        ExpiredKeys: List of [Code[20]];
    begin
        foreach CustomerNo in CacheExpiry.Keys do begin
            CachedTime := CacheExpiry.Get(CustomerNo);
            if CurrentDateTime - CachedTime >= CacheTimeout then
                ExpiredKeys.Add(CustomerNo);
        end;
        
        foreach CustomerNo in ExpiredKeys do begin
            CustomerCreditCache.Remove(CustomerNo);
            CacheExpiry.Remove(CustomerNo);
        end;
    end;
}
```

### Event Parameter Optimization

Optimize expensive parameter preparation:

```al
procedure PublishOrderCompleted(SalesHeader: Record "Sales Header")
var
    SalesLines: Record "Sales Line";
    CustomerInfo: Record Customer;
    OptimizedLines: Text;
begin
    // Only load full line details if subscribers exist
    if HasEventSubscribers(Codeunit::"Order Events", 'OnOrderCompleted') then begin
        // Optimized line loading - only essential fields
        SalesLines.SetRange("Document Type", SalesHeader."Document Type");
        SalesLines.SetRange("Document No.", SalesHeader."No.");
        SalesLines.SetLoadFields("Line No.", "No.", Quantity, "Unit Price", "Line Amount");
        
        // Load customer only if needed
        if CustomerInfo.Get(SalesHeader."Sell-to Customer No.") then
            CustomerInfo.SetLoadFields("No.", Name, "Credit Limit");
            
        OnOrderCompleted(SalesHeader, SalesLines, CustomerInfo);
    end;
end;
```

## Asynchronous Event Processing

### Background Event Processing

Move non-critical events to background processing:

```al
codeunit 50402 "Async Event Processor"
{
    procedure QueueAsyncEvent(EventType: Text; EventData: Text)
    var
        EventQueueEntry: Record "Event Queue Entry";
    begin
        EventQueueEntry.Init();
        EventQueueEntry."Entry No." := GetNextEntryNo();
        EventQueueEntry."Event Type" := CopyStr(EventType, 1, MaxStrLen(EventQueueEntry."Event Type"));
        EventQueueEntry."Event Data" := EventData;
        EventQueueEntry."Queued DateTime" := CurrentDateTime;
        EventQueueEntry."Processing Status" := EventQueueEntry."Processing Status"::Queued;
        EventQueueEntry.Insert();
        
        // Schedule background processing
        if not IsTaskScheduled() then
            TaskScheduler.CreateTask(Codeunit::"Background Event Processor", 0, true, CompanyName, CurrentDateTime + 1000);
    end;
    
    procedure ProcessQueuedEvents()
    var
        EventQueueEntry: Record "Event Queue Entry";
        ProcessingStartTime: DateTime;
        ProcessedCount: Integer;
        MaxProcessingTime: Integer;
    begin
        MaxProcessingTime := 30000; // 30 seconds maximum processing time
        ProcessingStartTime := CurrentDateTime;
        
        EventQueueEntry.SetRange("Processing Status", EventQueueEntry."Processing Status"::Queued);
        EventQueueEntry.SetCurrentKey("Queued DateTime");
        
        if EventQueueEntry.FindSet() then
            repeat
                if CurrentDateTime - ProcessingStartTime > MaxProcessingTime then
                    break; // Yield to prevent long-running processes
                    
                ProcessSingleEvent(EventQueueEntry);
                ProcessedCount += 1;
                
            until EventQueueEntry.Next() = 0;
        
        // Schedule next processing cycle if more events remain
        if HasQueuedEvents() then
            TaskScheduler.CreateTask(Codeunit::"Background Event Processor", 0, true, CompanyName, CurrentDateTime + 5000);
    end;
}
```

## Performance Monitoring

### Event Performance Metrics

Monitor event performance to identify bottlenecks:

```al
codeunit 50403 "Event Performance Monitor"
{
    procedure LogEventPerformance(EventName: Text; SubscriberCount: Integer; TotalDuration: Duration; AverageSubscriberDuration: Duration)
    var
        PerfData: JsonObject;
        PerfPayload: Text;
    begin
        PerfData.Add('eventName', EventName);
        PerfData.Add('subscriberCount', SubscriberCount);
        PerfData.Add('totalDuration', TotalDuration);
        PerfData.Add('averageDuration', AverageSubscriberDuration);
        PerfData.Add('timestamp', CurrentDateTime);
        PerfData.Add('company', CompanyName);
        
        PerfPayload := Format(PerfData);
        
        Session.LogMessage('EventPerformance', PerfPayload, Verbosity::Normal, 
                          DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 
                          'Category', 'Performance');
    end;
    
    procedure MeasureEventExecution(EventPublisher: Codeunit "Event Publisher"; EventName: Text)
    var
        StartTime: DateTime;
        EndTime: DateTime;
        Duration: Duration;
    begin
        StartTime := CurrentDateTime;
        
        // Execute event (this would be actual event call)
        // EventPublisher.PublishEvent();
        
        EndTime := CurrentDateTime;
        Duration := EndTime - StartTime;
        
        if Duration > 1000 then // Log events taking longer than 1 second
            LogSlowEvent(EventName, Duration);
    end;
}
```

## Best Practices Summary

### Performance Guidelines

1. **Minimize Event Overhead**:
   - Use `IsHandled` patterns for early exits
   - Only fire events when subscribers exist  
   - Batch multiple records into single events
   - Cache expensive data lookups

2. **Optimize Subscriber Design**:
   - Keep subscriber logic lightweight
   - Use TryFunction for operations that might fail
   - Implement proper error handling
   - Cache data within subscribers when appropriate

3. **Monitor and Measure**:
   - Log performance metrics for critical events
   - Set performance budgets for event processing
   - Alert on events exceeding thresholds
   - Regularly review event performance data

4. **Asynchronous Processing**:
   - Move non-critical events to background processing
   - Use queuing for high-volume event scenarios
   - Implement retry logic for failed events
   - Consider external message queues for very high volumes

Event performance optimization ensures that extensibility enhances rather than hinders system performance, creating sustainable event-driven architectures that scale with business needs.
