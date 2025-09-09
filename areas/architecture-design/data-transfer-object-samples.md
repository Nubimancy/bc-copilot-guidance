# Data Transfer Object Patterns - Sample Implementations

This document provides comprehensive code samples for the data transfer object patterns outlined in `data-transfer-object-patterns.md`.

## Basic DataTransfer Samples

### Simple Field-to-Field Transfer

```al
// Basic DataTransfer for customer data migration
codeunit 50160 "Simple Customer Transfer"
{
    procedure TransferCustomerBasicData()
    var
        OldCustomer: Record "Old Customer";
        NewCustomer: Record "New Customer";
        DataTransfer: DataTransfer;
        RecordCount: Integer;
    begin
        // Initialize DataTransfer
        DataTransfer.SetTables(Database::"Old Customer", Database::"New Customer");
        
        // Map basic fields
        DataTransfer.AddFieldValue(OldCustomer.FieldNo("No."), NewCustomer.FieldNo("No."));
        DataTransfer.AddFieldValue(OldCustomer.FieldNo(Name), NewCustomer.FieldNo(Name));
        DataTransfer.AddFieldValue(OldCustomer.FieldNo(Address), NewCustomer.FieldNo(Address));
        DataTransfer.AddFieldValue(OldCustomer.FieldNo(City), NewCustomer.FieldNo(City));
        DataTransfer.AddFieldValue(OldCustomer.FieldNo("Post Code"), NewCustomer.FieldNo("Post Code"));
        
        // Add constant values for new fields
        DataTransfer.AddConstantValue(Today(), NewCustomer.FieldNo("Migration Date"));
        DataTransfer.AddConstantValue('BASIC_MIGRATION', NewCustomer.FieldNo("Migration Type"));
        
        // Execute transfer
        RecordCount := DataTransfer.CopyRows();
        Message('Transferred %1 customer records', RecordCount);
    end;
}
```

### Selective Transfer with Filters

```al
// Transfer with source filters and conditions
codeunit 50161 "Selective Data Transfer"
{
    procedure TransferActiveItemsOnly()
    var
        SourceItem: Record "Legacy Item";
        TargetItem: Record "Modern Item";
        DataTransfer: DataTransfer;
        TransferView: Text;
    begin
        // Set up filters on source
        SourceItem.SetRange(Blocked, false);
        SourceItem.SetRange("Item Category Code", 'FINISHED_GOODS');
        SourceItem.SetFilter("Unit Price", '>0');
        
        // Create view string with filters
        TransferView := SourceItem.GetView();
        
        // Initialize transfer with filtered view
        DataTransfer.SetTables(Database::"Legacy Item", Database::"Modern Item");
        DataTransfer.CopyTable(TransferView);
        
        // Map fields
        DataTransfer.AddFieldValue(SourceItem.FieldNo("No."), TargetItem.FieldNo("No."));
        DataTransfer.AddFieldValue(SourceItem.FieldNo(Description), TargetItem.FieldNo(Description));
        DataTransfer.AddFieldValue(SourceItem.FieldNo("Unit Price"), TargetItem.FieldNo("Unit Price"));
        DataTransfer.AddFieldValue(SourceItem.FieldNo("Unit Cost"), TargetItem.FieldNo("Unit Cost"));
        
        // Add filter-based constants
        DataTransfer.AddConstantValue('ACTIVE', TargetItem.FieldNo(Status));
        DataTransfer.AddConstantValue('MIGRATED_FILTERED', TargetItem.FieldNo("Transfer Method"));
        
        if DataTransfer.CopyRows() then
            Message('Selective transfer completed successfully')
        else
            Error('Transfer failed: %1', GetLastErrorText());
    end;
}
```

### Multi-Table Transfer Coordination

