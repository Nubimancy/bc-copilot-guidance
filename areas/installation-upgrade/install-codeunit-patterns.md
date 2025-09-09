---
title: "Install Codeunit Patterns"
description: "Comprehensive patterns for Business Central install codeunits with intelligent initialization and dependency management"
area: "installation-upgrade"
difficulty: "advanced"
object_types: ["Codeunit", "Table"]
variable_types: ["RecordRef", "JsonObject", "Boolean", "ErrorInfo"]
tags: ["install-codeunit", "initialization", "setup-data", "dependencies", "error-handling"]
---

# Install Codeunit Patterns

## Overview

Install codeunit patterns in Business Central enable automated application setup, data initialization, and dependency management during extension installation. This atomic covers intelligent installation frameworks with comprehensive error handling, rollback capabilities, and environment-specific configuration.

## Smart Install Framework

### AI-Enhanced Install Codeunit
```al
codeunit 50200 "Smart Install Manager"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        RunIntelligentInstallProcess();
    end;

    trigger OnInstallAppPerDatabase()
    begin
        RunDatabaseLevelInstall();
    end;

    local procedure RunIntelligentInstallProcess()
    var
        InstallationEngine: Codeunit "Installation Engine";
        InstallationContext: JsonObject;
    begin
        // Initialize installation context with environment analysis
        InstallationContext := BuildInstallationContext();
        
        // Run comprehensive installation with AI optimization
        InstallationEngine.ExecuteIntelligentInstall(InstallationContext);
    end;

    local procedure BuildInstallationContext(): JsonObject
    var
        Context: JsonObject;
        EnvironmentAnalyzer: Codeunit "Environment Analyzer";
        CompanyAnalyzer: Codeunit "Company Context Analyzer";
    begin
        // Analyze installation environment
        Context.Add('environment', EnvironmentAnalyzer.AnalyzeEnvironment());
        
        // Analyze company-specific context
        Context.Add('companyContext', CompanyAnalyzer.AnalyzeCompanySetup());
        
        // Add installation metadata
        Context.Add('installationTime', CurrentDateTime());
        Context.Add('installingUser', UserId());
        Context.Add('appVersion', GetCurrentAppVersion());
        
        exit(Context);
    end;
}
```

### Installation Engine Framework
```al
codeunit 50201 "Installation Engine"
{
    procedure ExecuteIntelligentInstall(InstallationContext: JsonObject)
    var
        InstallationOrchestrator: Codeunit "Installation Orchestrator";
        DependencyManager: Codeunit "Dependency Manager";
        ConfigurationEngine: Codeunit "Configuration Engine";
        ValidationEngine: Codeunit "Installation Validator";
    begin
        // Validate installation prerequisites
        ValidationEngine.ValidateInstallationReadiness(InstallationContext);
        
        // Resolve and install dependencies
        DependencyManager.ResolveDependencies(InstallationContext);
        
        // Execute orchestrated installation
        InstallationOrchestrator.ExecuteInstallationSteps(InstallationContext);
        
        // Apply intelligent configuration
        ConfigurationEngine.ApplyIntelligentConfiguration(InstallationContext);
        
        // Finalize installation
        FinalizeInstallation(InstallationContext);
    end;

    local procedure FinalizeInstallation(InstallationContext: JsonObject)
    var
        InstallationLogger: Codeunit "Installation Logger";
        PostInstallValidator: Codeunit "Post Install Validator";
    begin
        // Log successful installation
        InstallationLogger.LogInstallationSuccess(InstallationContext);
        
        // Run post-installation validation
        PostInstallValidator.ValidateInstallationResult(InstallationContext);
        
        // Initialize telemetry
        InitializeInstallationTelemetry(InstallationContext);
    end;
}
```

## Data Initialization Patterns

