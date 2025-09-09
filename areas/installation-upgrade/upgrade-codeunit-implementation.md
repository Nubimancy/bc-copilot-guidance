---
title: "Upgrade Codeunit Implementation"
description: "Comprehensive upgrade codeunit patterns for Business Central extension lifecycle management with intelligent data migration and version transition"
area: "installation-upgrade"
difficulty: "advanced"
object_types: ["codeunit", "table"]
variable_types: ["ModuleInfo", "RecordRef", "JsonObject"]
tags: ["upgrade-codeunit", "data-migration", "version-management", "lifecycle-management", "schema-evolution"]
---

# Upgrade Codeunit Implementation

## Overview

Upgrade codeunit implementation provides comprehensive patterns for managing Business Central extension upgrades through intelligent data migration, schema evolution, and version transition management. This framework enables seamless upgrade processes with automatic rollback capabilities and data integrity validation.

## Core Implementation

### Intelligent Upgrade Engine

**Smart Upgrade Orchestrator**
```al
codeunit 50330 "Smart Upgrade Engine" implements "Upgrade Handler"
{
    var
        UpgradeSteps: List of [Codeunit "Upgrade Step"];
        DataMigrator: Codeunit "Intelligent Data Migrator";
        SchemaEvolver: Codeunit "Schema Evolution Manager";
        ValidationEngine: Codeunit "Upgrade Validation Engine";

    trigger OnUpgradePerDatabase()
    var
        ModuleInfo: ModuleInfo;
        UpgradeContext: JsonObject;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        UpgradeContext := InitializeUpgradeContext(ModuleInfo);
        
        ExecutePerDatabaseUpgrade(UpgradeContext);
    end;

    trigger OnUpgradePerCompany()
    var
        ModuleInfo: ModuleInfo;
        UpgradeContext: JsonObject;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        UpgradeContext := InitializeCompanyUpgradeContext(ModuleInfo);
        
        ExecutePerCompanyUpgrade(UpgradeContext);
    end;

    local procedure ExecutePerDatabaseUpgrade(UpgradeContext: JsonObject)
    var
        UpgradeStep: Codeunit "Upgrade Step";
        StepResult: JsonObject;
    begin
        LogUpgradeStart('PerDatabase', UpgradeContext);
        
        foreach UpgradeStep in GetDatabaseUpgradeSteps() do begin
            if UpgradeStep.IsApplicable(UpgradeContext) then begin
                StepResult := ExecuteUpgradeStep(UpgradeStep, UpgradeContext);
                
                if not GetStepSuccess(StepResult) then begin
                    HandleUpgradeFailure(UpgradeStep, StepResult, UpgradeContext);
                    Error('Upgrade failed at step: %1', UpgradeStep.GetStepName());
                end;
                
                LogUpgradeStepSuccess(UpgradeStep, StepResult);
            end;
        end;
        
        ValidateUpgradeCompletion('PerDatabase', UpgradeContext);
        LogUpgradeCompletion('PerDatabase', UpgradeContext);
    end;

    local procedure ExecutePerCompanyUpgrade(UpgradeContext: JsonObject)
    var
        UpgradeStep: Codeunit "Upgrade Step";
        StepResult: JsonObject;
        CompanyName: Text;
    begin
        CompanyName := CompanyName();
        LogUpgradeStart('PerCompany', UpgradeContext);
        
        foreach UpgradeStep in GetCompanyUpgradeSteps() do begin
            if UpgradeStep.IsApplicable(UpgradeContext) then begin
                StepResult := ExecuteUpgradeStepWithCompanyContext(UpgradeStep, UpgradeContext, CompanyName);
                
                if not GetStepSuccess(StepResult) then begin
                    HandleCompanyUpgradeFailure(UpgradeStep, StepResult, UpgradeContext, CompanyName);
                    Error('Company upgrade failed at step: %1 for company: %2', UpgradeStep.GetStepName(), CompanyName);
                end;
                
                LogCompanyUpgradeStepSuccess(UpgradeStep, StepResult, CompanyName);
            end;
        end;
        
        ValidateCompanyUpgradeCompletion(UpgradeContext, CompanyName);
        LogCompanyUpgradeCompletion(UpgradeContext, CompanyName);
    end;
}
```

