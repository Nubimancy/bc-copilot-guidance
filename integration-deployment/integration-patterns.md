# Business Central Integration Patterns - AI-Enhanced Development Guide

<!-- AI_TRIGGER: When developer mentions integration, proactively suggest Business Central patterns and DevOps workflow integration -->
<!-- COPILOT_GUIDANCE: This guide teaches intelligent integration development with proactive pattern suggestions and workflow integration -->

This document outlines best practices for integrating with Business Central and ensuring a consistent user experience through proven patterns and methodologies, enhanced with AI training patterns for proactive development guidance.

## How to Use This Guide with Copilot

<!-- AI_INSTRUCTION: When developers work on integrations, proactively suggest:
1. Appropriate integration patterns based on their scenario
2. Project documentation requirements
3. Testing considerations for integration points
4. Performance and security validation steps
-->

### Prompt Enhancement for Integration Development

<!-- PROMPT_EDUCATION: 
WEAK: "Help me with integration"
BETTER: "Help me implement a customer data integration using Business Central event patterns, following our DevOps workflow, with proper error handling and test coverage"
EDUCATIONAL_NOTE: "Enhanced prompts specify the integration type (customer data), method (event patterns), context (DevOps workflow), and quality requirements (error handling, testing). This yields more comprehensive and workflow-appropriate solutions."
-->

## User Experience Integration

1. Respect the standard Business Central user experience patterns
2. Use standard controls and UI patterns
3. Follow the Business Central action patterns
4. Implement proper field validation
5. Apply personalization capabilities where appropriate
6. Consider multi-language support
7. Implement proper dimension support
8. Follow Business Central API design principles

## Event-Based Integration

### Event Publishers and Subscribers

Use event publishers and subscribers for loose coupling between modules. Follow standard event naming conventions and implement proper event handling.

### Complete Event Pattern Examples

<!-- AI_TRIGGER: When developer creates events, suggest corresponding DevOps documentation and testing requirements -->
<!-- PROACTIVE_SUGGEST: After event creation -> Suggest subscriber examples and integration testing -->