```al
// Coordinated transfer across related tables
codeunit 50162 "Multi Table Transfer"
{
    procedure TransferCustomerAndContacts()
    var
        CustomerTransferResult: Integer;
        ContactTransferResult: Integer;
        TotalTransferred: Integer;
    begin
        // Transfer customers first (parent records)
        CustomerTransferResult := TransferCustomerMasterData();
        
        if CustomerTransferResult > 0 then begin
            // Transfer related contacts
            ContactTransferResult := TransferRelatedContacts();
            
            TotalTransferred := CustomerTransferResult + ContactTransferResult;
            LogMultiTableTransferResults(CustomerTransferResult, ContactTransferResult);
        end else
            Error('Customer transfer failed - aborting contact transfer');
        
        Message('Multi-table transfer completed. Total records: %1', TotalTransferred);
    end;
    
    local procedure TransferCustomerMasterData(): Integer
    var
        SourceCustomer: Record "Legacy Customer";
        TargetCustomer: Record "Modern Customer";
        DataTransfer: DataTransfer;
    begin
        DataTransfer.SetTables(Database::"Legacy Customer", Database::"Modern Customer");
        
        // Customer fields
        DataTransfer.AddFieldValue(SourceCustomer.FieldNo("No."), TargetCustomer.FieldNo("No."));
        DataTransfer.AddFieldValue(SourceCustomer.FieldNo(Name), TargetCustomer.FieldNo(Name));
        DataTransfer.AddFieldValue(SourceCustomer.FieldNo("Customer Posting Group"), TargetCustomer.FieldNo("Customer Posting Group"));
        
        // Migration tracking
        DataTransfer.AddConstantValue('CUSTOMER_MASTER', TargetCustomer.FieldNo("Migration Phase"));
        DataTransfer.AddConstantValue(1, TargetCustomer.FieldNo("Migration Order"));
        
        exit(DataTransfer.CopyRows());
    end;
    
    local procedure TransferRelatedContacts(): Integer
    var
        SourceContact: Record "Legacy Contact";
        TargetContact: Record "Modern Contact";
        DataTransfer: DataTransfer;
        ModernCustomer: Record "Modern Customer";
    begin
        // Only transfer contacts for successfully migrated customers
        SourceContact.SetFilter("Customer No.", '<>%1', '');
        
        // Validate that all referenced customers exist in target
        if not ValidateCustomerReferencesExist(SourceContact) then
            Error('Cannot transfer contacts - some referenced customers missing');
        
        DataTransfer.SetTables(Database::"Legacy Contact", Database::"Modern Contact");
        
        // Contact fields
        DataTransfer.AddFieldValue(SourceContact.FieldNo("No."), TargetContact.FieldNo("No."));
        DataTransfer.AddFieldValue(SourceContact.FieldNo(Name), TargetContact.FieldNo(Name));
        DataTransfer.AddFieldValue(SourceContact.FieldNo("Customer No."), TargetContact.FieldNo("Customer No."));
        DataTransfer.AddFieldValue(SourceContact.FieldNo("E-Mail"), TargetContact.FieldNo("E-Mail"));
        
        // Migration tracking
        DataTransfer.AddConstantValue('CUSTOMER_CONTACTS', TargetContact.FieldNo("Migration Phase"));
        DataTransfer.AddConstantValue(2, TargetContact.FieldNo("Migration Order"));
        
        exit(DataTransfer.CopyRows());
    end;
    
    local procedure ValidateCustomerReferencesExist(var SourceContact: Record "Legacy Contact"): Boolean
    var
        ModernCustomer: Record "Modern Customer";
        MissingCustomers: Integer;
    begin
        SourceContact.SetCurrentKey("Customer No.");
        if SourceContact.FindSet() then begin
            repeat
                if not ModernCustomer.Get(SourceContact."Customer No.") then
                    MissingCustomers += 1;
            until SourceContact.Next() = 0;
        end;
        
        if MissingCustomers > 0 then begin
            Error('Found %1 contacts referencing non-migrated customers', MissingCustomers);
            exit(false);
        end;
        
        exit(true);
    end;
}
```

## Intermediate Transfer Samples

### Complex Field Transformation

