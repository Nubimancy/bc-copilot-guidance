---
title: "External System Integration Events"
description: "Patterns for integrating Business Central events with external systems via HTTP, webhooks, and message queues"
area: "integration"
difficulty: "advanced"
object_types: ["Codeunit"]
variable_types: ["HttpClient", "JsonObject"]
tags: ["integration", "events", "http", "webhooks", "external-systems", "api"]
---

# External System Integration Events

## HTTP-Based External Notifications

### Synchronous External System Notification

Send immediate notifications to external systems when business events occur.

```al
codeunit 50300 "External System Notifier"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Registration", 'OnAfterCustomerRegistration', '', false, false)]
    local procedure NotifyExternalSystemOfNewCustomer(var Customer: Record Customer)
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        EventPayload: Text;
        IsSuccess: Boolean;
    begin
        EventPayload := CreateCustomerEventPayload(Customer);
        
        // Configure HTTP request
        HttpContent.WriteFrom(EventPayload);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        HttpHeaders.Add('Authorization', GetAuthorizationHeader());
        
        // Send notification with retry logic
        IsSuccess := TrySendNotificationWithRetry(HttpClient, EventPayload, Response);
        
        if IsSuccess then
            LogSuccessfulNotification('CustomerCreated', Customer."No.")
        else
            HandleNotificationFailure('CustomerCreated', Customer."No.", Response);
    end;
    
    local procedure CreateCustomerEventPayload(Customer: Record Customer): Text
    var
        EventJson: JsonObject;
        CustomerJson: JsonObject;
    begin
        // Build customer data
        CustomerJson.Add('customerNo', Customer."No.");
        CustomerJson.Add('name', Customer.Name);
        CustomerJson.Add('email', Customer."E-Mail");
        CustomerJson.Add('phoneNo', Customer."Phone No.");
        CustomerJson.Add('address', Customer.Address);
        CustomerJson.Add('city', Customer.City);
        CustomerJson.Add('postCode', Customer."Post Code");
        CustomerJson.Add('countryCode', Customer."Country/Region Code");
        
        // Build event envelope
        EventJson.Add('eventType', 'CustomerCreated');
        EventJson.Add('eventId', CreateGuid());
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('source', 'BusinessCentral');
        EventJson.Add('version', '1.0');
        EventJson.Add('data', CustomerJson);
        
        exit(Format(EventJson));
    end;
    
    local procedure TrySendNotificationWithRetry(var HttpClient: HttpClient; EventPayload: Text; var Response: HttpResponseMessage): Boolean
    var
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        RetryCount: Integer;
        MaxRetries: Integer;
        RetryDelay: Integer;
        IsSuccess: Boolean;
    begin
        MaxRetries := 3;
        RetryDelay := 1000; // 1 second
        
        for RetryCount := 1 to MaxRetries do begin
            HttpContent.WriteFrom(EventPayload);
            HttpContent.GetHeaders(HttpHeaders);
            HttpHeaders.Clear();
            HttpHeaders.Add('Content-Type', 'application/json');
            HttpHeaders.Add('Authorization', GetAuthorizationHeader());
            
            IsSuccess := HttpClient.Post(GetExternalSystemEndpoint(), HttpContent, Response);
            
            if IsSuccess and Response.IsSuccessStatusCode() then
                exit(true)
            else if RetryCount < MaxRetries then begin
                Sleep(RetryDelay);
                RetryDelay := RetryDelay * 2; // Exponential backoff
            end;
        end;
        
        exit(false);
    end;
}
```

### Asynchronous External Notifications

Queue external notifications for reliable delivery without blocking business processes.

