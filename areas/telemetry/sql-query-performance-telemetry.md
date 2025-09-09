---
title: "SQL Query Performance Telemetry"
description: "Advanced SQL query performance telemetry for Business Central with intelligent query analysis and optimization recommendations"
area: "telemetry"
difficulty: "advanced"
object_types: ["Codeunit", "Interface", "Query"]
variable_types: ["JsonObject", "Dictionary", "Duration", "RecordRef", "Text"]
tags: ["sql-telemetry", "query-performance", "database-optimization", "monitoring", "analytics"]
---

# SQL Query Performance Telemetry

## Overview

SQL query performance telemetry in Business Central enables comprehensive monitoring of database operations, query execution patterns, and optimization opportunities. This atomic covers intelligent query analysis with AI-powered optimization recommendations, real-time performance tracking, and predictive analytics.

## Intelligent SQL Telemetry Framework

### Smart SQL Monitor
```al
codeunit 50250 "Smart SQL Monitor"
{
    var
        TelemetryCD: Codeunit Telemetry;
        QueryTracker: Dictionary of [Guid, JsonObject];
        PerformanceAnalyzer: Codeunit "SQL Performance Analyzer";

    procedure StartQueryTracking(QueryContext: JsonObject): Guid
    var
        TrackingId: Guid;
        QueryMetadata: JsonObject;
        BaselineMetrics: JsonObject;
    begin
        TrackingId := CreateGuid();
        
        // Build comprehensive query metadata
        QueryMetadata := BuildQueryMetadata(QueryContext);
        
        // Capture baseline database metrics
        BaselineMetrics := CaptureBaselineMetrics();
        QueryMetadata.Add('baselineMetrics', BaselineMetrics);
        QueryMetadata.Add('startTime', CurrentDateTime());
        QueryMetadata.Add('trackingId', TrackingId);
        
        // Store tracking context
        QueryTracker.Add(TrackingId, QueryMetadata);
        
        // Log query initiation
        LogQueryStart(QueryMetadata);
        
        exit(TrackingId);
    end;

    procedure CompleteQueryTracking(TrackingId: Guid; QueryResult: JsonObject): Boolean
    var
        QueryMetadata: JsonObject;
        PerformanceMetrics: JsonObject;
        AnalysisResult: JsonObject;
    begin
        if not QueryTracker.Get(TrackingId, QueryMetadata) then
            exit(false);
        
        // Calculate query performance metrics
        PerformanceMetrics := CalculateQueryPerformance(QueryMetadata, QueryResult);
        
        // Analyze query patterns and optimization opportunities
        AnalysisResult := PerformanceAnalyzer.AnalyzeQueryExecution(PerformanceMetrics);
        
        // Log comprehensive query telemetry
        LogQueryCompletion(TrackingId, PerformanceMetrics, AnalysisResult);
        
        // Check for performance alerts
        CheckPerformanceAlerts(PerformanceMetrics);
        
        // Clean up tracking
        QueryTracker.Remove(TrackingId);
        
        exit(true);
    end;

    local procedure BuildQueryMetadata(QueryContext: JsonObject): JsonObject
    var
        Metadata: JsonObject;
        TableAnalyzer: Codeunit "Table Usage Analyzer";
        UserContext: JsonObject;
    begin
        // Extract query context information
        Metadata.Add('queryType', GetQueryType(QueryContext));
        Metadata.Add('tableList', GetInvolvedTables(QueryContext));
        Metadata.Add('filterConditions', GetFilterConditions(QueryContext));
        Metadata.Add('sortingOptions', GetSortingOptions(QueryContext));
        
        // Add user and session context
        UserContext := BuildUserContext();
        Metadata.Add('userContext', UserContext);
        
        // Analyze table usage patterns
        Metadata.Add('tableAnalysis', TableAnalyzer.AnalyzeTableUsage(QueryContext));
        
        exit(Metadata);
    end;
}
```

