---
title: "Event Documentation Standards - Code Samples"
description: "Complete examples of comprehensive event documentation using XML comments and self-documenting patterns"
area: "code-creation"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "List"]
tags: ["documentation", "events", "xml-comments", "samples", "maintainability"]
---

# Event Documentation Standards - Code Samples

## Complete Integration Event Documentation

### Customer Management Events - Full Documentation Example

```al
/// <summary>
/// Customer Management Events for extending customer lifecycle operations.
/// Provides comprehensive integration points for custom business logic, validation, and external system integration.
/// </summary>
/// <designPrinciples>
/// Event Design Principles:
/// - Rich Context: All events provide complete business context through record parameters
/// - Extensible Parameters: Record-based parameters support future field additions
/// - Clear Semantics: Event names clearly indicate business operation and timing
/// - Error Collection: Validation events collect multiple errors for better user experience
/// - Performance Aware: Events designed to minimize performance impact on core operations
/// </designPrinciples>
codeunit 50300 "Customer Lifecycle Events"
{
    /// <summary>
    /// Raised before new customer registration begins validation and creation process.
    /// Use to modify customer data, add custom validation rules, or completely replace registration logic.
    /// </summary>
    /// <param name="Customer">Customer record being registered. Modify as needed for custom logic.</param>
    /// <param name="RegistrationContext">Additional context about registration source and parameters.</param>
    /// <param name="ValidationErrors">Add validation error messages. Registration fails if any errors exist.</param>
    /// <param name="IsHandled">Set true to completely skip standard registration process.</param>
    /// <example>
    /// Add industry-specific validation and data enrichment:
    /// <code>
    /// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Lifecycle Events", 'OnBeforeCustomerRegistration', '', false, false)]
    /// local procedure ValidateIndustryRequirements(var Customer: Record Customer; RegistrationContext: Record "Registration Context"; var ValidationErrors: List of [Text]; var IsHandled: Boolean)
    /// begin
    ///     // Validate required industry-specific fields
    ///     if Customer."Industry Code" = '' then
    ///         ValidationErrors.Add('Industry Code is required for B2B customers');
    ///         
    ///     if (Customer."Industry Code" = 'FINANCE') and (Customer."Credit Rating" = '') then
    ///         ValidationErrors.Add('Credit rating required for financial industry customers');
    ///         
    ///     // Enrich customer data from external sources
    ///     if Customer."VAT Registration No." <> '' then
    ///         EnrichFromVATRegistry(Customer);
    /// end;
    /// </code>
    /// </example>
    /// <businessScenarios>
    /// Common business scenarios:
    /// 1. Industry-specific validation rules
    /// 2. External data enrichment (credit checks, VAT validation)
    /// 3. Duplicate customer detection and merging
    /// 4. Custom approval workflows for high-risk customers
    /// 5. Integration with CRM systems for lead conversion
    /// </businessScenarios>
    /// <performanceConsiderations>
    /// Performance Guidelines:
    /// - Keep validation logic lightweight (< 100ms per subscriber)
    /// - Use TryFunction for external API calls
    /// - Cache expensive lookups (credit ratings, industry data)
    /// - Avoid complex calculations that can be deferred to OnAfter events
    /// </performanceConsiderations>
    /// <errorHandling>
    /// Error Handling:
    /// - Add specific, actionable error messages to ValidationErrors
    /// - Include field names and expected values in error messages
    /// - Group related validation errors for better user experience
    /// - Use localized error messages for multi-language support
    /// </errorHandling>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerRegistration(var Customer: Record Customer; 
                                                RegistrationContext: Record "Registration Context";
                                                var ValidationErrors: List of [Text];
                                                var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised after successful customer creation but before default setup application.
    /// Use to create related records, apply custom defaults, or initialize feature-specific data.
    /// </summary>
    /// <param name="Customer">Newly created customer record with system-assigned number and basic data.</param>
    /// <param name="RegistrationContext">Context information about registration source and options.</param>
    /// <example>
    /// Create related records and apply custom defaults:
    /// <code>
    /// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Lifecycle Events", 'OnAfterCustomerCreation', '', false, false)]
    /// local procedure SetupCustomerExtensions(var Customer: Record Customer; RegistrationContext: Record "Registration Context")
    /// var
    ///     CustomerPreferences: Record "Customer Preferences";
    ///     LoyaltyAccount: Record "Loyalty Account";
    /// begin
    ///     // Create loyalty account for all new customers
    ///     CreateLoyaltyAccount(Customer."No.", RegistrationContext."Initial Loyalty Tier");
    ///     
    ///     // Setup communication preferences
    ///     CustomerPreferences.Init();
    ///     CustomerPreferences."Customer No." := Customer."No.";
    ///     CustomerPreferences."Email Notifications" := true;
    ///     CustomerPreferences."Marketing Emails" := RegistrationContext."Marketing Opt-In";
    ///     CustomerPreferences.Insert();
    ///     
    ///     // Apply industry-specific defaults
    ///     ApplyIndustryDefaults(Customer, RegistrationContext);
    /// end;
    /// </code>
    /// </example>
    /// <relatedRecords>
    /// Commonly created related records:
    /// - Customer contact information and relationships
    /// - Loyalty program enrollment and initial points
    /// - Communication preferences and opt-in settings
    /// - Industry-specific configuration records
    /// - Integration system customer IDs and mappings
    /// - Custom dimension values for reporting
    /// </relatedRecords>
    /// <timing>
    /// Event Timing:
    /// - Fires immediately after Customer.Insert(true)
    /// - Customer."No." is available (auto-generated or assigned)
    /// - Before standard default setup (payment terms, posting groups)
    /// - Before OnAfterCustomerDefaultsApplied event
    /// - Within same database transaction as customer creation
    /// </timing>
    [IntegrationEvent(false, false)]
    local procedure OnAfterCustomerCreation(var Customer: Record Customer; 
                                           RegistrationContext: Record "Registration Context")
    begin
    end;

    /// <summary>
    /// Raised when customer credit limit is being modified, either through direct edit or automated process.
    /// Use to implement custom approval workflows, external credit checks, or audit logging.
    /// </summary>
    /// <param name="Customer">Customer record with current credit limit (before change).</param>
    /// <param name="OldCreditLimit">Previous credit limit value for comparison and audit trails.</param>
    /// <param name="NewCreditLimit">Proposed new credit limit value.</param>
    /// <param name="ChangeReason">Reason code for credit limit change (manual, automatic, external).</param>
    /// <param name="IsApproved">Set false to reject credit limit change. Default true.</param>
    /// <param name="ApprovalMessage">Message explaining approval decision, shown to user.</param>
    /// <example>
    /// Implement credit limit approval workflow:
    /// <code>
    /// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Lifecycle Events", 'OnBeforeCreditLimitChange', '', false, false)]
    /// local procedure ValidateCreditLimitIncrease(var Customer: Record Customer; OldCreditLimit: Decimal; NewCreditLimit: Decimal; ChangeReason: Code[10]; var IsApproved: Boolean; var ApprovalMessage: Text)
    /// var
    ///     CreditAnalysis: Record "Credit Analysis";
    ///     RequiredApprovalAmount: Decimal;
    /// begin
    ///     RequiredApprovalAmount := 50000; // Increases over $50k need approval
    ///     
    ///     if NewCreditLimit > OldCreditLimit then begin
    ///         if (NewCreditLimit - OldCreditLimit) > RequiredApprovalAmount then begin
    ///             if not HasPendingCreditApproval(Customer."No.") then begin
    ///                 CreateCreditApprovalRequest(Customer, OldCreditLimit, NewCreditLimit, ChangeReason);
    ///                 IsApproved := false;
    ///                 ApprovalMessage := StrSubstNo('Credit increase of %1 requires approval. Request submitted.', NewCreditLimit - OldCreditLimit);
    ///             end;
    ///         end;
    ///         
    ///         // Log all credit increases for audit
    ///         LogCreditLimitChange(Customer, OldCreditLimit, NewCreditLimit, ChangeReason, IsApproved);
    ///     end;
    /// end;
    /// </code>
    /// </example>
    /// <approvalWorkflow>
    /// Approval Workflow Integration:
    /// 1. Check if change requires approval based on amount, percentage, or risk factors
    /// 2. Create approval request with complete context (customer history, financial data)
    /// 3. Route to appropriate approver based on amount and customer risk profile
    /// 4. Set IsApproved = false to prevent immediate change
    /// 5. Provide clear message to user about approval process
    /// 6. Use workflow system to track approval status and notifications
    /// </approvalWorkflow>
    /// <auditingRequirements>
    /// Audit Trail Requirements:
    /// - Log all credit limit changes with timestamp and user
    /// - Record business justification and supporting documentation
    /// - Track approval chain and decision rationale
    /// - Maintain history for regulatory compliance
    /// - Include external credit check results if applicable
    /// </auditingRequirements>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreditLimitChange(var Customer: Record Customer; 
                                            OldCreditLimit: Decimal;
                                            NewCreditLimit: Decimal;
                                            ChangeReason: Code[10];
                                            var IsApproved: Boolean;
                                            var ApprovalMessage: Text)
    begin
    end;
}
```

