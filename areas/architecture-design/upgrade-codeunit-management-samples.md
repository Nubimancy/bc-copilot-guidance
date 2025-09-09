# Upgrade Codeunit Management - Sample Implementations

This document provides comprehensive code samples for the upgrade codeunit management patterns outlined in `upgrade-codeunit-management-patterns.md`.

## Basic Upgrade Codeunit Samples

### Simple Per-Company Upgrade

```al
codeunit 50150 "Basic Upgrade Example"
{
    Subtype = Upgrade;
    
    trigger OnUpgradePerCompany()
    begin
        // Basic field migration with proper tag management
        if not UpgradeTag.HasUpgradeTag('50150-CustomerGrade-20250120') then begin
            MigrateCustomerGradeField();
            UpgradeTag.SetUpgradeTag('50150-CustomerGrade-20250120');
        end;
    end;
    
    local procedure MigrateCustomerGradeField()
    var
        Customer: Record Customer;
        Counter: Integer;
    begin
        Customer.SetFilter("Old Grade Field", '<>%1', '');
        if Customer.FindSet(true) then begin
            repeat
                // Simple field mapping
                Customer."Customer Grade" := ConvertOldGradeToNew(Customer."Old Grade Field");
                Customer."Old Grade Field" := ''; // Clear old field
                Customer.Modify(true);
                Counter += 1;
            until Customer.Next() = 0;
        end;
        
        Message('Migrated %1 customer records', Counter);
    end;
    
    local procedure ConvertOldGradeToNew(OldGrade: Text[20]): Enum "Customer Grade"
    begin
        case UpperCase(OldGrade) of
            'A', 'PREMIUM':
                exit("Customer Grade"::Premium);
            'B', 'STANDARD':
                exit("Customer Grade"::Standard);
            'C', 'BASIC':
                exit("Customer Grade"::Basic);
            else
                exit("Customer Grade"::Standard); // Default fallback
        end;
    end;
}
```

### Per-Database Setup Migration

```al
codeunit 50151 "Database Setup Upgrade"
{
    Subtype = Upgrade;
    
    trigger OnUpgradePerDatabase()
    begin
        if not UpgradeTag.HasUpgradeTag('50151-NumberSeries-20250120', '', true) then begin
            CreateDefaultNumberSeries();
            UpgradeTag.SetUpgradeTag('50151-NumberSeries-20250120', '', true);
        end;
    end;
    
    local procedure CreateDefaultNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create primary number series
        if not NoSeries.Get('CUSTGRADE') then begin
            NoSeries.Init();
            NoSeries.Code := 'CUSTGRADE';
            NoSeries.Description := 'Customer Grade Assignments';
            NoSeries."Default Nos." := true;
            NoSeries.Insert(true);
            
            // Create number series line
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'CUSTGRADE';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'CG000001';
            NoSeriesLine."Ending No." := 'CG999999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;
    end;
}
```

## Intermediate Upgrade Samples

### Data Migration with Error Handling

