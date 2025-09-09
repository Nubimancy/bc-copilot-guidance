# AppSource Integration and Performance Standards - Code Samples

## API Integration Examples

```al
// External API integration with proper error handling
codeunit 50110 "BRC External API Client"
{
    var
        HttpClient: HttpClient;
        ApiBaseUrl: Text;
        AccessToken: Text;

    /// <summary>
    /// Synchronizes customer data with external CRM system
    /// </summary>
    /// <param name="Customer">Customer record to synchronize</param>
    /// <returns>True if synchronization was successful</returns>
    procedure SynchronizeCustomer(var Customer: Record Customer): Boolean
    var
        JsonPayload: JsonObject;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ErrorInfo: ErrorInfo;
    begin
        if not ValidateApiConfiguration() then
            exit(false);

        // Build JSON payload
        JsonPayload.Add('customerNo', Customer."No.");
        JsonPayload.Add('name', Customer.Name);
        JsonPayload.Add('email', Customer."E-Mail");
        JsonPayload.Add('phoneNo', Customer."Phone No.");

        // Configure HTTP request
        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.SetRequestUri(ApiBaseUrl + '/customers');
        HttpRequestMessage.Content.WriteFrom(Format(JsonPayload));
        HttpRequestMessage.Content.GetHeaders().Add('Content-Type', 'application/json');
        HttpRequestMessage.GetHeaders().Add('Authorization', 'Bearer ' + AccessToken);

        // Send request with timeout and retry logic
        if not SendRequestWithRetry(HttpRequestMessage, HttpResponseMessage, 3) then begin
            ErrorInfo.Title := 'API Communication Failed';
            ErrorInfo.Message := 'Unable to synchronize customer data with external system.';
            ErrorInfo.DetailedMessage := 'The external CRM system is currently unavailable. The customer data has been saved locally and will be synchronized when the system becomes available.';
            ErrorInfo.AddAction('Retry Now', Codeunit::"BRC External API Client", 'RetrySync');
            Error(ErrorInfo);
        end;

        // Process response
        HttpResponseMessage.Content.ReadAs(ResponseText);
        
        if HttpResponseMessage.IsSuccessStatusCode() then begin
            ProcessSyncResponse(Customer, ResponseText);
            exit(true);
        end else
            HandleApiError(HttpResponseMessage, ResponseText);

        exit(false);
    end;

    local procedure SendRequestWithRetry(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; MaxRetries: Integer): Boolean
    var
        RetryCount: Integer;
        DelayMilliseconds: Integer;
    begin
        DelayMilliseconds := 1000; // Start with 1 second delay
        
        for RetryCount := 1 to MaxRetries do begin
            if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
                exit(true);
                
            if RetryCount < MaxRetries then begin
                Sleep(DelayMilliseconds);
                DelayMilliseconds := DelayMilliseconds * 2; // Exponential backoff
            end;
        end;
        
        exit(false);
    end;
}
```

## Performance Optimization Examples

