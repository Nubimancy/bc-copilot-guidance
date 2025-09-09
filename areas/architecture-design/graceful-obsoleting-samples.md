# Graceful Obsoleting Patterns - Sample Implementations

This document provides comprehensive code samples for the graceful obsoleting patterns outlined in `graceful-obsoleting-patterns.md`.

## Basic Obsoleting Samples

### Simple Function Obsoleting

```al
// Basic obsoleting with clear migration guidance
codeunit 50170 "Basic Obsoleting Examples"
{
    // Original simple function being replaced
    [Obsolete('Use CalculateTaxAdvanced(Amount, TaxGroup, Region) for enhanced tax calculation', '24.0')]
    procedure CalculateTax(Amount: Decimal): Decimal
    var
        TaxSetup: Record "Tax Setup";
    begin
        // Maintain backward compatibility
        TaxSetup.Get();
        exit(CalculateTaxAdvanced(Amount, TaxSetup."Default Tax Group", TaxSetup."Default Region"));
    end;
    
    // New enhanced function
    procedure CalculateTaxAdvanced(Amount: Decimal; TaxGroup: Code[20]; Region: Code[10]): Decimal
    var
        TaxRate: Record "Tax Rate";
        TaxAmount: Decimal;
    begin
        TaxRate.Get(TaxGroup, Region);
        TaxAmount := Amount * TaxRate.Rate / 100;
        
        // Enhanced logic with exemption handling
        if TaxRate."Exemption Threshold" > 0 then
            if Amount <= TaxRate."Exemption Threshold" then
                TaxAmount := 0;
        
        exit(TaxAmount);
    end;
    
    // Phased obsoleting example
    [Obsolete('Phase 1 deprecation: Use FormatCurrencyValue(Amount, CurrencyCode) instead. This function will be removed in version 26.0', '24.0')]
    procedure FormatCurrency(Amount: Decimal): Text
    begin
        // Forward to new function with default currency
        exit(FormatCurrencyValue(Amount, GetLCYCode()));
    end;
    
    procedure FormatCurrencyValue(Amount: Decimal; CurrencyCode: Code[10]): Text
    var
        Currency: Record Currency;
        AutoFormat: Codeunit "Auto Format";
    begin
        if Currency.Get(CurrencyCode) then
            exit(AutoFormat.Format(Amount, 1, Currency."Amount Decimal Places"))
        else
            exit(Format(Amount, 0, 2));
    end;
}
```

### Event Obsoleting Examples

```al
// Event obsoleting with subscriber migration
codeunit 50171 "Event Obsoleting Examples"
{
    // Original event being replaced
    [Obsolete('Use OnCustomerDataChanged with enhanced context parameters', '24.5')]
    [IntegrationEvent(false, false)]
    procedure OnCustomerModified(CustomerNo: Code[20])
    begin
    end;
    
    // New enhanced event
    [IntegrationEvent(false, false)]
    procedure OnCustomerDataChanged(CustomerNo: Code[20]; FieldName: Text; OldValue: Variant; NewValue: Variant; var IsHandled: Boolean)
    begin
    end;
    
    // Publishing both events during transition
    local procedure PublishCustomerEvents(CustomerNo: Code[20]; FieldName: Text; OldValue: Variant; NewValue: Variant)
    var
        IsHandled: Boolean;
    begin
        // Publish old event for backward compatibility
        OnCustomerModified(CustomerNo);
        
        // Publish new enhanced event
        OnCustomerDataChanged(CustomerNo, FieldName, OldValue, NewValue, IsHandled);
    end;
    
    // Business event obsoleting
    [Obsolete('Use OnSalesDocumentStatusChanged with structured event data', '25.0')]
    [BusinessEvent(false)]
    procedure OnSalesOrderPosted(DocumentNo: Code[20])
    begin
    end;
    
    [BusinessEvent(false)]
    procedure OnSalesDocumentStatusChanged(EventData: JsonObject)
    begin
    end;
    
    local procedure PublishSalesEvents(DocumentNo: Code[20]; DocumentType: Enum "Sales Document Type"; Status: Text)
    var
        EventData: JsonObject;
    begin
        // Old event for backward compatibility
        if DocumentType = DocumentType::Order then
            OnSalesOrderPosted(DocumentNo);
        
        // New structured event
        EventData.Add('documentNo', DocumentNo);
        EventData.Add('documentType', Format(DocumentType));
        EventData.Add('status', Status);
        EventData.Add('timestamp', CurrentDateTime());
        
        OnSalesDocumentStatusChanged(EventData);
    end;
}
```