### Smart Data Setup Manager
```al
codeunit 50202 "Smart Data Setup Manager"
{
    procedure InitializeApplicationData(InstallationContext: JsonObject)
    var
        SetupDataBuilder: Codeunit "Setup Data Builder";
        MasterDataInitializer: Codeunit "Master Data Initializer";
        ConfigurationPresets: Codeunit "Configuration Presets";
    begin
        // Initialize foundational setup data
        SetupDataBuilder.CreateFoundationalSetup(InstallationContext);
        
        // Initialize master data with intelligent defaults
        MasterDataInitializer.InitializeMasterData(InstallationContext);
        
        // Apply configuration presets based on context
        ConfigurationPresets.ApplyIntelligentPresets(InstallationContext);
        
        // Initialize security and permissions
        InitializeSecuritySetup(InstallationContext);
    end;

    local procedure InitializeSecuritySetup(InstallationContext: JsonObject)
    var
        PermissionSetManager: Codeunit "Permission Set Manager";
        SecurityConfigManager: Codeunit "Security Config Manager";
        DefaultPermissions: JsonArray;
    begin
        // Create default permission sets
        DefaultPermissions := BuildDefaultPermissionSets();
        PermissionSetManager.CreatePermissionSets(DefaultPermissions);
        
        // Configure security policies
        SecurityConfigManager.ApplySecurityConfiguration(InstallationContext);
    end;
}
```

### Configuration Presets Engine
```al
codeunit 50203 "Configuration Presets"
{
    procedure ApplyIntelligentPresets(InstallationContext: JsonObject)
    var
        PresetAnalyzer: Codeunit "Preset Analyzer";
        CompanyContext: JsonObject;
        RecommendedPresets: JsonArray;
    begin
        InstallationContext.Get('companyContext', CompanyContext);
        
        // Analyze company context to determine appropriate presets
        RecommendedPresets := PresetAnalyzer.AnalyzePresetRequirements(CompanyContext);
        
        // Apply recommended configuration presets
        ApplyConfigurationPresets(RecommendedPresets);
    end;

    local procedure ApplyConfigurationPresets(Presets: JsonArray)
    var
        PresetToken: JsonToken;
        PresetObject: JsonObject;
        PresetType: Text;
        i: Integer;
    begin
        for i := 0 to Presets.Count() - 1 do begin
            Presets.Get(i, PresetToken);
            PresetObject := PresetToken.AsObject();
            PresetObject.Get('presetType', PresetType);
            
            case PresetType of
                'NumberSeries':
                    ApplyNumberSeriesPreset(PresetObject);
                'ChartOfAccounts':
                    ApplyChartOfAccountsPreset(PresetObject);
                'VATSetup':
                    ApplyVATSetupPreset(PresetObject);
                'PaymentTerms':
                    ApplyPaymentTermsPreset(PresetObject);
            end;
        end;
    end;

    local procedure ApplyNumberSeriesPreset(PresetConfig: JsonObject)
    var
        NoSeriesLine: Record "No. Series Line";
        NoSeriesManager: Codeunit "No. Series Manager";
        SeriesCode: Text;
        StartingNo: Text;
    begin
        PresetConfig.Get('seriesCode', SeriesCode);
        PresetConfig.Get('startingNo', StartingNo);
        
        // Create number series with intelligent defaults
        NoSeriesManager.CreateNumberSeries(SeriesCode, StartingNo, true);
    end;
}
```

## Dependency Management Framework

