---
title: "AL Codeunit Creation Patterns"
description: "Comprehensive patterns for creating robust and maintainable AL codeunit objects with proper error handling, business logic implementation, and integration capabilities"
area: "code-creation"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "JsonObject", "HttpClient", "ErrorInfo"]
tags: ["al-codeunit-patterns", "business-logic", "error-handling", "integration-patterns", "validation-logic"]
---

# AL Codeunit Creation Patterns

## Overview

This guide provides comprehensive patterns for creating AL codeunit objects that implement business logic, handle integrations, and provide robust error handling. Codeunits are the workhorses of Business Central extensions and require careful design for maintainability and performance.

## Learning Objectives

- **Beginner**: Create basic codeunits with validation and error handling
- **Intermediate**: Implement complex business logic with integration patterns
- **Advanced**: Design integration codeunits with retry logic and monitoring
- **Expert**: Create event-driven architectures and architectural documentation

## 🟢 Basic Codeunit Patterns
**For new AL developers learning codeunit fundamentals**

### Simple Business Logic Codeunit

**Learning Objective**: Implement basic business validation and calculation logic

```al
// Basic business logic codeunit with proper structure
codeunit 50100 "Customer Rating Manager"
{
    Access = Public;
    
    /// <summary>
    /// Calculates the average rating for a customer
    /// </summary>
    /// <param name="CustomerNo">Customer number to calculate rating for</param>
    /// <returns>Average rating value</returns>
    procedure CalculateCustomerAverageRating(CustomerNo: Code[20]): Decimal
    var
        CustomerRating: Record "Customer Rating";
        TotalRating: Decimal;
        RatingCount: Integer;
    begin
        // Input validation
        if CustomerNo = '' then
            Error('Customer number cannot be empty.');
            
        // Validate customer exists
        ValidateCustomerExists(CustomerNo);
        
        // Calculate average rating
        CustomerRating.SetRange("Customer No.", CustomerNo);
        if CustomerRating.FindSet() then begin
            repeat
                TotalRating += CustomerRating."Rating Value";
                RatingCount += 1;
            until CustomerRating.Next() = 0;
            
            if RatingCount > 0 then
                exit(Round(TotalRating / RatingCount, 0.01))
            else
                exit(0);
        end else
            exit(0);
    end;
    
    /// <summary>
    /// Updates customer loyalty tier based on rating
    /// </summary>
    /// <param name="CustomerNo">Customer to update</param>
    procedure UpdateCustomerLoyaltyTier(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        AverageRating: Decimal;
        NewTierLevel: Enum "Customer Loyalty Tier";
    begin
        // Validate input
        if CustomerNo = '' then
            Error('Customer number cannot be empty.');
            
        // Get customer record
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 does not exist.', CustomerNo);
            
        // Calculate tier based on rating
        AverageRating := CalculateCustomerAverageRating(CustomerNo);
        NewTierLevel := DetermineTierLevel(AverageRating);
        
        // Update customer record
        if Customer."Loyalty Tier" <> NewTierLevel then begin
            Customer.Validate("Loyalty Tier", NewTierLevel);
            Customer.Modify(true);
            LogTierChange(CustomerNo, Customer."Loyalty Tier", NewTierLevel);
        end;
    end;
    
    /// <summary>
    /// Validates that a customer exists and is not blocked
    /// </summary>
    /// <param name="CustomerNo">Customer number to validate</param>
    local procedure ValidateCustomerExists(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 does not exist.', CustomerNo);
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked and cannot be processed.', CustomerNo);
    end;
    
    /// <summary>
    /// Determines loyalty tier based on average rating
    /// </summary>
    /// <param name="AverageRating">The customer's average rating</param>
    /// <returns>Appropriate tier level</returns>
    local procedure DetermineTierLevel(AverageRating: Decimal): Enum "Customer Loyalty Tier"
    begin
        case true of
            AverageRating >= 4.5:
                exit("Customer Loyalty Tier"::Platinum);
            AverageRating >= 4.0:
                exit("Customer Loyalty Tier"::Gold);
            AverageRating >= 3.5:
                exit("Customer Loyalty Tier"::Silver);
            AverageRating >= 3.0:
                exit("Customer Loyalty Tier"::Bronze);
            else
                exit("Customer Loyalty Tier"::None);
        end;
    end;
    
    /// <summary>
    /// Logs tier changes for audit purposes
    /// </summary>
    /// <param name="CustomerNo">Customer number</param>
    /// <param name="OldTier">Previous tier level</param>
    /// <param name="NewTier">New tier level</param>
    local procedure LogTierChange(CustomerNo: Code[20]; OldTier: Enum "Customer Loyalty Tier"; NewTier: Enum "Customer Loyalty Tier")
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            Database::Customer,
            ActivityLog.Status::Success,
            'Tier Change',
            'Customer Tier Updated',
            StrSubstNo('Customer %1 tier changed from %2 to %3', CustomerNo, OldTier, NewTier));
    end;
}
```

