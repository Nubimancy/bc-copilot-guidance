---
title: "BC API Synchronization Implementation Samples"
description: "Working AL implementations for Business Central API synchronization with external systems using web services, OData APIs, and integration events"
area: "integration"
difficulty: "advanced"
object_types: ["Codeunit", "Table", "Page", "XMLport"]
variable_types: ["JsonObject", "HttpClient", "DateTime", "Boolean", "RecordRef"]
tags: ["bc-api", "web-services", "odata", "integration-events", "external-sync"]
---

# BC API Synchronization Implementation Samples

## Custom API Page Design

### Customer API for External Integration

```al
// Custom API page for customer synchronization
page 50300 "Customer API"
{
    APIVersion = 'v2.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    PageType = API;
    SourceTable = Customer;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                
                field(number; Rec."No.")
                {
                    Caption = 'Number';
                }
                
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                
                field(type; Rec."Customer Type")
                {
                    Caption = 'Type';
                }
                
                field(addressLine1; Rec.Address)
                {
                    Caption = 'Address Line 1';
                }
                
                field(addressLine2; Rec."Address 2")
                {
                    Caption = 'Address Line 2';
                }
                
                field(city; Rec.City)
                {
                    Caption = 'City';
                }
                
                field(state; Rec.County)
                {
                    Caption = 'State';
                }
                
                field(country; Rec."Country/Region Code")
                {
                    Caption = 'Country';
                }
                
                field(postalCode; Rec."Post Code")
                {
                    Caption = 'Postal Code';
                }
                
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone Number';
                }
                
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email';
                }
                
                field(website; Rec."Home Page")
                {
                    Caption = 'Website';
                }
                
                field(taxRegistrationNumber; Rec."VAT Registration No.")
                {
                    Caption = 'Tax Registration Number';
                }
                
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                
                field(paymentTermsId; Rec."Payment Terms Code")
                {
                    Caption = 'Payment Terms';
                }
                
                field(shipmentMethodId; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method';
                }
                
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    Editable = false;
                }
                
                // External system fields
                field(externalId; Rec."External System ID")
                {
                    Caption = 'External System ID';
                }
                
                field(lastSyncDateTime; Rec."Last Sync DateTime")
                {
                    Caption = 'Last Sync Date Time';
                    Editable = false;
                }
            }
        }
    }
    
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        CustomerApiMgt: Codeunit "Customer API Management";
    begin
        CustomerApiMgt.ProcessApiInsert(Rec);
    end;
    
    trigger OnModifyRecord(): Boolean
    var
        CustomerApiMgt: Codeunit "Customer API Management";
    begin
        CustomerApiMgt.ProcessApiModify(Rec);
    end;
    
    trigger OnDeleteRecord(): Boolean
    var
        CustomerApiMgt: Codeunit "Customer API Management";
    begin
        CustomerApiMgt.ProcessApiDelete(Rec);
    end;
}

// Table extension for external system integration
tableextension 50300 "Customer External Integration" extends Customer
{
    fields
    {
        field(50300; "External System ID"; Text[50])
        {
            Caption = 'External System ID';
            DataClassification = CustomerContent;
        }
        
        field(50301; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync Date Time';
            DataClassification = SystemMetadata;
        }
        
        field(50302; "Sync Status"; Enum "Integration Sync Status")
        {
            Caption = 'Sync Status';
            DataClassification = SystemMetadata;
        }
        
        field(50303; "Customer Type"; Enum "Customer Type API")
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
        }
    }
}

// Enums for API consistency
enum 50300 "Integration Sync Status"
{
    Extensible = true;
    
    value(0; "Not Synced")
    {
        Caption = 'Not Synced';
    }
    
    value(1; "Synced")
    {
        Caption = 'Synced';
    }
    
    value(2; "Sync Pending")
    {
        Caption = 'Sync Pending';
    }
    
    value(3; "Sync Error")
    {
        Caption = 'Sync Error';
    }
}

enum 50301 "Customer Type API"
{
    Extensible = true;
    
    value(0; "Company")
    {
        Caption = 'Company';
    }
    
    value(1; "Person")
    {
        Caption = 'Person';
    }
}
```