### SQL Performance Analyzer
```al
codeunit 50251 "SQL Performance Analyzer"
{
    procedure AnalyzeQueryExecution(PerformanceMetrics: JsonObject): JsonObject
    var
        AnalysisResult: JsonObject;
        OptimizationEngine: Codeunit "Query Optimization Engine";
        PatternDetector: Codeunit "SQL Pattern Detector";
    begin
        // Analyze execution patterns
        AnalysisResult.Add('executionPattern', PatternDetector.DetectExecutionPatterns(PerformanceMetrics));
        
        // Identify performance bottlenecks
        AnalysisResult.Add('bottlenecks', IdentifyBottlenecks(PerformanceMetrics));
        
        // Generate optimization recommendations
        AnalysisResult.Add('optimizations', OptimizationEngine.GenerateOptimizations(PerformanceMetrics));
        
        // Analyze resource utilization
        AnalysisResult.Add('resourceAnalysis', AnalyzeResourceUtilization(PerformanceMetrics));
        
        // Compare with historical performance
        AnalysisResult.Add('performanceComparison', CompareWithBaseline(PerformanceMetrics));
        
        exit(AnalysisResult);
    end;

    local procedure IdentifyBottlenecks(PerformanceMetrics: JsonObject): JsonArray
    var
        Bottlenecks: JsonArray;
        ExecutionTime: Duration;
        LockWaitTime: Duration;
        IOWaitTime: Duration;
        BottleneckThreshold: Duration;
    begin
        BottleneckThreshold := 5000; // 5 seconds
        
        // Analyze execution time bottlenecks
        PerformanceMetrics.Get('executionTime', ExecutionTime);
        if ExecutionTime > BottleneckThreshold then
            AddBottleneck(Bottlenecks, 'ExecutionTime', ExecutionTime, 'Query execution time exceeds threshold');
        
        // Analyze lock wait bottlenecks
        if PerformanceMetrics.Get('lockWaitTime', LockWaitTime) then
            if LockWaitTime > (ExecutionTime * 0.3) then
                AddBottleneck(Bottlenecks, 'LockWait', LockWaitTime, 'Excessive lock wait time detected');
        
        // Analyze I/O wait bottlenecks
        if PerformanceMetrics.Get('ioWaitTime', IOWaitTime) then
            if IOWaitTime > (ExecutionTime * 0.5) then
                AddBottleneck(Bottlenecks, 'IOWait', IOWaitTime, 'Excessive I/O wait time detected');
        
        exit(Bottlenecks);
    end;

    local procedure AddBottleneck(var Bottlenecks: JsonArray; BottleneckType: Text; Value: Duration; Description: Text)
    var
        Bottleneck: JsonObject;
    begin
        Bottleneck.Add('type', BottleneckType);
        Bottleneck.Add('value', Format(Value));
        Bottleneck.Add('description', Description);
        Bottleneck.Add('severity', CalculateBottleneckSeverity(Value));
        Bottlenecks.Add(Bottleneck);
    end;
}
```

## Real-Time Query Monitoring

