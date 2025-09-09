---
title: "Graceful Obsoleting Patterns"
description: "Graceful obsoleting patterns using Obsolete attributes for backward-compatible API evolution and function migration in Business Central"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Page", "Table"]
variable_types: ["Record", "Variant"]
tags: ["obsolete-patterns", "backward-compatibility", "api-evolution", "deprecation-management", "version-strategy"]
---

# Graceful Obsoleting Patterns

## Overview

This guide provides comprehensive patterns for gracefully obsoleting functions, procedures, and APIs in Business Central using the Obsolete attribute. These patterns ensure backward compatibility while guiding developers toward modern implementations and maintaining clear migration paths.

## Learning Objectives

- **Beginner**: Understand Obsolete attribute basics and simple deprecation
- **Intermediate**: Implement complex obsoleting strategies with migration guidance
- **Advanced**: Design backward-compatible API evolution patterns
- **Expert**: Create enterprise obsoleting frameworks with automated migration

## 🟢 Basic Obsoleting Patterns
**For developers new to deprecation management**

### Simple Function Obsoleting

**Learning Objective**: Mark functions as obsolete while providing clear migration guidance and maintaining backward compatibility

```al
// Basic obsoleting patterns with clear migration paths
codeunit 50130 "Basic Obsoleting Examples"
{
    /// <summary>
    /// Original function - being phased out
    /// This demonstrates basic obsoleting with migration guidance
    /// </summary>
    [Obsolete('Use CalculateCustomerDiscountAdvanced instead', '25.0')]
    procedure CalculateCustomerDiscount(CustomerNo: Code[20]; Amount: Decimal): Decimal
    var
        Customer: Record Customer;
    begin
        // Maintain backward compatibility while guiding users to new method
        if Customer.Get(CustomerNo) then
            exit(CalculateCustomerDiscountAdvanced(CustomerNo, Amount, Customer."Customer Discount Group"));
        
        exit(0);
    end;
    
    /// <summary>
    /// New enhanced function with additional parameters
    /// This is the recommended replacement
    /// </summary>
    procedure CalculateCustomerDiscountAdvanced(CustomerNo: Code[20]; Amount: Decimal; DiscountGroup: Code[20]): Decimal
    var
        Customer: Record Customer;
        DiscountCalculation: Record "Customer Discount";
        DiscountPercentage: Decimal;
    begin
        // Enhanced logic with better performance and features
        if not Customer.Get(CustomerNo) then
            exit(0);
        
        // Use discount group for more precise calculation
        DiscountCalculation.SetRange("Customer Discount Group", DiscountGroup);
        DiscountCalculation.SetFilter("Minimum Amount", '<=%1', Amount);
        if DiscountCalculation.FindLast() then
            DiscountPercentage := DiscountCalculation."Discount %"
        else
            DiscountPercentage := Customer."Default Discount %";
        
        exit(Amount * DiscountPercentage / 100);
    end;
    
    /// <summary>
    /// Shows proper obsoleting with detailed migration instructions
    /// </summary>
    [Obsolete('Use ProcessSalesOrderModern with enhanced error handling. See migration guide: ProcessSalesOrderModern(SalesHeader, true, ErrorHandling)', '24.5')]
    procedure ProcessSalesOrder(var SalesHeader: Record "Sales Header"): Boolean
    var
        ErrorHandling: Enum "Error Handling Method";
    begin
        // Forward call to new method with default error handling
        ErrorHandling := ErrorHandling::"Show Error";
        exit(ProcessSalesOrderModern(SalesHeader, true, ErrorHandling));
    end;
    
    /// <summary>
    /// Modern replacement with enhanced capabilities
    /// </summary>
    procedure ProcessSalesOrderModern(var SalesHeader: Record "Sales Header"; ValidateLines: Boolean; ErrorHandling: Enum "Error Handling Method"): Boolean
    var
        SalesLine: Record "Sales Line";
        ProcessingResult: Boolean;
        ErrorMessage: Text;
    begin
        ProcessingResult := true;
        
        try
            // Enhanced processing logic
            if ValidateLines then
                ValidateSalesLinesBeforeProcessing(SalesHeader);
            
            // Process order with improved logic
            ExecuteOrderProcessing(SalesHeader);
            
        except
            ErrorMessage := GetLastErrorText();
            ProcessingResult := false;
            
            case ErrorHandling of
                ErrorHandling::"Show Error":
                    Error(ErrorMessage);
                ErrorHandling::"Log Error":
                    LogProcessingError(SalesHeader."No.", ErrorMessage);
                ErrorHandling::"Silent Fail":
                    ; // Do nothing
            end;
        end;
        
        exit(ProcessingResult);
    end;
    
    /// <summary>
    /// Demonstrates phased obsoleting with intermediate migration step
    /// Phase 1: Mark as obsolete but maintain full functionality
    /// </summary>
    [Obsolete('This function will be removed in version 26.0. Migrate to GetCustomerInfoV2 for enhanced functionality', '24.0')]
    procedure GetCustomerInfo(CustomerNo: Code[20]) CustomerInfo: Text
    var
        Customer: Record Customer;
    begin
        // Maintain exact same functionality for backward compatibility
        if Customer.Get(CustomerNo) then
            CustomerInfo := StrSubstNo('%1|%2|%3', Customer.Name, Customer.City, Customer."Phone No.")
        else
            CustomerInfo := 'Customer not found';
    end;
    
    /// <summary>
    /// Enhanced replacement function with structured return data
    /// </summary>
    procedure GetCustomerInfoV2(CustomerNo: Code[20]) CustomerData: JsonObject
    var
        Customer: Record Customer;
        ContactInfo: JsonObject;
        AddressInfo: JsonObject;
    begin
        if Customer.Get(CustomerNo) then begin
            // Structured data return with enhanced information
            CustomerData.Add('customerNo', CustomerNo);
            CustomerData.Add('name', Customer.Name);
            CustomerData.Add('blocked', Customer.Blocked);
            
            // Contact information object
            ContactInfo.Add('phoneNo', Customer."Phone No.");
            ContactInfo.Add('email', Customer."E-Mail");
            ContactInfo.Add('homePage', Customer."Home Page");
            CustomerData.Add('contactInfo', ContactInfo);
            
            // Address information object
            AddressInfo.Add('address', Customer.Address);
            AddressInfo.Add('city', Customer.City);
            AddressInfo.Add('postCode', Customer."Post Code");
            AddressInfo.Add('countryRegionCode', Customer."Country/Region Code");
            CustomerData.Add('addressInfo', AddressInfo);
        end else begin
            CustomerData.Add('error', 'Customer not found');
        end;
    end;
}
```

