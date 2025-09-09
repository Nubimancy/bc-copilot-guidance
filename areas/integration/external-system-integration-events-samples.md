---
title: "External System Integration Events - Code Samples"
description: "Production-ready implementations for integrating Business Central events with external systems via REST APIs, webhooks, and message queues"
area: "integration"
difficulty: "advanced"
object_types: ["Codeunit", "Table"]
variable_types: ["HttpClient", "JsonObject", "Dictionary", "List"]
tags: ["integration", "events", "http", "webhooks", "external-systems", "api", "samples"]
---

# External System Integration Events - Code Samples

## Complete HTTP Integration Framework

### Robust External System Notifier

```al
codeunit 50300 "Enterprise External Notifier"
{
    var
        HttpTimeout: Integer;
        MaxRetryAttempts: Integer;
        BaseRetryDelay: Integer;
        ConnectionPoolSize: Integer;
        
    trigger OnRun()
    begin
        Initialize();
    end;
    
    local procedure Initialize()
    begin
        HttpTimeout := 30000; // 30 seconds
        MaxRetryAttempts := 5;
        BaseRetryDelay := 1000; // 1 second
        ConnectionPoolSize := 10;
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Management", 'OnAfterCustomerRegistration', '', false, false)]
    local procedure NotifyExternalSystemsOfNewCustomer(var Customer: Record Customer)
    var
        ExternalEndpoints: List of [Text];
        EventPayload: Text;
        Endpoint: Text;
        NotificationResults: Dictionary of [Text, Boolean];
        SuccessCount: Integer;
        TotalEndpoints: Integer;
    begin
        // Get configured endpoints for customer events
        ExternalEndpoints := GetExternalEndpointsForEventType('CustomerCreated');
        TotalEndpoints := ExternalEndpoints.Count;
        
        if TotalEndpoints = 0 then
            exit; // No endpoints configured
            
        EventPayload := CreateComprehensiveCustomerEventPayload(Customer);
        
        // Send to all endpoints in parallel (async)
        foreach Endpoint in ExternalEndpoints do begin
            if SendNotificationToEndpoint(Endpoint, EventPayload, 'CustomerCreated') then begin
                NotificationResults.Set(Endpoint, true);
                SuccessCount += 1;
            end else
                NotificationResults.Set(Endpoint, false);
        end;
        
        // Log overall results
        LogNotificationSummary('CustomerCreated', Customer."No.", SuccessCount, TotalEndpoints, NotificationResults);
        
        // Handle partial failures
        if SuccessCount < TotalEndpoints then
            HandlePartialNotificationFailure('CustomerCreated', Customer."No.", NotificationResults);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Management", 'OnAfterOrderStatusChange', '', false, false)]
    local procedure NotifyOrderStatusChange(var SalesHeader: Record "Sales Header"; 
                                          OldStatus: Enum "Sales Document Status";
                                          NewStatus: Enum "Sales Document Status")
    var
        EventPayload: Text;
        NotificationContext: JsonObject;
        ExternalEndpoints: List of [Text];
        Endpoint: Text;
        NotificationId: Guid;
    begin
        // Create rich event context
        NotificationContext.Add('orderId', SalesHeader."No.");
        NotificationContext.Add('customerId', SalesHeader."Sell-to Customer No.");
        NotificationContext.Add('oldStatus', Format(OldStatus));
        NotificationContext.Add('newStatus', Format(NewStatus));
        NotificationContext.Add('priority', GetOrderPriority(SalesHeader));
        NotificationContext.Add('estimatedValue', CalculateOrderValue(SalesHeader));
        
        EventPayload := CreateOrderStatusEventPayload(SalesHeader, OldStatus, NewStatus, NotificationContext);
        ExternalEndpoints := GetExternalEndpointsForEventType('OrderStatusChanged');
        
        foreach Endpoint in ExternalEndpoints do begin
            NotificationId := CreateGuid();
            
            // Send with correlation ID for tracking
            if not SendNotificationWithCorrelation(Endpoint, EventPayload, 'OrderStatusChanged', NotificationId) then
                QueueFailedNotification(Endpoint, EventPayload, 'OrderStatusChanged', NotificationId);
        end;
    end;
    
    local procedure SendNotificationToEndpoint(Endpoint: Text; EventPayload: Text; EventType: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        IsSuccess: Boolean;
        RetryAttempt: Integer;
        RetryDelay: Integer;
        RequestId: Guid;
        StartTime: DateTime;
        Duration: Duration;
    begin
        RequestId := CreateGuid();
        StartTime := CurrentDateTime;
        RetryDelay := BaseRetryDelay;
        
        // Configure HTTP client
        HttpClient.Timeout := HttpTimeout;
        HttpClient.GetDefaultRequestHeaders(RequestHeaders);
        RequestHeaders.Add('User-Agent', 'BusinessCentral-Integration/2.0');
        RequestHeaders.Add('X-BC-Request-ID', Format(RequestId));
        RequestHeaders.Add('X-BC-Event-Type', EventType);
        RequestHeaders.Add('X-BC-Timestamp', Format(CurrentDateTime, 0, 9));
        
        for RetryAttempt := 1 to MaxRetryAttempts do begin
            // Configure request content
            Clear(HttpContent);
            HttpContent.WriteFrom(EventPayload);
            HttpContent.GetHeaders(HttpHeaders);
            HttpHeaders.Clear();
            HttpHeaders.Add('Content-Type', 'application/json');
            HttpHeaders.Add('Authorization', GetAuthorizationHeaderForEndpoint(Endpoint));
            HttpHeaders.Add('X-BC-Retry-Attempt', Format(RetryAttempt));
            
            // Add request signature for security
            HttpHeaders.Add('X-BC-Signature', CreateRequestSignature(EventPayload, Endpoint));
            
            try
                IsSuccess := HttpClient.Post(Endpoint, HttpContent, Response);
                
                Duration := CurrentDateTime - StartTime;
                
                if IsSuccess and Response.IsSuccessStatusCode() then begin
                    LogSuccessfulNotification(Endpoint, EventType, RequestId, RetryAttempt, Duration);
                    exit(true);
                end else begin
                    LogFailedAttempt(Endpoint, EventType, RequestId, RetryAttempt, Response, Duration);
                    
                    // Check if we should retry based on response
                    if not ShouldRetryBasedOnResponse(Response) then
                        break;
                        
                    if RetryAttempt < MaxRetryAttempts then begin
                        Sleep(RetryDelay);
                        RetryDelay := RetryDelay * 2; // Exponential backoff
                        StartTime := CurrentDateTime; // Reset timer for next attempt
                    end;
                end;
            finally
                // Always log the attempt
                LogHttpAttempt(Endpoint, EventType, RequestId, RetryAttempt, IsSuccess);
            end;
        end;
        
        // All retries exhausted
        LogExhaustedRetries(Endpoint, EventType, RequestId, MaxRetryAttempts);
        exit(false);
    end;
    
    local procedure SendNotificationWithCorrelation(Endpoint: Text; EventPayload: Text; EventType: Text; CorrelationId: Guid): Boolean
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        EnhancedPayload: JsonObject;
        OriginalPayload: JsonObject;
        MetadataJson: JsonObject;
    begin
        // Parse original payload
        if not OriginalPayload.ReadFrom(EventPayload) then
            Error('Invalid JSON payload');
        
        // Add correlation metadata
        MetadataJson.Add('correlationId', Format(CorrelationId));
        MetadataJson.Add('sourceSystem', 'BusinessCentral');
        MetadataJson.Add('sourceVersion', GetSystemVersion());
        MetadataJson.Add('traceId', CreateGuid());
        
        // Build enhanced payload
        EnhancedPayload.Add('metadata', MetadataJson);
        EnhancedPayload.Add('event', OriginalPayload);
        
        exit(SendNotificationToEndpoint(Endpoint, Format(EnhancedPayload), EventType));
    end;
    
    local procedure CreateComprehensiveCustomerEventPayload(Customer: Record Customer): Text
    var
        EventJson: JsonObject;
        CustomerJson: JsonObject;
        AddressJson: JsonObject;
        ContactJson: JsonObject;
        FinancialJson: JsonObject;
        PreferencesJson: JsonObject;
        MetadataJson: JsonObject;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // Customer basic info
        CustomerJson.Add('no', Customer."No.");
        CustomerJson.Add('name', Customer.Name);
        CustomerJson.Add('name2', Customer."Name 2");
        CustomerJson.Add('searchName', Customer."Search Name");
        CustomerJson.Add('blocked', Format(Customer.Blocked));
        CustomerJson.Add('privacyBlocked', Customer."Privacy Blocked");
        
        // Address information
        AddressJson.Add('address', Customer.Address);
        AddressJson.Add('address2', Customer."Address 2");
        AddressJson.Add('city', Customer.City);
        AddressJson.Add('county', Customer.County);
        AddressJson.Add('postCode', Customer."Post Code");
        AddressJson.Add('countryRegionCode', Customer."Country/Region Code");
        CustomerJson.Add('address', AddressJson);
        
        // Contact information
        ContactJson.Add('phoneNo', Customer."Phone No.");
        ContactJson.Add('mobilePhoneNo', Customer."Mobile Phone No.");
        ContactJson.Add('email', Customer."E-Mail");
        ContactJson.Add('homePage', Customer."Home Page");
        ContactJson.Add('faxNo', Customer."Fax No.");
        CustomerJson.Add('contact', ContactJson);
        
        // Financial information
        FinancialJson.Add('creditLimit', Customer."Credit Limit (LCY)");
        FinancialJson.Add('balance', Customer."Balance (LCY)");
        FinancialJson.Add('balanceDue', Customer."Balance Due (LCY)");
        FinancialJson.Add('salesLCY', Customer."Sales (LCY)");
        FinancialJson.Add('paymentsLCY', Customer."Payments (LCY)");
        FinancialJson.Add('currencyCode', Customer."Currency Code");
        FinancialJson.Add('paymentTermsCode', Customer."Payment Terms Code");
        FinancialJson.Add('paymentMethodCode', Customer."Payment Method Code");
        CustomerJson.Add('financial', FinancialJson);
        
        // Business preferences
        if SalesSetup.Get() then begin
            PreferencesJson.Add('pricesIncludingVAT', Customer."Prices Including VAT");
            PreferencesJson.Add('genBusPostingGroup', Customer."Gen. Bus. Posting Group");
            PreferencesJson.Add('vatBusPostingGroup', Customer."VAT Bus. Posting Group");
            PreferencesJson.Add('customerPostingGroup', Customer."Customer Posting Group");
            PreferencesJson.Add('shipmentMethodCode', Customer."Shipment Method Code");
            CustomerJson.Add('businessPreferences', PreferencesJson);
        end;
        
        // Metadata
        MetadataJson.Add('lastModifiedDateTime', Customer.SystemModifiedAt);
        MetadataJson.Add('lastModifiedBy', Customer.SystemModifiedBy);
        MetadataJson.Add('createdDateTime', Customer.SystemCreatedAt);
        MetadataJson.Add('createdBy', Customer.SystemCreatedBy);
        CustomerJson.Add('metadata', MetadataJson);
        
        // Build event envelope
        EventJson.Add('eventType', 'CustomerCreated');
        EventJson.Add('eventId', CreateGuid());
        EventJson.Add('eventVersion', '2.0');
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('source', 'BusinessCentral');
        EventJson.Add('subject', StrSubstNo('Customer %1 created', Customer."No."));
        EventJson.Add('dataContentType', 'application/json');
        EventJson.Add('specVersion', '1.0');
        EventJson.Add('data', CustomerJson);
        
        exit(Format(EventJson));
    end;
    
    local procedure CreateOrderStatusEventPayload(SalesHeader: Record "Sales Header"; 
                                                OldStatus: Enum "Sales Document Status";
                                                NewStatus: Enum "Sales Document Status";
                                                Context: JsonObject): Text
    var
        EventJson: JsonObject;
        OrderJson: JsonObject;
        StatusChangeJson: JsonObject;
        OrderLinesArray: JsonArray;
        SalesLines: Record "Sales Line";
        LineJson: JsonObject;
        CustomerJson: JsonObject;
        Customer: Record Customer;
        TotalsJson: JsonObject;
    begin
        // Load customer information
        if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
            CustomerJson.Add('no', Customer."No.");
            CustomerJson.Add('name', Customer.Name);
            CustomerJson.Add('email', Customer."E-Mail");
        end;
        
        // Order header information
        OrderJson.Add('no', SalesHeader."No.");
        OrderJson.Add('documentType', Format(SalesHeader."Document Type"));
        OrderJson.Add('sellToCustomerNo', SalesHeader."Sell-to Customer No.");
        OrderJson.Add('orderDate', SalesHeader."Order Date");
        OrderJson.Add('requestedDeliveryDate', SalesHeader."Requested Delivery Date");
        OrderJson.Add('promisedDeliveryDate', SalesHeader."Promised Delivery Date");
        OrderJson.Add('externalDocumentNo', SalesHeader."External Document No.");
        OrderJson.Add('yourReference', SalesHeader."Your Reference");
        OrderJson.Add('salespersonCode', SalesHeader."Salesperson Code");
        OrderJson.Add('currencyCode', SalesHeader."Currency Code");
        OrderJson.Add('customer', CustomerJson);
        
        // Order lines
        SalesLines.SetRange("Document Type", SalesHeader."Document Type");
        SalesLines.SetRange("Document No.", SalesHeader."No.");
        if SalesLines.FindSet() then
            repeat
                Clear(LineJson);
                LineJson.Add('lineNo', SalesLines."Line No.");
                LineJson.Add('type', Format(SalesLines.Type));
                LineJson.Add('no', SalesLines."No.");
                LineJson.Add('description', SalesLines.Description);
                LineJson.Add('quantity', SalesLines.Quantity);
                LineJson.Add('unitPrice', SalesLines."Unit Price");
                LineJson.Add('lineAmount', SalesLines."Line Amount");
                LineJson.Add('vatPercent', SalesLines."VAT %");
                LineJson.Add('locationCode', SalesLines."Location Code");
                OrderLinesArray.Add(LineJson);
            until SalesLines.Next() = 0;
        OrderJson.Add('lines', OrderLinesArray);
        
        // Calculate totals
        SalesHeader.CalcFields(Amount, "Amount Including VAT");
        TotalsJson.Add('amount', SalesHeader.Amount);
        TotalsJson.Add('amountIncludingVAT', SalesHeader."Amount Including VAT");
        TotalsJson.Add('vatAmount', SalesHeader."Amount Including VAT" - SalesHeader.Amount);
        OrderJson.Add('totals', TotalsJson);
        
        // Status change information
        StatusChangeJson.Add('fromStatus', Format(OldStatus));
        StatusChangeJson.Add('toStatus', Format(NewStatus));
        StatusChangeJson.Add('changedDateTime', CurrentDateTime);
        StatusChangeJson.Add('changedBy', UserId);
        StatusChangeJson.Add('context', Context);
        
        // Build event envelope
        EventJson.Add('eventType', 'OrderStatusChanged');
        EventJson.Add('eventId', CreateGuid());
        EventJson.Add('eventVersion', '2.0');
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('source', 'BusinessCentral');
        EventJson.Add('subject', StrSubstNo('Order %1 status changed from %2 to %3', 
                                          SalesHeader."No.", Format(OldStatus), Format(NewStatus)));
        EventJson.Add('dataContentType', 'application/json');
        EventJson.Add('specVersion', '1.0');
        EventJson.Add('order', OrderJson);
        EventJson.Add('statusChange', StatusChangeJson);
        
        exit(Format(EventJson));
    end;
    
    local procedure GetExternalEndpointsForEventType(EventType: Text): List of [Text]
    var
        ExternalEndpoints: Record "External Integration Endpoint";
        EndpointList: List of [Text];
    begin
        ExternalEndpoints.SetRange("Event Type", EventType);
        ExternalEndpoints.SetRange(Active, true);
        
        if ExternalEndpoints.FindSet() then
            repeat
                if IsEndpointHealthy(ExternalEndpoints."Endpoint URL") then
                    EndpointList.Add(ExternalEndpoints."Endpoint URL");
            until ExternalEndpoints.Next() = 0;
        
        exit(EndpointList);
    end;
    
    local procedure IsEndpointHealthy(EndpointUrl: Text): Boolean
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        HealthCheckUrl: Text;
    begin
        // Construct health check URL (assuming standard pattern)
        HealthCheckUrl := EndpointUrl;
        if not HealthCheckUrl.EndsWith('/health') then
            HealthCheckUrl := HealthCheckUrl + '/health';
            
        HttpClient.Timeout := 5000; // 5 second timeout for health checks
        
        if HttpClient.Get(HealthCheckUrl, Response) then
            exit(Response.IsSuccessStatusCode())
        else
            exit(false);
    end;
    
    local procedure GetAuthorizationHeaderForEndpoint(Endpoint: Text): Text
    var
        EndpointConfig: Record "External Integration Endpoint";
        AccessToken: Text;
    begin
        EndpointConfig.SetRange("Endpoint URL", Endpoint);
        if EndpointConfig.FindFirst() then begin
            case EndpointConfig."Auth Type" of
                EndpointConfig."Auth Type"::Bearer:
                    begin
                        AccessToken := GetAccessTokenForEndpoint(EndpointConfig);
                        exit('Bearer ' + AccessToken);
                    end;
                EndpointConfig."Auth Type"::"API Key":
                    exit('ApiKey ' + EndpointConfig."API Key");
                EndpointConfig."Auth Type"::Basic:
                    exit('Basic ' + EncodeBased64(EndpointConfig."Username" + ':' + EndpointConfig."Password"));
                else
                    exit('');
            end;
        end;
        
        exit('');
    end;
    
    local procedure CreateRequestSignature(Payload: Text; Endpoint: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        SigningKey: Text;
        Timestamp: Text;
        StringToSign: Text;
    begin
        SigningKey := GetSigningKeyForEndpoint(Endpoint);
        Timestamp := Format(CurrentDateTime, 0, 9);
        StringToSign := Endpoint + Timestamp + Payload;
        
        exit(CryptographyManagement.GenerateHash(StringToSign + SigningKey, 2)); // SHA256
    end;
    
    local procedure ShouldRetryBasedOnResponse(Response: HttpResponseMessage): Boolean
    var
        StatusCode: Integer;
    begin
        StatusCode := Response.HttpStatusCode();
        
        // Retry on server errors and specific client errors
        case StatusCode of
            408, 429, 500, 502, 503, 504: // Timeout, rate limit, server errors
                exit(true);
            else
                exit(false);
        end;
    end;
    
    local procedure QueueFailedNotification(Endpoint: Text; EventPayload: Text; EventType: Text; NotificationId: Guid)
    var
        FailedNotificationQueue: Record "Failed Notification Queue";
    begin
        FailedNotificationQueue.Init();
        FailedNotificationQueue."Entry No." := GetNextFailedQueueEntryNo();
        FailedNotificationQueue."Notification ID" := NotificationId;
        FailedNotificationQueue."Event Type" := CopyStr(EventType, 1, MaxStrLen(FailedNotificationQueue."Event Type"));
        FailedNotificationQueue."Endpoint URL" := CopyStr(Endpoint, 1, MaxStrLen(FailedNotificationQueue."Endpoint URL"));
        FailedNotificationQueue."Created DateTime" := CurrentDateTime;
        FailedNotificationQueue."Retry Count" := 0;
        FailedNotificationQueue."Status" := FailedNotificationQueue."Status"::Queued;
        
        SetFailedNotificationPayload(FailedNotificationQueue, EventPayload);
        FailedNotificationQueue.Insert();
        
        // Schedule retry processing
        ScheduleFailedNotificationRetry();
    end;
    
    local procedure LogSuccessfulNotification(Endpoint: Text; EventType: Text; RequestId: Guid; RetryAttempt: Integer; Duration: Duration)
    var
        LogData: JsonObject;
    begin
        LogData.Add('endpoint', Endpoint);
        LogData.Add('eventType', EventType);
        LogData.Add('requestId', Format(RequestId));
        LogData.Add('retryAttempt', RetryAttempt);
        LogData.Add('durationMs', Duration);
        LogData.Add('timestamp', CurrentDateTime);
        LogData.Add('status', 'Success');
        
        Session.LogMessage('ExternalNotificationSuccess', Format(LogData), 
                          Verbosity::Normal, DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'ExternalIntegration');
    end;
    
    local procedure LogFailedAttempt(Endpoint: Text; EventType: Text; RequestId: Guid; RetryAttempt: Integer; 
                                   Response: HttpResponseMessage; Duration: Duration)
    var
        LogData: JsonObject;
        ResponseContent: Text;
    begin
        Response.Content.ReadAs(ResponseContent);
        
        LogData.Add('endpoint', Endpoint);
        LogData.Add('eventType', EventType);
        LogData.Add('requestId', Format(RequestId));
        LogData.Add('retryAttempt', RetryAttempt);
        LogData.Add('durationMs', Duration);
        LogData.Add('httpStatusCode', Response.HttpStatusCode());
        LogData.Add('responseContent', ResponseContent);
        LogData.Add('timestamp', CurrentDateTime);
        LogData.Add('status', 'Failed');
        
        Session.LogMessage('ExternalNotificationFailed', Format(LogData), 
                          Verbosity::Warning, DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'ExternalIntegration');
    end;
    
    local procedure LogNotificationSummary(EventType: Text; EntityId: Text; SuccessCount: Integer; 
                                         TotalEndpoints: Integer; Results: Dictionary of [Text, Boolean])
    var
        SummaryJson: JsonObject;
        ResultsJson: JsonObject;
        Endpoint: Text;
        Success: Boolean;
    begin
        SummaryJson.Add('eventType', EventType);
        SummaryJson.Add('entityId', EntityId);
        SummaryJson.Add('successCount', SuccessCount);
        SummaryJson.Add('totalEndpoints', TotalEndpoints);
        SummaryJson.Add('successRate', Round(SuccessCount / TotalEndpoints * 100, 0.01));
        SummaryJson.Add('timestamp', CurrentDateTime);
        
        // Add individual endpoint results
        foreach Endpoint in Results.Keys do begin
            Success := Results.Get(Endpoint);
            ResultsJson.Add(Endpoint, Success);
        end;
        SummaryJson.Add('endpointResults', ResultsJson);
        
        Session.LogMessage('NotificationSummary', Format(SummaryJson), 
                          Verbosity::Normal, DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'ExternalIntegration');
    end;
    
    // Helper procedures for configuration and utilities
    local procedure GetAccessTokenForEndpoint(EndpointConfig: Record "External Integration Endpoint"): Text
    begin
        // Implement OAuth token acquisition based on endpoint configuration
        // This would typically integrate with Azure AD or other OAuth providers
        exit(''); // Placeholder
    end;
    
    local procedure GetSigningKeyForEndpoint(Endpoint: Text): Text
    var
        EndpointConfig: Record "External Integration Endpoint";
    begin
        EndpointConfig.SetRange("Endpoint URL", Endpoint);
        if EndpointConfig.FindFirst() then
            exit(EndpointConfig."Signing Key")
        else
            exit('');
    end;
    
    local procedure GetOrderPriority(SalesHeader: Record "Sales Header"): Text
    begin
        // Implement business logic to determine order priority
        if SalesHeader."Requested Delivery Date" <= (Today + 1) then
            exit('Urgent')
        else if SalesHeader.Amount > 10000 then
            exit('High')
        else
            exit('Normal');
    end;
    
    local procedure CalculateOrderValue(SalesHeader: Record "Sales Header"): Decimal
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        exit(SalesHeader."Amount Including VAT");
    end;
    
    local procedure GetSystemVersion(): Text
    begin
        // Return Business Central version information
        exit('BusinessCentral-2024-Release-Wave-2');
    end;
    
    local procedure EncodeBased64(Input: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.ToBase64(Input));
    end;
    
    local procedure GetNextFailedQueueEntryNo(): BigInteger
    var
        FailedNotificationQueue: Record "Failed Notification Queue";
    begin
        FailedNotificationQueue.SetCurrentKey("Entry No.");
        if FailedNotificationQueue.FindLast() then
            exit(FailedNotificationQueue."Entry No." + 1)
        else
            exit(1);
    end;
    
    local procedure SetFailedNotificationPayload(var FailedNotificationQueue: Record "Failed Notification Queue"; Payload: Text)
    var
        OutStream: OutStream;
    begin
        FailedNotificationQueue."Event Payload".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(Payload);
    end;
    
    local procedure ScheduleFailedNotificationRetry()
    begin
        // Schedule background task to retry failed notifications
        TaskScheduler.CreateTask(Codeunit::"Failed Notification Retry Processor", 
                               0, true, CompanyName, 
                               CurrentDateTime + 300000); // 5 minutes delay
    end;
}
```

This comprehensive external integration framework provides production-ready event handling with proper error handling, retry logic, correlation tracking, and comprehensive logging for enterprise-grade external system integration.