## 🟡 Intermediate Codeunit Patterns
**For developers comfortable with AL concepts**

### Complex Business Logic with Validation

**Learning Objective**: Implement sophisticated business rules with comprehensive error handling

```al
// Intermediate business logic codeunit with complex validation
codeunit 50101 "Loyalty Points Manager"
{
    Access = Public;
    
    /// <summary>
    /// Awards loyalty points to a customer with business rule validation
    /// </summary>
    /// <param name="CustomerNo">Customer to award points to</param>
    /// <param name="PointsToAward">Number of points to award</param>
    /// <param name="ReasonCode">Reason for awarding points</param>
    procedure AwardLoyaltyPoints(CustomerNo: Code[20]; PointsToAward: Integer; ReasonCode: Code[10])
    var
        CustomerLoyaltyPoints: Record "Customer Loyalty Points";
        Customer: Record Customer;
    begin
        // Comprehensive input validation
        ValidateAwardPointsParameters(CustomerNo, PointsToAward, ReasonCode);
        
        // Business rule validation
        ValidateAwardPointsBusinessRules(CustomerNo, PointsToAward);
        
        // Get or create loyalty points record
        if not CustomerLoyaltyPoints.Get(CustomerNo) then begin
            CustomerLoyaltyPoints.Init();
            CustomerLoyaltyPoints."Customer No." := CustomerNo;
            CustomerLoyaltyPoints.Insert(true);
        end;
        
        // Award points with transaction safety
        CustomerLoyaltyPoints.LockTable();
        CustomerLoyaltyPoints.Get(CustomerNo);
        CustomerLoyaltyPoints."Current Points" += PointsToAward;
        CustomerLoyaltyPoints."Lifetime Points" += PointsToAward;
        CustomerLoyaltyPoints.Modify(true);
        
        // Create points history entry
        CreatePointsHistoryEntry(CustomerNo, PointsToAward, ReasonCode, 'AWARDED');
        
        // Update customer tier if necessary
        UpdateCustomerTierFromPoints(CustomerNo);
        
        // Send notification if configured
        SendPointsAwardedNotification(CustomerNo, PointsToAward);
        
        Commit();
    end;
    
    /// <summary>
    /// Redeems loyalty points with validation and business rules
    /// </summary>
    /// <param name="CustomerNo">Customer redeeming points</param>
    /// <param name="PointsToRedeem">Number of points to redeem</param>
    /// <param name="RedemptionType">Type of redemption</param>
    procedure RedeemLoyaltyPoints(CustomerNo: Code[20]; PointsToRedeem: Integer; RedemptionType: Code[10])
    var
        CustomerLoyaltyPoints: Record "Customer Loyalty Points";
        RedemptionValue: Decimal;
    begin
        // Validate parameters and business rules
        ValidateRedeemPointsParameters(CustomerNo, PointsToRedeem, RedemptionType);
        ValidateRedeemPointsBusinessRules(CustomerNo, PointsToRedeem);
        
        // Check sufficient points balance
        CustomerLoyaltyPoints.Get(CustomerNo);
        if CustomerLoyaltyPoints."Current Points" < PointsToRedeem then
            Error('Customer %1 has insufficient points. Current balance: %2, Requested: %3',
                CustomerNo, CustomerLoyaltyPoints."Current Points", PointsToRedeem);
        
        // Calculate redemption value
        RedemptionValue := CalculateRedemptionValue(PointsToRedeem, RedemptionType);
        
        // Process redemption with transaction safety
        CustomerLoyaltyPoints.LockTable();
        CustomerLoyaltyPoints.Get(CustomerNo);
        CustomerLoyaltyPoints."Current Points" -= PointsToRedeem;
        CustomerLoyaltyPoints."Points Redeemed" += PointsToRedeem;
        CustomerLoyaltyPoints.Modify(true);
        
        // Create redemption history
        CreateRedemptionHistoryEntry(CustomerNo, PointsToRedeem, RedemptionType, RedemptionValue);
        
        // Update customer tier
        UpdateCustomerTierFromPoints(CustomerNo);
        
        Commit();
    end;
    
    /// <summary>
    /// Validates parameters for awarding points
    /// </summary>
    local procedure ValidateAwardPointsParameters(CustomerNo: Code[20]; PointsToAward: Integer; ReasonCode: Code[10])
    var
        Customer: Record Customer;
        ReasonCodeRec: Record "Reason Code";
    begin
        if CustomerNo = '' then
            Error('Customer number cannot be empty.');
            
        if PointsToAward <= 0 then
            Error('Points to award must be greater than zero.');
            
        if ReasonCode = '' then
            Error('Reason code is required when awarding points.');
            
        // Validate customer exists
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 does not exist.', CustomerNo);
            
        // Validate reason code exists
        if not ReasonCodeRec.Get(ReasonCode) then
            Error('Reason code %1 does not exist.', ReasonCode);
    end;
    
    /// <summary>
    /// Validates business rules for awarding points
    /// </summary>
    local procedure ValidateAwardPointsBusinessRules(CustomerNo: Code[20]; PointsToAward: Integer)
    var
        Customer: Record Customer;
        LoyaltySetup: Record "Loyalty Program Setup";
        TodaysPoints: Integer;
    begin
        Customer.Get(CustomerNo);
        
        // Check if customer is eligible for loyalty program
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Cannot award points to blocked customer %1.', CustomerNo);
            
        // Check daily limits
        LoyaltySetup.Get();
        TodaysPoints := GetTodaysPointsAwarded(CustomerNo);
        
        if (TodaysPoints + PointsToAward) > LoyaltySetup."Max Daily Points Award" then
            Error('Daily points limit exceeded. Current: %1, Requested: %2, Limit: %3',
                TodaysPoints, PointsToAward, LoyaltySetup."Max Daily Points Award");
                
        // Check single transaction limits
        if PointsToAward > LoyaltySetup."Max Single Award" then
            Error('Single award limit exceeded. Requested: %1, Limit: %2',
                PointsToAward, LoyaltySetup."Max Single Award");
    end;
    
    /// <summary>
    /// Gets total points awarded today for a customer
    /// </summary>
    local procedure GetTodaysPointsAwarded(CustomerNo: Code[20]): Integer
    var
        LoyaltyPointsHistory: Record "Loyalty Points History";
    begin
        LoyaltyPointsHistory.SetRange("Customer No.", CustomerNo);
        LoyaltyPointsHistory.SetRange("Transaction Date", Today());
        LoyaltyPointsHistory.SetRange("Transaction Type", 'AWARDED');
        LoyaltyPointsHistory.CalcSums("Points Amount");
        exit(LoyaltyPointsHistory."Points Amount");
    end;
    
    /// <summary>
    /// Creates points history entry for tracking
    /// </summary>
    local procedure CreatePointsHistoryEntry(CustomerNo: Code[20]; PointsAmount: Integer; ReasonCode: Code[10]; TransactionType: Code[10])
    var
        LoyaltyPointsHistory: Record "Loyalty Points History";
    begin
        LoyaltyPointsHistory.Init();
        LoyaltyPointsHistory."Entry No." := GetNextHistoryEntryNo();
        LoyaltyPointsHistory."Customer No." := CustomerNo;
        LoyaltyPointsHistory."Transaction Date" := Today();
        LoyaltyPointsHistory."Transaction Time" := Time();
        LoyaltyPointsHistory."Points Amount" := PointsAmount;
        LoyaltyPointsHistory."Reason Code" := ReasonCode;
        LoyaltyPointsHistory."Transaction Type" := TransactionType;
        LoyaltyPointsHistory."User ID" := UserId();
        LoyaltyPointsHistory.Insert(true);
    end;
    
    local procedure GetNextHistoryEntryNo(): Integer
    var
        LoyaltyPointsHistory: Record "Loyalty Points History";
    begin
        LoyaltyPointsHistory.LockTable();
        if LoyaltyPointsHistory.FindLast() then
            exit(LoyaltyPointsHistory."Entry No." + 1)
        else
            exit(1);
    end;
}
```

