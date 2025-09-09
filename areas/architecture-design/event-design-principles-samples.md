---
title: "Event Design Principles - Code Samples"
description: "Production-ready implementations demonstrating best practices for designing maintainable and extensible integration events"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record", "Enum", "JsonObject", "List", "Dictionary"]
tags: ["events", "design", "principles", "integration", "extensibility", "maintainability", "samples"]
---

# Event Design Principles - Code Samples

## Complete Customer Management Event System

### Well-Designed Customer Events with Rich Context

```al
codeunit 50400 "Customer Management Events"
{
    /// <summary>
    /// Comprehensive customer registration with full business context
    /// </summary>
    procedure RegisterNewCustomer(var Customer: Record Customer; RegistrationSource: Enum "Customer Registration Source"): Boolean
    var
        RegistrationContext: JsonObject;
        ValidationErrors: List of [Text];
        IsHandled: Boolean;
        ProcessingResults: JsonObject;
    begin
        // Build rich registration context
        BuildRegistrationContext(Customer, RegistrationSource, RegistrationContext);
        
        // Pre-registration validation and setup
        OnBeforeCustomerRegistration(Customer, RegistrationContext, ValidationErrors, IsHandled);
        
        if IsHandled then
            exit(true); // Subscriber handled the entire process
            
        // Handle validation errors
        if ValidationErrors.Count > 0 then begin
            HandleRegistrationValidationErrors(ValidationErrors);
            exit(false);
        end;
        
        // Core registration process
        if not ExecuteCustomerRegistration(Customer, RegistrationContext, ProcessingResults) then
            exit(false);
            
        // Post-registration event
        OnAfterCustomerRegistration(Customer, RegistrationContext, ProcessingResults);
        
        // Publish business event for external systems
        PublishCustomerRegistrationBusinessEvent(Customer, RegistrationContext);
        
        exit(true);
    end;
    
    /// <summary>
    /// Raised before customer registration begins.
    /// Provides complete business context and allows custom validation or process override.
    /// </summary>
    /// <param name="Customer">Customer record being registered (var for modification)</param>
    /// <param name="RegistrationContext">Rich context including source, preferences, defaults</param>
    /// <param name="ValidationErrors">List to collect any validation errors</param>
    /// <param name="IsHandled">Set true to completely override standard registration</param>
    /// <example>
    /// Implement custom validation rules:
    /// <code>
    /// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Management Events", 
    ///                  'OnBeforeCustomerRegistration', '', false, false)]
    /// local procedure ValidateCustomerAgainstCRM(var Customer: Record Customer;
    ///                                           RegistrationContext: JsonObject;
    ///                                           var ValidationErrors: List of [Text];
    ///                                           var IsHandled: Boolean)
    /// var
    ///     CRMValidation: Codeunit "CRM Validation Service";
    /// begin
    ///     if not CRMValidation.ValidateNewCustomer(Customer) then
    ///         ValidationErrors.Add('Customer validation failed in CRM system');
    /// end;
    /// </code>
    /// </example>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerRegistration(var Customer: Record Customer;
                                                RegistrationContext: JsonObject;
                                                var ValidationErrors: List of [Text];
                                                var IsHandled: Boolean)
    begin
    end;
    
    /// <summary>
    /// Raised after successful customer registration.
    /// Provides access to complete registration context and processing results.
    /// </summary>
    /// <param name="Customer">Newly registered customer record</param>
    /// <param name="RegistrationContext">Registration context used during process</param>
    /// <param name="ProcessingResults">Results from registration process including timings, created records</param>
    /// <example>
    /// Set up customer in external systems:
    /// <code>
    /// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Management Events", 
    ///                  'OnAfterCustomerRegistration', '', false, false)]
    /// local procedure SyncToExternalSystems(Customer: Record Customer;
    ///                                      RegistrationContext: JsonObject;
    ///                                      ProcessingResults: JsonObject)
    /// var
    ///     CRMSync: Codeunit "CRM Synchronization";
    ///     ERPSync: Codeunit "ERP Integration";
    /// begin
    ///     CRMSync.CreateCustomerRecord(Customer);
    ///     ERPSync.NotifyCustomerCreation(Customer, RegistrationContext);
    /// end;
    /// </code>
    /// </example>
    [IntegrationEvent(false, false)]
    local procedure OnAfterCustomerRegistration(Customer: Record Customer;
                                              RegistrationContext: JsonObject;
                                              ProcessingResults: JsonObject)
    begin
    end;
    
    /// <summary>
    /// Advanced credit limit validation with comprehensive business context
    /// </summary>
    procedure ValidateCustomerCreditLimit(var Customer: Record Customer; RequestedLimit: Decimal): Boolean
    var
        CreditContext: JsonObject;
        ValidationResult: Enum "Credit Validation Result";
        ReasonCode: Code[20];
        SuggestedLimit: Decimal;
        ValidationDetails: JsonObject;
        IsHandled: Boolean;
    begin
        // Build comprehensive credit assessment context
        BuildCreditValidationContext(Customer, RequestedLimit, CreditContext);
        
        // Allow custom credit validation
        OnBeforeValidateCustomerCreditLimit(Customer, RequestedLimit, CreditContext,
                                          ValidationResult, ReasonCode, SuggestedLimit,
                                          ValidationDetails, IsHandled);
        
        if IsHandled then begin
            // Subscriber provided complete validation
            exit(ValidationResult = ValidationResult::Approved);
        end;
        
        // Standard credit validation logic
        ValidationResult := ExecuteStandardCreditValidation(Customer, RequestedLimit, 
                                                           CreditContext, ReasonCode, SuggestedLimit);
        
        // Post-validation event
        OnAfterCreditLimitValidation(Customer, RequestedLimit, ValidationResult, 
                                   ReasonCode, SuggestedLimit, ValidationDetails);
        
        exit(ValidationResult = ValidationResult::Approved);
    end;
    
    /// <summary>
    /// Comprehensive credit limit validation event with rich business context.
    /// Allows complete override of validation logic or enhancement of standard process.
    /// </summary>
    /// <param name="Customer">Customer record with current financial data</param>
    /// <param name="RequestedLimit">Requested credit limit amount</param>
    /// <param name="CreditContext">Complete financial context: payment history, outstanding orders, etc.</param>
    /// <param name="ValidationResult">Set validation result (Approved, Rejected, RequiresApproval)</param>
    /// <param name="ReasonCode">Reason code for validation decision</param>
    /// <param name="SuggestedLimit">Alternative limit suggestion if applicable</param>
    /// <param name="ValidationDetails">Additional validation details as JSON</param>
    /// <param name="IsHandled">Set true to completely override standard validation</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateCustomerCreditLimit(var Customer: Record Customer;
                                                       RequestedLimit: Decimal;
                                                       CreditContext: JsonObject;
                                                       var ValidationResult: Enum "Credit Validation Result";
                                                       var ReasonCode: Code[20];
                                                       var SuggestedLimit: Decimal;
                                                       var ValidationDetails: JsonObject;
                                                       var IsHandled: Boolean)
    begin
    end;
    
    /// <summary>
    /// Post-validation event providing complete validation results.
    /// Use for logging, notifications, or follow-up actions.
    /// </summary>
    [IntegrationEvent(false, false)]
    local procedure OnAfterCreditLimitValidation(var Customer: Record Customer;
                                                RequestedLimit: Decimal;
                                                ValidationResult: Enum "Credit Validation Result";
                                                ReasonCode: Code[20];
                                                SuggestedLimit: Decimal;
                                                ValidationDetails: JsonObject)
    begin
    end;
    
    local procedure BuildRegistrationContext(Customer: Record Customer; 
                                           RegistrationSource: Enum "Customer Registration Source";
                                           var RegistrationContext: JsonObject)
    var
        PreferencesJson: JsonObject;
        DefaultsJson: JsonObject;
        MetadataJson: JsonObject;
        SalesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // Registration metadata
        MetadataJson.Add('registrationDateTime', CurrentDateTime);
        MetadataJson.Add('registrationSource', Format(RegistrationSource));
        MetadataJson.Add('registeredBy', UserId);
        MetadataJson.Add('sessionId', SessionId);
        MetadataJson.Add('companyName', CompanyName);
        RegistrationContext.Add('metadata', MetadataJson);
        
        // Business preferences and defaults
        if SalesSetup.Get() then begin
            DefaultsJson.Add('defaultPaymentTermsCode', SalesSetup."Default Payment Terms Code");
            DefaultsJson.Add('defaultShipmentMethodCode', SalesSetup."Default Shipment Method Code");
            DefaultsJson.Add('creditWarningsEnabled', SalesSetup."Credit Warnings");
            DefaultsJson.Add('stockoutWarningsEnabled', SalesSetup."Stockout Warning");
        end;
        
        if GeneralLedgerSetup.Get() then begin
            DefaultsJson.Add('lcyCode', GeneralLedgerSetup."LCY Code");
            DefaultsJson.Add('vatRoundingPrecision', GeneralLedgerSetup."VAT Rounding Precision");
        end;
        
        RegistrationContext.Add('defaults', DefaultsJson);
        
        // Customer preferences
        PreferencesJson.Add('receiveMarketingEmails', true); // Default opt-in
        PreferencesJson.Add('preferredContactMethod', 'Email');
        PreferencesJson.Add('preferredLanguage', GetUserLanguage());
        RegistrationContext.Add('preferences', PreferencesJson);
        
        // Registration source specific context
        case RegistrationSource of
            RegistrationSource::"Web Portal":
                AddWebPortalContext(RegistrationContext);
            RegistrationSource::"Sales Representative":
                AddSalesRepContext(RegistrationContext);
            RegistrationSource::"Import Process":
                AddImportContext(RegistrationContext);
        end;
    end;
    
    local procedure BuildCreditValidationContext(Customer: Record Customer; 
                                               RequestedLimit: Decimal;
                                               var CreditContext: JsonObject)
    var
        FinancialJson: JsonObject;
        HistoryJson: JsonObject;
        RiskFactorsJson: JsonObject;
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        SalesHeader: Record "Sales Header";
        PaymentHistory: JsonArray;
        OutstandingOrders: JsonArray;
    begin
        // Current financial position
        Customer.CalcFields(Balance, "Balance (LCY)", "Net Change", "Net Change (LCY)",
                          "Sales (LCY)", "Payments (LCY)", "Outstanding Orders (LCY)");
        
        FinancialJson.Add('currentBalance', Customer."Balance (LCY)");
        FinancialJson.Add('currentCreditLimit', Customer."Credit Limit (LCY)");
        FinancialJson.Add('availableCredit', Customer."Credit Limit (LCY)" - Customer."Balance (LCY)");
        FinancialJson.Add('totalSalesYTD', Customer."Sales (LCY)");
        FinancialJson.Add('totalPaymentsYTD', Customer."Payments (LCY)");
        FinancialJson.Add('outstandingOrdersValue', Customer."Outstanding Orders (LCY)");
        FinancialJson.Add('requestedLimit', RequestedLimit);
        FinancialJson.Add('limitIncrease', RequestedLimit - Customer."Credit Limit (LCY)");
        CreditContext.Add('financial', FinancialJson);
        
        // Payment history analysis
        BuildPaymentHistoryAnalysis(Customer, HistoryJson);
        CreditContext.Add('paymentHistory', HistoryJson);
        
        // Risk factors assessment
        BuildRiskFactorsAssessment(Customer, RiskFactorsJson);
        CreditContext.Add('riskFactors', RiskFactorsJson);
        
        // Business relationship metrics
        CalculateCustomerMetrics(Customer, CreditContext);
    end;
    
    local procedure BuildPaymentHistoryAnalysis(Customer: Record Customer; var HistoryJson: JsonObject)
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustomerLedgEntry: Record "Detailed Cust. Ledg. Entry";
        LatePayments: Integer;
        TotalInvoices: Integer;
        AveragePaymentDays: Decimal;
        LargestOverdueAmount: Decimal;
        PaymentReliabilityScore: Decimal;
    begin
        // Analyze payment patterns over last 12 months
        CustomerLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustomerLedgerEntry.SetRange("Posting Date", CalcDate('-12M', Today), Today);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        
        if CustomerLedgerEntry.FindSet() then
            repeat
                TotalInvoices += 1;
                
                // Check if payment was late
                if CustomerLedgerEntry."Due Date" < CustomerLedgerEntry."Closed at Date" then
                    LatePayments += 1;
                    
                // Calculate average payment days
                if CustomerLedgerEntry."Closed at Date" <> 0D then
                    AveragePaymentDays += CustomerLedgerEntry."Closed at Date" - CustomerLedgerEntry."Due Date";
                    
                // Track largest overdue amount
                if CustomerLedgerEntry."Remaining Amt. (LCY)" > LargestOverdueAmount then
                    LargestOverdueAmount := CustomerLedgerEntry."Remaining Amt. (LCY)";
                    
            until CustomerLedgerEntry.Next() = 0;
            
        if TotalInvoices > 0 then begin
            AveragePaymentDays := AveragePaymentDays / TotalInvoices;
            PaymentReliabilityScore := (1 - (LatePayments / TotalInvoices)) * 100;
        end;
        
        HistoryJson.Add('totalInvoices12Months', TotalInvoices);
        HistoryJson.Add('latePayments12Months', LatePayments);
        HistoryJson.Add('latePaymentPercentage', Round(LatePayments / TotalInvoices * 100, 0.1));
        HistoryJson.Add('averagePaymentDays', Round(AveragePaymentDays, 0.1));
        HistoryJson.Add('largestOverdueAmount', LargestOverdueAmount);
        HistoryJson.Add('paymentReliabilityScore', Round(PaymentReliabilityScore, 0.1));
        HistoryJson.Add('customerSince', Customer."Created DateTime");
        
        // Payment trend analysis
        AnalyzePaymentTrends(Customer, HistoryJson);
    end;
    
    local procedure BuildRiskFactorsAssessment(Customer: Record Customer; var RiskFactorsJson: JsonObject)
    var
        RiskScore: Integer;
        RiskLevel: Text;
        RiskFactors: JsonArray;
        ContactsCount: Integer;
        AddressVerified: Boolean;
    begin
        RiskScore := 100; // Start with perfect score
        
        // Assess various risk factors
        if Customer.Blocked <> Customer.Blocked::" " then begin
            RiskScore -= 50;
            AddRiskFactor(RiskFactors, 'Customer is blocked', 'High');
        end;
        
        if Customer."Privacy Blocked" then begin
            RiskScore -= 20;
            AddRiskFactor(RiskFactors, 'Privacy blocked', 'Medium');
        end;
        
        if Customer."Phone No." = '' then begin
            RiskScore -= 10;
            AddRiskFactor(RiskFactors, 'No phone number', 'Low');
        end;
        
        if Customer."E-Mail" = '' then begin
            RiskScore -= 10;
            AddRiskFactor(RiskFactors, 'No email address', 'Low');
        end;
        
        // Determine risk level
        case RiskScore of
            80..100:
                RiskLevel := 'Low';
            60..79:
                RiskLevel := 'Medium';
            40..59:
                RiskLevel := 'High';
            else
                RiskLevel := 'Critical';
        end;
        
        RiskFactorsJson.Add('riskScore', RiskScore);
        RiskFactorsJson.Add('riskLevel', RiskLevel);
        RiskFactorsJson.Add('riskFactors', RiskFactors);
        RiskFactorsJson.Add('assessmentDate', CurrentDateTime);
    end;
    
    local procedure AnalyzePaymentTrends(Customer: Record Customer; var HistoryJson: JsonObject)
    var
        TrendJson: JsonObject;
        MonthlyPayments: JsonArray;
        CurrentMonth: Date;
        MonthData: JsonObject;
        MonthlyAmount: Decimal;
        MonthlyCount: Integer;
    begin
        // Analyze monthly payment patterns for last 6 months
        CurrentMonth := CalcDate('-6M', Today);
        
        while CurrentMonth <= Today do begin
            Clear(MonthData);
            GetMonthlyPaymentData(Customer, CurrentMonth, MonthlyAmount, MonthlyCount);
            
            MonthData.Add('month', Format(CurrentMonth, 0, '<Month Text> <Year4>'));
            MonthData.Add('amount', MonthlyAmount);
            MonthData.Add('paymentCount', MonthlyCount);
            MonthlyPayments.Add(MonthData);
            
            CurrentMonth := CalcDate('+1M', CurrentMonth);
        end;
        
        TrendJson.Add('monthlyPayments', MonthlyPayments);
        HistoryJson.Add('trends', TrendJson);
    end;
    
    local procedure GetMonthlyPaymentData(Customer: Record Customer; Month: Date; var Amount: Decimal; var Count: Integer)
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        StartDate: Date;
        EndDate: Date;
    begin
        StartDate := CalcDate('<-CM>', Month);
        EndDate := CalcDate('<CM>', Month);
        
        CustomerLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustomerLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Payment);
        
        if CustomerLedgerEntry.FindSet() then
            repeat
                Amount += Abs(CustomerLedgerEntry."Amount (LCY)");
                Count += 1;
            until CustomerLedgerEntry.Next() = 0;
    end;
    
    local procedure AddRiskFactor(var RiskFactors: JsonArray; Factor: Text; Severity: Text)
    var
        RiskFactor: JsonObject;
    begin
        RiskFactor.Add('factor', Factor);
        RiskFactor.Add('severity', Severity);
        RiskFactor.Add('detectedDate', CurrentDateTime);
        RiskFactors.Add(RiskFactor);
    end;
    
    local procedure CalculateCustomerMetrics(Customer: Record Customer; var CreditContext: JsonObject)
    var
        MetricsJson: JsonObject;
        RelationshipScore: Decimal;
        BusinessVolume: Decimal;
        GrowthRate: Decimal;
    begin
        // Calculate business relationship strength
        RelationshipScore := CalculateRelationshipScore(Customer);
        BusinessVolume := Customer."Sales (LCY)";
        GrowthRate := CalculateCustomerGrowthRate(Customer);
        
        MetricsJson.Add('relationshipScore', Round(RelationshipScore, 0.1));
        MetricsJson.Add('annualBusinessVolume', BusinessVolume);
        MetricsJson.Add('growthRate', Round(GrowthRate, 0.1));
        MetricsJson.Add('customerTenure', CalculateCustomerTenure(Customer));
        
        CreditContext.Add('businessMetrics', MetricsJson);
    end;
    
    local procedure CalculateRelationshipScore(Customer: Record Customer): Decimal
    var
        Score: Decimal;
        ContactsCount: Integer;
        InteractionCount: Integer;
    begin
        Score := 50; // Base score
        
        // Positive factors
        if Customer."E-Mail" <> '' then Score += 10;
        if Customer."Phone No." <> '' then Score += 10;
        if Customer.Address <> '' then Score += 5;
        if Customer."Payment Terms Code" <> '' then Score += 5;
        
        // Business relationship factors
        ContactsCount := GetCustomerContactsCount(Customer."No.");
        Score += ContactsCount * 2;
        
        InteractionCount := GetCustomerInteractionCount(Customer."No.");
        Score += InteractionCount * 0.1;
        
        exit(Score);
    end;
    
    local procedure CalculateCustomerGrowthRate(Customer: Record Customer): Decimal
    var
        CurrentYearSales: Decimal;
        PreviousYearSales: Decimal;
    begin
        CurrentYearSales := GetCustomerSalesForPeriod(Customer."No.", CalcDate('-1Y', Today), Today);
        PreviousYearSales := GetCustomerSalesForPeriod(Customer."No.", CalcDate('-2Y', Today), CalcDate('-1Y', Today));
        
        if PreviousYearSales <> 0 then
            exit((CurrentYearSales - PreviousYearSales) / PreviousYearSales * 100)
        else
            exit(0);
    end;
    
    local procedure GetCustomerContactsCount(CustomerNo: Code[20]): Integer
    var
        Contact: Record Contact;
    begin
        Contact.SetCurrentKey("Company No.");
        Contact.SetRange("Company No.", CustomerNo);
        exit(Contact.Count);
    end;
    
    local procedure GetCustomerInteractionCount(CustomerNo: Code[20]): Integer
    var
        InteractionLogEntry: Record "Interaction Log Entry";
    begin
        InteractionLogEntry.SetRange("Contact Company No.", CustomerNo);
        InteractionLogEntry.SetRange(Date, CalcDate('-1Y', Today), Today);
        exit(InteractionLogEntry.Count());
    end;
    
    local procedure GetCustomerSalesForPeriod(CustomerNo: Code[20]; StartDate: Date; EndDate: Date): Decimal
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        TotalSales: Decimal;
    begin
        CustomerLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustomerLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        
        if CustomerLedgerEntry.FindSet() then
            repeat
                TotalSales += CustomerLedgerEntry."Sales (LCY)";
            until CustomerLedgerEntry.Next() = 0;
            
        exit(TotalSales);
    end;
    
    local procedure CalculateCustomerTenure(Customer: Record Customer): Integer
    begin
        if Customer."Created DateTime" <> 0DT then
            exit(Round((CurrentDateTime - Customer."Created DateTime") / (1000 * 60 * 60 * 24), 1))
        else
            exit(0);
    end;
    
    // Additional helper procedures for registration context
    local procedure AddWebPortalContext(var RegistrationContext: JsonObject)
    var
        WebContextJson: JsonObject;
    begin
        WebContextJson.Add('sourceType', 'WebPortal');
        WebContextJson.Add('requiresEmailVerification', true);
        WebContextJson.Add('autoSendWelcomeEmail', true);
        WebContextJson.Add('defaultCommunicationPreference', 'Email');
        RegistrationContext.Add('sourceContext', WebContextJson);
    end;
    
    local procedure AddSalesRepContext(var RegistrationContext: JsonObject)
    var
        SalesContextJson: JsonObject;
    begin
        SalesContextJson.Add('sourceType', 'SalesRepresentative');
        SalesContextJson.Add('salesPersonCode', GetCurrentSalesperson());
        SalesContextJson.Add('requiresManagerApproval', false);
        SalesContextJson.Add('autoAssignSalesRep', true);
        RegistrationContext.Add('sourceContext', SalesContextJson);
    end;
    
    local procedure AddImportContext(var RegistrationContext: JsonObject)
    var
        ImportContextJson: JsonObject;
    begin
        ImportContextJson.Add('sourceType', 'Import');
        ImportContextJson.Add('batchValidation', true);
        ImportContextJson.Add('autoSetDefaults', true);
        ImportContextJson.Add('suppressNotifications', true);
        RegistrationContext.Add('sourceContext', ImportContextJson);
    end;
    
    local procedure GetUserLanguage(): Text
    var
        UserPersonalization: Record "User Personalization";
    begin
        if UserPersonalization.Get(UserSecurityId()) then
            exit(Format(UserPersonalization."Language ID"))
        else
            exit('ENU');
    end;
    
    local procedure GetCurrentSalesperson(): Code[20]
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then
            exit(UserSetup."Salespers./Purch. Code")
        else
            exit('');
    end;
    
    // Implementation stubs for core processes
    local procedure ExecuteCustomerRegistration(var Customer: Record Customer; 
                                               RegistrationContext: JsonObject; 
                                               var ProcessingResults: JsonObject): Boolean
    var
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        
        // Core customer registration logic here
        Customer.Insert(true);
        
        // Record processing results
        ProcessingResults.Add('registrationCompleted', true);
        ProcessingResults.Add('processingTimeMs', CurrentDateTime - StartTime);
        ProcessingResults.Add('customerCreated', true);
        
        exit(true);
    end;
    
    local procedure ExecuteStandardCreditValidation(Customer: Record Customer; 
                                                   RequestedLimit: Decimal;
                                                   CreditContext: JsonObject; 
                                                   var ReasonCode: Code[20]; 
                                                   var SuggestedLimit: Decimal): Enum "Credit Validation Result"
    begin
        // Standard credit validation logic
        if RequestedLimit <= Customer."Credit Limit (LCY)" then begin
            ReasonCode := 'CURRENT';
            exit("Credit Validation Result"::Approved);
        end;
        
        // Simple validation based on payment history
        if Customer."Balance (LCY)" = 0 then begin
            ReasonCode := 'GOOD_HIST';
            exit("Credit Validation Result"::Approved);
        end;
        
        // Suggest alternative limit
        SuggestedLimit := Customer."Credit Limit (LCY)" * 1.2;
        ReasonCode := 'SUGGESTED';
        exit("Credit Validation Result"::RequiresApproval);
    end;
    
    local procedure HandleRegistrationValidationErrors(ValidationErrors: List of [Text])
    var
        ErrorMessage: Text;
        AllErrors: Text;
    begin
        foreach ErrorMessage in ValidationErrors do begin
            if AllErrors <> '' then
                AllErrors += '\';
            AllErrors += ErrorMessage;
        end;
        
        Error('Customer registration validation failed:\\%1', AllErrors);
    end;
    
    local procedure PublishCustomerRegistrationBusinessEvent(Customer: Record Customer; 
                                                           RegistrationContext: JsonObject)
    var
        EventPayload: JsonObject;
    begin
        EventPayload.Add('customerNo', Customer."No.");
        EventPayload.Add('customerName', Customer.Name);
        EventPayload.Add('registrationContext', RegistrationContext);
        EventPayload.Add('timestamp', CurrentDateTime);
        
        Session.LogMessage('CustomerRegistered', Format(EventPayload), 
                          Verbosity::Normal, DataClassification::CustomerContent, 
                          TelemetryScope::ExtensionPublisher, 'Category', 'BusinessEvent');
    end;
}

// Supporting enum for credit validation
enum 50400 "Credit Validation Result"
{
    Extensible = true;
    
    value(0; Approved) { Caption = 'Approved'; }
    value(1; Rejected) { Caption = 'Rejected'; }
    value(2; RequiresApproval) { Caption = 'Requires Approval'; }
}

enum 50401 "Customer Registration Source"
{
    Extensible = true;
    
    value(0; "Web Portal") { Caption = 'Web Portal'; }
    value(1; "Sales Representative") { Caption = 'Sales Representative'; }
    value(2; "Import Process") { Caption = 'Import Process'; }
    value(3; Manual) { Caption = 'Manual Entry'; }
}
```