```al
codeunit 50200 "Advanced Data Migration"
{
    Subtype = Upgrade;
    
    var
        ErrorCount: Integer;
        ProcessedCount: Integer;
        SkippedCount: Integer;
    
    trigger OnUpgradePerCompany()
    begin
        if not UpgradeTag.HasUpgradeTag('50200-InventoryRestructure-20250120') then begin
            if MigrateInventoryDataWithValidation() then
                UpgradeTag.SetUpgradeTag('50200-InventoryRestructure-20250120')
            else
                Error('Inventory migration failed. Processed: %1, Errors: %2, Skipped: %3', 
                      ProcessedCount, ErrorCount, SkippedCount);
        end;
    end;
    
    local procedure MigrateInventoryDataWithValidation(): Boolean
    var
        Item: Record Item;
        InventoryEntry: Record "Item Ledger Entry";
        MigrationSuccess: Boolean;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        ClearCounters();
        
        // Phase 1: Validate data integrity
        if not ValidateInventoryDataIntegrity() then
            exit(false);
        
        // Phase 2: Migrate item master data
        Item.SetRange("Old Category Code", '..', 'ZZZZZ'); // Non-blank values
        if Item.FindSet(true) then begin
            repeat
                if MigrateSingleItem(Item) then
                    ProcessedCount += 1
                else begin
                    ErrorCount += 1;
                    LogItemMigrationError(Item);
                end;
            until Item.Next() = 0;
        end;
        
        // Phase 3: Update inventory entries
        MigrationSuccess := UpdateInventoryEntries();
        
        // Phase 4: Validate migration results
        if MigrationSuccess then
            MigrationSuccess := ValidateMigrationResults();
        
        LogMigrationCompletion(StartTime, MigrationSuccess);
        exit(MigrationSuccess);
    end;
    
    local procedure MigrateSingleItem(var Item: Record Item): Boolean
    var
        NewCategoryCode: Code[20];
        ValidationResult: Boolean;
    begin
        // Validate item data
        if not ValidateItemForMigration(Item) then
            exit(false);
        
        // Convert category code
        NewCategoryCode := ConvertCategoryCode(Item."Old Category Code");
        if NewCategoryCode = '' then begin
            SkippedCount += 1;
            exit(false);
        end;
        
        // Update item with error handling
        try
            Item."Item Category Code" := NewCategoryCode;
            Item."Migration Date" := Today();
            Item."Migrated By" := UserId();
            Item.Modify(true);
            
            // Clear old field
            Item."Old Category Code" := '';
            Item.Modify(true);
            
            exit(true);
        except
            // Log specific error but continue processing
            LogItemUpdateError(Item, GetLastErrorText());
            exit(false);
        end;
    end;
    
    local procedure ValidateInventoryDataIntegrity(): Boolean
    var
        Item: Record Item;
        DuplicateCount: Integer;
        OrphanedCount: Integer;
    begin
        // Check for duplicate items
        Item.SetCurrentKey("No.");
        Item.SetFilter("Old Category Code", '<>%1', '');
        DuplicateCount := Item.Count();
        
        // Additional validation logic here
        if DuplicateCount = 0 then begin
            Message('No inventory data requires migration');
            exit(true);
        end;
        
        if DuplicateCount > 10000 then begin
            Error('Too many items to migrate in single operation: %1. Consider batch processing.', DuplicateCount);
            exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure LogMigrationCompletion(StartTime: DateTime; Success: Boolean)
    var
        Duration: Integer;
        ActivityLog: Record "Activity Log";
        LogText: Text;
    begin
        Duration := CurrentDateTime() - StartTime;
        
        if Success then begin
            LogText := StrSubstNo('Inventory migration completed successfully. Duration: %1ms, Processed: %2, Errors: %3, Skipped: %4',
                                  Duration, ProcessedCount, ErrorCount, SkippedCount);
            ActivityLog.LogActivity(Item, ActivityLog.Status::Success, 'Data Migration', 'Inventory Restructure', LogText);
        end else begin
            LogText := StrSubstNo('Inventory migration failed. Duration: %1ms, Processed: %2, Errors: %3, Skipped: %4',
                                  Duration, ProcessedCount, ErrorCount, SkippedCount);
            ActivityLog.LogActivity(Item, ActivityLog.Status::Failed, 'Data Migration', 'Inventory Restructure', LogText);
        end;
    end;
    
    local procedure ClearCounters()
    begin
        ErrorCount := 0;
        ProcessedCount := 0;
        SkippedCount := 0;
    end;
}
```

### Rollback-Capable Migration