### Schema Evolution Manager

**Intelligent Schema Transformation**
```al
codeunit 50331 "Schema Evolution Manager"
{
    var
        SchemaChanges: Dictionary of [Version, JsonArray];
        DataPreserver: Codeunit "Data Preservation Engine";
        IndexManager: Codeunit "Index Management Engine";

    procedure ExecuteSchemaEvolution(FromVersion: Version; ToVersion: Version; UpgradeContext: JsonObject): JsonObject
    var
        EvolutionResult: JsonObject;
        SchemaTransforms: JsonArray;
        Transform: JsonToken;
        TransformResult: JsonObject;
    begin
        SchemaTransforms := GetSchemaTransforms(FromVersion, ToVersion);
        EvolutionResult.Add('from_version', Format(FromVersion));
        EvolutionResult.Add('to_version', Format(ToVersion));
        EvolutionResult.Add('start_time', CurrentDateTime);
        
        foreach Transform in SchemaTransforms do begin
            TransformResult := ExecuteSchemaTransform(Transform.AsObject(), UpgradeContext);
            AddTransformResult(EvolutionResult, TransformResult);
            
            if not GetTransformSuccess(TransformResult) then begin
                HandleSchemaTransformFailure(Transform.AsObject(), TransformResult);
                Error('Schema evolution failed at transform: %1', Transform.AsObject().Get('transform_name').AsValue().AsText());
            end;
        end;
        
        EvolutionResult.Add('end_time', CurrentDateTime);
        EvolutionResult.Add('success', true);
        
        exit(EvolutionResult);
    end;

    local procedure ExecuteSchemaTransform(Transform: JsonObject; UpgradeContext: JsonObject): JsonObject
    var
        TransformResult: JsonObject;
        TransformType: Text;
    begin
        TransformType := Transform.Get('type').AsValue().AsText();
        TransformResult.Add('transform_name', Transform.Get('name').AsValue().AsText());
        TransformResult.Add('transform_type', TransformType);
        TransformResult.Add('start_time', CurrentDateTime);
        
        case TransformType of
            'add_table':
                TransformResult.Add('result', ExecuteAddTable(Transform, UpgradeContext));
            'add_field':
                TransformResult.Add('result', ExecuteAddField(Transform, UpgradeContext));
            'modify_field':
                TransformResult.Add('result', ExecuteModifyField(Transform, UpgradeContext));
            'remove_field':
                TransformResult.Add('result', ExecuteRemoveField(Transform, UpgradeContext));
            'add_index':
                TransformResult.Add('result', ExecuteAddIndex(Transform, UpgradeContext));
            'modify_table':
                TransformResult.Add('result', ExecuteModifyTable(Transform, UpgradeContext));
        end;
        
        TransformResult.Add('end_time', CurrentDateTime);
        exit(TransformResult);
    end;

    local procedure ExecuteAddField(Transform: JsonObject; UpgradeContext: JsonObject): Boolean
    var
        TableID: Integer;
        FieldName: Text;
        FieldType: Text;
        DefaultValue: Text;
        RecRef: RecordRef;
    begin
        TableID := Transform.Get('table_id').AsValue().AsInteger();
        FieldName := Transform.Get('field_name').AsValue().AsText();
        FieldType := Transform.Get('field_type').AsValue().AsText();
        
        if Transform.Contains('default_value') then
            DefaultValue := Transform.Get('default_value').AsValue().AsText();
        
        // Field addition is handled by platform during upgrade
        // This method handles any post-addition logic like setting default values
        if DefaultValue <> '' then
            SetDefaultFieldValues(TableID, FieldName, DefaultValue);
            
        LogSchemaChange('AddField', StrSubstNo('Table %1, Field %2', TableID, FieldName));
        exit(true);
    end;

    local procedure ExecuteModifyField(Transform: JsonObject; UpgradeContext: JsonObject): Boolean
    var
        TableID: Integer;
        FieldName: Text;
        OldFieldType: Text;
        NewFieldType: Text;
        DataMigrationResult: JsonObject;
    begin
        TableID := Transform.Get('table_id').AsValue().AsInteger();
        FieldName := Transform.Get('field_name').AsValue().AsText();
        OldFieldType := Transform.Get('old_field_type').AsValue().AsText();
        NewFieldType := Transform.Get('new_field_type').AsValue().AsText();
        
        // Preserve existing data before modification
        DataPreserver.PreserveFieldData(TableID, FieldName, OldFieldType);
        
        // Platform handles the actual field modification
        // This method handles data migration after modification
        DataMigrationResult := DataPreserver.MigrateFieldData(TableID, FieldName, OldFieldType, NewFieldType);
        
        LogSchemaChange('ModifyField', StrSubstNo('Table %1, Field %2: %3 -> %4', TableID, FieldName, OldFieldType, NewFieldType));
        exit(GetMigrationSuccess(DataMigrationResult));
    end;
}
```

