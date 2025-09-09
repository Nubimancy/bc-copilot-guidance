# AL Performance Optimization Guidelines - Code Samples

## Database Operation Optimization

### Efficient Record Filtering and Processing

```al
// WRONG: Processing all records without filtering
procedure ProcessAllCustomers()
var
    Customer: Record Customer;
begin
    if Customer.FindSet() then
        repeat
            // Expensive operation on every customer
            ProcessCustomerData(Customer);
        until Customer.Next() = 0;
end;

// RIGHT: Filter before processing
procedure ProcessActiveCustomers()
var
    Customer: Record Customer;
begin
    // Filter to reduce dataset size
    Customer.SetRange(Blocked, Customer.Blocked::" ");
    Customer.SetFilter("Date Filter", '>=%1', CalcDate('-1Y', Today()));
    
    if Customer.FindSet() then
        repeat
            ProcessCustomerData(Customer);
        until Customer.Next() = 0;
end;
```

### SetLoadFields for Selective Field Loading

```al
// WRONG: Loading entire record when only few fields needed
procedure GetCustomerNames(): List of [Text]
var
    Customer: Record Customer;
    CustomerNames: List of [Text];
begin
    if Customer.FindSet() then  // Loads ALL fields
        repeat
            CustomerNames.Add(Customer.Name);
        until Customer.Next() = 0;
    exit(CustomerNames);
end;

// RIGHT: Load only required fields
procedure GetCustomerNamesOptimized(): List of [Text]
var
    Customer: Record Customer;
    CustomerNames: List of [Text];
begin
    Customer.SetLoadFields(Name);  // Load only Name field
    if Customer.FindSet(false, false) then  // ReadOnly = true, ReadShared = true
        repeat
            CustomerNames.Add(Customer.Name);
        until Customer.Next() = 0;
    exit(CustomerNames);
end;
```

### Avoiding Nested Database Operations

```al
// WRONG: Nested database calls in loops
procedure CalculateCustomerTotalsWrong()
var
    Customer: Record Customer;
    SalesLine: Record "Sales Line";
    CustomerTotal: Decimal;
begin
    if Customer.FindSet() then
        repeat
            // Database call inside loop - VERY SLOW!
            SalesLine.SetRange("Sell-to Customer No.", Customer."No.");
            SalesLine.CalcSums(Amount);
            CustomerTotal := SalesLine.Amount;
            
            Customer."Total Sales" := CustomerTotal;
            Customer.Modify();
        until Customer.Next() = 0;
end;

// RIGHT: Use queries or bulk operations
procedure CalculateCustomerTotalsOptimized()
var
    Customer: Record Customer;
    TempCustomerTotals: Record "Customer Totals Buffer" temporary;
begin
    // Step 1: Calculate all totals in a single query operation
    CalculateAllCustomerTotals(TempCustomerTotals);
    
    // Step 2: Update customers in bulk
    if Customer.FindSet(true, false) then
        repeat
            if TempCustomerTotals.Get(Customer."No.") then begin
                Customer."Total Sales" := TempCustomerTotals."Total Amount";
                Customer.Modify();
            end;
        until Customer.Next() = 0;
end;

local procedure CalculateAllCustomerTotals(var TempCustomerTotals: Record "Customer Totals Buffer" temporary)
var
    SalesLine: Record "Sales Line";
begin
    TempCustomerTotals.DeleteAll();
    
    // Use SQL aggregation to calculate all totals at once
    SalesLine.SetCurrentKey("Sell-to Customer No.");
    if SalesLine.FindSet() then
        repeat
            if not TempCustomerTotals.Get(SalesLine."Sell-to Customer No.") then begin
                TempCustomerTotals."Customer No." := SalesLine."Sell-to Customer No.";
                TempCustomerTotals."Total Amount" := 0;
                TempCustomerTotals.Insert();
            end;
            TempCustomerTotals."Total Amount" += SalesLine.Amount;
            TempCustomerTotals.Modify();
        until SalesLine.Next() = 0;
end;
```

## UI Performance Optimization