```al
codeunit 50250 "Rollback Migration Example"
{
    Subtype = Upgrade;
    
    var
        RollbackData: Record "Migration Rollback Data" temporary;
    
    trigger OnUpgradePerCompany()
    begin
        if not UpgradeTag.HasUpgradeTag('50250-PriceStructure-20250120') then begin
            if ExecutePriceStructureMigration() then
                UpgradeTag.SetUpgradeTag('50250-PriceStructure-20250120')
            else
                ExecuteRollback(); // Rollback on failure
        end;
    end;
    
    local procedure ExecutePriceStructureMigration(): Boolean
    var
        SalesPrice: Record "Sales Price";
        MigrationPhase: Integer;
        PhaseSuccess: Boolean;
    begin
        // Prepare rollback data before making changes
        PrepareRollbackData();
        
        // Phase 1: Backup existing data
        MigrationPhase := 1;
        PhaseSuccess := BackupExistingPrices();
        if not PhaseSuccess then
            exit(false);
        
        // Phase 2: Create new price structures
        MigrationPhase := 2;
        PhaseSuccess := CreateNewPriceStructures();
        if not PhaseSuccess then begin
            RollbackPhase(MigrationPhase - 1);
            exit(false);
        end;
        
        // Phase 3: Migrate price data
        MigrationPhase := 3;
        PhaseSuccess := MigratePriceData();
        if not PhaseSuccess then begin
            RollbackPhase(MigrationPhase - 1);
            exit(false);
        end;
        
        // Phase 4: Validate migration
        if not ValidatePriceMigration() then begin
            RollbackPhase(MigrationPhase);
            exit(false);
        end;
        
        // Clean up rollback data on success
        ClearRollbackData();
        exit(true);
    end;
    
    local procedure PrepareRollbackData()
    var
        SalesPrice: Record "Sales Price";
        RollbackEntry: Record "Migration Rollback Data" temporary;
    begin
        // Store original data for potential rollback
        SalesPrice.SetRange("Starting Date", 0D, Today());
        if SalesPrice.FindSet() then begin
            repeat
                RollbackEntry.Init();
                RollbackEntry."Entry No." := RollbackEntry."Entry No." + 1;
                RollbackEntry."Table ID" := Database::"Sales Price";
                RollbackEntry."Primary Key" := SalesPrice.GetPosition();
                RollbackEntry."Original Data" := SerializeSalesPriceRecord(SalesPrice);
                RollbackData.Insert();
            until SalesPrice.Next() = 0;
        end;
    end;
    
    local procedure RollbackPhase(Phase: Integer)
    var
        RollbackEntry: Record "Migration Rollback Data" temporary;
        SalesPrice: Record "Sales Price";
    begin
        case Phase of
            1: RollbackPhase1(); // Restore original backup
            2: RollbackPhase2(); // Remove created structures
            3: RollbackPhase3(); // Restore original data
        end;
        
        // Log rollback action
        LogRollbackExecution(Phase);
    end;
    
    local procedure ExecuteRollback()
    begin
        // Complete rollback of all changes
        RollbackPhase(3);
        RollbackPhase(2);
        RollbackPhase(1);
        
        Error('Price structure migration failed and has been rolled back. Check logs for details.');
    end;
}
```

## Advanced Enterprise Samples

### Multi-Phase Enterprise Migration

```al
codeunit 50300 "Enterprise Migration Framework"
{
    Subtype = Upgrade;
    
    var
        MigrationOrchestrator: Codeunit "Migration Orchestrator";
        PerformanceMonitor: Codeunit "Performance Monitor";
        NotificationService: Codeunit "Notification Service";
    
    trigger OnUpgradePerCompany()
    var
        EnterpriseContext: Record "Enterprise Migration Context";
    begin
        if not UpgradeTag.HasUpgradeTag('50300-EnterpriseMigration-20250120') then begin
            InitializeEnterpriseContext(EnterpriseContext);
            
            if ExecuteEnterpriseMigration(EnterpriseContext) then
                UpgradeTag.SetUpgradeTag('50300-EnterpriseMigration-20250120')
            else
                HandleMigrationFailure(EnterpriseContext);
        end;
    end;
    
    local procedure ExecuteEnterpriseMigration(var Context: Record "Enterprise Migration Context"): Boolean
    var
        MigrationPhases: List of [Text];
        CurrentPhase: Text;
        OverallSuccess: Boolean;
        PhaseResult: Boolean;
    begin
        // Initialize performance monitoring
        PerformanceMonitor.StartMonitoring('EnterpriseMigration');
        
        // Define enterprise migration phases
        MigrationPhases.Add('DataValidation');
        MigrationPhases.Add('SchemaUpgrade');
        MigrationPhases.Add('DataMigration');
        MigrationPhases.Add('BusinessLogicUpdate');
        MigrationPhases.Add('IntegrationUpdate');
        MigrationPhases.Add('ValidationAndTesting');
        
        OverallSuccess := true;
        foreach CurrentPhase in MigrationPhases do begin
            NotificationService.NotifyPhaseStart(CurrentPhase, Context);
            
            PhaseResult := ExecuteMigrationPhase(CurrentPhase, Context);
            LogPhaseCompletion(CurrentPhase, PhaseResult, Context);
            
            if not PhaseResult then begin
                OverallSuccess := false;
                NotificationService.NotifyPhaseFailure(CurrentPhase, Context);
                
                if ShouldAbortOnPhaseFailure(CurrentPhase) then
                    break;
            end else begin
                NotificationService.NotifyPhaseSuccess(CurrentPhase, Context);
            end;
        end;
        
        // Complete monitoring
        PerformanceMonitor.StopMonitoring('EnterpriseMigration');
        
        exit(OverallSuccess);
    end;
    
    local procedure ExecuteMigrationPhase(Phase: Text; var Context: Record "Enterprise Migration Context"): Boolean
    var
        PhaseExecutor: Interface "IMigration Phase Executor";
        PhaseContext: Record "Phase Execution Context";
        ExecutionResult: Boolean;
    begin
        // Create phase-specific context
        CreatePhaseContext(Phase, Context, PhaseContext);
        
        // Get appropriate executor for phase
        PhaseExecutor := GetPhaseExecutor(Phase);
        
        // Execute phase with monitoring
        try
            ExecutionResult := PhaseExecutor.Execute(PhaseContext);
        except
            LogPhaseException(Phase, GetLastErrorText(), Context);
            ExecutionResult := false;
        end;
        
        // Update context with results
        UpdatePhaseResults(Phase, ExecutionResult, PhaseContext, Context);
        
        exit(ExecutionResult);
    end;
    
    local procedure GetPhaseExecutor(Phase: Text): Interface "IMigration Phase Executor"
    var
        DataValidationExecutor: Codeunit "Data Validation Executor";
        SchemaUpgradeExecutor: Codeunit "Schema Upgrade Executor";
        DataMigrationExecutor: Codeunit "Data Migration Executor";
        BusinessLogicExecutor: Codeunit "Business Logic Executor";
        IntegrationExecutor: Codeunit "Integration Update Executor";
        ValidationExecutor: Codeunit "Validation Testing Executor";
    begin
        case Phase of
            'DataValidation':
                exit(DataValidationExecutor);
            'SchemaUpgrade':
                exit(SchemaUpgradeExecutor);
            'DataMigration':
                exit(DataMigrationExecutor);
            'BusinessLogicUpdate':
                exit(BusinessLogicExecutor);
            'IntegrationUpdate':
                exit(IntegrationExecutor);
            'ValidationAndTesting':
                exit(ValidationExecutor);
            else
                Error('Unknown migration phase: %1', Phase);
        end;
    end;
}
```

