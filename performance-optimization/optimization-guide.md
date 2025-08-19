# Performance Optimization Guide for AL Development - AI-Enhanced Performance Coaching

<!-- AI_TRIGGER: When developer writes queries or loops, proactively suggest performance optimization patterns -->
<!-- COPILOT_GUIDANCE: This guide teaches intelligent performance optimization with proactive suggestions and measurement strategies -->

This comprehensive guide outlines best practices and advanced techniques for optimizing AL code performance in Microsoft Business Central applications, enhanced with AI training patterns for proactive performance guidance.

## How to Use This Guide with Copilot

**See**: [`../shared-templates.md`](../shared-templates.md) Template A for complete AI instruction patterns.

**Context**: Performance optimization (CONTEXT="performance optimization", BASIC_REQUEST="Make this code faster", ENHANCED_REQUEST="Optimize performance with measurement and validation using established patterns")

## Query Optimization and Database Performance

### SetLoadFields Usage - AL-Specific Performance Pattern

<!-- AI_TRIGGER: When developer writes record loops, suggest SetLoadFields for performance optimization -->
<!-- PROACTIVE_SUGGEST: During record processing -> Suggest performance measurement and monitoring -->

```al
// Example 1: Basic SetLoadFields usage for customer processing
procedure ProcessCustomersEfficiently()
var
    Customer: Record Customer;
    ProcessedCount: Integer;
begin
    <!-- COPILOT_GUIDANCE: When showing this pattern, remind developers to:
    1. Add performance telemetry to track optimization effectiveness
    2. Update Azure DevOps work item with performance requirements
    3. Create performance tests to validate improvements
    4. Document optimization rationale for code reviews
    -->
    
    // Load only the fields needed for processing
    Customer.SetLoadFields("No.", "Name", "Credit Limit (LCY)", "Balance (LCY)");
    Customer.SetRange(Blocked, Customer.Blocked::" ");
    
    if Customer.FindSet() then
        repeat
            // Process only loaded fields for optimal performance
            if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then
                ProcessOverLimitCustomer(Customer."No.", Customer.Name);
            ProcessedCount += 1;
        until Customer.Next() = 0;
    
    Message('Processed %1 customers efficiently', ProcessedCount);
end;

// Example 2: Advanced SetLoadFields with calculated fields
procedure GetCustomerStatistics(var TempCustomerStats: Record "Customer Statistics" temporary)
var
    Customer: Record Customer;
    CustomerLedgerEntry: Record "Cust. Ledger Entry";
begin
    // Efficient customer data loading
    Customer.SetLoadFields("No.", "Name", "Customer Posting Group");
    if Customer.FindSet() then
        repeat
            TempCustomerStats.Init();
            TempCustomerStats."Customer No." := Customer."No.";
            TempCustomerStats."Customer Name" := Customer.Name;
            
            // Efficient ledger entry processing with SetLoadFields
            CustomerLedgerEntry.SetLoadFields("Remaining Amount", "Amount");
            CustomerLedgerEntry.SetRange("Customer No.", Customer."No.");
            CustomerLedgerEntry.SetRange(Open, true);
            CustomerLedgerEntry.CalcSums("Remaining Amount");
            TempCustomerStats."Outstanding Amount" := CustomerLedgerEntry."Remaining Amount";
            
            TempCustomerStats.Insert();
        until Customer.Next() = 0;
end;

// Example 3: SetLoadFields in complex scenarios with related tables
procedure AnalyzeCustomerPurchasePatterns()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    CustomerAnalysis: Record "Customer Analysis" temporary;
    TotalAmount: Decimal;
begin
    // Load only essential customer fields
    Customer.SetLoadFields("No.", "Name", "ABC Customer Category");
    Customer.SetRange("ABC Customer Category", Customer."ABC Customer Category"::Premium);
    
    if Customer.FindSet() then
        repeat
            Clear(CustomerAnalysis);
            CustomerAnalysis."Customer No." := Customer."No.";
            CustomerAnalysis."Customer Name" := Customer.Name;
            
            // Efficient sales analysis with minimal field loading
            SalesHeader.SetLoadFields("No.", "Sell-to Customer No.", "Document Date");
            SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
            SalesHeader.SetRange("Document Date", CalcDate('<-1Y>', Today), Today);
            
            if SalesHeader.FindSet() then
                repeat
                    SalesLine.SetLoadFields("Document No.", "Line Amount");
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.CalcSums("Line Amount");
                    TotalAmount += SalesLine."Line Amount";
                until SalesHeader.Next() = 0;
            
            CustomerAnalysis."Total Purchase Amount" := TotalAmount;
            CustomerAnalysis.Insert();
            TotalAmount := 0;
        until Customer.Next() = 0;
end;
```