### Intelligent Dependency Resolver
```al
codeunit 50204 "Dependency Manager"
{
    procedure ResolveDependencies(InstallationContext: JsonObject)
    var
        DependencyAnalyzer: Codeunit "Dependency Analyzer";
        DependencyGraph: JsonObject;
        InstallationOrder: JsonArray;
    begin
        // Analyze application dependencies
        DependencyGraph := DependencyAnalyzer.BuildDependencyGraph();
        
        // Calculate optimal installation order
        InstallationOrder := CalculateInstallationOrder(DependencyGraph);
        
        // Execute dependency installation
        ExecuteDependencyInstallation(InstallationOrder, InstallationContext);
    end;

    local procedure CalculateInstallationOrder(DependencyGraph: JsonObject): JsonArray
    var
        TopologicalSorter: Codeunit "Topological Sorter";
        InstallationOrder: JsonArray;
    begin
        // Use topological sort to determine installation order
        InstallationOrder := TopologicalSorter.SortDependencies(DependencyGraph);
        
        // Validate installation order for circular dependencies
        ValidateInstallationOrder(InstallationOrder);
        
        exit(InstallationOrder);
    end;

    local procedure ExecuteDependencyInstallation(InstallationOrder: JsonArray; InstallationContext: JsonObject)
    var
        DependencyInstaller: Codeunit "Dependency Installer";
        OrderToken: JsonToken;
        DependencyObject: JsonObject;
        i: Integer;
    begin
        for i := 0 to InstallationOrder.Count() - 1 do begin
            InstallationOrder.Get(i, OrderToken);
            DependencyObject := OrderToken.AsObject();
            
            DependencyInstaller.InstallDependency(DependencyObject, InstallationContext);
        end;
    end;
}
```

### Feature Dependency Manager
```al
codeunit 50205 "Feature Dependency Manager"
{
    procedure ValidateFeatureDependencies(RequestedFeatures: JsonArray): JsonObject
    var
        ValidationResult: JsonObject;
        MissingDependencies: JsonArray;
        ConflictingFeatures: JsonArray;
    begin
        // Validate each requested feature
        MissingDependencies := FindMissingDependencies(RequestedFeatures);
        ConflictingFeatures := FindConflictingFeatures(RequestedFeatures);
        
        // Build validation result
        ValidationResult.Add('isValid', (MissingDependencies.Count() = 0) and (ConflictingFeatures.Count() = 0));
        ValidationResult.Add('missingDependencies', MissingDependencies);
        ValidationResult.Add('conflictingFeatures', ConflictingFeatures);
        
        exit(ValidationResult);
    end;

    local procedure FindMissingDependencies(RequestedFeatures: JsonArray): JsonArray
    var
        MissingDependencies: JsonArray;
        FeatureToken: JsonToken;
        FeatureObject: JsonObject;
        Dependencies: JsonArray;
        i: Integer;
    begin
        for i := 0 to RequestedFeatures.Count() - 1 do begin
            RequestedFeatures.Get(i, FeatureToken);
            FeatureObject := FeatureToken.AsObject();
            
            if FeatureObject.Get('dependencies', Dependencies) then
                ValidateFeatureDependencies(Dependencies, MissingDependencies);
        end;
        
        exit(MissingDependencies);
    end;
}
```

## Error Handling and Rollback

### Installation Error Handler
```al
codeunit 50206 "Installation Error Handler"
{
    procedure HandleInstallationError(ErrorInfo: ErrorInfo; InstallationContext: JsonObject): Boolean
    var
        ErrorAnalyzer: Codeunit "Installation Error Analyzer";
        RollbackManager: Codeunit "Installation Rollback Manager";
        RecoveryStrategy: Enum "Installation Recovery Strategy";
    begin
        // Analyze the installation error
        RecoveryStrategy := ErrorAnalyzer.AnalyzeInstallationError(ErrorInfo, InstallationContext);
        
        // Apply appropriate recovery strategy
        case RecoveryStrategy of
            RecoveryStrategy::"Retry Installation":
                exit(RetryInstallation(InstallationContext));
            RecoveryStrategy::"Partial Rollback":
                exit(RollbackManager.ExecutePartialRollback(InstallationContext));
            RecoveryStrategy::"Full Rollback":
                exit(RollbackManager.ExecuteFullRollback(InstallationContext));
            RecoveryStrategy::"Manual Intervention":
                exit(RequestManualIntervention(ErrorInfo, InstallationContext));
        end;
        
        exit(false);
    end;

    local procedure ExecuteRollback(InstallationContext: JsonObject): Boolean
    var
        RollbackSteps: JsonArray;
        StepToken: JsonToken;
        StepObject: JsonObject;
        i: Integer;
    begin
        // Get rollback steps from installation context
        InstallationContext.Get('rollbackSteps', RollbackSteps);
        
        // Execute rollback steps in reverse order
        for i := RollbackSteps.Count() - 1 downto 0 do begin
            RollbackSteps.Get(i, StepToken);
            StepObject := StepToken.AsObject();
            
            if not ExecuteRollbackStep(StepObject) then
                exit(false);
        end;
        
        exit(true);
    end;
}
```