## Web Service Integration Patterns

### HTTP Client Integration with External APIs

```al
// Codeunit for external system synchronization
codeunit 50300 "External System Integration"
{
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        
    procedure SynchronizeCustomer(var Customer: Record Customer): Boolean
    var
        CustomerJson: JsonObject;
        ResponseJson: JsonObject;
        ApiUrl: Text;
        AuthToken: Text;
    begin
        // Prepare customer data for external system
        CustomerJson := BuildCustomerJson(Customer);
        
        // Get API configuration
        ApiUrl := GetExternalApiUrl();
        AuthToken := GetAuthenticationToken();
        
        // Perform synchronization
        if Customer."External System ID" = '' then
            exit(CreateCustomerInExternalSystem(CustomerJson, Customer))
        else
            exit(UpdateCustomerInExternalSystem(CustomerJson, Customer));
    end;
    
    local procedure BuildCustomerJson(Customer: Record Customer): JsonObject
    var
        CustomerJson: JsonObject;
    begin
        // Use SetLoadFields for performance
        Customer.SetLoadFields("No.", Name, Address, City, "Post Code", 
                              "Country/Region Code", "Phone No.", "E-Mail",
                              "VAT Registration No.", "Currency Code");
        
        CustomerJson.Add('number', Customer."No.");
        CustomerJson.Add('name', Customer.Name);
        CustomerJson.Add('address', Customer.Address);
        CustomerJson.Add('city', Customer.City);
        CustomerJson.Add('postalCode', Customer."Post Code");
        CustomerJson.Add('country', Customer."Country/Region Code");
        CustomerJson.Add('phone', Customer."Phone No.");
        CustomerJson.Add('email', Customer."E-Mail");
        CustomerJson.Add('vatNumber', Customer."VAT Registration No.");
        CustomerJson.Add('currency', Customer."Currency Code");
        CustomerJson.Add('lastModified', Customer.SystemModifiedAt);
        
        exit(CustomerJson);
    end;
    
    local procedure CreateCustomerInExternalSystem(CustomerJson: JsonObject; var Customer: Record Customer): Boolean
    var
        RequestBody: Text;
        ResponseBody: Text;
        ResponseJson: JsonObject;
        ExternalId: Text;
        ApiUrl: Text;
    begin
        ApiUrl := GetExternalApiUrl() + '/customers';
        CustomerJson.WriteTo(RequestBody);
        
        // Setup HTTP request
        SetupHttpHeaders();
        HttpRequestMessage.SetRequestUri(ApiUrl);
        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.Content.WriteFrom(RequestBody);
        
        // Send request with retry logic
        if not SendHttpRequestWithRetry() then
            exit(false);
            
        // Process response
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseJson.ReadFrom(ResponseBody) then begin
            if GetJsonValue(ResponseJson, 'id', ExternalId) then begin
                Customer."External System ID" := ExternalId;
                Customer."Last Sync DateTime" := CurrentDateTime;
                Customer."Sync Status" := Customer."Sync Status"::Synced;
                Customer.Modify(true);
                exit(true);
            end;
        end;
        
        Customer."Sync Status" := Customer."Sync Status"::"Sync Error";
        Customer.Modify(true);
        exit(false);
    end;
    
    local procedure UpdateCustomerInExternalSystem(CustomerJson: JsonObject; var Customer: Record Customer): Boolean
    var
        RequestBody: Text;
        ApiUrl: Text;
    begin
        ApiUrl := GetExternalApiUrl() + '/customers/' + Customer."External System ID";
        CustomerJson.WriteTo(RequestBody);
        
        // Setup HTTP request
        SetupHttpHeaders();
        HttpRequestMessage.SetRequestUri(ApiUrl);
        HttpRequestMessage.Method := 'PUT';
        HttpRequestMessage.Content.WriteFrom(RequestBody);
        
        // Send request with retry logic
        if SendHttpRequestWithRetry() then begin
            Customer."Last Sync DateTime" := CurrentDateTime;
            Customer."Sync Status" := Customer."Sync Status"::Synced;
            Customer.Modify(true);
            exit(true);
        end;
        
        Customer."Sync Status" := Customer."Sync Status"::"Sync Error";
        Customer.Modify(true);
        exit(false);
    end;
    
    local procedure SendHttpRequestWithRetry(): Boolean
    var
        RetryCount: Integer;
        MaxRetries: Integer;
        DelayMilliseconds: Integer;
        Success: Boolean;
    begin
        MaxRetries := 3;
        DelayMilliseconds := 1000;
        
        for RetryCount := 1 to MaxRetries do begin
            Clear(HttpResponseMessage);
            
            if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
                if HttpResponseMessage.IsSuccessStatusCode then
                    exit(true);
                    
                // Log error and retry for server errors
                if HttpResponseMessage.HttpStatusCode >= 500 then begin
                    LogHttpError(HttpResponseMessage, RetryCount);
                    if RetryCount < MaxRetries then
                        Sleep(DelayMilliseconds * RetryCount);
                end else
                    exit(false); // Don't retry for client errors
            end else begin
                LogHttpError(HttpResponseMessage, RetryCount);
                if RetryCount < MaxRetries then
                    Sleep(DelayMilliseconds * RetryCount);
            end;
        end;
        
        exit(false);
    end;
    
    local procedure SetupHttpHeaders()
    var
        Headers: HttpHeaders;
        AuthToken: Text;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Headers.Add('Accept', 'application/json');
        
        AuthToken := GetAuthenticationToken();
        if AuthToken <> '' then
            Headers.Add('Authorization', 'Bearer ' + AuthToken);
    end;
    
    local procedure GetExternalApiUrl(): Text
    var
        IntegrationSetup: Record "Integration Setup";
    begin
        IntegrationSetup.Get();
        exit(IntegrationSetup."External API Base URL");
    end;
    
    local procedure GetAuthenticationToken(): Text
    var
        IntegrationSetup: Record "Integration Setup";
        OAuth2: Codeunit OAuth2;
        AccessToken: Text;
    begin
        IntegrationSetup.Get();
        
        // Use BC OAuth2 helper for token management
        OAuth2.AcquireTokenByAuthorizationCode(
            IntegrationSetup."Client ID",
            IntegrationSetup."Client Secret",
            IntegrationSetup."Authority URL",
            IntegrationSetup."Redirect URL",
            IntegrationSetup."Resource URL",
            '', // Authorization code from setup
            AccessToken);
            
        exit(AccessToken);
    end;
    
    local procedure GetJsonValue(JsonObj: JsonObject; PropertyName: Text; var Value: Text): Boolean
    var
        JsonToken: JsonToken;
    begin
        if JsonObj.Get(PropertyName, JsonToken) then begin
            Value := JsonToken.AsValue().AsText();
            exit(true);
        end;
        exit(false);
    end;
    
    local procedure LogHttpError(HttpResponse: HttpResponseMessage; RetryAttempt: Integer)
    var
        ErrorText: Text;
    begin
        ErrorText := StrSubstNo('HTTP Error: Status %1, Retry %2', 
                               HttpResponse.HttpStatusCode, 
                               RetryAttempt);
        
        // Log to BC Application Insights
        Session.LogMessage('EXT001', ErrorText, Verbosity::Warning, 
                          DataClassification::SystemMetadata, 
                          TelemetryScope::ExtensionPublisher, 
                          'Category', 'External Integration');
    end;
}
```