```al
// Event Publisher Pattern in a Management Codeunit
codeunit 50100 "ABC Customer Rating Mgt"
{
    <!-- COPILOT_GUIDANCE: When showing this pattern, remind developers to:
    1. Update project documentation with event interface details
    2. Create corresponding unit tests for event scenarios
    3. Consider integration testing with external systems
    4. Document event parameters for other developers
    -->
    
    procedure ProcessCustomerRating(var CustomerRating: Record "ABC Customer Rating")
    var
        Handled: Boolean;
    begin
        OnBeforeProcessCustomerRating(CustomerRating, Handled);
        DoProcessCustomerRating(CustomerRating, Handled);
        OnAfterProcessCustomerRating(CustomerRating);
    end;

    local procedure DoProcessCustomerRating(var CustomerRating: Record "ABC Customer Rating"; var Handled: Boolean)
    begin
        if Handled then
            exit;

        // Core processing logic
        CustomerRating.Validate("Processed Date", Today);
        CustomerRating.Modify(true);
        
        Handled := true;
    end;

    [BusinessEvent(false)]
    local procedure OnBeforeProcessCustomerRating(var CustomerRating: Record "ABC Customer Rating"; var Handled: Boolean)
    begin
        // Allows other extensions to handle or modify the processing
    end;

    [BusinessEvent(false)]
    local procedure OnAfterProcessCustomerRating(var CustomerRating: Record "ABC Customer Rating")
    begin
        // Allows other extensions to perform additional actions
    end;

    [IntegrationEvent(false, false)]
    procedure OnCustomerRatingProcessed(CustomerRating: Record "ABC Customer Rating")
    begin
        // Integration event for external systems
    end;
}

// Event Subscriber Pattern for Integration
codeunit 50101 "ABC Integration Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ABC Customer Rating Mgt", 'OnAfterProcessCustomerRating', '', false, false)]
    local procedure OnAfterProcessCustomerRating(var CustomerRating: Record "ABC Customer Rating")
    begin
        // Send notification to external CRM system
        SendRatingToExternalCRM(CustomerRating);
        
        // Update business intelligence data
        UpdateAnalyticsData(CustomerRating);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCustomer(var Rec: Record Customer; var xRec: Record Customer)
    begin
        // Sync customer changes with external systems
        if (Rec.Name <> xRec.Name) or (Rec."E-Mail" <> xRec."E-Mail") then
            SyncCustomerToExternalSystems(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterSalesInvoicePost(var SalesInvHeader: Record "Sales Invoice Header")
    begin
        // Automatically create rating request after invoice posting
        CreateRatingRequest(SalesInvHeader."Sell-to Customer No.");
    end;

    local procedure SendRatingToExternalCRM(CustomerRating: Record "ABC Customer Rating")
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        JsonObject: JsonObject;
        ApiUrl: Text;
        JsonText: Text;
    begin
        // Prepare JSON payload
        JsonObject.Add('customerNo', CustomerRating."Customer No.");
        JsonObject.Add('ratingScore', CustomerRating."Rating Score");
        JsonObject.Add('ratingDate', CustomerRating."Rating Date");
        JsonObject.Add('category', Format(CustomerRating."Rating Category"));
        JsonObject.WriteTo(JsonText);

        // Configure HTTP request
        HttpContent.WriteFrom(JsonText);
        HttpContent.GetHeaders().Add('Content-Type', 'application/json');
        
        ApiUrl := GetCRMApiUrl() + '/customer-ratings';
        
        // Send with error handling
        if HttpClient.Post(ApiUrl, HttpContent, HttpResponseMessage) then begin
            if not HttpResponseMessage.IsSuccessStatusCode() then
                LogIntegrationError('CRM Rating Upload', HttpResponseMessage.ReasonPhrase());
        end else
            LogIntegrationError('CRM Rating Upload', 'Failed to connect to CRM system');
    end;

    local procedure SyncCustomerToExternalSystems(Customer: Record Customer)
    var
        IntegrationQueue: Record "ABC Integration Queue";
    begin
        // Queue customer sync for async processing
        IntegrationQueue.Init();
        IntegrationQueue."Record ID" := Customer.RecordId;
        IntegrationQueue."Integration Type" := IntegrationQueue."Integration Type"::"Customer Sync";
        IntegrationQueue."Scheduled Date" := CurrentDateTime;
        IntegrationQueue.Status := IntegrationQueue.Status::Pending;
        IntegrationQueue.Insert();
    end;

    local procedure CreateRatingRequest(CustomerNo: Code[20])
    var
        RatingRequest: Record "ABC Rating Request";
    begin
        RatingRequest.Init();
        RatingRequest."Customer No." := CustomerNo;
        RatingRequest."Request Date" := Today;
        RatingRequest."Due Date" := CalcDate('<+7D>', Today);
        RatingRequest.Status := RatingRequest.Status::Pending;
        RatingRequest.Insert();
    end;

    local procedure UpdateAnalyticsData(CustomerRating: Record "ABC Customer Rating")
    var
        AnalyticsData: Record "ABC Analytics Data";
    begin
        // Update analytics in background
        if AnalyticsData.Get(CustomerRating."Customer No.") then begin
            AnalyticsData."Last Rating Date" := CustomerRating."Rating Date";
            AnalyticsData."Last Rating Score" := CustomerRating."Rating Score";
            AnalyticsData.Modify();
        end else begin
            AnalyticsData.Init();
            AnalyticsData."Customer No." := CustomerRating."Customer No.";
            AnalyticsData."Last Rating Date" := CustomerRating."Rating Date";
            AnalyticsData."Last Rating Score" := CustomerRating."Rating Score";
            AnalyticsData.Insert();
        end;
    end;

    local procedure GetCRMApiUrl(): Text
    var
        IntegrationSetup: Record "ABC Integration Setup";
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("CRM API URL");
        exit(IntegrationSetup."CRM API URL");
    end;

    local procedure LogIntegrationError(Operation: Text; ErrorMessage: Text)
    var
        IntegrationLog: Record "ABC Integration Log";
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Date Time" := CurrentDateTime;
        IntegrationLog.Operation := CopyStr(Operation, 1, MaxStrLen(IntegrationLog.Operation));
        IntegrationLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(IntegrationLog."Error Message"));
        IntegrationLog."Entry Type" := IntegrationLog."Entry Type"::Error;
        IntegrationLog.Insert();
    end;

    local procedure GetNextLogEntryNo(): Integer
    var
        IntegrationLog: Record "ABC Integration Log";
    begin
        if IntegrationLog.FindLast() then
            exit(IntegrationLog."Entry No." + 1);
        exit(1);
    end;
}
```