### Filtering Best Practices

- Use appropriate filters before reading records
- Use SetRange/SetFilter with indexed fields when possible
- Apply filters in the order of selectivity (most selective first)
- Avoid using FIND('-') without filters

```al
// Good: Efficient filtering with indexed fields
Customer.SetRange("Customer Posting Group", PostingGroup);
Customer.SetRange("Blocked", Customer.Blocked::" ");
Customer.SetLoadFields("No.", "Name");

// Avoid: Unfiltered searches
Customer.FindSet(); // This loads all customers without filters
```

### Database Operations Optimization

### Database Operations Optimization

#### Complete Before/After Examples for Database Performance

```al
// BEFORE: Inefficient approach with nested database calls
procedure CalculateCustomerTotalsInefficient()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    TotalAmount: Decimal;
begin
    if Customer.FindSet() then // Loads all fields for all customers
        repeat
            // Database call inside loop - AVOID
            SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
            if SalesHeader.FindSet() then
                repeat
                    // Another nested database call - VERY INEFFICIENT
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.CalcSums("Line Amount");
                    TotalAmount += SalesLine."Line Amount";
                until SalesHeader.Next() = 0;
            // Process customer with total...
        until Customer.Next() = 0;
end;

// AFTER: Optimized approach with SetLoadFields and bulk operations
procedure CalculateCustomerTotalsOptimized()
var
    Customer: Record Customer;
    SalesLine: Record "Sales Line";
    TempCustomerTotals: Record "Customer Totals" temporary;
    CustomerNo: Code[20];
begin
    // Step 1: Load only required customer fields
    Customer.SetLoadFields("No.", "Name");
    Customer.SetRange(Blocked, Customer.Blocked::" ");
    
    // Step 2: Bulk load sales data with efficient field selection
    SalesLine.SetLoadFields("Sell-to Customer No.", "Line Amount");
    SalesLine.SetRange("Document Date", CalcDate('<-1Y>', Today), Today);
    
    // Step 3: Process in memory using temporary tables
    if SalesLine.FindSet() then
        repeat
            TempCustomerTotals.Reset();
            TempCustomerTotals.SetRange("Customer No.", SalesLine."Sell-to Customer No.");
            if TempCustomerTotals.FindFirst() then begin
                TempCustomerTotals."Total Amount" += SalesLine."Line Amount";
                TempCustomerTotals.Modify();
            end else begin
                TempCustomerTotals.Init();
                TempCustomerTotals."Customer No." := SalesLine."Sell-to Customer No.";
                TempCustomerTotals."Total Amount" := SalesLine."Line Amount";
                TempCustomerTotals.Insert();
            end;
        until SalesLine.Next() = 0;
    
    // Step 4: Final processing with minimal database operations
    if Customer.FindSet() then
        repeat
            TempCustomerTotals.SetRange("Customer No.", Customer."No.");
            if TempCustomerTotals.FindFirst() then
                ProcessCustomerTotal(Customer."No.", Customer.Name, TempCustomerTotals."Total Amount");
        until Customer.Next() = 0;
end;

// OPTIMIZED PATTERN: Bulk operations with efficient indexing
procedure BulkUpdateCustomerRatings()
var
    Customer: Record Customer;
    CustomerRating: Record "ABC Customer Rating";
    TempRatingAverage: Record "Rating Average" temporary;
    CustomerNo: Code[20];
    TotalScore: Decimal;
    RatingCount: Integer;
begin
    // Step 1: Calculate averages in one pass
    CustomerRating.SetLoadFields("Customer No.", "Rating Score");
    if CustomerRating.FindSet() then
        repeat
            TempRatingAverage.SetRange("Customer No.", CustomerRating."Customer No.");
            if TempRatingAverage.FindFirst() then begin
                TempRatingAverage."Total Score" += CustomerRating."Rating Score";
                TempRatingAverage."Rating Count" += 1;
                TempRatingAverage."Average Score" := TempRatingAverage."Total Score" / TempRatingAverage."Rating Count";
                TempRatingAverage.Modify();
            end else begin
                TempRatingAverage.Init();
                TempRatingAverage."Customer No." := CustomerRating."Customer No.");
                TempRatingAverage."Total Score" := CustomerRating."Rating Score";
                TempRatingAverage."Rating Count" := 1;
                TempRatingAverage."Average Score" := CustomerRating."Rating Score";
                TempRatingAverage.Insert();
            end;
        until CustomerRating.Next() = 0;
    
    // Step 2: Bulk update customers
    Customer.SetLoadFields("No.", "ABC Average Rating");
    if TempRatingAverage.FindSet() then
        repeat
            if Customer.Get(TempRatingAverage."Customer No.") then begin
                Customer."ABC Average Rating" := TempRatingAverage."Average Score";
                Customer.Modify();
            end;
        until TempRatingAverage.Next() = 0;
end;
```