## Integration Events and Business Events

### Customer Business Event Implementation

```al
// Business event for customer changes
codeunit 50301 "Customer Integration Events"
{
    [BusinessEvent(true)]
    procedure OnCustomerCreated(Customer: Record Customer)
    begin
    end;
    
    [BusinessEvent(true)]
    procedure OnCustomerModified(Customer: Record Customer; xCustomer: Record Customer)
    begin
    end;
    
    [BusinessEvent(true)]
    procedure OnCustomerDeleted(CustomerNo: Code[20])
    begin
    end;
    
    [IntegrationEvent(false, false)]
    procedure OnBeforeCustomerSync(var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;
    
    [IntegrationEvent(false, false)]
    procedure OnAfterCustomerSync(Customer: Record Customer; SyncResult: Boolean)
    begin
    end;
}

// Event subscriber for external system notification
codeunit 50302 "Customer Sync Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Integration Events", 'OnCustomerCreated', '', false, false)]
    local procedure HandleCustomerCreated(Customer: Record Customer)
    var
        SyncJob: Record "Integration Sync Job";
    begin
        // Create async job for external sync
        CreateSyncJob(SyncJob, Customer.SystemId, SyncJob."Operation Type"::Create);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Integration Events", 'OnCustomerModified', '', false, false)]
    local procedure HandleCustomerModified(Customer: Record Customer; xCustomer: Record Customer)
    var
        SyncJob: Record "Integration Sync Job";
    begin
        // Only sync if relevant fields changed
        if RelevantFieldsChanged(Customer, xCustomer) then
            CreateSyncJob(SyncJob, Customer.SystemId, SyncJob."Operation Type"::Update);
    end;
    
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterCustomerInsert(var Rec: Record Customer; RunTrigger: Boolean)
    var
        CustomerIntegrationEvents: Codeunit "Customer Integration Events";
    begin
        if not Rec.IsTemporary then
            CustomerIntegrationEvents.OnCustomerCreated(Rec);
    end;
    
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterCustomerModify(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    var
        CustomerIntegrationEvents: Codeunit "Customer Integration Events";
    begin
        if not Rec.IsTemporary then
            CustomerIntegrationEvents.OnCustomerModified(Rec, xRec);
    end;
    
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterCustomerDelete(var Rec: Record Customer; RunTrigger: Boolean)
    var
        CustomerIntegrationEvents: Codeunit "Customer Integration Events";
    begin
        if not Rec.IsTemporary then
            CustomerIntegrationEvents.OnCustomerDeleted(Rec."No.");
    end;
    
    local procedure CreateSyncJob(var SyncJob: Record "Integration Sync Job"; RecordSystemId: Guid; OperationType: Enum "Sync Operation Type")
    begin
        SyncJob.Init();
        SyncJob."Entry No." := 0; // Auto-increment
        SyncJob."Table ID" := Database::Customer;
        SyncJob."Record System ID" := RecordSystemId;
        SyncJob."Operation Type" := OperationType;
        SyncJob.Status := SyncJob.Status::Pending;
        SyncJob."Created DateTime" := CurrentDateTime;
        SyncJob.Insert(true);
        
        // Schedule job queue entry
        ScheduleSyncJobQueue();
    end;
    
    local procedure RelevantFieldsChanged(Customer: Record Customer; xCustomer: Record Customer): Boolean
    begin
        exit((Customer.Name <> xCustomer.Name) or
             (Customer.Address <> xCustomer.Address) or
             (Customer.City <> xCustomer.City) or
             (Customer."Post Code" <> xCustomer."Post Code") or
             (Customer."Phone No." <> xCustomer."Phone No.") or
             (Customer."E-Mail" <> xCustomer."E-Mail") or
             (Customer.Blocked <> xCustomer.Blocked));
    end;
    
    local procedure ScheduleSyncJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "Job Queue Management";
    begin
        // Check if sync job queue already exists and is running
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Sync Processor");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
        
        if JobQueueEntry.IsEmpty then begin
            // Create new job queue entry
            JobQueueMgt.CreateJobQueueEntry(JobQueueEntry);
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := Codeunit::"Integration Sync Processor";
            JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime;
            JobQueueEntry."Run on Mondays" := true;
            JobQueueEntry."Run on Tuesdays" := true;
            JobQueueEntry."Run on Wednesdays" := true;
            JobQueueEntry."Run on Thursdays" := true;
            JobQueueEntry."Run on Fridays" := true;
            JobQueueEntry."Run on Saturdays" := true;
            JobQueueEntry."Run on Sundays" := true;
            JobQueueEntry.Modify(true);
        end;
    end;
}
```

