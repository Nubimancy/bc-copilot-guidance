---
title: "Event Performance Optimization - Code Samples"
description: "Complete implementation examples for optimizing AL event performance in high-volume scenarios"
area: "performance-optimization"
difficulty: "advanced"
object_types: ["Codeunit"]
variable_types: ["Record", "List", "Dictionary"]
tags: ["performance", "events", "optimization", "samples", "batching", "caching"]
---

# Event Performance Optimization - Code Samples

## Complete Batching Implementation

### High-Performance Order Processing System

```al
codeunit 50500 "Optimized Order Processor"
{
    var
        OrderBatch: List of [Code[20]];
        BatchTimer: DateTime;
        BatchSizeLimit: Integer;
        BatchTimeLimit: Integer;
        PerformanceMetrics: Dictionary of [Text, Duration];
        
    trigger OnRun()
    begin
        Initialize();
    end;
    
    local procedure Initialize()
    begin
        BatchSizeLimit := 100; // Process 100 orders per batch
        BatchTimeLimit := 30000; // 30 seconds maximum batch time
        BatchTimer := CurrentDateTime;
        Clear(PerformanceMetrics);
    end;
    
    procedure ProcessOrderWithBatching(OrderNo: Code[20])
    var
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        
        // Add to batch instead of immediate processing
        OrderBatch.Add(OrderNo);
        
        // Process batch when limits reached
        if (OrderBatch.Count >= BatchSizeLimit) or 
           (CurrentDateTime - BatchTimer > BatchTimeLimit) then begin
            ProcessOrderBatch();
            LogBatchPerformance('BatchProcessing', CurrentDateTime - StartTime);
        end;
    end;
    
    local procedure ProcessOrderBatch()
    var
        SalesHeaders: Record "Sales Header";
        SalesLines: Record "Sales Line";
        OrderStatusUpdates: Dictionary of [Code[20], Enum "Sales Document Status"];
        CustomerUpdates: List of [Code[20]];
        InventoryUpdates: List of [Code[20]];
        ProcessingStart: DateTime;
        OrderNo: Code[20];
    begin
        if OrderBatch.Count = 0 then
            exit;
            
        ProcessingStart := CurrentDateTime;
        
        // Load all orders in batch efficiently
        LoadOrdersInBatch(SalesHeaders, SalesLines);
        
        // Collect all updates before firing events
        CollectBatchUpdates(SalesHeaders, OrderStatusUpdates, CustomerUpdates, InventoryUpdates);
        
        // Single events for entire batch
        OnBeforeProcessOrderBatch(OrderBatch, SalesHeaders, SalesLines);
        
        // Process all orders
        ProcessOrdersEfficiently(SalesHeaders, SalesLines, OrderStatusUpdates);
        
        // Single after event for batch
        OnAfterProcessOrderBatch(OrderBatch, OrderStatusUpdates, CustomerUpdates, InventoryUpdates);
        
        // Publish consolidated business events
        PublishBatchBusinessEvents(OrderStatusUpdates, CustomerUpdates);
        
        // Reset batch state
        Clear(OrderBatch);
        BatchTimer := CurrentDateTime;
        
        LogBatchPerformance('BatchCompletion', CurrentDateTime - ProcessingStart);
    end;
    
    local procedure LoadOrdersInBatch(var SalesHeaders: Record "Sales Header"; var SalesLines: Record "Sales Line")
    var
        OrderFilter: TextBuilder;
        OrderNo: Code[20];
    begin
        // Build efficient filter for all orders
        foreach OrderNo in OrderBatch do begin
            if OrderFilter.Length > 0 then
                OrderFilter.Append('|');
            OrderFilter.Append(OrderNo);
        end;
        
        // Load headers with optimized field selection
        SalesHeaders.SetFilter("No.", OrderFilter.ToText());
        SalesHeaders.SetLoadFields("No.", "Document Type", "Sell-to Customer No.", Status, "Order Date");
        
        // Load lines with optimized field selection
        if SalesHeaders.FindSet() then begin
            SalesLines.SetFilter("Document No.", OrderFilter.ToText());
            SalesLines.SetRange("Document Type", SalesLines."Document Type"::Order);
            SalesLines.SetLoadFields("Document No.", "Line No.", "No.", Type, Quantity, "Unit Price");
        end;
    end;
    
    local procedure CollectBatchUpdates(var SalesHeaders: Record "Sales Header";
                                       var StatusUpdates: Dictionary of [Code[20], Enum "Sales Document Status"];
                                       var CustomerUpdates: List of [Code[20]];
                                       var InventoryUpdates: List of [Code[20]])
    var
        SalesLines: Record "Sales Line";
        ItemNo: Code[20];
    begin
        // Collect status changes
        if SalesHeaders.FindSet() then
            repeat
                StatusUpdates.Set(SalesHeaders."No.", SalesHeaders.Status::"Pending Approval");
                
                // Track unique customers affected
                if not CustomerUpdates.Contains(SalesHeaders."Sell-to Customer No.") then
                    CustomerUpdates.Add(SalesHeaders."Sell-to Customer No.");
                    
                // Track unique items affected
                SalesLines.SetRange("Document No.", SalesHeaders."No.");
                if SalesLines.FindSet() then
                    repeat
                        if (SalesLines.Type = SalesLines.Type::Item) and (SalesLines."No." <> '') then begin
                            ItemNo := SalesLines."No.";
                            if not InventoryUpdates.Contains(ItemNo) then
                                InventoryUpdates.Add(ItemNo);
                        end;
                    until SalesLines.Next() = 0;
                    
            until SalesHeaders.Next() = 0;
    end;
    
    local procedure ProcessOrdersEfficiently(var SalesHeaders: Record "Sales Header"; 
                                           var SalesLines: Record "Sales Line";
                                           var StatusUpdates: Dictionary of [Code[20], Enum "Sales Document Status"])
    var
        OrderNo: Code[20];
        NewStatus: Enum "Sales Document Status";
    begin
        // Batch update all order statuses
        if SalesHeaders.FindSet() then
            repeat
                NewStatus := StatusUpdates.Get(SalesHeaders."No.");
                if SalesHeaders.Status <> NewStatus then begin
                    SalesHeaders.Status := NewStatus;
                    SalesHeaders.Modify(false); // Skip triggers for performance
                end;
            until SalesHeaders.Next() = 0;
    end;
    
    local procedure PublishBatchBusinessEvents(var OrderStatusUpdates: Dictionary of [Code[20], Enum "Sales Document Status"];
                                             var CustomerUpdates: List of [Code[20]])
    var
        BatchEventPayload: Text;
        EventJson: JsonObject;
        OrdersArray: JsonArray;
        CustomersArray: JsonArray;
        OrderNo: Code[20];
        CustomerNo: Code[20];
        Status: Enum "Sales Document Status";
        OrderObj: JsonObject;
    begin
        // Build consolidated business event
        EventJson.Add('eventType', 'OrderBatchProcessed');
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('batchId', CreateGuid());
        EventJson.Add('orderCount', OrderStatusUpdates.Count);
        EventJson.Add('customerCount', CustomerUpdates.Count);
        
        // Add order details
        foreach OrderNo in OrderStatusUpdates.Keys do begin
            Clear(OrderObj);
            Status := OrderStatusUpdates.Get(OrderNo);
            OrderObj.Add('orderNo', OrderNo);
            OrderObj.Add('newStatus', Format(Status));
            OrdersArray.Add(OrderObj);
        end;
        EventJson.Add('orders', OrdersArray);
        
        // Add customer list
        foreach CustomerNo in CustomerUpdates do
            CustomersArray.Add(CustomerNo);
        EventJson.Add('customers', CustomersArray);
        
        BatchEventPayload := Format(EventJson);
        
        // Publish single business event for entire batch
        Session.LogMessage('OrderBatchProcessed', BatchEventPayload, Verbosity::Normal, 
                          DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 
                          'Category', 'BusinessEventBatch');
    end;
    
    // Integration events for batch processing
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrderBatch(var OrderNumbers: List of [Code[20]];
                                            var SalesHeaders: Record "Sales Header";
                                            var SalesLines: Record "Sales Line")
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessOrderBatch(var OrderNumbers: List of [Code[20]];
                                           var StatusUpdates: Dictionary of [Code[20], Enum "Sales Document Status"];
                                           var CustomerUpdates: List of [Code[20]];
                                           var InventoryUpdates: List of [Code[20]])
    begin
    end;
    
    local procedure LogBatchPerformance(Operation: Text; Duration: Duration)
    begin
        PerformanceMetrics.Set(Operation, Duration);
        
        Session.LogMessage('BatchPerformance', 
                          StrSubstNo('%1: %2ms, BatchSize: %3', Operation, Duration, OrderBatch.Count), 
                          Verbosity::Normal, DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'Performance');
    end;
    
    // Force immediate batch processing (called at transaction boundaries)
    procedure FlushOrderBatch()
    begin
        if OrderBatch.Count > 0 then
            ProcessOrderBatch();
    end;
}
```