### Event Obsoleting Patterns

**Learning Objective**: Obsolete events while maintaining subscriber compatibility and providing clear migration paths

```al
// Event obsoleting with subscriber migration guidance
codeunit 50131 "Event Obsoleting Examples"
{
    /// <summary>
    /// Original event - being replaced with enhanced version
    /// Maintains publisher-subscriber contract during transition
    /// </summary>
    [Obsolete('Use OnBeforeCustomerValidationAdvanced with additional context parameters', '25.0')]
    [IntegrationEvent(false, false)]
    procedure OnBeforeCustomerValidation(var Customer: Record Customer)
    begin
        // Event body remains empty - publishers should not contain logic
    end;
    
    /// <summary>
    /// Enhanced replacement event with additional context
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnBeforeCustomerValidationAdvanced(var Customer: Record Customer; ValidationContext: Text; var IsHandled: Boolean)
    begin
        // Enhanced event with additional parameters for better control
    end;
    
    /// <summary>
    /// Demonstrates dual event publishing for smooth migration
    /// </summary>
    local procedure ValidateCustomerWithEvents(var Customer: Record Customer; Context: Text)
    var
        IsHandled: Boolean;
    begin
        // Publish both old and new events during transition period
        OnBeforeCustomerValidation(Customer); // Old event for backward compatibility
        OnBeforeCustomerValidationAdvanced(Customer, Context, IsHandled); // New event
        
        if not IsHandled then begin
            // Perform validation logic only if not handled by subscribers
            PerformCustomerValidation(Customer, Context);
        end;
    end;
    
    /// <summary>
    /// Business event obsoleting with migration timeline
    /// </summary>
    [Obsolete('This event will be removed in version 27.0. Use OnSalesOrderStatusChanged with structured event data', '25.0')]
    [BusinessEvent(false)]
    procedure OnSalesOrderProcessed(SalesOrderNo: Code[20]; ProcessedBy: Code[50])
    begin
        // Business event - empty implementation
    end;
    
    /// <summary>
    /// Modern business event with structured data
    /// </summary>
    [BusinessEvent(false)]
    procedure OnSalesOrderStatusChanged(SalesOrderEventData: JsonObject)
    var
        SalesOrderNo: Code[20];
        ProcessedBy: Code[50];
        EventDataText: Text;
    begin
        // Enhanced business event with structured data
        // Event data includes: OrderNo, ProcessedBy, Status, Timestamp, Additional Context
    end;
    
    /// <summary>
    /// Publishing both events during transition for backward compatibility
    /// </summary>
    local procedure PublishSalesOrderEvents(SalesOrderNo: Code[20]; ProcessedBy: Code[50]; Status: Text)
    var
        EventData: JsonObject;
    begin
        // Publish old event for existing subscribers
        OnSalesOrderProcessed(SalesOrderNo, ProcessedBy);
        
        // Publish new structured event
        EventData.Add('orderNo', SalesOrderNo);
        EventData.Add('processedBy', ProcessedBy);
        EventData.Add('status', Status);
        EventData.Add('timestamp', CurrentDateTime());
        EventData.Add('version', '2.0');
        
        OnSalesOrderStatusChanged(EventData);
    end;
}
```