```al
codeunit 50301 "Async External Notifier"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Management", 'OnAfterOrderStatusChange', '', false, false)]
    local procedure QueueOrderStatusNotification(var SalesHeader: Record "Sales Header"; OldStatus: Enum "Sales Document Status")
    var
        NotificationQueue: Record "External Notification Queue";
        EventPayload: Text;
    begin
        EventPayload := CreateOrderStatusEventPayload(SalesHeader, OldStatus);
        QueueExternalNotification('OrderStatusChanged', EventPayload, GetNotificationPriority(SalesHeader));
    end;
    
    local procedure QueueExternalNotification(EventType: Text; EventPayload: Text; Priority: Integer)
    var
        NotificationQueue: Record "External Notification Queue";
        EntryNo: BigInteger;
    begin
        EntryNo := GetNextQueueEntryNumber();
        
        NotificationQueue.Init();
        NotificationQueue."Entry No." := EntryNo;
        NotificationQueue."Event Type" := CopyStr(EventType, 1, MaxStrLen(NotificationQueue."Event Type"));
        NotificationQueue."Priority" := Priority;
        NotificationQueue."Created DateTime" := CurrentDateTime;
        NotificationQueue."Status" := NotificationQueue.Status::Pending;
        NotificationQueue."Retry Count" := 0;
        
        // Store payload
        SetNotificationPayload(NotificationQueue, EventPayload);
        NotificationQueue.Insert();
        
        // Schedule background processing
        ScheduleNotificationProcessing();
    end;
    
    procedure ProcessNotificationQueue()
    var
        NotificationQueue: Record "External Notification Queue";
        ProcessedCount: Integer;
        FailedCount: Integer;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        
        // Process pending notifications in priority order
        NotificationQueue.SetRange(Status, NotificationQueue.Status::Pending);
        NotificationQueue.SetCurrentKey(Priority, "Created DateTime");
        NotificationQueue.SetAscending(Priority, false); // High priority first
        
        if NotificationQueue.FindSet() then
            repeat
                if ProcessSingleNotification(NotificationQueue) then
                    ProcessedCount += 1
                else
                    FailedCount += 1;
            until NotificationQueue.Next() = 0;
        
        LogProcessingResults(ProcessedCount, FailedCount, CurrentDateTime - StartTime);
    end;
    
    local procedure ProcessSingleNotification(var NotificationQueue: Record "External Notification Queue"): Boolean
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        EventPayload: Text;
        IsSuccess: Boolean;
    begin
        // Mark as processing
        NotificationQueue.Status := NotificationQueue.Status::Processing;
        NotificationQueue."Processing Started" := CurrentDateTime;
        NotificationQueue.Modify();
        Commit();
        
        EventPayload := GetNotificationPayload(NotificationQueue);
        IsSuccess := TrySendExternalNotification(HttpClient, EventPayload, Response);
        
        if IsSuccess then begin
            // Mark as completed
            NotificationQueue.Status := NotificationQueue.Status::Completed;
            NotificationQueue."Completed DateTime" := CurrentDateTime;
            NotificationQueue.Modify();
        end else begin
            HandleNotificationQueueFailure(NotificationQueue, Response);
        end;
        
        Commit();
        exit(IsSuccess);
    end;
    
    local procedure HandleNotificationQueueFailure(var NotificationQueue: Record "External Notification Queue"; Response: HttpResponseMessage)
    var
        ErrorMessage: Text;
        ResponseContent: Text;
    begin
        if Response.IsSuccessStatusCode() then
            exit; // Not actually a failure
            
        Response.Content.ReadAs(ResponseContent);
        ErrorMessage := StrSubstNo('HTTP %1: %2', Response.HttpStatusCode(), ResponseContent);
        
        NotificationQueue."Retry Count" += 1;
        NotificationQueue."Last Error" := CopyStr(ErrorMessage, 1, MaxStrLen(NotificationQueue."Last Error"));
        NotificationQueue."Last Retry DateTime" := CurrentDateTime;
        
        if NotificationQueue."Retry Count" < GetMaxRetries(NotificationQueue."Event Type") then begin
            // Schedule retry
            NotificationQueue.Status := NotificationQueue.Status::Pending;
            NotificationQueue."Next Retry DateTime" := CalculateNextRetryTime(NotificationQueue."Retry Count");
        end else begin
            // Max retries exceeded
            NotificationQueue.Status := NotificationQueue.Status::Failed;
            NotificationQueue."Completed DateTime" := CurrentDateTime;
            
            LogCriticalNotificationFailure(NotificationQueue, ErrorMessage);
        end;
        
        NotificationQueue.Modify();
    end;
}
```

## Webhook Integration Patterns

### Outbound Webhook Management

Manage webhook subscriptions and ensure reliable delivery to external systems.