### Optimized OnAfterGetRecord Trigger

```al
// WRONG: Heavy calculations in OnAfterGetRecord
pageextension 50100 "Customer List Slow" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field("Total Sales Amount"; GetTotalSalesAmount())
            {
                ApplicationArea = All;
            }
        }
    }

    // This will be called for EVERY visible record - SLOW!
    local procedure GetTotalSalesAmount(): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Sell-to Customer No.", Rec."No.");
        SalesLine.CalcSums(Amount);
        exit(SalesLine.Amount);
    end;
}

// RIGHT: Use FlowFields or pre-calculated values
pageextension 50101 "Customer List Fast" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field("Total Sales (LCY)"; Rec."Sales (LCY)")  // Use existing FlowField
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Set auto-calc for the FlowField once
        Rec.SetAutoCalcFields("Sales (LCY)");
    end;
}
```

### Efficient Page Updates

```al
// WRONG: Frequent page updates
procedure UpdateMultipleRecords()
var
    Customer: Record Customer;
begin
    if Customer.FindSet(true, false) then
        repeat
            Customer."Last Modified" := CurrentDateTime();
            Customer.Modify();
            CurrPage.Update(true);  // Updates page for each record - SLOW!
        until Customer.Next() = 0;
end;

// RIGHT: Batch updates with single page refresh
procedure UpdateMultipleRecordsOptimized()
var
    Customer: Record Customer;
begin
    if Customer.FindSet(true, false) then
        repeat
            Customer."Last Modified" := CurrentDateTime();
            Customer.Modify();
        until Customer.Next() = 0;
        
    CurrPage.Update(false);  // Single update after all modifications
end;
```

## Background Processing Patterns

### StartSession for Long-Running Operations

```al
// Long-running operation moved to background
codeunit 50100 "Background Processing Manager"
{
    procedure StartBackgroundCalculation(CustomerId: Code[20])
    var
        CalculationCodeunit: Codeunit "Heavy Calculation Engine";
    begin
        // Start in background session to avoid blocking UI
        StartSession(SessionId(), Codeunit::"Heavy Calculation Engine", CompanyName(), CustomerId);
        
        Message('Calculation started in background. You will receive a notification when complete.');
    end;
}

// Heavy calculation codeunit
codeunit 50101 "Heavy Calculation Engine"
{
    trigger OnRun()
    var
        CustomerId: Code[20];
        NotificationManager: Codeunit "Notification Management";
    begin
        // Get parameter from session
        CustomerId := GetParameter();
        
        // Perform heavy calculation
        if PerformComplexCalculation(CustomerId) then
            NotificationManager.SendNotification('Calculation completed successfully for customer ' + CustomerId)
        else
            NotificationManager.SendNotification('Calculation failed for customer ' + CustomerId);
    end;

    local procedure PerformComplexCalculation(CustomerId: Code[20]): Boolean
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        Progress: Dialog;
        Counter: Integer;
        Total: Integer;
    begin
        // Show progress for long operation
        Progress.Open('Processing customer data... @1@@@@@@@@@@@');
        
        Customer.Get(CustomerId);
        
        SalesLine.SetRange("Sell-to Customer No.", CustomerId);
        Total := SalesLine.Count();
        
        if SalesLine.FindSet() then
            repeat
                Counter += 1;
                Progress.Update(1, Round(Counter / Total * 10000, 1));
                
                // Perform complex calculation
                ProcessSalesLine(SalesLine);
                
                // Allow other operations to process
                if Counter mod 100 = 0 then
                    Sleep(10);
                    
            until SalesLine.Next() = 0;
            
        Progress.Close();
        exit(true);
    end;
}
```

### Job Queue Entry Implementation

```al
// Job queue setup for scheduled background processing
codeunit 50102 "Scheduled Processing Manager"
{
    procedure ScheduleDailyProcessing()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Daily Processing Engine";
        JobQueueEntry.Description := 'Daily Customer Data Processing';
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."Run on Mondays" := true;
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Starting Time" := 020000T;  // 2:00 AM
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry.Insert(true);
    end;
}
```