#### Query Optimization Patterns

```al
// Example 1: Using Query object for complex data aggregation
query 50100 "Customer Rating Analysis"
{
    QueryType = Normal;
    
    elements
    {
        dataitem(Customer; Customer)
        {
            filter(CustomerNoFilter; "No.")
            { }
            filter(CategoryFilter; "ABC Customer Category")
            { }
            
            column(CustomerNo; "No.")
            { }
            column(CustomerName; Name)
            { }
            column(CustomerCategory; "ABC Customer Category")
            { }
            
            dataitem(CustomerRating; "ABC Customer Rating")
            {
                DataItemLink = "Customer No." = Customer."No.";
                SqlJoinType = LeftOuterJoin;
                
                column(AvgRatingScore; "Rating Score")
                {
                    Method = Average;
                }
                column(TotalRatings; "Rating Score")
                {
                    Method = Count;
                }
                column(MinRatingScore; "Rating Score")
                {
                    Method = Min;
                }
                column(MaxRatingScore; "Rating Score")
                {
                    Method = Max;
                }
            }
        }
    }
}

// Using the query for efficient data retrieval
procedure GetCustomerRatingAnalysis()
var
    CustomerRatingAnalysis: Query "Customer Rating Analysis";
    TempAnalysisResult: Record "Analysis Result" temporary;
begin
    CustomerRatingAnalysis.SetFilter(CategoryFilter, '%1|%2', 
        Customer."ABC Customer Category"::Premium, 
        Customer."ABC Customer Category"::Standard);
    
    CustomerRatingAnalysis.Open();
    while CustomerRatingAnalysis.Read() do begin
        TempAnalysisResult.Init();
        TempAnalysisResult."Customer No." := CustomerRatingAnalysis.CustomerNo;
        TempAnalysisResult."Customer Name" := CustomerRatingAnalysis.CustomerName;
        TempAnalysisResult."Average Rating" := CustomerRatingAnalysis.AvgRatingScore;
        TempAnalysisResult."Total Ratings" := CustomerRatingAnalysis.TotalRatings;
        TempAnalysisResult.Insert();
    end;
    CustomerRatingAnalysis.Close();
    
    // Process results efficiently in memory
    ProcessAnalysisResults(TempAnalysisResult);
end;

// Example 2: Efficient data loading with proper indexing
procedure OptimizedCustomerSearch(SearchText: Text; var TempCustomer: Record Customer temporary)
var
    Customer: Record Customer;
begin
    // Use proper filtering on indexed fields
    Customer.SetLoadFields("No.", "Name", "Phone No.", "E-Mail");
    
    // Apply filters in order of selectivity (most selective first)
    if StrLen(SearchText) > 0 then begin
        Customer.SetFilter("No.", '@*' + SearchText + '*');
        Customer.SetFilter(Name, '@*' + SearchText + '*');
    end;
    
    // Limit results for performance
    Customer.SetRange(Blocked, Customer.Blocked::" ");
    
    if Customer.FindSet() then begin
        if Customer.Count > 1000 then
            Message('Search returned more than 1000 results. Consider refining your search.');
        
        repeat
            TempCustomer.TransferFields(Customer);
            TempCustomer.Insert();
        until (Customer.Next() = 0) or (TempCustomer.Count >= 1000);
    end;
end;
```