### API Obsoleting Examples

```al
// Simple API obsoleting
page 50210 "Simple API Obsoleting"
{
    APIPublisher = 'MyCompany';
    APIGroup = 'items';
    APIVersion = 'v1.0';
    
    [Obsolete('This API version is deprecated. Use v2.0 for enhanced features', '24.0')]
    EntityName = 'item';
    EntitySetName = 'items';
    
    SourceTable = Item;
    
    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field(no; Rec."No.")
                {
                }
                
                // Field being replaced
                field(unitPrice; Rec."Unit Price")
                {
                    [Obsolete('Use priceInfo field in v2.0 for currency-aware pricing', '24.0')]
                }
                
                // Simple field migration
                field(description; Rec.Description)
                {
                }
            }
        }
    }
}
```

## Intermediate Obsoleting Samples

### Complex Migration Scenarios

```al
// Complex function splitting and migration
codeunit 50200 "Complex Migration Examples"
{
    // Original complex function being split
    [Obsolete('This function has been split for better performance: Use GetItemAvailability() for stock info, GetItemPricing() for price info, or GetItemComplete() for full data', '25.0')]
    procedure GetItemInformation(ItemNo: Code[20]; IncludeStock: Boolean; IncludePrice: Boolean; IncludeVendor: Boolean) Information: Text
    var
        StockInfo: JsonObject;
        PriceInfo: JsonObject;
        VendorInfo: JsonObject;
        CombinedInfo: JsonObject;
    begin
        // Maintain backward compatibility by calling new specialized functions
        if IncludeStock then
            StockInfo := GetItemAvailability(ItemNo);
        
        if IncludePrice then
            PriceInfo := GetItemPricing(ItemNo);
        
        if IncludeVendor then
            VendorInfo := GetItemVendorInfo(ItemNo);
        
        // Combine results in original format
        CombinedInfo.Add('stock', StockInfo);
        CombinedInfo.Add('pricing', PriceInfo);
        CombinedInfo.Add('vendor', VendorInfo);
        
        exit(Format(CombinedInfo));
    end;
    
    // New specialized function for availability
    procedure GetItemAvailability(ItemNo: Code[20]) AvailabilityInfo: JsonObject
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        QtyOnHand: Decimal;
        QtyReserved: Decimal;
        QtyAvailable: Decimal;
    begin
        if Item.Get(ItemNo) then begin
            Item.CalcFields(Inventory, "Reserved Qty. on Inventory");
            QtyOnHand := Item.Inventory;
            QtyReserved := Item."Reserved Qty. on Inventory";
            QtyAvailable := QtyOnHand - QtyReserved;
            
            AvailabilityInfo.Add('itemNo', ItemNo);
            AvailabilityInfo.Add('qtyOnHand', QtyOnHand);
            AvailabilityInfo.Add('qtyReserved', QtyReserved);
            AvailabilityInfo.Add('qtyAvailable', QtyAvailable);
            AvailabilityInfo.Add('lastUpdated', CurrentDateTime());
        end;
    end;
    
    // New specialized function for pricing
    procedure GetItemPricing(ItemNo: Code[20]) PricingInfo: JsonObject
    var
        Item: Record Item;
        SalesPrice: Record "Sales Price";
        PurchasePrice: Record "Purchase Price";
    begin
        if Item.Get(ItemNo) then begin
            PricingInfo.Add('itemNo', ItemNo);
            PricingInfo.Add('unitCost', Item."Unit Cost");
            PricingInfo.Add('unitPrice', Item."Unit Price");
            
            // Get special prices
            SalesPrice.SetRange("Item No.", ItemNo);
            if SalesPrice.FindFirst() then
                PricingInfo.Add('specialSalesPrice', SalesPrice."Unit Price");
            
            PurchasePrice.SetRange("Item No.", ItemNo);
            if PurchasePrice.FindFirst() then
                PricingInfo.Add('lastPurchasePrice', PurchasePrice."Unit Cost");
            
            PricingInfo.Add('profitMargin', CalculateProfitMargin(Item));
        end;
    end;
    
    // New specialized function for vendor info
    procedure GetItemVendorInfo(ItemNo: Code[20]) VendorInfo: JsonObject
    var
        Item: Record Item;
        ItemVendor: Record "Item Vendor";
        Vendor: Record Vendor;
        VendorList: JsonArray;
        VendorEntry: JsonObject;
    begin
        VendorInfo.Add('itemNo', ItemNo);
        
        ItemVendor.SetRange("Item No.", ItemNo);
        if ItemVendor.FindSet() then begin
            repeat
                if Vendor.Get(ItemVendor."Vendor No.") then begin
                    VendorEntry.Add('vendorNo', Vendor."No.");
                    VendorEntry.Add('vendorName', Vendor.Name);
                    VendorEntry.Add('leadTime', ItemVendor."Lead Time Calculation");
                    VendorEntry.Add('isPrimary', ItemVendor."Vendor No." = Item."Vendor No.");
                    
                    VendorList.Add(VendorEntry);
                    Clear(VendorEntry);
                end;
            until ItemVendor.Next() = 0;
        end;
        
        VendorInfo.Add('vendors', VendorList);
    end;
    
    // Comprehensive function for cases needing all data
    procedure GetItemComplete(ItemNo: Code[20]) CompleteInfo: JsonObject
    var
        AvailabilityInfo: JsonObject;
        PricingInfo: JsonObject;
        VendorInfo: JsonObject;
    begin
        // Optimized to get all information in single call
        AvailabilityInfo := GetItemAvailability(ItemNo);
        PricingInfo := GetItemPricing(ItemNo);
        VendorInfo := GetItemVendorInfo(ItemNo);
        
        CompleteInfo.Add('availability', AvailabilityInfo);
        CompleteInfo.Add('pricing', PricingInfo);
        CompleteInfo.Add('vendorInfo', VendorInfo);
        CompleteInfo.Add('completedAt', CurrentDateTime());
        CompleteInfo.Add('version', '2.0');
    end;
}
```