## 🔴 Advanced Codeunit Patterns
**For experienced developers handling integrations**

### Integration Codeunit with Retry Logic

**Learning Objective**: Create robust external integrations with comprehensive error handling

```al
// Advanced integration codeunit with retry logic and monitoring
codeunit 50200 "External Rating API Manager"
{
    Access = Public;
    
    var
        MaxRetryAttempts: Integer;
        RetryDelaySeconds: Integer;
        
    trigger OnRun()
    begin
        MaxRetryAttempts := 3;
        RetryDelaySeconds := 5;
    end;
    
    /// <summary>
    /// Syncs customer ratings from external API with retry logic
    /// </summary>
    /// <param name="CustomerNo">Customer to sync ratings for</param>
    procedure SyncCustomerRatingsFromAPI(CustomerNo: Code[20]): Boolean
    var
        IntegrationLogEntry: Record "Integration Log Entry";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        RetryCount: Integer;
        Success: Boolean;
        ErrorMessage: Text;
    begin
        // Validate input
        if CustomerNo = '' then
            Error('Customer number cannot be empty.');
            
        // Initialize integration logging
        CreateIntegrationLogEntry(IntegrationLogEntry, CustomerNo, 'RATING_SYNC', 'Started');
        
        // Retry logic with exponential backoff
        for RetryCount := 1 to MaxRetryAttempts do begin
            ClearLastError();
            
            if AttemptRatingSync(CustomerNo, HttpClient, HttpResponseMessage) then begin
                Success := ProcessSyncResponse(CustomerNo, HttpResponseMessage);
                if Success then begin
                    UpdateIntegrationLogEntry(IntegrationLogEntry, 'Completed', '');
                    LogSuccessfulSync(CustomerNo, RetryCount);
                    exit(true);
                end else begin
                    ErrorMessage := 'Failed to process sync response';
                    LogFailedAttempt(CustomerNo, ErrorMessage, RetryCount);
                end;
            end else begin
                ErrorMessage := GetLastErrorText();
                LogFailedAttempt(CustomerNo, ErrorMessage, RetryCount);
            end;
            
            // Exponential backoff before retry
            if RetryCount < MaxRetryAttempts then
                Sleep(RetryDelaySeconds * RetryCount * 1000);
        end;
        
        // Final failure handling
        UpdateIntegrationLogEntry(IntegrationLogEntry, 'Failed', ErrorMessage);
        HandleSyncFailure(CustomerNo, ErrorMessage);
        exit(false);
    end;
    
    /// <summary>
    /// Attempts to sync ratings from external API
    /// </summary>
    [TryFunction]
    local procedure AttemptRatingSync(CustomerNo: Code[20]; var HttpClient: HttpClient; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        RequestUri: Text;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        AuthToken: Text;
    begin
        // Build request URI
        RequestUri := BuildRatingAPIUri(CustomerNo);
        
        // Setup authentication
        AuthToken := GetAPIAuthToken();
        if AuthToken = '' then
            Error('Failed to obtain API authentication token.');
            
        // Configure HTTP client
        HttpClient.Clear();
        HttpClient.SetBaseAddress(GetAPIBaseUrl());
        HttpClient.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Bearer %1', AuthToken));
        HttpClient.DefaultRequestHeaders().Add('User-Agent', 'BusinessCentral-RatingSync/1.0');
        HttpClient.Timeout(30000); // 30 second timeout
        
        // Make API call
        exit(HttpClient.Get(RequestUri, HttpResponseMessage));
    end;
    
    /// <summary>
    /// Processes successful sync response
    /// </summary>
    local procedure ProcessSyncResponse(CustomerNo: Code[20]; HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ResponseContent: Text;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        RatingsArray: JsonArray;
        Success: Boolean;
    begin
        // Validate response status
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            LogAPIError(CustomerNo, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase());
            exit(false);
        end;
        
        // Get response content
        if not HttpResponseMessage.Content().ReadAs(ResponseContent) then begin
            LogAPIError(CustomerNo, 0, 'Failed to read response content');
            exit(false);
        end;
        
        // Parse JSON response
        if not JsonResponse.ReadFrom(ResponseContent) then begin
            LogAPIError(CustomerNo, 0, 'Invalid JSON response format');
            exit(false);
        end;
        
        // Extract and process ratings
        if JsonResponse.Get('ratings', JsonToken) then begin
            RatingsArray := JsonToken.AsArray();
            Success := ProcessRatingsData(CustomerNo, RatingsArray);
        end else begin
            LogAPIError(CustomerNo, 0, 'Missing ratings data in response');
            Success := false;
        end;
        
        exit(Success);
    end;
    
    /// <summary>
    /// Processes ratings data from API response
    /// </summary>
    local procedure ProcessRatingsData(CustomerNo: Code[20]; RatingsArray: JsonArray): Boolean
    var
        JsonToken: JsonToken;
        RatingObject: JsonObject;
        CustomerRating: Record "Customer Rating";
        RatingValue: Decimal;
        RatingDate: Date;
        ReviewerName: Text[100];
        Comments: Text[250];
        ProcessedCount: Integer;
    begin
        // Process each rating in the array
        foreach JsonToken in RatingsArray do begin
            RatingObject := JsonToken.AsObject();
            
            // Extract rating data
            if ExtractRatingData(RatingObject, RatingValue, RatingDate, ReviewerName, Comments) then begin
                // Create or update rating record
                if not RatingExists(CustomerNo, RatingDate, ReviewerName) then begin
                    CreateRatingRecord(CustomerNo, RatingValue, RatingDate, ReviewerName, Comments);
                    ProcessedCount += 1;
                end;
            end;
        end;
        
        // Log processing results
        LogRatingProcessingResults(CustomerNo, RatingsArray.Count(), ProcessedCount);
        
        exit(ProcessedCount > 0);
    end;
    
    /// <summary>
    /// Handles sync failure with appropriate notifications
    /// </summary>
    local procedure HandleSyncFailure(CustomerNo: Code[20]; ErrorMessage: Text)
    var
        NotificationMgt: Codeunit "Notification Management";
        ActivityLog: Record "Activity Log";
    begin
        // Send notification to administrators
        NotificationMgt.SendNotification(
            StrSubstNo('Rating sync failed for customer %1: %2', CustomerNo, ErrorMessage),
            "Notification Entry Type"::Error);
            
        // Log critical failure for monitoring
        ActivityLog.LogActivity(
            Database::Customer,
            ActivityLog.Status::Failed,
            'External Rating Sync',
            'Sync Failure',
            StrSubstNo('Failed to sync ratings for customer %1 after %2 attempts. Error: %3',
                CustomerNo, MaxRetryAttempts, ErrorMessage));
                
        // Create follow-up task if configured
        CreateSyncFailureFollowUpTask(CustomerNo, ErrorMessage);
    end;
    
    /// <summary>
    /// Creates integration log entry for tracking
    /// </summary>
    local procedure CreateIntegrationLogEntry(var IntegrationLogEntry: Record "Integration Log Entry"; CustomerNo: Code[20]; IntegrationType: Text[50]; Status: Text[20])
    begin
        IntegrationLogEntry.Init();
        IntegrationLogEntry."Entry No." := GetNextLogEntryNo();
        IntegrationLogEntry."Integration Type" := IntegrationType;
        IntegrationLogEntry."Customer No." := CustomerNo;
        IntegrationLogEntry.Status := Status;
        IntegrationLogEntry."Start DateTime" := CurrentDateTime();
        IntegrationLogEntry."User ID" := UserId();
        IntegrationLogEntry.Insert(true);
    end;
    
    local procedure UpdateIntegrationLogEntry(var IntegrationLogEntry: Record "Integration Log Entry"; Status: Text[20]; ErrorMessage: Text)
    begin
        IntegrationLogEntry.Status := Status;
        IntegrationLogEntry."End DateTime" := CurrentDateTime();
        if ErrorMessage <> '' then
            IntegrationLogEntry."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(IntegrationLogEntry."Error Message"));
        IntegrationLogEntry.Modify(true);
    end;
}
```