```al
// Advanced field transformation during transfer
codeunit 50200 "Transform Transfer Example"
{
    var
        TransformationLog: Record "Transformation Log" temporary;
    
    procedure TransferWithComplexTransformations()
    var
        SourceProduct: Record "Legacy Product";
        TargetProduct: Record "Modern Product";
        DataTransfer: DataTransfer;
        TransformationSuccess: Boolean;
    begin
        ClearTransformationLog();
        
        // Pre-process transformations
        TransformationSuccess := PreprocessProductTransformations();
        
        if TransformationSuccess then begin
            // Execute main transfer
            DataTransfer.SetTables(Database::"Legacy Product", Database::"Modern Product");
            SetupProductFieldMappings(DataTransfer, SourceProduct, TargetProduct);
            
            if DataTransfer.CopyRows() then begin
                // Post-process validation
                ValidateTransformationResults();
                Message('Complex transformation completed successfully');
            end else
                Error('Transfer execution failed: %1', GetLastErrorText());
        end else
            HandleTransformationFailure();
    end;
    
    local procedure PreprocessProductTransformations(): Boolean
    var
        SourceProduct: Record "Legacy Product";
        TransformHelper: Record "Product Transform Helper" temporary;
        ProcessedCount: Integer;
        ErrorCount: Integer;
    begin
        // Process each product individually for complex transformations
        if SourceProduct.FindSet() then begin
            repeat
                if TransformSingleProduct(SourceProduct, TransformHelper) then
                    ProcessedCount += 1
                else
                    ErrorCount += 1;
            until SourceProduct.Next() = 0;
        end;
        
        LogTransformationSummary(ProcessedCount, ErrorCount);
        exit(ErrorCount = 0);
    end;
    
    local procedure TransformSingleProduct(var SourceProduct: Record "Legacy Product"; var TransformHelper: Record "Product Transform Helper" temporary): Boolean
    var
        CategoryMapper: Codeunit "Category Transformation";
        PriceCalculator: Codeunit "Price Transformation";
        DimensionMapper: Codeunit "Dimension Transformation";
        ValidationPassed: Boolean;
    begin
        ValidationPassed := true;
        
        try
            // Transform category code with complex logic
            TransformHelper."New Category" := CategoryMapper.MapComplexCategory(
                SourceProduct."Legacy Category",
                SourceProduct."Sub Category",
                SourceProduct."Product Type");
                
            // Transform pricing with business rules
            TransformHelper."New Price" := PriceCalculator.CalculateTransformedPrice(
                SourceProduct."Base Price",
                SourceProduct."Markup Percentage",
                SourceProduct."Volume Tier",
                SourceProduct."Currency Code");
                
            // Transform dimension codes
            TransformHelper."New Department" := DimensionMapper.MapDepartmentCode(
                SourceProduct."Old Dept Code",
                SourceProduct."Division");
                
            // Validate transformation results
            ValidationPassed := ValidateSingleTransformation(SourceProduct, TransformHelper);
            
            if ValidationPassed then
                StoreTransformationResults(SourceProduct, TransformHelper);
                
        except
            LogTransformationError(SourceProduct."No.", GetLastErrorText());
            ValidationPassed := false;
        end;
        
        exit(ValidationPassed);
    end;
    
    local procedure SetupProductFieldMappings(var DataTransfer: DataTransfer; var SourceProduct: Record "Legacy Product"; var TargetProduct: Record "Modern Product")
    begin
        // Direct field mappings
        DataTransfer.AddFieldValue(SourceProduct.FieldNo("No."), TargetProduct.FieldNo("No."));
        DataTransfer.AddFieldValue(SourceProduct.FieldNo(Description), TargetProduct.FieldNo(Description));
        
        // Transformed fields will be handled by post-processing
        // For now, use placeholder values
        DataTransfer.AddConstantValue('TBD', TargetProduct.FieldNo("Item Category Code"));
        DataTransfer.AddConstantValue(0, TargetProduct.FieldNo("Unit Price"));
        
        // Standard migration fields
        DataTransfer.AddConstantValue(Today(), TargetProduct.FieldNo("Migration Date"));
        DataTransfer.AddConstantValue('COMPLEX_TRANSFORM', TargetProduct.FieldNo("Migration Method"));
        DataTransfer.AddConstantValue(false, TargetProduct.FieldNo("Transform Validated"));
    end;
}
```

### Batch Processing with Error Recovery