### API Version Migration

```al
// API version migration with enhanced features
page 50220 "Advanced API Migration v1"
{
    APIPublisher = 'MyCompany';
    APIGroup = 'customers';
    APIVersion = 'v1.0';
    
    [Obsolete('API v1.0 will be discontinued on 2025-12-31. Migrate to v2.0 for enhanced features. Migration guide: https://docs.company.com/api-migration', '24.0')]
    EntityName = 'customer';
    EntitySetName = 'customers';
    
    SourceTable = Customer;
    
    layout
    {
        area(Content)
        {
            repeater(Customers)
            {
                field(no; Rec."No.")
                {
                }
                
                field(name; Rec.Name)
                {
                }
                
                // Simple field being enhanced in v2
                field(phone; Rec."Phone No.")
                {
                    [Obsolete('Use contactInfo.primaryPhone in v2.0 for structured contact data', '24.0')]
                }
                
                field(email; Rec."E-Mail")
                {
                    [Obsolete('Use contactInfo.primaryEmail in v2.0 for structured contact data', '24.0')]
                }
                
                // Field with limited functionality
                field(balance; GetSimpleBalance())
                {
                    [Obsolete('Use financialInfo.currentBalance in v2.0 for currency-aware balance information', '24.0')]
                }
            }
        }
    }
    
    local procedure GetSimpleBalance(): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", Rec."No.");
        CustLedgerEntry.CalcFields("Remaining Amt. (LCY)");
        exit(CustLedgerEntry."Remaining Amt. (LCY)");
    end;
}

// Enhanced API v2.0
page 50221 "Advanced API Migration v2"
{
    APIPublisher = 'MyCompany';
    APIGroup = 'customers';
    APIVersion = 'v2.0';
    
    EntityName = 'customer';
    EntitySetName = 'customers';
    
    SourceTable = Customer;
    
    layout
    {
        area(Content)
        {
            repeater(Customers)
            {
                field(no; Rec."No.")
                {
                }
                
                field(name; Rec.Name)
                {
                }
                
                // Enhanced structured contact information
                field(contactInfo; GetStructuredContactInfo())
                {
                    Caption = 'Contact Information';
                }
                
                // Enhanced financial information with currency support
                field(financialInfo; GetStructuredFinancialInfo())
                {
                    Caption = 'Financial Information';
                }
                
                // New fields only available in v2.0
                field(preferences; GetCustomerPreferences())
                {
                    Caption = 'Customer Preferences';
                }
                
                field(metadata; GetRecordMetadata())
                {
                    Caption = 'Record Metadata';
                }
            }
        }
    }
    
    local procedure GetStructuredContactInfo(): Text
    var
        ContactInfo: JsonObject;
        PhoneNumbers: JsonArray;
        EmailAddresses: JsonArray;
        PhoneEntry: JsonObject;
        EmailEntry: JsonObject;
    begin
        // Primary contact info
        PhoneEntry.Add('type', 'primary');
        PhoneEntry.Add('number', Rec."Phone No.");
        PhoneNumbers.Add(PhoneEntry);
        
        EmailEntry.Add('type', 'primary');
        EmailEntry.Add('address', Rec."E-Mail");
        EmailAddresses.Add(EmailEntry);
        
        // Additional contact methods
        if Rec."Mobile Phone No." <> '' then begin
            Clear(PhoneEntry);
            PhoneEntry.Add('type', 'mobile');
            PhoneEntry.Add('number', Rec."Mobile Phone No.");
            PhoneNumbers.Add(PhoneEntry);
        end;
        
        ContactInfo.Add('phoneNumbers', PhoneNumbers);
        ContactInfo.Add('emailAddresses', EmailAddresses);
        ContactInfo.Add('website', Rec."Home Page");
        ContactInfo.Add('preferredContactMethod', GetPreferredContactMethod());
        
        exit(Format(ContactInfo));
    end;
    
    local procedure GetStructuredFinancialInfo(): Text
    var
        FinancialInfo: JsonObject;
        BalanceInfo: JsonObject;
        CreditInfo: JsonObject;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Current balance with currency information
        CustLedgerEntry.SetRange("Customer No.", Rec."No.");
        CustLedgerEntry.CalcFields("Remaining Amt. (LCY)", "Remaining Amount");
        
        BalanceInfo.Add('currentBalanceLCY', CustLedgerEntry."Remaining Amt. (LCY)");
        BalanceInfo.Add('currentBalance', CustLedgerEntry."Remaining Amount");
        BalanceInfo.Add('currencyCode', GetCustomerCurrencyCode());
        BalanceInfo.Add('lastUpdated', CurrentDateTime());
        
        // Credit information
        CreditInfo.Add('creditLimit', Rec."Credit Limit (LCY)");
        CreditInfo.Add('availableCredit', Rec."Credit Limit (LCY)" - CustLedgerEntry."Remaining Amt. (LCY)");
        CreditInfo.Add('creditUtilizationPercentage', CalculateCreditUtilization());
        
        FinancialInfo.Add('balance', BalanceInfo);
        FinancialInfo.Add('credit', CreditInfo);
        
        exit(Format(FinancialInfo));
    end;
}
```