### Installation Validator
```al
codeunit 50207 "Installation Validator"
{
    procedure ValidateInstallationReadiness(InstallationContext: JsonObject): Boolean
    var
        EnvironmentValidator: Codeunit "Environment Validator";
        PermissionValidator: Codeunit "Permission Validator";
        DependencyValidator: Codeunit "Dependency Validator";
        ValidationResults: JsonObject;
    begin
        // Validate environment prerequisites
        ValidationResults.Add('environment', EnvironmentValidator.ValidateEnvironment());
        
        // Validate installation permissions
        ValidationResults.Add('permissions', PermissionValidator.ValidateInstallationPermissions());
        
        // Validate dependencies
        ValidationResults.Add('dependencies', DependencyValidator.ValidateDependencies());
        
        // Check overall validation result
        exit(IsValidationSuccessful(ValidationResults));
    end;

    local procedure ValidatePostInstallation(InstallationContext: JsonObject): JsonObject
    var
        PostValidationResults: JsonObject;
        DataValidator: Codeunit "Data Integrity Validator";
        ConfigValidator: Codeunit "Configuration Validator";
    begin
        // Validate data integrity
        PostValidationResults.Add('dataIntegrity', DataValidator.ValidateDataIntegrity());
        
        // Validate configuration completeness
        PostValidationResults.Add('configuration', ConfigValidator.ValidateConfiguration());
        
        // Validate system functionality
        PostValidationResults.Add('functionality', ValidateSystemFunctionality());
        
        exit(PostValidationResults);
    end;
}
```

## Implementation Checklist

### Install Codeunit Setup
- [ ] Create install codeunit with proper subtype declaration
- [ ] Implement OnInstallAppPerCompany and OnInstallAppPerDatabase triggers
- [ ] Configure intelligent installation context analysis
- [ ] Set up comprehensive error handling and rollback mechanisms
- [ ] Initialize installation logging and telemetry

### Data Initialization
- [ ] Implement smart data setup with environment-specific defaults
- [ ] Configure master data initialization with business rules
- [ ] Set up intelligent configuration presets
- [ ] Initialize security settings and permission structures
- [ ] Create default number series and business setup data

### Dependency Management
- [ ] Implement dependency analysis and resolution
- [ ] Configure topological sorting for installation order
- [ ] Set up feature dependency validation
- [ ] Enable conflict detection and resolution
- [ ] Configure dependency update and maintenance

### Validation and Quality Assurance
- [ ] Implement pre-installation validation checks
- [ ] Configure post-installation verification
- [ ] Set up data integrity validation
- [ ] Enable configuration completeness checking
- [ ] Configure system functionality validation

## Best Practices

### Installation Design Principles
- Design installations to be idempotent and resumable
- Implement comprehensive validation before making changes
- Use intelligent defaults based on environment analysis
- Provide clear rollback capabilities for error scenarios
- Enable detailed logging for troubleshooting and auditing

### Error Handling Strategy
- Anticipate common installation failure scenarios
- Provide meaningful error messages with resolution guidance
- Implement graduated rollback strategies based on error severity
- Enable manual intervention points for complex scenarios
- Maintain installation state for recovery operations

## Anti-Patterns to Avoid

- Creating install codeunits without proper error handling
- Implementing data initialization without validation
- Ignoring dependency management and installation order
- Hardcoding installation settings without environment analysis
- Failing to provide rollback capabilities for error scenarios

## Related Topics
- [Extension Lifecycle Management](extension-lifecycle-management.md)
- [Company Initialize Codeunits](company-initialize-codeunits.md)
- [Setup Data Initialization](setup-data-initialization.md)