### Use TempTables for Intermediate Data

- Declare record variables as temporary for in-memory operations
- Process data in memory before writing to database
- Use temporary tables for sorting and filtering operations

```al
// Efficient temporary table usage
procedure ProcessCustomerData()
var
    TempCustomer: Record Customer temporary;
begin
    LoadCustomersToTemp(TempCustomer);
    TempCustomer.ProcessInMemory();
    TempCustomer.WriteResultsToDatabase();
end;
```

### Transaction Handling for Optimal Performance

- Keep transactions as short as possible
- Avoid user interaction during transactions
- Use LockTable() only when necessary and as late as possible
- Consider using snapshot isolation for read operations

## DevOps Integration for Performance Optimization

<!-- AI_TRIGGER: When developer implements performance optimizations, suggest DevOps integration for monitoring and validation -->
<!-- PROACTIVE_SUGGEST: During performance work -> Suggest performance testing pipeline and monitoring setup -->

### Performance Monitoring in DevOps Workflows

**Planning Phase:**
- Define performance requirements and acceptance criteria in work items
- Plan performance testing scenarios and benchmarks
- Estimate performance optimization effort and validation time
- Document expected performance improvements

<!-- COPILOT_GUIDANCE: When developer works on performance optimization, suggest:
1. "Add performance benchmarks to your work item acceptance criteria"
2. "Have you planned performance testing for this optimization?"
3. "Consider adding telemetry to measure optimization effectiveness"
4. "Document baseline performance metrics before optimization"
-->

**Development Phase:**
- Implement performance telemetry and measurement
- Update work items with optimization approach and rationale
- Track performance improvements with metrics
- Maintain performance testing checklist

**Testing Phase:**
- Validate performance improvements with automated tests
- Compare before/after performance metrics
- Test performance under various load conditions
- Verify optimization doesn't introduce regressions

**Deployment Phase:**
- Monitor performance metrics after deployment
- Validate optimization effectiveness in production
- Set up performance alerts and monitoring dashboards
- Document performance optimization outcomes

### Performance Quality Gates

<!-- QUALITY_TRIGGERS:
BEFORE_PERFORMANCE_OPTIMIZATION: Suggest baseline measurement
DURING_PERFORMANCE_DEVELOPMENT: Suggest incremental measurement
AFTER_PERFORMANCE_OPTIMIZATION: Suggest validation testing
BEFORE_PERFORMANCE_DEPLOYMENT: Suggest load testing
-->

1. **Baseline Measurement**: Establish performance baselines before optimization
2. **Incremental Validation**: Validate performance improvements during development
3. **Load Testing**: Test performance under expected production load
4. **Regression Testing**: Ensure optimizations don't introduce functional regressions
5. **Production Monitoring**: Monitor performance metrics in production environment

## Memory Management and Object Lifecycle

### AL-Specific Memory Optimization