### Intelligent Data Migrator

**Advanced Data Migration Engine**
```al
codeunit 50332 "Intelligent Data Migrator"
{
    var
        MigrationRules: Dictionary of [Text, Codeunit "Migration Rule"];
        DataValidator: Codeunit "Data Migration Validator";
        ConflictResolver: Codeunit "Migration Conflict Resolver";

    procedure MigrateTableData(SourceTableID: Integer; TargetTableID: Integer; MigrationContext: JsonObject): JsonObject
    var
        MigrationResult: JsonObject;
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        RecordCount: Integer;
        MigratedCount: Integer;
        ErrorCount: Integer;
    begin
        SourceRecRef.Open(SourceTableID);
        TargetRecRef.Open(TargetTableID);
        
        MigrationResult.Add('source_table', SourceTableID);
        MigrationResult.Add('target_table', TargetTableID);
        MigrationResult.Add('start_time', CurrentDateTime);
        
        RecordCount := SourceRecRef.Count();
        MigrationResult.Add('total_records', RecordCount);
        
        if SourceRecRef.FindSet() then
            repeat
                if MigrateSingleRecord(SourceRecRef, TargetRecRef, MigrationContext) then
                    MigratedCount += 1
                else
                    ErrorCount += 1;
            until SourceRecRef.Next() = 0;
        
        MigrationResult.Add('migrated_records', MigratedCount);
        MigrationResult.Add('error_count', ErrorCount);
        MigrationResult.Add('success_rate', MigratedCount / RecordCount);
        MigrationResult.Add('end_time', CurrentDateTime);
        
        SourceRecRef.Close();
        TargetRecRef.Close();
        
        exit(MigrationResult);
    end;

    local procedure MigrateSingleRecord(var SourceRecRef: RecordRef; var TargetRecRef: RecordRef; MigrationContext: JsonObject): Boolean
    var
        MigrationRule: Codeunit "Migration Rule";
        RuleName: Text;
        MigrationSuccess: Boolean;
    begin
        TargetRecRef.Init();
        MigrationSuccess := true;
        
        // Apply migration rules for field mapping and transformation
        foreach RuleName in GetApplicableMigrationRules(SourceRecRef, TargetRecRef) do begin
            if MigrationRules.Get(RuleName, MigrationRule) then begin
                if not MigrationRule.ApplyRule(SourceRecRef, TargetRecRef, MigrationContext) then begin
                    LogMigrationRuleFailure(RuleName, SourceRecRef, TargetRecRef);
                    MigrationSuccess := false;
                end;
            end;
        end;
        
        if MigrationSuccess then begin
            if not TryInsertMigratedRecord(TargetRecRef) then begin
                HandleInsertConflict(SourceRecRef, TargetRecRef, MigrationContext);
                MigrationSuccess := false;
            end;
        end;
        
        exit(MigrationSuccess);
    end;

    [TryFunction]
    local procedure TryInsertMigratedRecord(var TargetRecRef: RecordRef)
    begin
        TargetRecRef.Insert(true);
    end;

    local procedure HandleInsertConflict(var SourceRecRef: RecordRef; var TargetRecRef: RecordRef; MigrationContext: JsonObject)
    var
        ConflictResolution: JsonObject;
        ResolutionStrategy: Text;
    begin
        ConflictResolution := ConflictResolver.AnalyzeConflict(SourceRecRef, TargetRecRef);
        ResolutionStrategy := ConflictResolution.Get('strategy').AsValue().AsText();
        
        case ResolutionStrategy of
            'merge':
                ConflictResolver.MergeRecords(SourceRecRef, TargetRecRef, ConflictResolution);
            'update':
                ConflictResolver.UpdateExistingRecord(SourceRecRef, TargetRecRef, ConflictResolution);
            'skip':
                LogSkippedRecord(SourceRecRef, ConflictResolution);
        end;
    end;

    procedure ValidateMigrationIntegrity(MigrationResults: JsonArray): JsonObject
    var
        IntegrityReport: JsonObject;
        ValidationResults: JsonArray;
        MigrationResult: JsonToken;
    begin
        foreach MigrationResult in MigrationResults do
            ValidationResults.Add(DataValidator.ValidateTableMigration(MigrationResult.AsObject()));
        
        IntegrityReport.Add('validation_results', ValidationResults);
        IntegrityReport.Add('overall_integrity', CalculateOverallIntegrity(ValidationResults));
        IntegrityReport.Add('data_consistency_check', ValidateDataConsistency(MigrationResults));
        
        exit(IntegrityReport);
    end;
}
```