## ⚫ Expert Codeunit Patterns
**For architects and senior developers**

### Event-Driven Architecture Codeunit

**Learning Objective**: Design event-driven systems with comprehensive monitoring and documentation

```al
// Expert-level event-driven codeunit with architectural documentation
codeunit 50300 "Customer Event Orchestrator"
{
    Access = Public;
    
    /// <summary>
    /// Orchestrates customer-related events with proper event sequencing
    /// Architectural Decision: Event-driven pattern for loose coupling and extensibility
    /// Documented in Azure DevOps Wiki: Architecture/Event-Driven-Patterns.md
    /// </summary>
    /// <param name="CustomerNo">Customer triggering the event</param>
    /// <param name="EventType">Type of customer event</param>
    procedure ProcessCustomerEvent(CustomerNo: Code[20]; EventType: Enum "Customer Event Type")
    var
        EventProcessingContext: Record "Event Processing Context";
        PerformanceMonitor: Codeunit "Performance Monitor";
        MonitoringSession: Guid;
    begin
        // Initialize performance monitoring
        MonitoringSession := PerformanceMonitor.StartSession('Customer Event Processing');
        
        // Create processing context for event tracking
        CreateEventProcessingContext(EventProcessingContext, CustomerNo, EventType);
        
        try
            // Process event with proper sequencing
            case EventType of
                "Customer Event Type"::"Rating Changed":
                    ProcessRatingChangedEvent(CustomerNo, EventProcessingContext);
                "Customer Event Type"::"Loyalty Points Awarded":
                    ProcessLoyaltyPointsAwardedEvent(CustomerNo, EventProcessingContext);
                "Customer Event Type"::"Tier Level Changed":
                    ProcessTierLevelChangedEvent(CustomerNo, EventProcessingContext);
                "Customer Event Type"::"Profile Updated":
                    ProcessProfileUpdatedEvent(CustomerNo, EventProcessingContext);
                else
                    Error('Unknown event type: %1', EventType);
            end;
            
            // Mark event as successfully processed
            CompleteEventProcessing(EventProcessingContext, true, '');
            
        except
            // Handle event processing failure
            CompleteEventProcessing(EventProcessingContext, false, GetLastErrorText());
            
            // Re-raise exception for caller handling
            Error(GetLastErrorText());
        end;
        
        // Complete performance monitoring
        PerformanceMonitor.EndSession(MonitoringSession);
    end;
    
    /// <summary>
    /// Processes rating changed event with cascading updates
    /// </summary>
    local procedure ProcessRatingChangedEvent(CustomerNo: Code[20]; var EventProcessingContext: Record "Event Processing Context")
    var
        Customer: Record Customer;
        OldTierLevel: Enum "Customer Loyalty Tier";
        NewTierLevel: Enum "Customer Loyalty Tier";
        LoyaltyPointsManager: Codeunit "Loyalty Points Manager";
        CustomerRatingManager: Codeunit "Customer Rating Manager";
    begin
        // Get current tier level before updates
        if Customer.Get(CustomerNo) then
            OldTierLevel := Customer."Loyalty Tier";
            
        // Update customer tier based on new rating
        CustomerRatingManager.UpdateCustomerLoyaltyTier(CustomerNo);
        
        // Check if tier changed
        if Customer.Get(CustomerNo) then
            NewTierLevel := Customer."Loyalty Tier";
            
        // If tier changed, award bonus points
        if NewTierLevel <> OldTierLevel then begin
            AwardTierChangeBonus(CustomerNo, OldTierLevel, NewTierLevel);
            
            // Publish tier change event for other subscribers
            PublishTierChangedEvent(CustomerNo, OldTierLevel, NewTierLevel);
        end;
        
        // Publish rating changed event
        PublishRatingChangedEvent(CustomerNo);
        
        // Update event processing context
        UpdateEventProcessingStep(EventProcessingContext, 'Rating processing completed');
    end;
    
    /// <summary>
    /// Publishes integration events for event subscribers
    /// Architecture Pattern: Publisher-Subscriber for loose coupling
    /// </summary>
    /// <param name="CustomerNo">Customer number</param>
    /// <param name="OldTier">Previous tier level</param>
    /// <param name="NewTier">New tier level</param>
    [IntegrationEvent(false, false)]
    procedure OnCustomerTierChanged(CustomerNo: Code[20]; OldTier: Enum "Customer Loyalty Tier"; NewTier: Enum "Customer Loyalty Tier")
    begin
        // Event for subscribers to handle tier changes
        // Examples: Update pricing, send notifications, trigger workflows
    end;
    
    /// <summary>
    /// Publishes rating changed event
    /// </summary>
    /// <param name="CustomerNo">Customer number</param>
    [IntegrationEvent(false, false)]
    procedure OnCustomerRatingChanged(CustomerNo: Code[20])
    begin
        // Event for rating-related processing by subscribers
    end;
    
    /// <summary>
    /// Documents architectural decisions for team reference
    /// Expert Pattern: Living architecture documentation
    /// </summary>
    /// <param name="DecisionContext">Context of the architectural decision</param>
    /// <param name="DecisionRationale">Reasoning behind the decision</param>
    /// <param name="Alternatives">Alternative approaches considered</param>
    procedure DocumentArchitecturalDecision(DecisionContext: Text; DecisionRationale: Text; Alternatives: Text)
    var
        ArchitecturalDecision: Record "Architectural Decision";
        DecisionGuid: Guid;
    begin
        // Create architectural decision record for team reference
        DecisionGuid := CreateGuid();
        
        ArchitecturalDecision.Init();
        ArchitecturalDecision."Decision ID" := DecisionGuid;
        ArchitecturalDecision."Decision Date" := Today();
        ArchitecturalDecision."Decision Context" := CopyStr(DecisionContext, 1, MaxStrLen(ArchitecturalDecision."Decision Context"));
        ArchitecturalDecision."Rationale" := CopyStr(DecisionRationale, 1, MaxStrLen(ArchitecturalDecision."Rationale"));
        ArchitecturalDecision."Alternatives Considered" := CopyStr(Alternatives, 1, MaxStrLen(ArchitecturalDecision."Alternatives Considered"));
        ArchitecturalDecision."Architect" := UserId();
        ArchitecturalDecision.Insert(true);
        
        // Create Azure DevOps work item for architectural documentation
        CreateArchitecturalDocumentationTask(DecisionGuid, DecisionContext);
    end;
    
    /// <summary>
    /// Provides mentoring guidance to junior developers
    /// Expert Responsibility: Knowledge sharing and team development
    /// </summary>
    /// <param name="DeveloperUserId">User ID of developer receiving guidance</param>
    /// <param name="TopicArea">Area of guidance needed</param>
    /// <param name="GuidanceLevel">Level of detail needed</param>
    procedure ProvideMentoringGuidance(DeveloperUserId: Code[50]; TopicArea: Text[100]; GuidanceLevel: Option Basic,Intermediate,Advanced)
    var
        MentoringSession: Record "Mentoring Session";
        GuidanceContent: Text;
    begin
        // Create mentoring session record
        CreateMentoringSession(MentoringSession, DeveloperUserId, TopicArea, GuidanceLevel);
        
        // Generate appropriate guidance content
        GuidanceContent := GenerateGuidanceContent(TopicArea, GuidanceLevel);
        
        // Log mentoring activity for tracking
        LogMentoringActivity(DeveloperUserId, TopicArea, GuidanceContent);
        
        // Send guidance notification
        SendMentoringGuidance(DeveloperUserId, GuidanceContent);
    end;
    
    /// <summary>
    /// Creates event processing context for tracking and monitoring
    /// </summary>
    local procedure CreateEventProcessingContext(var EventProcessingContext: Record "Event Processing Context"; CustomerNo: Code[20]; EventType: Enum "Customer Event Type")
    begin
        EventProcessingContext.Init();
        EventProcessingContext."Context ID" := CreateGuid();
        EventProcessingContext."Customer No." := CustomerNo;
        EventProcessingContext."Event Type" := EventType;
        EventProcessingContext."Start DateTime" := CurrentDateTime();
        EventProcessingContext.Status := EventProcessingContext.Status::Processing;
        EventProcessingContext."User ID" := UserId();
        EventProcessingContext.Insert(true);
    end;
    
    /// <summary>
    /// Completes event processing with success/failure tracking
    /// </summary>
    local procedure CompleteEventProcessing(var EventProcessingContext: Record "Event Processing Context"; Success: Boolean; ErrorMessage: Text)
    begin
        EventProcessingContext."End DateTime" := CurrentDateTime();
        if Success then
            EventProcessingContext.Status := EventProcessingContext.Status::Completed
        else begin
            EventProcessingContext.Status := EventProcessingContext.Status::Failed;
            EventProcessingContext."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(EventProcessingContext."Error Message"));
        end;
        EventProcessingContext.Modify(true);
    end;
}
```