## 🟡 Intermediate Obsoleting Strategies
**For developers managing complex API evolution**

### API Version Management

**Learning Objective**: Implement sophisticated API versioning with graceful obsoleting and automated migration guidance

```al
// Advanced API obsoleting with version management
page 50200 "Customer API v1"
{
    APIPublisher = 'MyCompany';
    APIGroup = 'customers';
    APIVersion = 'v1.0';
    
    // Mark entire API version as obsolete
    [Obsolete('API v1.0 is deprecated. Migrate to v2.0 for enhanced features and better performance. See migration guide at docs.example.com/api-migration', '25.0')]
    EntityName = 'customer';
    EntitySetName = 'customers';
    
    SourceTable = Customer;
    DelayedInsert = true;
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                
                // Obsoleted field with migration guidance
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                    
                    // Mark specific field as obsolete within API
                    [Obsolete('Use contactInfo.phoneNo in API v2.0 for structured contact data', '24.5')]
                    ApplicationArea = All;
                }
                
                field(creditLimit; Rec."Credit Limit (LCY)")
                {
                    Caption = 'Credit Limit';
                    
                    // Field being replaced with enhanced validation
                    [Obsolete('Use creditLimitInfo in API v2.0 for currency-aware credit limits', '24.5')]
                    ApplicationArea = All;
                }
            }
        }
    }
    
    // Obsoleted action with migration path
    actions
    {
        area(processing)
        {
            action(calculateDiscount)
            {
                Caption = 'Calculate Discount';
                
                [Obsolete('Use POST /customers/{id}/discounts/calculate in API v2.0 for enhanced discount calculation', '24.0')]
                trigger OnAction()
                var
                    DiscountCalculation: Codeunit "Discount Calculation";
                begin
                    // Maintain backward compatibility while guiding to new endpoint
                    Message('This action is deprecated. Please use the new discount calculation endpoint.');
                end;
            }
        }
    }
}

// Modern API version with enhanced capabilities
page 50201 "Customer API v2"
{
    APIPublisher = 'MyCompany';
    APIGroup = 'customers';
    APIVersion = 'v2.0';
    
    EntityName = 'customer';
    EntitySetName = 'customers';
    
    SourceTable = Customer;
    DelayedInsert = true;
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                
                // Enhanced structured contact information
                field(contactInfo; GetContactInfo())
                {
                    Caption = 'Contact Info';
                }
                
                // Enhanced credit limit with currency awareness
                field(creditLimitInfo; GetCreditLimitInfo())
                {
                    Caption = 'Credit Limit Info';
                }
                
                // New fields available only in v2.0
                field(customerTier; Rec."Customer Tier")
                {
                    Caption = 'Customer Tier';
                }
                
                field(lastModified; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified';
                }
            }
        }
    }
    
    // Enhanced actions with better structure
    actions
    {
        area(processing)
        {
            action(calculateDiscountAdvanced)
            {
                Caption = 'Calculate Discount';
                
                trigger OnAction()
                var
                    DiscountAPI: Codeunit "Discount API v2";
                begin
                    // Enhanced discount calculation with structured response
                    DiscountAPI.CalculateCustomerDiscount(Rec);
                end;
            }
        }
    }
    
    // Helper procedures for structured data
    local procedure GetContactInfo(): Text
    var
        ContactInfo: JsonObject;
    begin
        ContactInfo.Add('phoneNo', Rec."Phone No.");
        ContactInfo.Add('email', Rec."E-Mail");
        ContactInfo.Add('homePage', Rec."Home Page");
        ContactInfo.Add('preferredContact', Rec."Preferred Contact Method");
        
        exit(Format(ContactInfo));
    end;
    
    local procedure GetCreditLimitInfo(): Text
    var
        CreditLimitInfo: JsonObject;
        Currency: Record Currency;
    begin
        CreditLimitInfo.Add('amount', Rec."Credit Limit (LCY)");
        CreditLimitInfo.Add('currencyCode', GetLCYCode());
        CreditLimitInfo.Add('utilized', CalculateCreditUtilization());
        CreditLimitInfo.Add('available', Rec."Credit Limit (LCY)" - CalculateCreditUtilization());
        
        exit(Format(CreditLimitInfo));
    end;
}
```