### Upgrade Rollback System

**Intelligent Rollback Management**
```al
codeunit 50333 "Upgrade Rollback Manager"
{
    var
        RollbackPlan: JsonObject;
        BackupManager: Codeunit "Upgrade Backup Manager";
        StateManager: Codeunit "Upgrade State Manager";

    procedure CreateRollbackPlan(UpgradeSteps: JsonArray): JsonObject
    var
        Plan: JsonObject;
        RollbackSteps: JsonArray;
        UpgradeStep: JsonToken;
        RollbackStep: JsonObject;
    begin
        Plan.Add('created_at', CurrentDateTime);
        Plan.Add('upgrade_steps_count', UpgradeSteps.Count());
        
        foreach UpgradeStep in UpgradeSteps do begin
            RollbackStep := CreateRollbackStep(UpgradeStep.AsObject());
            if not IsNullOrEmpty(RollbackStep) then
                RollbackSteps.Add(RollbackStep);
        end;
        
        Plan.Add('rollback_steps', RollbackSteps);
        Plan.Add('rollback_feasible', RollbackSteps.Count() > 0);
        
        exit(Plan);
    end;

    procedure ExecuteRollback(RollbackPlan: JsonObject): JsonObject
    var
        RollbackResult: JsonObject;
        RollbackSteps: JsonArray;
        Step: JsonToken;
        StepResult: JsonObject;
        SuccessfulSteps: Integer;
    begin
        RollbackResult.Add('rollback_started', CurrentDateTime);
        
        RollbackPlan.Get('rollback_steps', RollbackSteps);
        
        // Execute rollback steps in reverse order
        foreach Step in RollbackSteps do begin
            StepResult := ExecuteRollbackStep(Step.AsObject());
            
            if GetRollbackStepSuccess(StepResult) then
                SuccessfulSteps += 1
            else begin
                LogRollbackStepFailure(Step.AsObject(), StepResult);
                // Continue with other rollback steps even if one fails
            end;
        end;
        
        RollbackResult.Add('total_steps', RollbackSteps.Count());
        RollbackResult.Add('successful_steps', SuccessfulSteps);
        RollbackResult.Add('rollback_completed', CurrentDateTime);
        RollbackResult.Add('success_rate', SuccessfulSteps / RollbackSteps.Count());
        
        exit(RollbackResult);
    end;

    local procedure ExecuteRollbackStep(RollbackStep: JsonObject): JsonObject
    var
        StepResult: JsonObject;
        StepType: Text;
        StepName: Text;
    begin
        StepType := RollbackStep.Get('type').AsValue().AsText();
        StepName := RollbackStep.Get('name').AsValue().AsText();
        
        StepResult.Add('step_name', StepName);
        StepResult.Add('step_type', StepType);
        StepResult.Add('started_at', CurrentDateTime);
        
        case StepType of
            'restore_backup':
                StepResult.Add('success', BackupManager.RestoreBackup(RollbackStep));
            'revert_data':
                StepResult.Add('success', RevertDataChanges(RollbackStep));
            'restore_schema':
                StepResult.Add('success', RestoreSchemaState(RollbackStep));
            'cleanup_temp_data':
                StepResult.Add('success', CleanupTemporaryData(RollbackStep));
        end;
        
        StepResult.Add('completed_at', CurrentDateTime);
        exit(StepResult);
    end;

    local procedure RevertDataChanges(RollbackStep: JsonObject): Boolean
    var
        RevertActions: JsonArray;
        Action: JsonToken;
        RevertSuccess: Boolean;
    begin
        RevertSuccess := true;
        RollbackStep.Get('revert_actions', RevertActions);
        
        foreach Action in RevertActions do
            if not ExecuteRevertAction(Action.AsObject()) then
                RevertSuccess := false;
                
        exit(RevertSuccess);
    end;
}
```