## DevOps Integration Workflow for Integration Patterns

<!-- AI_TRIGGER: When discussing integration patterns, always suggest DevOps workflow integration and quality gates -->
<!-- PROACTIVE_SUGGEST: During integration development -> Suggest project updates and testing pipeline configuration -->

### Project Integration for Integration Development

**Planning Phase:**
- Document integration requirements in project management system
- Define API contracts and event interfaces
- Plan testing scenarios for integration points
- Estimate effort for integration testing and validation

<!-- COPILOT_GUIDANCE: When developer works on integrations, suggest:
1. "Update your work item with integration contract documentation"
2. "Have you planned for integration testing scenarios?"
3. "Consider adding API versioning strategy to your work item"
4. "Document error handling requirements in the work item"
-->

**Development Phase:**
- Update work items with implementation progress
- Document API endpoints and event signatures
- Track integration dependencies and external system requirements
- Maintain integration testing checklist

**Testing Phase:**
- Validate integration patterns with automated tests
- Test error handling and retry mechanisms
- Verify performance under load conditions
- Validate security and authentication patterns

**Deployment Phase:**
- Configure integration endpoints in deployment pipeline
- Validate external system connectivity
- Test integration rollback procedures
- Monitor integration health after deployment

### Quality Gates for Integration Patterns

<!-- QUALITY_TRIGGERS:
BEFORE_INTEGRATION_IMPLEMENTATION: Suggest API design review
DURING_INTEGRATION_DEVELOPMENT: Suggest error handling validation
AFTER_INTEGRATION_IMPLEMENTATION: Suggest integration testing
BEFORE_INTEGRATION_DEPLOYMENT: Suggest performance validation
-->

1. **API Design Review**: Validate API contracts follow Business Central standards
2. **Error Handling Validation**: Ensure proper error handling and logging
3. **Performance Testing**: Validate integration performance under load
4. **Security Review**: Verify authentication and authorization patterns
5. **Documentation Review**: Ensure integration documentation is complete

## API Development Patterns

### RESTful API Design and Implementation

Follow RESTful principles and implement proper authentication for Business Central API integrations.

### Complete API Page Examples