## AI Guidance Integration

### Context-Aware Codeunit Suggestions

**Proactive AI Behavior**: When creating codeunits, Copilot suggests:
- Input validation patterns based on parameter types
- Error handling approaches for business logic
- Testing strategies for complex validation rules
- Integration patterns for external system connections
- Performance considerations for data-intensive operations

### Educational Escalation

**Weak Prompt**: "Create a codeunit"
**Enhanced**: "Create a Business Central codeunit for customer loyalty management with input validation patterns from error-handling-principles.md, business logic testing from testing-workflow-integration.md, and integration monitoring from performance-optimization-guidelines.md"
**Educational Note**: Enhanced prompts specify business purpose, validation patterns, testing approach, and monitoring requirements for comprehensive codeunit design.

## DevOps Integration

### Work Item Documentation

When creating codeunits, update Azure DevOps work items with:
- **Business Logic Purpose**: What business requirements the codeunit fulfills
- **Integration Points**: External systems or APIs the codeunit interacts with
- **Error Handling Strategy**: How errors are managed and logged
- **Testing Approach**: Unit tests and integration test scenarios
- **Performance Considerations**: Expected load and optimization strategies

### Quality Gates

- **Design Review**: Validate codeunit patterns against architectural standards
- **Implementation Review**: Verify error handling, validation, and logging
- **Testing Review**: Confirm comprehensive test coverage
- **Performance Review**: Validate performance requirements are met

## Success Metrics

- ✅ Codeunits include comprehensive input validation
- ✅ Error handling follows established patterns
- ✅ Business logic is properly documented and tested
- ✅ Integration codeunits include retry logic and monitoring
- ✅ Event-driven patterns support extensibility without modification
- ✅ Performance considerations are documented and validated

**This guide ensures codeunit development follows best practices while building developer expertise and maintaining quality standards.**