### Machine Learning Upgrade Optimization

```al
codeunit 50400 "ML Upgrade Optimizer"
{
    var
        MLAnalyzer: Codeunit "Machine Learning Analyzer";
        PerformancePredictor: Codeunit "Performance Predictor";
        OptimizationEngine: Codeunit "Optimization Engine";
    
    /// <summary>
    /// Uses machine learning to optimize upgrade performance
    /// </summary>
    procedure OptimizeUpgradeStrategy(var UpgradeContext: Record "Enterprise Migration Context"): Text
    var
        SystemProfile: Record "System Performance Profile" temporary;
        HistoricalData: Record "Upgrade History" temporary;
        OptimizedStrategy: Text;
        PredictedDuration: Integer;
        RecommendedBatchSize: Integer;
        OptimalExecutionTime: DateTime;
    begin
        // Analyze current system performance
        AnalyzeSystemPerformance(SystemProfile);
        
        // Load historical upgrade data
        LoadUpgradeHistory(HistoricalData);
        
        // Generate ML-based recommendations
        OptimizedStrategy := MLAnalyzer.GenerateUpgradeStrategy(SystemProfile, HistoricalData);
        PredictedDuration := PerformancePredictor.PredictUpgradeDuration(SystemProfile, UpgradeContext);
        RecommendedBatchSize := OptimizationEngine.CalculateOptimalBatchSize(SystemProfile);
        OptimalExecutionTime := OptimizationEngine.RecommendExecutionTime(SystemProfile, PredictedDuration);
        
        // Update context with optimized parameters
        UpgradeContext."Recommended Batch Size" := RecommendedBatchSize;
        UpgradeContext."Predicted Duration" := PredictedDuration;
        UpgradeContext."Optimal Start Time" := OptimalExecutionTime;
        UpgradeContext."Strategy" := OptimizedStrategy;
        UpgradeContext.Modify();
        
        exit(OptimizedStrategy);
    end;
    
    local procedure AnalyzeSystemPerformance(var SystemProfile: Record "System Performance Profile" temporary)
    var
        SystemInfo: Codeunit "System Information";
        DatabaseInfo: Record "Database Information";
    begin
        // Collect system metrics
        SystemProfile.Init();
        SystemProfile."CPU Usage" := GetCurrentCPUUsage();
        SystemProfile."Memory Usage" := GetCurrentMemoryUsage();
        SystemProfile."Disk IO Rate" := GetCurrentDiskIORate();
        SystemProfile."Network Latency" := GetNetworkLatency();
        SystemProfile."Database Size" := GetDatabaseSize();
        SystemProfile."Active Users" := GetActiveUserCount();
        SystemProfile."Peak Usage Hours" := GetPeakUsagePattern();
        SystemProfile.Insert();
    end;
    
    /// <summary>
    /// Provides real-time upgrade recommendations during execution
    /// </summary>
    procedure GetRealTimeRecommendations(CurrentMetrics: Record "Real Time Metrics"): Text
    var
        RecommendationText: Text;
        AdjustedBatchSize: Integer;
        SuggestedActions: List of [Text];
    begin
        // Analyze current performance metrics
        if CurrentMetrics."CPU Usage" > 80 then begin
            SuggestedActions.Add('Reduce batch size by 25%');
            SuggestedActions.Add('Implement processing delays');
        end;
        
        if CurrentMetrics."Memory Usage" > 75 then begin
            SuggestedActions.Add('Increase garbage collection frequency');
            SuggestedActions.Add('Process in smaller chunks');
        end;
        
        if CurrentMetrics."Lock Contention" > 5 then begin
            SuggestedActions.Add('Implement lock optimization');
            SuggestedActions.Add('Consider sequential processing');
        end;
        
        // Generate recommendation text
        RecommendationText := FormatRecommendations(SuggestedActions);
        
        exit(RecommendationText);
    end;
}
```