```al
// Batch processing with comprehensive error handling
codeunit 50250 "Batch Transfer with Recovery"
{
    var
        BatchSize: Integer;
        MaxRetries: Integer;
        CurrentBatch: Integer;
        TotalBatches: Integer;
        
    procedure ExecuteBatchTransferWithRecovery()
    var
        BatchProcessor: Record "Batch Processing Control" temporary;
        OverallSuccess: Boolean;
        ProcessedBatches: Integer;
        FailedBatches: Integer;
    begin
        InitializeBatchProcessing();
        
        // Calculate total batches needed
        TotalBatches := CalculateTotalBatches();
        
        // Process each batch with error recovery
        for CurrentBatch := 1 to TotalBatches do begin
            if ProcessSingleBatch(CurrentBatch, BatchProcessor) then
                ProcessedBatches += 1
            else begin
                FailedBatches += 1;
                HandleBatchFailure(CurrentBatch, BatchProcessor);
            end;
        end;
        
        // Report final results
        ReportBatchProcessingResults(ProcessedBatches, FailedBatches);
        
        OverallSuccess := (FailedBatches = 0);
        if not OverallSuccess then
            Error('Batch processing completed with %1 failed batches', FailedBatches);
    end;
    
    local procedure ProcessSingleBatch(BatchNumber: Integer; var BatchProcessor: Record "Batch Processing Control" temporary): Boolean
    var
        SourceRecord: Record "Large Source Table";
        TargetRecord: Record "Large Target Table";
        DataTransfer: DataTransfer;
        RetryAttempt: Integer;
        BatchSuccess: Boolean;
        BatchStartTime: DateTime;
    begin
        BatchStartTime := CurrentDateTime();
        BatchSuccess := false;
        
        // Retry logic for failed batches
        for RetryAttempt := 1 to MaxRetries do begin
            try
                // Set up batch-specific filters
                SetupBatchFilters(SourceRecord, BatchNumber);
                
                // Initialize DataTransfer for this batch
                DataTransfer.SetTables(Database::"Large Source Table", Database::"Large Target Table");
                DataTransfer.CopyTable(SourceRecord.GetView());
                
                // Set up field mappings
                SetupBatchFieldMappings(DataTransfer, SourceRecord, TargetRecord, BatchNumber);
                
                // Execute batch transfer
                if DataTransfer.CopyRows() then begin
                    BatchSuccess := true;
                    LogBatchSuccess(BatchNumber, RetryAttempt, BatchStartTime);
                    break;
                end else
                    LogBatchRetry(BatchNumber, RetryAttempt, GetLastErrorText());
                    
            except
                LogBatchException(BatchNumber, RetryAttempt, GetLastErrorText());
                if RetryAttempt < MaxRetries then
                    Sleep(CalculateRetryDelay(RetryAttempt));
            end;
        end;
        
        if not BatchSuccess then
            LogBatchFinalFailure(BatchNumber, MaxRetries);
            
        exit(BatchSuccess);
    end;
    
    local procedure SetupBatchFilters(var SourceRecord: Record "Large Source Table"; BatchNumber: Integer)
    var
        StartRange: Integer;
        EndRange: Integer;
    begin
        // Calculate range for this batch
        StartRange := (BatchNumber - 1) * BatchSize + 1;
        EndRange := BatchNumber * BatchSize;
        
        // Apply range filters - assuming integer key field
        SourceRecord.SetRange("Entry No.", StartRange, EndRange);
        
        // Additional business logic filters
        SourceRecord.SetRange("Transfer Required", true);
        SourceRecord.SetRange("Transfer Status", ''); // Not yet processed
    end;
    
    local procedure HandleBatchFailure(FailedBatch: Integer; var BatchProcessor: Record "Batch Processing Control" temporary)
    var
        RecoveryAction: Text;
        RecoverySuccess: Boolean;
    begin
        // Determine recovery action
        RecoveryAction := DetermineRecoveryAction(FailedBatch);
        
        case RecoveryAction of
            'SKIP':
                LogBatchSkipped(FailedBatch);
            'REDUCE_SIZE':
                RecoverySuccess := RetryWithReducedBatchSize(FailedBatch);
            'MANUAL_REVIEW':
                QueueManualReview(FailedBatch);
            'ABORT':
                Error('Critical batch failure - aborting operation');
        end;
        
        // Update batch processor status
        UpdateBatchProcessorStatus(BatchProcessor, FailedBatch, RecoveryAction, RecoverySuccess);
    end;
    
    local procedure RetryWithReducedBatchSize(FailedBatch: Integer): Boolean
    var
        ReducedBatchSize: Integer;
        SubBatchCount: Integer;
        SubBatch: Integer;
        SubBatchSuccess: Boolean;
        OverallSuccess: Boolean;
    begin
        // Reduce batch size by 50%
        ReducedBatchSize := BatchSize div 2;
        SubBatchCount := 2; // Split into 2 sub-batches
        
        OverallSuccess := true;
        for SubBatch := 1 to SubBatchCount do begin
            SubBatchSuccess := ProcessReducedBatch(FailedBatch, SubBatch, ReducedBatchSize);
            if not SubBatchSuccess then
                OverallSuccess := false;
        end;
        
        LogReducedBatchResults(FailedBatch, SubBatchCount, OverallSuccess);
        exit(OverallSuccess);
    end;
    
    local procedure CalculateRetryDelay(RetryAttempt: Integer): Integer
    begin
        // Exponential backoff: 2^attempt seconds * 1000ms
        exit(Power(2, RetryAttempt) * 1000);
    end;
    
    local procedure InitializeBatchProcessing()
    begin
        BatchSize := 1000; // Default batch size
        MaxRetries := 3;   // Default retry attempts
        CurrentBatch := 0;
        TotalBatches := 0;
        
        // Adjust batch size based on system capacity
        BatchSize := GetOptimalBatchSize();
    end;
    
    local procedure GetOptimalBatchSize(): Integer
    var
        SystemMetrics: Record "System Performance" temporary;
    begin
        // Get current system performance metrics
        CollectSystemMetrics(SystemMetrics);
        
        // Calculate optimal batch size based on available resources
        if SystemMetrics."Memory Available GB" > 8 then
            exit(2000)  // Large batch for high-memory systems
        else if SystemMetrics."Memory Available GB" > 4 then
            exit(1000)  // Medium batch for standard systems
        else
            exit(500);  // Small batch for constrained systems
    end;
}
```