## Performance Monitoring Implementation

### Telemetry Integration for Performance Tracking

```al
codeunit 50103 "Performance Monitoring"
{
    procedure TrackOperationPerformance(OperationName: Text; StartTime: DateTime; EndTime: DateTime; RecordCount: Integer)
    var
        TelemetryClient: Codeunit "Telemetry Client";
        CustomDimensions: Dictionary of [Text, Text];
        Duration: Duration;
    begin
        Duration := EndTime - StartTime;
        
        // Add custom dimensions for detailed analysis
        CustomDimensions.Add('OperationName', OperationName);
        CustomDimensions.Add('Duration', Format(Duration));
        CustomDimensions.Add('RecordCount', Format(RecordCount));
        CustomDimensions.Add('RecordsPerSecond', Format(RecordCount / (Duration / 1000)));
        
        // Send telemetry data
        TelemetryClient.LogMessage(
            'Performance-Tracking',
            StrSubstNo('Operation %1 processed %2 records in %3ms', OperationName, RecordCount, Duration),
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            CustomDimensions
        );
    end;

    procedure MonitorDatabaseOperation(var RecordToProcess: RecordRef; OperationName: Text)
    var
        StartTime: DateTime;
        EndTime: DateTime;
        RecordCount: Integer;
    begin
        StartTime := CurrentDateTime();
        
        // Perform the operation
        RecordCount := RecordToProcess.Count();
        
        EndTime := CurrentDateTime();
        
        // Track performance
        TrackOperationPerformance(OperationName, StartTime, EndTime, RecordCount);
        
        // Alert if operation is slow
        if (EndTime - StartTime) > 5000 then  // 5 seconds
            LogSlowOperation(OperationName, EndTime - StartTime, RecordCount);
    end;

    local procedure LogSlowOperation(OperationName: Text; Duration: Duration; RecordCount: Integer)
    var
        TelemetryClient: Codeunit "Telemetry Client";
    begin
        TelemetryClient.LogMessage(
            'Performance-Alert',
            StrSubstNo('SLOW OPERATION: %1 took %2ms for %3 records', OperationName, Duration, RecordCount),
            Verbosity::Warning,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher
        );
    end;
}
```

### Performance Profiling Integration

```al
// Performance profiling wrapper for critical operations
codeunit 50104 "Performance Profiler"
{
    var
        ProfileStartTime: DateTime;
        ProfileOperationName: Text;

    procedure StartProfiling(OperationName: Text)
    begin
        ProfileOperationName := OperationName;
        ProfileStartTime := CurrentDateTime();
    end;

    procedure EndProfiling()
    var
        Duration: Duration;
        PerformanceMonitor: Codeunit "Performance Monitoring";
    begin
        if ProfileStartTime <> 0DT then begin
            Duration := CurrentDateTime() - ProfileStartTime;
            PerformanceMonitor.TrackOperationPerformance(ProfileOperationName, ProfileStartTime, CurrentDateTime(), 1);
            
            // Reset for next operation
            Clear(ProfileStartTime);
            Clear(ProfileOperationName);
        end;
    end;

    procedure ProfileOperation(OperationName: Text; OperationToProfile: Codeunit "Operation Interface")
    begin
        StartProfiling(OperationName);
        OperationToProfile.Execute();
        EndProfiling();
    end;
}

// Usage example with profiling
codeunit 50105 "Customer Processing Engine"
{
    procedure ProcessCustomers()
    var
        Profiler: Codeunit "Performance Profiler";
        Customer: Record Customer;
    begin
        Profiler.StartProfiling('Customer Processing - Data Load');
        
        // Optimized data loading
        Customer.SetLoadFields(Name, "Phone No.", "E-Mail");
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        
        Profiler.EndProfiling();
        Profiler.StartProfiling('Customer Processing - Business Logic');
        
        if Customer.FindSet() then
            repeat
                ProcessIndividualCustomer(Customer);
            until Customer.Next() = 0;
            
        Profiler.EndProfiling();
    end;
}
```