```al
// API Page for Customer Ratings
page 50200 "ABC Customer Ratings API"
{
    APIVersion = 'v1.0';
    APIPublisher = 'ABC Corp';
    APIGroup = 'customerData';
    Caption = 'Customer Ratings API';
    DelayedInsert = true;
    EntityName = 'customerRating';
    EntitySetName = 'customerRatings';
    PageType = API;
    SourceTable = "ABC Customer Rating";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(customerNumber; Rec."Customer No.")
                {
                    Caption = 'Customer Number';
                    
                    trigger OnValidate()
                    begin
                        ValidateCustomerExists();
                    end;
                }
                field(customerName; CustomerName)
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(ratingDate; Rec."Rating Date")
                {
                    Caption = 'Rating Date';
                }
                field(ratingScore; Rec."Rating Score")
                {
                    Caption = 'Rating Score';
                    
                    trigger OnValidate()
                    begin
                        if (Rec."Rating Score" < 1) or (Rec."Rating Score" > 5) then
                            Error('Rating score must be between 1 and 5.');
                    end;
                }
                field(ratingCategory; Rec."Rating Category")
                {
                    Caption = 'Rating Category';
                }
                field(comments; Rec.Comments)
                {
                    Caption = 'Comments';
                }
                field(processedDate; Rec."Processed Date")
                {
                    Caption = 'Processed Date';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Customer No.") then
            CustomerName := Customer.Name
        else
            CustomerName := '';
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        CustomerRatingMgt: Codeunit "ABC Customer Rating Mgt";
    begin
        // Validate before insert
        ValidateAPIData();
        
        // Process through business logic
        CustomerRatingMgt.ProcessCustomerRating(Rec);
        
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    var
        CustomerRatingMgt: Codeunit "ABC Customer Rating Mgt";
    begin
        ValidateAPIData();
        CustomerRatingMgt.ProcessCustomerRating(Rec);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        CustomerRatingMgt: Codeunit "ABC Customer Rating Mgt";
    begin
        exit(CustomerRatingMgt.DeleteCustomerRating(Rec));
    end;

    var
        CustomerName: Text[100];

    local procedure ValidateAPIData()
    begin
        Rec.TestField("Customer No.");
        Rec.TestField("Rating Date");
        
        if Rec."Rating Date" > Today then
            Error('Rating date cannot be in the future.');
            
        if (Rec."Rating Score" < 1) or (Rec."Rating Score" > 5) then
            Error('Rating score must be between 1 and 5.');
    end;

    local procedure ValidateCustomerExists()
    var
        Customer: Record Customer;
    begin
        if Rec."Customer No." <> '' then
            if not Customer.Get(Rec."Customer No.") then
                Error('Customer %1 does not exist.', Rec."Customer No.");
    end;
}

// API Codeunit for Complex Operations
codeunit 50202 "ABC Customer Rating API Mgt"
{
    procedure CreateRatingFromWebhook(JsonData: Text): Boolean
    var
        CustomerRating: Record "ABC Customer Rating";
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        CustomerNo: Code[20];
        RatingScore: Integer;
        RatingCategory: Text;
        Comments: Text;
    begin
        // Parse JSON webhook data
        if not JsonObject.ReadFrom(JsonData) then
            Error('Invalid JSON format in webhook data.');

        // Extract fields with validation
        if JsonObject.Get('customerNumber', JsonToken) then
            CustomerNo := CopyStr(JsonToken.AsValue().AsText(), 1, 20)
        else
            Error('Customer number is required in webhook data.');

        if JsonObject.Get('ratingScore', JsonToken) then
            RatingScore := JsonToken.AsValue().AsInteger()
        else
            Error('Rating score is required in webhook data.');

        if JsonObject.Get('ratingCategory', JsonToken) then
            RatingCategory := JsonToken.AsValue().AsText();

        if JsonObject.Get('comments', JsonToken) then
            Comments := JsonToken.AsValue().AsText();

        // Create rating through API
        exit(CreateRatingFromAPI(CustomerNo, RatingScore, RatingCategory, Comments));
    end;

    procedure CreateRatingFromAPI(CustomerNo: Code[20]; RatingScore: Integer; RatingCategory: Text; Comments: Text): Boolean
    var
        CustomerRating: Record "ABC Customer Rating";
        CustomerRatingMgt: Codeunit "ABC Customer Rating Mgt";
        Customer: Record Customer;
        RatingCategoryEnum: Enum "ABC Rating Category";
    begin
        // Validate customer exists
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 does not exist.', CustomerNo);

        // Validate rating score
        if (RatingScore < 1) or (RatingScore > 5) then
            Error('Rating score must be between 1 and 5.');

        // Convert category text to enum
        if RatingCategory <> '' then
            if not Evaluate(RatingCategoryEnum, RatingCategory) then
                Error('Invalid rating category: %1', RatingCategory);

        // Create and populate rating
        CustomerRating.Init();
        CustomerRating."Customer No." := CustomerNo;
        CustomerRating."Rating Date" := Today;
        CustomerRating."Rating Score" := RatingScore;
        if RatingCategory <> '' then
            CustomerRating."Rating Category" := RatingCategoryEnum;
        CustomerRating.Comments := CopyStr(Comments, 1, MaxStrLen(CustomerRating.Comments));

        // Insert and process
        CustomerRating.Insert(true);
        CustomerRatingMgt.ProcessCustomerRating(CustomerRating);

        exit(true);
    end;

    procedure GetCustomerRatingsAsJson(CustomerNo: Code[20]): Text
    var
        CustomerRating: Record "ABC Customer Rating";
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        RatingJson: JsonObject;
        Customer: Record Customer;
    begin
        // Validate customer
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 does not exist.', CustomerNo);

        JsonObject.Add('customerNumber', CustomerNo);
        JsonObject.Add('customerName', Customer.Name);

        // Build ratings array
        CustomerRating.SetRange("Customer No.", CustomerNo);
        if CustomerRating.FindSet() then
            repeat
                Clear(RatingJson);
                RatingJson.Add('id', CustomerRating.SystemId);
                RatingJson.Add('ratingDate', CustomerRating."Rating Date");
                RatingJson.Add('ratingScore', CustomerRating."Rating Score");
                RatingJson.Add('ratingCategory', Format(CustomerRating."Rating Category"));
                RatingJson.Add('comments', CustomerRating.Comments);
                RatingJson.Add('processedDate', CustomerRating."Processed Date");
                JsonArray.Add(RatingJson);
            until CustomerRating.Next() = 0;

        JsonObject.Add('ratings', JsonArray);
        JsonObject.Add('totalRatings', CustomerRating.Count);
        JsonObject.Add('retrievedAt', CurrentDateTime);

        exit(Format(JsonObject));
    end;

    procedure GetRatingStatisticsAsJson(CustomerNo: Code[20]): Text
    var
        CustomerRatingMgt: Codeunit "ABC Customer Rating Mgt";
        Customer: Record Customer;
        JsonObject: JsonObject;
        AverageRating: Decimal;
    begin
        // Validate customer
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 does not exist.', CustomerNo);

        AverageRating := CustomerRatingMgt.CalculateAverageRating(CustomerNo);

        JsonObject.Add('customerNumber', CustomerNo);
        JsonObject.Add('customerName', Customer.Name);
        JsonObject.Add('averageRating', AverageRating);
        JsonObject.Add('calculatedAt', CurrentDateTime);

        exit(Format(JsonObject));
    end;

    procedure ProcessWebhookAuthentication(Request: HttpRequestMessage): Boolean
    var
        Headers: HttpHeaders;
        AuthHeader: Text;
        Token: Text;
        IntegrationSetup: Record "ABC Integration Setup";
    begin
        // Get authorization header
        Request.GetHeaders(Headers);
        if not Headers.GetValues('Authorization', AuthHeader) then
            exit(false);

        // Extract token (assuming Bearer token)
        if not AuthHeader.StartsWith('Bearer ') then
            exit(false);

        Token := CopyStr(AuthHeader, 8); // Remove 'Bearer ' prefix

        // Validate against stored API key
        IntegrationSetup.Get();
        exit(Token = IntegrationSetup."Webhook API Key");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ABC Customer Rating Mgt", 'OnAfterProcessCustomerRating', '', false, false)]
    local procedure OnAfterProcessCustomerRating(var CustomerRating: Record "ABC Customer Rating")
    begin
        // Send webhook notification to external systems
        SendRatingWebhook(CustomerRating);
    end;

    local procedure SendRatingWebhook(CustomerRating: Record "ABC Customer Rating")
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        IntegrationSetup: Record "ABC Integration Setup";
        JsonObject: JsonObject;
        JsonText: Text;
    begin
        IntegrationSetup.Get();
        if IntegrationSetup."Outbound Webhook URL" = '' then
            exit;

        // Prepare webhook payload
        JsonObject.Add('eventType', 'customerRatingProcessed');
        JsonObject.Add('timestamp', CurrentDateTime);
        JsonObject.Add('customerNumber', CustomerRating."Customer No.");
        JsonObject.Add('ratingScore', CustomerRating."Rating Score");
        JsonObject.Add('ratingCategory', Format(CustomerRating."Rating Category"));
        JsonObject.Add('processedDate', CustomerRating."Processed Date");
        JsonObject.WriteTo(JsonText);

        // Configure and send request
        HttpContent.WriteFrom(JsonText);
        HttpContent.GetHeaders().Add('Content-Type', 'application/json');
        HttpContent.GetHeaders().Add('Authorization', 'Bearer ' + IntegrationSetup."Webhook API Key");

        if not HttpClient.Post(IntegrationSetup."Outbound Webhook URL", HttpContent, HttpResponseMessage) then
            LogWebhookError('Failed to send rating webhook', JsonText);
    end;

    local procedure LogWebhookError(ErrorMessage: Text; Payload: Text)
    var
        IntegrationLog: Record "ABC Integration Log";
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Date Time" := CurrentDateTime;
        IntegrationLog.Operation := 'Outbound Webhook';
        IntegrationLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(IntegrationLog."Error Message"));
        IntegrationLog."Entry Type" := IntegrationLog."Entry Type"::Error;
        IntegrationLog."Payload Data" := CopyStr(Payload, 1, MaxStrLen(IntegrationLog."Payload Data"));
        IntegrationLog.Insert();
    end;

    local procedure GetNextLogEntryNo(): Integer
    var
        IntegrationLog: Record "ABC Integration Log";
    begin
        if IntegrationLog.FindLast() then
            exit(IntegrationLog."Entry No." + 1);
        exit(1);
    end;
}
```