### Upgrade Validation Engine

**Comprehensive Upgrade Validation**
```al
codeunit 50334 "Upgrade Validation Engine"
{
    procedure ValidateUpgradeReadiness(UpgradeContext: JsonObject): JsonObject
    var
        ValidationResult: JsonObject;
        ReadinessChecks: JsonArray;
    begin
        ReadinessChecks.Add(ValidateSystemRequirements(UpgradeContext));
        ReadinessChecks.Add(ValidateDataIntegrity(UpgradeContext));
        ReadinessChecks.Add(ValidateDependencies(UpgradeContext));
        ReadinessChecks.Add(ValidateBackupReadiness(UpgradeContext));
        ReadinessChecks.Add(ValidateResourceAvailability(UpgradeContext));
        
        ValidationResult.Add('readiness_checks', ReadinessChecks);
        ValidationResult.Add('overall_readiness', CalculateOverallReadiness(ReadinessChecks));
        ValidationResult.Add('blocking_issues', FindBlockingIssues(ReadinessChecks));
        
        exit(ValidationResult);
    end;

    procedure ValidateUpgradeCompletion(UpgradeContext: JsonObject): JsonObject
    var
        CompletionValidation: JsonObject;
        ValidationChecks: JsonArray;
    begin
        ValidationChecks.Add(ValidateDataMigrationSuccess(UpgradeContext));
        ValidationChecks.Add(ValidateSchemaEvolution(UpgradeContext));
        ValidationChecks.Add(ValidateFunctionalityIntegrity(UpgradeContext));
        ValidationChecks.Add(ValidatePerformanceImpact(UpgradeContext));
        
        CompletionValidation.Add('validation_checks', ValidationChecks);
        CompletionValidation.Add('upgrade_successful', AllChecksSuccessful(ValidationChecks));
        CompletionValidation.Add('post_upgrade_actions', GetRequiredPostUpgradeActions(ValidationChecks));
        
        exit(CompletionValidation);
    end;

    local procedure ValidateDataIntegrity(UpgradeContext: JsonObject): JsonObject
    var
        IntegrityCheck: JsonObject;
        DataIntegrityValidator: Codeunit "Data Integrity Validator";
    begin
        IntegrityCheck.Add('check_name', 'Data Integrity');
        IntegrityCheck.Add('check_result', DataIntegrityValidator.ValidateAllTables());
        IntegrityCheck.Add('referential_integrity', DataIntegrityValidator.ValidateReferentialIntegrity());
        IntegrityCheck.Add('data_consistency', DataIntegrityValidator.ValidateDataConsistency());
        
        exit(IntegrityCheck);
    end;

    local procedure ValidateFunctionalityIntegrity(UpgradeContext: JsonObject): JsonObject
    var
        FunctionalityCheck: JsonObject;
        FunctionTester: Codeunit "Post Upgrade Function Tester";
    begin
        FunctionalityCheck.Add('check_name', 'Functionality Integrity');
        FunctionalityCheck.Add('critical_functions', FunctionTester.TestCriticalFunctions());
        FunctionalityCheck.Add('integration_points', FunctionTester.TestIntegrationPoints());
        FunctionalityCheck.Add('user_workflows', FunctionTester.TestUserWorkflows());
        
        exit(FunctionalityCheck);
    end;
}
```