```al
codeunit 50302 "Webhook Event Publisher"
{
    procedure RegisterWebhook(EventType: Text; CallbackUrl: Text; SecretKey: Text): Text
    var
        WebhookSubscription: Record "Webhook Subscription";
        SubscriptionId: Guid;
    begin
        SubscriptionId := CreateGuid();
        
        WebhookSubscription.Init();
        WebhookSubscription."Subscription ID" := SubscriptionId;
        WebhookSubscription."Event Type" := CopyStr(EventType, 1, MaxStrLen(WebhookSubscription."Event Type"));
        WebhookSubscription."Callback URL" := CopyStr(CallbackUrl, 1, MaxStrLen(WebhookSubscription."Callback URL"));
        WebhookSubscription."Secret Key" := CopyStr(SecretKey, 1, MaxStrLen(WebhookSubscription."Secret Key"));
        WebhookSubscription."Created DateTime" := CurrentDateTime;
        WebhookSubscription.Active := true;
        WebhookSubscription.Insert();
        
        exit(Format(SubscriptionId));
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Management", 'OnAfterInventoryAdjustment', '', false, false)]
    local procedure PublishInventoryWebhook(var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        WebhookSubscription: Record "Webhook Subscription";
        EventPayload: Text;
    begin
        // Find active webhook subscriptions for this event type
        WebhookSubscription.SetRange("Event Type", 'InventoryAdjustment');
        WebhookSubscription.SetRange(Active, true);
        
        if WebhookSubscription.FindSet() then begin
            EventPayload := CreateInventoryEventPayload(ItemLedgerEntry);
            
            repeat
                DeliverWebhook(WebhookSubscription, EventPayload);
            until WebhookSubscription.Next() = 0;
        end;
    end;
    
    local procedure DeliverWebhook(WebhookSubscription: Record "Webhook Subscription"; EventPayload: Text)
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        Signature: Text;
        IsDelivered: Boolean;
    begin
        // Create webhook signature for security
        Signature := CreateWebhookSignature(EventPayload, WebhookSubscription."Secret Key");
        
        // Configure HTTP request
        HttpContent.WriteFrom(EventPayload);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        HttpHeaders.Add('X-Webhook-Signature', Signature);
        HttpHeaders.Add('X-Webhook-Delivery', CreateGuid());
        HttpHeaders.Add('User-Agent', 'BusinessCentral-Webhook/1.0');
        
        IsDelivered := HttpClient.Post(WebhookSubscription."Callback URL", HttpContent, Response);
        
        // Log webhook delivery
        LogWebhookDelivery(WebhookSubscription."Subscription ID", IsDelivered, Response);
        
        // Update subscription statistics
        UpdateWebhookStatistics(WebhookSubscription, IsDelivered);
    end;
    
    local procedure CreateWebhookSignature(Payload: Text; SecretKey: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        Signature: Text;
    begin
        Signature := CryptographyManagement.GenerateHash(Payload + SecretKey, 2); // SHA256
        exit('sha256=' + Signature);
    end;
    
    local procedure CreateInventoryEventPayload(ItemLedgerEntry: Record "Item Ledger Entry"): Text
    var
        EventJson: JsonObject;
        ItemJson: JsonObject;
    begin
        // Build item data
        ItemJson.Add('itemNo', ItemLedgerEntry."Item No.");
        ItemJson.Add('description', ItemLedgerEntry.Description);
        ItemJson.Add('quantity', ItemLedgerEntry.Quantity);
        ItemJson.Add('remainingQuantity', ItemLedgerEntry."Remaining Quantity");
        ItemJson.Add('unitCost', ItemLedgerEntry."Cost Amount (Actual)");
        ItemJson.Add('locationCode', ItemLedgerEntry."Location Code");
        ItemJson.Add('postingDate', ItemLedgerEntry."Posting Date");
        
        // Build event envelope
        EventJson.Add('eventType', 'InventoryAdjustment');
        EventJson.Add('eventId', CreateGuid());
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('source', 'BusinessCentral');
        EventJson.Add('version', '1.0');
        EventJson.Add('data', ItemJson);
        
        exit(Format(EventJson));
    end;
}
```

## Message Queue Integration

### Service Bus Event Publishing

Publish events to Azure Service Bus for enterprise message processing.