## Event Subscriber Examples

### Comprehensive Event Subscriber Implementation

```al
codeunit 50401 "Customer Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Management Events", 
                     'OnBeforeCustomerRegistration', '', false, false)]
    local procedure ValidateCustomerWithExternalCRM(var Customer: Record Customer;
                                                   RegistrationContext: JsonObject;
                                                   var ValidationErrors: List of [Text];
                                                   var IsHandled: Boolean)
    var
        CRMIntegration: Codeunit "CRM Integration Service";
        CRMValidationResult: JsonObject;
        ErrorToken: JsonToken;
        ErrorMessage: Text;
    begin
        // Validate against external CRM system
        if not CRMIntegration.ValidateNewCustomer(Customer, CRMValidationResult) then begin
            if CRMValidationResult.Get('error', ErrorToken) then
                ErrorMessage := ErrorToken.AsValue().AsText()
            else
                ErrorMessage := 'CRM validation failed';
                
            ValidationErrors.Add(StrSubstNo('CRM Validation: %1', ErrorMessage));
        end;
        
        // Check for duplicate in CRM
        if CRMIntegration.CustomerExistsInCRM(Customer.Name, Customer."E-Mail") then
            ValidationErrors.Add('Customer with same name and email already exists in CRM');
            
        // Don't handle the process, just validate
        IsHandled := false;
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Management Events", 
                     'OnAfterCustomerRegistration', '', false, false)]
    local procedure SyncNewCustomerToExternalSystems(Customer: Record Customer;
                                                    RegistrationContext: JsonObject;
                                                    ProcessingResults: JsonObject)
    var
        CRMSync: Codeunit "CRM Synchronization";
        MarketingSync: Codeunit "Marketing Automation";
        EmailService: Codeunit "Email Service";
        SourceToken: JsonToken;
        RegistrationSource: Text;
        SyncResults: JsonObject;
    begin
        // Extract registration source from context
        if RegistrationContext.Get('metadata', SourceToken) then begin
            if SourceToken.AsObject().Get('registrationSource', SourceToken) then
                RegistrationSource := SourceToken.AsValue().AsText();
        end;
        
        // Sync to CRM system
        if CRMSync.CreateCustomerRecord(Customer, RegistrationContext) then
            Session.LogMessage('CRMSync', 
                              StrSubstNo('Customer %1 synced to CRM successfully', Customer."No."),
                              Verbosity::Normal, DataClassification::SystemMetadata, 
                              TelemetryScope::ExtensionPublisher, 'Category', 'Integration');
        
        // Add to marketing automation if from web portal
        if RegistrationSource = Format("Customer Registration Source"::"Web Portal") then
            MarketingSync.AddToWelcomeCampaign(Customer);
        
        // Send welcome email
        EmailService.SendCustomerWelcomeEmail(Customer, RegistrationContext);
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Management Events", 
                     'OnBeforeValidateCustomerCreditLimit', '', false, false)]
    local procedure EnhanceCreditValidationWithExternalData(var Customer: Record Customer;
                                                           RequestedLimit: Decimal;
                                                           CreditContext: JsonObject;
                                                           var ValidationResult: Enum "Credit Validation Result";
                                                           var ReasonCode: Code[20];
                                                           var SuggestedLimit: Decimal;
                                                           var ValidationDetails: JsonObject;
                                                           var IsHandled: Boolean)
    var
        CreditBureau: Codeunit "Credit Bureau Service";
        ExternalCreditRating: Text;
        CreditScore: Integer;
        RecommendedLimit: Decimal;
    begin
        // Get external credit rating
        if CreditBureau.GetCreditRating(Customer."No.", ExternalCreditRating, CreditScore) then begin
            ValidationDetails.Add('externalCreditRating', ExternalCreditRating);
            ValidationDetails.Add('creditScore', CreditScore);
            
            // Use external data to determine validation result
            if CreditScore >= 750 then begin
                RecommendedLimit := RequestedLimit * 1.2; // Allow 20% more for excellent credit
                ValidationResult := ValidationResult::Approved;
                ReasonCode := 'EXT_EXCELLENT';
                SuggestedLimit := RecommendedLimit;
            end else if CreditScore >= 650 then begin
                ValidationResult := ValidationResult::Approved;
                ReasonCode := 'EXT_GOOD';
            end else if CreditScore >= 550 then begin
                ValidationResult := ValidationResult::RequiresApproval;
                ReasonCode := 'EXT_FAIR';
                SuggestedLimit := RequestedLimit * 0.8; // Reduce by 20% for fair credit
            end else begin
                ValidationResult := ValidationResult::Rejected;
                ReasonCode := 'EXT_POOR';
                SuggestedLimit := Customer."Credit Limit (LCY)"; // Keep current limit
            end;
            
            ValidationDetails.Add('externalValidationApplied', true);
            ValidationDetails.Add('originalRequestedLimit', RequestedLimit);
            ValidationDetails.Add('creditBureauRecommendation', Format(ValidationResult));
            
            IsHandled := true; // Override standard validation
        end else begin
            // External service unavailable, log and continue with standard validation
            Session.LogMessage('CreditValidation', 
                              'External credit bureau service unavailable, using internal validation',
                              Verbosity::Warning, DataClassification::SystemMetadata, 
                              TelemetryScope::ExtensionPublisher, 'Category', 'CreditValidation');
            
            ValidationDetails.Add('externalValidationAttempted', true);
            ValidationDetails.Add('externalValidationFailed', true);
            IsHandled := false; // Let standard validation proceed
        end;
    end;
}
```

This comprehensive implementation demonstrates production-ready event design with rich context, proper error handling, extensibility, and real-world business scenarios.