### Complex Migration Scenarios

**Learning Objective**: Handle complex obsoleting scenarios with multiple replacement functions and conditional migration paths

```al
// Complex obsoleting with conditional migration paths
codeunit 50250 "Complex Obsoleting Patterns"
{
    /// <summary>
    /// Complex function being split into multiple specialized functions
    /// Provides migration guidance based on usage patterns
    /// </summary>
    [Obsolete('This function has been split into specialized methods. Use GetCustomerBalance() for balance queries, GetCustomerCreditInfo() for credit information, or GetCustomerFullFinancials() for complete data', '25.0')]
    procedure GetCustomerFinancialInfo(CustomerNo: Code[20]; IncludeBalance: Boolean; IncludeCredit: Boolean; IncludeHistory: Boolean) FinancialInfo: Text
    var
        BalanceInfo: Text;
        CreditInfo: Text;
        HistoryInfo: Text;
    begin
        // Provide backward compatibility by routing to appropriate new methods
        if IncludeBalance then
            BalanceInfo := Format(GetCustomerBalance(CustomerNo));
        
        if IncludeCredit then
            CreditInfo := Format(GetCustomerCreditInfo(CustomerNo));
        
        if IncludeHistory then
            HistoryInfo := Format(GetCustomerFinancialHistory(CustomerNo));
        
        // Return combined data in original format
        FinancialInfo := StrSubstNo('%1|%2|%3', BalanceInfo, CreditInfo, HistoryInfo);
    end;
    
    /// <summary>
    /// Specialized function for balance queries - high performance
    /// </summary>
    procedure GetCustomerBalance(CustomerNo: Code[20]): Decimal
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustomerLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustomerLedgerEntry.CalcFields("Remaining Amount");
        exit(CustomerLedgerEntry."Remaining Amount");
    end;
    
    /// <summary>
    /// Specialized function for credit information - enhanced data
    /// </summary>
    procedure GetCustomerCreditInfo(CustomerNo: Code[20]) CreditInfo: JsonObject
    var
        Customer: Record Customer;
        CreditUtilization: Decimal;
    begin
        if Customer.Get(CustomerNo) then begin
            CreditUtilization := CalculateCreditUtilization(CustomerNo);
            
            CreditInfo.Add('creditLimit', Customer."Credit Limit (LCY)");
            CreditInfo.Add('utilized', CreditUtilization);
            CreditInfo.Add('available', Customer."Credit Limit (LCY)" - CreditUtilization);
            CreditInfo.Add('utilizationPercentage', (CreditUtilization / Customer."Credit Limit (LCY)") * 100);
            CreditInfo.Add('riskLevel', CalculateRiskLevel(Customer));
        end;
    end;
    
    /// <summary>
    /// Specialized function for financial history - comprehensive data
    /// </summary>
    procedure GetCustomerFinancialHistory(CustomerNo: Code[20]) HistoryInfo: JsonArray
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        HistoryEntry: JsonObject;
    begin
        CustomerLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustomerLedgerEntry.SetRange("Posting Date", CalcDate('<-1Y>', Today()), Today());
        
        if CustomerLedgerEntry.FindSet() then begin
            repeat
                HistoryEntry.Add('postingDate', CustomerLedgerEntry."Posting Date");
                HistoryEntry.Add('documentType', Format(CustomerLedgerEntry."Document Type"));
                HistoryEntry.Add('documentNo', CustomerLedgerEntry."Document No.");
                HistoryEntry.Add('amount', CustomerLedgerEntry.Amount);
                HistoryEntry.Add('remainingAmount', CustomerLedgerEntry."Remaining Amount");
                
                HistoryInfo.Add(HistoryEntry);
                Clear(HistoryEntry);
            until CustomerLedgerEntry.Next() = 0;
        end;
    end;
    
    /// <summary>
    /// Comprehensive function for cases requiring all financial data
    /// Optimized to fetch all data in single operation
    /// </summary>
    procedure GetCustomerFullFinancials(CustomerNo: Code[20]) FullFinancials: JsonObject
    var
        BalanceInfo: Decimal;
        CreditInfo: JsonObject;
        HistoryInfo: JsonArray;
    begin
        // Optimized to fetch all data efficiently
        BalanceInfo := GetCustomerBalance(CustomerNo);
        CreditInfo := GetCustomerCreditInfo(CustomerNo);
        HistoryInfo := GetCustomerFinancialHistory(CustomerNo);
        
        FullFinancials.Add('balance', BalanceInfo);
        FullFinancials.Add('creditInfo', CreditInfo);
        FullFinancials.Add('history', HistoryInfo);
        FullFinancials.Add('lastUpdated', CurrentDateTime());
        FullFinancials.Add('dataVersion', '2.0');
    end;
}
```