## Advanced Enterprise Samples

### Migration Framework Implementation

```al
// Enterprise migration framework
codeunit 50300 "Enterprise Migration Framework"
{
    var
        MigrationTracker: Record "Migration Tracking" temporary;
        
    procedure ExecuteAPIVersionMigration(SourceVersion: Text; TargetVersion: Text; EntityType: Text)
    var
        MigrationPlan: Record "API Migration Plan";
        MigrationRule: Record "API Migration Rule";
        MigrationResult: Record "Migration Execution Result" temporary;
        OverallSuccess: Boolean;
    begin
        // Initialize migration tracking
        InitializeMigrationTracking(SourceVersion, TargetVersion, EntityType);
        
        // Load migration plan
        LoadAPIVersionMigrationPlan(SourceVersion, TargetVersion, EntityType, MigrationPlan);
        
        // Execute migration phases
        OverallSuccess := ExecuteMigrationPhases(MigrationPlan, MigrationResult);
        
        // Generate migration report
        GenerateMigrationReport(MigrationPlan, MigrationResult, OverallSuccess);
        
        if not OverallSuccess then
            HandleMigrationFailure(MigrationPlan, MigrationResult);
    end;
    
    local procedure ExecuteMigrationPhases(var MigrationPlan: Record "API Migration Plan"; var MigrationResult: Record "Migration Execution Result" temporary): Boolean
    var
        MigrationPhase: Record "API Migration Phase";
        PhaseExecutor: Codeunit "Migration Phase Executor";
        PhaseResult: Boolean;
        OverallResult: Boolean;
    begin
        OverallResult := true;
        
        MigrationPhase.SetRange("Migration Plan ID", MigrationPlan.ID);
        MigrationPhase.SetCurrentKey("Execution Order");
        
        if MigrationPhase.FindSet() then begin
            repeat
                PhaseResult := ExecuteSingleMigrationPhase(MigrationPhase, MigrationResult);
                
                if not PhaseResult then begin
                    OverallResult := false;
                    LogPhaseFailure(MigrationPhase, MigrationResult);
                    
                    if MigrationPhase."Stop on Failure" then
                        break;
                end else
                    LogPhaseSuccess(MigrationPhase, MigrationResult);
                    
            until MigrationPhase.Next() = 0;
        end;
        
        exit(OverallResult);
    end;
    
    local procedure ExecuteSingleMigrationPhase(var MigrationPhase: Record "API Migration Phase"; var MigrationResult: Record "Migration Execution Result" temporary): Boolean
    var
        PhaseExecutor: Interface "IMigration Phase Executor";
        PhaseContext: Record "Migration Phase Context";
        ExecutionResult: Boolean;
        StartTime: DateTime;
        EndTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        
        try
            // Initialize phase context
            InitializePhaseContext(MigrationPhase, PhaseContext);
            
            // Get appropriate executor
            PhaseExecutor := GetPhaseExecutor(MigrationPhase."Phase Type");
            
            // Execute phase
            ExecutionResult := PhaseExecutor.ExecutePhase(MigrationPhase, PhaseContext);
            
            EndTime := CurrentDateTime();
            
            // Record results
            RecordPhaseExecution(MigrationPhase, ExecutionResult, StartTime, EndTime, MigrationResult);
            
        except
            EndTime := CurrentDateTime();
            RecordPhaseException(MigrationPhase, GetLastErrorText(), StartTime, EndTime, MigrationResult);
            ExecutionResult := false;
        end;
        
        exit(ExecutionResult);
    end;
    
    procedure AnalyzeMigrationImpact(SourceAPI: Text; TargetAPI: Text) ImpactAnalysis: JsonObject
    var
        UsageAnalyzer: Codeunit "API Usage Analyzer";
        DependencyAnalyzer: Codeunit "API Dependency Analyzer";
        UsageMetrics: Record "API Usage Metrics" temporary;
        Dependencies: Record "API Dependencies" temporary;
        RiskAssessment: JsonObject;
        MigrationEffort: JsonObject;
    begin
        // Analyze current usage patterns
        UsageAnalyzer.AnalyzeAPIUsage(SourceAPI, UsageMetrics);
        
        // Analyze dependencies
        DependencyAnalyzer.AnalyzeDependencies(SourceAPI, Dependencies);
        
        // Calculate risk assessment
        RiskAssessment := CalculateRiskAssessment(UsageMetrics, Dependencies);
        
        // Estimate migration effort
        MigrationEffort := EstimateMigrationEffort(SourceAPI, TargetAPI, UsageMetrics);
        
        // Compile impact analysis
        ImpactAnalysis.Add('sourceAPI', SourceAPI);
        ImpactAnalysis.Add('targetAPI', TargetAPI);
        ImpactAnalysis.Add('usageMetrics', Format(UsageMetrics));
        ImpactAnalysis.Add('dependencies', Format(Dependencies));
        ImpactAnalysis.Add('riskAssessment', RiskAssessment);
        ImpactAnalysis.Add('migrationEffort', MigrationEffort);
        ImpactAnalysis.Add('analysisDate', CurrentDateTime());
    end;
}
```