```al
// High-performance bulk processing with SetLoadFields
codeunit 50111 "BRC Customer Bulk Processor"
{
    /// <summary>
    /// Processes large customer datasets efficiently
    /// </summary>
    /// <param name="DateFilter">Date filter for processing</param>
    procedure ProcessCustomerLoyaltyUpdates(DateFilter: Text)
    var
        Customer: Record Customer;
        LoyaltyCard: Record "BRC Customer Loyalty Card";
        TempProcessingBuffer: Record "Name/Value Buffer" temporary;
        ProcessedCount: Integer;
        StartTime: DateTime;
        Duration: Duration;
    begin
        StartTime := CurrentDateTime();
        
        // Use SetLoadFields for optimal performance
        Customer.SetLoadFields("No.", Name, "Last Date Modified");
        Customer.SetFilter("Last Date Modified", DateFilter);
        
        if Customer.FindSet() then
            repeat
                // Buffer processing for batch operations
                TempProcessingBuffer.Init();
                TempProcessingBuffer.ID := ProcessedCount + 1;
                TempProcessingBuffer.Name := Customer."No.";
                TempProcessingBuffer.Value := Customer.Name;
                TempProcessingBuffer.Insert();
                
                ProcessedCount += 1;
                
                // Process in batches to avoid memory issues
                if ProcessedCount mod 1000 = 0 then begin
                    ProcessCustomerBatch(TempProcessingBuffer);
                    TempProcessingBuffer.DeleteAll();
                    Commit(); // Prevent long-running transactions
                    
                    // Log progress
                    Duration := CurrentDateTime() - StartTime;
                    Message('Processed %1 customers in %2 seconds...', ProcessedCount, Duration div 1000);
                end;
            until Customer.Next() = 0;
            
        // Process remaining records
        if not TempProcessingBuffer.IsEmpty then
            ProcessCustomerBatch(TempProcessingBuffer);
            
        Duration := CurrentDateTime() - StartTime;
        Message('Successfully processed %1 customers in %2 seconds.', ProcessedCount, Duration div 1000);
    end;

    local procedure ProcessCustomerBatch(var TempBuffer: Record "Name/Value Buffer" temporary)
    var
        LoyaltyCard: Record "BRC Customer Loyalty Card";
    begin
        // Batch process loyalty card updates
        if TempBuffer.FindSet() then
            repeat
                LoyaltyCard.SetLoadFields("Customer No.", "Points Balance");
                LoyaltyCard.SetRange("Customer No.", TempBuffer.Name);
                
                if LoyaltyCard.FindFirst() then begin
                    LoyaltyCard."Points Balance" += CalculateBonusPoints(TempBuffer.Name);
                    LoyaltyCard.Modify();
                end;
            until TempBuffer.Next() = 0;
    end;
}
```

## Telemetry and Monitoring Examples

```al
// Application Insights integration for monitoring
codeunit 50112 "BRC Telemetry Manager"
{
    /// <summary>
    /// Logs performance metrics to Application Insights
    /// </summary>
    /// <param name="OperationName">Name of the operation being measured</param>
    /// <param name="Duration">Duration in milliseconds</param>
    /// <param name="Success">Whether the operation was successful</param>
    procedure LogPerformanceMetric(OperationName: Text; Duration: Duration; Success: Boolean)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        // Add custom dimensions for better analysis
        CustomDimensions.Add('CompanyName', CompanyName);
        CustomDimensions.Add('UserID', UserId);
        CustomDimensions.Add('Operation', OperationName);
        CustomDimensions.Add('Success', Format(Success));
        CustomDimensions.Add('DurationMs', Format(Duration));
        
        // Send to Application Insights
        Session.LogMessage('BRC001', 'Performance: ' + OperationName, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    /// <summary>
    /// Logs business events for analytics
    /// </summary>
    /// <param name="EventName">Name of the business event</param>
    /// <param name="EventData">Additional event data</param>
    procedure LogBusinessEvent(EventName: Text; EventData: Dictionary of [Text, Text])
    var
        CustomDimensions: Dictionary of [Text, Text];
        Key: Text;
    begin
        // Add standard dimensions
        CustomDimensions.Add('EventType', 'Business');
        CustomDimensions.Add('EventName', EventName);
        CustomDimensions.Add('CompanyName', CompanyName);
        CustomDimensions.Add('Timestamp', Format(CurrentDateTime, 0, 9));
        
        // Add custom event data
        foreach Key in EventData.Keys do
            CustomDimensions.Add(Key, EventData.Get(Key));
        
        Session.LogMessage('BRC002', 'Business Event: ' + EventName, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;
}
```

## Error Handling and Recovery Examples