```al
// Efficient memory usage with proper variable scope
procedure ProcessLargeDataset()
var
    TempBuffer: Record "Integer" temporary;
begin
    // Use temporary records for large datasets
    LoadDataToTempBuffer(TempBuffer);
    ProcessTempBuffer(TempBuffer);
    // TempBuffer automatically cleaned up when procedure exits
end;
```

### Data Structure Optimization

- Use appropriate data types for fields and variables
- Minimize the use of Text variables with large lengths
- Consider using BLOB fields for large text content
- Implement proper cleanup for temporary objects

## UI Performance and Page Loading

### Minimize Code in OnAfterGetRecord Triggers

- Move complex calculations to separate procedures
- Use CurrPage.UPDATE(FALSE) to avoid unnecessary refreshes
- Consider using background tasks for heavy calculations

```al
// Optimized OnAfterGetRecord
trigger OnAfterGetRecord()
begin
    // Minimal processing in trigger
    CalculatedField := GetCachedCalculation(Rec."No.");
end;

// Heavy processing moved to separate procedure
procedure RefreshCalculations()
begin
    // Complex calculations performed on demand
    PerformComplexCalculations();
    CurrPage.Update();
end;
```

### Use FlowFields and FlowFilters Appropriately

- Avoid excessive CALCFIELDS calls, especially in loops
- Use SetAutoCalcFields only for fields that are always needed
- Consider using normal fields with manual updates for frequently accessed calculated values

### Optimize UI Performance

- Use DisableControls/EnableControls when updating multiple records
- Implement virtual scrolling for large datasets
- Minimize the number of visible fields on list pages
- Use page extensions instead of replacing entire pages

## Background Processing Patterns

### Efficient Page Loading Techniques

```al
// Optimize page loading with SetLoadFields
trigger OnOpenPage()
begin
    SetLoadFields("No.", "Name", "Status"); // Load only essential fields
    if FindSet() then; // Prepare recordset efficiently
end;
```

### Implement Background Processing for Long-Running Operations

- Use StartSession for non-interactive processing
- Consider job queue entries for scheduled operations
- Implement proper progress reporting for long-running tasks

```al
// Background processing pattern
procedure ProcessLargeDatasetInBackground()
var
    JobQueueEntry: Record "Job Queue Entry";
begin
    JobQueueEntry.ScheduleJobQueueEntry(
        Codeunit::"Large Dataset Processor",
        Rec.RecordId);
end;
```

## Performance Monitoring and Bottleneck Identification

### AL Performance Monitoring Techniques

```al
// Performance measurement pattern
procedure MeasurePerformance()
var
    StartTime: DateTime;
    Duration: Duration;
begin
    StartTime := CurrentDateTime;

    // Performance-critical operation
    PerformCriticalOperation();

    Duration := CurrentDateTime - StartTime;
    LogPerformanceMetric('CriticalOperation', Duration);
end;
```

### Profiling Techniques for AL Development

- Implement telemetry to track operation durations
- Use the performance profiler to identify bottlenecks
- Set up alerts for slow-running operations
- Regularly review performance metrics with Business Central telemetry

## Report Optimization

### Optimize Report Performance

- Use appropriate filters to limit data retrieval
- Consider using processing-only reports for data manipulation
- Use temporary tables to prepare data before rendering

```al
// Efficient report data preparation
trigger OnPreDataItem()
begin
    SetLoadFields("No.", "Name"); // Optimize field loading
    SetFilter("Date Filter", GetDateFilter()); // Apply business logic filters
end;
```

## SQL Optimization for Business Central

### Optimize Queries for Business Central Database

- Use indexed fields in filters and sorting
- Avoid complex calculations in WHERE clauses
- Use EXISTS/IN instead of joins when appropriate
- Monitor and optimize slow-running queries through telemetry

### Advanced Query Patterns

```al
// Efficient query usage for complex operations
query CustomerSalesAnalysis
{
    elements
    {
        dataitem(Customer; Customer)
        {
            filter(PostingGroup; "Customer Posting Group")
            {
                // Indexed field for efficient filtering
            }
            column(CustomerNo; "No.")
            column(CustomerName; Name)

            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Sell-to Customer No." = Customer."No.";
                column(TotalAmount; Amount)
                {
                    Method = Sum;
                }
            }
        }
    }
}
```