## Job Queue Synchronization Implementation

### Batch Sync Processing with Job Queue

```al
// Job queue processor for integration synchronization
codeunit 50303 "Integration Sync Processor"
{
    TableNo = "Job Queue Entry";
    
    trigger OnRun()
    begin
        ProcessPendingSyncJobs();
    end;
    
    local procedure ProcessPendingSyncJobs()
    var
        SyncJob: Record "Integration Sync Job";
        ExternalIntegration: Codeunit "External System Integration";
        Customer: Record Customer;
        ProcessedCount: Integer;
        MaxBatchSize: Integer;
    begin
        MaxBatchSize := 50; // Process in batches
        ProcessedCount := 0;
        
        SyncJob.SetRange(Status, SyncJob.Status::Pending);
        SyncJob.SetCurrentKey("Created DateTime");
        SyncJob.SetAscending("Created DateTime", true);
        
        if SyncJob.FindSet(true) then
            repeat
                if ProcessedCount >= MaxBatchSize then
                    break;
                    
                SyncJob.Status := SyncJob.Status::"In Progress";
                SyncJob."Started DateTime" := CurrentDateTime;
                SyncJob.Modify(true);
                Commit(); // Release lock
                
                case SyncJob."Table ID" of
                    Database::Customer:
                        ProcessCustomerSync(SyncJob);
                    // Add other tables as needed
                end;
                
                ProcessedCount += 1;
            until SyncJob.Next() = 0;
            
        // Log processing summary
        if ProcessedCount > 0 then
            Session.LogMessage('SYNC001', 
                             StrSubstNo('Processed %1 sync jobs', ProcessedCount),
                             Verbosity::Normal, 
                             DataClassification::SystemMetadata, 
                             TelemetryScope::ExtensionPublisher, 
                             'Category', 'Integration Sync');
    end;
    
    local procedure ProcessCustomerSync(var SyncJob: Record "Integration Sync Job")
    var
        Customer: Record Customer;
        ExternalIntegration: Codeunit "External System Integration";
        SyncResult: Boolean;
    begin
        if not Customer.GetBySystemId(SyncJob."Record System ID") then begin
            // Record might be deleted
            if SyncJob."Operation Type" = SyncJob."Operation Type"::Delete then
                SyncResult := ProcessCustomerDeletion(SyncJob)
            else begin
                SyncJob.Status := SyncJob.Status::Error;
                SyncJob."Error Message" := 'Customer record not found';
            end;
        end else begin
            case SyncJob."Operation Type" of
                SyncJob."Operation Type"::Create,
                SyncJob."Operation Type"::Update:
                    SyncResult := ExternalIntegration.SynchronizeCustomer(Customer);
                SyncJob."Operation Type"::Delete:
                    SyncResult := ProcessCustomerDeletion(SyncJob);
            end;
        end;
        
        // Update sync job status
        if SyncResult then begin
            SyncJob.Status := SyncJob.Status::Completed;
            SyncJob."Completed DateTime" := CurrentDateTime;
        end else begin
            SyncJob.Status := SyncJob.Status::Error;
            SyncJob."Retry Count" += 1;
            
            // Schedule retry if under limit
            if SyncJob."Retry Count" < 3 then begin
                SyncJob.Status := SyncJob.Status::Pending;
                SyncJob."Next Retry DateTime" := CurrentDateTime + (60000 * SyncJob."Retry Count"); // Exponential backoff
            end;
        end;
        
        SyncJob.Modify(true);
    end;
    
    local procedure ProcessCustomerDeletion(var SyncJob: Record "Integration Sync Job"): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ApiUrl: Text;
        ExternalId: Text;
    begin
        // Get external ID from sync job parameter
        ExternalId := SyncJob."External Record ID";
        if ExternalId = '' then
            exit(false);
            
        ApiUrl := GetExternalApiUrl() + '/customers/' + ExternalId;
        
        HttpRequestMessage.SetRequestUri(ApiUrl);
        HttpRequestMessage.Method := 'DELETE';
        SetupHttpHeaders(HttpRequestMessage);
        
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            exit(HttpResponseMessage.IsSuccessStatusCode);
            
        exit(false);
    end;
    
    local procedure GetExternalApiUrl(): Text
    var
        IntegrationSetup: Record "Integration Setup";
    begin
        IntegrationSetup.Get();
        exit(IntegrationSetup."External API Base URL");
    end;
    
    local procedure SetupHttpHeaders(var HttpRequestMessage: HttpRequestMessage)
    var
        Headers: HttpHeaders;
        AuthToken: Text;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        
        AuthToken := GetAuthenticationToken();
        if AuthToken <> '' then
            Headers.Add('Authorization', 'Bearer ' + AuthToken);
    end;
    
    local procedure GetAuthenticationToken(): Text
    var
        IntegrationSetup: Record "Integration Setup";
    begin
        IntegrationSetup.Get();
        // Implement token acquisition logic
        exit(IntegrationSetup."Access Token");
    end;
}

// Table for tracking sync jobs
table 50300 "Integration Sync Job"
{
    Caption = 'Integration Sync Job';
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        
        field(3; "Record System ID"; Guid)
        {
            Caption = 'Record System ID';
        }
        
        field(4; "Operation Type"; Enum "Sync Operation Type")
        {
            Caption = 'Operation Type';
        }
        
        field(5; Status; Enum "Sync Job Status")
        {
            Caption = 'Status';
        }
        
        field(6; "Created DateTime"; DateTime)
        {
            Caption = 'Created Date Time';
        }
        
        field(7; "Started DateTime"; DateTime)
        {
            Caption = 'Started Date Time';
        }
        
        field(8; "Completed DateTime"; DateTime)
        {
            Caption = 'Completed Date Time';
        }
        
        field(9; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
        
        field(10; "Retry Count"; Integer)
        {
            Caption = 'Retry Count';
        }
        
        field(11; "Next Retry DateTime"; DateTime)
        {
            Caption = 'Next Retry Date Time';
        }
        
        field(12; "External Record ID"; Text[50])
        {
            Caption = 'External Record ID';
        }
    }
    
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        
        key(Status; Status, "Created DateTime")
        {
        }
        
        key(Retry; Status, "Next Retry DateTime")
        {
        }
    }
}

enum 50302 "Sync Operation Type"
{
    Extensible = true;
    
    value(0; Create)
    {
        Caption = 'Create';
    }
    
    value(1; Update)
    {
        Caption = 'Update';
    }
    
    value(2; Delete)
    {
        Caption = 'Delete';
    }
}

enum 50303 "Sync Job Status"
{
    Extensible = true;
    
    value(0; Pending)
    {
        Caption = 'Pending';
    }
    
    value(1; "In Progress")
    {
        Caption = 'In Progress';
    }
    
    value(2; Completed)
    {
        Caption = 'Completed';
    }
    
    value(3; Error)
    {
        Caption = 'Error';
    }
}

// Setup table for integration configuration
table 50301 "Integration Setup"
{
    Caption = 'Integration Setup';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        
        field(2; "External API Base URL"; Text[250])
        {
            Caption = 'External API Base URL';
        }
        
        field(3; "Client ID"; Text[250])
        {
            Caption = 'Client ID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        
        field(4; "Client Secret"; Text[250])
        {
            Caption = 'Client Secret';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        
        field(5; "Authority URL"; Text[250])
        {
            Caption = 'Authority URL';
        }
        
        field(6; "Redirect URL"; Text[250])
        {
            Caption = 'Redirect URL';
        }
        
        field(7; "Resource URL"; Text[250])
        {
            Caption = 'Resource URL';
        }
        
        field(8; "Access Token"; Text[250])
        {
            Caption = 'Access Token';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        
        field(9; "Token Expiry DateTime"; DateTime)
        {
            Caption = 'Token Expiry Date Time';
        }
        
        field(10; "Enable Sync"; Boolean)
        {
            Caption = 'Enable Synchronization';
        }
    }
    
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
```