## Implementation Checklist

### Planning and Preparation Phase
- [ ] **Upgrade Strategy**: Develop comprehensive upgrade strategy and approach
- [ ] **Version Mapping**: Map upgrade paths between different versions
- [ ] **Data Migration Planning**: Plan data migration and transformation requirements
- [ ] **Rollback Planning**: Develop rollback procedures and recovery plans
- [ ] **Testing Strategy**: Create comprehensive upgrade testing strategy

### Framework Development
- [ ] **Upgrade Engine**: Build intelligent upgrade orchestration engine
- [ ] **Schema Evolution**: Create schema evolution and migration framework
- [ ] **Data Migrator**: Implement comprehensive data migration system
- [ ] **Validation Engine**: Build upgrade validation and verification system
- [ ] **Rollback System**: Create automated rollback and recovery capabilities

### Implementation and Testing
- [ ] **Upgrade Codeunits**: Implement upgrade codeunits for all versions
- [ ] **Migration Scripts**: Create data migration and transformation scripts
- [ ] **Validation Rules**: Implement upgrade validation and integrity checks
- [ ] **Test Scenarios**: Create comprehensive upgrade test scenarios
- [ ] **Performance Testing**: Test upgrade performance and resource impact

### Deployment and Monitoring
- [ ] **Deployment Procedures**: Establish upgrade deployment procedures
- [ ] **Monitoring Systems**: Implement upgrade progress monitoring
- [ ] **Error Handling**: Create comprehensive error handling and recovery
- [ ] **Documentation**: Create upgrade documentation and procedures
- [ ] **Support Procedures**: Establish upgrade support and troubleshooting

## Best Practices

### Upgrade Design Principles
- **Backward Compatibility**: Maintain backward compatibility where possible
- **Incremental Upgrades**: Design incremental upgrade paths for large changes
- **Data Preservation**: Ensure critical data is preserved during upgrades
- **Rollback Capability**: Always provide rollback capabilities for upgrades
- **Validation Comprehensive**: Implement comprehensive validation at each step

### Data Migration Excellence
- **Data Integrity**: Maintain data integrity throughout migration process
- **Performance Optimization**: Optimize data migration for performance
- **Error Handling**: Handle migration errors gracefully with detailed logging
- **Validation Testing**: Validate migrated data for accuracy and completeness
- **Conflict Resolution**: Handle data conflicts intelligently during migration

### Testing and Validation
- **Comprehensive Testing**: Test upgrades in realistic scenarios and environments
- **Automated Validation**: Automate upgrade validation and integrity checks
- **Performance Testing**: Test upgrade performance impact and resource usage
- **Rollback Testing**: Test rollback procedures and recovery mechanisms
- **User Acceptance Testing**: Include user acceptance testing in upgrade validation

## Anti-Patterns to Avoid

### Design Anti-Patterns
- **Monolithic Upgrades**: Creating monolithic upgrade processes that are difficult to test and debug
- **Breaking Changes**: Introducing unnecessary breaking changes during upgrades
- **Data Loss Risk**: Creating upgrade processes that risk data loss
- **No Rollback Plan**: Not providing rollback capabilities for failed upgrades
- **Insufficient Validation**: Not implementing comprehensive validation and integrity checks

### Implementation Anti-Patterns
- **Manual Processes**: Relying on manual processes for critical upgrade steps
- **Error Suppression**: Suppressing errors during upgrade without proper handling
- **Resource Neglect**: Not considering resource requirements and performance impact
- **Testing Shortcuts**: Skipping comprehensive testing of upgrade procedures
- **Documentation Gaps**: Not documenting upgrade procedures and troubleshooting

### Deployment Anti-Patterns
- **Production Testing**: Testing upgrade procedures for the first time in production
- **Insufficient Backup**: Not creating adequate backups before upgrade
- **Timing Issues**: Running upgrades during high-usage periods
- **Support Unpreparedness**: Not preparing support teams for upgrade issues
- **Communication Failures**: Not communicating upgrade plans and impacts to stakeholders