### Query Execution Tracker
```al
codeunit 50252 "Query Execution Tracker"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterFindSetEvent', '', false, false)]
    local procedure OnCustomerFindSet(var Rec: Record Customer; var Result: Boolean)
    var
        QueryContext: JsonObject;
        TrackingId: Guid;
    begin
        QueryContext := BuildTableQueryContext(Database::Customer, 'FindSet');
        TrackingId := StartQueryTracking(QueryContext);
        
        // Store tracking ID for completion
        SetQueryTrackingContext(TrackingId, QueryContext);
    end;

    procedure TrackRecordOperations(RecordRef: RecordRef; OperationType: Text): Guid
    var
        QueryContext: JsonObject;
        SQLMonitor: Codeunit "Smart SQL Monitor";
        TrackingId: Guid;
    begin
        // Build operation context
        QueryContext := BuildRecordOperationContext(RecordRef, OperationType);
        
        // Start tracking with SQL monitor
        TrackingId := SQLMonitor.StartQueryTracking(QueryContext);
        
        exit(TrackingId);
    end;

    local procedure BuildRecordOperationContext(RecordRef: RecordRef; OperationType: Text): JsonObject
    var
        Context: JsonObject;
        TableInfo: JsonObject;
        FilterInfo: JsonArray;
    begin
        // Table information
        TableInfo.Add('tableId', RecordRef.Number());
        TableInfo.Add('tableName', RecordRef.Name());
        TableInfo.Add('recordCount', RecordRef.Count());
        Context.Add('tableInfo', TableInfo);
        
        // Operation details
        Context.Add('operationType', OperationType);
        Context.Add('timestamp', CurrentDateTime());
        Context.Add('userId', UserId());
        
        // Filter information
        FilterInfo := ExtractRecordFilters(RecordRef);
        Context.Add('filters', FilterInfo);
        
        exit(Context);
    end;

    local procedure ExtractRecordFilters(RecordRef: RecordRef): JsonArray
    var
        FilterArray: JsonArray;
        FieldRef: FieldRef;
        FilterInfo: JsonObject;
        i: Integer;
    begin
        for i := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(i);
            
            if FieldRef.GetFilter() <> '' then begin
                FilterInfo.Add('fieldNo', FieldRef.Number());
                FilterInfo.Add('fieldName', FieldRef.Name());
                FilterInfo.Add('filterValue', FieldRef.GetFilter());
                FilterInfo.Add('dataType', Format(FieldRef.Type()));
                FilterArray.Add(FilterInfo);
                Clear(FilterInfo);
            end;
        end;
        
        exit(FilterArray);
    end;
}
```

### Database Resource Monitor
```al
codeunit 50253 "Database Resource Monitor"
{
    procedure CaptureResourceMetrics(): JsonObject
    var
        ResourceMetrics: JsonObject;
        ConnectionMetrics: JsonObject;
        PerformanceCounters: JsonObject;
    begin
        // Capture connection pool metrics
        ConnectionMetrics := CaptureConnectionMetrics();
        ResourceMetrics.Add('connections', ConnectionMetrics);
        
        // Capture performance counters
        PerformanceCounters := CapturePerformanceCounters();
        ResourceMetrics.Add('performance', PerformanceCounters);
        
        // Capture lock information
        ResourceMetrics.Add('locks', CaptureLockMetrics());
        
        // Capture buffer pool statistics
        ResourceMetrics.Add('bufferPool', CaptureBufferPoolMetrics());
        
        exit(ResourceMetrics);
    end;

    local procedure CaptureConnectionMetrics(): JsonObject
    var
        ConnectionMetrics: JsonObject;
        SessionInfo: Record "Active Session";
        ActiveConnections: Integer;
        BlockedConnections: Integer;
    begin
        // Count active sessions/connections
        ActiveConnections := SessionInfo.Count();
        
        // Analyze connection status
        ConnectionMetrics.Add('activeConnections', ActiveConnections);
        ConnectionMetrics.Add('maxConnections', GetMaxConnections());
        ConnectionMetrics.Add('connectionUtilization', (ActiveConnections / GetMaxConnections()) * 100);
        ConnectionMetrics.Add('timestamp', CurrentDateTime());
        
        exit(ConnectionMetrics);
    end;

    local procedure CapturePerformanceCounters(): JsonObject
    var
        PerformanceCounters: JsonObject;
        DatabaseMonitor: Codeunit "Database Performance Monitor";
    begin
        // Capture key database performance metrics
        PerformanceCounters.Add('transactionsPerSecond', DatabaseMonitor.GetTransactionsPerSecond());
        PerformanceCounters.Add('pagesPerSecond', DatabaseMonitor.getPagesPerSecond());
        PerformanceCounters.Add('lockWaitsPerSecond', DatabaseMonitor.GetLockWaitsPerSecond());
        PerformanceCounters.Add('deadlocksPerSecond', DatabaseMonitor.GetDeadlocksPerSecond());
        PerformanceCounters.Add('bufferCacheHitRatio', DatabaseMonitor.GetBufferCacheHitRatio());
        
        exit(PerformanceCounters);
    end;
}
```