## Advanced Caching System

### Multi-Level Event Subscriber Cache

```al
codeunit 50501 "Advanced Cache Event Subscriber"
{
    var
        // Level 1: In-memory cache with fast access
        CustomerCache: Dictionary of [Code[20], Text]; // JSON serialized customer data
        ItemCache: Dictionary of [Code[20], Text]; // JSON serialized item data
        
        // Level 2: Cache metadata for intelligent eviction
        CacheTimestamps: Dictionary of [Text, DateTime];
        CacheHitCount: Dictionary of [Text, Integer];
        CacheAccessOrder: List of [Text]; // LRU tracking
        
        // Configuration
        MaxCacheEntries: Integer;
        CacheExpiryTime: Integer;
        
    trigger OnRun()
    begin
        Initialize();
    end;
    
    local procedure Initialize()
    begin
        MaxCacheEntries := 1000;
        CacheExpiryTime := 300000; // 5 minutes
        
        // Schedule periodic cache cleanup
        TaskScheduler.CreateTask(Codeunit::"Cache Cleanup Task", 0, true, CompanyName, CurrentDateTime + 60000);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Validator", 'OnValidateOrder', '', false, false)]
    local procedure ValidateOrderWithCaching(var SalesHeader: Record "Sales Header"; 
                                           var SalesLines: Record "Sales Line";
                                           var ValidationErrors: List of [Text])
    var
        Customer: JsonObject;
        Items: Dictionary of [Code[20], JsonObject];
        ValidationStartTime: DateTime;
    begin
        ValidationStartTime := CurrentDateTime;
        
        // Load customer data with caching
        Customer := GetCachedCustomerData(SalesHeader."Sell-to Customer No.");
        
        // Load item data for all lines with caching
        LoadCachedItemsForOrder(SalesLines, Items);
        
        // Perform validation using cached data
        ValidateCustomerBusinessRules(Customer, SalesHeader, ValidationErrors);
        ValidateItemBusinessRules(Items, SalesLines, ValidationErrors);
        
        // Log cache performance
        LogCachePerformance('OrderValidation', CurrentDateTime - ValidationStartTime);
    end;
    
    local procedure GetCachedCustomerData(CustomerNo: Code[20]): JsonObject
    var
        Customer: Record Customer;
        CustomerJson: JsonObject;
        CachedData: Text;
        CacheKey: Text;
    begin
        CacheKey := 'Customer_' + CustomerNo;
        
        // Check cache first
        if IsDataCached(CacheKey) then begin
            CachedData := CustomerCache.Get(CustomerNo);
            if CustomerJson.ReadFrom(CachedData) then begin
                RecordCacheHit(CacheKey);
                UpdateAccessOrder(CacheKey);
                exit(CustomerJson);
            end;
        end;
        
        // Cache miss - load from database
        if Customer.Get(CustomerNo) then begin
            BuildCustomerJson(Customer, CustomerJson);
            CacheCustomerData(CustomerNo, Format(CustomerJson));
            RecordCacheMiss(CacheKey);
        end;
        
        exit(CustomerJson);
    end;
    
    local procedure LoadCachedItemsForOrder(var SalesLines: Record "Sales Line"; var Items: Dictionary of [Code[20], JsonObject])
    var
        ItemNumbers: List of [Code[20]];
        UncachedItems: List of [Code[20]];
        ItemNo: Code[20];
        ItemJson: JsonObject;
    begin
        // Collect unique item numbers
        if SalesLines.FindSet() then
            repeat
                if (SalesLines.Type = SalesLines.Type::Item) and (SalesLines."No." <> '') then
                    if not ItemNumbers.Contains(SalesLines."No.") then
                        ItemNumbers.Add(SalesLines."No.");
            until SalesLines.Next() = 0;
        
        // Check cache for each item
        foreach ItemNo in ItemNumbers do begin
            ItemJson := GetCachedItemData(ItemNo);
            if ItemJson.Keys.Count > 0 then
                Items.Set(ItemNo, ItemJson)
            else
                UncachedItems.Add(ItemNo);
        end;
        
        // Batch load uncached items
        if UncachedItems.Count > 0 then
            BatchLoadAndCacheItems(UncachedItems, Items);
    end;
    
    local procedure GetCachedItemData(ItemNo: Code[20]): JsonObject
    var
        ItemJson: JsonObject;
        CachedData: Text;
        CacheKey: Text;
    begin
        CacheKey := 'Item_' + ItemNo;
        
        if IsDataCached(CacheKey) then begin
            CachedData := ItemCache.Get(ItemNo);
            if ItemJson.ReadFrom(CachedData) then begin
                RecordCacheHit(CacheKey);
                UpdateAccessOrder(CacheKey);
                exit(ItemJson);
            end;
        end;
        
        RecordCacheMiss(CacheKey);
        exit(ItemJson); // Return empty object for cache miss
    end;
    
    local procedure BatchLoadAndCacheItems(var ItemNumbers: List of [Code[20]]; var Items: Dictionary of [Code[20], JsonObject])
    var
        Item: Record Item;
        ItemFilter: TextBuilder;
        ItemNo: Code[20];
        ItemJson: JsonObject;
        LoadStartTime: DateTime;
    begin
        LoadStartTime := CurrentDateTime;
        
        // Build efficient filter
        foreach ItemNo in ItemNumbers do begin
            if ItemFilter.Length > 0 then
                ItemFilter.Append('|');
            ItemFilter.Append(ItemNo);
        end;
        
        // Load all items with optimized field selection
        Item.SetFilter("No.", ItemFilter.ToText());
        Item.SetLoadFields("No.", Description, "Unit Price", "Unit Cost", Inventory, Blocked);
        
        if Item.FindSet() then
            repeat
                BuildItemJson(Item, ItemJson);
                Items.Set(Item."No.", ItemJson);
                CacheItemData(Item."No.", Format(ItemJson));
                Clear(ItemJson);
            until Item.Next() = 0;
            
        LogCachePerformance('BatchItemLoad', CurrentDateTime - LoadStartTime);
    end;
    
    local procedure BuildCustomerJson(Customer: Record Customer; var CustomerJson: JsonObject)
    begin
        CustomerJson.Add('no', Customer."No.");
        CustomerJson.Add('name', Customer.Name);
        CustomerJson.Add('blocked', Format(Customer.Blocked));
        CustomerJson.Add('creditLimit', Customer."Credit Limit");
        CustomerJson.Add('balance', Customer."Balance (LCY)");
        CustomerJson.Add('paymentTerms', Customer."Payment Terms Code");
        CustomerJson.Add('lastModified', Customer.SystemModifiedAt);
    end;
    
    local procedure BuildItemJson(Item: Record Item; var ItemJson: JsonObject)
    begin
        ItemJson.Add('no', Item."No.");
        ItemJson.Add('description', Item.Description);
        ItemJson.Add('unitPrice', Item."Unit Price");
        ItemJson.Add('unitCost', Item."Unit Cost");
        ItemJson.Add('inventory', Item.Inventory);
        ItemJson.Add('blocked', Item.Blocked);
        ItemJson.Add('lastModified', Item.SystemModifiedAt);
    end;
    
    local procedure CacheCustomerData(CustomerNo: Code[20]; CustomerData: Text)
    var
        CacheKey: Text;
    begin
        CacheKey := 'Customer_' + CustomerNo;
        
        // Ensure cache size limits
        EnsureCacheCapacity();
        
        CustomerCache.Set(CustomerNo, CustomerData);
        CacheTimestamps.Set(CacheKey, CurrentDateTime);
        UpdateAccessOrder(CacheKey);
    end;
    
    local procedure CacheItemData(ItemNo: Code[20]; ItemData: Text)
    var
        CacheKey: Text;
    begin
        CacheKey := 'Item_' + ItemNo;
        
        // Ensure cache size limits
        EnsureCacheCapacity();
        
        ItemCache.Set(ItemNo, ItemData);
        CacheTimestamps.Set(CacheKey, CurrentDateTime);
        UpdateAccessOrder(CacheKey);
    end;
    
    local procedure IsDataCached(CacheKey: Text): Boolean
    var
        CacheTime: DateTime;
    begin
        if not CacheTimestamps.ContainsKey(CacheKey) then
            exit(false);
            
        CacheTime := CacheTimestamps.Get(CacheKey);
        if CurrentDateTime - CacheTime > CacheExpiryTime then begin
            RemoveFromCache(CacheKey);
            exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure EnsureCacheCapacity()
    begin
        while (CustomerCache.Count + ItemCache.Count) >= MaxCacheEntries do
            EvictLeastRecentlyUsed();
    end;
    
    local procedure EvictLeastRecentlyUsed()
    var
        LRUKey: Text;
        KeyParts: List of [Text];
        EntityType: Text;
        EntityNo: Code[20];
    begin
        if CacheAccessOrder.Count = 0 then
            exit;
            
        // Get least recently used item
        LRUKey := CacheAccessOrder.Get(1);
        CacheAccessOrder.RemoveAt(1);
        
        // Parse key to determine cache type
        KeyParts := LRUKey.Split('_');
        if KeyParts.Count >= 2 then begin
            EntityType := KeyParts.Get(1);
            EntityNo := KeyParts.Get(2);
            
            case EntityType of
                'Customer':
                    CustomerCache.Remove(EntityNo);
                'Item':
                    ItemCache.Remove(EntityNo);
            end;
        end;
        
        CacheTimestamps.Remove(LRUKey);
        if CacheHitCount.ContainsKey(LRUKey) then
            CacheHitCount.Remove(LRUKey);
    end;
    
    local procedure UpdateAccessOrder(CacheKey: Text)
    var
        ExistingIndex: Integer;
    begin
        // Remove from current position
        ExistingIndex := CacheAccessOrder.IndexOf(CacheKey);
        if ExistingIndex > 0 then
            CacheAccessOrder.RemoveAt(ExistingIndex);
            
        // Add to end (most recently used)
        CacheAccessOrder.Add(CacheKey);
    end;
    
    local procedure RemoveFromCache(CacheKey: Text)
    var
        KeyParts: List of [Text];
        EntityType: Text;
        EntityNo: Code[20];
    begin
        KeyParts := CacheKey.Split('_');
        if KeyParts.Count >= 2 then begin
            EntityType := KeyParts.Get(1);
            EntityNo := KeyParts.Get(2);
            
            case EntityType of
                'Customer':
                    if CustomerCache.ContainsKey(EntityNo) then
                        CustomerCache.Remove(EntityNo);
                'Item':
                    if ItemCache.ContainsKey(EntityNo) then
                        ItemCache.Remove(EntityNo);
            end;
        end;
        
        CacheTimestamps.Remove(CacheKey);
        CacheAccessOrder.Remove(CacheKey);
    end;
    
    local procedure RecordCacheHit(CacheKey: Text)
    var
        HitCount: Integer;
    begin
        if CacheHitCount.ContainsKey(CacheKey) then
            HitCount := CacheHitCount.Get(CacheKey);
        CacheHitCount.Set(CacheKey, HitCount + 1);
    end;
    
    local procedure RecordCacheMiss(CacheKey: Text)
    begin
        // Cache miss logging for optimization analysis
        Session.LogMessage('CacheMiss', CacheKey, Verbosity::Normal, 
                          DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 
                          'Category', 'CachePerformance');
    end;
    
    local procedure LogCachePerformance(Operation: Text; Duration: Duration)
    var
        PerfData: JsonObject;
        PerfPayload: Text;
    begin
        PerfData.Add('operation', Operation);
        PerfData.Add('duration', Duration);
        PerfData.Add('customerCacheSize', CustomerCache.Count);
        PerfData.Add('itemCacheSize', ItemCache.Count);
        PerfData.Add('totalCacheEntries', CacheTimestamps.Count);
        PerfData.Add('timestamp', CurrentDateTime);
        
        PerfPayload := Format(PerfData);
        
        Session.LogMessage('CachePerformance', PerfPayload, Verbosity::Normal, 
                          DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 
                          'Category', 'Performance');
    end;
    
    // Public method to clear cache when needed
    procedure ClearCache()
    begin
        Clear(CustomerCache);
        Clear(ItemCache);
        Clear(CacheTimestamps);
        Clear(CacheHitCount);
        Clear(CacheAccessOrder);
    end;
    
    // Public method to get cache statistics
    procedure GetCacheStatistics(): Text
    var
        Stats: JsonObject;
        TotalHits: Integer;
        CacheKey: Text;
    begin
        foreach CacheKey in CacheHitCount.Keys do
            TotalHits += CacheHitCount.Get(CacheKey);
            
        Stats.Add('customerCacheEntries', CustomerCache.Count);
        Stats.Add('itemCacheEntries', ItemCache.Count);
        Stats.Add('totalHits', TotalHits);
        Stats.Add('cacheUtilization', (CustomerCache.Count + ItemCache.Count) / MaxCacheEntries * 100);
        
        exit(Format(Stats));
    end;
}
```