```al
// Robust error handling with recovery strategies
codeunit 50113 "BRC Error Recovery Manager"
{
    /// <summary>
    /// Handles integration errors with automatic recovery
    /// </summary>
    /// <param name="ErrorContext">Context information about the error</param>
    /// <param name="RetryAttempts">Number of retry attempts remaining</param>
    procedure HandleIntegrationError(ErrorContext: Text; var RetryAttempts: Integer): Boolean
    var
        ErrorLog: Record "BRC Error Log";
        ErrorInfo: ErrorInfo;
        RecoveryAction: Text;
    begin
        // Log the error for analysis
        LogError(ErrorContext, GetLastErrorText());
        
        // Determine recovery strategy based on error type
        case true of
            GetLastErrorText().Contains('timeout'):
                RecoveryAction := 'RETRY_WITH_DELAY';
            GetLastErrorText().Contains('unauthorized'):
                RecoveryAction := 'REFRESH_TOKEN';
            GetLastErrorText().Contains('rate limit'):
                RecoveryAction := 'EXPONENTIAL_BACKOFF';
            else
                RecoveryAction := 'MANUAL_INTERVENTION';
        end;
        
        // Execute recovery action
        case RecoveryAction of
            'RETRY_WITH_DELAY':
                begin
                    if RetryAttempts > 0 then begin
                        Sleep(5000); // Wait 5 seconds
                        RetryAttempts -= 1;
                        exit(true); // Indicate retry should be attempted
                    end;
                end;
                
            'REFRESH_TOKEN':
                begin
                    if RefreshApiToken() then
                        exit(true);
                end;
                
            'EXPONENTIAL_BACKOFF':
                begin
                    if RetryAttempts > 0 then begin
                        Sleep((4 - RetryAttempts) * 10000); // Exponential backoff
                        RetryAttempts -= 1;
                        exit(true);
                    end;
                end;
                
            'MANUAL_INTERVENTION':
                begin
                    ErrorInfo.Title := 'Integration Error - Manual Intervention Required';
                    ErrorInfo.Message := 'An integration error occurred that requires manual intervention.';
                    ErrorInfo.DetailedMessage := StrSubstNo('Error: %1\n\nContext: %2\n\nPlease contact your system administrator.', GetLastErrorText(), ErrorContext);
                    ErrorInfo.AddAction('View Error Log', Page::"BRC Error Log");
                    Error(ErrorInfo);
                end;
        end;
        
        exit(false); // No recovery possible
    end;

    local procedure LogError(Context: Text; ErrorMessage: Text)
    var
        ErrorLog: Record "BRC Error Log";
    begin
        ErrorLog.Init();
        ErrorLog."Entry No." := GetNextErrorEntryNo();
        ErrorLog."Date Time" := CurrentDateTime;
        ErrorLog."User ID" := UserId;
        ErrorLog.Context := CopyStr(Context, 1, MaxStrLen(ErrorLog.Context));
        ErrorLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(ErrorLog."Error Message"));
        ErrorLog."Company Name" := CompanyName;
        ErrorLog.Insert();
    end;
}
```

## Performance Testing Framework

```al
// Performance testing and validation framework
codeunit 50114 "BRC Performance Tester"
{
    /// <summary>
    /// Runs performance tests to validate AppSource compliance
    /// </summary>
    procedure RunPerformanceTests(): Boolean
    var
        TestResults: Dictionary of [Text, Duration];
        TestPassed: Boolean;
    begin
        TestPassed := true;
        
        // Test 1: Page load performance
        TestResults.Add('PageLoad', TestPageLoadPerformance());
        if TestResults.Get('PageLoad') > 3000 then // 3 seconds max
            TestPassed := false;
            
        // Test 2: Bulk processing performance
        TestResults.Add('BulkProcessing', TestBulkProcessingPerformance());
        if TestResults.Get('BulkProcessing') > 30000 then // 30 seconds max
            TestPassed := false;
            
        // Test 3: Search performance
        TestResults.Add('SearchPerformance', TestSearchPerformance());
        if TestResults.Get('SearchPerformance') > 2000 then // 2 seconds max
            TestPassed := false;
            
        // Log all test results
        LogPerformanceTestResults(TestResults, TestPassed);
        
        exit(TestPassed);
    end;

    local procedure TestPageLoadPerformance(): Duration
    var
        StartTime: DateTime;
        LoyaltyCard: Record "BRC Customer Loyalty Card";
    begin
        StartTime := CurrentDateTime;
        
        // Simulate page load operations
        LoyaltyCard.SetLoadFields("Card No.", "Customer No.", "Customer Name", "Points Balance");
        LoyaltyCard.FindSet();
        
        exit(CurrentDateTime - StartTime);
    end;

    local procedure TestBulkProcessingPerformance(): Duration
    var
        StartTime: DateTime;
        Customer: Record Customer;
        ProcessedCount: Integer;
    begin
        StartTime := CurrentDateTime;
        
        // Process 1000 customer records
        Customer.SetLoadFields("No.", Name);
        if Customer.FindSet() then
            repeat
                // Simulate processing
                ProcessedCount += 1;
            until (Customer.Next() = 0) or (ProcessedCount >= 1000);
        
        exit(CurrentDateTime - StartTime);
    end;
}
```