## Query Optimization Intelligence

### Query Optimization Engine
```al
codeunit 50254 "Query Optimization Engine"
{
    procedure GenerateOptimizations(PerformanceMetrics: JsonObject): JsonArray
    var
        Optimizations: JsonArray;
        IndexAnalyzer: Codeunit "Index Analyzer";
        FilterAnalyzer: Codeunit "Filter Optimizer";
    begin
        // Generate index optimization recommendations
        AddIndexOptimizations(Optimizations, IndexAnalyzer.AnalyzeIndexUsage(PerformanceMetrics));
        
        // Generate filter optimization recommendations
        AddFilterOptimizations(Optimizations, FilterAnalyzer.AnalyzeFilterEfficiency(PerformanceMetrics));
        
        // Generate join optimization recommendations
        AddJoinOptimizations(Optimizations, AnalyzeJoinPatterns(PerformanceMetrics));
        
        // Generate caching recommendations
        AddCachingOptimizations(Optimizations, AnalyzeCachingOpportunities(PerformanceMetrics));
        
        exit(Optimizations);
    end;

    local procedure AddIndexOptimizations(var Optimizations: JsonArray; IndexAnalysis: JsonObject)
    var
        Optimization: JsonObject;
        MissingIndexes: JsonArray;
        IndexToken: JsonToken;
        i: Integer;
    begin
        if IndexAnalysis.Get('missingIndexes', MissingIndexes) then begin
            for i := 0 to MissingIndexes.Count() - 1 do begin
                MissingIndexes.Get(i, IndexToken);
                
                Optimization.Add('type', 'Index');
                Optimization.Add('priority', 'High');
                Optimization.Add('recommendation', 'Create missing index');
                Optimization.Add('details', IndexToken.AsObject());
                Optimization.Add('estimatedImprovement', '50-80%');
                
                Optimizations.Add(Optimization);
                Clear(Optimization);
            end;
        end;
    end;

    local procedure AnalyzeCachingOpportunities(PerformanceMetrics: JsonObject): JsonObject
    var
        CachingAnalysis: JsonObject;
        FrequentQueries: JsonArray;
        QueryPattern: Text;
        ExecutionFrequency: Integer;
    begin
        // Identify frequently executed queries
        if PerformanceMetrics.Get('queryPattern', QueryPattern) then begin
            ExecutionFrequency := GetQueryExecutionFrequency(QueryPattern);
            
            if ExecutionFrequency > 100 then begin // More than 100 executions
                CachingAnalysis.Add('recommendCaching', true);
                CachingAnalysis.Add('cacheType', 'ResultSet');
                CachingAnalysis.Add('estimatedImprovement', '30-60%');
            end;
        end;
        
        exit(CachingAnalysis);
    end;
}
```