## 🔴 Advanced Enterprise Obsoleting
**For architects managing large-scale API evolution**

### Automated Migration Framework

**Learning Objective**: Create comprehensive obsoleting frameworks that provide automated migration assistance and usage analytics

```al
// Enterprise obsoleting framework with automated migration
codeunit 50300 "Enterprise Obsoleting Framework"
{
    var
        ObsoletingManager: Interface "IObsoleting Manager";
        MigrationAssistant: Codeunit "Automated Migration Assistant";
        UsageAnalytics: Codeunit "API Usage Analytics";
        NotificationService: Codeunit "Obsoleting Notification Service";
        
    /// <summary>
    /// Manages enterprise-wide obsoleting with automated migration assistance
    /// Architecture: Uses observer pattern with automated migration recommendations
    /// </summary>
    procedure ManageEnterpriseObsoleting(ObsoletingPlan: Record "Obsoleting Plan")
    var
        ObsoletingStrategy: Interface "IObsoleting Strategy";
        MigrationPlan: Record "Migration Plan";
        AnalyticsResults: Record "Usage Analytics Results";
        ExecutionResult: Boolean;
    begin
        // Analyze current usage patterns
        AnalyzeObsoleteAPIUsage(ObsoletingPlan, AnalyticsResults);
        
        // Generate automated migration plan
        GenerateAutomatedMigrationPlan(ObsoletingPlan, AnalyticsResults, MigrationPlan);
        
        // Select appropriate obsoleting strategy
        ObsoletingStrategy := SelectObsoletingStrategy(ObsoletingPlan, AnalyticsResults);
        
        // Execute managed obsoleting
        ExecutionResult := ExecuteManagedObsoleting(ObsoletingStrategy, MigrationPlan);
        
        // Monitor and report results
        MonitorObsoletingProgress(ObsoletingPlan, ExecutionResult);
    end;
    
    /// <summary>
    /// Analyzes usage patterns of obsolete APIs to inform migration strategy
    /// </summary>
    local procedure AnalyzeObsoleteAPIUsage(ObsoletingPlan: Record "Obsoleting Plan"; var AnalyticsResults: Record "Usage Analytics Results")
    var
        APIEndpoint: Record "API Endpoint";
        UsageMetrics: Record "API Usage Metrics" temporary;
        AnalysisEngine: Codeunit "Usage Analysis Engine";
    begin
        // Collect usage data for obsolete endpoints
        APIEndpoint.SetRange("Obsoleting Plan ID", ObsoletingPlan.ID);
        if APIEndpoint.FindSet() then begin
            repeat
                CollectEndpointUsageData(APIEndpoint, UsageMetrics);
            until APIEndpoint.Next() = 0;
        end;
        
        // Analyze usage patterns
        AnalysisEngine.AnalyzeUsagePatterns(UsageMetrics, AnalyticsResults);
        
        // Identify high-impact migrations
        IdentifyHighImpactMigrations(AnalyticsResults);
        
        // Generate usage reports
        GenerateUsageAnalysisReports(AnalyticsResults);
    end;
    
    /// <summary>
    /// Generates automated migration plans with code transformation suggestions
    /// </summary>
    local procedure GenerateAutomatedMigrationPlan(ObsoletingPlan: Record "Obsoleting Plan"; AnalyticsResults: Record "Usage Analytics Results"; var MigrationPlan: Record "Migration Plan")
    var
        MigrationRule: Record "Migration Rule";
        CodeTransformer: Codeunit "Code Transformation Engine";
        TransformationRules: List of [Text];
    begin
        // Initialize migration plan
        MigrationPlan.Init();
        MigrationPlan."Plan ID" := ObsoletingPlan.ID;
        MigrationPlan."Generated DateTime" := CurrentDateTime();
        MigrationPlan."Confidence Level" := CalculateMigrationConfidence(AnalyticsResults);
        
        // Generate transformation rules
        GenerateTransformationRules(ObsoletingPlan, AnalyticsResults, TransformationRules);
        
        // Create automated migration scripts
        GenerateAutomatedMigrationScripts(TransformationRules, MigrationPlan);
        
        // Validate migration plan
        ValidateMigrationPlan(MigrationPlan);
        
        MigrationPlan.Insert();
    end;
    
    /// <summary>
    /// Provides intelligent migration recommendations based on usage patterns
    /// Expert Pattern: Uses machine learning to optimize migration strategies
    /// </summary>
    procedure ProvideMigrationRecommendations(ObsoleteAPI: Text; UsageContext: Text): Text
    var
        RecommendationEngine: Codeunit "ML Migration Recommendations";
        UsagePattern: Record "Usage Pattern Analysis" temporary;
        MigrationOptions: List of [Text];
        OptimalMigration: Text;
        ConfidenceScore: Decimal;
    begin
        // Analyze usage context
        AnalyzeUsageContext(ObsoleteAPI, UsageContext, UsagePattern);
        
        // Generate migration options
        RecommendationEngine.GenerateMigrationOptions(UsagePattern, MigrationOptions);
        
        // Select optimal migration path
        OptimalMigration := RecommendationEngine.SelectOptimalMigration(
            MigrationOptions, UsagePattern, ConfidenceScore);
        
        // Format recommendation with confidence level
        exit(FormatMigrationRecommendation(OptimalMigration, ConfidenceScore, MigrationOptions));
    end;
    
    /// <summary>
    /// Executes managed obsoleting with rollback capability
    /// </summary>
    local procedure ExecuteManagedObsoleting(ObsoletingStrategy: Interface "IObsoleting Strategy"; var MigrationPlan: Record "Migration Plan"): Boolean
    var
        ObsoletingPhases: List of [Text];
        CurrentPhase: Text;
        PhaseResult: Boolean;
        OverallResult: Boolean;
        RollbackPoint: Record "Obsoleting Rollback Point";
    begin
        OverallResult := true;
        
        // Create rollback point
        CreateObsoletingRollbackPoint(MigrationPlan, RollbackPoint);
        
        // Get strategy-specific phases
        ObsoletingPhases := ObsoletingStrategy.GetObsoletingPhases(MigrationPlan);
        
        // Execute each phase with monitoring
        foreach CurrentPhase in ObsoletingPhases do begin
            NotificationService.NotifyPhaseStart(CurrentPhase, MigrationPlan);
            
            PhaseResult := ObsoletingStrategy.ExecutePhase(CurrentPhase, MigrationPlan);
            
            if PhaseResult then begin
                NotificationService.NotifyPhaseSuccess(CurrentPhase, MigrationPlan);
                LogObsoletingPhaseSuccess(CurrentPhase, MigrationPlan);
            end else begin
                NotificationService.NotifyPhaseFailure(CurrentPhase, MigrationPlan);
                LogObsoletingPhaseFailure(CurrentPhase, MigrationPlan);
                
                OverallResult := false;
                
                if ShouldRollbackOnPhaseFailure(CurrentPhase, MigrationPlan) then begin
                    ExecuteObsoletingRollback(RollbackPoint, MigrationPlan);
                    break;
                end;
            end;
        end;
        
        // Complete obsoleting process
        CompleteObsoletingExecution(MigrationPlan, OverallResult);
        
        exit(OverallResult);
    end;
    
    /// <summary>
    /// Monitors obsoleting progress with real-time impact analysis
    /// </summary>
    local procedure MonitorObsoletingProgress(var ObsoletingPlan: Record "Obsoleting Plan"; ExecutionResult: Boolean)
    var
        ImpactAnalyzer: Codeunit "Real-time Impact Analyzer";
        ImpactMetrics: Record "Obsoleting Impact Metrics" temporary;
        AlertThresholds: Record "Impact Alert Thresholds";
        CriticalImpactDetected: Boolean;
    begin
        // Collect real-time impact metrics
        ImpactAnalyzer.CollectImpactMetrics(ObsoletingPlan, ImpactMetrics);
        
        // Check against alert thresholds
        CriticalImpactDetected := CheckImpactThresholds(ImpactMetrics, AlertThresholds);
        
        if CriticalImpactDetected then begin
            NotificationService.NotifyCriticalImpact(ObsoletingPlan, ImpactMetrics);
            HandleCriticalImpactResponse(ObsoletingPlan, ImpactMetrics);
        end;
        
        // Generate progress reports
        GenerateObsoletingProgressReports(ObsoletingPlan, ImpactMetrics);
        
        // Update obsoleting plan status
        UpdateObsoletingPlanStatus(ObsoletingPlan, ExecutionResult, ImpactMetrics);
    end;
    
    /// <summary>
    /// Provides automated code transformation assistance
    /// </summary>
    procedure GenerateCodeTransformation(SourceCode: Text; ObsoletePattern: Text; TargetPattern: Text): Text
    var
        TransformationEngine: Codeunit "Code Transformation Engine";
        TransformationRules: Record "Code Transformation Rules" temporary;
        TransformedCode: Text;
        ValidationResult: Boolean;
    begin
        // Load transformation rules for pattern
        LoadTransformationRules(ObsoletePattern, TargetPattern, TransformationRules);
        
        // Apply transformation
        TransformedCode := TransformationEngine.TransformCode(SourceCode, TransformationRules);
        
        // Validate transformation result
        ValidationResult := ValidateTransformedCode(TransformedCode, TargetPattern);
        
        if ValidationResult then begin
            LogSuccessfulTransformation(ObsoletePattern, TargetPattern);
            exit(TransformedCode);
        end else begin
            LogFailedTransformation(ObsoletePattern, TargetPattern, SourceCode);
            exit(SourceCode); // Return original code if transformation fails
        end;
    end;
}
```