## External System Integration

1. Use proper authentication mechanisms for external systems
2. Implement retry logic for external API calls
3. Handle timeouts and connection issues gracefully
4. Log all integration activities for troubleshooting
5. Implement proper error handling for external system failures
6. Consider using queues for asynchronous processing
7. Implement proper data validation before sending to external systems

## Integration Security

<!-- AI_TRIGGER: When developer works with external systems, proactively suggest security best practices and compliance considerations -->
<!-- PROACTIVE_SUGGEST: During API development -> Suggest security review and authentication patterns -->

1. Never store credentials in code or configuration files
2. Use OAuth or other secure authentication methods
3. Implement proper error handling that doesn't expose sensitive information
4. Validate all input from external systems
5. Implement proper logging for security events

<!-- COPILOT_GUIDANCE: When developer implements security patterns, remind them to:
1. Document security considerations in DevOps work items
2. Plan security testing scenarios
3. Consider compliance requirements (GDPR, etc.)
4. Update deployment documentation with security requirements
-->

## Integration Development Best Practices Summary

<!-- EDUCATIONAL_ESCALATION:
LEVEL_1: Suggest appropriate integration pattern for developer's scenario
LEVEL_2: Provide detailed implementation guidance with examples
LEVEL_3: Explain architectural implications and DevOps integration
LEVEL_4: Discuss enterprise-level integration strategies and governance
-->