## Asynchronous Event Processing System

### Background Event Queue Processor

```al
codeunit 50502 "Async Event Queue Processor"
{
    TableNo = "Event Queue Entry";
    
    trigger OnRun()
    begin
        ProcessEventQueue();
    end;
    
    procedure QueueBusinessEvent(EventType: Text; EventPayload: Text; Priority: Integer)
    var
        QueueEntry: Record "Event Queue Entry";
        EntryNo: BigInteger;
    begin
        EntryNo := GetNextEntryNumber();
        
        QueueEntry.Init();
        QueueEntry."Entry No." := EntryNo;
        QueueEntry."Event Type" := CopyStr(EventType, 1, MaxStrLen(QueueEntry."Event Type"));
        QueueEntry."Priority" := Priority;
        QueueEntry."Queued DateTime" := CurrentDateTime;
        QueueEntry."Processing Status" := QueueEntry."Processing Status"::Queued;
        QueueEntry."Retry Count" := 0;
        QueueEntry."Max Retries" := 3;
        
        // Store payload in blob field
        SetEventPayload(QueueEntry, EventPayload);
        QueueEntry.Insert();
        
        // Schedule processing if needed
        ScheduleProcessing();
    end;
    
    local procedure ProcessEventQueue()
    var
        QueueEntry: Record "Event Queue Entry";
        ProcessingStartTime: DateTime;
        MaxProcessingDuration: Integer;
        ProcessedCount: Integer;
        FailedCount: Integer;
    begin
        ProcessingStartTime := CurrentDateTime;
        MaxProcessingDuration := 30000; // 30 seconds maximum
        
        // Process in priority order
        QueueEntry.SetRange("Processing Status", QueueEntry."Processing Status"::Queued);
        QueueEntry.SetCurrentKey(Priority, "Queued DateTime");
        QueueEntry.SetAscending(Priority, false); // High priority first
        
        if QueueEntry.FindSet() then
            repeat
                // Check time limit to prevent long-running processes
                if CurrentDateTime - ProcessingStartTime > MaxProcessingDuration then
                    break;
                    
                if ProcessSingleQueueEntry(QueueEntry) then
                    ProcessedCount += 1
                else
                    FailedCount += 1;
                    
            until QueueEntry.Next() = 0;
        
        // Log processing results
        LogQueueProcessingResults(ProcessedCount, FailedCount, CurrentDateTime - ProcessingStartTime);
        
        // Schedule next processing cycle if more work remains
        if HasPendingEvents() then
            ScheduleProcessing();
    end;
    
    local procedure ProcessSingleQueueEntry(var QueueEntry: Record "Event Queue Entry"): Boolean
    var
        EventPayload: Text;
        ProcessingStartTime: DateTime;
        IsSuccess: Boolean;
    begin
        ProcessingStartTime := CurrentDateTime;
        
        // Mark as processing
        QueueEntry."Processing Status" := QueueEntry."Processing Status"::Processing;
        QueueEntry."Processing Started" := CurrentDateTime;
        QueueEntry.Modify();
        Commit(); // Ensure status is saved
        
        // Get event payload
        EventPayload := GetEventPayload(QueueEntry);
        
        // Process the event
        IsSuccess := TryProcessBusinessEvent(QueueEntry."Event Type", EventPayload);
        
        if IsSuccess then begin
            // Mark as completed
            QueueEntry."Processing Status" := QueueEntry."Processing Status"::Completed;
            QueueEntry."Completed DateTime" := CurrentDateTime;
            QueueEntry."Processing Duration" := CurrentDateTime - ProcessingStartTime;
            QueueEntry.Modify();
        end else begin
            // Handle failure
            HandleEventProcessingFailure(QueueEntry);
        end;
        
        Commit(); // Ensure status is saved
        exit(IsSuccess);
    end;
    
    [TryFunction]
    local procedure TryProcessBusinessEvent(EventType: Text; EventPayload: Text)
    var
        EventProcessor: Codeunit "Business Event Processor";
    begin
        case EventType of
            'CustomerCreated':
                EventProcessor.ProcessCustomerCreatedEvent(EventPayload);
            'OrderStatusChanged':
                EventProcessor.ProcessOrderStatusChangedEvent(EventPayload);
            'InventoryLevelChanged':
                EventProcessor.ProcessInventoryLevelChangedEvent(EventPayload);
            'PaymentReceived':
                EventProcessor.ProcessPaymentReceivedEvent(EventPayload);
            else
                Error('Unknown event type: %1', EventType);
        end;
    end;
    
    local procedure HandleEventProcessingFailure(var QueueEntry: Record "Event Queue Entry")
    var
        ErrorMessage: Text;
        ShouldRetry: Boolean;
    begin
        ErrorMessage := GetLastErrorText();
        QueueEntry."Retry Count" += 1;
        QueueEntry."Last Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(QueueEntry."Last Error Message"));
        QueueEntry."Last Retry DateTime" := CurrentDateTime;
        
        ShouldRetry := QueueEntry."Retry Count" < QueueEntry."Max Retries";
        
        if ShouldRetry then begin
            // Schedule retry with exponential backoff
            QueueEntry."Processing Status" := QueueEntry."Processing Status"::Queued;
            QueueEntry."Next Retry DateTime" := CurrentDateTime + (QueueEntry."Retry Count" * QueueEntry."Retry Count" * 60000); // Quadratic backoff
        end else begin
            // Max retries exceeded - mark as failed
            QueueEntry."Processing Status" := QueueEntry."Processing Status"::Failed;
            QueueEntry."Completed DateTime" := CurrentDateTime;
            
            // Log critical failure
            LogCriticalEventFailure(QueueEntry, ErrorMessage);
        end;
        
        QueueEntry.Modify();
    end;
    
    local procedure ScheduleProcessing()
    var
        TaskExists: Boolean;
    begin
        // Check if processing task is already scheduled
        TaskExists := IsProcessingTaskScheduled();
        
        if not TaskExists then begin
            TaskScheduler.CreateTask(Codeunit::"Async Event Queue Processor", 
                                   0, true, CompanyName, 
                                   CurrentDateTime + 5000, // 5 second delay
                                   RecordId);
        end;
    end;
    
    local procedure IsProcessingTaskScheduled(): Boolean
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        ScheduledTask.SetRange("Object Type to Run", ScheduledTask."Object Type to Run"::Codeunit);
        ScheduledTask.SetRange("Object ID to Run", Codeunit::"Async Event Queue Processor");
        ScheduledTask.SetRange("Is Ready", true);
        ScheduledTask.SetFilter("Not Before", '>%1', CurrentDateTime - 60000); // Tasks scheduled in last minute
        
        exit(not ScheduledTask.IsEmpty);
    end;
    
    local procedure HasPendingEvents(): Boolean
    var
        QueueEntry: Record "Event Queue Entry";
    begin
        QueueEntry.SetRange("Processing Status", QueueEntry."Processing Status"::Queued);
        QueueEntry.SetFilter("Next Retry DateTime", '<=%1|%2', CurrentDateTime, 0DT);
        exit(not QueueEntry.IsEmpty);
    end;
    
    local procedure GetNextEntryNumber(): BigInteger
    var
        QueueEntry: Record "Event Queue Entry";
    begin
        QueueEntry.SetCurrentKey("Entry No.");
        if QueueEntry.FindLast() then
            exit(QueueEntry."Entry No." + 1)
        else
            exit(1);
    end;
    
    local procedure SetEventPayload(var QueueEntry: Record "Event Queue Entry"; EventPayload: Text)
    var
        PayloadOutStream: OutStream;
    begin
        QueueEntry."Event Payload".CreateOutStream(PayloadOutStream, TextEncoding::UTF8);
        PayloadOutStream.WriteText(EventPayload);
    end;
    
    local procedure GetEventPayload(QueueEntry: Record "Event Queue Entry"): Text
    var
        PayloadInStream: InStream;
        EventPayload: Text;
    begin
        QueueEntry.CalcFields("Event Payload");
        QueueEntry."Event Payload".CreateInStream(PayloadInStream, TextEncoding::UTF8);
        PayloadInStream.ReadText(EventPayload);
        exit(EventPayload);
    end;
    
    local procedure LogQueueProcessingResults(ProcessedCount: Integer; FailedCount: Integer; Duration: Duration)
    var
        ResultsJson: JsonObject;
    begin
        ResultsJson.Add('processedCount', ProcessedCount);
        ResultsJson.Add('failedCount', FailedCount);
        ResultsJson.Add('processingDuration', Duration);
        ResultsJson.Add('timestamp', CurrentDateTime);
        
        Session.LogMessage('QueueProcessing', Format(ResultsJson), Verbosity::Normal, 
                          DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 
                          'Category', 'AsyncProcessing');
    end;
    
    local procedure LogCriticalEventFailure(QueueEntry: Record "Event Queue Entry"; ErrorMessage: Text)
    begin
        Session.LogMessage('CriticalEventFailure', 
                          StrSubstNo('Event %1 (Entry %2) failed after %3 retries: %4', 
                                   QueueEntry."Event Type", QueueEntry."Entry No.", 
                                   QueueEntry."Retry Count", ErrorMessage), 
                          Verbosity::Error, DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'AsyncProcessing');
    end;
    
    // Public methods for monitoring and management
    procedure GetQueueStatistics(): Text
    var
        QueueEntry: Record "Event Queue Entry";
        Stats: JsonObject;
    begin
        Stats.Add('queuedCount', GetStatusCount(QueueEntry."Processing Status"::Queued));
        Stats.Add('processingCount', GetStatusCount(QueueEntry."Processing Status"::Processing));
        Stats.Add('completedCount', GetStatusCount(QueueEntry."Processing Status"::Completed));
        Stats.Add('failedCount', GetStatusCount(QueueEntry."Processing Status"::Failed));
        Stats.Add('timestamp', CurrentDateTime);
        
        exit(Format(Stats));
    end;
    
    local procedure GetStatusCount(Status: Enum "Event Processing Status"): Integer
    var
        QueueEntry: Record "Event Queue Entry";
    begin
        QueueEntry.SetRange("Processing Status", Status);
        exit(QueueEntry.Count);
    end;
}
```

These comprehensive examples demonstrate production-ready event performance optimization that maintains high throughput while preserving system responsiveness and reliability.