### Machine Learning Migration Assistance

**Learning Objective**: Implement AI-driven migration assistance that learns from successful migration patterns

```al
// ML-powered migration assistance
codeunit 50400 "ML Migration Assistant"
{
    var
        MLModel: Record "Migration Learning Model";
        PatternRecognizer: Codeunit "Migration Pattern Recognition";
        RecommendationEngine: Codeunit "ML Recommendation Engine";
        
    /// <summary>
    /// Uses machine learning to predict optimal migration strategies
    /// </summary>
    procedure PredictOptimalMigrationStrategy(ObsoleteAPI: Text; UsageContext: Text; SystemProfile: Text): Text
    var
        ContextAnalysis: Record "Migration Context Analysis" temporary;
        HistoricalMigrations: Record "Migration History" temporary;
        PredictionModel: Record "ML Migration Model" temporary;
        OptimalStrategy: Text;
        ConfidenceLevel: Decimal;
    begin
        // Analyze migration context
        AnalyzeMigrationContext(ObsoleteAPI, UsageContext, SystemProfile, ContextAnalysis);
        
        // Load historical migration data
        LoadMigrationHistory(ObsoleteAPI, HistoricalMigrations);
        
        // Train or update prediction model
        if ShouldUpdateModel(MLModel, HistoricalMigrations) then
            TrainMigrationPredictionModel(HistoricalMigrations, PredictionModel);
        
        // Generate prediction
        OptimalStrategy := RecommendationEngine.PredictMigrationStrategy(
            ContextAnalysis, PredictionModel, ConfidenceLevel);
        
        // Validate prediction
        if ConfidenceLevel < 0.7 then // Low confidence threshold
            OptimalStrategy := GetConservativeMigrationStrategy(ObsoleteAPI, ContextAnalysis);
        
        // Document prediction for learning
        DocumentMigrationPrediction(ObsoleteAPI, OptimalStrategy, ConfidenceLevel);
        
        exit(OptimalStrategy);
    end;
    
    /// <summary>
    /// Learns from migration outcomes to improve future recommendations
    /// </summary>
    procedure LearnFromMigrationOutcome(MigrationExecution: Record "Migration Execution"; ActualOutcome: Record "Migration Outcome")
    var
        LearningData: Record "Migration Learning Data" temporary;
        ModelUpdater: Codeunit "ML Model Updater";
        LearningInsights: Text;
    begin
        // Create learning data point
        CreateMigrationLearningData(MigrationExecution, ActualOutcome, LearningData);
        
        // Update learning model
        ModelUpdater.UpdateMigrationModel(MLModel, LearningData);
        
        // Extract insights from outcome
        LearningInsights := ExtractMigrationInsights(LearningData, ActualOutcome);
        
        // Apply insights to improve recommendations
        ApplyLearningInsights(LearningInsights, MLModel);
        
        // Document learning for audit trail
        DocumentLearningOutcome(LearningData, LearningInsights);
    end;
}
```