## Caching Strategies

### Implement Caching for Frequently Accessed Data

- Cache lookup values that don't change frequently
- Use application cache for shared data
- Implement proper cache invalidation when data changes

```al
// Caching pattern for lookup data
procedure GetCachedSetupValue(KeyValue: Code[20]): Text
var
    TempSetup: Record "Setup Table" temporary;
begin
    if not TempSetup.Get(KeyValue) then begin
        TempSetup.LoadFromDatabase(KeyValue);
        TempSetup.Insert();
    end;
    exit(TempSetup."Setup Value");
end;
```

## Advanced Performance Patterns

### Bulk Processing Techniques

```al
// Efficient bulk operations
procedure BulkUpdateCustomers()
var
    Customer: Record Customer;
begin
    Customer.SetLoadFields("Credit Limit (LCY)", "Last Modified Date Time");
    if Customer.FindSet(true) then
        repeat
            Customer."Credit Limit (LCY)" := CalculateNewLimit(Customer);
            Customer.Modify(false); // Skip validation for bulk operations
        until Customer.Next() = 0;
end;
```

### Performance Testing and Validation

<!-- AI_TRIGGER: When developer completes performance optimization, suggest comprehensive testing and monitoring -->
<!-- PROACTIVE_SUGGEST: After optimization implementation -> Suggest performance validation checklist -->

- Implement automated performance tests
- Use telemetry data to identify regression
- Set performance benchmarks for critical operations
- Monitor resource utilization during peak usage

## Performance Optimization Best Practices Summary

<!-- EDUCATIONAL_ESCALATION:
LEVEL_1: Suggest appropriate optimization pattern for developer's code
LEVEL_2: Provide detailed implementation guidance with measurement
LEVEL_3: Explain performance impact and DevOps integration
LEVEL_4: Discuss enterprise-level performance strategies and monitoring
-->

### Quick Performance Optimization Checklist

<!-- AI_TRIGGER: When developer reviews performance-critical code, suggest this checklist -->
<!-- PROACTIVE_SUGGEST: Before code review -> Suggest performance validation checklist -->

- [ ] **SetLoadFields Usage**: Only load required fields for record processing
- [ ] **Efficient Filtering**: Use indexed fields and appropriate filter strategies
- [ ] **Database Operations**: Minimize database calls and use bulk operations
- [ ] **Memory Management**: Proper cleanup and temporary table usage
- [ ] **Caching Strategy**: Implement appropriate caching for frequently accessed data
- [ ] **Performance Measurement**: Baseline metrics and improvement validation
- [ ] **Testing Integration**: Performance tests in CI/CD pipeline
- [ ] **DevOps Integration**: Work items updated with performance requirements
- [ ] **Monitoring Setup**: Performance alerts and dashboards configured
- [ ] **Documentation**: Optimization rationale and metrics documented

### AI-Enhanced Performance Development

<!-- CONTEXT_RECOGNITION_PATTERNS:
IF developer_writing_loops AND no_setloadfields_mentioned:
  SUGGEST: "Consider using SetLoadFields to optimize field loading"
  EDUCATE: "SetLoadFields significantly improves performance by loading only required fields"

IF developer_optimizing_performance AND no_measurement_mentioned:
  SUGGEST: "Add performance measurement to validate your optimization"
  EDUCATE: "Measuring performance before and after optimization ensures effectiveness"

IF developer_working_on_performance AND no_devops_mentioned:
  SUGGEST: "Update your Azure DevOps work item with performance requirements"
  EDUCATE: "Performance requirements help team understand optimization impact"
-->

This guide enables Copilot to provide intelligent, context-aware guidance for AL performance optimization, ensuring measurable improvements and proper DevOps integration throughout the development lifecycle.