## Advanced Enterprise Samples

### Multi-Threaded Transfer Coordination

```al
// Enterprise parallel transfer processing
codeunit 50300 "Parallel Transfer Manager"
{
    var
        TransferThreads: List of [Guid];
        ThreadResults: Dictionary of [Guid, Boolean];
        ThreadCoordinator: Codeunit "Thread Coordination Service";
        
    procedure ExecuteParallelTransfer()
    var
        TransferPartitions: List of [Text];
        PartitionGuid: Guid;
        CurrentPartition: Text;
        ThreadSuccess: Boolean;
        CompletedThreads: Integer;
        FailedThreads: Integer;
    begin
        // Create transfer partitions
        CreateTransferPartitions(TransferPartitions);
        
        // Start parallel transfer threads
        foreach CurrentPartition in TransferPartitions do begin
            PartitionGuid := StartTransferThread(CurrentPartition);
            TransferThreads.Add(PartitionGuid);
        end;
        
        // Monitor thread completion
        MonitorTransferThreads(CompletedThreads, FailedThreads);
        
        // Process results
        ProcessParallelTransferResults(CompletedThreads, FailedThreads);
    end;
    
    local procedure StartTransferThread(Partition: Text): Guid
    var
        ThreadGuid: Guid;
        TransferThread: Codeunit "Transfer Thread Worker";
        ThreadConfig: Record "Thread Configuration" temporary;
    begin
        ThreadGuid := CreateGuid();
        
        // Configure thread parameters
        ThreadConfig."Thread ID" := ThreadGuid;
        ThreadConfig."Partition Definition" := Partition;
        ThreadConfig."Max Processing Time" := 3600000; // 1 hour max
        ThreadConfig."Progress Reporting Interval" := 30000; // 30 seconds
        
        // Start thread asynchronously
        TransferThread.StartTransferThread(ThreadConfig);
        
        exit(ThreadGuid);
    end;
    
    local procedure MonitorTransferThreads(var CompletedThreads: Integer; var FailedThreads: Integer)
    var
        CurrentThread: Guid;
        ThreadStatus: Text;
        MonitoringActive: Boolean;
        MonitorStartTime: DateTime;
        MaxMonitoringTime: Integer;
    begin
        MonitoringActive := true;
        MonitorStartTime := CurrentDateTime();
        MaxMonitoringTime := 7200000; // 2 hours max
        CompletedThreads := 0;
        FailedThreads := 0;
        
        while MonitoringActive do begin
            // Check each thread status
            foreach CurrentThread in TransferThreads do begin
                ThreadStatus := ThreadCoordinator.GetThreadStatus(CurrentThread);
                
                case ThreadStatus of
                    'COMPLETED':
                        if not ThreadResults.ContainsKey(CurrentThread) then begin
                            ThreadResults.Add(CurrentThread, true);
                            CompletedThreads += 1;
                        end;
                    'FAILED':
                        if not ThreadResults.ContainsKey(CurrentThread) then begin
                            ThreadResults.Add(CurrentThread, false);
                            FailedThreads += 1;
                        end;
                    'TIMEOUT':
                        HandleThreadTimeout(CurrentThread);
                end;
            end;
            
            // Check if all threads completed
            if (CompletedThreads + FailedThreads) >= TransferThreads.Count() then
                MonitoringActive := false;
                
            // Check for overall timeout
            if (CurrentDateTime() - MonitorStartTime) > MaxMonitoringTime then begin
                HandleMonitoringTimeout();
                MonitoringActive := false;
            end;
            
            // Wait before next check
            if MonitoringActive then
                Sleep(5000); // 5 second intervals
        end;
    end;
}
```

### Real-Time Performance Optimization