```al
codeunit 50303 "Service Bus Event Publisher"
{
    var
        ServiceBusConnectionString: Text;
        ServiceBusQueueName: Text;
        
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Processing", 'OnAfterPaymentPosted', '', false, false)]
    local procedure PublishPaymentEvent(var GenJournalLine: Record "Gen. Journal Line")
    var
        EventMessage: Text;
        MessageProperties: Dictionary of [Text, Text];
    begin
        EventMessage := CreatePaymentEventMessage(GenJournalLine);
        
        // Add message properties for routing
        MessageProperties.Set('EventType', 'PaymentPosted');
        MessageProperties.Set('CustomerNo', GenJournalLine."Account No.");
        MessageProperties.Set('Amount', Format(GenJournalLine.Amount));
        MessageProperties.Set('Currency', GenJournalLine."Currency Code");
        
        PublishToServiceBus(EventMessage, MessageProperties);
    end;
    
    local procedure PublishToServiceBus(EventMessage: Text; MessageProperties: Dictionary of [Text, Text])
    var
        ServiceBusClient: Codeunit "Service Bus Message Sender";
        IsPublished: Boolean;
        RetryCount: Integer;
        MaxRetries: Integer;
    begin
        MaxRetries := 3;
        
        for RetryCount := 1 to MaxRetries do begin
            IsPublished := TryPublishToServiceBus(ServiceBusClient, EventMessage, MessageProperties);
            
            if IsPublished then begin
                LogSuccessfulPublish(EventMessage);
                exit;
            end else if RetryCount < MaxRetries then
                Sleep(RetryCount * 1000); // Exponential backoff
        end;
        
        // Failed after retries - queue for later processing
        QueueFailedMessage(EventMessage, MessageProperties);
    end;
    
    [TryFunction]
    local procedure TryPublishToServiceBus(ServiceBusClient: Codeunit "Service Bus Message Sender"; 
                                         EventMessage: Text; 
                                         MessageProperties: Dictionary of [Text, Text])
    var
        MessageId: Text;
    begin
        MessageId := ServiceBusClient.SendMessage(
            GetServiceBusConnectionString(),
            GetServiceBusQueueName(),
            EventMessage,
            MessageProperties
        );
        
        if MessageId = '' then
            Error('Failed to get message ID from Service Bus');
    end;
    
    local procedure CreatePaymentEventMessage(GenJournalLine: Record "Gen. Journal Line"): Text
    var
        EventJson: JsonObject;
        PaymentJson: JsonObject;
        Customer: Record Customer;
    begin
        // Load customer data
        if Customer.Get(GenJournalLine."Account No.") then begin
            PaymentJson.Add('customerNo', Customer."No.");
            PaymentJson.Add('customerName', Customer.Name);
        end;
        
        // Build payment data
        PaymentJson.Add('documentNo', GenJournalLine."Document No.");
        PaymentJson.Add('amount', GenJournalLine.Amount);
        PaymentJson.Add('currencyCode', GenJournalLine."Currency Code");
        PaymentJson.Add('postingDate', GenJournalLine."Posting Date");
        PaymentJson.Add('description', GenJournalLine.Description);
        PaymentJson.Add('externalDocumentNo', GenJournalLine."External Document No.");
        
        // Build event envelope
        EventJson.Add('eventType', 'PaymentPosted');
        EventJson.Add('eventId', CreateGuid());
        EventJson.Add('timestamp', CurrentDateTime);
        EventJson.Add('source', 'BusinessCentral');
        EventJson.Add('correlationId', CreateGuid());
        EventJson.Add('version', '1.0');
        EventJson.Add('data', PaymentJson);
        
        exit(Format(EventJson));
    end;
}
```

## Event Security and Authentication

### Secure External Integration

Implement proper authentication and encryption for external system integration.

```al
codeunit 50304 "Secure External Integration"
{
    local procedure GetAuthorizationHeader(): Text
    var
        AccessToken: Text;
        TokenType: Text;
    begin
        AccessToken := GetOAuthAccessToken();
        TokenType := 'Bearer';
        
        exit(StrSubstNo('%1 %2', TokenType, AccessToken));
    end;
    
    local procedure GetOAuthAccessToken(): Text
    var
        OAuth2: Codeunit OAuth2;
        AccessToken: Text;
        ClientId: Text;
        ClientSecret: Text;
        TokenEndpoint: Text;
        Scopes: Text;
    begin
        ClientId := GetClientId();
        ClientSecret := GetClientSecret();
        TokenEndpoint := GetTokenEndpoint();
        Scopes := GetRequiredScopes();
        
        if OAuth2.AcquireTokenByCredentials(ClientId, ClientSecret, TokenEndpoint, Scopes, AccessToken) then
            exit(AccessToken)
        else
            Error('Failed to acquire OAuth access token');
    end;
    
    local procedure EncryptSensitiveData(PlainText: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        EncryptedText: Text;
    begin
        if CryptographyManagement.IsEncryptionEnabled() then
            EncryptedText := CryptographyManagement.Encrypt(PlainText)
        else
            EncryptedText := PlainText;
            
        exit(EncryptedText);
    end;
    
    local procedure ValidateWebhookSignature(Payload: Text; Signature: Text; SecretKey: Text): Boolean
    var
        ExpectedSignature: Text;
    begin
        ExpectedSignature := CreateWebhookSignature(Payload, SecretKey);
        exit(Signature = ExpectedSignature);
    end;
}
```

External system integration through events enables Business Central to participate in enterprise workflows while maintaining loose coupling and high reliability.