## AI Guidance Integration

### Context-Aware Obsoleting Suggestions

**Proactive AI Behavior**: When marking functions as obsolete, Copilot suggests:
- Clear migration paths to replacement functions
- Appropriate obsoleting timeline based on usage patterns
- Backward compatibility strategies during transition
- Documentation updates for API consumers
- Version management for API evolution

### Educational Escalation

**Weak Prompt**: "Mark this function obsolete"
**Enhanced**: "Mark function obsolete using graceful-obsoleting-patterns.md with migration guidance from api-versioning-patterns.md and backward compatibility from version-strategy-patterns.md"
**Educational Note**: Enhanced prompts specify obsoleting patterns, migration strategies, and compatibility considerations for smooth API evolution.

## DevOps Integration

### Work Item Documentation

When implementing obsoleting strategies, update Azure DevOps work items with:
- **Obsoleting Timeline**: Version numbers and removal dates
- **Migration Path**: Step-by-step guidance for consumers
- **Impact Analysis**: Affected systems and integration points
- **Backward Compatibility**: Support strategy during transition
- **Communication Plan**: How and when to notify consumers

### Quality Gates

- **Pre-Obsoleting**: Analyze usage patterns and impact assessment
- **During Transition**: Monitor adoption of replacement APIs
- **Post-Migration**: Verify successful migration and remove obsolete code
- **Documentation Review**: Ensure migration guidance is clear and complete

## Success Metrics

- ✅ Obsolete functions provide clear migration guidance
- ✅ Backward compatibility is maintained during transition periods
- ✅ API versioning follows consistent patterns
- ✅ Migration paths are well-documented and tested
- ✅ Consumer impact is minimized through gradual deprecation
- ✅ Automated tools assist with code transformation

**This guide ensures obsoleting is handled gracefully, maintaining system stability while guiding developers toward modern implementations.**