```al
// Dynamic performance optimization during transfer
codeunit 50350 "Dynamic Transfer Optimizer"
{
    var
        PerformanceMetrics: Record "Real Time Metrics" temporary;
        OptimizationHistory: Record "Optimization History" temporary;
        
    procedure OptimizeTransferPerformance(var TransferContext: Record "Transfer Context")
    var
        CurrentMetrics: Record "Performance Snapshot" temporary;
        OptimizationRecommendations: List of [Text];
        Recommendation: Text;
        OptimizationApplied: Boolean;
    begin
        // Collect current performance metrics
        CollectRealTimeMetrics(CurrentMetrics, TransferContext);
        
        // Analyze performance patterns
        AnalyzePerformancePatterns(CurrentMetrics, OptimizationRecommendations);
        
        // Apply optimizations
        foreach Recommendation in OptimizationRecommendations do begin
            OptimizationApplied := ApplyPerformanceOptimization(Recommendation, TransferContext);
            RecordOptimizationOutcome(Recommendation, OptimizationApplied, CurrentMetrics);
        end;
        
        // Update transfer context with optimized settings
        UpdateTransferContextWithOptimizations(TransferContext, OptimizationRecommendations);
    end;
    
    local procedure AnalyzePerformancePatterns(var CurrentMetrics: Record "Performance Snapshot" temporary; var Recommendations: List of [Text])
    var
        PatternAnalyzer: Codeunit "Performance Pattern Analyzer";
        TrendAnalysis: Record "Performance Trends" temporary;
        BottleneckAnalysis: Record "Bottleneck Analysis" temporary;
    begin
        // Identify performance trends
        PatternAnalyzer.AnalyzeTrends(PerformanceMetrics, TrendAnalysis);
        
        // Identify system bottlenecks
        PatternAnalyzer.IdentifyBottlenecks(CurrentMetrics, BottleneckAnalysis);
        
        // Generate recommendations based on analysis
        GeneratePerformanceRecommendations(TrendAnalysis, BottleneckAnalysis, Recommendations);
    end;
    
    local procedure ApplyPerformanceOptimization(Recommendation: Text; var TransferContext: Record "Transfer Context"): Boolean
    var
        OptimizationResult: Boolean;
    begin
        OptimizationResult := true;
        
        case UpperCase(Recommendation) of
            'REDUCE_BATCH_SIZE':
                OptimizationResult := ReduceTransferBatchSize(TransferContext);
            'INCREASE_PARALLEL_THREADS':
                OptimizationResult := IncreaseParallelThreads(TransferContext);
            'ENABLE_COMPRESSION':
                OptimizationResult := EnableDataCompression(TransferContext);
            'OPTIMIZE_MEMORY_USAGE':
                OptimizationResult := OptimizeMemoryUsage(TransferContext);
            'ADJUST_RETRY_STRATEGY':
                OptimizationResult := AdjustRetryStrategy(TransferContext);
            else
                OptimizationResult := false;
        end;
        
        exit(OptimizationResult);
    end;
    
    local procedure GeneratePerformanceRecommendations(var TrendAnalysis: Record "Performance Trends" temporary; var BottleneckAnalysis: Record "Bottleneck Analysis" temporary; var Recommendations: List of [Text])
    begin
        // Memory pressure recommendations
        if BottleneckAnalysis."Memory Usage %" > 80 then begin
            Recommendations.Add('REDUCE_BATCH_SIZE');
            Recommendations.Add('OPTIMIZE_MEMORY_USAGE');
        end;
        
        // CPU utilization recommendations
        if BottleneckAnalysis."CPU Usage %" < 50 then
            Recommendations.Add('INCREASE_PARALLEL_THREADS');
            
        // I/O throughput recommendations
        if BottleneckAnalysis."Disk I/O Rate" > 85 then begin
            Recommendations.Add('ENABLE_COMPRESSION');
            Recommendations.Add('REDUCE_BATCH_SIZE');
        end;
        
        // Network latency recommendations
        if BottleneckAnalysis."Network Latency MS" > 100 then begin
            Recommendations.Add('ADJUST_RETRY_STRATEGY');
            Recommendations.Add('ENABLE_COMPRESSION');
        end;
        
        // Error rate recommendations
        if TrendAnalysis."Error Rate %" > 2 then begin
            Recommendations.Add('ADJUST_RETRY_STRATEGY');
            Recommendations.Add('REDUCE_BATCH_SIZE');
        end;
    end;
}
```

These samples provide practical implementations of DataTransfer patterns from basic field mappings to enterprise-scale parallel processing with real-time optimization.