### SQL Pattern Detector
```al
codeunit 50255 "SQL Pattern Detector"
{
    procedure DetectExecutionPatterns(PerformanceMetrics: JsonObject): JsonObject
    var
        PatternAnalysis: JsonObject;
        AntiPatterns: JsonArray;
        PerformancePatterns: JsonArray;
    begin
        // Detect anti-patterns
        AntiPatterns := DetectAntiPatterns(PerformanceMetrics);
        PatternAnalysis.Add('antiPatterns', AntiPatterns);
        
        // Detect performance patterns
        PerformancePatterns := DetectPerformancePatterns(PerformanceMetrics);
        PatternAnalysis.Add('performancePatterns', PerformancePatterns);
        
        // Analyze query complexity
        PatternAnalysis.Add('complexityAnalysis', AnalyzeQueryComplexity(PerformanceMetrics));
        
        exit(PatternAnalysis);
    end;

    local procedure DetectAntiPatterns(PerformanceMetrics: JsonObject): JsonArray
    var
        AntiPatterns: JsonArray;
        QueryPattern: JsonObject;
        FilterConditions: JsonArray;
        SortingOptions: JsonArray;
    begin
        PerformanceMetrics.Get('filterConditions', FilterConditions);
        PerformanceMetrics.Get('sortingOptions', SortingOptions);
        
        // Detect N+1 query pattern
        if DetectNPlusOnePattern(PerformanceMetrics) then
            AddAntiPattern(AntiPatterns, 'N+1 Query', 'Multiple queries in loop detected', 'High');
        
        // Detect missing WHERE clauses
        if FilterConditions.Count() = 0 then
            AddAntiPattern(AntiPatterns, 'Missing Filter', 'Query without WHERE clause detected', 'Medium');
        
        // Detect inefficient sorting
        if HasIneefficientSorting(SortingOptions) then
            AddAntiPattern(AntiPatterns, 'Inefficient Sort', 'Sorting on non-indexed columns detected', 'Medium');
        
        // Detect large result sets
        if HasLargeResultSet(PerformanceMetrics) then
            AddAntiPattern(AntiPatterns, 'Large Result Set', 'Query returns excessive number of rows', 'Low');
        
        exit(AntiPatterns);
    end;

    local procedure AddAntiPattern(var AntiPatterns: JsonArray; PatternName: Text; Description: Text; Severity: Text)
    var
        AntiPattern: JsonObject;
    begin
        AntiPattern.Add('pattern', PatternName);
        AntiPattern.Add('description', Description);
        AntiPattern.Add('severity', Severity);
        AntiPattern.Add('detectedAt', CurrentDateTime());
        AntiPatterns.Add(AntiPattern);
    end;
}
```

## Implementation Checklist

### SQL Telemetry Infrastructure
- [ ] Deploy Smart SQL Monitor and supporting codeunits
- [ ] Configure query tracking and metadata collection
- [ ] Set up performance metrics calculation and analysis
- [ ] Initialize database resource monitoring
- [ ] Configure intelligent pattern detection

### Performance Analysis
- [ ] Implement SQL performance analyzer with bottleneck detection
- [ ] Configure query optimization engine and recommendations
- [ ] Set up anti-pattern detection and alerting
- [ ] Enable historical performance comparison
- [ ] Configure predictive performance analytics

### Real-Time Monitoring
- [ ] Set up query execution tracking for critical operations
- [ ] Configure database resource monitoring and alerting
- [ ] Enable real-time performance dashboard
- [ ] Set up automated performance threshold monitoring
- [ ] Configure performance degradation alerting

### Optimization Integration
- [ ] Enable automated optimization recommendations
- [ ] Configure index usage analysis and suggestions
- [ ] Set up query rewrite recommendations
- [ ] Enable caching opportunity identification
- [ ] Configure performance tuning workflows

## Best Practices

### Telemetry Collection Strategy
- Focus on business-critical queries and high-impact operations
- Use intelligent sampling to balance accuracy with performance overhead
- Implement comprehensive metadata collection for thorough analysis
- Enable real-time monitoring with intelligent alerting thresholds
- Provide actionable optimization recommendations

### Performance Optimization
- Use efficient telemetry collection methods that minimize database impact
- Implement intelligent query analysis with pattern recognition
- Enable predictive analytics for proactive performance management
- Use background processing for intensive performance analysis
- Maintain historical performance data for trend analysis

## Anti-Patterns to Avoid

- Collecting excessive telemetry data that impacts database performance
- Implementing query monitoring without optimization recommendations
- Creating telemetry systems that generate more problems than they solve
- Ignoring database-specific optimization opportunities
- Failing to provide clear performance improvement guidance

## Related Topics
- [Performance Counter Telemetry](performance-counter-telemetry.md)
- [Custom Telemetry Dimensions](custom-telemetry-dimensions.md)
- [Database Performance Optimization](../performance-optimization/database-performance-optimization.md)