## Business Event Documentation Examples

### Order Management Business Events

```al
/// <summary>
/// Order Management Business Events for external system integration and workflow automation.
/// Publishes structured business events for consumption by Power Platform, Logic Apps, and third-party systems.
/// </summary>
/// <integrationArchitecture>
/// Integration Architecture:
/// - Events published as JSON messages through Business Central's telemetry system
/// - External systems subscribe via Event Hub, Service Bus, or HTTP webhooks
/// - Asynchronous processing prevents external system failures from blocking BC operations
/// - Event versioning ensures backward compatibility as business requirements evolve
/// </integrationArchitecture>
/// <eventVersioning>
/// Event Versioning Strategy:
/// - All events include version number in payload
/// - Breaking changes increment major version (v1.0 → v2.0)
/// - New fields increment minor version (v1.0 → v1.1)
/// - Consumers should handle unknown fields gracefully
/// - Legacy versions supported for minimum 2 years
/// </eventVersioning>
codeunit 50301 "Order Business Events"
{
    /// <summary>
    /// Published when sales order status changes to Released, indicating order is ready for fulfillment.
    /// External systems can use this event to trigger warehouse operations, shipping arrangements, and customer notifications.
    /// </summary>
    /// <param name="SalesHeader">Released sales order with complete header information.</param>
    /// <param name="SalesLines">All order lines with item details, quantities, and pricing.</param>
    /// <param name="PreviousStatus">Previous order status before release.</param>
    /// <param name="ReleaseContext">Context about release trigger (manual, automatic, approval completion).</param>
    /// <eventSchema>
    /// JSON Event Schema v1.2:
    /// <code>
    /// {
    ///   "eventType": "SalesOrderReleased",
    ///   "version": "1.2",
    ///   "timestamp": "2024-03-15T14:30:00Z",
    ///   "correlationId": "550e8400-e29b-41d4-a716-446655440000",
    ///   "source": {
    ///     "system": "Business Central",
    ///     "company": "CRONUS USA Inc.",
    ///     "environment": "Production"
    ///   },
    ///   "order": {
    ///     "no": "SO-1001",
    ///     "customerNo": "CUST001",
    ///     "customerName": "Acme Corporation",
    ///     "orderDate": "2024-03-15",
    ///     "requestedDeliveryDate": "2024-03-20",
    ///     "totalAmount": 15750.50,
    ///     "currency": "USD",
    ///     "previousStatus": "Open",
    ///     "newStatus": "Released",
    ///     "releaseContext": "Automatic",
    ///     "salesPerson": "AH",
    ///     "paymentTerms": "30 DAYS"
    ///   },
    ///   "lines": [
    ///     {
    ///       "lineNo": 10000,
    ///       "itemNo": "ITEM001",
    ///       "description": "Professional Service Hours",
    ///       "quantity": 40,
    ///       "unitPrice": 125.00,
    ///       "lineAmount": 5000.00,
    ///       "requestedDeliveryDate": "2024-03-20"
    ///     }
    ///   ],
    ///   "shipping": {
    ///     "locationCode": "EAST",
    ///     "shipToAddress": {
    ///       "name": "Acme Corporation",
    ///       "address": "123 Business St",
    ///       "city": "New York",
    ///       "state": "NY",
    ///       "zipCode": "10001",
    ///       "country": "US"
    ///     }
    ///   }
    /// }
    /// </code>
    /// </eventSchema>
    /// <consumptionExamples>
    /// Example consumption scenarios:
    /// 
    /// WAREHOUSE MANAGEMENT SYSTEM:
    /// - Receive order release event
    /// - Create pick list and allocate inventory
    /// - Schedule warehouse staff and equipment
    /// - Update expected shipping timeline
    /// 
    /// CUSTOMER PORTAL:
    /// - Notify customer of order confirmation
    /// - Update order tracking information
    /// - Send delivery timeline estimate
    /// - Provide tracking number when available
    /// 
    /// ERP INTEGRATION:
    /// - Synchronize order status across systems
    /// - Update production planning systems
    /// - Trigger procurement for drop-ship items
    /// - Update financial forecasting data
    /// </consumptionExamples>
    /// <errorHandling>
    /// Consumer Error Handling:
    /// - Implement idempotent processing (handle duplicate events)
    /// - Use correlationId for deduplication and tracking
    /// - Implement retry logic with exponential backoff
    /// - Log processing failures for monitoring and alerting
    /// - Have fallback mechanisms for critical workflows
    /// - Validate event schema before processing
    /// </errorHandling>
    /// <monitoring>
    /// Event Monitoring:
    /// - Track event publishing success/failure rates
    /// - Monitor consumer processing latency
    /// - Alert on event delivery failures
    /// - Measure end-to-end workflow completion times
    /// - Track business outcome metrics (order fulfillment rates)
    /// </monitoring>
    procedure PublishSalesOrderReleased(var SalesHeader: Record "Sales Header";
                                       var SalesLines: Record "Sales Line"; 
                                       PreviousStatus: Enum "Sales Document Status";
                                       ReleaseContext: Enum "Order Release Context")
    var
        EventPayload: Text;
        CorrelationId: Guid;
    begin
        CorrelationId := CreateGuid();
        EventPayload := BuildOrderReleasedPayload(SalesHeader, SalesLines, PreviousStatus, ReleaseContext, CorrelationId);
        
        // Publish business event
        Session.LogMessage('SalesOrderReleased', EventPayload, Verbosity::Normal, 
                          DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 
                          'Category', 'BusinessEvent', 
                          'CorrelationId', Format(CorrelationId));
                          
        // Log for internal monitoring
        LogBusinessEventPublished('SalesOrderReleased', SalesHeader."No.", CorrelationId, CurrentDateTime);
        
        // Fire integration event for internal subscribers
        OnAfterPublishSalesOrderReleased(SalesHeader, SalesLines, PreviousStatus, ReleaseContext, CorrelationId);
    end;

    /// <summary>
    /// Integration event fired after sales order release business event is published.
    /// Use for internal system coordination that should happen after external notification.
    /// </summary>
    /// <param name="SalesHeader">Released sales order header record.</param>
    /// <param name="SalesLines">Sales order lines record set.</param>
    /// <param name="PreviousStatus">Status before release.</param>
    /// <param name="ReleaseContext">Context of how order was released.</param>
    /// <param name="CorrelationId">Unique identifier linking related events and processes.</param>
    /// <internalUsage>
    /// Internal processing scenarios:
    /// - Update dashboard metrics and KPIs
    /// - Trigger internal approval notifications
    /// - Update sales commission calculations
    /// - Refresh reporting data caches
    /// - Log to audit trail systems
    /// </internalUsage>
    [IntegrationEvent(false, false)]
    local procedure OnAfterPublishSalesOrderReleased(var SalesHeader: Record "Sales Header";
                                                    var SalesLines: Record "Sales Line";
                                                    PreviousStatus: Enum "Sales Document Status";
                                                    ReleaseContext: Enum "Order Release Context";
                                                    CorrelationId: Guid)
    begin
    end;
}
```