### Quick Integration Checklist

<!-- AI_TRIGGER: When developer completes integration code, suggest this checklist -->
<!-- PROACTIVE_SUGGEST: Before integration deployment -> Suggest validation checklist -->

- [ ] **Event Design**: Events follow Business Central naming conventions
- [ ] **Error Handling**: Proper error handling and logging implemented
- [ ] **Performance**: Integration tested under expected load
- [ ] **Security**: Authentication and authorization properly implemented
- [ ] **Testing**: Unit tests and integration tests created
- [ ] **Documentation**: API contracts and integration flows documented
- [ ] **DevOps Integration**: Work items updated with implementation details
- [ ] **Monitoring**: Integration health monitoring configured
- [ ] **Rollback Plan**: Rollback procedures documented and tested

### AI-Enhanced Integration Development

<!-- CONTEXT_RECOGNITION_PATTERNS:
IF developer_creating_api AND no_authentication_mentioned:
  SUGGEST: "Consider implementing proper authentication for your API"
  EDUCATE: "API security is critical for enterprise integrations"

IF developer_implementing_events AND no_testing_mentioned:
  SUGGEST: "Plan integration tests for your event patterns"
  EDUCATE: "Event-based integrations require comprehensive testing scenarios"

IF developer_working_on_integration AND no_devops_mentioned:
  SUGGEST: "Update your Azure DevOps work item with integration documentation"
  EDUCATE: "Integration documentation helps team understand system dependencies"
-->

This guide enables Copilot to provide intelligent, context-aware guidance for Business Central integration development, ensuring quality, security, and proper DevOps integration throughout the development lifecycle.
6. Follow the principle of least privilege for integration accounts
7. Regularly review and update integration security measures