## Tag Management Examples

### Comprehensive Tag Naming

```al
// Comprehensive tag naming examples for different scenarios
local procedure DemonstrateTagNamingBestPractices()
begin
    // ✅ Standard format: AppID-Feature-Date
    UpgradeTag.SetUpgradeTag('50100-CustomerMigration-20250120', '', false);
    UpgradeTag.SetUpgradeTag('50100-InventoryRestructure-20250120', '', false);
    UpgradeTag.SetUpgradeTag('50100-APIEndpointUpdate-20250120', '', false);
    
    // ✅ Multi-phase upgrades with phase indicators
    UpgradeTag.SetUpgradeTag('50100-DataMigration-Phase1-20250120', '', false);
    UpgradeTag.SetUpgradeTag('50100-DataMigration-Phase2-20250120', '', false);
    UpgradeTag.SetUpgradeTag('50100-DataMigration-Phase3-20250120', '', false);
    
    // ✅ Environment-specific tags
    UpgradeTag.SetUpgradeTag('50100-ProdOptimization-20250120', '', false);
    UpgradeTag.SetUpgradeTag('50100-SandboxTesting-20250120', '', false);
    
    // ✅ Version-specific migrations
    UpgradeTag.SetUpgradeTag('50100-UpgradeToV2.1-20250120', '', false);
    UpgradeTag.SetUpgradeTag('50100-BackwardCompatibility-20250120', '', false);
    
    // ✅ Per-database vs per-company clarity
    UpgradeTag.SetUpgradeTag('50100-GlobalSettings-20250120', '', true);    // Per-database
    UpgradeTag.SetUpgradeTag('50100-CompanyData-20250120', '', false);      // Per-company
end;
```

### Tag Validation and Cleanup

```al
// Tag management utilities
codeunit 50500 "Upgrade Tag Management"
{
    /// <summary>
    /// Validates existing upgrade tags and reports status
    /// </summary>
    procedure ValidateUpgradeTags(): Boolean
    var
        ExpectedTags: List of [Text];
        CurrentTag: Text;
        AllTagsValid: Boolean;
    begin
        AllTagsValid := true;
        
        // Define expected tags for current version
        PopulateExpectedTags(ExpectedTags);
        
        foreach CurrentTag in ExpectedTags do begin
            if not UpgradeTag.HasUpgradeTag(CurrentTag) then begin
                LogMissingTag(CurrentTag);
                AllTagsValid := false;
            end;
        end;
        
        exit(AllTagsValid);
    end;
    
    /// <summary>
    /// Lists all upgrade tags for documentation
    /// </summary>
    procedure DocumentUpgradeTags()
    var
        UpgradeTagRecord: Record "Upgrade Tags";
        DocumentationText: Text;
    begin
        if UpgradeTagRecord.FindSet() then begin
            repeat
                DocumentationText += StrSubstNo('Tag: %1, Created: %2, Company: %3\n',
                    UpgradeTagRecord.Tag, UpgradeTagRecord."Tag Timestamp", UpgradeTagRecord."Company Name");
            until UpgradeTagRecord.Next() = 0;
        end;
        
        // Export to file or display
        ExportUpgradeDocumentation(DocumentationText);
    end;
}
```

These samples demonstrate practical implementations of the upgrade patterns, from basic migrations to enterprise-grade orchestration systems with machine learning optimization.