## Event Testing Documentation

### Comprehensive Testing Framework Documentation

```al
/// <summary>
/// Event Testing Framework providing comprehensive test patterns for integration and business events.
/// Demonstrates proper event testing methodology with mock subscribers and validation techniques.
/// </summary>
/// <testingPhilosophy>
/// Event Testing Philosophy:
/// - Test events in isolation from business logic implementation
/// - Verify event contracts (parameters, timing, conditions)
/// - Mock external dependencies and subscriber behavior
/// - Test error scenarios and edge cases
/// - Validate event sequencing and interaction patterns
/// - Performance test with realistic subscriber loads
/// </testingPhilosophy>
/// <testCategories>
/// Test Categories:
/// 1. Contract Tests - Verify event signatures and parameter passing
/// 2. Timing Tests - Validate when events fire in business process
/// 3. Integration Tests - Test with real subscribers and side effects
/// 4. Performance Tests - Measure event overhead and subscriber impact
/// 5. Error Tests - Verify error handling and recovery scenarios
/// 6. Business Event Tests - Validate JSON payload structure and delivery
/// </testCategories>
codeunit 80300 "Comprehensive Event Tests"
{
    Subtype = Test;
    
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        EventTestHarness: Codeunit "Event Test Harness";

    /// <summary>
    /// Test customer registration events fire with correct parameters and timing.
    /// Validates complete event sequence and parameter fidelity.
    /// </summary>
    /// <testObjective>
    /// Verify that customer registration events:
    /// - Fire in correct sequence (Before → After)
    /// - Pass parameters correctly without modification
    /// - Allow subscriber modification of customer data
    /// - Collect validation errors from multiple subscribers
    /// - Handle IsHandled parameter correctly
    /// </testObjective>
    /// <testData>
    /// Test data requirements:
    /// - Valid customer record with required fields
    /// - Registration context with source information
    /// - Mock subscribers with known behavior patterns
    /// - Validation scenarios (pass/fail/multiple errors)
    /// </testData>
    [Test]
    procedure TestCustomerRegistrationEventSequence()
    var
        Customer: Record Customer;
        RegistrationContext: Record "Registration Context";
        CustomerRegistration: Codeunit "Customer Registration Manager";
        MockSubscriber: Codeunit "Mock Event Subscriber";
        ValidationErrors: List of [Text];
        EventSequence: List of [Text];
    begin
        // Initialize
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Comprehensive Event Tests");
        
        // Setup test data
        CreateValidTestCustomer(Customer);
        CreateRegistrationContext(RegistrationContext, 'WEB_REGISTRATION');
        
        // Setup mock subscriber to track events
        MockSubscriber.SetTrackEventSequence(true);
        MockSubscriber.SetShouldAddValidationError(false);
        BindSubscription(MockSubscriber);
        
        // Execute registration
        CustomerRegistration.RegisterNewCustomer(Customer, RegistrationContext);
        
        // Verify event sequence
        EventSequence := MockSubscriber.GetEventSequence();
        Assert.AreEqual(2, EventSequence.Count, 'Should fire exactly 2 events');
        Assert.AreEqual('OnBeforeCustomerRegistration', EventSequence.Get(1), 'First event should be OnBefore');
        Assert.AreEqual('OnAfterCustomerCreation', EventSequence.Get(2), 'Second event should be OnAfter');
        
        // Verify parameters passed correctly
        VerifyCustomerParameterFidelity(MockSubscriber.GetLastCustomerParameter(), Customer);
        VerifyRegistrationContextParameter(MockSubscriber.GetLastContextParameter(), RegistrationContext);
        
        // Cleanup
        UnbindSubscription(MockSubscriber);
    end;

    /// <summary>
    /// Test validation error collection from multiple subscribers.
    /// Ensures all subscriber validation errors are collected and reported properly.
    /// </summary>
    /// <testScenario>
    /// Multiple subscribers add different validation errors:
    /// - Subscriber 1: Industry-specific validation
    /// - Subscriber 2: Credit rating validation  
    /// - Subscriber 3: Geographic restriction validation
    /// All errors should be collected and registration should fail with combined error message.
    /// </testScenario>
    [Test]
    procedure TestMultipleSubscriberValidationErrors()
    var
        Customer: Record Customer;
        RegistrationContext: Record "Registration Context";
        CustomerRegistration: Codeunit "Customer Registration Manager";
        IndustryValidator: Codeunit "Industry Validation Subscriber";
        CreditValidator: Codeunit "Credit Validation Subscriber";  
        GeoValidator: Codeunit "Geographic Validation Subscriber";
        ExpectedErrors: List of [Text];
        ErrorText: Text;
    begin
        // Initialize  
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Comprehensive Event Tests");
        
        // Setup customer that will fail multiple validations
        CreateCustomerWithValidationIssues(Customer);
        CreateRegistrationContext(RegistrationContext, 'IMPORT');
        
        // Setup expected validation errors
        ExpectedErrors.Add('Industry code RESTRICTED not allowed for new registrations');
        ExpectedErrors.Add('Credit rating insufficient for requested credit limit');
        ExpectedErrors.Add('Geographic region blocked for new customer registration');
        
        // Bind validation subscribers
        IndustryValidator.SetShouldRejectIndustry('RESTRICTED', true);
        CreditValidator.SetMinimumCreditRating('B');
        GeoValidator.SetBlockedRegions('EMEA');
        
        BindSubscription(IndustryValidator);
        BindSubscription(CreditValidator);
        BindSubscription(GeoValidator);
        
        // Execute registration (should fail)
        asserterror CustomerRegistration.RegisterNewCustomer(Customer, RegistrationContext);
        ErrorText := GetLastErrorText();
        
        // Verify all expected errors are included
        foreach ExpectedError in ExpectedErrors do
            Assert.IsTrue(StrPos(ErrorText, ExpectedError) > 0, 
                         StrSubstNo('Error text should contain: %1', ExpectedError));
        
        // Verify customer was not created
        Assert.IsFalse(Customer.Find(), 'Customer should not be created when validation fails');
        
        // Cleanup
        UnbindSubscription(IndustryValidator);
        UnbindSubscription(CreditValidator);
        UnbindSubscription(GeoValidator);
    end;

    /// <summary>
    /// Test business event JSON payload structure and content accuracy.
    /// Validates that published business events contain correct data and format.
    /// </summary>
    /// <payloadValidation>
    /// JSON payload validation covers:
    /// - Schema compliance with documented structure
    /// - Data accuracy (all values match source records)
    /// - Required field presence and correct data types
    /// - Optional field handling (null/undefined)
    /// - Nested object structure integrity
    /// - Array formatting for line items
    /// </payloadValidation>
    [Test]
    procedure TestOrderReleasedBusinessEventPayload()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        OrderEvents: Codeunit "Order Business Events";
        TelemetrySubscriber: Codeunit "Test Telemetry Subscriber";
        EventPayload: Text;
        PayloadJson: JsonObject;
        OrderObject: JsonObject;
        LinesArray: JsonArray;
    begin
        // Initialize
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Comprehensive Event Tests");
        BindSubscription(TelemetrySubscriber);
        
        // Create test order
        CreateReleasableTestOrder(SalesHeader, SalesLine);
        
        // Publish business event
        OrderEvents.PublishSalesOrderReleased(SalesHeader, SalesLine, 
                                             SalesHeader."Document Status"::Open, 
                                             "Order Release Context"::Manual);
        
        // Retrieve and parse event payload
        EventPayload := TelemetrySubscriber.GetLastBusinessEventPayload('SalesOrderReleased');
        Assert.IsTrue(EventPayload <> '', 'Business event payload should be captured');
        
        PayloadJson.ReadFrom(EventPayload);
        
        // Validate top-level event properties
        ValidateEventMetadata(PayloadJson, 'SalesOrderReleased', '1.2');
        
        // Validate order data accuracy
        Assert.IsTrue(PayloadJson.Get('order', OrderObject), 'Should contain order object');
        ValidateOrderData(OrderObject, SalesHeader);
        
        // Validate line items
        Assert.IsTrue(PayloadJson.Get('lines', LinesArray), 'Should contain lines array');
        ValidateOrderLines(LinesArray, SalesLine);
        
        // Cleanup
        UnbindSubscription(TelemetrySubscriber);
    end;

    /// <summary>
    /// Performance test measuring event overhead with multiple subscribers.
    /// Ensures events don't significantly impact business process performance.
    /// </summary>
    /// <performanceTargets>
    /// Performance targets:
    /// - Event publishing overhead < 50ms per event
    /// - 10 subscribers total overhead < 200ms
    /// - Memory usage increase < 10MB during event processing
    /// - No memory leaks after event completion
    /// </performanceTargets>
    [Test]
    procedure TestEventPerformanceWithMultipleSubscribers()
    var
        Customer: Record Customer;
        RegistrationContext: Record "Registration Context";
        CustomerRegistration: Codeunit "Customer Registration Manager";
        PerformanceSubscriber: array[10] of Codeunit "Performance Test Subscriber";
        StartTime: DateTime;
        EndTime: DateTime;
        Duration: Duration;
        MaxAllowedDuration: Duration;
        i: Integer;
    begin
        // Initialize
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Comprehensive Event Tests");
        MaxAllowedDuration := 200; // 200ms maximum
        
        // Setup multiple subscribers
        for i := 1 to ArrayLen(PerformanceSubscriber) do
            BindSubscription(PerformanceSubscriber[i]);
            
        // Setup test data
        CreateValidTestCustomer(Customer);
        CreateRegistrationContext(RegistrationContext, 'PERFORMANCE_TEST');
        
        // Measure registration performance
        StartTime := CurrentDateTime;
        CustomerRegistration.RegisterNewCustomer(Customer, RegistrationContext);
        EndTime := CurrentDateTime;
        
        Duration := EndTime - StartTime;
        
        // Verify performance target
        Assert.IsTrue(Duration < MaxAllowedDuration, 
                     StrSubstNo('Event processing took %1ms, should be under %2ms', Duration, MaxAllowedDuration));
        
        // Cleanup
        for i := 1 to ArrayLen(PerformanceSubscriber) do
            UnbindSubscription(PerformanceSubscriber[i]);
    end;
}
```

These comprehensive examples demonstrate how proper documentation transforms events from simple extension points into powerful, well-understood integration tools that enable confident extension development and reliable system integration.