### Automated Code Transformation

```al
// Automated code transformation for migration
codeunit 50350 "Automated Code Transformer"
{
    procedure TransformObsoleteCode(SourceCode: Text; ObsoletePattern: Text; ReplacementPattern: Text) TransformedCode: Text
    var
        PatternMatcher: Codeunit "Code Pattern Matcher";
        CodeRewriter: Codeunit "Code Rewriter";
        TransformationRules: Record "Code Transformation Rules" temporary;
        MatchingPatterns: List of [Text];
        Pattern: Text;
        TransformationSuccess: Boolean;
    begin
        // Load transformation rules
        LoadTransformationRules(ObsoletePattern, ReplacementPattern, TransformationRules);
        
        // Find matching patterns in source code
        PatternMatcher.FindPatterns(SourceCode, ObsoletePattern, MatchingPatterns);
        
        if MatchingPatterns.Count() = 0 then
            exit(SourceCode); // No patterns to transform
        
        // Apply transformations
        TransformedCode := SourceCode;
        TransformationSuccess := true;
        
        foreach Pattern in MatchingPatterns do begin
            if not CodeRewriter.ApplyTransformation(TransformedCode, Pattern, ReplacementPattern) then
                TransformationSuccess := false;
        end;
        
        // Validate transformation result
        if TransformationSuccess and ValidateTransformedCode(TransformedCode) then begin
            LogSuccessfulTransformation(ObsoletePattern, ReplacementPattern, MatchingPatterns.Count());
            exit(TransformedCode);
        end else begin
            LogTransformationFailure(ObsoletePattern, SourceCode);
            exit(SourceCode); // Return original if transformation fails
        end;
    end;
    
    procedure GenerateTransformationReport(SourceCode: Text; TransformedCode: Text; TransformationType: Text) Report: JsonObject
    var
        ChangeAnalyzer: Codeunit "Code Change Analyzer";
        Changes: Record "Code Changes" temporary;
        ChangesSummary: JsonObject;
        ValidationResults: JsonObject;
    begin
        // Analyze changes
        ChangeAnalyzer.AnalyzeChanges(SourceCode, TransformedCode, Changes);
        
        // Summarize changes
        ChangesSummary := SummarizeChanges(Changes);
        
        // Validate transformed code
        ValidationResults := ValidateTransformation(TransformedCode, TransformationType);
        
        // Generate comprehensive report
        Report.Add('transformationType', TransformationType);
        Report.Add('sourceLineCount', CountLines(SourceCode));
        Report.Add('transformedLineCount', CountLines(TransformedCode));
        Report.Add('changesSummary', ChangesSummary);
        Report.Add('validationResults', ValidationResults);
        Report.Add('transformationDate', CurrentDateTime());
        Report.Add('confidence', CalculateTransformationConfidence(Changes, ValidationResults));
    end;
}
```

These samples demonstrate comprehensive obsoleting patterns from basic function deprecation to enterprise-scale automated migration frameworks.
